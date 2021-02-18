function [bestParam, minError] = fit_model(probs, modelOptions, nFits, maxEvals)
    % Fits models by minimising mean squared error.
    % Equivalent to least squares.
    
    model = modelOptions{1}; regularisationTerm = modelOptions{2};
    
    if strcmp(model, 'sb')
        bestParam = []; % Simple Bayes doesn't have any free parameters.
        minError = model_mse(probs, model, []);

    else
        if strcmp(model, 'wb')
            nParam = 2; % [wp, wl]
        else
            nParam = 4; % [ap, al, wp, wl]
        end

        param = zeros(nFits, nParam); fval = zeros(nFits, 1);
        searchOptions = optimset('MaxFunEvals', maxEvals, 'Display', 'off');

        for i = 1:nFits % run nFits random initialisations
            [param(i, :), fval(i)] = fminsearch(@(x) ...
                                     model_mse(probs, modelOptions, x), ...
                                     rand(1, nParam) - 0.5, searchOptions);
        end

        [minError, bestIdx] = min(fval); % get best fit

        % transform parameters to range [0, 1]
        if strcmp(model, 'wb')
            bestParam = [0, 0, expit(param(bestIdx, :))];
        else
            bestParam = expit(param(bestIdx, :));

            % remove regularisation adjustment from error
            minError = minError - regularisationTerm * bestParam(1)^2 - ...
                                  regularisationTerm * bestParam(2)^2;
        end
    end

end
