# Define an abstract type for the ProcessMean, each subtype should define methods 
# genMean(p::ProcessMean,,Nlon,Nlat,Ntime )
abstract ProcessMean
export ProcessMean
# trivial case, constant mean wothout seasonal cycle
type ConstantMean <: ProcessMean
    m::Float64
end
export ConstantMean
genMean(c::ConstantMean,Nlon,Nlat,Ntime)=fill(c.m,Nlon,Nlat,Ntime)
export genMean
# very simple periodic Mean
type PeriodicSineMean <: ProcessMean
	nOsc::Int # Number of oscillations
	amp::Float64
end
export PeriodicSineMean
genMean(m::PeriodicSineMean,Nlon,Nlat,Ntime)=[m.amp*sin(k*m.nOsc/Ntime*2*pi) for i=1:Nlon,j=1:Nlat,k=1:Ntime]


