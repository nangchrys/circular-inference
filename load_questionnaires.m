function Scores = load_questionnaires(folder, subsample)
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
    switch subsample
        case 'all'
            first = 1;
            last = height(answers);
        case 'prolific'
            first = 1;
            last = sum(contains(answers{:, 'ID'}, 'p'));
        case 'social'
            first = 1 + sum(contains(answers{:, 'ID'}, 'p'));
            last = height(answers);
    end

    n = last - first + 1;

    Scores = struct(...
                'asd', NaN(n, 1), ...       % autism diagnoses, -1 to 4
                'aq', zeros(n, 1), ...        % AQ total scores
                'pdi', zeros(n, 4), ...       % PDI [Y/N, distr, preocc, conv]
                'durationSec', NaN(n, 1), ...  % questionnaire duration
                'attention', NaN(n, 1), ... % succesful att. checks out of 2
                'ids', strings(n ,1));     % participsnt IDs

    for row = first:last % iterates over chosen subsample participants
        k = row - first + 1; % index of loaded data
        for i = 1:21
            qn = strcat('PDI', string(i));
            % calculates PDI scores
            if strcmp(answers{row, qn}{1}, 'YES')
                Scores.pdi(k, :) = Scores.pdi(k, :) + [1,...
                    answers{row, strcat(qn, '_distress')},...
                    answers{row, strcat(qn, '_preoccupation')},...
                    answers{row, strcat(qn, '_conviction')}];
            end
        end

        % calculates total AQ scores
        for i = [1, 2, 4, 5, 6, 7, 9, 12, 13, 16, 18, 19, 20,...
                21, 22, 23, 26, 33, 35, 39, 41, 42, 43, 45, 46]
            if ismember(answers{row, strcat('AQ', string(i))},...
                    ["Slightly Agree", "Definitely Agree"])
                Scores.aq(k) = Scores.aq(k) + 1;
            end
        end
        for i = [3, 8, 10, 11, 14, 15, 17, 24, 25, 27, 28, 29, 30,...
                31, 32, 34, 36, 37, 38, 40, 44, 47, 48, 49, 50]
            if ismember(answers{row, strcat('AQ', string(i))},...
                    ["Slightly Disagree", "Definitely Disagree"])
                Scores.aq(k) = Scores.aq(k) + 1;
            end
        end

        % codifies answers about ASD diagnosis
        switch char(answers{row, 'ASD'})
            case 'No'
                Scores.asd(k) = -1;
            case 'No - but I identify as being on the autistic spectrum'
                Scores.asd(k) = 1;
            case 'I am in the process of receiving a diagnosis'
                Scores.asd(k) = 2;
            case 'Yes - as a child'
                Scores.asd(k) = 3;
            case 'Yes - as an adult'
                Scores.asd(k) = 4;
            otherwise
                Scores.asd(k) = 0; % Don't know/rather not say | social subsample
        end

        Scores.durationSec(k) = answers{row, 'Duration'};
        Scores.attention(k) = answers{row, 'Attention'};
        Scores.ids(k) = string(answers{row, 'ID'});
    end
    
end