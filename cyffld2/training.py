from ._ffld2 import cy_train


def train_model(positive_image_arrays, positive_bbox_arrays,
                negative_image_arrays, n_components=3, pad_x=6, pad_y=6,
                cache_wisdom=False, interval=5, n_relabel=8, n_datamine=10, 
                max_negatives=24000, C=0.002, J=2.0, overlap=0.5):
    r"""
    Trains an ffld2 model using a set of in-memory images. Must explicitly pass
    a list of positive images and a list of negative images. The negative images
    should not contain any objects from the positive set.

    Both ``positive_image_arrays`` and ``negative_image_arrays`` should be a
    list of uint8 arrays with an explicit channel axis. Can be RGB or Greyscale,
    but Greyscale images must have an empty channel axis.

    ``positive_bbox_arrays`` should be a list of lists of arrays with
    4 elements:

        [x, y, width, height]

    which should be type `int`, as described in FFLDDetection.

    NOTE: Once you run this function, you will not be able to kill the Python
    process via Ctrl+C or any other interrupt until training is complete.
    Also note that training may take a number of hours and possible approach
    days if there are a lot of images.

    Parameters
    ----------
    positive_image_arrays : list of ``(height, width, n_channels)`` `uint8 ndarray`
        The list of uint8 images which are for positive training.
    positive_bbox_arrays : list of lists of 1D int ndarrays with 4 elements
        The elements should be [x, y, width, height] where the meaning of those
        elements is as described in FFLDDetection. A list of lists is passed
        as there may be more than one object per image.
    negative_image_arrays: list of ``(height, width, n_channels)`` `uint8 ndarray`
        The list of uint8 images which are for negative training.
    n_components : `int`, optional
        Number of mixture components (without symmetry).
    pad_x : `int`, optional
        Amount of zero padding in HOG cells (x-direction).
    pad_y : `int`, optional
        Amount of zero padding in HOG cells (y-direction).
    cache_wisdom : `bool`, optional
        Whether or not to cache an FFTW wisdom file or not.
    interval : `int`, optional
        Number of levels per octave in the HOG pyramid.
    n_relabel : `int`, optional
        Maximum number of training iterations.
    n_datamine : `int`, optional
        Maximum number of data-mining iterations within each training iteration.
    max_negatives : `int`, optional
        Maximum number of negative images to consider, can be useful for
        reducing training time.
    C : `double`, optional
        SVM regularization constant.
    J : `double`, optional
        SVM positive regularization constant boost.
    overlap : `double`, optional
        Minimum overlap in in latent positive search and non-maxima suppression.

    Returns
    -------
    model : `FFLDMixture`
        The newly trained model.

    Raises
    ------
    ValueError
        If the model fails to train in any way.
    """
    return cy_train(positive_image_arrays, positive_bbox_arrays,
                    negative_image_arrays, n_components, pad_x, pad_y,
                    cache_wisdom, interval, n_relabel, n_datamine,
                    max_negatives, C, J, overlap)
