function [confusion, corrs] = recovery(model, nsims, or_params, or_errors)

nfits = 100; nevals = 10000;

if model == "both"
    model = ["ci", "nr"];
    nmodels = 2;
    bic = struct;
    bic.ci = NaN(nsims, 2);
    bic.nr = NaN(nsims, 2);
else
    nmodels = 1;
end
or_n = size(or_errors, 1);
corrs = NaN(nmodels, 4);

priors = [];
likelihoods = [];

for i=1:9
    for j=1:9
        if i+j>=4 && i+j<=16 && ~(i==5 && j==5)
            priors = [priors; i/10];
            likelihoods = [likelihoods; j/10];
            if ismember(i, [3, 4, 6, 7]) || ismember(j, [3, 4, 6, 7])
                priors = [priors; i/10];
                likelihoods = [likelihoods; j/10];
            end
        end
    end
end

% for i=[0.1 0.2 0.3 0.4 0.5 0.5 0.6 0.7 0.8 0.9]
%     for j=[0.1 0.2 0.3 0.4 0.5 0.5 0.6 0.7 0.8 0.9]
%         priors = [priors; i];
%         likelihoods = [likelihoods; j];
%     end
% end

ntrials = length(priors);

% iterate over simulated participants
for j = 1:nmodels
    sim_params = NaN(nsims, 4);
    rec_params = NaN(nsims, 4);

for i = 1:nsims
    if mod(i, 50) == 0 || i == 1
        disp("Model: "+model(j)+", participant: "+int2str(i))
    end
    
    if nmodels == 2
        or_params = squeeze(or_params(:, j, :));
        or_errors = squeeze(or_errors(:, j, :));
    else
        or_params = squeeze(or_params);
        or_errors = squeeze(or_errors);
    end
    
    sparam = [or_params(randi(or_n), 1), or_params(randi(or_n), 2)...
        or_params(randi(or_n), 3), or_params(randi(or_n), 4)];
    
    sim_params(i, :) = min(max(sparam + 0.05*(rand(1, 4)-0.5), 0), 1);

    sigma = or_errors(randi(or_n))^0.5;
    
    % calculate prediction
    if j == 1
        prediction = ci_prediction(priors, likelihoods, sim_params(i, :));
    else
        prediction = nr_prediction(priors, likelihoods, sim_params(i, :));
    end
    
    prediction = max(min(prediction, 0.99), 0.01);
    logit_prediction = logit(prediction);
    
    % simulate probability estimations based on the predictions
    % and assuming assuming gaussian noise in their logs
    logit_input = logit_prediction + randn([ntrials 1])*sigma;
    expit_input = expit(logit_input);
    simulated_input = max(min(expit_input, 0.99), 0.01);
    probs = [priors, likelihoods, simulated_input];
    
    % estimate parameters with all models
    if nmodels == 2
        if j == 1
            [rec_params(i, :), error] = fit_models(probs, "ci", nfits, nevals);
            bic.ci(i, 1) = gaussian_bic(error, ntrials, 4);
            
            [~, error] = fit_models(probs, "nr", nfits, nevals);
            bic.ci(i, 2) = gaussian_bic(error, ntrials, 4);
        else
            [~, error] = fit_models(probs, "ci", nfits, nevals);
            bic.nr(i, 1) = gaussian_bic(error, ntrials, 4);
            
            [rec_params(i, :), error] = fit_models(...
                probs, "nr", nfits, nevals);
            bic.nr(i, 2) = gaussian_bic(error, ntrials, 4);
        end
    else
        [rec_params(i, :), ~] = fit_models(probs, model(j), nfits, nevals);
    end
    
end
    for k=1:4
        r = corrcoef(sim_params(:, k), rec_params(:, k));
        corrs(j, k) = r(1, 2);
    end
end
if nmodels == 2
    correct_ci = (sum(bic.ci(:, 1) < bic.ci(:, 2)) +...
        sum(bic.ci(:, 1) == bic.ci(:, 2))/2) / nsims;
    correct_nr = (sum(bic.nr(:, 1) > bic.nr(:, 2)) +...
        sum(bic.nr(:, 1) == bic.nr(:, 2))/2) / nsims;
    confusion = [correct_ci, correct_nr];
else
    confusion = [];
end
end