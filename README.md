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


You can plot a hydrograph with a dataframe.
In this case, `hydrograph` looks for the `Date` column for dates and the `Flow` column for streamflow data.

````julia
julia> data = dataset("doherty")
julia> hydrograph(data)
````

You can also use pipe operator to use a dataframe.

````julia
julia> data |> hydrograph

````

You can give column names for dates and streamflow data.

````julia
julia> hydrograph(data, "Date", "Flow")
````

You can also give the indices of columns for dates and streamflow data.

````julia
julia> hydrograph(data, 1, 2)
````

If you plot streamflow data in a log scale,

````julia
julia> hydrograph(data; logscale=true)


If you want to plot rainfall data along with streamflow data, give the column name as following.

````julia
julia> hydrograph(data, "Date", "Flow", "Rainfall")
````

Or, you can give column indices.

````julia
julia> hydrograph(data, 1, 2, 4)
````

You can directly give arrays. The arrays should have the same lengths.
````julia
julia> hydrograph(data.Date, data.Flow, data.Rainfall)
````

If you want to change the width of hydrograph,

````julia
julia> hydrograph(data; width=1000)
````

The hydrograph at the bottom does not aggregate streamflow data.
If you want to show monthly aggregated data in the hydrograph, use `aggregate` keyword.

````julia
julia> hydrograph(data; aggregate="monthly")
````

If you want to show weekly aggregated streamflow data,

````julia
julia> hydrograph(data; aggregate="weekly")
````

[travis-img]: https://travis-ci.org/petershintech/Hydrographs.jl.svg?branch=master
[travis-url]: https://travis-ci.org/petershintech/Hydrographs.jl

[codecov-img]: https://codecov.io/gh/petershintech/Hydrographs.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/petershintech/Hydrographs.jl
