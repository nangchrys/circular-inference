function scores = load_questionnaires(folder, subsample)
% extracts the relevant information from the questionnaire answers
% Inputs
%   folder:     the data folder path. assumes that the folder
%               cointains questionnaires.csv.
%   subsample:  "all", "prolific", or "social"
%
% Outputs
%   scores:     struct with fields ASD, AQ, PDI, duration, attention, ids

filename = fullfile(folder, 'questionnaires.csv');
answers = readtable(filename);
answers = answers(strcmp(answers.Cleaning, 'accepted'), :);

% defines first and last rows of the chosen (sub)sample
if strcmp(subsample, 'all')
    first = 1;
    last = height(answers);
elseif strcmp(subsample, 'prolific')
    first = 1;
    last = sum(contains(answers{:, 'ID'}, 'p'));
elseif strcmp(subsample, 'social')
    first = 1 + sum(contains(answers{:, 'ID'}, 'p'));
    last = height(answers);
end

n = last-first+1;

scores = struct(...
            'ASD', NaN(n, 1),...       % autism diagnoses, -1 to 4
            'AQ', zeros(n, 1),...        % AQ total scores
            'PDI', zeros(n, 4),...       % PDI [Y/N, distr, preocc, conv]
            'duration', NaN(n, 1),...  % questionnaire duration in mins
            'attention', NaN(n, 1),... % succesful att. checks out of 2
            'ids', strings(n ,1));     % participsnt IDs

for r = first:last % iterates over chosen subsample participants
    k = r - first + 1; % index of loaded data
    for i = 1:21
        qn = strcat('PDI', string(i));
        % calculates PDI scores
        if strcmp(answers{r, qn}{1}, 'YES')
            scores.PDI(k, :) = scores.PDI(k, :) + [1,...
                answers{r, strcat(qn, '_distress')},...
                answers{r, strcat(qn, '_preoccupation')},...
                answers{r, strcat(qn, '_conviction')}];
        end
    end
    
    % calculates total AQ scores
    for i = [1, 2, 4, 5, 6, 7, 9, 12, 13, 16, 18, 19, 20,...
            21, 22, 23, 26, 33, 35, 39, 41, 42, 43, 45, 46]
        if ismember(answers{r, strcat('AQ', string(i))},...
                ["Slightly Agree", "Definitely Agree"])
            scores.AQ(k) = scores.AQ(k) + 1;
        end
    end
    for i = [3, 8, 10, 11, 14, 15, 17, 24, 25, 27, 28, 29, 30,...
            31, 32, 34, 36, 37, 38, 40, 44, 47, 48, 49, 50]
        if ismember(answers{r, strcat('AQ', string(i))},...
                ["Slightly Disagree", "Definitely Disagree"])
            scores.AQ(k) = scores.AQ(k) + 1;
        end
    end
    
    % codifies answers about ASD diagnosis
    if strcmp(answers{r, 'ASD'}, 'No')
        scores.ASD(k) = -1;
    elseif strcmp(answers{r, 'ASD'},...
        'No - but I identify as being on the autistic spectrum')
        scores.ASD(k) = 1;
    elseif strcmp(answers{r, 'ASD'},...
            'I am in the process of receiving a diagnosis')
        scores.ASD(k) = 2;
    elseif strcmp(answers{r, 'ASD'}, 'Yes - as a child')
        scores.ASD(k) = 3;
    elseif strcmp(answers{r, 'ASD'}, 'Yes - as an adult')
        scores.ASD(k) = 4;
    else
        scores.ASD(k) = 0; % Don't know/rather not say | social subsample
    end
    
    scores.duration(k) = answers{r, 'Duration'}/60;
    scores.attention(k) = answers{r, 'Attention'};
    scores.ids(k) = string(answers{r, 'ID'});
end