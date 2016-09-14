defmodule Jsonapi.Base do

  defmacro base_url(url) do
    quote do
      @base_url unquote(url)

      def base_url do
        @base_url
      end
    end
  end

  defmacro headers(list) do
    quote do
      @headers unquote(list)

      def headers do
        @headers
      end
    end
  end

  defmacro __using__(_) do
    quote do
      import Jsonapi.Base

      def index(resource, opts \\ []) do
        fetch(base_url <> "/#{resource}", opts)
      end

      def show(resource, id, opts \\ []) do
        fetch(base_url <> "/#{resource}/#{id}", opts)
      end

      # implements filters and sort. missing: page, sparse_fields, includes
      def fetch(url, opts \\ []) do
        param_list = parse_filter(opts[:filters] || []) ++
          parse_sort(opts[:sort])
        response = HTTPoison.get!(url, [{"Accept", "application/vnd.api+json"}] ++ headers, params: param_list)
        handle_response(Poison.decode!(response.body))
      end

      defp handle_response(%{"errors" => errors}) do
        {:error, %Jsonapi.Response{errors: errors}}
      end

      defp handle_response(%{"data" => data, "links" => links}) do
        {:ok, %Jsonapi.Response{data: data, links: links}}
      end

      defp parse_filter(list) do
        Enum.map(list, fn({key, value}) -> {"filter[#{key}]", value} end)
      end

      defp parse_sort(nil) do [] end

      defp parse_sort(list) do
        [{"sort", Enum.join(list, ",")}]
      end

    end
  end

end

