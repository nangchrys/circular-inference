function mse = model_mse(probs, modelOptions, param)
    % Calculates model mean squared error, given parameter values.
    % Notice that there is a small L2 regularisation penalty on the
    % reverberation parameters to prevent "degenerate" solutions with
    % weights close to 0 and artificially large alphas. Model predictions
    % are almost completely insensitive to this added cost.
    %
    % Inputs
    %   probs:          N x 3 numerical array, where N the number of trials
    %                   [priors, likelihoods, confidence] in probabilities
    %   modelOptions:   Cell array, {model, L2 term}. model is one of
    %                   "sb", "wb", "cir", "cinr". L2 term is usuall 0.00005
    %   param:          parameter values of the chosen model, number varies
    %
    % Outputs
    %   mse:            mean squared error
    
    model = modelOptions{1}; regularisationTerm = modelOptions{2};
    prior = probs(:, 1); likelihood = probs(:, 2); confidence = probs(:, 3);
    param = num2cell(expit(param));
    
    switch model
        case 'sb' % Simple Bayes
            [ap, al, wp, wl] = deal(0, 0, 1, 1);
        case 'wb' % Weighted Bayes
            [ap, al] = deal(0, 0); [wp, wl] = param{:};
        otherwise % Circular Inference
            [ap, al, wp, wl] = param{:};
    end
    regularisationPenalty = regularisationTerm * (ap^2 + al^2);
    
    % Gets predictions from each model, given parameter values.
    if strcmp(model, 'cir')
        prediction = cir_prediction(prior, likelihood, ap, al, wp, wl);
    else
        prediction = cinr_prediction(prior, likelihood, ap, al, wp, wl);
    end

    % Models assume Gaussian error in logits, therefore can't handle values
    % too close to 0 or 1. Confidence has been simlarly adjusted.
    prediction = restrictProbability(prediction);
    logitPrediction = logit(prediction);
    logitConfidence = logit(confidence);

    % Calculates MSE with small L2 regularisation term.
    % MSE is chosen, instead of least squares error, so that regularisation
    % strength wouldn't vary with changing number of trials.
    mse = sum((logitConfidence - logitPrediction).^2) / length(prediction) + ...
          regularisationPenalty;

end
