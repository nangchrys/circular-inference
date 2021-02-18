function prediction = cinr_prediction(prior, likelihood, ap, al, wp, wl)
    % Calculates the prediction of the Circular Inference - No Reverberation
    % model. To avoid potential numerical issues, this prediction is computed
    % in terms of probabilities and not logits. Turned into logits, it is
    % equivalent to the equations reported in the text.

    priorWithComplement = [prior, 1 - prior];
    likelihoodWithComplement = [likelihood, 1 - likelihood];

    % both weights are between 0.5 and 1, as 0.5 basically discards the
    % information from the prior/likelihood and 1 keeps it unchanged
    wp = 0.5 + wp / 2;
    wl = 0.5 + wl / 2;

    % alphas have no reason to be limited between 0 and 1
    % through experimentation we found that 60 is a good max value
    ap = ap * 60;
    al = al * 60;

    % Turns prior and likelihood weights into conditional probability matrix.
    wpMatrix =    [wp, 1 - wp;
               1 - wp, wp];
    wlMatrix =    [wl, 1 - wl;
               1 - wl, wl];

    amplifiedPrior = expit(logit(prior) * ap);
    amplifiedLikelihood = expit(logit(likelihood) * al);

    fPrior = [amplifiedPrior, 1 - amplifiedPrior] * wpMatrix;
    fLikelihood = [amplifiedLikelihood, 1 - amplifiedLikelihood] * wlMatrix;

    % corrupting/overcounting each signal separately
    posteriorSignal = ((likelihoodWithComplement .* fLikelihood) * wlMatrix) .* ...
                      ((priorWithComplement .* fPrior) * wpMatrix);

    % normalising, i.e. turning into probabilities
    prediction = posteriorSignal(:, 1) ./ ...
                (posteriorSignal(:, 1) + posteriorSignal(:, 2));

end
