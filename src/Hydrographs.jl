module Hydrographs

using Dates: Date
using DataStructures: OrderedDict
using DataFrames: DataFrame, outerjoin
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
    data = outerjoin(Q, P, on=:Date)
    return hydrograph(data, names(Q)[2], names(P)[2]; kwargs...)
end

function dataset(name::AbstractString)::DataFrame
    data_path = joinpath(@__DIR__, "..", "data", string(name, ".csv"))

    ispath(data_path) || error("Unable to locate dataset file $data_path")
    isfile(data_path) || error("Not a file, $data_path")

    return DataFrame(File(data_path, header=true, comment="#"))
end

end # Hydrographs