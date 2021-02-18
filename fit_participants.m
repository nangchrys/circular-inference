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
    params = struct; modelErrors = struct;

    for i = 1:nParticipants
        disp("Participant " + int2str(i))
        probs = Participants(i).probs;        

        for k = 1:nModels
            modelOptions = {char(fitModels(k)), regLambda};
            % prm = [ap, al, wp, wl] for cir, cinr
            [prm, err] = fit_model(probs, modelOptions, nFits, maxEvals);
            params.(fitModels(k))(i, :) = prm;
            modelErrors.(fitModels(k))(i) = err;
        end
    end

end
