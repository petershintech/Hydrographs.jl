# Hydrographs

| **Build Status**                                                                                |
|:----------------------------------------------------------------------------------------------- |
 [![][travis-img]][travis-url] [![][codecov-img]][codecov-url]

Hydrograph plotting tools.

## Installation

The package can be installed with the Julia package manager. From the Julia REPL, type `]` to enter the Pkg REPL mode and run:

````julia
pkg> add Hydrographs
````

If you want to install the package directly from its github development site,

````julia
pkg> add http://github.com/petershintech/Hydrographs.jl
````

And load the package using the command:

````julia
using Hydrographs
````

## Hydrograph only with streamflow data

`hydrograph()` returns forecast data as Vega Lite specification.

````julia
julia> data = CSV.read("data.csv")

julia> hydrograph(data)

julia> data |> hydrograph

julia> hydrograph(data, "Date", "Flow")

julia> hydrograph(data, 1, 2)

julia> hydrograph(data, "Date", "Flow", "Rainfall")

julia> hydrograph(data, 1, 2, 4)

[travis-img]: https://travis-ci.org/petershintech/Hydrographs.jl.svg?branch=master
[travis-url]: https://travis-ci.org/petershintech/Hydrographs.jl

[codecov-img]: https://codecov.io/gh/petershintech/Hydrographs.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/petershintech/Hydrographs.jl
