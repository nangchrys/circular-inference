function [Participants, Scores, AllData] = load_experiment_data(folder, subsample)
    % gets questionnaire and fisher task data for prescreening and analysis
    % Inputs
    %   folder:     the data folder path. assumes that the folder cointains
    %               questionnaires.csv and the 'accepted' folder, with the
    %               selected participants csv.
    %   subsample:  "all", "prolific", or "social"
    %
    % Outputs
    %   scores:     struct from load questionnaires
    %   task_data:  cell array with fisher task data, with participants in the
    %               same order as in scores

    Scores = load_questionnaires(folder, subsample);
    
    SELECTED_COLUMNS = ["mouse_x", "mouse_y", "leftLake", ...
                        "mouse_time", "space1_rt", "space2_rt"];

    % get the filelist corresponding to the chosen (sub)sample
    switch subsample
        case 'all'
            filelist = dir(fullfile(folder, 'accepted\*.csv'));
        case 'prolific'
            filelist = dir(fullfile(folder, 'accepted\p*.csv'));
        case 'social'
            filelist = dir(fullfile(folder, 'accepted\s*.csv'));
    end
    
    AllData = struct('aq', [], 'pdi', [], 'reactionTimes', [], ...
                     'id', [], 'probs', []);
    nParticipants = length(filelist);

    for i = 1:nParticipants
        filename = strcat(Scores.id(i), '.csv');
        file = readtable(fullfile(folder, 'accepted', filename));
        % get table with positions of the mouse, names of the leftLake file
        % (has prior & likelihood information), reaction times, break times
        taskData = file(end - 141:end - 1, SELECTED_COLUMNS);
        [probs, reactionTimes] = extract_probabilities(taskData);
        
        Participants(i).probs = probs;
        participants(i).reactionTimes = reactionTimes;

        nTrials = size(probs, 1);

        AllData.id = [AllData.id; i * ones(nTrials, 1)];
        AllData.aq = [AllData.aq; Scores.aq(i) * ones(nTrials, 1)];
        AllData.pdi = [AllData.pdi; Scores.pdi(i, 1) * ones(nTrials, 1)];
        AllData.reactionTimes = [AllData.reactionTimes; reactionTimes];
        AllData.probs = [AllData.probs; probs];
    end

end
