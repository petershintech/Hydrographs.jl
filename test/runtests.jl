using Hydrographs

using Test
using CSV

@testset "Hydrographs.jl" begin
    data = CSV.read(joinpath("..", "data", "data.csv"))

    plt = hydrograph(data)
    @test plt.vconcat[1]["encoding"]["x"]["field"] == names(data)[1]
    @test plt.vconcat[2]["encoding"]["y"]["field"] == names(data)[2]

    plt = data |> hydrograph
    @test plt.vconcat[1]["encoding"]["x"]["field"] == names(data)[1]
    @test plt.vconcat[2]["encoding"]["y"]["field"] == names(data)[2]

    plt = hydrograph(data, 1, 2)
    @test plt.vconcat[1]["encoding"]["x"]["field"] == names(data)[1]
    @test plt.vconcat[2]["encoding"]["y"]["field"] == names(data)[2]

    plt = hydrograph(data, "Date", "Flow")
    @test plt.vconcat[1]["encoding"]["x"]["field"] == "Date"
    @test plt.vconcat[2]["encoding"]["y"]["field"] == "Flow"

    plt = hydrograph(data, "Date", "Flow", "Rainfall")
    @test plt.vconcat[1]["encoding"]["x"]["field"] == "Date"
    @test plt.vconcat[1]["encoding"]["y"]["field"] == "Rainfall"

    plt = hydrograph(data, 1, 2, 4)
    @test plt.vconcat[1]["encoding"]["x"]["field"] == "Date"
    @test plt.vconcat[1]["encoding"]["y"]["field"] == "Rainfall"

    T = data.Date; Q = data.Flow; P = data.Rainfall
    p = hydrograph(T, Q, P)
    @test plt.vconcat[1]["encoding"]["x"]["field"] == "Date"
    @test plt.vconcat[1]["encoding"]["y"]["field"] == "Rainfall"
    @test_throws DimensionMismatch hydrograph(T[1:end-1],Q,P)

    plt = hydrograph(data; width=1000)
    @test plt.vconcat[1]["encoding"]["x"]["field"] == names(data)[1]
    @test plt.vconcat[2]["encoding"]["y"]["field"] == names(data)[2]
end