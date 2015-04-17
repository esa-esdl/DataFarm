In the following we briefly list thee key requirements that the BAST indices should fulfill: 
 
1. Computable from different sets of variables, where each set may contain both discrete and realvalued variables as well as variables that only cover a certain range of values.

2. Computable locally or regionally with respect to both time and spatial position.

3. Robustly detecting temporal outliers, where one or more dimensions in the data stream are extreme – but where we can certainly exclude effects of measurement noise. From this approach we follow that we need the following criteria:

4. Invariance to noise classes (even if moderate autocorrelations affect the data). The crucial challenge is differentiating between noise and extremes, i.e. we have to avoid detecting noisy measurements and have high credibility in the existence of real extreme values.

5. Invariance to periodic patterns and trends. In particular some suitable consideration of dominant seasonal-annual cycles should avoid to be confounded with the detection of abnormal situations in the System Trajectory.

6. Provide the basis for detecting regional (spatially) abrupt regime shifts, i.e., cases where one or more dimensions abruptly depict a change in mean or higher order statistical moments (variance, kurtosis).


To ensure, that BAST indices are able to deal with the common properties of satellite data and fulfill the above-mentioned requirements, a test data farm will be created. We extend an approach offered by Guh and Shiue (2008) to the multivariate and generic case. The test data farm will be used to evaluate different construction possibilities with respect to their usability for the BAST index construction. Within the test data farm, the variation of a variable over time Xt,i, is defined as

Xt,i = Bt,i + Nt,i + St,i = bt,i (1 + kb evt,i) + nt,i (1 + kn evt,i) + ks evt,i σ

where

- Xt,i is the data stream, consisting of the observed process at spatial locations i and time points t. 

- Bt,i is the process baseline, which is the mean state vector, defined by the main change of the vector over time. Note that the process baseline can be either static or periodic (mimicking the annual cycle), or follow any other function or model (e.g. linear trend, roessler system, arma process). To introduce changes in the baseline’s amplitude or trend, Bt,i  = bt,i (1 + kb evt,i), with bt,i  being the original process baseline, kb defining the amplitude of the event, and evt,i defining the occurrence of the event in space and time (evt,i = 0 means no event, Bt,i defined by the original process baseline, evt,i = 1 if there is a spatio-temporal event)

- Nt,i is the “common” variation around the data mean state Bt,i, following some distribution or noise pattern (e.g. normal distribution or some correlated noise). Variance shifts can be induced by defining Nt,i = nt,i (1 + kn evt,i), with evt,i= 1 if there is a variance shift present, and evt,i=0 otherwise. The magnitude of the variance shift is defined by kn. nt,i is characterized by its standard deviation σ. 

- St,i defines a shift in the baseline and is defined as St,i = ks evt,i σ with evt,i =1 if there is a shift present, and evt,i =0 otherwise; ks being some factor defining the magnitude of the shift relative to σ.

At least three different data streams Xt,i will be created for each virtual location in a spatial grid i of 100 x 100 pixels, with 300 temporal observations t to deal with requirement 2. Another four (or more) data streams are created by linear or multiplicative combinations of these three core data streams. Together, the data streams and their combinations are forming a multivariate vector Xd,i,t as one test data cube. 

Each data cube is explicitly designed to test the BAST index to deal with one of the above-listed requirements or combinations of it. This is done by inducing extremes with high ks and short duration evt,i = 1 (3), shifts in mean with intermediate ks and long duration of evt,i = 1 (4), changing the magnitude of the shift with different ks (5), or including long-term periodicities and trends in bt,i (6). Furthermore, shifts in variance can be included by manipulating the values of kn (4). Hence, each test data in the test farm set will include at least one example of the above-mentioned designs, thus the overall test data farm is able to quantify the ability of the different BAST construction possibilities to deal with the requirements and problems of the data. Together, all different test data cubes form the overall test data farm.