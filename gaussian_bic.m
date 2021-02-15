function bic = gaussian_bic(mse, ntrials, nparams)
    % Calculates an approximation to the Bayesian Information Criterion for
    % normally distributed model errors
    %
    % Inputs
    %   mse:        participant mean squared error
    %   ntrials:    number of accepted trials for each participant
    %   nparams:    number of model parameters
    %
    % Outputs
    %   bic:        BIC approximation

    bic = ntrials .* log(mse) + nparams .* log(ntrials);
end
