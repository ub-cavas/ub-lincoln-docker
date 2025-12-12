#!/bin/bash

# Artifacts from:
# https://github.com/autowarefoundation/autoware/blob/main/ansible/roles/artifacts/tasks/main.yaml


RED='\033[1;91m'
GREEN='\033[1;92m'
RESET='\033[0m'

echo -e "${GREEN}Downloading Artifacts${RESET}"

# yabloc_pose_initializer
mkdir yabloc_pose_initializer
cd yabloc_pose_initializer
wget https://s3.ap-northeast-2.wasabisys.com/pinto-model-zoo/136_road-segmentation-adas-0001/resources.tar.gz
tar -xvzf resources.tar.gz
rm resources.tar.gz
cd ..

# bevfusion
mkdir bevfusion
cd bevfusion
wget https://awf.ml.dev.web.auto/perception/models/bevfusion/t4base_120m/v1/bevfusion_lidar.onnx
wget https://awf.ml.dev.web.auto/perception/models/bevfusion/t4base_120m/v1/bevfusion_camera_lidar.onnx
wget https://awf.ml.dev.web.auto/perception/models/bevfusion/t4base_120m/v1/ml_package_bevfusion_lidar.param.yaml
wget https://awf.ml.dev.web.auto/perception/models/bevfusion/t4base_120m/v1/ml_package_bevfusion_camera_lidar.param.yaml
wget https://awf.ml.dev.web.auto/perception/models/bevfusion/t4base_120m/v1/detection_class_remapper.param.yaml
cd ..

# image_projection_based_fusion
mkdir image_projection_based_fusion
cd image_projection_based_fusion
wget https://awf.ml.dev.web.auto/perception/models/pointpainting/v4/pts_voxel_encoder_pointpainting.onnx
wget https://awf.ml.dev.web.auto/perception/models/pointpainting/v4/pts_backbone_neck_head_pointpainting.onnx
wget https://awf.ml.dev.web.auto/perception/models/pointpainting/v4/detection_class_remapper.param.yaml
wget https://awf.ml.dev.web.auto/perception/models/pointpainting/v4/pointpainting_ml_package.param.yaml
cd ..

# lidar_apollo_instance_segmentation
mkdir lidar_apollo_instance_segmentation
cd lidar_apollo_instance_segmentation
wget https://awf.ml.dev.web.auto/perception/models/lidar_apollo_instance_segmentation/vlp-16.onnx
wget https://awf.ml.dev.web.auto/perception/models/lidar_apollo_instance_segmentation/hdl-64.onnx
wget https://awf.ml.dev.web.auto/perception/models/lidar_apollo_instance_segmentation/vls-128.onnx
cd ..

# lidar_centerpoint
mkdir lidar_centerpoint
cd lidar_centerpoint
wget https://awf.ml.dev.web.auto/perception/models/centerpoint/v2/pts_voxel_encoder_centerpoint.onnx
wget https://awf.ml.dev.web.auto/perception/models/centerpoint/v2/pts_backbone_neck_head_centerpoint.onnx
wget https://awf.ml.dev.web.auto/perception/models/centerpoint/v2/pts_voxel_encoder_centerpoint_tiny.onnx
wget https://awf.ml.dev.web.auto/perception/models/centerpoint/v2/pts_backbone_neck_head_centerpoint_tiny.onnx
wget https://awf.ml.dev.web.auto/perception/models/centerpoint/v2/centerpoint_ml_package.param.yaml
wget https://awf.ml.dev.web.auto/perception/models/centerpoint/v2/centerpoint_tiny_ml_package.param.yaml
wget https://awf.ml.dev.web.auto/perception/models/centerpoint/v2/centerpoint_sigma_ml_package.param.yaml
wget https://awf.ml.dev.web.auto/perception/models/centerpoint/v2/detection_class_remapper.param.yaml
wget https://awf.ml.dev.web.auto/perception/models/centerpoint/v2/deploy_metadata.yaml
cd ..

# lidar_transfusion
mkdir lidar_transfusion
cd lidar_transfusion
wget https://awf.ml.dev.web.auto/perception/models/transfusion/t4xx1_90m/v2.1/transfusion.onnx
wget https://awf.ml.dev.web.auto/perception/models/transfusion/t4xx1_90m/v2.1/transfusion_ml_package.param.yaml
wget https://awf.ml.dev.web.auto/perception/models/transfusion/t4xx1_90m/v2.1/detection_class_remapper.param.yaml
cd ..

