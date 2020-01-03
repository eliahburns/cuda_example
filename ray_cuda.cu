#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdbool.h>
#include <sys/time.h>
#include <time.h>
#include <cuda.h>
#include <curand.h>
#include <curand_kernel.h>


#define PI 3.14159265359


typedef struct 
{
    double x;
    double y;
    double z;
} Vector3D;


/// 3D dot product
__device__
double dot_prod3D(Vector3D *V1, Vector3D *V2)
{
    return V1->x*V2->x + V1->y*V2->y + V1->z*V2->z;
} 


/// window intersection scalar
/// assumes V is unit vector and returns true if scalar exists 
__device__
bool view_scalar(Vector3D * V, Vector3D * C, int R, double * t)
{
    double dot_VC = dot_prod3D(V, C);
    double dot_CC = dot_prod3D(C, C);

    if ((dot_VC*dot_VC + R*R - dot_CC) < 0)
        return false;

    *t = dot_VC - sqrt(dot_VC*dot_VC + R*R - dot_CC); 
    
    return true;
}


/// intersection of view and sphere
__device__
void intersection(Vector3D * I, Vector3D * V, double t)
{
    I->x = t*V->x;
    I->y = t*V->y;
    I->z = t*V->z;
}


/// unit normal vector of sphere
__device__
void unit_norm_sphere(Vector3D *I, Vector3D *C, Vector3D *N)
{
    Vector3D ImC;

    ImC.x = I->x - C->x;
    ImC.y = I->y - C->y;
    ImC.z = I->z - C->z;

    double dot_ImC = dot_prod3D(&ImC, &ImC);

    N->x = (ImC.x) / sqrt(dot_ImC);
    N->y = (ImC.y) / sqrt(dot_ImC);
    N->z = (ImC.z) / sqrt(dot_ImC);
}


/// create shadow ray and compute brightness
__device__
double brightness(Vector3D *I, Vector3D *L, Vector3D *N)
{
    Vector3D S;
    Vector3D LmI;

    // calculate shadow ray
    LmI.x = L->x - I->x;
    LmI.y = L->y - I->y;
    LmI.z = L->z - I->z;

    double dot_LmI = dot_prod3D(&LmI, &LmI);

    S.x = (LmI.x) / sqrt(dot_LmI);
    S.y = (LmI.y) / sqrt(dot_LmI);
    S.z = (LmI.z) / sqrt(dot_LmI);
    
    // return the max between 0 and S.N
    double dot_SN = dot_prod3D(&S, N);

    return (dot_SN > 0) ? dot_SN : 0.0;
}


// kernel function
__global__
void raytrace(double * grid, int grid_p, int n_rays)
{
	// use cuda's random number generator
	int i =  blockDim.x*blockIdx.x + threadIdx.x;

	curandState_t state;
  	curand_init(i, 0, 0, &state);

    int radius = 6;
    double W_y = 10; double W_max = 10;
    double window_scale = (((double)grid_p) / ((double)(2*W_max)));
     
    // set up light source and sphere center position
    Vector3D L;
    L.x = 4; L.y = 4; L.z = -1; 
    
    Vector3D C;
    C.x = 0; C.y = 12; C.z = 0;

    Vector3D W; Vector3D V; Vector3D I; Vector3D N;

    for (int i = 0; i < n_rays; ++i)
    {
        double t, theta, phi, b;

        do
        {
   	    phi = (double) curand_uniform(&state) * (double) M_PI;
      	    theta = (double) curand_uniform(&state)  * (double) M_PI;
 
            V.x  = sin(theta) * cos(phi);
            V.y  = sin(theta) * sin(phi);
            V.z  = cos(theta);

            W.x = (W_y / V.y) * V.x;
            W.y = (W_y / V.y) * V.y; 
            W.z = (W_y / V.y) * V.z;

        } while ((!view_scalar(&V, &C, radius, &t)) || (fabs(W.x) > W_max) || (fabs(W.z) > W_max));

        intersection(&I, &V, t);

        unit_norm_sphere(&I, &C, &N);
        
        b = brightness(&I, &L, &N);        
        
        double x = (W.x + (double)W_max);
        double z = (W.z + (double)W_max);
        x = x * window_scale;
        z = z * window_scale;
		
        grid[(int)x*grid_p + (int)z] += b;

    } 
}



int main(int argc, char **argv)
{
    // arg[1] = number of rays, arg[2] = number of grid points
    if (argc != 3)
    {
        printf("Invalid number of arguments.\n");
        printf("To run: $ ./raytrace <number_of_rays> <number_of_gridpoints>\n");
        exit(1);
    }
    int n_rays = atoi(argv[1]);
    int grid_p = atoi(argv[2]);

    if (n_rays < (grid_p*grid_p))
    {
        printf("Invalid arguments: number of rays must be greater than grid_points^2\n");
        exit(1);
    }

	struct timeval start, end;
	gettimeofday(&start, NULL);

    srand(time(NULL));

    // allocate window (grid_p x grid_p) 
    double * grid = (double *) calloc(grid_p*grid_p, sizeof(double));  

	// copy data over launch kernel 

	// Cuda malloc
	double * cuda_grid;
	cudaError_t _e;
	_e = cudaMalloc((void**)&cuda_grid, grid_p*grid_p * sizeof(double));
	if (_e != cudaSuccess)
		printf("Cuda error: %s\n", cudaGetErrorString(_e));

	//transfer data to gpu
	_e = cudaMemcpy(cuda_grid, grid, grid_p*grid_p*sizeof(double), cudaMemcpyHostToDevice);
	if (_e != cudaSuccess)
		printf("Cuda error: %s\n", cudaGetErrorString(_e));

	// run kernel
	int block_size = ;
	int rays_per_thread = 50;
	int n_blocks = (n_rays + block_size - 1) / (block_size*rays_per_thread);
	printf("number of blocks = %d\n", n_blocks);

	raytrace<<< n_blocks, block_size>>>(cuda_grid, grid_p, rays_per_thread);
	_e = cudaGetLastError();

	//get data from gpu
	_e = cudaMemcpy(grid, cuda_grid, grid_p*grid_p*sizeof(double), cudaMemcpyDeviceToHost);
	if (_e != cudaSuccess)
		printf("Cuda error: %s\n", cudaGetErrorString(_e));

    // print execution time
    gettimeofday(&end, NULL);
    double m = 1000000;
    double t = ((end.tv_sec*m + end.tv_usec) - (start.tv_sec*m + start.tv_usec));   
    printf("Cuda,%d, %g\n", n_rays, t / m);

    // write grid to file
    FILE * out = fopen("sphere.bin", "wb");

    for (int i = 0; i < grid_p; ++i)
        for (int j = 0; j < grid_p; ++j)
        {
            fwrite(&(grid[i*grid_p + j]), sizeof(double), 1, out);
        }            
    

    fclose(out);

    free(grid);

    return 0;
}

