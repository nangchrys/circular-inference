function mse = model_mse(probs, model, param)
% Calculates model mean squared error, given parameter values.
% Notice that there is a small regularisation term on the
% overcounting/reverberation parameters to prevent "degenerate"
% solutions with weights close to 0 and artificially large alphas. Model
% predictions are almost completely insensitive to this added cost.
%
% Inputs
%   probs:      N x 3 numerical array, where N the number of trials
%               [priors, likelihoods, confidence] in probabilities
%   model:      the model, one of "sb", "wb", "ci", "nr"
%   param:      parameter values of the chosen model, number varies
%
% Outputs
%   MSE:        mean squared error

prior = probs(:, 1); likelihood = probs(:, 2); confidence = probs(:, 3);

% Gets predictions from each model, given parameter values.
if strcmp(model, 'sb') % Simple Bayes
    param = [0, 0, 1, 1];
    prediction = nr_prediction(prior, likelihood, param);
elseif strcmp(model, 'wb') % Weighted Bayes
    param = [0, 0, expit(param)];
    prediction = nr_prediction(prior, likelihood, param);
elseif strcmp(model, 'ci') % Circular Inference
    param = expit(param);
    prediction = ci_prediction(prior, likelihood, param);
elseif strcmp(model, 'nr') % No Reverberation
    param = expit(param);
    prediction = nr_prediction(prior, likelihood, param);
end

% Models assume Gaussian error in logits, therefore can't handle values
% too close to 0 or 1. Confidence has been simlarly adjusted.
prediction = min(max(prediction, 0.01), 0.99);
logit_prediction = logit(prediction);
logit_input = logit(confidence);

% Calculates MSE with small L2 regularisation term.
% MSE is chosen, instead of least squares error, so that regularisation
% strength wouldn't vary with changing number of trials.
mse = sum((logit_input - logit_prediction).^2)/length(prediction) + ...
    0.00005*param(1)^2 + 0.00005*param(2)^2; % very small penalty term