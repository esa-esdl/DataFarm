# Define an abstract type for the Baseline, each subtype should define methods 
# genMean(p::Baseline,,Nlon,Nlat,Ntime )
abstract Baseline
export Baseline
# trivial case, constant mean wothout seasonal cycle
type ConstantBaseline <: Baseline
    m::Float64
end
export ConstantBaseline
genBaseline(c::ConstantBaseline,Nlon,Nlat,Ntime)=fill(c.m,Nlon,Nlat,Ntime)
export genBaseline
# very simple periodic Mean
type SineBaseline <: Baseline
	nOsc::Int # Number of oscillations
	amp::Float64
end
export SineBaseline
genBaseline(m::SineBaseline,Nlon,Nlat,Ntime)=[m.amp*sin(k*m.nOsc/Ntime*2*pi) for i=1:Nlon,j=1:Nlat,k=1:Ntime]


