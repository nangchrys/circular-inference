function [scores, task_data] = load_experiment_data(folder, subsample)
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

scores = load_questionnaires(folder, subsample);

% get the filelist corresponding to the chosen (sub)sample
if strcmp(subsample, 'all')
    filelist = dir(fullfile(folder, 'accepted\*.csv'));
elseif strcmp(subsample, 'prolific')
    filelist = dir(fullfile(folder, 'accepted\p*.csv'));
elseif strcmp(subsample, 'social')
    filelist = dir(fullfile(folder, 'accepted\s*.csv'));
end

n = length(filelist);
task_data = cell(n, 1);

for i = 1:n
    filename = strcat(scores.ids(i), '.csv');
    file = readtable(fullfile(folder, 'accepted', filename));
    % get table with positions of the mouse, names of the leftLake file
    % (has prior & likelihood information), reaction times, break times
    file = file(end-141:end-1, ["mouse_x", "mouse_y", "leftLake",...
                                "mouse_time", "space1_rt", "space2_rt"]);
    task_data{i} = file;
end
end