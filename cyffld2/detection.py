import os.path as op

from ._ffld2 import FFLDMixture, cy_detect_objects
from .paths import models_dir_path


# Cache the frontal face detector
FRONTAL_DETECTOR_PATH = op.join(models_dir_path(),
                                'headhunter_dpm_baseline.txt')
FRONTAL_DETECTOR = None


def get_frontal_face_mixture_model():
    r"""
    Returns a mixture model that can detect frontal faces. This model
    is the DPM Baseline model provided by Mathias et. al. from [1]_.

    This package makes no claim over the training of this model, and refers
    the user to the LICENSE files for more information.

    Returns
    -------
    model : `FFLDMixture`
        The frontal face detection model.

    References
    ----------
    .. [1] M. Mathias and R. Benenson and M. Pedersoli and L. Van Gool
       Face detection without bells and whistles
       ECCV 2014
    """
    global FRONTAL_DETECTOR
    if FRONTAL_DETECTOR is None:
        FRONTAL_DETECTOR = FFLDMixture()
        FRONTAL_DETECTOR.load(FRONTAL_DETECTOR_PATH)
    return FRONTAL_DETECTOR


def detect_frontal_faces(image, padding=6, interval=5, threshold=4.0,
                         overlap=0.3):
    r"""
    Detect frontal faces in the given image. The image can be either
    RGB or Greyscale, but must be uint8 (unsigned char) and have a channel axis,
    even if Greyscale.

    Parameters
    ----------
    image : ``(height, width, n_channels)`` `uint8 ndarray`
        An unsigned 8-bit image with pixels [0, 255] with an explicit channel
        axis as the last axis.
    padding : `int`
        Amount of zero padding in HOG cells
    interval : `int`
        Number of levels per octave in the HOG pyramid
    threshold : `double`
        Minimum detection threshold. Detections with a score less than this
        value are not returned. Values can be negative.
    overlap : `double`
        Minimum overlap in in latent positive search and non-maxima suppression.
        As discussed in [1]_, a sensible value for overlap is 0.3

    Returns
    -------
    detections : list of FFLDDetection
        Sorted by DPM score.

    Examples
    --------
    Notice the explicit 1 in the last axis to give the greyscale image
    channel axis.

    >>> import numpy as np
    >>> from cyffld2 import detect_frontal_faces
    >>> fake_greyscale_im = np.random.randint(0, high=255, size=(100, 100, 1))
    >>> fake_greyscale_im = fake_greyscale_im.astype(np.uint8)
    >>> detect_frontal_faces(fake_greyscale_im)
    """
    return detect_objects(get_frontal_face_mixture_model(), image,
                          padding=padding, interval=interval,
                          threshold=threshold, overlap=overlap)


def detect_objects(model, image, padding=6, interval=5, threshold=0.5,
                   overlap=0.3):
    r"""
    Detect objects using the provided model in the image. The image can be
    either RGB or Greyscale, but must be uint8 (unsigned char) and have a
    channel axis, even if Greyscale.

    Parameters
    ----------
    model : FFLDMixture
        A model to perform detections with.
    image : ``(height, width, n_channels)`` `uint8 ndarray`
        An unsigned 8-bit image with pixels [0, 255] with an explicit channel
        axis as the last axis.
    padding : `int`
        Amount of zero padding in HOG cells
    interval : `int`
        Number of levels per octave in the HOG pyramid
    threshold : `double`
        Minimum detection threshold. Detections with a score less than this
        value are not returned. Values can be negative.
    overlap : `double`
        Minimum overlap in in latent positive search and non-maxima suppression.
        As discussed in [1]_, a sensible value for overlap is 0.3

    Returns
    -------
    detections : list of FFLDDetection
        Sorted by DPM score.

    Raises
    ------
    ValueError
        If the model is empty.
    """
    if model.is_empty():
        raise ValueError('Mixture model must not be empty.')
    return cy_detect_objects(model, image, padding, interval, threshold,
                             overlap)
