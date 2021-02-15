function [probs, rts] = get_probabilities(raw_data)
    % Transforms participant raw data to probabilities and discards bad trials
    % Inputs
    %   raw_data:   table with fisher task data
    %
    % Outputs
    %   probs:      [priors, likelihoods, confidence] in probabilities. doesn't
    %               include trials where participant didn't click on scale
    %   rts:        reaction times in seconds for all trials

    mousex = table2array(raw_data(12:end, 1));
    mousey = table2array(raw_data(12:end, 2));
    lakenames = char(table2array(raw_data(12:end, 3)));
    rts = table2array(raw_data(12:end, 4));

    angles = atan2d(mousex, mousey + 0.425); % Get angle from mouse coordinates.

    % Trials where participant clicked on scale. 0.415 used instead of 0.425 to
    % give small margin to subjects and account for slightly non-circular scale
    good_trials = mousex.^2 + (mousey + 0.415).^2 > 0.007 & ...
        mousex.^2 + (mousey + 0.415).^2 < 0.055;

    % Selecting good trials and adjusting for non-circularity.
    angles = angles(good_trials) .* (90/94);

    % Getting prior and likelihood values from lake filenames.
    prior = str2num(lakenames(good_trials, 15:16)) / 100;
    likelihood = str2num(lakenames(good_trials, 17:18)) / 100;

    % Transforming response angles to confidence estimates, i.e. probabilities.
    % 0 is full confidence for right lake, 1 for left.
    confidence = -angles / 180 + 0.5;

    % Some participants click slightly below scale, also models can't handle
    % values too close to 1 or 0, due to assummed Gaussian noise in logits
    confidence = max(min(confidence, 0.99), 0.01);

    probs = [prior, likelihood, confidence];
end
