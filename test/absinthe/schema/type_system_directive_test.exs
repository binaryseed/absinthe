defmodule Absinthe.Schema.TypeSystemDirectiveTest do
  use ExUnit.Case

  defmodule WithTypeSystemDirective do
    use Absinthe.Schema.Prototype

    input_object :complex do
      field :str, :string
    end

    directive :feature do
      arg :name, non_null(:string)
      arg :number, :integer
      arg :complex, :complex

      repeatable true

      on [
        :schema,
        :scalar,
        :object,
        :field_definition,
        :argument_definition,
        :interface,
        :union,
        :enum,
        :enum_value,
        :input_object,
        :input_field_definition
      ]
    end
  end

  defmodule TypeSystemDirectivesSchema do
    use Absinthe.Schema

    @prototype_schema WithTypeSystemDirective

    @sdl """
    schema @feature(name: ":schema") {
      query: Query
    }

    interface Animal @feature(name: ":interface") {
      legCount: Int! @feature(name: \"""
        Multiline here?
        Second line
      \""")
    }

    input SearchFilter @feature(name: ":input_object") {
      query: String = "default" @feature(name: ":input_field_definition")
    }

    type Post @feature(name: ":object", number: 3, complex: {str: "foo"}) {
      name: String @deprecated(reason: "Bye")
    }

    scalar SweetScalar @feature(name: ":scalar")

    type DirectiveEcho {
      name: String
      args: [DirectiveArgEcho]
    }

    type Query @feature(name: "Query!") {
      post: Post @feature(name: ":field_definition")
      sweet: SweetScalar
      pet: Dog
      which: Category
      search(filter: SearchFilter @feature(name: ":argument_definition")): SearchResult
      directiveEcho: [DirectiveEcho]
    }

    type Dog implements Animal {
      legCount: Int!
      name: String!
    }

    type DirectiveArgEcho {
      name: String
      value: String
    }

    enum Category @feature(name: ":enum") {
      THIS
      THAT @feature(name: ":enum_value")
      THE_OTHER @deprecated(reason: "It's old")
    }

    union SearchResult @feature(name: ":union") = Dog | Post
    """
    import_sdl @sdl
    def sdl, do: @sdl

    def hydrate(%{identifier: :animal}, _) do
      {:resolve_type, &__MODULE__.resolve_type/1}
    end

    def hydrate(%{identifier: :directive_echo}, [%{identifier: :query}]) do
      {:resolve, &__MODULE__.directive_echo/3}
    end

    def hydrate(_node, _ancestors), do: []

    def resolve_type(_), do: false

    def directive_echo(_source, _args, res) do
      directive_echo =
        res.definition.parent_type.directives
        |> Enum.map(fn directive ->
          args = Enum.map(directive.args, fn {name, value} -> %{name: name, value: value} end)
          %{name: directive.name, args: args}
        end)

      {:ok, directive_echo}
    end
  end

  test "Render SDL with Type System Directives applied" do
    assert Absinthe.Schema.to_sdl(TypeSystemDirectivesSchema) ==
             TypeSystemDirectivesSchema.sdl()
  end

  test "Type System Directives available inside resolution" do
    {:ok, %{data: data}} =
      Absinthe.run("{ directiveEcho { name args { name value } } }", TypeSystemDirectivesSchema)

    args = get_in(data, ["directiveEcho", Access.at(0), "args", Access.at(0)])

    assert args["name"] == "name"
    assert args["value"] == "Query!"
  end
end
