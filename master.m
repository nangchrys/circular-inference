%% Master file for Angeletos Chrysaitis et al., 2021
% used to load both task and questionnaire data (Participants & Scores),
% fit the linear mixed-effects model and the 4 Bayesian models,
% and run parameter and model recovery 
% Options
%   fitModels:      are the models that will be fitted on the data
%                   choose any number from ["sb", "wb", "cir", "cinr"]
%   recModels:      are the models that will be used for model and
%                   parameter recovery. choose either "cir", "cinr" or both
%                   if both, put them IN THE SAME ORDER that they are in
%                   originalParams and originalErrors
%   regLambda:      the coefficient of the regularisation term for
%                   the ap and al parameters of CIR and CINR.
%                   0.00005 was used in the study.
%   nFits:          the number of random initialisations used in the model
%                   fittings (including those happening during recovery).
%   maxEvals:       sets the MaxFunEvals option of fminsearch. 
%   nSimulations:   determines the number of simulated participants used in
%                   model and parameter recovery.
%   subsample:      determines the subsample of participants for
%                   data loading and model fitting. HAS TO BE CHAR TYPE.
%                   choose from 'all', 'prolific', and 'social'.

warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames')

Options = struct('fitModels', ["sb", "wb", "cir", "cinr"], ...
                 'recModels', ["cir", "cinr"], ...
                 'regLambda', 0.00005, ...
                 'nFits', 100, ...
                 'maxEvals', 10000, ...
                 'nSimulations', 1000);

%% Load data
[Participants, Scores, AllData] = load_experiment_data(folder, subsample);

%% Fit LME
lme = fit_lme(AllData);

%% Fit Bayesian models
[params, modelErrors] = fit_participants(Participants, Options);

%% Do parameter and model recovery
originalParams = params; originalErrors = modelErrors;
[Measures, AllParams] = recovery(originalParams, originalErrors, Options);
