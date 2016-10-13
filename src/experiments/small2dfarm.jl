module TinyFarm
#This generates small 2d examples for datacubes, can be used for example plotting
using SurrogateCube
macro load_defaults()
  esc(quote
    Ncomp=2
    Nvar=2
    Ntime=300
    Nlat=5
    Nlon=5
    kb=0.0
    kn=0.0
    ks=0.0
    kw=0.0
    b=[ConstantBaseline(0.0), ConstantBaseline(0.0)]
    n=[WhiteNoise(1.0),WhiteNoise(1.0)]
    dt=[CubeEvent(1,[0.6],[0.6],[0.2],[0.5],[0.5],[0.5]),EmptyEvent()]
    dnoise=WhiteNoise(0.1)
    coupling=Coupling[LinearCoupling(),LinearCoupling()]
    weight=[LaplaceWeight(2),LaplaceWeight(2)]
  end)
end

macro makeCube()
  esc(:(genDataCube(b,n,dt,dnoise,coupling,weight,Ncomp,Nvar,Ntime,Nlat,Nlon,kb,kn,ks,kw)))
end

function depShift()
  @load_defaults
  kw=1.0
  #Make sure event happens in all conmponents
  dt=[CubeEvent(1,[0.6],[0.6],[0.2],[0.5],[0.5],[0.5]),CubeEvent(1,[0.6],[0.6],[0.2],[0.5],[0.5],[0.5])]
  weight=[DisturbedLaplaceWeight(2),LaplaceWeight(2)]
  @makeCube
end

function baseShift()
  @load_defaults
  ks=5.0
  @makeCube
end

function noiseshift()
  @load_defaults
  kn=5.0
  @makeCube
end

function trendjump()
  @load_defaults
  ks=5.0
  dt[1]=TrendEvent(dt[1],false)
  @makeCube
end

function trendonset()
  @load_defaults
  ks=5.0
  dt[1]=TrendEvent(OnsetEvent(0.6,0.6,0.5,0.5,0.5),true)
  @makeCube
end

function quadraticdep()
  @load_defaults
  coupling[1]=QuadraticCoupling(1.0)
  @makeCube
end

function quadraticdepshift()
  @load_defaults
  coupling[2]=QuadraticCoupling(1.0)
  kw=1.0
  dt=[CubeEvent(1,[0.6],[0.6],[0.2],[0.5],[0.5],[0.5]),CubeEvent(1,[0.6],[0.6],[0.2],[0.5],[0.5],[0.5])]
  weight=[DisturbedLaplaceWeight([0.95,sqrt(1-0.95^2)],[-sqrt(1-0.95^2),0.95]),LaplaceWeight([0.9,sqrt(1-0.9^2)])]
  weight=[DisturbedLaplaceWeight(2),LaplaceWeight(2)]
  @makeCube
end

plotVars(c)=plot(1:300,slice(c.variables,:,3,3,:))
plotEvents(c)=plot(1:300,slice(c.eventmap,:,3,3,:))
plotComps(c)=plot(1:300,slice(c.components,:,3,3,:))
function plotDep(c)
  plot(c.variables[:,:,:,1][:],c.variables[:,:,:,2][:],".")
end




end
