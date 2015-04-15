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
    a = zeros(Int,Nlon,Nlat,Ntime)
    a[px:(px+sx-1),py:(py+sy-1),pz:(pz+sz-1)]=1
    a
end
# Some convenience Constructors to create centered disturbances of a certain size
CubeDisturbance(s::Number) =  CubeDisturbance((s,s,s),(0.5,0.5,0.5))

#simple local distrubance that covers a single longitude-latitude point (0..1,0..1) over the time span s (0..1) starting at time t (0..1)
type LocalDisturbance <: Disturbance
    xlon::Float64
    xlat::Float64
    s   ::Float64
    t   ::Float64
end
function genDisturbance(d::LocalDisturbance,Nlon,Nlat,Ntime)
    sx = iround(d.xlon*Nlon)
    sy = iround(d.xlat*Nlat)
    tstart = iround(d.s*Ntime+0.5)
    tend   = tstart+iround(d.t*Ntime+0.5)-1
    a = zeros(Int,Nlon,Nlat,Ntime)
    a[sx,sy,tstart:tend]=1
    a
end


#Type for an empty Distrubance
type EmptyDisturbance <: Disturbance
end
genDisturbance(d::EmptyDisturbance,Nlon,Nlat,Ntime)=zeros(Int,Nlon,Nlat,Ntime)