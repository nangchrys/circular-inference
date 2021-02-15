function L = logit(p)
% Log-odds ration, transforms (0, 1) inputs to (-Inf, Inf) outputs

L = log(p./(1-p));