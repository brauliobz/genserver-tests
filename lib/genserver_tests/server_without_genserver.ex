defmodule GenserverTests.ServerWithoutGenserver do
  require Logger

  def my_start_link() do
    :proc_lib.start_link(__MODULE__, :my_init, [:erlang.self()])
  end

  def my_init(parent_pid) do
    state = 0
    current_pid = :erlang.self()
    debug_state = :sys.debug_options([])
    :erlang.register(__MODULE__, current_pid)
    :proc_lib.init_ack(parent_pid, {:ok, current_pid})
    my_loop(state, parent_pid, debug_state)
  end

  def child_spec(_args) do
    parent_pid = :erlang.self()

    %{
      id: __MODULE__,
      start: {__MODULE__, :my_init, [parent_pid]}
    }
  end

  def my_loop(state, parent_pid, debug_state) do
    receive do
      {:incr} ->
        debug_state = :sys.handle_debug(debug_state, &write_debug/3, state, {:in, :incr})
        my_loop(state + 1, parent_pid, debug_state)

      {from_pid, :get} ->
        debug_state = :sys.handle_debug(debug_state, &write_debug/3, state, {:in, :get})
        send(from_pid, {:get, state})
        my_loop(state, parent_pid, debug_state)

      {:system, from, request} ->
        Logger.info("Received :system message", from: from, request: request)
        :sys.handle_system_msg(request, from, parent_pid, __MODULE__, debug_state, state)

      other ->
        Logger.error("Unhandled message received", msg: other)
        my_loop(state, parent_pid, debug_state)
    end
  end

  def system_continue(parent_pid, debug_state, state) do
    my_loop(state, parent_pid, debug_state)
  end

  def system_terminate(reason, _parent, _debug_state, _state) do
    exit(reason)
  end

  def system_get_state(state) do
    {:ok, state}
  end

  def system_replace_state(state_function, state) do
    new_state = state_function.(state)
    {:ok, new_state, new_state}
  end

  def write_debug(io_device, event, name) do
    :io.format(io_device, "~p event = ~p~n", [name, event])
  end
end
