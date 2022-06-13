defmodule Router do
  use Plug.Router
  
  plug(:match)
  plug(:dispatch)

  get "/wasm/:uuid" do
    IdleTimer.reset_timer()

    uuid = conn.params["uuid"]

    conn = conn
    |> put_resp_header("content-type", "application/wasm")
    |> send_file(200, "builds/#{uuid}/target/wasm32-unknown-unknown/debug/template.wasm")

    File.rm_rf!("builds/#{uuid}")

    conn
  end

  post "/compile" do
    IdleTimer.reset_timer()

    {:ok, body, conn} = Plug.Conn.read_body(conn)
    code = body
           |> Jason.decode!()
           |> Access.get("code")

    uuid = UUID.uuid4()
    build_path = "builds/#{uuid}"
    File.cp_r!("template", build_path)
    File.write!("#{build_path}/src/main.rs", code)

    {:ok, task} = Task.start(fn ->
      System.cmd("cargo", ["build", "--target", "wasm32-unknown-unknown"], cd: build_path)
    end)

    loop = fn loop ->
      if Process.alive?(task) do
        IdleTimer.reset_timer()
        Process.sleep(1000)
        loop.(loop)
      end
    end

    loop.(loop)

    conn
    |> Plug.Conn.put_resp_content_type("application/wasm", "")
    |> send_resp(200, uuid)
  end

  get "" do
    IdleTimer.reset_timer()
    send_file(conn, 200, "test.html")
  end

  match _ do
    send_resp(conn, 404, "404")
  end
end

defmodule VisitCounter do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> 0 end, name: __MODULE__)
  end

  def get() do
    Agent.get(__MODULE__, & &1)
  end

  def increment() do
    Agent.update(__MODULE__, & &1 + 1)
  end
end
