warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames')
% Get priors, likelihoods, and confidence estimates,
% and fit models for all participants

% Options
nfit = 100; % Number of fits with random initialisations
neval = 10000; % MaxEvals option for fminsearch
models = ["ci", "nr"]; % Options: ["sb", "wb", "ci", "nr"]. Leave empty to not fit any.
subsample = 'all'; % To focus on one subsample use "social" or "prolific".

%% Loading data and initialising
disp("Loading data...")
[scores, task_data] = load_experiment_data("data", subsample);

% scores are in the form:
disp("Data loaded.")

nmodels = length(models); n = length(task_data);
ntrials = NaN(n, 1); param = NaN(n, nmodels, 4); err = NaN(n, nmodels);
% all_aq = []; all_pdi = []; all_rts = []; all_id = []; all_probs = [];

%% Preprocessing data and model fitting for each participant i
for i = 1:n
    disp("Participant " + int2str(i))

    file = task_data{i};
    % Getting relevant data for the on scale responses.
    % probs = [prior, likelihood, confidence], rts = reaction times in sec
    [probs, rts] = get_probabilities(file);

    ntrials(i) = size(probs, 1);

    % Used for fit_lme.

    % all_id = [all_id; i*ones(ntrials(i), 1)];
    % all_aq = [all_aq; scores.AQ(i)*ones(ntrials(i), 1)];
    % all_pdi = [all_pdi; scores.PDI(i, 1)*ones(ntrials(i), 1)];
    % all_rts = [all_rts; rts];
    % all_probs = [all_probs; probs];

    for k = 1:nmodels
        % params = [alpha_p, alpha_l, wp, wl] for ci, nr
        [param(i, k, :), err(i, k)] = fit_models(probs, models(k), nfit, neval);
    end

end
