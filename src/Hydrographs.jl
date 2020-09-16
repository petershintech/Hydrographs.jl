module Hydrographs

using VegaLite
using DataFrames: DataFrame

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

function hydrograph(data::DataFrame)
    T, Q = names(data)[1:2]
    return hydrograph(data, T, Q)
end

function hydrograph(data::DataFrame, it::Int, iq::Int)
    T, Q = names(data)[[it, iq]]
    return hydrograph(data, T, Q)
end

end # Hydrographs