# distutils: language = c++
from libcpp.vector cimport vector
from ._ffld2 cimport (InMemoryScene, Detection, Mixture, Object, Rectangle,
                      load_mixture_model, save_mixture_model, detect, train)


cpdef load_model(string path):
    r"""
    Loads a mixture model from the provided path and returns an FFLDMixture.

    Parameters
    ----------
    path : string
        The path to the model.

    Returns
    -------
    model : FFLDMixture
        The model.
    """
    mixture = FFLDMixture()
    mixture.load(path)
    return mixture

cdef class FFLDMixture:

    cdef Mixture mixture

    def is_empty(self):
        r"""
        Whether the model is empty or not.

        Returns
        -------
        is_empty : `bool`
            Whether the model is empty.
        """
        return self.mixture.empty()

    def save(self, output_filename):
        r"""
        Save this model to the given path.

        Parameters
        ----------
        output_filename : `str`
            The full path to save the model to. Saved in the standard
            text format assumed by ffld2.
        """
        save_mixture_model(output_filename.encode('UTF-8'), self.mixture)

    cpdef load(self, input_filename):
        r"""
        Load a model from disk and update this model with the loaded state.

        Parameters
        ----------
        input_filename : `str`
            The full path to load the ffld2 model from.

        Raises
        ------
        ValueError
            Loading fails.
        """
        if not load_mixture_model(input_filename.encode('UTF-8'), self.mixture):
            raise ValueError('Unable to load mixture model from the given '
                             'path: {}'.format(input_filename))

    def __str__(self):
        return '{} - Min Size: {}, Max Size: {}'.format(
            type(self).__name__, self.mixture.minSize(), self.mixture.maxSize()
        )


cdef class FFLDDetection:

    cdef Detection detection

    def __cinit__(self, float score, int x, int y, int width, int height):
        self.detection.setX(x)
        self.detection.setY(y)
        self.detection.setWidth(width)
        self.detection.setHeight(height)
        self.detection.score = score

    @property
    def x(self):
        r"""
        The x-coordinate of 'bottom' corner of the box. The lowest x-coordinate.

        :type: `int`
        """
        return self.detection.x()

    @property
    def y(self):
        r"""
        The y-coordinate of 'bottom' corner of the box. The lowest y-coordinate.

        :type: `int`
        """
        return self.detection.y()

    @property
    def width(self):
        r"""
        The width of the box.

        :type: `int`
        """
        return self.detection.width()

    @property
    def height(self):
        r"""
        The height of the box.

        :type: `int`
        """
        return self.detection.height()

    @property
    def left(self):
        r"""
        The smallest x-coordinate (the furthest 'left' in the image).

        :type: `int`
        """
        return self.detection.left()

    @property
    def right(self):
        r"""
        The largest x-coordinate (the furthest 'right' in the image).

        :type: `int`
        """
        return self.detection.right()

    @property
    def top(self):
        r"""
        The largest y-coordinate (the furthest 'up' in the image).

        :type: `int`
        """
        return self.detection.top()

    @property
    def bottom(self):
        r"""
        The smallest y-coordinate (the furthest 'down' in the image).

        :type: `int`
        """
        return self.detection.bottom()

    @property
    def score(self):
        r"""
        The DPM score of this detection.

        :type: `float`
        """
        return self.detection.score

    def __richcmp__(x, y, int op):
        if op == 0:  # <
            return x.score < y.score
        if op == 1:  # <=
            return x.score <= y.score
        if op == 2:  # ==
            return x.score == y.score
        if op == 3:  # !=
            return x.score != y.score
        if op == 3:  # >
            return x.score > y.score
        if op == 5:  # >=
            return x.score >= y.score

    def __str__(self):
        return '{} - Score: {}, Left: {}, Top: {}, Right: {}, Bottom: {}'.format(
            type(self).__name__, self.score, self.left, self.top, self.right,
            self.bottom
        )


cpdef cy_detect_objects(FFLDMixture mixture_model, unsigned char[:, :, :] image,
                        int padding, int interval, double threshold,
                        double overlap):
    r"""
    Detect all objects described by the given model in the given image. RGB
    and Greyscale images are both supported, but Greyscale images must have
    a channel axis.

    Parameters
    ----------
    mixture_model : FFLDMixture
        The mixture model to detect with.
    image : unsigned char[:, :, :]
        The image to detect inside. Can be either RGB or Greyscale, but must
        have a channel axis (last axis).
    padding : int
        Amount of zero padding in HOG cells
    interval : int
        Number of levels per octave in the HOG pyramid
    threshold : double
        Minimum detection threshold. Detections with a score less than this
        value are not returned. Values can be negative.
    overlap : double
        Minimum overlap in in latent positive search and non-maxima suppression.

    Returns
    -------
    detections : list of FFLDDetection
        The detections, sorted by score from highest to lowest.
    """
    cdef:
        vector[Detection] detections
    detect(mixture_model.mixture, &image[0, 0, 0], image.shape[1],
           image.shape[0], image.shape[2], padding, interval, threshold,
           overlap, detections)

    output_detections = []
    for d in detections:
        output_detections.append(FFLDDetection(d.score, d.x(), d.y(),
                                               d.width(), d.height()))
    return output_detections


