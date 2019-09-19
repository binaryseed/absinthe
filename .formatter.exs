locals_without_parens = [
  mutation: 2,
  query: 2,
  subscription: 2,
  arg: 2,
  arg: 3,
  complexity: 1,
  config: 1,
  deprecate: 1,
  description: 1,
  directive: 3,
  enum: 2,
  enum: 3,
  expand: 1,
  field: 2,
  field: 3,
  field: 4,
  import_fields: 2,
  import_fields: 1,
  import_types: 1,
  import_sdl: 1,
  import_sdl: 2,
  input_object: 3,
  input_union: 3,
  interface: 1,
  interface: 3,
  interfaces: 1,
  is_type_of: 1,
  meta: 1,
  meta: 2,
  middleware: 2,
  middleware: 1,
  object: 3,
  on: 1,
  parse: 1,
  record_object!: 4,
  recordable!: 4,
  resolve: 1,
  resolve_type: 1,
  scalar: 2,
  scalar: 3,
  serialize: 1,
  trigger: 2,
  types: 1,
  union: 3,
  value: 1,
  value: 2
]

[
  inputs: ["mix.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: locals_without_parens,
  export: [
    locals_without_parens: locals_without_parens
  ]
]
