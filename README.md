A few helper functions to plot frequently used charts using
VegaLite.jl


```julia
cols = [randstring('a':'f') for i in 1:8]
z = round.(rand(8,8), digits=2)
plt = corrplot(z, cols)
```

![corrplot](docs/imgs/corrplot.svg)
