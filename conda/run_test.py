import sys
import cyffld2
import numpy as np
from scipy import misc

if __name__ == "__main__":
    lena = misc.lena().astype(np.uint8)[..., None]
    results = cyffld2.detect_frontal_faces(lena, threshold=2.)
    print('Found {} faces'.format(len(results)))
    assert(len(results) == 1)

