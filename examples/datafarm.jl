using SurrogateCube
#This function will generate the whole test datafarm
function simpleshift(Ntime,Nlat,Nlon,path)
	# Simple shift in the data, the extent is 20% of all dimensions
	Ncomp = 3 #We want 3 independent components
	Nvar  = 10 # we want 10 measured variables
	noise = WhiteNoise(0.2) #Each component has a noise with sigma=0.5
	means = [ConstantBaseline(0.0),ConstantBaseline(0.0),ConstantBaseline(0.0)] # All Baselines are flat
	dists = [CubeEvent(0.2),EmptyEvent(),EmptyEvent()] # Only one of the components is disturbed with a size of 20% in each dimension
	varNoise = WhiteNoise(0.1) # each variable generated has some independent white noise
	kb,kn,ks=(0.0,0.0,Float64[-10:-1,1:10])  # How strongly do we want to perturb
	#Set dimensions
	ds = genDataCube(means,noise,dists,varNoise,Ncomp,Nvar,Ntime,Nlat,Nlon,kb,kn,ks,"SimpleShift",path);
end

function trendonset(Ntime,Nlat,Nlon,path)
	# Simple shift in the data, the extent is 20% of all dimensions
	Ncomp = 3
	Nvar  = 10
	noise = WhiteNoise(0.2) #Each component has a noise with sigma=0.5
	means = [ConstantBaseline(0.0),ConstantBaseline(0.0),ConstantBaseline(0.0)] # All Baselines are flat
	dists = [TrendEvent(OnsetEvent(0.2,0.2,0.5,0.5,0.5)),EmptyEvent(),EmptyEvent()] # Only one of the components is disturbed with a size of 20% in each dimension
	varNoise = WhiteNoise(0.1) # each variable generated has some independent white noise
	kb,kn,ks=(0.0,0.0,Float64[-10:-1,1:10])  # How strongly do we want to perturb
	#Set dimensions
	ds = genDataCube(means,noise,dists,varNoise,Ncomp,Nvar,Ntime,Nlat,Nlon,kb,kn,ks,"TrendOnset",path);
end

function varianceshift(Ntime,Nlon,Nlat,path)
	# Shift in the variance of a white noise dataset
	Ncomp = 3 #We want 3 independent components
	Nvar  = 10 # we want 10 measured variables
	noise = WhiteNoise(0.2) #Each component has a noise with sigma=0.5
	means = [ConstantBaseline(0.0),ConstantBaseline(0.0),ConstantBaseline(0.0)] # All Baselines are flat
	dists = [CubeEvent(0.2),EmptyEvent(),EmptyEvent()] # Only one of the components is disturbed with a size of 20% in each dimension
	varNoise = WhiteNoise(0.1) # each variable generated has some independent white noise
	kb,kn,ks=(0.0,Float64[-2:0.2:-0.2,0.2:0.2:2],0.0)  # How strongly do we want to perturb
	#Set dimensions
	ds = genDataCube(means,noise,dists,varNoise,Ncomp,Nvar,Ntime,Nlat,Nlon,kb,kn,ks,"VarianceShift",path);
end

function macchange(Ntime,Nlon,Nlat,path)
	# Change in amplitude of MAC, 2 years in the center are disturbed
	Ncomp = 3 #We want 3 independent components
	Nvar  = 10 # we want 10 measured variables
	noise = WhiteNoise(0.2) #Each component has a noise with sigma=0.5
	means = [SineBaseline(10,2.0),ConstantBaseline(0.0),ConstantBaseline(0.0)] # All Baselines are flat
	dists = [CubeEvent(0.2),EmptyEvent(),EmptyEvent()] # Only one of the components is disturbed with a size of 20% in each dimension
	varNoise = WhiteNoise(0.1) # each variable generated has some independent white noise
	kb,kn,ks=(Float64[-2:0.2:-0.2,0.2:0.2:2],0.0,0.0)  # How strongly do we want to perturb
	#Set dimensions
	ds = genDataCube(means,noise,dists,varNoise,Ncomp,Nvar,Ntime,Nlat,Nlon,kb,kn,ks,"MACchange",path);
end

function makeDataFarm(Ntime,Nlon,Nlat,path)
	simpleshift(Ntime,Nlon,Nlat,path)
	trendonset(Ntime,Nlon,Nlat,path)
	varianceshift(Ntime,Nlon,Nlat,path)
	macchange(Ntime,Nlon,Nlat,path)
end