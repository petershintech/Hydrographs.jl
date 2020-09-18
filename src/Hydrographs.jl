module Hydrographs

using Dates: Date
using DataStructures: OrderedDict
using DataFrames: DataFrame
using JSON: parse
using VegaLite: VLSpec

export hydrograph

function read_template()
    path = joinpath(dirname(@__FILE__), "template.json")
    template = parse(open(path), dicttype=OrderedDict)
    return template
end

vl_template = read_template()

function hydrograph(data::DataFrame, T::AbstractString, Q::AbstractString)::VLSpec
    vlspec = deepcopy(vl_template)

    popfirst!(vlspec["vconcat"])

    for panel in vlspec["vconcat"]
        panel["encoding"]["x"]["field"] = T
        panel["encoding"]["y"]["field"] = Q
    end

    plt = data |> VLSpec(vlspec)
    return plt
end

function hydrograph(data::DataFrame,
                    T::AbstractString, Q::AbstractString, P::AbstractString)::VLSpec
    vlspec = deepcopy(vl_template)

    for panel in vlspec["vconcat"]
        panel["encoding"]["x"]["field"] = T
    end
    vlspec["vconcat"][1]["encoding"]["y"]["field"] = P
    vlspec["vconcat"][2]["encoding"]["y"]["field"] = Q
    vlspec["vconcat"][3]["encoding"]["y"]["field"] = Q

    plt = data |> VLSpec(vlspec)
    return plt
end

function hydrograph(data::DataFrame)
    T, Q = names(data)[1:2]
    return hydrograph(data, T, Q)
end

function hydrograph(data::DataFrame, it::Int, iq::Int)
    T, Q = names(data)[[it, iq]]
    return hydrograph(data, T, Q)
end

function hydrograph(data::DataFrame, it::Int, iq::Int, ip::Int)
    T, Q, P = names(data)[[it, iq, ip]]
    return hydrograph(data, T, Q, P)
end

function hydrograph(T::Array{Date,1}, Q::Array{Float64,1}, P::Array{Float64,1})
    length(T) == length(Q) || throw(DimensionMismatch("Date and streamflow arrays have different lengths."))
    length(T) == length(P) || throw(DimensionMismatch("Date and rainfall arrays have different lengths."))

    data = DataFrame("Date"=>T, "Flow"=>Q, "Rainfall"=>P)
    return hydrograph(data, "Date", "Flow", "Rainfall")
end

end # Hydrographs