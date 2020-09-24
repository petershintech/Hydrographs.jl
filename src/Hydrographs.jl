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
    Plot a hydrograph with streamflow and rainfall data


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

You can plot a hydrograph with two dataframes: one for streamflow data and the other for rainfall data.
In the case, the data periods can be different.

````julia
julia> Q = data[!,[:Date,:Flow]]
julia> P = data[!,[:Date,:Rainfall]]
julia> hydrograph(Q, P)
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
"""
function hydrograph() end

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

function hydrograph(data::DataFrame; kwargs...)
    T, Q = names(data)[1:2]
    return hydrograph(data, T, Q; kwargs...)
end

function hydrograph(data::DataFrame, it::Int, iq::Int; kwargs...)
    T, Q = names(data)[[it, iq]]
    return hydrograph(data, T, Q; kwargs...)
end

function hydrograph(data::DataFrame, it::Int, iq::Int, ip::Int; kwargs...)
    T, Q, P = names(data)[[it, iq, ip]]
    return hydrograph(data, T, Q, P; kwargs...)
end

function hydrograph(T::Array{Date,1}, Q::Array{Float64,1},
                    P::Array{Float64,1}; kwargs...)
    length(T) == length(Q) || throw(DimensionMismatch("Date and streamflow arrays have different lengths."))
    length(T) == length(P) || throw(DimensionMismatch("Date and rainfall arrays have different lengths."))

    data = DataFrame("Date"=>T, "Flow"=>Q, "Rainfall"=>P)
    return hydrograph(data, "Date", "Flow", "Rainfall"; kwargs...)
end

function hydrograph(Q::DataFrame, P::DataFrame; kwargs...)
    data = outerjoin(Q, P, on="Date")
    sort!(data, "Date")
    return hydrograph(data, "Date", names(Q)[2], names(P)[2]; kwargs...)
end

function dataset(name::AbstractString)::DataFrame
    data_path = joinpath(@__DIR__, "..", "data", string(name, ".csv"))

    ispath(data_path) || error("Unable to locate dataset file $data_path")
    isfile(data_path) || error("Not a file, $data_path")

    return DataFrame(File(data_path, header=true, comment="#"))
end

end # Hydrographs