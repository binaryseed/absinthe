defmodule Absinthe.Type.InputUnion do
  @moduledoc """
  An InputUnion is an abstract input type made up of multiple possible concrete input types.

  ```
  input_union :search_query do
    description "A search query"

    types [:by_name, :by_id]
  end
  ```
  """

  use Absinthe.Introspection.Kind

  alias Absinthe.Type

  @typedoc """
  * `:name` - The name of the input union type. Should be a TitleCased `binary`. Set automatically.
  * `:description` - A nice description for introspection.
  * `:types` - The list of possible types.

  The `__private__` and `:__reference__` keys are for internal use.

  """
  @type t :: %__MODULE__{
          name: binary,
          description: binary,
          types: [Type.identifier_t()],
          identifier: atom,
          __private__: Keyword.t(),
          definition: module,
          __reference__: Type.Reference.t()
        }

  defstruct name: nil,
            description: nil,
            identifier: nil,
            types: [],
            __private__: [],
            definition: nil,
            __reference__: nil

  @doc false
  @spec member?(t, Type.t()) :: boolean
  def member?(%{types: types}, %{__reference__: %{identifier: ident}}) do
    ident in types
  end

  def member?(_, _) do
    false
  end

  def determine_concrete_type(included_fields, input_union, schema) do
    with %{input_value: %{normalized: %{value: inputname}}} <-
           Enum.find(included_fields, fn field -> field.name == "__inputname" end) do
      Absinthe.Schema.lookup_type(schema, inputname)
    else
      nil ->
        # structural discrimination

        input_union.types
        |> lookup_concrete_types(schema)
        |> determine_matching_types(included_fields)
        |> case do
          [{identifier, _type_fields}] -> identifier
          _ -> nil
        end
    end
  end

  defp lookup_concrete_types(input_union_types, schema) do
    input_union_types
    |> Enum.map(&Absinthe.Schema.lookup_type(schema, &1))
    |> Enum.map(fn concrete_type ->
      field_names =
        concrete_type.fields
        |> Map.drop([:__inputname])
        |> Enum.map(fn {_identifier, %{name: name}} -> name end)
        |> MapSet.new()

      {concrete_type.identifier, field_names}
    end)
  end

  defp determine_matching_types(possible_types, included_fields) do
    included_field_names = included_fields |> Enum.map(& &1.name) |> MapSet.new()

    Enum.filter(possible_types, fn {_identifier, input_field_names} ->
      MapSet.subset?(included_field_names, input_field_names)
    end)
  end
end
