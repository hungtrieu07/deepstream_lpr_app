#!/bin/bash

if [ -f "tao-converter" ]; then
    echo "tao-converter exist"
else 
    echo " download tao-converter from https://catalog.ngc.nvidia.com/orgs/nvidia/teams/tao/resources/tao-converter/version"
	TARGET_DEVICE=$(uname -m)
	if [ "${TARGET_DEVICE}" = "x86_64" ]; then
		wget --content-disposition 'https://api.ngc.nvidia.com/v2/resources/nvidia/tao/tao-converter/versions/v3.21.11_trt8.0_x86/files/tao-converter'
	else
		wget --content-disposition 'https://api.ngc.nvidia.com/v2/resources/nvidia/tao/tao-converter/versions/v3.21.11_trt8.0_aarch64/files/tao-converter'
	fi
fi

chmod 755 tao-converter

echo "need to download_us.sh first"

echo "prepare trafficcamnet"
mkdir -p triton_models/us/trafficcamnet/1/
./tao-converter -k tlt_encode -t int8 -c models/tao_pretrained_models/trafficcamnet/trafficnet_int8.txt -e triton_models/us/trafficcamnet/1/resnet18_trafficcamnet_pruned.etlt_b1_gpu0_int8.engine -b 1 -d 3,544,960 models/tao_pretrained_models/trafficcamnet/resnet18_trafficcamnet_pruned.etlt

echo "prepare US_LPD"
mkdir -p triton_models/us/US_LPD/1/
./tao-converter -k nvidia_tlt  -t int8 -c  models/LP/LPD/usa_lpd_cal.bin -e triton_models/us/US_LPD/1/usa_pruned.etlt_b16_gpu0_int8.engine -b 16 -d 3,480,640 models/LP/LPD/usa_pruned.etlt
cp models/LP/LPD/usa_lpd_label.txt triton_models/us/US_LPD/

echo "prepare us yolov4-tiny"
mkdir -p triton_models/us/us_lpd_yolov4-tiny/1/
./tao-converter -k nvidia_tlt -t int8 -c models/tao_pretrained_models/yolov4-tiny/yolov4_tiny_usa_cal.bin -e triton_models/us/us_lpd_yolov4-tiny/1/yolov4_tiny_usa_deployable.etlt_b16_gpu0_int8.engine -b 16 -p Input,1x3x480x640,8x3x480x640,16x3x480x640 models/tao_pretrained_models/yolov4-tiny/yolov4_tiny_usa_deployable.etlt 
cp models/tao_pretrained_models/yolov4-tiny/usa_lpd_label.txt triton_models/us/us_lpd_yolov4-tiny

echo "prepare us_lprnet"
mkdir -p triton_models/us/us_lprnet/1/
./tao-converter -k nvidia_tlt -t fp16 -e triton_models/us/us_lprnet/1/us_lprnet_baseline18_deployable.etlt_b16_gpu0_fp16.engine -p image_input,1x3x48x96,8x3x48x96,16x3x48x96 models/LP/LPR/us_lprnet_baseline18_deployable.etlt

