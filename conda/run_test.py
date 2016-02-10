import os
import sys
import cyffld2
import numpy as np
from PIL import Image

if __name__ == "__main__":
    recipe_filepath = os.environ.get('RECIPE_DIR', os.path.dirname(os.path.abspath(__file__)))
    lena_path = os.path.join(recipe_filepath, 'lena.png')

    lena = np.array(Image.open(lena_path))

    results = cyffld2.detect_frontal_faces(lena, threshold=2.)
    print('Found {} faces'.format(len(results)))
    assert(len(results) == 1)

