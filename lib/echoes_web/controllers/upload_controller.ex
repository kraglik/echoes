defmodule EchoesWeb.UploadController do
  use EchoesWeb, :controller

  alias Echoes.File

  def upload(conn, %{"file" => upload_params}) do
    resp = File.upload_file(upload_params)
    render(conn, "upload_response.json", resp: resp)
  end

end