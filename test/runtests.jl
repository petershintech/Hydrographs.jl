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

    plt = hydrograph(data, "date", "flow")
    @test plt.vconcat[1]["encoding"]["x"]["field"] == "date"
    @test plt.vconcat[2]["encoding"]["y"]["field"] == "flow"
end