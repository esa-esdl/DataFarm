using Distributions
#
#
#
# We want to model a disturbed dataset of the form X_xyt = μ + n + M
# where μ is some constant, periodic, or quasiperiodic mean, n is some kind
# of Noise and M is the disturbance

# Define Noise as an abstract type, each subtype should define the following methods:
# genNoise(,n::Noise,Nlon,Nlat,Ntime)
abstract Noise

# White Noise, everything is uncorrelated
type WhiteNoise <: Noise
    σ::Float64
end
genNoise(n::WhiteNoise,Nlon,Nlat,Ntime)=reshape(rand(Normal(0.0,n.σ),Nlon*Nlat*Ntime),Nlon,Nlat,Ntime)


# Define an abstract type for the ProcessMean, each subtype should define methods 
# genMean(p::ProcessMean,,Nlon,Nlat,Ntime )
abstract ProcessMean

# trivial case, constant mean wothout seasonal cycle
type ConstantMean <: ProcessMean
    m::Float64
end
genMean(c::ConstantMean,Nlon,Nlat,Ntime)=fill(c.m,Nlon,Nlat,Ntime)



# Define abstract type for the distrubance, each subtype should define the method
# genDisturbance()
abstract Disturbance

# simple cubic disturbance of relative size s (3-tuple 0..1) with the center corner at p (0..1)
# The positions and sizes are relative to the cube size
type CubeDisturbance <: Disturbance
    s::(Float64,Float64,Float64)
    p::(Float64,Float64,Float64)
end


function genDisturbance(d::CubeDisturbance,Nlon,Nlat,Ntime)
    sx=iround(d.s[1]*Nlon);px=iround(d.p[1]*Nlon+0.25)-div(sx,2)
    sy=iround(d.s[2]*Nlat);py=iround(d.p[2]*Nlat+0.25)-div(sy,2)
    sz=iround(d.s[3]*Ntime);pz=iround(d.p[3]*Ntime+0.25)-div(sz,2)
    # FIrst check that disturbance fits into the cube
    if (px+sx>Nlon+1) || (py+sy>Nlat+1) | (pz+sz>Ntime+1) error("Disturbance does not fit at the given place") end
    println("$px $sx $py $sy $pz $sz")
    a = zeros(Int,Nlon,Nlat,Ntime)
    a[px:(px+sx-1),py:(py+sy-1),pz:(pz+sz-1)]=1
    a
end

function genCube(mt::ProcessMean,nt::Noise,dt::Disturbance,Nlon,Nlat,Ntime,k)
    m=genMean(mt,Nlon,Nlat,Ntime)
    n=genNoise(nt,Nlon,Nlat,Ntime)
    d=genDisturbance(dt,Nlon,Nlat,Ntime)
    x = m + n + k * std(n) * d
end
     