using RandomNumbers
using Base.Test: @test

macro test_diff(dir1, dir2)
    files1 = readdir(dir1)
    files2 = readdir(dir2)
    @test files1 == files2
    for file in files1
        file1 = joinpath(dir1, file)
        file2 = joinpath(dir2, file)
        @test readlines(file1) == readlines(file2)
    end
end
