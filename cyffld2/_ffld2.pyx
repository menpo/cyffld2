# distutils: language = c++
from libcpp.vector cimport vector
from ._ffld2 cimport detect, Detection, Mixture, load_mixture_model


cdef class FFLDMixture:

    cdef Mixture mixture

    def __cinit__(self, path):
        if not load_mixture_model(path, self.mixture):
            raise ValueError('Unable to load mixture model from the given '
                             'path: {}'.format(path))

    def is_empty(self):
        return self.mixture.empty()

cdef class FFLDDetection:

    cdef Detection detection

    def __cinit__(self, float score, int x, int y, int width, int height):
        self.detection.setX(x)
        self.detection.setY(y)
        self.detection.setWidth(width)
        self.detection.setHeight(height)
        self.detection.score = score

    @property
    def left(self):
        return self.detection.left()

    @property
    def right(self):
        return self.detection.right()

    @property
    def top(self):
        return self.detection.top()

    @property
    def bottom(self):
        return self.detection.bottom()

    @property
    def score(self):
        return self.detection.score

    def __str__(self):
        return '{} - Score: {}, Left: {}, Top: {}, Right: {}, Bottom: {}'.format(
            type(self).__name__, self.score, self.left, self.top, self.right,
            self.bottom
        )


cpdef cy_detect_objects(FFLDMixture mixture_model, unsigned char[:, :] image,
                        int padding, int interval, double threshold,
                        double overlap):
    cdef:
        vector[Detection] detections
    detect(mixture_model.mixture, &image[0, 0], image.shape[1], image.shape[0],
           padding, interval, threshold, overlap, detections)
    output_detections = []
    for d in detections:
        output_detections.append(FFLDDetection(d.score, d.x(), d.y(),
                                               d.width(), d.height()))
    return output_detections
