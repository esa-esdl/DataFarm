
@doc """
Noise is an abstract type representing fluctuations around a baseline of a variable, each subtype should define the following method:

    genNoise(,n::Noise,Nlon,Nlat,Ntime)

"""->
abstract Noise
export Noise


@doc "This function generates a 3D Array of Nlon, Nlat, Ntime"->
genNoise(n::Noise,Nlon,Nlat,Ntime)=error("Method genNoise not implemented for type $(typeof(n)).")
export genNoise


@doc """
The simplest form of noise, White noise with mean 0 and standard deviation `s`
"""->
# White Noise, everything is uncorrelated
type WhiteNoise <: Noise
    s::Float64
end
export WhiteNoise
genNoise(n::WhiteNoise,Nlon,Nlat,Ntime)=reshape(rand(Normal(0.0,n.s),Nlon*Nlat*Ntime),Nlon,Nlat,Ntime)

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
function genNoise(n::RedNoise,Nlon,Nlat,Ntime)
	wn1=reshape(rand(Normal(0.0,n.s),Nlon*Nlat*Ntime),Nlon,Nlat,Ntime)
	wn=fft(wn1)
	for itime=1:Ntime
		ftime=itime > (Ntime+1)/2 ? Ntime+1-itime : itime-1
		ftime=max(ftime,1.0)
		for ilat=1:Nlat
			flat=ilat > (Nlat+1)/2 ? Nlat+1-ilat : ilat-1
			flat=max(flat,1.0)
			for ilon=1:Nlon
				flon=ilon > (Nlon+1)/2 ? Nlon+1-ilon : ilon-1
				flon=max(flon,1.0)
				wn[ilon,ilat,itime]=wn[ilon,ilat,itime]/ftime^n.btime/flon^n.blon/flat^n.blat
			end
		end
	end
	fft!(wn)
	for k=1:Ntime, j=1:Nlat, i=1:Nlon
		wn1[i,j,k]=real(wn[i,j,k])
	end
	scale!(wn1,n.s/std(wn1))
end

