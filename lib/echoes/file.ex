defmodule Echoes.File do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias Echoes.{Repo, File}

  @timestamps_opts [type: :utc_datetime_usec]
  schema "files" do
    field :filename, :string
    field :type, :string
    field :url, :string

    timestamps()
  end

  def upload_file(params) do
    bucket_name = System.get_env("BUCKET_NAME")

    path = case MIME.extensions(params.content_type) do
      [] -> "#{next_file_name()}"
      exts -> "#{next_file_name()}.#{Enum.take(exts, 1)}"
    end

    ExAws.S3.Upload.stream_file(params.path)
    |> ExAws.S3.upload(bucket_name, path, content_type: params.content_type)
    |> ExAws.request!()

    {:ok, file} = Repo.insert(%File{
      filename: params.filename,
      type: params.content_type,
      url: "http://#{bucket_name}.s3.amazonaws.com/#{path}"
    })

    file
  end

  def next_file_name do
    Repo.one(from f in File, select: count(f.id))
    |> Integer.to_string
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, [:filename, :url, :type])
    |> validate_required([:filename, :url, :type])
  end
end
