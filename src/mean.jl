# Define an abstract type for the ProcessMean, each subtype should define methods 
# genMean(p::ProcessMean,,Nlon,Nlat,Ntime )
abstract ProcessMean

# trivial case, constant mean wothout seasonal cycle
type ConstantMean <: ProcessMean
    m::Float64
end
genMean(c::ConstantMean,Nlon,Nlat,Ntime)=fill(c.m,Nlon,Nlat,Ntime)

