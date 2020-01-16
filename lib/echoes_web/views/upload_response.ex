defmodule EchoesWeb.UploadView do
  use EchoesWeb, :view

  def render("upload_response.json", %{resp: resp}) do
    %{
      url: resp.url,
      name: resp.filename
    }
  end
end