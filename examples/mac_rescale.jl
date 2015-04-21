using SurrogateCube
# Define some Parameters
Ncomp = 3 #We want 3 independent components
Nvar  = 5 # we want 10 measured variables
noise = WhiteNoise(0.2) #Each component has a noise with sigma=0.5
means = [ConstantBaseline(0.0),ConstantBaseline(0.0),SineBaseline(5,2.0)] # One of the Conmponents has a seasonal cycle
dists = [EmptyEvent(),EmptyEvent(),CubeEvent(0.2)] # Only one of the components is disturbed with a size of 20% in each dimension
varNoise = WhiteNoise(0.1) # each variable generated has some independent white noise
kb=-1  # We increase the amplitude of the MAC by a factor of 2 
kn=0.0  # No disturbance in the variance
ks=0.0  # No disturbance in the mean
#Set dimensions
Nlon = 10
Nlat = 10
Ntime =100
ds = genDataCube(means,noise,dists,varNoise,Ncomp,Nvar,Nlon,Nlat,Ntime,kb,kn,ks);
#Save the datacube to a file
save_cube(ds)
#Plot something
using PyPlot
pygui(true)
f=figure()
#plot(int(d[1,5,5,:][:]))
for i=1:Nvar
plot(ds.variables[i,5,5,:][:])
end


