#!/bin/bash

./build_ara_image.sh
flashrom --programmer dediprog -w ./build/ara-es2-debug-apridgea/image/nuttx.bin
