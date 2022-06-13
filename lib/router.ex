defmodule Router do
  use Plug.Router
  
  plug(IdleTimerPlug)
  plug(:match)
  plug(:dispatch)

  post "/compile" do
    # body :: { code: string }
    {:ok, body, conn} = Plug.Conn.read_body(conn)
    code = body
           |> Jason.decode!()
           |> Access.get("code")

    # Copy the template to a build folder
    uuid = UUID.uuid4()
    build_path = "builds/#{uuid}"
    File.cp_r!("template", build_path)
    File.write!("#{build_path}/src/main.rs", code)

    # Run cargo and wait for it to finish
    {:ok, task} = Task.start(fn ->
      System.cmd("cargo", ["build", "--target", "wasm32-unknown-unknown"], cd: build_path)
    end)
    IdleTimer.wait_for_process(task)

    # Send wasm to client and delete the build directory
    conn = conn
    |> put_resp_header("content-type", "application/wasm")
    |> send_file(200, "builds/#{uuid}/target/wasm32-unknown-unknown/debug/template.wasm")

    File.rm_rf!("builds/#{uuid}")

    conn
  end

  get "/js/index.js" do
    conn
    |> put_resp_header("content-type", "application/javascript")
    |> send_file(200, "frontend/js/index.js")
  end

  get "" do
    send_file(conn, 200, "frontend/index.html")
  end

  match _ do
    send_resp(conn, 404, "404")
  end
end
