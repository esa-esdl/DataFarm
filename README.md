# Project to collect surrogate dataset creation code

### Notes from last meeting:

- start with very simple base dataset (white noise, equal seasonal cycle, ...)
- add new "complications" to the simplest case one at a time
- don't mix them in the first version
- us the extreme generation model presented by Milan
- start with a 2-level approach on/off for disturbing effects
- in v1 write data to NetCDF files, in later versions think about directly callable functions that generate datasets in the fly
- define additive and multiplicative processes
- add several periodicities


### Open questions

-  which language to choose, should be compilable to shared lib