# Datasets

Generate sample datasets similar to sklearn.datasets in python

## Use

Currently only the make_moons method is implemented

### Generating Datasets
```
iex> Datasets.make_moons()
```
Will create a dataset that looks like:

![make_moons with standard deviations of 0](docs/graph_make_moons_stddev_0.png "Default Parameters")

```
iex> Datasets.make_moons(100, true, 0.3)
```
Will create a dataset that looks like:

![make moons with standard deviation of 0.3](docs/graph_make_moons_stddev_0.3.png "Standard Deviation of 0.3")

```
iex> Datasets.make_moons(1000, true, 0.3)
```
Will create a dataset that looks like:

![make moons with standard deviation of 0.3 and sample size of 1000](docs/graph_make_moons_stddev_0.3_1000.png "Standard Deviation of 0.3 and Sample Size of 1000")

### Graphing Datasets
```
iex> points = Datasets.make_moons(1000, true, 0.3)
:ok
iex> Datasets.Graph.scatter(points)
:ok
```
Will create the last graph above in a directory called `output` (that must exist prior to generating the graph)


## Installation

  1. Add datasets to your list of dependencies in `mix.exs`:

        def deps do
          [{:datasets, "~> 0.1.0"}]
        end

  2. Ensure datasets is started before your application:

        def application do
          [applications: [:datasets]]
        end

