defmodule Shortener.Url do
  use Ecto.Schema
  import Ecto.Changeset

  @hostname_regex ~r/^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}$/x

  schema "urls" do
    field :original, :string
    field :shortened, :string

    timestamps()
  end

  @doc false
  def changeset(url, attrs) do
    url
    |> cast(attrs, [:original, :shortened])
    |> validate_required([:original, :shortened])
    |> validate_uri(:original)
    |> unique_constraint(:original, message: "URL has already been shortened.")
    |> unique_constraint(:shortened, message: "Shortened has already been taken.")
  end

  def validate_uri(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, url ->
      uri = URI.parse(url)
      case uri do
        %URI{scheme: nil} -> [{field, options[:message] || "Not a valid http or https URL."}]
        %URI{host: nil} -> [{field, options[:message] || "Host cannot be nil."}]
        uri ->
          case Regex.match?(@hostname_regex, uri.host) do
            true -> []
            false -> [{field, options[:message] || "Host is not valid."}]
          end
      end
    end)
  end
end
