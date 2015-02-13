#!/bin/sh

cp -r $RECIPE_DIR/../ .

MAKE_ARCH="-m"$ARCH

if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  export CFLAGS="$CFLAGS $MAKE_ARCH"
  export LDFLAGS="$LDFLAGS $MAKE_ARCH"
fi

export CFLAGS="-I$INCLUDE_PATH -I$INCLUDE_PATH/libxml2"

"$PYTHON" setup.py install --single-version-externally-managed --record=/tmp/record.txt
