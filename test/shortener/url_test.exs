defmodule Shortener.UrlTest do
  use Shortener.DataCase

  alias Shortener.Url

  @valid_attrs %{original: "https://google.com/maps/123455", shortened: "abc12345"}
  @invalid_attrs %{}

  test "change set with valid attributes" do
    changeset = Url.changeset(%Url{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Url.changeset(%Url{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "original url must be http or https" do
    changeset = Url.changeset(%Url{}, %{original: "foo.com", shortened: @valid_attrs.shortened})
    assert changeset.errors[:original] == {"Not a valid http or https URL.", []}
  end

  test "original url must have a host" do
    changeset = Url.changeset(%Url{}, %{original: "http://", shortened: @valid_attrs.shortened})
    assert changeset.errors[:original] == {"Host cannot be nil.", []}
  end

  describe "original url host" do
    test "must have a top level domain" do
      changeset = Url.changeset(%Url{}, %{original: "http://foo", shortened: @valid_attrs.shortened})
      assert changeset.errors[:original] == {"Host is not valid.", []}
    end

    test "must have a valid top level domain" do
      changeset = Url.changeset(%Url{}, %{original: "http://foo.c", shortened: @valid_attrs.shortened})
      refute changeset.valid?
    end

    test "can have a 2 character top level domain" do
      changeset = Url.changeset(%Url{}, %{original: "http://foo.co", shortened: @valid_attrs.shortened})
      assert changeset.valid?
    end

    test "can have a 6 character top level domain" do
      changeset = Url.changeset(%Url{}, %{original: "http://foo.museum", shortened: @valid_attrs.shortened})
      assert changeset.valid?
    end

    test "can have a subdomain" do
      changeset = Url.changeset(%Url{}, %{original: "http://docs.google.com", shortened: @valid_attrs.shortened})
      assert changeset.valid?
    end

    test "can have a second top level domain" do
      changeset = Url.changeset(%Url{}, %{original: "http://docs.google.co.uk", shortened: @valid_attrs.shortened})
      assert changeset.valid?
    end
  end

  test "original has been taken" do
    assert {:ok, _url } = Repo.insert(Url.changeset(%Url{}, @valid_attrs))

    dup = Url.changeset(%Url{}, %{original: @valid_attrs.original, shortened: "123abcde"})

    {:error, changeset} = Repo.insert(dup)
    assert changeset.errors[:original] == {"URL has already been shortened.", []}
  end

  test "shortened has been taken" do
    assert {:ok, _url } = Repo.insert(Url.changeset(%Url{}, @valid_attrs))

    dup = Url.changeset(%Url{}, %{original: "https://foo.com", shortened: @valid_attrs.shortened})

    {:error, changeset} = Repo.insert(dup)
    assert changeset.errors[:shortened] == {"Shortened has already been taken.", []}
  end
end