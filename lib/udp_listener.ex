defmodule FrasierBox.UdpListener do
  use GenServer
  alias FrasierBox.CommandProcessor
  require Logger

  def start_link(port) do
    GenServer.start_link(__MODULE__, [port], [])
  end

  def init([port]) do
    {:ok, socket} = :gen_udp.open(port, [:binary, {:active, true}])
    {:ok, %{socket: socket}}
  end

  def handle_info({:udp, _, src, _port, payload}, state) do
    Logger.debug("Message received from #{inspect src}: #{inspect payload}")
    CommandProcessor.process_command(payload)
    {:noreply, state}
  end

  def handle_info(msg, state) do
    {:noreply, state}
  end

  def terminate(reason, %{socket: socket}) do
    Logger.warn("UDP listener terminating: #{inspect reason}")
    :gen_udp.close(socket)
    :ok
  end
end
