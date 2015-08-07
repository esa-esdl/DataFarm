#General
This is the general description of the DataFarm, as of version v2. The datafarm is generated to test novelty/event detection methods for their performance. Hence a variety of artificial datacubes is generated and events at certain time steps are inserted. A resulting datacube is a 4-dimensional array of dimensions time-lat-lon-variable. For details on the generation methodology, check out doc.md. Here the single experiments are described in detail. 

Every experiment is a combination of a disturbance, i.e. the event that we want to detect and possibly an additional complication which might make the detection of the disturbance harder for certain algorithms (e.g. the presence of a seasonal cycle or correlated noise). Every experiment/complication combination is stored in a separate folder containing the name of both.

#Standard settings

Here the standard settings for the undisturbed data cube are listed. Each disturbance or complication will modify a part of these standard settings in some way. These modifications are listed in the next section.

- Number of independent components `ncomp=3
- Number of variables `nvar=10`
- Type of noise for components `compnoise=WhiteNoise(compnoiselevel(et,co))` - white noise by default
- Sigma of component noise `compnoiselevel=1.0`
- Type of variable noise `varnoise=WhiteNoise(varnoiselevel(et,co))
- Sigma of variable noise `varnoiselevel=0.3`
- Baseline types for components `bases=[ConstantBaseline(0.0) for i=1:ncomp(et,co)]` by default constant baselines are chosen
- Event type for components `event=CubeEvent(nevent(et,co),spatsize(et,co),spatsize(et,co),tempsize(et,co))`by default a cubic event is generated
- Number of events `nevent=2`
- Spatial extent of events `spatsize=0.2` Events size is 20% along each spatial axis
- Temporal extent of events `tempsize=5/300` events are 5 time steps long
- Strength to baseline modification `kb=0.0`
- Strength of Component noise variantion `kn=0.0`
- Strength of shift parameter `ks=0.0`

# Setting modifications by experiment types

## BaseShift
A simple sudden shift in the baseline
- `ks=Float64[0.2:0.2:5]`

## TrendJump
This generates extremes that increase linearly by intensity and then end abruptly, think of a dry period, where soil moisture gets lower and lower and then goes quickly back to normal state after a rain event
- `event=TrendEvent(event(BaseShift(),co),false)`
- `ks=Float64[0.2:0.2:5]`

## Trend
Generates a Trend onset in the middle of the time series which will persist until the end of the datacube
- event(et::Trend,co::Complication)=TrendEvent(OnsetEvent(spatsize(et,co),spatsize(et,co),0.5,0.5,0.5),true)
- `ks=Float64[0.2:0.2:5]`

## VarianceShift
Generates shifts in variances over a given event
- `kn=Float64[-2:0.2:-0.2,0.2:0.2:2]`

## MACShift
Generates extremes where Amplitude of the MAC is increased or decreased
- introduces a seasonal cycle `bases=[i==1 ? SineBaseline(300/46,5.0) : ConstantBaseline(0.0) for i=1:ncomp(et,co)]`
- makes the event 2 years long `tempsize(et::MACShift,co::Complication)=92/300`
- `kb=Float64[-2:0.2:-0.2,0.2:0.2:2]`


# Complications
In addition to the events that the algorithm is supposed to detect, it is possible to change properties of the datacube which makes the events harder to detect. Here follows a list of these modifications:

## NoiseIncrease
Increase the variabke signal-to noise ratio to 1/1 (from 10/3) 
- varnoise=WhiteNoise(1.0)

## SeasonalCycle
Adds a seasonal cycle to the data
- ´bases=[SineBaseline(300/46,5.0),ConstantBaseline(0.0),ConstantBaseline(0.0)]`

## NonGaussianNoise
Make component noise Cauchy-distributed, very long-tailed
- `compnoise=CauchyNoise(compnoiselevel(et,co),1.0)`

##CorrelatedNoise
Make noise long-term correlated with a 1/f noise and `beta=1.0` in time and space
- `compnoise=RedNoise(compnoiselevel(et,co),1.0,1.0,1.0)`

## RandomWalkExtreme
Change the shape of the extreme to resemble a random walk in 3D
- `event=RandomWalkEvent(nevent(et,co),spatsize(et,co),spatsize(et,co),tempsize(et,co))`

## MoreIndepComponents
Raise number of intrinsic dimensions to 6
- `ncomp=6`

## NoComplication
Standard case

## ShortExtremes
Change the length of the extremes to 1 time step only but generate 10 extremes in exchange. For `MACShift` expriments the duration is reduced to 1 year
- ´nevent(::ExperimentType,::ShortExtremes)=10´
- ´nevent(::MACShift,::ShortExtremes)=4´
- ´tempsize(::MACShift,::ShortExtremes)=46/300´
- ´tempsize(::ExperimentType,::ShortExtremes)=1/300´

## LongExtremes
Change the length of the extremes to 10 time steps but generate 1 extreme in exchange. For `MACShift` expriments the duration is increased to 4 years
- ´nevent(::ExperimentType,::ShortExtremes)=1´
- ´tempsize(::MACShift,::ShortExtremes)=104/300´
- ´tempsize(::ExperimentType,::ShortExtremes)=10/300´

