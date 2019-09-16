defmodule Absinthe.Blueprint.Schema.InputUnionTypeDefinition do
  @moduledoc false

  alias Absinthe.{Blueprint, Type}

  @enforce_keys [:name]
  defstruct [
    :identifier,
    :name,
    :module,
    description: nil,
    resolve_type: nil,
    fields: [],
    directives: [],
    types: [],
    source_location: nil,
    # Added by phases
    flags: %{},
    errors: [],
    __reference__: nil,
    __private__: []
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          description: nil | String.t(),
          directives: [Blueprint.Directive.t()],
          types: [Blueprint.TypeReference.Name.t()],
          source_location: nil | Blueprint.SourceLocation.t(),
          # Added by phases
          flags: Blueprint.flags_t(),
          errors: [Absinthe.Phase.Error.t()]
        }

  def build(type_def, schema) do
    %Type.InputUnion{
      name: type_def.name,
      description: type_def.description,
      identifier: type_def.identifier,
      types: type_def.types |> Enum.sort(),
      definition: type_def.module
    }
  end

  defimpl Inspect do
    defdelegate inspect(term, options),
      to: Absinthe.Schema.Notation.SDL.Render
  end
end
