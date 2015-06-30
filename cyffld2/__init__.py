from .detection import (detect_objects, detect_frontal_faces,
                        get_frontal_face_mixture_model)
from .training import train_model
from ._ffld2 import load_model

from ._version import get_versions
__version__ = get_versions()['version']
del get_versions
