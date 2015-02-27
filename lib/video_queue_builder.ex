defmodule FrasierBox.VideoQueueBuilder do
  use GenServer
  alias FrasierBox.VideoBlacklist
  require Logger

  def start_link(videos_path) do
    GenServer.start_link(__MODULE__, [videos_path], [name: __MODULE__])
  end

  def init([videos_path]) do
    ts = :os.timestamp
    :random.seed(ts)
    {:ok, %{videos_path: videos_path}}
  end

  # Client

  def build_queue(video_count) do
    GenServer.call(__MODULE__, {:build_queue, video_count})
  end

  # Server

  def handle_call({:build_queue, video_count}, _from, state) do
    result = case File.ls(state.videos_path) do
      {:ok, files} ->
        blacklist = VideoBlacklist.get_blacklist
        queue = build_queue(video_count, files, blacklist, [])
        {:ok, queue}
      _ ->
        {:error, :build_queue}
    end
    {:reply, result, state}
  end

  defp build_queue(video_count, files, blacklist, acc) when length(acc) < video_count do
    rindex = random_int(0, length(files))
    candidate = Enum.at(files, rindex)
    if candidate in blacklist or candidate in acc do
      build_queue(video_count, files, blacklist, acc)
    else
      build_queue(video_count, files, blacklist, [candidate|acc])
    end
  end

  defp build_queue(video_count, _, _, acc) when length(acc) == video_count do
    Enum.reverse(acc)
  end

  defp random_int(low, high) do
    trunc(:random.uniform() * (high - low) + low)
  end

  def terminate(reason, _state) do
    Logger.warn("Video queue builder terminating: #{inspect reason}")
    :ok
  end
end
