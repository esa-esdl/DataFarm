@doc """
Define abstract type for the distrubance, each subtype should define the method
genEvent(d::Event,Nlon,Nlat,Ntime)
"""->
abstract Event
export Event
outevent!(ev::Event,x)=x

@doc """
This function generates a 3D Array of Ntime, Nlat, Nlon. It should `= 0` for all points that are not affected by an event and `> 0` 
for affected grid cells. In the simplest case the resulting array is binary (either 0 or 1)
"""->
genEvent(d::Event,Ntime,Nlat,Nlon)=error("The method genEvent is not defined for $(typeof(d))")


@doc """
simple cubic disturbance of relative size sx,sy,sz (0..1) with the center at px,py,pz (0..1)
The positions and sizes are relative to the cube size
"""->
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
function genEvent(d::CubeEvent,Ntime,Nlat,Nlon)
    sx=d.sx*Nlon/2-0.5;px=d.px*(Nlon+1)
    sy=d.sy*Nlat/2-0.5;py=d.py*(Nlat+1)
    sz=d.sz*Ntime/2-0.5;pz=d.pz*(Ntime+1)
    # FIrst check that disturbance fits into the cube
    a = zeros(Float64,Ntime,Nlat,Nlon)
    a[iround(pz-sz):iround(pz+sz),iround(py-sy):iround(py+sy),iround(px-sx):iround(px+sx)]=1
    a
end
# Some convenience Constructors to create centered disturbances of a certain size
CubeEvent(s::Number) =  CubeEvent(s,s,s,0.5,0.5,0.5)


@doc """
simple local distrubance that covers a single longitude-latitude point (0..1,0..1) over the time span s (0..1) starting at time t (0..1)
"""->
type LocalEvent <: Event
    xlon::Float64
    xlat::Float64
    s   ::Float64
    t   ::Float64
end
export LocalEvent
function genEvent(d::LocalEvent,Ntime,Nlat,Nlon)
    sx = iround(d.xlon*Nlon)
    sy = iround(d.xlat*Nlat)
    tstart = iround(d.s*Ntime+0.5)
    tend   = tstart+iround(d.t*Ntime+0.5)-1
    a = zeros(Float64,Ntime,Nlat,Nlon)
    a[tstart:tend,sx,sy]=1
    a
end


@doc "Type for an empty Disturbance"->
type EmptyEvent <: Event
end
export EmptyEvent
genEvent(d::EmptyEvent,Ntime,Nlat,Nlon)=zeros(Int,Ntime,Nlat,Nlon)



@doc "Gaussian disturbance, no sharp edegs. This is constructed by supplying a center px,py,pz and bandwidth sx,sy,sz"->
type GaussianEvent
    sx::Float64
    sy::Float64
    sz::Float64
    px::Float64
    py::Float64
    pz::Float64
end
export GaussianEvent
GaussianEvent(s::Number)=GaussianEvent(s,s,s,0.5,0.5,0.5)
function genEvent(d::GaussianEvent,Ntime,Nlat,Nlon)
    sx=d.sx*Nlon/2-0.5;px=d.px*(Nlon+1)
    sy=d.sy*Nlat/2-0.5;py=d.py*(Nlat+1)
    sz=d.sz*Ntime/2-0.5;pz=d.pz*(Ntime+1)
    a=[exp((i-px)^2/sx^2 + (j-py)^2/sy^2) + (k-pz)^2/sz^2 for k=1:Ntime,j=1:Nlat,i=1:Nlon]
end

@doc """
This is a wrapper type that generates trend-like events in time. It wraps a given event `ev` which is usually a step 
function and integrates it in the time domain to obtain slowly changing behaviour.
"""->
type TrendEvent{T<:Event} <: Event
    ev::T
end
export TrendEvent
function genEvent(d::TrendEvent,Ntime,Nlat,Nlon)
    #First generate innner event
    a = genEvent(d.ev,Ntime,Nlat,Nlon)
    #Integrate over time
    cumsum!(a,a,1)
    #And rescale
    scale!(a,1./maximum(a))
    a
end
function outevent!(ev::TrendEvent,x)
    for ilon=1:size(x,3), ilat=1:size(x,2), itime=size(x,1):-1:2
        x[itime,ilat,ilon]=x[itime,ilat,ilon]-x[itime-1,ilat,ilon]
    end
    scale!(x,1/maximum(x))
    x
end

@doc "This generates an event of spatial size sx,sy at px,py that starts at time os and lasts until the end of the time series"->
type OnsetEvent <: Event
    sx::Float64
    sy::Float64
    px::Float64
    py::Float64
    os::Float64
end
export OnsetEvent
function genEvent(d::OnsetEvent,Ntime,Nlat,Nlon)
    sx=d.sx*Nlon/2-0.5;px=d.px*(Nlon+1)
    sy=d.sy*Nlat/2-0.5;py=d.py*(Nlat+1)
    pz=d.os*(Ntime+1)
    # FIrst check that disturbance fits into the cube
    a = zeros(Float64,Ntime,Nlat,Nlon)
    a[iround(pz):Ntime,iround(py-sy):iround(py+sy),iround(px-sx):iround(px+sx)]=1
    a
end








