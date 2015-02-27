defmodule FrasierBox.Ets do
  defmacro def_ets_manager(supervisor, manager, managed) do
    quote do
      defmodule unquote(supervisor) do
        use Supervisor

        def start_link do
          Supervisor.start_link(__MODULE__, [])
        end

        def init([]) do
          children = [
            worker(unquote(managed), []),
            worker(unquote(manager), [])
          ]

          supervise(children, strategy: :one_for_one)
        end
      end

      defmodule unquote(manager) do
        use GenServer
        require Logger

        def start_link do
          GenServer.start_link(__MODULE__, [], [name: unquote(manager)])
        end

        def gift do
          GenServer.cast(unquote(manager), {:gift, nil})
        end

        def init([]) do
          Process.flag(:trap_exit, true)
          gift()
          {:ok, %{table_id: nil}}
        end

        def handle_call(_, _, state) do
          {:reply, :ok, state}
        end

        def handle_cast({:gift, data}, state) do
          server = Process.whereis(unquote(managed))
          Process.link(server)

          table_id = :ets.new(__MODULE__, [:private])

          unless is_nil(data) do
            :ets.insert(table_id, data)
          end

          :ets.setopts(table_id, {:heir, self(), data})
          :ets.give_away(table_id, server, data)

          {:noreply, %{state | table_id: table_id}}
        end

        def handle_cast(_, state) do
          {:noreply, state}
        end
        def handle_info({:EXIT, _pid, :killed}, state) do
          {:noreply, state}
        end

        def handle_info({:EXIT, _pid, _other}, state) do
          {:noreply, state}
        end

        def handle_info({:"ETS-TRANSFER", table_id, _pid, data}, state) do
          server = wait_for_server()
          Process.link(server)
          :ets.give_away(table_id, server, data)
          {:noreply, %{state | table_id: table_id}}
        end

        def wait_for_server do
          case Process.whereis(unquote(managed)) do
            nil ->
              :timer.sleep(1)
              wait_for_server()
            pid -> pid
          end
        end

      end
    end
  end
end
