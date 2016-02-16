abstract Coupling
combineComponents(xout::AbstractArray,coupling::Coupling,dataNoise2::Vector)=error("Method coupling not yet defined for $coupling")
immutable LinearCoupling <: Coupling end

function combineComponents(xout::AbstractArray,acomp::AbstractArray,coupling::LinearCoupling,dataNoise::Vector)
  Ntime,Nlat,Nlon,Nvar=size(xout)
  Ncomp=size(acomp,4)
  for i=1:Nvar
    w = rand(Laplace(),Ncomp)
    w = w./sumabs(w)
    varnoise = genNoise(dataNoise[i],Ntime,Nlat,Nlon)
    for ilon=1:Nlon, ilat=1:Nlat, itime=1:Ntime
      for icomp=1:Ncomp
        xout[itime,ilat,ilon,i]+=acomp[itime,ilat,ilon,icomp]*w[icomp]
      end
      xout[itime,ilat,ilon,i]+=varnoise[itime,ilat,ilon]
    end
  end
  xout
end

"""A coupling where half of the variable depend linearly on the components and the other half nonlinearly"""
immutable QuadraticCoupling <: Coupling end
function combineComponents(xout::AbstractArray,acomp::AbstractArray,coupling::QuadraticCoupling,dataNoise::Vector)
  Ntime,Nlat,Nlon,Nvar=size(xout)
  Ncomp=size(acomp,4)
  for i=1:Nvar
    w = rand(Laplace(),Ncomp)
    dep = randbool(Ncomp)
    w = w./sumabs(w)
    varnoise = genNoise(dataNoise[i],Ntime,Nlat,Nlon)
    for ilon=1:Nlon, ilat=1:Nlat, itime=1:Ntime
      for icomp=1:Ncomp
        xout[itime,ilat,ilon,i]+= dep[icomp] ? acomp[itime,ilat,ilon,icomp]*w[icomp] : acomp[itime,ilat,ilon,icomp]*acomp[itime,ilat,ilon,icomp]*w[icomp]
      end
      xout[itime,ilat,ilon,i]+=varnoise[itime,ilat,ilon]
    end
  end
  xout
end
