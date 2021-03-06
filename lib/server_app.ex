defmodule ServerApp do
  use Application

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http, 
        plug: Router, 
        options: [port: 4000]
      ),
      {IdleTimer, 90},
    ]
    
    System.cmd("cargo", ["build", "--target", "wasm32-unknown-unknown", "--release"], cd: "template")

    opts = [strategy: :one_for_one, name: ServerApp.Supervisor]                         
    IO.puts("Starting Server at http://localhost:4000...")                                                         
    Supervisor.start_link(children, opts)
  end
end
