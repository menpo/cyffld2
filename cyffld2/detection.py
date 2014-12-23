import os.path as op

from ._ffld2 import FFLDMixture, cy_detect_objects
from .paths import models_dir_path


# Cache the frontal face detector
FRONTAL_DETECTOR_PATH = op.join(models_dir_path(),
                                'headhunter_dpm_baseline.txt')
FRONTAL_DETECTOR = None


def get_frontal_face_mixture_model():
    global FRONTAL_DETECTOR
    if FRONTAL_DETECTOR is None:
        FRONTAL_DETECTOR = FFLDMixture(FRONTAL_DETECTOR_PATH)
    return FRONTAL_DETECTOR


def detect_frontal_faces(image, padding=6, interval=5, threshold=4.0,
                         overlap=0.3):
    return detect_objects(get_frontal_face_mixture_model(), image,
                          padding=padding, interval=interval,
                          threshold=threshold, overlap=overlap)


def detect_objects(model, image, padding=6, interval=5, threshold=4.0,
                   overlap=0.9):
    if model.is_empty():
        raise ValueError('Mixture model must not be empty.')
    if image.ndim != 2:
        raise ValueError('Image must be greyscale.')
    return cy_detect_objects(model, image, padding, interval, threshold,
                             overlap)
