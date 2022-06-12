defmodule Router do
  use Plug.Router
  
  plug(:match)
  plug(:dispatch)

  get "" do
    send_resp(conn, 200, %{hello: "world"} |> Jason.encode!())
  end

  match _ do
    send_resp(conn, 404, "404")
  end
end
