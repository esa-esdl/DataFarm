using SurrogateCube
# Define some Parameters
Ncomp = 3 #We want 3 independent components
Nvar  = 10 # we want 10 measured variables
noise = WhiteNoise(0.2) #Each component has a noise with sigma=0.5
means = [ConstantMean(0.0),ConstantMean(0.0),PeriodicSineMean(2,2.0)] # One of the Conmponents has a seasonal cycle
dists = [CubeDisturbance(0.2),EmptyDisturbance(),EmptyDisturbance()] # Only one of the components is disturbed with a size of 20% in each dimension
varNoise = WhiteNoise(0.1) # each variable generated has some independent white noise
k=10.0  # How strongly do we want to perturb
#Set dimensions
Nlon = 10
Nlat = 10
Ntime =100
x, a, d = genDataset(means,noise,dists,varNoise,Ncomp,Nvar,Nlon,Nlat,Ntime,k);
using PyPlot
pygui(true)
figure()
#plot(int(d[1,5,5,:][:]))
for i=1:Nvar
plot(x[i,5,5,:][:])
end



