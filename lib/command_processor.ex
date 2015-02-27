defmodule FrasierBox.CommandProcessor do
  use GenServer
  alias FrasierBox.VideoPlayer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init([]) do
    {:ok, %{started: :os.timestamp, cmd_count: 0}}
  end

  def process_command(command) when is_binary(command) do
    GenServer.cast(__MODULE__, command)
  end

  def handle_cast(command, state) do
    cmd_count = state.cmd_count + 1
    Logger.debug("Command #{cmd_count} received: #{inspect command}")
    :ok = dispatch(command)
    {:noreply, %{state | cmd_count: cmd_count}}
  end

  def dispatch(<<0>>) do
    Logger.debug("Start command received")
    result = VideoPlayer.play_videos(["test0001.avi", "test0002.avi", "test0003.avi"])
    Logger.debug(inspect result)
    #case VideoPlayer.play_video("test0001.avi") do
    #  :ok -> Logger.debug("Video started")
    #  _ -> Logger.debug("Video failed to start")
    #end
    :ok
  end

  def dispatch(other) do
    Logger.warn("Unrecognized command: #{inspect other}")
    :ok
  end

  def terminate(reason, _state) do
    Logger.warn("Command processor terminating: #{inspect reason}")
    :ok
  end
end
