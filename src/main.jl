using Distributions
#
#
#
# We want to model a disturbed dataset of the form X_xyt = μ + n + M
# where μ is some constant, periodic, or quasiperiodic mean, n is some kind
# of Noise and M is the disturbance
include("noise.jl")
include("mean.jl")
include("disturbance.jl")

#Function that generates a single datacube, this can serve as a basis to build an independent component of a dataset
function genCube(mt::ProcessMean,nt::Noise,dt::Disturbance,Nlon,Nlat,Ntime,k)
    m=genMean(mt,Nlon,Nlat,Ntime)
    n=genNoise(nt,Nlon,Nlat,Ntime)
    d=genDisturbance(dt,Nlon,Nlat,Ntime)
    x = m + n + k * std(n) * d
    return(x,d.>0)
end

#This function generates a whole multivariate datacube, the input is as follows:
function genDataset{T<:ProcessMean,U<:Noise,V<:Disturbance,W<:Noise}(mt::Union(Vector{T},T),nt::Union(Vector{U},U),dt::Union(Vector{V},V),dataNoise::Union(Vector{W},W),Ncomp,Nvar,Nlon,Nlat,Ntime,k)
    #Make vectors if single values were given by the user
    mt2 = isa(mt,Vector) ? mt : fill(mt,Ncomp)
    nt2 = isa(nt,Vector) ? nt : fill(nt,Ncomp)
    dt2 = isa(dt,Vector) ? dt : fill(dt,Ncomp)
    # First generate the independent components of the datacube
    dataNoise2 = isa(dataNoise,Vector) ? dataNoise : fill(dataNoise,Nvar)

    acomp = Array(Float64,Ncomp,Nlon,Nlat,Ntime)
    dcomp = falses(Ncomp,Nlon,Nlat,Ntime)
    for i = 1:Ncomp
        
        x,d = genCube(mt2[i],nt2[i],dt2[i],Nlon,Nlat,Ntime,k)
        acomp[i,:,:,:]=x
        dcomp[i,:,:,:]=d
        
    end
    
    # Generate weights to generate variables out of the independent components
    xout = zeros(Float64,Nvar,Nlon,Nlat,Ntime)
    for i=1:Nvar
        w = rand(Normal(),Ncomp)
        w = w./sum(w)
        varnoise = genNoise(dataNoise2[i],Nlon,Nlat,Ntime)
        for ilon=1:Nlon, ilat=1:Nlat, itime=1:Ntime
            for icomp=1:Ncomp
                xout[i,ilon,ilat,itime]+=acomp[icomp,ilon,ilat,itime]*w[icomp]
            end
            xout[i,ilon,ilat,itime]+=varnoise[ilon,ilat,itime]
        end
    end
    
    xout,acomp,dcomp
end
    

    
    
    
