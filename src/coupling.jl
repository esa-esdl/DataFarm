abstract Coupling
export Coupling
combineComponents(xout::AbstractArray,coupling::Coupling,dataNoise2::Vector)=error("Method coupling not yet defined for $coupling")
immutable LinearCoupling <: Coupling end
export LinearCoupling
"""A coupling where a fraction p of the components is qoupled quadratically"""
immutable QuadraticCoupling <: Coupling
  pquad::Float64 #Probability of a weight being quadratically coupled
end
QuadraticCoupling()=QuadraticCoupling(0.5)
export QuadraticCoupling
function combineComponents!(xout::AbstractArray,acomp::AbstractArray,dcomp,coupling,dataNoise::Vector,weights::Vector,kw::Number)
  Ntime,Nlat,Nlon,Nvar=size(xout)
  Ncomp=size(acomp,4)
  for i=1:Nvar
    w=weights[i]
    varnoise = genNoise(dataNoise[i],Ntime,Nlat,Nlon)
    fillVals(coupling[i],i,Nlon,Nlat,Ntime,Ncomp,xout,acomp,dcomp,w,kw,varnoise)
  end
  xout
end

function fillVals(c::QuadraticCoupling,i,Nlon,Nlat,Ntime,Ncomp,xout,acomp,dcomp,w,kw,varnoise)
  dep = rand(Ncomp) .<= c.pquad
  f=2^(-0.5)
  for ilon=1:Nlon, ilat=1:Nlat, itime=1:Ntime
    for icomp=1:Ncomp
      xout[itime,ilat,ilon,i]+= !dep[icomp] ? acomp[itime,ilat,ilon,icomp]*getWeight(w,icomp,kw,dcomp[itime,ilon,ilat,icomp]) : (acomp[itime,ilat,ilon,icomp]*acomp[itime,ilat,ilon,icomp]-1)*f*getWeight(w,icomp,kw,dcomp[itime,ilon,ilat,icomp])
    end
    xout[itime,ilat,ilon,i]+=varnoise[itime,ilat,ilon]
  end
end

function fillVals(::LinearCoupling,i,Nlon,Nlat,Ntime,Ncomp,xout,acomp,dcomp,w,kw,varnoise)
  for ilon=1:Nlon, ilat=1:Nlat, itime=1:Ntime
    for icomp=1:Ncomp
      xout[itime,ilat,ilon,i]+= acomp[itime,ilat,ilon,icomp]*getWeight(w,icomp,kw,dcomp[itime,ilon,ilat,icomp])
    end
    xout[itime,ilat,ilon,i]+=varnoise[itime,ilat,ilon]
  end
end
