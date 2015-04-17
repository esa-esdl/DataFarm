import NetCDF
import NetCDF: NcDim,NcVar
# FUnction to save the 
function save_cube(d::DataCube, savedir = joinpath(Pkg.dir(),"SurrogateCube","data"),filename="")
	# Test if output directory exists
	isdir(savedir) || mkdir(savedir)
	# Generate new file name if none is given
	if filename==""
		i=1
		while isfile(joinpath(savedir,"file$(i).nc"))
			i=i+1
		end
		filename = "file$(i).nc"
	else 
		isfile(joinpath(savedir,filename)) && rm(joinpath(savedir,filename))
	end
	fullname=joinpath(savedir,filename)
	# Now create essential variables
	Nvar,Nlon,Nlat,Ntime = size(d.variables)
	Ncomp = size(d.components,2)

	#Create variables
	#First define variable attributes
	varatts = Dict()
	compatts= Dict()
	objectToAtt(varatts,d.varnoise,"VarNoise")
	objectToAtt(compatts,d.compnoise,"CompNoise")
	objectToAtt(compatts,d.baselines,"Baseline")
	objectToAtt(compatts,d.events,"Event")
	
	dvar = NcDim("variable", Nvar)
	dcomp= NcDim("component", Ncomp)
	dlon = NcDim("longitude", Nlon)
	dlat = NcDim("latitude", Nlat)
	dtim = NcDim("time", Ntime)
	
	vcube = NcVar("datacube",[dvar,dlon,dlat,dtim],atts=varatts)
	vcomp = NcVar("components",[dcomp,dlon,dlat,dtim],atts=compatts)
	veven = NcVar("events",[dcomp,dlon,dlat,dtim])

	nc = NetCDF.create(fullname,[vcube,vcomp,veven])

	NetCDF.putvar(nc,"datacube",d.variables)
	NetCDF.putvar(nc,"components",d.components)
	NetCDF.putvar(nc,"events",d.eventmap)

	NetCDF.close(nc)
end
export save_cube

function objectToAtt(atts::Dict,t,prestring)

	T=string(typeof(t))
	n=names(t)
	atts[prestring]=T
	for i=1:length(n)
		atts[@sprintf("%s_%s",prestring,string(n[i]))]=t.(n[i])
	end
end

function objectToAtt(atts::Dict,t::Vector,prestring)

	for i=1:length(t)
		objectToAtt(atts,t[i],@sprintf("%s_%d",prestring,i))
	end
end