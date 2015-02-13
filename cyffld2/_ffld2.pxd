from libcpp.vector cimport vector
from libcpp.pair cimport pair
from libcpp.string cimport string
from libcpp cimport bool


cdef extern from "ffld2/JPEGImage.h" namespace "FFLD":
    cppclass JPEGImage:
        JPEGImage()
        JPEGImage(int width, int height, int depth, const unsigned char* bits)
        JPEGImage(const string& filename)
        bool empty() const
        int width() const
        int height() const
        int depth() const
        const unsigned char* bits()
        unsigned char* bits()
        const unsigned char* scanLine(int y)
        unsigned char scanLine(int y)
        void save(const string& filename, int quality)
        JPEGImage rescale(double scale)


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


cdef extern from "ffld2/Object.h" namespace "FFLD::Object":
    enum Name:
        AEROPLANE, BICYCLE, BIRD, BOAT, BOTTLE, BUS, CAR, CAT, CHAIR, COW, DININGTABLE, DOG,
        HORSE, MOTORBIKE, PERSON, POTTEDPLANT, SHEEP, SOFA, TRAIN, TVMONITOR, UNKNOWN
    enum Pose:
        FRONTAL, LEFT, REAR, RIGHT, UNSPECIFIED


cdef extern from "ffld2/Object.h" namespace "FFLD":
    cppclass Object:
        Object()
        Object(Name name, Pose pose, bool truncated, bool difficult, Rectangle bndbox)
        Object(Rectangle bndbox)
        bool empty()
        Name name()
        Pose pose()
        bool truncated()
        bool difficult()
        Rectangle bndbox()


cdef extern from "ffld2/Scene.h" namespace "FFLD":
    cppclass Scene:
        Scene()
        Scene(const string & filename)
        Scene(int width, int height, int depth, const string & filename,
              const vector[Object]& objects)
        bool empty()
        int width()
        int height()
        int depth()
        const string& filename()
        const vector[Object]& objects()

    cppclass InMemoryScene(Scene):
        InMemoryScene()
        InMemoryScene(const unsigned char* image,
                      const int width, const int height, const int depth,
                      const vector[Object]& objects)
        InMemoryScene(const JPEGImage image,
                      const int width, const int height, const int depth,
                      const vector[Object]& objects)
        const JPEGImage& image()


cdef extern from "ffld2/Mixture.h" namespace "FFLD":
    cppclass Mixture:
        Mixture()
        Mixture(int nbComponents, vector[InMemoryScene]& positive_scenes)
        bool empty()
        pair[int, int] minSize()
        pair[int, int] maxSize()


cdef extern from "ffld2/lib/ffld2.h":
    cppclass Detection(Rectangle):
        float score
        Detection()

    void detect(const Mixture mixture, const unsigned char* image,
                const int width, const int height, const int n_channels,
                const int padding, const int interval, const double threshold,
                const double overlap, vector[Detection]& detections)
    bool load_mixture_model(const string filepath, Mixture& mixture)
    bool save_mixture_model(const string filepath, const Mixture& mixture)
    bool train(const vector[InMemoryScene] positive_scenes,
               const vector[InMemoryScene] negative_scenes,
               const int nbComponents,
               const int padx, const int pady,
               const int interval, const int nbRelabel,
               const int nbDatamine, const int maxNegatives,
               const double C, const double J,
               const double overlap, const string model_out_path)
    bool train(const vector[InMemoryScene] positive_scenes,
               const vector[InMemoryScene] negative_scenes,
               const int padx, const int pady,
               const int interval, const int nbRelabel,
               const int nbDatamine, const int maxNegatives,
               const double C, const double J,
               const double overlap, Mixture& mixture)
