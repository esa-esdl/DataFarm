using Distributions
#This file contains the definition of the type VariableWeight, representing different
#style of weights that you can create
abstract VariableWeight
export VariableWeight
getWeight(w::VariableWeight,icomp::Integer)=error("getWeight method not defined for $(typeof(w))")

immutable LaplaceWeight
  w::Vector{Float64}
end
export LaplaceWeight
function LaplaceWeight(Ncomp)
  w = rand(Laplace(),Ncomp)
  scale!(w,inv(sqrt(sumabs2(w))))
  LaplaceWeight(w)
end
getWeight(w::LaplaceWeight,icomp::Integer,kw,d)=w.w[icomp]


"""
Type to represent a weight vector where the weights can shift during an event. the
field w contains the normal events and the field wd contains the disturbed events.
"""
immutable DisturbedLaplaceWeight
  w::Vector{Float64}
  wd::Vector{Float64}
end
export DisturbedLaplaceWeight
function DisturbedLaplaceWeight(Ncomp)
    w = rand(Laplace(),Ncomp)
    wd = rand(Laplace(),Ncomp)
    scale!(w,inv(sqrt(sumabs2(w))))
    #Make sure disturbance is orthogonal to original w
    wdort = wd - dot(wd,w)*w
    scale!(wdort,inv(sqrt(sumabs2(wdort))))
    DisturbedLaplaceWeight(w,wdort)
end
getWeight(w::DisturbedLaplaceWeight,icomp::Integer,kw,d)= d>0.0 ? kw * w.wd[icomp] + (1.0-kw) * w.w[icomp] : w.w[icomp]
