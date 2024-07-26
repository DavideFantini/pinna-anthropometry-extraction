# Pinna Anthropometry Extraction
Extraction of anthropometric features from pinna landmarks and depth images.
The description of the anthropometric parameters and their automatic measurement is reported in [*anthropometry_documentation.pdf*](./anthropometry_documentation.pdf).

This repository is part of the following [paper](https://smcnetwork.org/smc2024/papers/SMC2024_paper_id141.pdf):
>Davide Fantini, Federico Avanzini, Stavros Ntalampiras and Giorgio Presti (2024) "Toward a Novel Set of Pinna Anthropometric Features for Individualizing Head-Related Transfer Functions", In *Proceedings of the 21st Sound and Music Computing Conference*. Sound and Music Computing Network.

The supplementary research data for the paper are included in this repository are available in the public repository [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10805884.svg)](https://doi.org/10.5281/zenodo.10805884)

Tested with Matlab R2023b.



## How to use
The script [**pinna_anthropometry_extraction_demo.m**](./scripts/pinna_anthropometry_extraction_demo.m) provides a simple demonstration of how this repository can be used to obtained a set of pinna anthropometric parameters extracted from a pinna landmarks and range depth images. The script's workflow is straightforward. First, the configuration parameters are loaded in the structure `cfg`, then the example pinna landmarks and depth images included in the file [*pinna_demo.mat*](./pinna_demo.mat) are loaded. Then, the function [`get_pinna_anthropometry`](./pinna-anthropometry-extraction/get_pinna_anthropometry.m) is called. Finally, in the script the function [`plot_results.m`](./pinna-anthropometry-extraction/plot/plot_results.m) is called to plot the landmarks and the anthropometry on the pinna range images.

The function [**`get_pinna_anthropometry`**](./pinna-anthropometry-extraction/get_pinna_anthropometry.m) performs all the operations needed to extract the pinna features from the range image. In the follwing, we describe the inputs and the outputs of the function [`get_pinna_anthropometry`](./pinna-anthropometry-extraction/get_pinna_anthropometry.m):

***INPUT***
 - *REQUIRED*
   - `cfg`: this is the structure containing all the configuration parameters for the repository. You can get it by calling the function [`get_cfg.m`](./pinna-anthropometry-extraction/get_cfg.m). By editing this function, you can act on the behaviour of the code, for example by changing the parameters of the anthropometry measurement.
   - `pinna_images`: pinna depth image(s) from which measure anthropometry. These images must be provided as 3D arrays with shape [# pinna images × height resolution × width resolution].
   - `landmarks`: the coordinates of the $K=205$ pinna landmarks used to measure anthropometry. The provided landmarks must follow the annotation scheme described in the paper (Fantini et al., 2024).
   The landmarks can be provided either as a 2D or a 3D array:
     - If `landmarks` is a 2D array of shape [# pinnae × # landmarks * 2], then the 1st dimension represents the number of pinnae, while the 2nd dimension represent the landmarks $x$ and $y$ coordinates in the form ${x_1, y_1, x_2, y_2, ..., x_K, y_K}$ where $K=205$ is the total number of landmarks.
     - If `landmarks` is a 3D array of shape [# pinnae × # landmarks × 2], then the 1st dimension represents the number of pinnae, the 2nd dimension represents the number of landmarks, while the 3rd dimension represents the $x$ and $y$ coordinates.
- *OPTIONAL*
    - `xy_scale` [default: 1]: scale factor of the $x$ and $y$ coordinates of the range image. The measurements made in $x$ and $y$ coordinates are multiplied by `xy_scale` to convert them from pixel units to the unit of measurement of your interest (e.g. cm). For example, if in the range images you provides, 1 pixel corresponds to 0.1 cm, setting `xy_scale=0.1` convert the anthropometric measurements from pixels unit to centimenters.
    - `z_scale` [default: 1]: scale factor of the $z$ coordinate. The measurements made in z coordinate are multiplied by this factor to convert them from pixel units to the unit of measurement of your interest (e.g. cm).

***OUTPUT***
 - `anthropometry`: table of shape [# pinna images × # anthropometry] with the measured anthropometry. The columns represent the anthropometric parameters, while the rows represent the pinnae.
 - `landmarks`: landmarks with $x$, $y$ and $z$ coordinates returned as a 3D array of shape [# pinna images × # landmarks X 3 coordinates]. If you provided `landmarks` in input, the output is the same with the $z$ coordinates values in addition.
 - `info`: struct including information on pinna components



## Repository structure
 - [*anthropometry_documentation.pdf*](./anthropometry_documentation.pdf): documentation of the pinna anthropometry extraction implemented in this repository
 - [*pinna_img_demo.mat*](./pinna_img_demo.mat): *mat* file including the left and right pinnae range images of the subject with ID 3 in [HUTUBS dataset](https://depositonce.tu-berlin.de/items/dc2a3076-a291-417e-97f0-7697e332c960)
 - [*scripts*](./scripts/)
     - [*pinna_anthropometry_extraction_demo.m*](./scripts/pinna_anthropometry_extraction_demo.m): demo of how the repository works. Execute this script to measure the anthropometry for the pinna depth images in [*pinna_img_demo.mat*](./pinna_img_demo.mat) file.
     - [*mesh2image_HUTUBS.m*](./scripts/mesh2image_HUTUBS.m): script used to convert the HUTUBS 3D head meshes into pinna range images 
 - [*pinna-anthropometry-extraction*](./pinna-anthropometry-extraction/)
     - [*get_pinna_anthropometry.m*](./pinna-anthropometry-extraction/get_pinna_anthropometry.m): core funtion for the extraction of pinna anthropometry
     - [*get_cfg.m*](./pinna-anthropometry-extraction/get_cfg.m): function to get the configuration structure. Modify the variables in this configuration to change the code behavior.
     - [*core*](./pinna-anthropometry-extraction/core/): folder of the main functions to extract the pinna anthropometry
       - [*measure_anthropometry.m*](./pinna-anthropometry-extraction/core/measure_anthropometry.m): function to measure the pinna anthropometry given the landmarks
       - [*get_cavity_info.m*](./pinna-anthropometry-extraction/core/get_cavity_info.m): function to extract the information needed for the pinna cavities
     - [*plot*](./pinna-anthropometry-extraction/plot/): folder of the visualization functions
       - [*plot_results.m*](./pinna-anthropometry-extraction/plot/plot_results.m): plot the results obtained from anthropometric measurement for the pinna depth image
       - [*plot_landmarks_on_images.m*](./pinna-anthropometry-extraction/plot/plot_landmarks_on_images.m): plot the given landmarks on a depth image
     - [*utils*](./pinna-anthropometry-extraction/utils/): folder of utility functions

## How to cite
If you use this code, please cite the following [paper](https://smcnetwork.org/smc2024/papers/SMC2024_paper_id141.pdf):
```
@inproceedings{fantini2024toward,
  title={Toward a Novel Set of Pinna Anthropometric Features for Individualizing Head-Related Transfer Functions},
  author={Fantini, Davide and Ntalampiras, Stavros and Presti, Giorgio and Avanzini, Federico},
  booktitle={Proceedings of the 21st Sound and Music Computing Conference},
  year={2024},
  month={July},
  organization={Sound and Music Computing Network},
  url={https://smcnetwork.org/smc2024/papers/SMC2024_paper_id141.pdf}
}
```

## Acknowledgments
This work is part of [SONICOM](https://www.sonicom.eu/), a project that has received funding from the European Union’s Horizon 2020 research and innovation programme under grant agreement [No 101017743](https://doi.org/10.3030/101017743).