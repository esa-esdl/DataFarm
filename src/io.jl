# FUnction to save the 
function save_cube(d::Dataset, savedir = joinpath(Pkg.dir(),"SurrogateCube","data"),filename="")
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
		isfile(joinpath(savepath,filename)) && rm(joinpath(savepath,filename))
	end
	fullname=joinpath(savepath,filename)
	# Now create essential variables
	Nvar,Nlon,Nlat,Ntime = size(d.variables)
	Ncomp = size(d.components,2)