cdef image_arrays_to_scenes(list image_arrays, list bbox_arrays,
                            vector[InMemoryScene]& scenes):
    r"""
    Converts a list of image ndarrays and any bounding boxes to InMemoryScene
    objects for use in training.

    ``image_arrays` and ``bbox_arrays`` must have the same length or
    ``bbox_arrays`` will be ignored.

    Fills in the provided vector rather than returning any data.

    Parameters
    ----------
    image_arrays : list of unsigned char[:, :, :]
        The list of uint8 images which are for training.
    bbox_arrays : list of lists of 1D int ndarrays with 4 elements
        The elements should be [x, y, width, height] where the meaning of those
        elements is as described in FFLDDetection.
    scenes : vector[InMemoryScene]
        The output vector of scenes (passed by reference).
    """
    cdef:
        InMemoryScene scene
        vector[Object] objects
        Object obj
        Rectangle bndbox
        unsigned char[:, :, :] pixels_buffer
        bool has_objects = len(image_arrays) == len(bbox_arrays)


    for k, image in enumerate(image_arrays):
        pixels_buffer = image
        if has_objects:
            for bb in bbox_arrays[k]:
                bndbox = Rectangle(bb[0], bb[1], bb[2], bb[3])
                obj = Object(bndbox)
                objects.push_back(obj)
        scene = InMemoryScene(&pixels_buffer[0, 0, 0],
                              pixels_buffer.shape[1],
                              pixels_buffer.shape[0],
                              pixels_buffer.shape[2],
                              objects)
        scenes.push_back(scene)
        objects.clear()

cpdef cy_train(list positive_image_arrays, list positive_bbox_arrays,
               list negative_image_arrays, const int n_components,
               const int pad_x, const int pad_y, const int interval,
               const int n_relabel, const int n_datamine,
               const int max_negatives, const double C, const double J,
               const double overlap):
    r"""
    Trains an ffld2 model using a set of in-memory images. Must explicitly pass
    a list of positive images and a list of negative images. The negative images
    should not contain any objects from the positive set.

    Both ``positive_image_arrays`` and ``negative_image_arrays`` should be a
    list of unsigned char[:, :, :].

    ``positive_bbox_arrays`` should be a list of arrays with 4 elements:
        [x, y, width, height]
    as described in FFLDDetection.

    Parameters
    ----------
    positive_image_arrays : list of unsigned char[:, :, :]
        The list of uint8 images which are for positive training.
    positive_bbox_arrays : list of lists of 1D int ndarrays with 4 elements
        The elements should be [x, y, width, height] where the meaning of those
        elements is as described in FFLDDetection. A list of lists is passed
        as there may be more than one object per image.
    negative_image_arrays: list of unsigned char[:, :, :]
        The list of uint8 images which are for negative training.
    n_components : int
        Number of mixture components (without symmetry).
    pad_x : int
        Amount of zero padding in HOG cells (x-direction).
    pad_y : int
        Amount of zero padding in HOG cells (y-direction).
    interval : int
        Number of levels per octave in the HOG pyramid.
    n_relabel : int
        Maximum number of training iterations.
    n_datamine : int
        Maximum number of data-mining iterations within each training iteration.
    max_negatives : int
        Maximum number of negative images to consider, can be useful for
        reducing training time.
    C : double
        SVM regularization constant.
    J : double
        SVM positive regularization constant boost.
    overlap : double
        Minimum overlap in in latent positive search and non-maxima suppression.

    Returns
    -------
    model : FFLDMixture
        The newly trained model.

    Raises
    ------
    ValueError
        If the model fails to train in any way.
    """
    cdef:
        vector[InMemoryScene] positive_scenes
        vector[InMemoryScene] negative_scenes

    image_arrays_to_scenes(positive_image_arrays, positive_bbox_arrays,
                           positive_scenes)

    image_arrays_to_scenes(negative_image_arrays, [], negative_scenes)

    cdef Mixture mixture = Mixture(n_components, positive_scenes)

    if not train(positive_scenes, negative_scenes,
                 pad_x, pad_y, interval, n_relabel, n_datamine, max_negatives,
                 C, J, overlap, mixture):
        raise ValueError('Failed to train model.')
    mixture_wrapper = FFLDMixture()
    mixture_wrapper.mixture = mixture

    return mixture_wrapper
