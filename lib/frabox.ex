defmodule FrasierBox do
  use Application

  @udp_port     Application.get_env(:frabox, :udp_listener_port)
  @videos_path  Application.get_env(:frabox, :videos_path)
  @video_count  Application.get_env(:frabox, :video_count)

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(FrasierBox.UdpListener, [@udp_port]),
      worker(FrasierBox.CommandProcessor, [@video_count]),
      supervisor(FrasierBox.VideoBlacklistSupervisor, []),
      worker(FrasierBox.VideoQueueBuilder, [@videos_path]),
      worker(FrasierBox.VideoPlayer, [@videos_path])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
