import numpy as np
import matplotlib.pyplot as plt
from PIL import Image
import scipy.ndimage

n = 500
shape = (n, n)
with open("sphere.bin", 'rb') as f:
    data = np.fromfile(file=f, dtype=np.double).reshape(shape)
    plt.imshow(scipy.ndimage.rotate(data, 180))
    plt.show() 
    image = Image.fromarray(data)
    arr = np.asarray(image)
    plt.imshow(arr, cmap='gray', origin = 'lower')
    plt.show()

