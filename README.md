
Eli Burns
===

HW4 : MPCS 51087 : winter 2017
===


cuda version: ray_cuda.cu  (make cuda)
serial version: raytrace.c (make)


To run:

$ ./ray_cuda <num_rays> <dimension>

$ ./raytrace <num_rays> <dimension>



Note: 
---

Generated data is saved to "sphere.bin"
The python file, plot.py will generate two images from the data, but you 
must enter the dimension os the data as an argument (e.g. python3 plot.py 1000)


I have several sample images for your enjoyment. It shouldn't be difficult to 
generate more to testi, as well. 


All images/plots are located in the images directory. And some of my data is in
the data directory. I don't have an sbatch file for you, though. I couldn't get
an exclusive GPU (waited hours), so I ended up just testing things by hand in 
sinteractive. 


You'll see in the images directory, a plot illustrating a scaling study for the 
occupancy of the Tesla K80 GPU, running from 8 threads to 2048 threads and showing
a pretty continous improvement. Although I'm not sure if I buy it. I had to do some
juggling in places, so that as problem sizes change I don't go past the max thread or
block size (when this happened, it seemed like the GPU wouldn't actually do any cmpu-
tation). Some of the adjusting I do to compensate for this could be largely responsible
for the shape of the curve where it dips down and then begins to increase slightly 
before tapering off again. 


There's also a plot that shows the execution times for the serial and cuda versions side
by side, which are very surprising. We see the serial version increase in time rapidly, 
while the cuda version stays largely steady. The cuda version eventually hits a point 
where it starts exponentially increasing but it's at a much larger problem size. I think I 
tested successfully at 100 billion rays, and it didn't take too long. 


