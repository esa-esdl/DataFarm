
@doc """
Noise is an abstract type representing fluctuations around a baseline of a variable, each subtype should define the following method:

    genNoise(,n::Noise,Nlon,Nlat,Ntime)

"""->
abstract Noise
export Noise


@doc "This function generates a 3D Array of Nlon, Nlat, Ntime"->
genNoise(n::Noise,Ntime,Nlat,Nlon)=error("Method genNoise not implemented for type $(typeof(n)).")
export genNoise


@doc """
The simplest form of noise, White noise with mean 0 and standard deviation `s`
"""->
# White Noise, everything is uncorrelated
type WhiteNoise <: Noise
    s::Float64
end
export WhiteNoise
genNoise(n::WhiteNoise,Ntime,Nlat,Nlon)=reshape(rand(Normal(0.0,n.s),Nlon*Nlat*Ntime),Ntime,Nlat,Nlon)

@doc """
Cauchy-distributed random numbers as an example for a heavily long-tailed distribution, s is the final standard deviation and b the beta parameter
"""->
# White Noise, everything is uncorrelated
type CauchyNoise <: Noise
    s::Float64
    b::Float64
end
export CauchyNoise
function genNoise(n::CauchyNoise,Ntime,Nlat,Nlon)
	x=reshape(rand(Cauchy(0.0,n.b),Nlon*Nlat*Ntime),Ntime,Nlat,Nlon)
	scale!(x,n.s/std(x))
end


@doc """
Generate 1/f^beta noise with blon, blat, btime the scaling factors in each dimension
"""->
type RedNoise <: Noise
	s::Float64
	blon::Float64
	blat::Float64
	btime::Float64
end
export RedNoise
function genNoise(n::RedNoise,Ntime,Nlat,Nlon)
	wn1=reshape(rand(Normal(0.0,n.s),Nlon*Nlat*Ntime),Ntime,Nlat,Nlon)
	wn=fft(wn1)
	for ilon=1:Nlon
		flon=ilon > (Nlon+1)/2 ? Nlon+1-ilon : ilon-1
		flon=max(flon,1.0)
		for ilat=1:Nlat
			flat=ilat > (Nlat+1)/2 ? Nlat+1-ilat : ilat-1
			flat=max(flat,1.0)
			for itime=1:Ntime
				ftime=itime > (Ntime+1)/2 ? Ntime+1-itime : itime-1
				ftime=max(ftime,1.0)
				wn[itime,ilat,ilon]=wn[itime,ilat,ilon]/ftime^n.btime/flon^n.blon/flat^n.blat
			end
		end
	end
	fft!(wn)
	for k=1:Nlon, j=1:Nlat, i=1:Ntime
		wn1[i,j,k]=real(wn[i,j,k])
	end
	scale!(wn1,n.s/std(wn1))
end

