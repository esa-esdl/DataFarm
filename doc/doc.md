# SurrogateCube

## Exported
---

#### genBaseline(m::Baseline, Nlon, Nlat, Ntime)
This function generates the Baseline 3D Array of size Nlon, Nlat, Ntime.

**source:**
[SurrogateCube/src/mean.jl:8](file:///Users/fgans/.julia/v0.3/SurrogateCube/src/mean.jl)

---

#### genDataCube{T<:Baseline, U<:Noise, V<:Event, W<:Noise}(mt::Union(Array{T<:Baseline, 1}, T<:Baseline), nt::Union(Array{U<:Noise, 1}, U<:Noise), dt::Union(V<:Event, Array{V<:Event, 1}), dataNoise::Union(W<:Noise, Array{W<:Noise, 1}), Ncomp, Nvar, Nlon, Nlat, Ntime, kb, kn, ks)
This function generates a whole multivariate datacube, the input is as follows. It needs the followings input:
- mt: Baseline or Vector{Baseline}, the process mean for the components
- nt: Noise or Vector{Noise}, the noise chosen for the independent components
- dt: Event or Vector{Event}, the distirbance events for each component
- dataNoise: Noise or Vector{Noise}, the noise added to each variable of the DataCube
- Ncomp: Number of independent components to generate
- Nvar: Number of variables to generate
- Nlon: Number of longitudes
- Nlat: Number of Latitudes
- Ntime: Number of Time steps
- kb: Strength of baseline modulation by event, kb=0 means no modulation, kb=1 means double amplitude, kb=
- kn: Strength of noise modulation by event, kn=0, means no modulation, kn=1 double noise, kn=-1 half noise 
- ks: Strength of mean shift event


**source:**
[SurrogateCube/src/SurrogateCube.jl:68](file:///Users/fgans/.julia/v0.3/SurrogateCube/src/SurrogateCube.jl)

---

#### genDataStream(mt::Baseline, nt::Noise, dt::Event, Nlon, Nlat, Ntime, kb, kn, ks)
Function that generates a single datacube, this can serve as a basis to build an independent component of a dataset. The input is as follows:
- mt: Baseline, the process mean
- nt: Noise, the noise chosen
- dt: Event, the disturbance event
- Nlon: Number of longitudes
- Nlat: Number of Latitudes
- Ntime: Number of Time steps
- kb: Strength of baseline modulation by event, kb=0 means no modulation, kb=1 means double amplitude, kb=
- kn: Strength of noise modulation by event, kn=0, means no modulation, kn=1 double noise, kn=-1 half noise 
- ks: Strength of mean shift event


**source:**
[SurrogateCube/src/SurrogateCube.jl:42](file:///Users/fgans/.julia/v0.3/SurrogateCube/src/SurrogateCube.jl)

---

#### genEvent(d::Event, Nlon, Nlat, Ntime)
This function generates a 3D Array of Nlon, Nlat, Ntime. It should `= 0` for all points that are not affected by an event and `> 0` 
for affected grid cells. In the simplest case the resulting array is binary (either 0 or 1)


**source:**
[SurrogateCube/src/disturbance.jl:12](file:///Users/fgans/.julia/v0.3/SurrogateCube/src/disturbance.jl)

---

#### genNoise(n::Noise, Nlon, Nlat, Ntime)
This function generates a 3D Array of Nlon, Nlat, Ntime

**source:**
[SurrogateCube/src/noise.jl:12](file:///Users/fgans/.julia/v0.3/SurrogateCube/src/noise.jl)

---

#### save_cube(d::DataCube)
This function save a DataCube object `d` generated by genDataCube to a NetCDF file `filename` in the directory `savedir`. The resulting NetCDF will have 3
variables, `datacube`, which is the actual multivariate dataset to be analysed, `components` will store the independent components used
to generate the cube and `events` will contain a map of events that should be detected by the algorithm. All settings will also be written
 as to the NetCDF file as attributes.


**source:**
[SurrogateCube/src/io.jl:8](file:///Users/fgans/.julia/v0.3/SurrogateCube/src/io.jl)

---

#### save_cube(d::DataCube, savedir)
This function save a DataCube object `d` generated by genDataCube to a NetCDF file `filename` in the directory `savedir`. The resulting NetCDF will have 3
variables, `datacube`, which is the actual multivariate dataset to be analysed, `components` will store the independent components used
to generate the cube and `events` will contain a map of events that should be detected by the algorithm. All settings will also be written
 as to the NetCDF file as attributes.


**source:**
[SurrogateCube/src/io.jl:8](file:///Users/fgans/.julia/v0.3/SurrogateCube/src/io.jl)

---

#### save_cube(d::DataCube, savedir, filename)
This function save a DataCube object `d` generated by genDataCube to a NetCDF file `filename` in the directory `savedir`. The resulting NetCDF will have 3
variables, `datacube`, which is the actual multivariate dataset to be analysed, `components` will store the independent components used
to generate the cube and `events` will contain a map of events that should be detected by the algorithm. All settings will also be written
 as to the NetCDF file as attributes.


**source:**
[SurrogateCube/src/io.jl:8](file:///Users/fgans/.julia/v0.3/SurrogateCube/src/io.jl)

---

#### Baseline
Abstract type for the Baseline, each subtype should define the method 
genBaseline(p::Baseline,,Nlon,Nlat,Ntime )


**source:**
[SurrogateCube/src/mean.jl:4](file:///Users/fgans/.julia/v0.3/SurrogateCube/src/mean.jl)

---

#### ConstantBaseline
Most trivial baseline case, constant mean `m` without seasonal cycle


**source:**
[SurrogateCube/src/mean.jl:14](file:///Users/fgans/.julia/v0.3/SurrogateCube/src/mean.jl)

---

#### CubeEvent
simple cubic disturbance of relative size sx,sy,sz (0..1) with the center at px,py,pz (0..1)
The positions and sizes are relative to the cube size


**source:**
[SurrogateCube/src/disturbance.jl:19](file:///Users/fgans/.julia/v0.3/SurrogateCube/src/disturbance.jl)

---

#### EmptyEvent
Type for an empty Disturbance

**source:**
[SurrogateCube/src/disturbance.jl:65](file:///Users/fgans/.julia/v0.3/SurrogateCube/src/disturbance.jl)

---

#### Event
Define abstract type for the distrubance, each subtype should define the method
genEvent(d::Event,Nlon,Nlat,Ntime)


**source:**
[SurrogateCube/src/disturbance.jl:4](file:///Users/fgans/.julia/v0.3/SurrogateCube/src/disturbance.jl)

---

#### LocalEvent
simple local distrubance that covers a single longitude-latitude point (0..1,0..1) over the time span s (0..1) starting at time t (0..1)


**source:**
[SurrogateCube/src/disturbance.jl:46](file:///Users/fgans/.julia/v0.3/SurrogateCube/src/disturbance.jl)

---

#### Noise
Noise is an abstract type representing fluctuations around a baseline of a variable, each subtype should define the following method:

    genNoise(,n::Noise,Nlon,Nlat,Ntime)



**source:**
[SurrogateCube/src/noise.jl:7](file:///Users/fgans/.julia/v0.3/SurrogateCube/src/noise.jl)

---

#### SineBaseline
very simple periodic BaseLine returning a sine oscillation in the time domain, 
where `nOsc` is the number of oscillations and `amp` is the amplitude


**source:**
[SurrogateCube/src/mean.jl:24](file:///Users/fgans/.julia/v0.3/SurrogateCube/src/mean.jl)

---

#### WhiteNoise
The simplest form of noise, White noise with mean 0 and standard deviation `s`


**source:**
[SurrogateCube/src/noise.jl:19](file:///Users/fgans/.julia/v0.3/SurrogateCube/src/noise.jl)

