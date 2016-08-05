defmodule Datasets do
  defmodule Point do
    defstruct [:x, :y, :group]
  end

  defimpl Inspect, for: Point do
    def inspect(%Point{x: x, y: y, group: group}, _) do
      "<(#{x}, #{y}) - group:#{group}>"
    end
  end

  @doc """
  Make two interleaving half circles

  Returns an list with count `samples` of the form {x: XX, y: YY, group: :inner | :outer}

  `samples`      - count of samples to return (defaults to 100)
  `shuffle`      - if the inner and outer circle data should be suffled (defaults to true)
  `noise`        - standard deviation of noise to add to each point (defaults to nil)
  `random_state` - random seed
  """
  def make_moons(samples \\ 100, shuffle \\ true, noise \\ nil, random_state \\ 0) do
    samples_outer = div(samples, 2)
    samples_inner = samples - samples_outer

    :random.seed(random_state)

    outer = Enum.map(linspace(0, :math.pi, samples_outer), fn angle ->
      %Point{x: :math.cos(angle), y: :math.sin(angle), group: :outer}
    end)

    inner = Enum.map(linspace(0, :math.pi, samples_inner), fn angle ->
      %Point{x: 1.0 - :math.cos(angle), y: 1.0 - :math.sin(angle) - 0.5, group: :inner}
    end)

    points = case shuffle do
      true ->  [outer | inner] |> List.flatten |> Enum.shuffle
      false -> [outer | inner] |> List.flatten
    end

    unless is_nil(noise) do
      points = Enum.map(points, fn point ->
        %Point{x: x, y: y, group: group} = point
        %Point{x: x + Statistics.Distributions.Normal.rand(0.0, noise), y: y + Statistics.Distributions.Normal.rand(0.0, noise), group: group}
      end)
    end

    points
  end

  def linspace(start, stop, number) do
    increment = (stop - start) / (number - 1)

    for x <- 0..number - 1, do: start + x * increment
  end
end
