module DataFarm
using SurrogateCube

#This defines the main experiment types with disturbances we want to detect
abstract ExperimentType

# This defines the complications that might be added 
abstract Complication

#Write genral functions that are applied when not overwritten
ncomp(::ExperimentType,::Complication)=3
nvar(::ExperimentType,::Complication)=10
compnoise(::ExperimentType,::Complication)=WhiteNoise(0.3)
varnoise(::ExperimentType,::Complication)=WhiteNoise(0.1)
bases(et::ExperimentType,co::Complication)=[ConstantBaseline(0.0) for i=1:ncomp(et,co)]
event(::ExperimentType,::Complication)=CubeEvent(2,0.2,0.2,5/300)
dists(::ExperimentType,::Complication)=error("You have to define a disturbance!")
kb(::ExperimentType,::Complication)=0.0
kn(::ExperimentType,::Complication)=0.0
ks(::ExperimentType,::Complication)=0.0
expName(et::ExperimentType,co::Complication)=string(string(et)[1:end-2],string(co)[1:end-2])
skipthis(::ExperimentType,::Complication)=false

#Here come the special functions that overload the abstract ones defined above
immutable BaseShift <: ExperimentType end
dists(et::BaseShift,co::Complication)=[i==1 ? event(et,co) : EmptyEvent() for i=1:ncomp(et,co)]
ks(::BaseShift,::Complication)=Float64[0.2:0.2:5]

immutable Trend <: ExperimentType end
event(::Trend,::Complication)=TrendEvent(OnsetEvent(0.2,0.2,0.5,0.5,0.5))
dists(et::Trend,co::Complication)=[i==1 ? event(et,co) : EmptyEvent() for i=1:ncomp(et,co)]
ks(::Trend,::Complication)=Float64[0.2:0.2:5]

immutable VarianceShift <: ExperimentType end
dists(et::VarianceShift,co::Complication)=[i==1 ? event(et,co) : EmptyEvent() for i=1:ncomp(et,co)]
kn(::VarianceShift,::Complication)=Float64[-2:0.2:-0.2,0.2:0.2:2]

immutable MACShift <: ExperimentType end
bases(et::MACShift,co::Complication)=[i==1 ? SineBaseline(10,2.0) : ConstantBaseline(0.0) for i=1:ncomp(et,co)]
dists(et::MACShift,co::Complication)=[i==1 ? event(et,co) : EmptyEvent() for i=1:ncomp(et,co)]
kb(::MACShift,::Complication)=Float64[-2:0.2:-0.2,0.2:0.2:2]

immutable NoiseIncrease <: Complication end
varnoise(::ExperimentType,::NoiseIncrease)=WhiteNoise(0.3)

immutable SeasonalCycle <: Complication end
bases(::MACShift,::SeasonalCycle)=error("This combination does not make sense!")
bases(::ExperimentType,::SeasonalCycle)=[SineBaseline(10,2.0),ConstantBaseline(0.0),ConstantBaseline(0.0)]
skipthis(::MACShift,::SeasonalCycle)=true

immutable NonGaussianNoise <: Complication end
compnoise(::ExperimentType,::NonGaussianNoise)=CauchyNoise(0.3,1.0)

immutable CorrelatedNoise <: Complication end
compnoise(::ExperimentType,::CorrelatedNoise)=RedNoise(0.3,1.0,1.0,1.0)

immutable RandomWalkExtreme <: Complication end
event(::Trend,::RandomWalkExtreme)=error("This combination is not possible")
event(::ExperimentType,::RandomWalkExtreme)=RandomWalkEvent(2,0.2,0.2,5/300)
skipthis(::Trend,::RandomWalkExtreme)=true

immutable TrendJumpExtreme <: Complication end


immutable MoreIndepComponents <: Complication end
ncomp(::ExperimentType,::MoreIndepComponents)=6

immutable NoComplication <: Complication end

immutable ShortExtremes <: Complication end
event(::Trend,::ShortExtremes)=error("This combination is not possible")
event(::ExperimentType,::ShortExtremes)=CubeEvent(10,0.2,0.2,1/300)
skipthis(::Trend,::ShortExtremes)=true

immutable LongExtremes <: Complication end
event(::Trend,::LongExtremes)=error("This combination is not possible")
event(::ExperimentType,::LongExtremes)=CubeEvent(1,0.2,0.2,10/300)
skipthis(::Trend,::LongExtremes)=true



#This function will generate the whole test datafarm
function myExperiment(et::ExperimentType,co::Complication,Ntime,Nlat,Nlon,path)
	# Simple shift in the data, the extent is 20% of all dimensions
	Ncomp = ncomp(et,co) #We want 3 independent components
	Nvar  = nvar(et,co) # we want 10 measured variables
	noise = compnoise(et,co) #Each component has a noise with sigma=0.5
	means = bases(et,co) # All Baselines are flat
	dists = dists(et,co) # Only one of the components is disturbed with a size of 20% in each dimension
	varNoise = varnoise(et,co) # each variable generated has some independent white noise
	kb,kn,ks=(kb(et,co),kn(et,co),ks(et,co))  # How strongly do we want to perturb
	#Set dimensions
	ds = genDataCube(means,noise,dists,varNoise,Ncomp,Nvar,Ntime,Nlat,Nlon,kb,kn,ks,expName(et,co),path);
end


function makeDataFarm(Ntime,Nlon,Nlat,path)
	# First sedd the RNG
	srand(uint(19021983))
	#Now generate data
	myExperiment(BaseShift(),NoComplication(),Ntime,Nlon,Nlat,path)
	myExperiment(Trend(),NoComplication(),Ntime,Nlon,Nlat,path)
	myExperiment(VarianceShift(),NoComplication(),Ntime,Nlon,Nlat,path)
	myExperiment(MACShift(),NoComplication(),Ntime,Nlon,Nlat,path)
end
end