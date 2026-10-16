defmodule Decorated.Mocks.HealthyGenServer do
  use Decorated.Mock.GenServer, hooks: [debug_hooks: true, exception_hooks: true]

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl GenServer
  def init(opts), do: {:ok, opts, {:continue, :continue}}

  @impl GenServer
  def handle_continue(:continue, state), do: {:noreply, state}

  @impl GenServer
  def handle_call(:call, from, state), do: {:reply, from, state}

  @impl GenServer
  def handle_cast(:cast, state), do: {:noreply, state}

  @impl GenServer
  def handle_info(:info, state), do: {:noreply, state}

  @impl GenServer
  def terminate(reason, _state), do: {:ok, reason}
end

defmodule Decorated.Mocks.ThrowingGenServer do
  use Decorated.Mock.GenServer, hooks: [debug_hooks: true, exception_hooks: true]

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl GenServer
  def init(_opts), do: throw({__MODULE__, :init_failure})

  @impl GenServer
  def handle_continue(:continue, _state), do: throw({__MODULE__, :continue_failure})

  @impl GenServer
  def handle_call(:call, _from, _state), do: throw({__MODULE__, :call_failure})

  @impl GenServer
  def handle_cast(:cast, _state), do: throw({__MODULE__, :cast_failure})

  @impl GenServer
  def handle_info(:info, _state), do: throw({__MODULE__, :info_failure})

  @impl GenServer
  def terminate(_reason, _state), do: throw({__MODULE__, :terminate_failure})
end

defmodule Decorated.Mocks.ExceptionGenServer do
  use Decorated.Mock.GenServer, hooks: [debug_hooks: true, exception_hooks: true]

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl GenServer
  def init(_opts), do: raise("init_failure")

  @impl GenServer
  def handle_continue(:continue, _state), do: raise("continue_failure")

  @impl GenServer
  def handle_call(:call, _from, _state), do: raise("call_failure")

  @impl GenServer
  def handle_cast(:cast, _state), do: raise("cast_failure")

  @impl GenServer
  def handle_info(:info, _state), do: raise("info_failure")

  @impl GenServer
  def terminate(_reason, _state), do: raise("terminate_failure")
end

defmodule Decorated.Mocks.ExitingGenServer do
  use Decorated.Mock.GenServer, hooks: [debug_hooks: true, exception_hooks: true]

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl GenServer
  def init(_opts), do: exit(:init_failure)

  @impl GenServer
  def handle_continue(:continue, _state), do: exit(:continue_failure)

  @impl GenServer
  def handle_call(:call, _from, _state), do: exit(:call_failure)

  @impl GenServer
  def handle_cast(:cast, _state), do: exit(:cast_failure)

  @impl GenServer
  def handle_info(:info, _state), do: exit(:info_failure)

  @impl GenServer
  def terminate(_reason, _state), do: exit(:terminate_failure)
end
