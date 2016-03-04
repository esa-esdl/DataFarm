module DataFarm
using SurrogateCube

#This defines the main experiment types with disturbances we want to detect
abstract ExperimentType

# This defines the complications that might be added
abstract Complication

#Write genral functions that are applied when not overwritten
#Number of independent components
ncomp(::ExperimentType,::Complication)=3
#Number of variables
nvar(::ExperimentType,::Complication)=10
#Type of noise for components
compnoise(et::ExperimentType,co::Complication)=WhiteNoise(compnoiselevel(et,co))
#Sigma of component noise
compnoiselevel(::ExperimentType,::Complication)=1.0
#Type of variable noise
varnoise(et::ExperimentType,co::Complication)=WhiteNoise(varnoiselevel(et,co))
#Sigma of variable noise
varnoiselevel(::ExperimentType,::Complication)=0.3
#Baseline types for components
bases(et::ExperimentType,co::Complication)=[ConstantBaseline(0.0) for i=1:ncomp(et,co)]
#Event type for components
function event(et::ExperimentType,co::Complication)
  sspat=spatsize(et,co)
  stime=tempsize(et,co)
	n=nevent(et,co)
	CubeEvent(n,fill(sspat,n),fill(sspat,n),fill(stime,n),p[1:n,1],p[1:n,2],p[1:n,3])
end
#Coupling
coupling(et::ExperimentType,co::Complication)=fill(LinearCoupling(),nvar(et,co))
#Weights
weights(et::ExperimentType,co::)=[LaplaceWeight() for i=1:ncomp(et,co)]
#Number of events
nevent(::ExperimentType,::Complication)=10
#Spatial extent of events
spatsize(::ExperimentType,::Complication)=0.4
#Temporal extent of events
tempsize(::ExperimentType,::Complication)=5/300
#Disturbances to apply
dists(::ExperimentType,::Complication)=error("You have to define a disturbance!")
#Strength to baseline modification
kb(::ExperimentType,::Complication)=0.0
#Strength of Component noise variantion
kn(::ExperimentType,::Complication)=0.0
#Strength of shift parameter
ks(::ExperimentType,::Complication)=0.0
#Noae of the experiment
expName(et::ExperimentType,co::Complication)=string(string(et)[1:end-2],"_",string(co)[1:end-2])
#Should this combination be skipped?
skipthis(::ExperimentType,::Complication)=false
#coupling
coup(::ExperimentType,::Complication)=LinearCoupling()

#Define macro that excludes combinations Experiments and complications
macro exclude_combi(et,co,fun)
	esc(:($(fun)(ext::$(et),com::$(co))=error(string("Combination of ",$(et), " and ",$(co)," not possible"));skipthis(ext::$(et),com::$(co))=true))
end

#Here come the special functions that overload the abstract ones defined above
immutable BaseShift <: ExperimentType end
dists(et::BaseShift,co::Complication)=[i==1 ? event(et,co) : EmptyEvent() for i=1:ncomp(et,co)]
ks(::BaseShift,::Complication)=Float64[0.2:0.2:4]

#This generates Extremes that start slowly and end abruptly
immutable TrendJump <: ExperimentType end
event(et::TrendJump,co::Complication)=TrendEvent(event(BaseShift(),co),false)
dists(et::TrendJump,co::Complication)=[i==1 ? event(et,co) : EmptyEvent() for i=1:ncomp(et,co)]
ks(::TrendJump,::Complication)=Float64[0.2:0.2:4]

#Generates extremes with a Trend onset in the middle of the time series
immutable Trend <: ExperimentType end
event(et::Trend,co::Complication)=TrendEvent(OnsetEvent(spatsize(et,co),spatsize(et,co),0.5,0.5,0.5),true)
dists(et::Trend,co::Complication)=[i==1 ? event(et,co) : EmptyEvent() for i=1:ncomp(et,co)]
ks(::Trend,::Complication)=Float64[0.2:0.2:4]

#Generates extremes with shifts in variances
immutable VarianceShift <: ExperimentType end
dists(et::VarianceShift,co::Complication)=[i==1 ? event(et,co) : EmptyEvent() for i=1:ncomp(et,co)]
kn(::VarianceShift,::Complication)=Float64[-2:0.2:-0.2;0.2:0.2:2]

#Generates extremes where AMplitude of the MAC is increased or decreased
immutable MACShift <: ExperimentType end
bases(et::MACShift,co::Complication)=[i==1 ? SineBaseline(300/46,5.0) : ConstantBaseline(0.0) for i=1:ncomp(et,co)]
dists(et::MACShift,co::Complication)=[i==1 ? event(et,co) : EmptyEvent() for i=1:ncomp(et,co)]
tempsize(et::MACShift,co::Complication)=92/300
kb(::MACShift,::Complication)=Float64[-2:0.2:-0.2;0.2:0.2:2]

#Generates events in which the coupling between variables in shifted
immutable DepShift <: ExperimentType end
kw(::DepShift,::Complication)=Float64[0.2:0.2:1]

# These are the function overrides for the variouse complications we can add
#Increase the variable noise
immutable NoiseIncrease <: Complication end
varnoise(::ExperimentType,::NoiseIncrease)=WhiteNoise(1.0)

#Add a seasonal cycle to the data
immutable SeasonalCycle <: Complication end
@exclude_combi MACShift SeasonalCycle bases
bases(::ExperimentType,::SeasonalCycle)=[SineBaseline(300/46,5.0),ConstantBaseline(0.0),ConstantBaseline(0.0)]

