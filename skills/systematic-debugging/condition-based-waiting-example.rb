# Complete implementation of condition-based waiting utilities
# From: test infrastructure improvements (2025-10-03)
# Context: Fixed 15 flaky tests by replacing arbitrary sleeps
#
# Drop these in spec/support/ and include the module in your RSpec config.

module ConditionWaiting
  # Wait for a specific event type to appear in a thread.
  #
  # thread_manager - object responding to #events(thread_id)
  # thread_id      - thread to check for events
  # event_type     - type of event to wait for
  # timeout        - maximum seconds to wait (default 5)
  # returns        - the first matching event
  #
  # Example:
  #   wait_for_event(thread_manager, agent_thread_id, :tool_result)
  def wait_for_event(thread_manager, thread_id, event_type, timeout: 5)
    deadline = monotonic_now + timeout

    loop do
      event = thread_manager.events(thread_id).find { |e| e.type == event_type }
      return event if event

      raise "Timeout waiting for #{event_type} event after #{timeout}s" if monotonic_now > deadline

      sleep 0.01 # Poll every 10ms for efficiency
    end
  end

  # Wait for a specific number of events of a given type.
  #
  # Example:
  #   # Wait for 2 agent_message events (initial response + continuation)
  #   wait_for_event_count(thread_manager, agent_thread_id, :agent_message, 2)
  def wait_for_event_count(thread_manager, thread_id, event_type, count, timeout: 5)
    deadline = monotonic_now + timeout

    loop do
      matching = thread_manager.events(thread_id).select { |e| e.type == event_type }
      return matching if matching.length >= count

      if monotonic_now > deadline
        raise "Timeout waiting for #{count} #{event_type} events after #{timeout}s (got #{matching.length})"
      end

      sleep 0.01
    end
  end

  # Wait for an event matching a custom predicate.
  # Useful when you need to check event data, not just type.
  #
  # Example:
  #   # Wait for tool_result with specific id
  #   wait_for_event_match(
  #     thread_manager,
  #     agent_thread_id,
  #     'tool_result with id=call_123'
  #   ) { |e| e.type == :tool_result && e.data[:id] == 'call_123' }
  def wait_for_event_match(thread_manager, thread_id, description, timeout: 5, &predicate)
    deadline = monotonic_now + timeout

    loop do
      event = thread_manager.events(thread_id).find(&predicate)
      return event if event

      raise "Timeout waiting for #{description} after #{timeout}s" if monotonic_now > deadline

      sleep 0.01
    end
  end

  private

  # Monotonic clock so the timeout is unaffected by wall-clock changes.
  def monotonic_now
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
end

# Usage example from actual debugging session:
#
# BEFORE (flaky):
# ---------------
# message = agent.send_message('Execute tools')
# sleep 0.3                                   # Hope tools start in 300ms
# agent.abort
# message.value
# sleep 0.05                                  # Hope results arrive in 50ms
# expect(tool_results.length).to eq(2)        # Fails randomly
#
# AFTER (reliable):
# ----------------
# message = agent.send_message('Execute tools')
# wait_for_event_count(thread_manager, thread_id, :tool_call, 2)   # Wait for tools to start
# agent.abort
# message.value
# wait_for_event_count(thread_manager, thread_id, :tool_result, 2) # Wait for results
# expect(tool_results.length).to eq(2) # Always succeeds
#
# Result: 60% pass rate → 100%, 40% faster execution
