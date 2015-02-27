defmodule FrasierBox.VideoPlayer do
  use GenServer
  require Logger

  def start_link(video_path) do
    GenServer.start_link(__MODULE__, [video_path], [name: __MODULE__])
  end

  def init([video_path]) do
    {:ok, %{video_path: video_path, video_queue: [], playing: nil}}
  end

  # Client

  def play_video(video_name) do
    GenServer.call(__MODULE__, {:play, video_name})
  end

  def play_videos(video_names) when is_list(video_names) do
    play_videos(video_names, [])
  end

  defp play_videos([h|t], acc) do
    result = GenServer.call(__MODULE__, {:play, h})
    play_videos(t, [{h, result}|acc])
  end

  defp play_videos([], acc) do
    Enum.reverse(acc)
  end

  # Server

  def handle_call({:play, video_name}, _from, state) do
    video_path = Path.join(state.video_path, video_name)
    new_queue = add_video_to_queue(self, video_path, state.video_queue)
    new_state = try_play_video(new_queue, state)
    {:reply, :ok, new_state}
  end

  def handle_call(msg, state) do
    {:reply, :ok, state}
  end

  def handle_info({:video_started, {ref, player, video_path}}, state) do
    Logger.debug("Video started: #{inspect ref} (#{video_path})")
    {:noreply, state}
  end

  def handle_info({:video_finished, key = {ref, player, video_path}, {output, rc}}, state) do
    Logger.debug("Video finished: #{inspect ref} (#{video_path})")
    new_queue = List.delete(state.video_queue, key)
    new_state = try_play_video(new_queue, state)
    {:noreply, new_state}
  end

  def handle_info(msg, state) do
    Logger.debug("Unknown message received: #{inspect msg}")
    {:noreply, state}
  end

  def terminate(reason, _state) do
    Logger.warn("Video player terminating: #{inspect reason}")
    :ok
  end

  defp try_play_video(new_queue = [key|_], state) do
    play_now = case state.playing do
      nil -> true
      pid when is_pid(pid) -> if Process.alive?(pid), do: false, else: true
    end
    if play_now do
      %{state | video_queue: new_queue, playing: play_video_now(key)}
    else
      %{state | video_queue: new_queue}
    end
  end

  defp try_play_video(new_queue = [], state) do
    Logger.debug("Video queue empty")
    %{state | video_queue: new_queue}
  end

  defp play_video_now(key = {ref, player, video_path}) do
    spawn_link(fn ->
      send(player, {:video_started, key})
      result = System.cmd("omxplayer", ["-b", video_path])
      send(player, {:video_finished, key, result})
    end)
  end

  def add_video_to_queue(player, video_path, queue) do
    ref = make_ref
    key = {ref, player, video_path}
    Enum.reverse([key|queue])
  end
end
