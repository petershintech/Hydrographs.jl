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

function set_options!(vlspec, kwargs)
    if :width in keys(kwargs)
        for panel in vlspec["vconcat"]
            panel["width"] = kwargs[:width]
        end
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

end # Hydrographs