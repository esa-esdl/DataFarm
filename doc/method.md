# Description of the main method to generate extremes

A BAST index should be invariant with respect to common properties of satellite data, not to raise false alarm. These common properties are namely


- different noise classes (e.g. white, red, pink noise) 
- periodic patterns (annual cycle)
- different overlapping periodicities
- trend
- missing values and/or structures induced by gap filling 
- chaotic behavior



To ensure, that BAST indices are able to deal with the common properties of satellite data and fulfill the above mentioned requirements,
a test data farm will be created, following an approach of \citet{Guh:2008dw}. 

$$
X_t = \mu_t + n_t + M_t
$$
with $mu$: the process mean vector, which can be static, periodic, or follow any function or model (e.g. roessler system), $n_t$: the common cause variation following some distribution (e.g. normal, ...),
$M_t = u_t \cdot k \sigma$ with $u_t$ being one if there is a shift in time, zero otherwise, $k$ being some factor, $\sigma$ being the standard deviation of $n_t$.

Three different variables will be created for each virtual location, another four being linear or multiplicative combinations of these core variables. Each test data set will include at least one example  of the above mentioned requirements, thus the test data farm is able to quantify the ability of the different BAST construction possibilities to deal with the requirements and problems of the data.

how to induce some spatial correlations?