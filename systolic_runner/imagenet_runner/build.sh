#!/bin/bash
release_path="Debug"

# First determine what path to link against
for var in "$@"
do
    if [ $var = "--config=Release" ]; then
        release_path="Release"
    fi
done
# I clearly have no idea how to actually write bash scripts. At all.
echo "Building against ${release_path}"
root_path=../../
build_path=${root_path}/build/${release_path}

extra_libs=""
extra_defs=""

# Check for hwacha support
for var in "$@"
do
	if [ $var = "--use_hwacha" ]; then
		echo "Building with hwacha support"
        extra_defs="-DUSE_HWACHA ${extra_defs}"
        extra_libs="${build_path}/libonnxruntime_providers_hwacha.a ${extra_libs}"
	fi
    if [ $var = "--for_firesim" ]; then 
        echo "Building with mlockall for running on Firesim"
        extra_defs="-DFOR_FIRESIM ${extra_defs}"
    fi
    if [ $var = "--enable_training" ]; then
        extra_libs="${build_path}/tensorboard/libtensorboard.a ${extra_libs}"
    fi

done

# Check for halide interop generated custom operators
if [ -f "${root_path}/systolic_runner/halide_interop/model_converter/generated/libcustom.a" ]; then
    echo "Found custom lib. Building with support for loading it."
    extra_libs="${root_path}/systolic_runner/halide_interop/model_converter/generated/libcustom.a \
                ${root_path}/systolic_runner/halide_interop/Halide/bin/halide_runtime.a ${extra_libs}"
    extra_defs="-DUSE_CUSTOM_OP_LIBRARY ${extra_defs}"
fi


rm -f ort_test
make -s ort_test root_path=${root_path} build_path=${build_path} extra_libs=${extra_libs} extra_defs=${extra_defs}