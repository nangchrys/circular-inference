# Circular Inference

Analysis code for Angeletos Chrysaitis et al. 2021


## Index

file                    | description 

master                  | master file: runs all top level scripts (those denoted by * below)
load_questionnaire_data | extracts data from questionnaires.csv
load_experiment_data    | loads questionnaire and task data
fit_lme                 | fits the linear mixed-effects model for absolute confidence
fit_model               | fits a Bayesian model to a participant's data
fit_participants        | uses fit_model on the chosen subsample for the chosen models
recover                 | performs parameter and model recovery for CIR and CINR
cinr_prediction         | calculates CINR prediction
cir_prediction          | calculates CIR prediction
model_mse               | calculates the mean squared error of a Bayesian model
gaussian_bic            | calculates BIC scores assuming Gaussian noise

restrict_probability    | helper function, restricts probabilities to [0.01, 0.99]
logit                   | helper function, calculates $ log (\frac(x)(1-x)) $
expit                   | helper function, calculates $ 1 / (1 + exp(x)) $
signtol                 | helper function, calculates the sign of a number with tolerance


## Instructions

Created in Matlab 2020a, but should work in most earlier versions with no problems

1. clone https://github.com/nangchrys/circular-inference
2. open master.m
3. change variable "datapath" to the filepath for the data folder
4. run any and all of the 4 scripts


## Acknowledgements
CDT Biomedical AI, School of Informatics, University of Edinburgh
