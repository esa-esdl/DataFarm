@doc """
Abstract type for the Baseline, each subtype should define the method 
genBaseline(p::Baseline,,Nlon,Nlat,Ntime )
""" ->
abstract Baseline
export Baseline

@doc "This function generates the Baseline 3D Array of size Nlon, Nlat, Ntime."->
genBaseline(m::Baseline,Nlon,Nlat,Ntime)=error("Method genBaseline not implemented for $(typeof(m))")
export genBaseline

@doc """
Most trivial baseline case, constant mean `m` without seasonal cycle
"""->
type ConstantBaseline <: Baseline
    m::Float64
end
export ConstantBaseline
genBaseline(c::ConstantBaseline,Ntime,Nlat,Nlon)=fill(c.m,Ntime,Nlat,Nlon)

@doc """
very simple periodic BaseLine returning a sine oscillation in the time domain, 
where `nOsc` is the number of oscillations and `amp` is the amplitude
"""->
type SineBaseline <: Baseline
	nOsc::Float64 # Number of oscillations
	amp::Float64
end
export SineBaseline
genBaseline(m::SineBaseline,Ntime,Nlat,Nlon)=[m.amp*sin(k*m.nOsc/Ntime*2*pi) for k=1:Ntime,j=1:Nlat,i=1:Nlon]

@doc """
A trend baseline where the mean is 0 and there is a trend in Lon, Lat and Time dimension. The range of the trend will be 
`[-tlon,tlon], [-tlat,tlat], [-ttime,ttime]`
"""->
type TrendBaseline <: Baseline
	tlon::Float64
	tlat::Float64
	ttime::Float64
end
export TrendBaseline
genBaseline(m::TrendBaseline,Ntime,Nlat,Nlon)=[(i-1)/(Nlon-1)*2*m.tlon-m.tlon + (j-1)/(Nlat-1)*2*m.tlat-m.tlat + (k-1)/(Ntime-1)*2*m.ttime-m.ttime for k=1:Ntime,j=1:Nlat,i=1:Nlon]