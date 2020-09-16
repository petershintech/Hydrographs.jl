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

    plt = hydrograph(data, "Date", 1, 2, 4)
    @test plt.vconcat[1]["encoding"]["x"]["field"] == "Date"
    @test plt.vconcat[1]["encoding"]["y"]["field"] == "Rainfall"
end