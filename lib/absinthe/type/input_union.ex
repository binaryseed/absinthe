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
end
