function lme = fit_lme(probs, rts, aq, pdi, id)
    % Fits a linear mixed effects model

    pp = probs(:, 1); ll = probs(:, 2); confidence = probs(:, 3);

    abs_ll = abs(ll - 0.5); % absolute likelihood
    congruency = (pp - 0.5) .* signtol(ll - 0.5, 1e-5); % prior congruency
    abs_confidence = abs(confidence - 0.5); % absolute confidence

    tbl = table(abs_confidence, abs_ll, congruency, aq, pdi, rts, id);

    % random effects: participants
    lme = fitlme(tbl, ...
        'abs_confidence ~ abs_ll + congruency + aq + pdi + rts + (1|id)');
end
