module Hydrographs

using Dates: Date
using DataStructures: OrderedDict
using DataFrames: DataFrame, outerjoin, sort!
using CSV: File
using JSON: parse
using VegaLite: VLSpec

export hydrograph, dataset

function read_template()
    path = joinpath(@__DIR__, "template.json")
    template = parse(open(path), dicttype=OrderedDict)
    return template
end

vl_template = read_template()

function set_options!(vlspec, kwargs)
    if :width in keys(kwargs)
        for panel in vlspec["vconcat"]
            panel["width"] = kwargs[:width]
        end
    end
    if :aggregate in keys(kwargs)
        if kwargs[:aggregate] == "monthly"
            vlspec["vconcat"][end]["encoding"]["x"]["timeUnit"] = "yearmonth"
            vlspec["vconcat"][end]["encoding"]["y"]["aggregate"] = "sum"
        elseif kwargs[:aggregate] == "weekly"
            vlspec["vconcat"][end]["encoding"]["x"]["timeUnit"] = "yearweek"
            vlspec["vconcat"][end]["encoding"]["y"]["aggregate"] = "sum"
        end
    end
    if get(kwargs, :logscale, false)
        vlspec["vconcat"][end-1]["encoding"]["y"]["scale"]["type"] = "log"
        vlspec["vconcat"][end]["encoding"]["y"]["scale"]["type"] = "log"
    end
end

"""
    hydrograph(data::DataFrame, T::AbstractString,
               Q::AbstractString; kwargs...)::VLSpec

Plot a hydrograph with two columns in a dataframe.

### Arguments
* `data` : A dataframe
* `T` : Column name for time X axis
* `Q` : Column name for streamlow Y axis

### Examples
```julia
julia> hydrograph(df, "Date", "Flow"; width=1000)
```
"""
function hydrograph(data::DataFrame, T::AbstractString,
                    Q::AbstractString; kwargs...)::VLSpec
    vlspec = deepcopy(vl_template)

    popfirst!(vlspec["vconcat"])

    for panel in vlspec["vconcat"]
        panel["encoding"]["x"]["field"] = T
        panel["encoding"]["y"]["field"] = Q
    end

    set_options!(vlspec, kwargs)

    plt = data |> VLSpec(vlspec)
    return plt
end

"""
    hydrograph(data::DataFrame, T::AbstractString,
               Q::AbstractString, P::AbstractString; kwargs...)::VLSpec

Plot a hydrograph with three columns in a dataframe.

### Arguments
* `data` : A dataframe
* `T` : Column name for time X axis
* `Q` : Column name for streamlow Y axis
* `P` : Column name for rainfall Y axis

### Examples
```julia
julia> hydrograph(df, "Date", "Flow", "Rainfall"; width=1000)
```
"""
function hydrograph(data::DataFrame, T::AbstractString,
                    Q::AbstractString, P::AbstractString; kwargs...)::VLSpec
    vlspec = deepcopy(vl_template)

    for panel in vlspec["vconcat"]
        panel["encoding"]["x"]["field"] = T
    end
    vlspec["vconcat"][1]["encoding"]["y"]["field"] = P
    vlspec["vconcat"][2]["encoding"]["y"]["field"] = Q
    vlspec["vconcat"][3]["encoding"]["y"]["field"] = Q

    set_options!(vlspec, kwargs)

    plt = data |> VLSpec(vlspec)
    return plt
end

"""
    hydrograph(data::DataFrame; kwargs...)::VLSpec

Plot a hydrograph with default columns in a dataframe.
The default name for time is "Dates" and the default name for streamflow data is "Flow".

### Arguments
* `data` : A dataframe

### Examples
```julia
julia> hydrograph(df; width=1000)
```
"""
function hydrograph(data::DataFrame; kwargs...)::VLSpec
    T, Q = names(data)[1:2]
    return hydrograph(data, T, Q; kwargs...)
end

"""
    hydrograph(data::DataFrame; kwargs...)::VLSpec

Plot a hydrograph with default columns in a dataframe.
The default name for time is "Dates" and the default name for streamflow data is "Flow".

### Arguments
* `data` : A dataframe

### Examples
```julia
julia> hydrograph(df; width=1000)
```
"""
function hydrograph(data::DataFrame, it::Int, iq::Int; kwargs...)::VLSpec
    T, Q = names(data)[[it, iq]]
    return hydrograph(data, T, Q; kwargs...)
end

"""
    hydrograph(data::DataFrame, it::Int, iq::Int, ip::Int; kwargs...)::VLSpec

Plot a hydrograph with a dataframe and column numbers.

### Arguments
* `data` : A dataframe
* `it` : Column number for time X axis
* `iq` : Column number for streamflow Y axis
* `ip` : Column number for rainfall Y axis

### Examples
```julia
julia> hydrograph(df, 1, 2, 4; width=1000)
```
"""
function hydrograph(data::DataFrame, it::Int, iq::Int, ip::Int; kwargs...)::VLSpec
    T, Q, P = names(data)[[it, iq, ip]]
    return hydrograph(data, T, Q, P; kwargs...)
end

"""
    hydrograph(T::Array{Date,1}, Q::Array{Float64,1},
               P::Array{Float64,1}; kwargs...)::VLSpec

Plot a hydrograph with three arrays. All three arrays should have the same length.

### Arguments
* `T` : Array for time X axis
* `Q` : Array for streamflow Y axis
* `P` : Array for rainfall Y axis

### Examples
```julia
julia> hydrograph(df, 1, 2, 4; width=1000)
```
"""
function hydrograph(T::Array{Date,1}, Q::Array{Float64,1},
                    P::Array{Float64,1}; kwargs...)::VLSpec
    length(T) == length(Q) || throw(DimensionMismatch("Date and streamflow arrays have different lengths."))
    length(T) == length(P) || throw(DimensionMismatch("Date and rainfall arrays have different lengths."))

    data = DataFrame("Date"=>T, "Flow"=>Q, "Rainfall"=>P)
    return hydrograph(data, "Date", "Flow", "Rainfall"; kwargs...)
end

"""
    hydrograph(Q::DataFrame, P::DataFrame; kwargs...)::VLSpec

Plot a hydrograph with two dataframes. The two dataframes can have different periods.

### Arguments
* `Q` : A dataframe with "Date" and "Flow" columns
* `P` : A dtaaframe with "Date" and "Rainfall" columns

### Examples
```julia
julia> hydrograph(df_q, df_p; width=1000)
```
"""
function hydrograph(Q::DataFrame, P::DataFrame; kwargs...)::VLSpec
    data = outerjoin(Q, P, on="Date")
    sort!(data, "Date")
    return hydrograph(data, "Date", names(Q)[2], names(P)[2]; kwargs...)
end

"""
    dataset(name::AbstractString)::DataFrame

Return a sample dataset.

### Arguments
* `name` : Dataset name e.g. "doherty"

### Examples
```julia
julia> data = dataset("doherty")
```
"""
function dataset(name::AbstractString)::DataFrame
    data_path = joinpath(@__DIR__, "..", "data", string(name, ".csv"))

    ispath(data_path) || error("Unable to locate dataset file $data_path")
    isfile(data_path) || error("Not a file, $data_path")

    return DataFrame(File(data_path, header=true, comment="#"))
end

end # Hydrographs