# tensorrt_yolox
mkdir tensorrt_yolox
cd tensorrt_yolox
wget https://awf.ml.dev.web.auto/perception/models/yolox-tiny.onnx
wget https://awf.ml.dev.web.auto/perception/models/yolox-sPlus-opt.onnx
wget https://awf.ml.dev.web.auto/perception/models/yolox-sPlus-opt.EntropyV2-calibration.table
wget https://awf.ml.dev.web.auto/perception/models/object_detection_yolox_s/v1/yolox-sPlus-T4-960x960-pseudo-finetune.onnx
wget https://awf.ml.dev.web.auto/perception/models/object_detection_yolox_s/v1/yolox-sPlus-T4-960x960-pseudo-finetune.EntropyV2-calibration.table
wget https://awf.ml.dev.web.auto/perception/models/label.txt
wget https://awf.ml.dev.web.auto/perception/models/object_detection_semseg_yolox_s/v1/yolox-sPlus-opt-pseudoV2-T4-960x960-T4-seg16cls.onnx
wget https://awf.ml.dev.web.auto/perception/models/object_detection_semseg_yolox_s/v1/yolox-sPlus-opt-pseudoV2-T4-960x960-T4-seg16cls.EntropyV2-calibration.table
wget https://awf.ml.dev.web.auto/perception/models/object_detection_semseg_yolox_s/v1/semseg_color_map.csv
cd ..

# tensorrt_rtmdet
mkdir tensorrt_rtmdet
cd tensorrt_rtmdet
wget https://autoware-files.s3.us-west-2.amazonaws.com/models/tensorrt_rtmdet_onnx_models.tar.gz
tar -xvzf tensorrt_rtmdet_onnx_models.tar.gz --strip-components=1 # Removes the top-level folder during extraction
rm tensorrt_rtmdet_onnx_models.tar.gz
cd ..

# tensorrt_yolox for whole_image_traffic_light_detector
cd tensorrt_yolox
wget https://awf.ml.dev.web.auto/perception/models/tl_detector_yolox_s/v1/yolox_s_car_ped_tl_detector_960_960_batch_1.onnx
wget https://awf.ml.dev.web.auto/perception/models/tl_detector_yolox_s/v1/yolox_s_car_ped_tl_detector_960_960_batch_1.EntropyV2-calibration.table
wget https://awf.ml.dev.web.auto/perception/models/tl_detector_yolox_s/v1/car_ped_tl_detector_labels.txt
cd ..

# traffic_light_classifier
mkdir traffic_light_classifier
cd traffic_light_classifier
wget https://awf.ml.dev.web.auto/perception/models/traffic_light_classifier/v2/traffic_light_classifier_mobilenetv2_batch_1.onnx
wget https://awf.ml.dev.web.auto/perception/models/traffic_light_classifier/v2/traffic_light_classifier_mobilenetv2_batch_4.onnx
wget https://awf.ml.dev.web.auto/perception/models/traffic_light_classifier/v2/traffic_light_classifier_mobilenetv2_batch_6.onnx
wget https://awf.ml.dev.web.auto/perception/models/traffic_light_classifier/v2/traffic_light_classifier_efficientNet_b1_batch_1.onnx
wget https://awf.ml.dev.web.auto/perception/models/traffic_light_classifier/v2/traffic_light_classifier_efficientNet_b1_batch_4.onnx
wget https://awf.ml.dev.web.auto/perception/models/traffic_light_classifier/v2/traffic_light_classifier_efficientNet_b1_batch_6.onnx
wget https://awf.ml.dev.web.auto/perception/models/traffic_light_classifier/v3/ped_traffic_light_classifier_mobilenetv2_batch_1.onnx
wget https://awf.ml.dev.web.auto/perception/models/traffic_light_classifier/v3/ped_traffic_light_classifier_mobilenetv2_batch_4.onnx
wget https://awf.ml.dev.web.auto/perception/models/traffic_light_classifier/v3/ped_traffic_light_classifier_mobilenetv2_batch_6.onnx
wget https://awf.ml.dev.web.auto/perception/models/traffic_light_classifier/v2/lamp_labels.txt
wget https://awf.ml.dev.web.auto/perception/models/traffic_light_classifier/v3/lamp_labels_ped.txt
cd ..


# traffic_light_fine_detector
mkdir traffic_light_fine_detector
cd traffic_light_fine_detector
wget https://awf.ml.dev.web.auto/perception/models/tlr_yolox_s/v3/tlr_car_ped_yolox_s_batch_1.onnx
wget https://awf.ml.dev.web.auto/perception/models/tlr_yolox_s/v3/tlr_car_ped_yolox_s_batch_4.onnx
wget https://awf.ml.dev.web.auto/perception/models/tlr_yolox_s/v3/tlr_car_ped_yolox_s_batch_6.onnx
wget https://awf.ml.dev.web.auto/perception/models/tlr_yolox_s/v3/tlr_labels.txt
cd ..