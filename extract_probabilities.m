function [probs, reactionTimes] = extract_probabilities(rawData)
    % Transforms participant raw data to probabilities and discards bad trials
    % Inputs
    %   rawData:        table with fisher task data from load_experiment_data.m
    %
    % Outputs
    %   probs:          [priors, likelihoods, confidence] in probabilities. Does
    %                   not include trials where participant didn't click on scale
    %   reactionTimes:  reaction times in seconds for all trials
    
    INNER_RADIUS = 0.0837; OUTER_RADIUS = 0.2345;
    SCALE_CENTRE_Y = -0.425; ADJUSTED_CENTRE_Y = -0.415;
    
    % first 11 rows are ignored, as they contain the training trials
    mouseX = table2array(rawData(12:end, 1));
    mouseY = table2array(rawData(12:end, 2));
    lakenames = char(table2array(rawData(12:end, 3)));
    reactionTimes = table2array(rawData(12:end, 4));

    % Get angle from mouse coordinates.
    angles = atan2d(mouseX, mouseY - SCALE_CENTRE_Y);

    % Trials where participant clicked on scale. Using adjusted centre y to
    % give small margin to subjects and account for slightly non-circular scale
    distFromCentre = sqrt(mouseX.^2 + (mouseY - ADJUSTED_CENTRE_Y).^2);
    goodTrials = INNER_RADIUS < distFromCentre & distFromCentre < OUTER_RADIUS;

    % Selecting good trials and adjusting for non-circularity.
    angles = angles(goodTrials) .* (90/94);

    % Getting prior and likelihood values from lake filenames.
    prior = str2num(lakenames(goodTrials, 15:16)) / 100;
    likelihood = str2num(lakenames(goodTrials, 17:18)) / 100;

    % Transforming response angles in [-90, 90] to confidence estimates,
    % i.e. probabilities. 0 is full confidence for right lake, 1 for left.
    confidence = -angles / 180 + 0.5;

    % Some participants click slightly below scale, also models can't handle
    % values too close to 1 or 0, due to assummed Gaussian noise in logits
    confidence = restrictProbability(confidence);

    probs = [prior, likelihood, confidence];
end
