import sys
import cyffld2
import numpy as np
from scipy import misc

if __name__ == "__main__":
    try:
        lena = misc.lena().astype(np.uint8)[..., None]
        results = cyffld2.detect_frontal_faces(lena)
        print('Found {} faces'.format(len(results)))
        assert(len(results) == 1)
    except:
        sys.exit(1)
