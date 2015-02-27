defmodule FrasierBox do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(FrasierBox.UdpListener, [5020]),
      worker(FrasierBox.CommandProcessor, []),
      worker(FrasierBox.VideoPlayer, ["/home/pi/frasier_box/test_videos"])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
