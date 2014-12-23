from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp cimport bool


cdef extern from "ffld2/Mixture.h" namespace "FFLD":
    cppclass Mixture:
        Mixture()
        bool empty()
        #double train(const vector[Scene] & scenes, Object::Name name, int padx = 12, int pady = 12,
        #int interval = 5, int nbRelabel = 5, int nbDatamine = 10, int maxNegatives = 24000,
        #double C = 0.002, double J = 2.0, double overlap = 0.7)
        void cacheFilters()

cdef extern from "ffld2/Rectangle.h" namespace "FFLD":
    cppclass Rectangle:
        Rectangle()
        Rectangle(int width, int height)
        Rectangle(int x, int y, int width, int height)
        int x()
        void setX(int x)
        int y()
        void setY(int y)
        int width()
        void setWidth(int width)
        int height()
        void setHeight(int height)
        int left()
        void setLeft(int left)
        int top()
        void setTop(int top)
        int right()
        void setRight(int right)
        int bottom()
        void setBottom(int bottom)
        bool empty()
        int area()

cdef extern from "ffld2/lib/ffld2.h":
    cppclass Detection(Rectangle):
        float score
        Detection()

    void detect(const Mixture mixture, const unsigned char* image,
                const int width, const int height, const int padding,
                const int interval, const double threshold, const double overlap,
                vector[Detection]& detections)
    bool load_mixture_model(const string filepath, Mixture& mixture)
