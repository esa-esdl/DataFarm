
@doc """
Noise is an abstract type representing fluctuations around a baseline of a variable, each subtype should define the following method:

    genNoise(,n::Noise,Nlon,Nlat,Ntime)

"""->
abstract Noise
export Noise


@doc "This function generates a 3D Array of Nlon, Nlat, Ntime"->
genNoise(n::Noise,Nlon,Nlat,Ntime)=error("Method genNoise not implemented for type $(typeof(n)).")
export genNoise


@doc """
The simplest form of noise, White noise with mean 0 and standard deviation `s`
"""->
# White Noise, everything is uncorrelated
type WhiteNoise <: Noise
    s::Float64
end
export WhiteNoise
genNoise(n::WhiteNoise,Nlon,Nlat,Ntime)=reshape(rand(Normal(0.0,n.s),Nlon*Nlat*Ntime),Nlon,Nlat,Ntime)
