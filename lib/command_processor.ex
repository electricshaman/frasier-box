defmodule FrasierBox.CommandProcessor do
  use GenServer
  alias FrasierBox.VideoPlayer
  alias FrasierBox.VideoQueueBuilder
  alias FrasierBox.VideoBlacklist
  require Logger

  def start_link(video_count) do
    GenServer.start_link(__MODULE__, [video_count], [name: __MODULE__])
  end

  def init([video_count]) do
    {:ok, %{started: :os.timestamp, cmd_count: 0, video_count: video_count}}
  end

  def process_command(command) when is_binary(command) do
    GenServer.cast(__MODULE__, command)
  end

  def handle_cast(command, state) do
    cmd_count = state.cmd_count + 1
    Logger.debug("Command #{cmd_count} received: #{inspect command}")
    case dispatch(command, state) do
      {:error, _} ->
        Logger.warn("Failed to dispatch command: #{inspect command}")
      _ ->
        :ok
    end
    {:noreply, %{state | cmd_count: cmd_count}}
  end

  @doc """
  Start command
  """
  def dispatch(<<0>>, state) do
    {:ok, queue} = VideoQueueBuilder.build_queue(state.video_count)
    response = List.duplicate(:ok, state.video_count)
    :ok = VideoBlacklist.add_videos(queue)
    result = VideoPlayer.play_videos(queue)
    case result do
      ^response -> :ok
      _ -> {:error, :dispatch_start}
    end
  end

  @doc """
  Stop command
  """
  def dispatch(<<1>>, state) do
    VideoPlayer.reset
  end

  def dispatch(other, state) do
    Logger.warn("Unrecognized command: #{inspect other}")
    :ok
  end

  def terminate(reason, _state) do
    Logger.warn("Command processor terminating: #{inspect reason}")
    :ok
  end
end
