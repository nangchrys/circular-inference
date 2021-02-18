function [params, modelErrors] = fit_participants(Participants, Options)
    % Runs parameter and models recovery for cir and cinr
    % Inputs
    %   Options:        struct with fit options, see master.m
    %
    %   Participants:   non scalar struct containing probs and
    %                   reaction times for each participant.
    %                   probs = [prior, likelihood, confidence]
    % Outputs
    %   params:         3d array of estimated model parameters in the form
    %                   participants x models x paramaters
    %   modelErrors:    2d array of model mean squared errors in the form
    %                   participants x models
    
    % unpacking
    fitModels = Options.fitModels; regLambda = Options.regLambda;
    nFits = Options.nFits; maxEvals = Options.maxEvals;

    nModels = length(fitModels); nParticipants = length(Participants);
    params = NaN(nParticipants, nModels, 4);
    modelErrors = NaN(nParticipants, nModels);

    for i = 1:nParticipants
        disp("Participant " + int2str(i))
        probs = Participant(i).probs;        

        for k = 1:nModels
            modelOptions = {char(fitModels(k)), regLambda};
            % prm = [ap, al, wp, wl] for cir, cinr
            [prm, err] = fit_model(probs, modelOptions, nFits, maxEvals);
            params(i, k, :) = prm; modelErrors(i, k) = err;
        end
    end

end
