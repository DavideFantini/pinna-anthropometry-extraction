# Pinna Anthropometry Extraction
Extraction of anthropometric features from pinna range images along with pinna landmarks and image features.
These features are extracted according to the method proposed in the following paper:

> Davide Fantini, Federico Avanzini, Stavros Ntalampiras and Giorgio Presti (2023) "Novel Anthropometric Pinna Features for Head-Related Transfer Function Individualization"

The ASM algorithm has been implemented with:

> John W. Miller (2023). Face detection with Active Shape Models (ASMs) (https://github.com/johnwmillr/ActiveShapeModels), GitHub. Retrieved April 13, 2023.

Some modifications have been performed to make the code compliant with our needs (no change has been made to the core of the ASM algorithm).

---

Tested with Matlab R2022b.

## Repository structure
 - *scripts*
	 - *demo.m*: demo of how the repository works. Execute this script to get the features of the pinna range image in *pinna_img_demo.mat* file.
 - *pinna-anthropometry-extraction*
	 - *get_pinna_features.m*: core funtion for the extraction of pinna anthropometry, landmarks and image features
	 - *get_cfg.m*: function to get the configuration structure. Modify this configuration to change the code behavior.
	 - *core*: folder of the main functions to extract the pinna features
	   - *fit_landmarks.m*: function to fit the pinna landmarks with ASM
	   - *measure_anthropometry.m*: function to measure the pinna anthropometry given the landmarks
	   - *extract_img_features.m*: function to extract the image features for the pinna cavities
	   - *get_cavity_info.m*: function to extract the information needed for the pinna cavities
	   - *pinna_images_preprocessing.m*: function to pre-process the pinna range images
	 - *models*: folder of the ASM model
	 - *plot*: folder of the visualization functions
	   - *plot_landmarks_on_images.m*: plot the given landmarks on a range image
	   - *plot_results.m*: plot the results obtained with the features extraction from the pinna range image
	 - *third-party*: folder of the third-party code
	   - *johnwmillr-ActiveShapeModels-e43d1f2*: ASM code retireved and adapted from [Matlab File Exchange by John W. Miller](https://it.mathworks.com/matlabcentral/fileexchange/62766-face-detection-with-active-shape-models-asms)
	 - *utils*: folder of utility functions