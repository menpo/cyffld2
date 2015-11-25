from setuptools import setup, find_packages, Extension
from glob import glob
from Cython.Build import cythonize
import platform
import os
import versioneer


include_dirs = ['ffld2', 'ffld2/lib']
library_dirs = []
extra_compile_args = []
extra_link_args = []
libraries = []

sources = (['cyffld2/ffld2/HOGPyramid.cpp',
            'cyffld2/ffld2/JPEGImage.cpp',
            'cyffld2/ffld2/LBFGS.cpp',
            'cyffld2/ffld2/Model.cpp',
            'cyffld2/ffld2/Object.cpp',
            'cyffld2/ffld2/Patchwork.cpp',
            'cyffld2/ffld2/Rectangle.cpp',
            'cyffld2/ffld2/Scene.cpp',
            'cyffld2/ffld2/Mixture.cpp',
            'cyffld2/ffld2/lib/ffld2.cpp',
            'cyffld2/_ffld2.pyx'])

_platform = platform.platform().lower()
if 'linux' in _platform:
    extra_compile_args += ['-fopenmp']
    extra_link_args += ['-fopenmp']

    libraries += ['xml2', 'fftw3f', 'jpeg']
elif 'darwin' in _platform:
    libraries += ['xml2', 'fftw3f', 'jpeg']
elif 'windows' in _platform:
    extra_compile_args += ['/openmp']
    extra_link_args += ['/openmp']
    
    if os.environ.get('CONDA_BUILD', None):
        # There is a bug in visual studio 2008 whereby you can't pass non-aligned
        # values, therefore, we have to turn off alignment enforcement
        # for eigen on Win32. See http://eigen.tuxfamily.org/bz/show_bug.cgi?id=83
        # more more information.
        if int(os.environ.get('ARCH', 32)) == 32:  # Default to 32 for safety
            extra_compile_args += ['/DEIGEN_DONT_ALIGN_STATICALLY=1']
    
        extra_compile_args += ['/D_USE_MATH_DEFINES=1' , '/EHsc']
        
        libxml_dir = os.path.join(os.environ['LIBRARY_INC'], 'libxml2')
        include_dirs += [os.environ['LIBRARY_INC'], libxml_dir]
        
        library_dirs.append(os.environ['LIBRARY_LIB'])
        # This looks a bit strange but it is to match the library names
        # that I have created in other recipes.
        libraries += ['libxml2', 'libfftw3f-3', 'jpeg']
            
extensions = [Extension('cyffld2._ffld2', sources,
                        include_dirs=include_dirs,
                        library_dirs=library_dirs,
                        extra_compile_args=extra_compile_args,
                        extra_link_args=extra_link_args,
                        libraries=libraries,
                        language='c++')]

requirements = ['Cython>=0.23,<=0.24']

setup(name='cyffld2',
      version=versioneer.get_version(),
      cmdclass=versioneer.get_cmdclass(),
      description='A Cython wrapper around the FFLD2 face detection library.',
      author='Patrick Snape',
      author_email='p.snape@imperial.ac.uk',
      url='https://github.com/menpo/cyffld2',
      ext_modules=cythonize(extensions, quiet=True),
      package_data={'cyffld2': [
          'ffld2/models/headhunter_dpm_baseline.txt',
          'ffld2/*.h',
          'ffld2/lib/*.h',
          'ffld2/*.cpp',
          'ffld2/lib/*.cpp',
          '_ffld2.pyx',
          '_ffld2.pxd'
      ]},
      install_requires=requirements,
      packages=find_packages()
)
