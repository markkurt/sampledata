defmodule Datasets.Graph do
  def scatter(points, options \\ []) do
    defaults = [
      data_file:    'output/data.dat', 
      command_file: 'output/command.txt', 
      image_file:   'output/graph.png',
      order_points: true,
      split_points: true,
      title:        'Scatter Plot',
      x_label:      'X Values',
      y_label:      'Y Values'
    ]

    %{
        data_file:    data_file, 
        command_file: command_file, 
        image_file:   image_file,
        order_points: order_points,
        split_points: split_points,
        title:        title,
        x_label:      x_label,
        y_label:      y_label
    } = Keyword.merge(defaults, options) |> Enum.into(%{})

    group_count = case split_points do
      true  -> Enum.map(points, fn i -> i.group end) |> MapSet.new |> MapSet.size
      false -> 1
    end

    data_write = write_data(points, data_file, order_points, split_points)
    command_write = write_commands(command_file, image_file, data_file, group_count, title, x_label, y_label)

    if data_write == :ok && command_write == :ok do
      plot(command_file)
    else
      :error
    end
  end

  defp write_data(points, data_path, order_points, split_points) do
    points = case order_points do
      true ->
        Enum.sort(points, fn i1, i2 -> 
          %{group: g1} = i1
          %{group: g2} = i2
          g1 <= g2
        end)
      false ->
        points
    end

    if {:ok, file} = File.open data_path, [:write, :utf8] do
      {:ok, current_group} = Agent.start_link(fn -> nil end)

      Enum.each(points, fn point ->
        %{x: x, y: y, group: group} = point

        if split_points do
          if !Enum.member?([group, nil], Agent.get_and_update(current_group, fn old -> {old, group} end)) do
            for _ <- 1..3 do
              IO.puts(file, "")
            end
            Agent.update(current_group, fn _ -> group end)
          end
        end

        IO.puts(file, "#{x},#{y},#{group}")
      end)

      File.close file
    else
      :error
    end
  end

  defp write_commands(command_path, image_path, data_path, group_count, title, x_label, y_label) do
    if {:ok, file} = File.open command_path, [:write, :utf8] do
      IO.puts(file, "set term png")
      IO.puts(file, "set output \"#{image_path}\"")
      IO.puts(file, "set datafile separator \",\"")
      IO.puts(file, "set title \"#{title}\"")
      IO.puts(file, "set xlabel \"#{x_label}\"")
      IO.puts(file, "set ylabel \"#{y_label}\"")
      IO.puts(file, "set grid")
      IO.puts(file, "set timestamp")
      
      plot_lines = if group_count > 1 do
        Enum.to_list(1..(group_count - 1)) |> Enum.map(&(", '' using 1:2 index #{&1}")) |> Enum.join("")
      else
        ""
      end

      IO.puts(file, "plot '#{data_path}' using 1:2 index 0" <> plot_lines)
      IO.puts(file, "quit")

      File.close file
    else
      :error
    end
  end

  defp plot(command_path) do
    System.cmd("gnuplot", [command_path])

    :ok
  end
end
