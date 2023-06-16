# Pinna Anthropometry Extraction
Extraction of anthropometric features from pinna range images along with pinna landmarks and image features.
The description of the anthropometric parameters and their automatic measurement is reported in [*anthropometry_documentation.pdf*](./anthropometry_documentation.pdf). This repository is part of the method proposed in the following paper:

> Davide Fantini, Federico Avanzini, Stavros Ntalampiras and Giorgio Presti (2023) "Automatic Extraction of Anthropometric Features for the Individualization of the Pinna-Related Transfer Function in the Median Plane"

The ASM algorithm has been implemented with:

> John W. Miller (2023). Face detection with Active Shape Models (ASMs) (https://github.com/johnwmillr/ActiveShapeModels), GitHub. Retrieved April 13, 2023.

Some modifications have been performed to make the code compliant with our needs (no change has been made to the core of the ASM algorithm).

---

Tested with Matlab R2022b.

## How to use
The script [**demo.m**](./scripts/demo.m) provides a simple demonstration of how this repository can be used to obtained a set of pinna features extracted from a pinna range image. The script's workflow is straightforward. First, the configuration parameters are loaded in the structure `cfg`, then the example pinna range images included in the file [*pinna_img_demo.mat*](./pinna_img_demo.mat) are loaded. Then, the function `get_pinna_features` is called. Finally, in the script the function `plot_results` is called to plot the landmarks and the anthropometry on the pinna range images.

The function [**`get_pinna_features`**](./pinna-anthropometry-extraction/get_pinna_features.m) performs all the operations needed to extract the pinna features from the range image. In the follwing, we describe the inputs and the outputs of the function [`get_pinna_features`](./pinna-anthropometry-extraction/get_pinna_features.m):

***INPUT***
 - *REQUIRED*
   - `cfg`: this is the structure containing all the configuration parameters for the repository. You can get it by calling the function [`get_cfg`](./pinna-anthropometry-extraction/get_cfg.m). By editing this function, you can act on the behaviour of the code, for example by changing the parameters of ASM, the anthropometry extraction and image features extraction.
   - `pinna_imgs`: pinna range image(s) from which extract the features. These images must be provided as 3D arrays with shape [# pinna images × height resolution × width resolution].
   The function expects left pinnae depicted in the range images, if you provide right pinnae use the parameter `righ_pinna` to make the code working properly.
   Although, the code can work with images of any resolution and any aspect ratio, it is recommended to provided range images with a resolution and, in particular, an aspect ratio similar to the ones used to train the ASM model (w: 140 × h: 160) to obtain the best results. The provided range images in input are resized without strecthing to best match the resolution 140 × 160.
 - *OPTIONAL*
   - `landmarks` [default: empty]: you can optionally provide the coordinates of the pinna landmarks that will be used to extract the features. The provided landmarks must follow the annotation scheme described in the paper (Fantini et al., 2023). If not specified the landmarks are automatically fitted using the ASM model provided the folder [*models*](./pinna-anthropometry-extraction/models/).
   The landmarks can be provided either as a 2D or a 3D array:
     - If `landmarks` is a 2D array of shape [# pinnae × # landmarks * 2], then the 1st dimension represents the number of pinnae, while the 2nd dimension represent the landmarks $x$ and $y$ coordinates in the form ${x_1, y_1, x_2, y_2, ..., x_K, y_K}$ where $K=167$ is the total number of landmarks.
     - If `landmarks` is a 3D array of shape [# pinnae × # landmarks × 2], then the 1st dimension represents the number of pinnae, the 2nd dimension represents the number of landmarks, while the 3rd dimension represents the $x$ and $y$ coordinates.
    - `xy_scale` [default: 1]: scale factor of the $x$ and $y$ coordinates of the range image. The measurements made in $x$ and $y$ coordinates are multiplied by `xy_scale` to convert them from pixel units to the unit of measurement of your interest (e.g. cm). For example, if in the range images you provides, 1 pixel corresponds to 0.1 cm, setting `xy_scale=0.1` convert the anthropometric measurements from pixels unit to centimenters.
    - `z_scale` [default: 1]: scale factor of the $z$ coordinate. The measurements made in z coordinate are multiplied by this factor to convert them from pixel units to the unit of measurement of your interest (e.g. cm).
    - `right_pinna` [default: false]: it is a boolean array of shape [# pinnae] with one element for each pinna indicating whether in the provided images are represented right pinnae. For the true elements, the corresponding pinna image is mirrored. This is needed to ensure the code works properly.

***OUTPUT***
 - `anthropometry`: table of shape [# pinna images × # anthropometry] with the measured anthropometry. The columns represent the anthropometric parameters, while the rows represent the pinnae.
 - `landmarks`: fitted landmarks with $x$, $y$ and $z$ coordinates returned as a 3D array of shape [# pinna images × # landmarks X 3 coordinates]. If you provided `landmarks` in input, the output is the same with the $z$ coordinates values in addition.
 - `img_features`: table of shape [# pinna images × # image features] with extracted image features.



## Repository structure
 - [*anthropometry_documentation.pdf*](./anthropometry_documentation.pdf): documentation of the pinna anthropometry extraction implemented in this repository
 - [*pinna_img_demo.mat*](./pinna_img_demo.mat): *mat* file including the left and right pinnae range images of the subject with ID 3 in [HUTUBS dataset](https://depositonce.tu-berlin.de/items/dc2a3076-a291-417e-97f0-7697e332c960)
 - [*scripts*](./scripts/)
	 - [*demo.m*](./scripts/demo.m): demo of how the repository works. Execute this script to get the features of the pinna range images in [*pinna_img_demo.mat*](./pinna_img_demo.mat) file.
 - [*pinna-anthropometry-extraction*](./pinna-anthropometry-extraction/)
     - [*get_pinna_features.m*](./pinna-anthropometry-extraction/get_pinna_features.m): core funtion for the extraction of pinna anthropometry, landmarks and image features
     - [*get_cfg.m*](./pinna-anthropometry-extraction/get_cfg.m): function to get the configuration structure. Modify the variables in this configuration to change the code behavior.
     - [*core*](./pinna-anthropometry-extraction/core/): folder of the main functions to extract the pinna features
       - [*fit_landmarks.m*](./pinna-anthropometry-extraction/core/fit_landmarks.m): function to fit the pinna landmarks with ASM
       - [*measure_anthropometry.m*](./pinna-anthropometry-extraction/core/measure_anthropometry.m): function to measure the pinna anthropometry given the landmarks
       - [*extract_img_features.m*](./pinna-anthropometry-extraction/core/extract_img_features.m): function to extract the image features for the pinna cavities
       - [*get_cavity_info.m*](./pinna-anthropometry-extraction/core/get_cavity_info.m): function to extract the information needed for the pinna cavities
       - [*pinna_images_preprocessing.m*](./pinna-anthropometry-extraction/core/pinna_images_preprocessing.m): function to pre-process the pinna range images
     - [*models*](./pinna-anthropometry-extraction/models/): folder of the ASM model
     - [*plot*](./pinna-anthropometry-extraction/plot/): folder of the visualization functions
	   - [*plot_results.m*](./pinna-anthropometry-extraction/plot/plot_results.m): plot the results obtained with the features extraction from the pinna range image
       - [*plot_landmarks_on_images.m*](./pinna-anthropometry-extraction/plot/plot_landmarks_on_images.m): plot the given landmarks on a range image
     - [*third-party*](./pinna-anthropometry-extraction/third-party/): folder of the third-party code
       - [*johnwmillr-ActiveShapeModels-e43d1f2*](./pinna-anthropometry-extraction/third-party/johnwmillr-ActiveShapeModels-e43d1f2/): ASM code retireved and adapted from [Matlab File Exchange by John W. Miller](https://it.mathworks.com/matlabcentral/fileexchange/62766-face-detection-with-active-shape-models-asms)
     - [*utils*](./pinna-anthropometry-extraction/utils/): folder of utility functions