module SurrogateCube
import Distributions: Normal, Laplace
using Docile
@docstrings
#
#
#
# We want to model a disturbed dataset of the form X_xyt = μ + n + M
# where μ is some constant, periodic, or quasiperiodic mean, n is some kind
# of Noise and M is the disturbance

# Define the return Datastructure of genDataset, so that it can be easily saved
type DataCube
	variables::Array{Float64,4}
	components::Array{Float64,4}
	eventmap::Array{Float64,4}
	baselines::Vector
	compnoise::Vector
	events::Vector
	varnoise::Vector
	k1::Float64
	k2::Float64
	k3::Float64
end

include("noise.jl")
include("baseline.jl")
include("event.jl")
include("io.jl")

@doc """
Function that generates a single datacube, this can serve as a basis to build an independent component of a dataset. The input is as follows:
- mt: Baseline, the process mean
- nt: Noise, the noise chosen
- dt: Event, the disturbance event
- Nlon: Number of longitudes
- Nlat: Number of Latitudes
- Ntime: Number of Time steps
- `kb > 0` : Strength of baseline modulation by event, kb=1 means no modulation, kb=2 means double amplitude, kb=0.5 means half amplitude
- `kn > 0` : Strength of noise modulation by event, kn=1, means no modulation, kn=2 double noise, kn=0.5 half noise 
- `ks > 0: Strength of mean shift event, ks=1 no shift ks=0.5 shift in negative direction by one sd(noise), ks=2 shift by one sd(noise) in positive direction
""" ->
function genDataStream(mt::Baseline,nt::Noise,dt::Event,Nlon,Nlat,Ntime,kb,kn,ks)
    b  = genBaseline(mt,Nlon,Nlat,Ntime)
    n  = genNoise(nt,Nlon,Nlat,Ntime)
    ev = genEvent(dt,Nlon,Nlat,Ntime)
    x = b .* 2.^(kb*ev) + n .* 2.^(kn*ev) + std(n) * ks * ev
    return(x,ev)
end
#If only one k is given, apply it to k3
genDataStream(mt::Baseline,nt::Noise,dt::Event,Nlon,Nlat,Ntime,k)=genDataStream(mt,nt,dt,Nlon,Nlat,Ntime,0.0,0.0,k)

export genDataStream
@doc """
This function generates a whole multivariate datacube, the input is as follows. It needs the followings input:
- mt: Baseline or Vector{Baseline}, the process mean for the components
- nt: Noise or Vector{Noise}, the noise chosen for the independent components
- dt: Event or Vector{Event}, the distirbance events for each component
- dataNoise: Noise or Vector{Noise}, the noise added to each variable of the DataCube
- Ncomp: Number of independent components to generate
- Nvar: Number of variables to generate
- Nlon: Number of longitudes
- Nlat: Number of Latitudes
- Ntime: Number of Time steps
- kb: Strength of baseline modulation by event, kb=1 means no modulation, kb=2 means double amplitude, kb=0.5 means half amplitude
- kn: Strength of noise modulation by event, kn=1, means no modulation, kn=2 double noise, kn=0.5 half noise 
- ks: Strength of mean shift event, ks=1 no shift ks=0.5 shift in negative direction by one sd(noise), ks=2 shift by one sd(noise) in positive direction
""" ->
function genDataCube{T<:Baseline,U<:Noise,V<:Event,W<:Noise}(mt::Union(Vector{T},T),nt::Union(Vector{U},U),dt::Union(Vector{V},V),dataNoise::Union(Vector{W},W),Ncomp,Nvar,Nlon,Nlat,Ntime,kb,kn,ks)
    #Make vectors if single values were given by the user
    mt2 = isa(mt,Vector) ? mt : fill(mt,Ncomp)
    nt2 = isa(nt,Vector) ? nt : fill(nt,Ncomp)
    dt2 = isa(dt,Vector) ? dt : fill(dt,Ncomp)
    # First generate the independent components of the datacube
    dataNoise2 = isa(dataNoise,Vector) ? dataNoise : fill(dataNoise,Nvar)

    acomp = zeros(Float64,Ncomp,Nlon,Nlat,Ntime)
    dcomp = zeros(Float64,Ncomp,Nlon,Nlat,Ntime)
    
    for i = 1:Ncomp
        
        x,d = genDataStream(mt2[i],nt2[i],dt2[i],Nlon,Nlat,Ntime,kb,kn,ks)
        acomp[i,:,:,:]=x
        dcomp[i,:,:,:]=d
        
    end
    
    # Generate weights to generate variables out of the independent components
    xout = zeros(Float64,Nvar,Nlon,Nlat,Ntime)
    for i=1:Nvar
        w = rand(Laplace(),Ncomp)
        w = w./sumabs(w)
        varnoise = genNoise(dataNoise2[i],Nlon,Nlat,Ntime)
        for ilon=1:Nlon, ilat=1:Nlat, itime=1:Ntime
            for icomp=1:Ncomp
                xout[i,ilon,ilat,itime]+=acomp[icomp,ilon,ilat,itime]*w[icomp]
            end
            xout[i,ilon,ilat,itime]+=varnoise[ilon,ilat,itime]
        end
    end
    DataCube(xout,acomp,dcomp,mt2,nt2,dt2,dataNoise2,kb,kn,ks)
end
genDataCube{T<:Baseline,U<:Noise,V<:Event,W<:Noise}(mt::Union(Vector{T},T),nt::Union(Vector{U},U),dt::Union(Vector{V},V),dataNoise::Union(Vector{W},W),Ncomp,Nvar,Nlon,Nlat,Ntime,k)=genDataCube(mt,nt,dt,dataNoise,Ncomp,Nvar,Nlon,Nlat,Ntime,0.0,0.0,k)
export genDataCube
end  

    
    
    
