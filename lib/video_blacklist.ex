defmodule FrasierBox.VideoBlacklist do
  use GenServer
  require Logger
  use Timex

  @num_days   Application.get_env(:frabox, :blacklist_num_days)

  def start_link do
    GenServer.start_link(__MODULE__, [@num_days], [name: __MODULE__])
  end

  def init([num_days]) do
    Logger.debug("Number of days to blacklist videos: #{num_days}")
    {:ok, %{table_id: nil, num_days: num_days}}
  end

  def check do
    GenServer.cast(__MODULE__, :check)
  end

  def add_videos(videos) do
    GenServer.call(__MODULE__, {:add_videos, videos})
  end

  def get_blacklist do
    GenServer.call(__MODULE__, :get_blacklist)
  end

  def handle_cast(:check, state) do
    table_id = state.table_id
    Logger.info("Table ID: #{table_id}, data: #{inspect(:ets.tab2list(table_id))}")
    {:noreply, state}
  end

  def handle_cast(_, state) do
    {:noreply, state}
  end

  def handle_call(:get_blacklist, _from, state) do
    blacklist = :ets.foldr(fn({video, date}, acc) ->
      now = Date.now
      video_date = Date.from(date)
      day_diff = Date.diff(video_date, now, :days)
      if day_diff <= state.num_days, do: [video|acc], else: acc
    end, [], state.table_id)
    {:reply, blacklist, state}
  end

  def handle_call({:add_videos, videos}, _from, state) do
    Enum.each(videos, fn(video) -> :ets.insert(state.table_id, {video, :erlang.date}) end)
    {:reply, :ok, state}
  end

  def handle_call(_, _, state) do
    {:reply, :ok, state}
  end

  # ETS transfer
  def handle_info({:"ETS-TRANSFER", table_id, pid, _data}, state) do
    Logger.debug("Video blacklist got ETS table #{table_id}")
    {:noreply, %{state | table_id: table_id}}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
