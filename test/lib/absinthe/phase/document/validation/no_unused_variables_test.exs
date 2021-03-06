defmodule Absinthe.Phase.Document.Validation.NoUnusedVariablesTest do
  use Absinthe.Case, async: true

  @rule Absinthe.Phase.Document.Validation.NoUnusedVariables

  use Support.Harness.Validation
  alias Absinthe.Blueprint

  defp unused_variable(name, operation_name, operation_line) do
    bad_value(
      Blueprint.Document.VariableDefinition,
      @rule.error_message(name, operation_name),
      operation_line,
      name: name
    )
  end

  describe "Validate: No unused variables" do

    it "uses all variables" do
      assert_passes_rule(@rule,
        """
        query ($a: String, $b: String, $c: String) {
          field(a: $a, b: $b, c: $c)
        }
        """,
        []
      )
    end

    it "uses all variables deeply" do
      assert_passes_rule(@rule,
        """
        query Foo($a: String, $b: String, $c: String) {
          field(a: $a) {
            field(b: $b) {
              field(c: $c)
            }
          }
        }
        """,
        []
      )
    end

    it "uses all variables deeply in inline fragments" do
      assert_passes_rule(@rule,
        """
        query Foo($a: String, $b: String, $c: String) {
          ... on Type {
            field(a: $a) {
              field(b: $b) {
                ... on Type {
                  field(c: $c)
                }
              }
            }
          }
        }
        """,
        []
      )
    end

    it "uses all variables in fragments" do
      assert_passes_rule(@rule,
        """
        query Foo($a: String, $b: String, $c: String) {
          ...FragA
        }
        fragment FragA on Type {
          field(a: $a) {
            ...FragB
          }
        }
        fragment FragB on Type {
          field(b: $b) {
            ...FragC
          }
        }
        fragment FragC on Type {
          field(c: $c)
        }
        """,
        []
      )
    end

    it "variable used by fragment in multiple operations" do
      assert_passes_rule(@rule,
        """
        query Foo($a: String) {
          ...FragA
        }
        query Bar($b: String) {
          ...FragB
        }
        fragment FragA on Type {
          field(a: $a)
        }
        fragment FragB on Type {
          field(b: $b)
        }
        """,
        []
      )
    end

    it "variable used by recursive fragment" do
      assert_passes_rule(@rule,
        """
        query Foo($a: String) {
          ...FragA
        }
        fragment FragA on Type {
          field(a: $a) {
            ...FragA
          }
        }
        """,
        []
      )
    end

    it "variable not used" do
      assert_fails_rule(@rule,
        """
        query ($a: String, $b: String, $c: String) {
          field(a: $a, b: $b)
        }
        """,
        [],
        [
          unused_variable("c", nil, 1)
        ]
      )
    end

    it "multiple variables not used" do
      assert_fails_rule(@rule,
        """
        query Foo($a: String, $b: String, $c: String) {
          field(b: $b)
        }
        """,
        [],
        [
          unused_variable("a", "Foo", 1),
          unused_variable("c", "Foo", 1)
        ]
      )
    end

    it "variable not used in fragments" do
      assert_fails_rule(@rule,
        """
        query Foo($a: String, $b: String, $c: String) {
          ...FragA
        }
        fragment FragA on Type {
          field(a: $a) {
            ...FragB
          }
        }
        fragment FragB on Type {
          field(b: $b) {
            ...FragC
          }
        }
        fragment FragC on Type {
          field
        }
        """,
        [],
        [
          unused_variable("c", "Foo", 1)
        ]
      )
    end

    it "multiple variables not used in fragments" do
      assert_fails_rule(@rule,
        """
        query Foo($a: String, $b: String, $c: String) {
          ...FragA
        }
        fragment FragA on Type {
          field {
            ...FragB
          }
        }
        fragment FragB on Type {
          field(b: $b) {
            ...FragC
          }
        }
        fragment FragC on Type {
          field
        }
        """,
        [],
        [
          unused_variable("a", "Foo", 1),
          unused_variable("c", "Foo", 1)
        ]
      )
    end

    it "variable not used by unreferenced fragment" do
      assert_fails_rule(@rule,
        """
        query Foo($b: String) {
          ...FragA
        }
        fragment FragA on Type {
          field(a: $a)
        }
        fragment FragB on Type {
          field(b: $b)
        }
        """,
        [],
        [
          unused_variable("b", "Foo", 1)
        ]
      )
    end

    it "variable not used by fragment used by other operation" do
      assert_fails_rule(@rule,
        """
        query Foo($b: String) {
          ...FragA
        }
        query Bar($a: String) {
          ...FragB
        }
        fragment FragA on Type {
          field(a: $a)
        }
        fragment FragB on Type {
          field(b: $b)
        }
        """,
        [],
        [
          unused_variable("b", "Foo", 1),
          unused_variable("a", "Bar", 4)
        ]
      )
    end

  end

end
