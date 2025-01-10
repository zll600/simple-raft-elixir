defmodule ExRaft.Core.Follower do
  @moduledoc """
  Follower Role Module

  Module :gen_state callbacks for follower role
  """

  import ExRaft.Guards

  alias ExRaft.Core.Common
  alias ExRaft.MessageHandlers
  alias ExRaft.Models.ReplicaState
  alias ExRaft.Pb

  require Logger

end