#Make component noise Cauchy-distributed, very long-tailed
immutable NonGaussianNoise <: Complication end
compnoise(et::ExperimentType,co::NonGaussianNoise)=CauchyNoise(compnoiselevel(et,co),1.0)

#Make noise correlated
immutable CorrelatedNoise <: Complication end
compnoise(et::ExperimentType,co::CorrelatedNoise)=RedNoise(compnoiselevel(et,co),1.0,1.0,1.0)

immutable RandomWalkExtreme <: Complication end
@exclude_combi Trend RandomWalkExtreme event
@exclude_combi TrendJump RandomWalkExtreme event
event(et::ExperimentType,co::RandomWalkExtreme)=RandomWalkEvent(nevent(et,co),spatsize(et,co),spatsize(et,co),tempsize(et,co))
compnoise(et::ExperimentType,co::RandomWalkExtreme)=RedNoise(compnoiselevel(et,co),1.0,1.0,0.0)

immutable MoreIndepComponents <: Complication end
ncomp(::ExperimentType,::MoreIndepComponents)=6

immutable NoComplication <: Complication end

immutable ShortExtremes <: Complication end
skipthis(::Trend,::ShortExtremes)=true
nevent(::ExperimentType,::ShortExtremes)=50
nevent(::MACShift,::ShortExtremes)=4
tempsize(::MACShift,::ShortExtremes)=46/300
tempsize(::ExperimentType,::ShortExtremes)=1/300

immutable LongExtremes <: Complication end
skipthis(::Trend,::LongExtremes)=true
nevent(::ExperimentType,::LongExtremes)=5
tempsize(::MACShift,::LongExtremes)=184/300
tempsize(::ExperimentType,::LongExtremes)=10/300

immutable NonLinearDep <: Complication end
coup(::ExperimentType,::NonLinearDep)=QuadraticCoupling()

immutable LatitudeGradient <: Complication end
bases(et::MACShift,co::LatitudeGradient)=[i==1 ? SineBaseline(300/46,5.0) : i==2 ? TrendBaseline(0.0,0.0,1.0) : ConstantBaseline(0.0) for i=1:ncomp(et,co)]
bases(et::ExperimentType,co::LatitudeGradient)=[i==2 ? TrendBaseline(0.0,0.0,1.0) : ConstantBaseline(0.0) for i=1:ncomp(et,co)]

#This function will generate the whole test datafarm
function myExperiment(et::ExperimentType,co::Complication,p,Ntime,Nlat,Nlon,path)
	# Simple shift in the data, the extent is 20% of all dimensions
	Ncomp = ncomp(et,co) #We want 3 independent components
	Nvar  = nvar(et,co) # we want 10 measured variables
	noise = compnoise(et,co) #Each component has a noise with sigma=0.5
	means = bases(et,co) # All Baselines are flat
	distus = dists(et,co) # Only one of the components is disturbed with a size of 20% in each dimension
	varNoise = varnoise(et,co) # each variable generated has some independent white noise
	kbs,kns,kss,kws=(kb(et,co),kn(et,co),ks(et,co),kw(et,co))  # How strongly do we want to perturb
  coup   = coupling(et,co) # Get the couplings
  we     = weights(et,co)  #get Weights
	#Set dimensions
	ds = genDataCube(means,noise,distus,varNoise,coup,we,Ncomp,Nvar,Ntime,Nlat,Nlon,kbs,kns,kss,kws,expName(et,co),path);
end


function makeDataFarm(Ntime,Nlon,Nlat,path)
	# First sedd the RNG
	srand(uint(19021983))
	#Get positions of extremes
	p=getValidPlaces(Ntime,Nlon,Nlat)
	#Now generate data
	for expi in [BaseShift, TrendJump, Trend, VarianceShift, MACShift]
		for compli in [NoiseIncrease, SeasonalCycle, NonGaussianNoise, CorrelatedNoise, RandomWalkExtreme, MoreIndepComponents, ShortExtremes, LongExtremes, NonLinearDep, LatitudeGradient]
			println(expName(expi(),compli()))
			skipthis(expi(),compli()) || myExperiment(expi(),compli(),p,Ntime,Nlon,Nlat,path)
		end
	end
end

function randomEventPlaces!(nEvent)
    rand!(p)
    for i=1:nEvent
        p[i,1]= p[i,1] > 0.5 ? 0.75:0.25
        p[i,2]= p[i,2] > 0.5 ? 0.75:0.25
    end
    p
end

const p=zeros(50,3)

function getValidPlaces(Ntime,Nlon,Nlat)
	expi=BaseShift()
  complis=[NoComplication(),ShortExtremes(),LongExtremes()]
  found=false
  ii=2
  while !found
    randomEventPlaces!(nevent(BaseShift(),ShortExtremes()));
    found=true
    for ii=1:length(complis)
      n=DataFarm.nevent(expi,complis[ii])
      sx=fill(spatsize(expi,complis[ii]),n)
      sy=fill(spatsize(expi,complis[ii]),n)
      sz=fill(tempsize(expi,complis[ii]),n)
      px=p[1:n,1]
      py=p[1:n,2]
      pz=p[1:n,3]
      ev=CubeEvent(n,sx,sy,sz,px,py,pz)
      x=genEvent(ev,Ntime,Nlat,Nlon)
      if sum(x.>1)>0
        found=false
      end
    end
  end
	p
end

end
