from setuptools import setup, find_packages, Extension
from glob import glob
from Cython.Build import cythonize

include_directories = ['ffld2', 'ffld2/lib']
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
extensions = [Extension('cyffld2._ffld2', sources,
                        include_dirs=include_directories,
                        extra_compile_args=['-w', '-fopenmp'],
                        extra_link_args=['-fopenmp'],
                        libraries=['xml2', 'fftw3f', 'jpeg'],
                        language='c++')]

requirements = ['Cython>=0.21,<=0.22']

setup(name='cyffld2',
      version='0.1.0',
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
