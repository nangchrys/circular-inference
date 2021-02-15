function [best_param, err] = fit_models(probs, model, nfits, nevals)
    % Fits models by minimising mean squared error. Equivalent to least squares

    if strcmp(model, 'sb')
        best_param = []; % Simple Bayes doesn't have any free parameters.
        err = model_mse(probs, model, []);

    else

        if strcmp(model, 'wb')
            nparam = 2; % [wp, wl]
        else
            nparam = 4; % [alpha_p, alpha_l, wp, wl]
        end

        param = zeros(nfits, nparam); fval = zeros(nfits, 1);
        search_opts = optimset('MaxFunEvals', nevals, 'Display', 'off');

        for i = 1:nfits% run nfits random initialisations
            [param(i, :), fval(i)] = fminsearch(@(x) model_mse(probs, model, x), ...
                rand(1, nparam) - 0.5, search_opts);
        end

        [err, idx] = min(fval); % get best fit

        % transform parameters to range [0, 1]
        if strcmp(model, "wb")
            best_param = [0, 0, expit(param(idx, :))];
        else
            best_param = expit(param(idx, :));

            % remove regularisation adjustment from error
            err = err - 0.00005 * best_param(1)^2 - 0.00005 * best_param(2)^2;
        end

    end
