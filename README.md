# CUDA Ray Trace Example

_Testing was performed on the Midway supercomputer at UChicago._

For a refresher (or intro) on what ray tracing is, check Wikipedia's
page on [ray tracing](https://en.wikipedia.org/wiki/Ray_tracing_(graphics))


## Usage


There's two versions in this project, which are largely similar. A
standard version written using only C. And a version which uses some extra
CUDA code to offload the most computationally intensive sections of the
code to a GPU--in the case of my tests a Tesla K80 GPU was used.

Generated data is saved to "sphere.bin"

The python file, plot.py will generate two images from the data, but you
must enter the dimension of the data as an argument (e.g. python3 plot.py 1000)

There are several sample images for your enjoyment. All images/plots are located
in the images directory. Data is in the data directory.


You'll see in the images directory, a plot illustrating a scaling study for the
occupancy of the Tesla K80 GPU, running from 8 threads to 2048 threads and showing
a pretty continous improvement. I had to do some juggling in places, so that as problem
sizes change I did not go past the max thread or block size--when this happened, it seemed
that the GPU wouldn't actually do any computations). Some of the adjusting I do to compensate
for this may be largely responsible for the shape of the curve where it dips down and then
begins to increase slightly before tapering off again.

There's also a plot that shows the execution times for serial and cuda versions side
by side. We see the serial version increase in time rapidly, while the cuda version stays largely
steady and linear. The cuda version eventually hits a point where it begins exponentially increasing in
computation time but it's at a much larger problem size.



## Compilation

To compile the CUDA version (_ray\_cude.cu_):
```
$ make cuda
```
To compile the standard version (_raytrace.c_):
```
$ make
```


## Execution:

After compiling, run either version of the executable file from the
command line, including the maximum number of rays that you would like
to be generated, along with the number of grid points:
```
$ ./ray_cuda <num_rays> <num_grid_pts>
```

```
$ ./raytrace <num_rays> <num_grid_pts>
```

_note: the number of grid points will be equal to the product of the
two dimensions of the grid, e.g. for a 4x4 grid we should enter 16 as the
number of grid points._


Note: 
---



