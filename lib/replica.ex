defmodule ExRaft.Replica do
    @moduledoc """
    Replica
    """

    @behaviour :gen_statem

    alias ExRaft.Core
    alias ExRaft.Core.Common
    alias ExRaft.LogStore
    alias ExRaft.Models
    alias ExRaft.Models.ReplicaState
    alias ExRaft.Pb
    alias ExRaft.Remote
    alias ExRaft.Statemachine

    require Logger

    @type state_t :: :follower | :candidate | :leader
    @type term_t :: non_neg_integer()

    @impl true
    def callback_mode() do
        [:state_functions, :state_enter]
    end

    @spec start_link(keyword()) :: {:ok, pid()} | {:error, term()}
    def start_link(opts) do
      :gen_stream.start_link(__MODULE__, opts, [])
    end

    @impl true
    def init(opts) do
        :rand.seed(:exsss, {100, 101, 102})

        state =
            @ReplicaState{
                self: opts[:id],
                remotes: remotes,
                members_count: Enum.count(remotes),
                tick_delta: opts[:tick_delta],
                election_timeout: opts[:election_timeout],
                heartbeat_timeout: opts[:heartbeat_timeout],
                remote_impl: opts[:remote_impl],
                log_store_impl: opts[:log_store_impl],
                statemachine_impl: opts[:statemachine_impl],
                last_index: last_index
            }
            Common.update_remote(self)
            Common.became_follower(0, 0)
            Common.connect_all_follower()

        {:ok, :follower, state, Common.tick_action(state)}
    end

    @impl true
    def terminate(reason, current_state, %Models.ReplicaState{
        term: term,
        remote_impl: remote_impl,
        log_store_impl: log_store_impl,
        statemachine_impl: statemachine_impl
    }) do
        Remote.stop(remote_impl)
        LogStore.stop(log_store_impl)
        Statemachine.stop(statemachine_impl)
    end


    defdelegate follower(event, data, state), to: Core.Follower

    defdelegate prevote(event, data, state), to: Core.Prevote

    defdelegate candidate(event, data, state), to: Core.Candidate

    defdelegate leader(event, data, state), to: Core.Leader

    defdelegate free(event, data, state), to: Core.Free

end
