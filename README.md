cuda version: ray_cuda.cu  (make cuda)
serial version: raytrace.c (make)


To run:

$ ./ray_cuda <num_rays> <dimension>

$ ./raytrace <num_rays> <dimension>



Note: 
---

_tested on Midway supercomputer_

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


