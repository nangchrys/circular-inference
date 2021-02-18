function [Measures, AllParams] = recovery(OriginalParams, OriginalErrors, Options)
    % Runs parameter and models recovery for cir and cinr
    % Inputs
    %   Options:        recovery options, see master.m
    %
    %   originalParams: The parameters estimated from task data. 3d Array
    %                   in the form of Participants x Models x Parameters.
    %   originalErrors: The model errors estimated from task data. 2d Array
    %                   in the form of Participants x Models.
    %
    % Outputs
    %   Measures:       struct with fields 'correlation', 'pvalue', 'confusion'.
    %     correlation:  Contains the Pearson correlation coefficients in the
    %                   form models x parameters, in the input model order.
    %     pvalue:       Contains the corresponding correlation p-values.
    %     confusion:    Contains the proportion of correctly selected models
    %                   for participants generated with each input model.
    %                   Returns [] if only one model is given.
    %   AllParams:      struct with fields 'simulated' and 'recovered',
    %                   containing the corresponding parameters as structs
    %                   with fields 'cir' and 'cinr'.
    
    models = Options.recModels; regLambda = Options.regLambda;
    nFits = Options.nFits; maxEvals = Options.maxEvals;
    nSimulations = Options.nSimulations;

    nModels = length(models);
    
    % initialisation
    if nModels == 2
        Bic = struct('cir', NaN(nSimulations, 2), ... 
                     'cinr', NaN(nSimulations, 2));
        SimulatedParams = struct('cir', NaN(nSimulations, 4), ...
                                 'cinr', NaN(nSimulations, 4));
        RecoveredParams = struct('cir', NaN(nSimulations, 4), ...
                                 'cinr', NaN(nSimulations, 4));
    else
        modelOptions = {char(models), regLambda};
        SimulatedParams = struct(models, NaN(nSimulations, 4));
        RecoveredParams = struct(models, NaN(nSimulations, 4));
    end

    nOriginal = size(OriginalErrors, 1);
    correlation = NaN(nModels, 4); pvalue = NaN(nModels, 4);
    
    % creates the trial set used in the study
    PRIORS = []; LIKELIHOODS = [];

    for p = 0.1:0.1:0.9
        for l = 0.1:0.1:0.9

            if 0.4 <= p + l && p + l <= 1.6 && ~(p == 0.5 && l == 0.5)
                PRIORS = [PRIORS; p];
                LIKELIHOODS = [LIKELIHOODS; l];
                
                % certain trials are repeated
                if ismember(p, [0.3, 0.4, 0.6, 0.7]) || ...
                            ismember(l, [0.3, 0.4, 0.6, 0.7])
                    PRIORS = [PRIORS; p];
                    LIKELIHOODS = [LIKELIHOODS; l];
                end
            end
        end
    end

    nTrials = length(PRIORS);

    for j = 1:nModels
        
        for i = 1:nSimulations % iterates over simulated participants
            
            if mod(i, 50) == 0 || i == 1 % shows progress
                disp("Model: " + models(j) + ", participant: " + int2str(i))
            end

            jOriginalParams = OriginalParams.(models(j));
            jOriginalErrors = OriginalErrors.(models(j));
            
            % gets 4 random parameters
            idx = sub2ind(size(jOriginalParams), randi(nOriginal, 1, 4), 1:4);
            selectedParam = jOriginalParams(idx);
            % adds small noise
            noise = 0.05 * (rand(1, 4) - 0.05);
            sparams = min(max(selectedParam + noise, 0), 1);
            SimulatedParams.(models(j))(i, :) = sparams;
            
            sigma = jOriginalErrors(randi(nOriginal))^0.5;

            % calculates model prediction for simulated participant
            sparams = num2cell(sparams); [ap, al, wp, wl] = sparams{:};
            if strcmp(models(j), 'cir')
                prediction = cir_prediction(PRIORS, LIKELIHOODS, ap, al, wp, wl);
            else
                prediction = cinr_prediction(PRIORS, LIKELIHOODS, ap, al, wp, wl);
            end

            prediction = restrictProbability(prediction);
            logitPrediction = logit(prediction);

            % simulate probability estimations based on the predictions
            % and assuming assuming gaussian noise in their logs
            logitConfidence = logitPrediction + randn([nTrials 1]) * sigma;
            simulatedConfidence = restrictProbability(expit(logitConfidence));
            probs = [PRIORS, LIKELIHOODS, simulatedConfidence];

            % estimate parameters with input models
            if nModels == 2
                cirOptions = {'cir', regLambda};
                [prm(1, :), err] = fit_model(probs, cirOptions, nFits, maxEvals);
                Bic.(models(j))(i, 1) = gaussian_bic(err, nTrials, 4);

                cinrOptions = {'cinr', regLambda};
                [prm(2, :), err] = fit_model(probs, cinrOptions, nFits, maxEvals);
                Bic.(models(j))(i, 2) = gaussian_bic(err, nTrials, 4);
                
                RecoveredParams.(models(j))(i, :) = prm(j, :);

            else
                modelOptions = {char(model), regLambda};
                [prm, ~] = fit_model(probs, modelOptions, nFits, maxEvals);
                RecoveredParams.(models)(i, :) = prm(j, :);
            end

        end

        for k = 1:4 % calculates Pearson correlations
            [r, p] = corrcoef(SimulatedParams.(models(j))(:, k), ...
                         RecoveredParams.(models(j))(:, k));
            correlation(j, k) = r(1, 2);
            pvalue(j, k) = p(1, 2);
        end

    end

    if nModels == 2 % calculates poportion of correctly selected models based on BIC
        correctCIR = (sum(Bic.cir(:, 1) < Bic.cir(:, 2)) + ...
                      sum(Bic.cir(:, 1) == Bic.cir(:, 2)) / 2) / nSimulations;
        correctCINR = (sum(Bic.cinr(:, 1) > Bic.cinr(:, 2)) + ...
                       sum(Bic.cinr(:, 1) == Bic.cinr(:, 2)) / 2) / nSimulations;
        if strcmp(models(j), 'cinr')
            confusion = [correctCINR, correctCIR];
        else
            confusion = [correctCIR, correctCINR];
        end
        
    else
        confusion = [];
    end
    
    Measures = struct('correlation', correlation, 'pvalue', pvalue, ...
                      'confusion', confusion);
    AllParams = struct('simulated', SimulatedParams, ...
                       'recovered', RecoveredParams);

end
