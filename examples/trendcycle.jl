using SurrogateCube
# Define some Parameters
Ncomp = 3 #We want 3 independent components
Nvar  = 10 # we want 10 measured variables
noise = WhiteNoise(0.1) #Each component has a noise with sigma=0.5
means = [ConstantBaseline(0.0),ConstantBaseline(0.0),SineBaseline(10,1.0)] # One Baseline has a cycle
dists = [EmptyEvent(),EmptyEvent(),TrendEvent(CubeEvent(0.3))] # Only one of the components is disturbed with a size of 20% in each dimension
varNoise = WhiteNoise(0.1) # each variable generated has some independent white noise
kb=1.0  # How strongly do we want to perturb
ks=0.0
kn=0.0
#Set dimensions
Nlon = 5
Nlat = 5
Ntime =300
ds = genDataCube(means,noise,dists,varNoise,Ncomp,Nvar,Ntime,Nlat,Nlon,kb,ks,kn);
#Save the datacube to a file
save_cube(ds)
#Plot something
using PyPlot
pygui(true)
f=figure()
for i=1:Nvar
plot(ds.variables[:,3,3,i][:])
end

f=figure()
for i=1:Ncomp
plot(ds.components[:,3,3,i][:])
end

f=figure()
for i=1:Ncomp
plot(ds.eventmap[:,3,3,i][:])
end




