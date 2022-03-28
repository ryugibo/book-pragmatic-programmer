defmodule Potato do
  def write_to_json({:ok, yaml_data}, yaml_path) do
    yaml_path
    |> String.replace_suffix(".yaml", ".json")
    |> File.write(Poison.encode!(yaml_data))
  end

  def write_to_json(error, _) do
    error
  end

  def main([path | _]) do
    path
    |> Path.absname()
    |> Path.join("*.yaml")
    |> Path.wildcard()
    |> Enum.map(fn yaml_path ->
      Task.async(fn ->
        yaml_path
        |> YamlElixir.read_from_file()
        |> write_to_json(yaml_path)
      end)
    end)
    |> Task.await_many()
  end
end
