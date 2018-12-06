import Mocking: Bindings, ingest_signature!

@testset "signature" begin
    @test @valid_method f(x) = x
    b = Bindings()
    ingest_signature!(b, :(f(x) = x).args[1])
    @test b.internal == Set([:x])
    @test b.external == Set([:f])


    b = Bindings()
    ingest_signature!(b, :(f{T}(::Type{T}) = T).args[1])
    @test b.internal == Set([:T])
    @test b.external == Set([:f, :Type])


    @test @valid_method f(::Type{T}) where T = T
    b = Bindings()
    ingest_signature!(b, :(f{T}(::Type{T}) = T).args[1])
    @test b.internal == Set([:T])
    @test b.external == Set([:Type, :f])


    b = Bindings()
    ingest_signature!(b, :(f{T,S<:T}(x::T, y::S) = (x, y)).args[1])
    @test b.internal == Set([:T, :S, :x, :y])
    @test b.external == Set([:f])

    @test @valid_method f(x::T, y::S) where S<:T where T = (x, y)
    b = Bindings()
    ingest_signature!(b, :(f(x::T, y::S) where S<:T where T = (x, y)).args[1])
    @test b.internal == Set([:T, :S, :x, :y])
    @test b.external == Set([:f])

    @test @valid_method f(x::T, y::S) where {T,S<:T} = (x, y)
    b = Bindings()
    ingest_signature!(b, :(f(x::T, y::S) where {T,S<:T} = (x, y)).args[1])
    @test b.internal == Set([:T, :S, :x, :y])
    @test b.external == Set([:f])

    @test @valid_method f(x=f) = x  # `f` the argument default refers the the function `f`
    b = Bindings()
    ingest_signature!(b, :(f(x=f)))
    @test b.internal == Set([:x])
    @test b.external == Set([:f])

    @test @valid_method f(f) = f  # `f` the function and `f` the parameter variable
    b = Bindings()
    ingest_signature!(b, :(f(f)))
    @test b.internal == Set([:f]) # Technically there are two separate `f`s here
    @test b.external == Set([:f])

    # f = 1; f(x=f) = f  # Error
end
