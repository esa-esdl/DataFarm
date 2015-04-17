# Define abstract type for the distrubance, each subtype should define the method
# genDisturbance()
abstract Event
export Event
# simple cubic disturbance of relative size s (3-tuple 0..1) with the center corner at p (0..1)
# The positions and sizes are relative to the cube size
type CubeEvent <: Event
    sx::Float64
    sy::Float64
    sz::Float64
    px::Float64
    py::Float64
    pz::Float64
end
export CubeEvent
export genEvent
function genEvent(d::CubeEvent,Nlon,Nlat,Ntime)
    sx=iround(d.sx*Nlon);px=iround(d.px*Nlon+0.25)-div(sx,2)
    sy=iround(d.sx*Nlat);py=iround(d.px*Nlat+0.25)-div(sy,2)
    sz=iround(d.sx*Ntime);pz=iround(d.px*Ntime+0.25)-div(sz,2)
    # FIrst check that disturbance fits into the cube
    if (px+sx>Nlon+1) || (py+sy>Nlat+1) | (pz+sz>Ntime+1) error("Event does not fit at the given place") end
    a = zeros(Int,Nlon,Nlat,Ntime)
    a[px:(px+sx-1),py:(py+sy-1),pz:(pz+sz-1)]=1
    a
end
# Some convenience Constructors to create centered disturbances of a certain size
CubeEvent(s::Number) =  CubeEvent(s,s,s,0.5,0.5,0.5)

#simple local distrubance that covers a single longitude-latitude point (0..1,0..1) over the time span s (0..1) starting at time t (0..1)
type LocalEvent <: Event
    xlon::Float64
    xlat::Float64
    s   ::Float64
    t   ::Float64
end
export LocalEvent
function genEvent(d::LocalEvent,Nlon,Nlat,Ntime)
    sx = iround(d.xlon*Nlon)
    sy = iround(d.xlat*Nlat)
    tstart = iround(d.s*Ntime+0.5)
    tend   = tstart+iround(d.t*Ntime+0.5)-1
    a = zeros(Int,Nlon,Nlat,Ntime)
    a[sx,sy,tstart:tend]=1
    a
end


#Type for an empty Distrubance
type EmptyEvent <: Event
end
export EmptyEvent
genEvent(d::EmptyEvent,Nlon,Nlat,Ntime)=zeros(Int,Nlon,Nlat,Ntime)