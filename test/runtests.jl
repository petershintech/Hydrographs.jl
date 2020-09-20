using Hydrographs

using Test

@testset "Hydrographs.jl" begin
    data = dataset("doherty")
    @test names(data) == ["Date", "Flow", "Qcode", "Rainfall"]
    @test size(data)[1] > 0

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

    plt = hydrograph(data; aggregate="monthly")
    @test plt.vconcat[end]["encoding"]["x"]["timeUnit"] == "yearmonth"
    @test plt.vconcat[end]["encoding"]["y"]["aggregate"] == "sum"

    plt = hydrograph(data, 1, 2, 4; aggregate="weekly")
    @test plt.vconcat[end]["encoding"]["x"]["timeUnit"] == "yearweek"
    @test plt.vconcat[end]["encoding"]["y"]["aggregate"] == "sum"

    plt = hydrograph(data; logscale=true)
    @test plt.vconcat[end-1]["encoding"]["y"]["scale"]["type"] == "log"
    @test plt.vconcat[end]["encoding"]["y"]["scale"]["type"] == "log"
end