using SurrogateCube
# Define some Parameters
Ncomp = 3 #We want 3 independent components
Nvar  = 10 # we want 10 measured variables
noise = WhiteNoise(0.2) #Each component has a noise with sigma=0.5
means = [ConstantBaseline(0.0),ConstantBaseline(0.0),SineBaseline(2,2.0)] # One of the Conmponents has a seasonal cycle
dists = [EmptyEvent(),EmptyEvent(),CubeEvent(0.5)] # Only one of the components is disturbed with a size of 20% in each dimension
varNoise = WhiteNoise(0.1) # each variable generated has some independent white noise
k1= 1.0  # We increase the amplitude of the MAC by a factor of 2 
k2=0.0  # No disturbance in the variance
k3=0.0  # No disturbance in the mean
#Set dimensions
Nlon = 10
Nlat = 10
Ntime =100
ds = genDataCube(means,noise,dists,varNoise,Ncomp,Nvar,Nlon,Nlat,Ntime,k1,k2,k3);
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


