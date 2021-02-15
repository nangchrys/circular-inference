function prediction = nr_prediction(prior, likelihood, param)
% Calculates the prediction of the No Reverberation model.
% To avoid potential numerical issues (e.g. infinite prediction logits)
% this prediction is computed in terms of probability and not logits.
% Turned into logits, it is equivalent to the circular inference model
% equations reported in the text.

alpha_p = param(1); alpha_l = param(2); wp = param(3); wl = param(4);

prior_comp = [prior, 1-prior];
likelihood_comp = [likelihood, 1-likelihood];

% both weights are between 0.5 and 1, as 0.5 basically discards the
% information from the prior/likelihood and 1 keeps it unchanged
wp = 0.5+wp/2;
wl = 0.5+wl/2;

% alphas have no reason to be limited between 0 and 1
% through experimentation we found that 60 is a good max value
alpha_p = alpha_p*60;
alpha_l = alpha_l*60;

% Turns prior and likelihood weights into conditional probability matrix.
wp_matrix=[wp, 1-wp;
           1-wp, wp];
wl_matrix=[wl, 1-wl;
           1-wl, wl];

aprior = expit(logit(prior)*alpha_p);
alikelihood = expit(logit(likelihood)*alpha_l);

f_prior = [aprior, 1-aprior]*wp_matrix;
f_likelihood = [alikelihood, 1-alikelihood]*wl_matrix;

% corrupting/overcounting each signal separately
temp = ((likelihood_comp.*f_likelihood)*wl_matrix).*...
    ((prior_comp.*f_prior)*wp_matrix);

% normalising, i.e. turning into probabilities
prediction = temp(:, 1)./(temp(:, 1)+temp(:, 2));