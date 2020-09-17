module Hydrographs

using VegaLite
using DataFrames: DataFrame
using Dates: Date

export hydrograph

function hydrograph(data::DataFrame, T::AbstractString, Q::AbstractString)
    plt = data |> @vlplot(
        vconcat = [
            {
                width = 800,
                mark = "line",
                encoding = {
                    x = {
                        field = T,
                        type = "temporal",
                        scale = {
                            domain = {
                                selection = "brush"
                            }
                        },
                        axis = {
                            title = ""
                        }
                    },
                    y = {
                        field = Q,
                        type = "quantitative"
                    }
                },
                transform = [{filter = {selection = "brush"}}]
            },
            {
                width = 800,
                height = 60,
                mark = "area",
                selection = {
                    brush = {
                        type = "interval",
                        encodings = ["x"]
                    }
                },
                encoding = {
                    x = {
                        field = T,
                        type = "temporal"
                    },
                    y = {
                        field = Q,
                        type = "quantitative",
                        axis = {
                            tickCount = 3,
                            grid = false
                        }
                    }
                }
            }
        ]
    )

    return plt
end

function hydrograph(data::DataFrame,
                    T::AbstractString, Q::AbstractString, P::AbstractString)
    plt = data |> @vlplot(
        vconcat = [
            {
                width = 800,
                height = 60,
                mark = {
                    type = "bar",
                    binSpacing = 0
                },
                encoding = {
                    x = {
                        field = T,
                        type = "temporal",
                        scale = {
                            domain = {
                                selection = "brush"
                            }
                        },
                        axis = {
                            title = "",
                            labels = false
                        }
                    },
                    y = {
                        field = P,
                        type = "quantitative"
                    }
                },
                transform = [{filter = {selection = "brush"}}]
            },
            {
                width = 800,
                mark = {type = "area", line = true},
                encoding = {
                    x = {
                        field = T,
                        type = "temporal",
                        scale = {
                            domain = {
                                selection = "brush"
                            }
                        },
                        axis = {
                            title = ""
                        }
                    },
                    y = {
                        field = Q,
                        type = "quantitative"
                    }
                },
                transform = [{filter = {selection = "brush"}}]
            },
            {
                width = 800,
                height = 60,
                mark = "area",
                selection = {
                    brush = {
                        type = "interval",
                        encodings = ["x"]
                    }
                },
                encoding = {
                    x = {
                        field = T,
                        type = "temporal",
                        timeUnit = "yearmonth"
                    },
                    y = {
                        field = Q,
                        type = "quantitative",
                        axis = {
                            tickCount = 3,
                            grid = false
                        },
                        aggregate = "sum"
                    }
                }
            }
        ]
    )

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
    length(T) == length(Q) || throw(ArgumentError("Date and streamflow arrays have different lengths."))
    length(T) == length(P) || throw(ArgumentError("Date and rainfall arrays have different lengths."))

    data = DataFrame("Date"=>T, "Flow"=>Q, "Rainfall"=>P)
    return hydrograph(data, "Date", "Flow", "Rainfall")
end

end # Hydrographs