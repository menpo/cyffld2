from ._ffld2 import cy_train


def train_model(positive_image_arrays, positive_bbox_arrays,
                negative_image_arrays, n_components=3, pad_x=6, pad_y=6,
                interval=5, n_relabel=8, n_datamine=10, max_negatives=24000,
                C=0.002, J=2.0, overlap=0.5):
    r"""
    Trains an ffld2 model using a set of in-memory images. Must explicitly pass
    a list of positive images and a list of negative images. The negative images
    should not contain any objects from the positive set.

    Both ``positive_image_arrays`` and ``negative_image_arrays`` should be a
    list of uint8 arrays with an explicit channel axis. Can be RGB or Greyscale,
    but Greyscale images must have an empty channel axis.

    ``positive_bbox_arrays`` should be a list of arrays with 4 elements:

        [x, y, width, height]

    as described in FFLDDetection.

    Parameters
    ----------
    positive_image_arrays : list of ``(height, width, n_channels)`` `uint8 ndarray`
        The list of uint8 images which are for positive training.
    positive_bbox_arrays : list of 1D ndarrays with 4 elements
        The elements should be [x, y, width, height] where the meaning of those
        elements is as described in FFLDDetection.
    negative_image_arrays: list of ``(height, width, n_channels)`` `uint8 ndarray`
        The list of uint8 images which are for negative training.
    n_components : `int`
        Number of mixture components (without symmetry).
    pad_x : `int`
        Amount of zero padding in HOG cells (x-direction).
    pad_y : `int`
        Amount of zero padding in HOG cells (y-direction).
    interval : `int`
        Number of levels per octave in the HOG pyramid.
    n_relabel : `int`
        Maximum number of training iterations.
    n_datamine : `int`
        Maximum number of data-mining iterations within each training iteration.
    max_negatives : `int`
        Maximum number of negative images to consider, can be useful for
        reducing training time.
    C : `double`
        SVM regularization constant.
    J : `double`
        SVM positive regularization constant boost.
    overlap : `double`
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
                    negative_image_arrays, n_components, pad_x, pad_y, interval,
                    n_relabel, n_datamine, max_negatives, C, J, overlap)
