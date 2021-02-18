function lme = fit_lme(AllData)
    % Fits a linear mixed effects model

    pp = AllData.probs(:, 1); ll = AllData.probs(:, 2);
    confidence = AllData.probs(:, 3);
    aq = AllData.aq; pdi = AllData.pdi; id = AllData.id;
    rts = AllData.reactionTimes;

    absLl = abs(ll - 0.5); % absolute likelihood
    congruency = (pp - 0.5) .* signtol(ll - 0.5, 1e-5); % prior congruency
    absConfidence = abs(confidence - 0.5); % absolute confidence

    tbl = table(absConfidence, absLl, congruency, aq, pdi, rts, id);

    % random effects: participants
    lme = fitlme(tbl, ...
        'absConfidence ~ absLl + congruency + aq + pdi + rts + (1|id)');
end
