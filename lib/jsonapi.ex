defmodule Jsonapi.Response do
  defstruct data: [], links: [], errors: []
end

defmodule Jsonapi do
  use Jsonapi.Base

  headers []
  base_url "foo"
end

