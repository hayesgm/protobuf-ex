# protobuf-ex

[![Hex.pm](https://img.shields.io/hexpm/v/protobuf-ex.svg)](https://hex.pm/packages/protobuf-ex)

A pure Elixir implementation of [Google Protobuf](https://developers.google.com/protocol-buffers/)

## Why this instead of exprotobuf(gpb)?

It has some must-have and other cool features like:

1. A protoc [plugin](https://developers.google.com/protocol-buffers/docs/cpptutorial#compiling-your-protocol-buffers) to generate Elixir code just like what other official libs do, which is powerful and reliable.
2. Generate **simple and explicit** code with the power of Macro. (see [test/support/test_msg.ex](https://github.com/hayesgm/protobuf-ex/blob/master/test/support/test_msg.ex))
3. Plugins support.
4. Use **structs** for messages instead of Erlang records.
5. Support Typespec in generated code.

## Installation

The package can be installed
by adding `protobuf` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:protobuf_ex, "~> 0.5.0"}]
end
```

## Features

* [x] Define messages with DSL
* [x] Decode basic messages
* [x] Skip unknown fields
* [x] Decode embedded messages
* [x] Decode packed and repeated fields
* [x] Encode messages
* [x] protoc plugin
* [x] map
* [x] Support default values
* [x] Validate values
* [x] Generate typespecs
* [x] Plugins
* [ ] oneof

## Usage

### Generate Elixir code

1. Install `protoc`(cpp) [here](https://developers.google.com/protocol-buffers/docs/downloads)
2. Install protoc plugin `protoc-gen-elixir` for Elixir. NOTE: You have to make sure `protoc-gen-elixir`(this name is important) is in your PATH.
```
$ mix escript.install hex protobuf_ex
```
3. Generate Elixir code using protoc
```
$ protoc --elixir_out=./lib helloword.proto
```
4. Files `helloworld.pb.ex` will be generated, like:

```elixir
defmodule Helloworld.HelloRequest do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    name: String.t
  }
  defstruct [:name]

  field :name, 1, type: :string
end

defmodule Helloworld.HelloReply do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    message: String.t
  }
  defstruct [:message]

  field :message, 1, type: :string
end
```

### Encode and decode in your code

```elixir
struct = Foo.new(a: 3.2, c: Foo.Bar.new())
encoded = Foo.encode(struct)
struct = Foo.decode(encoded)
```

Note:
- You should use `YourModule.new` instead of using the struct directly because default values will be set for all fields.
- Default values will be set by default in `decode`, which can be changed by `:use_default` option.
- Validation is done in `encode`. An error will be raised if the struct is invalid(like type is not matched).

### Tips for protoc

- Custom protoc-gen-elixir name or path using `--plugin`
```
$ protoc --elixir_out=./lib --plugin=./protoc-gen-elixir *.proto
```
- Pass `-I` argument if you import other protobuf files
```
$ protoc -I protos --elixir_out=./lib protos/hello.proto
```

## Acknowledgements

Many thanks to Tony Han's [protobuf-elixir](https://github.com/tony612/protobuf-elixir), [gpb](https://github.com/tomas-abrahamsson/gpb) and
[golang/protobuf](https://github.com/golang/protobuf) as good examples of
writing Protobuf decoder/encoder. This code is maintained as a fork of protobuf-elixir until we can reconcile plugin support.
