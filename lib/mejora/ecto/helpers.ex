defmodule Mejora.Ecto.Helpers do
  def translate_errors_to_string(errors, opts \\ [])

  def translate_errors_to_string(errors, _opts) when is_binary(errors), do: errors

  def translate_errors_to_string([{_key, {_, _}} | _] = errors, opts) do
    errors = for {field, {message, _}} <- errors, into: %{}, do: {field, [message]}
    join_translated_errors(errors, opts)
  end

  def translate_errors_to_string(%Ecto.Changeset{} = changeset, opts),
    do:
      changeset
      |> translate_errors()
      |> join_translated_errors(opts)

  def translate_errors_to_string(_, _), do: ""

  def translate_errors(changeset),
    do:
      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
          opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
        end)
      end)

  defp join_translated_errors(errors, opts) do
    no_print_field = opts[:no_print_field]

    Enum.reduce(errors, [], fn
      {field, [error | _] = errors}, acc when is_map(error) ->
        message =
          if no_print_field,
            do: join_translated_errors(errors, opts),
            else: "#{to_string(field)}: [#{join_translated_errors(errors, opts)}]"

        [message | acc]

      errors, acc when is_map(errors) and map_size(errors) > 0 ->
        [join_translated_errors(errors, opts) | acc]

      {field, errors}, acc ->
        message =
          if no_print_field,
            do: Enum.join(errors, ", "),
            else: to_string(field) <> " " <> Enum.join(errors, ", ")

        [message | acc]

      _, acc ->
        acc
    end)
    |> Enum.join(", ")
  end
end
