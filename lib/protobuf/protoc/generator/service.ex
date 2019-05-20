defmodule Protobuf.Protoc.Generator.Service do
  alias Protobuf.Protoc.Generator.Util

  def generate_list(ctx, descs) do
    Enum.map(descs, fn(desc) -> generate(ctx, desc) end)
  end

  def generate(ctx, desc) do
    mod_name = desc.name |> Macro.camelize |> Util.attach_pkg(ctx.package)
    name = "#{ctx.package}.#{desc.name}"
    methods = Enum.map(desc.method, fn(m) ->
      {generate_service_method(ctx, m), get_method_options(m), get_method_docs(m)}
    end)
    Protobuf.Protoc.Template.service(mod_name, name, methods)
  end

  defp generate_service_method(ctx, m) do
    input = service_arg(Util.trans_type_name(m.input_type, ctx), m.client_streaming)
    output = service_arg(Util.trans_type_name(m.output_type, ctx), m.server_streaming)
    ":#{m.name}, #{input}, #{output}"
  end

  defp get_method_options(%Google.Protobuf.MethodDescriptorProto{options: nil}), do: nil
  defp get_method_options(m) do
    case m.options do
      %{http: http} ->
        case http.pattern do
          {type, path} -> {type, path}
          _ -> nil
        end
      _ -> nil
    end
  end

  defp get_method_docs(%Google.Protobuf.MethodDescriptorProto{options: nil}), do: nil
  defp get_method_docs(m) do
    case m.options do
      %{docs: docs} ->
        case docs.description do
          "" -> nil
          desc when is_binary(desc) ->
            docs =
              desc
              |> String.split("\n")
              |> Enum.map(&String.trim/1)
              |> Enum.join("\n  ")
              |> String.trim()

            "@doc \"\"\"\n  #{docs}\n  \"\"\"\n  "
          _ -> nil
        end
      _ -> nil
    end
  end

  defp service_arg(type, true), do: "stream(#{type})"
  defp service_arg(type, _), do: type
end
