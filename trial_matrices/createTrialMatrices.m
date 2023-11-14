% function to create trial matrices
%
% Input the number of trials matrices you want to creat (n) and the first
% subject number (first_sub_num).
%
% The task and categories can be adjusted in first few lines

function [tr_mat, file_list] = createTrialMatrices(first_sub_num, n)

global FILE_POSTFIX expDir

if isempty(FILE_POSTFIX)
    FILE_POSTFIX = '*tif';
end

%% Set constant parameters:
n_pics_per_cate = 50;
n_pics_practice = 10;

% List the tasks.
tasks = ["categorization", "typicality", "familiarity", "aesthetic"];

% Create a structure storing the levels of each of these conditions:
pre_file_list = struct('bathroom', nan(1,n_pics_per_cate), ...
    'kitchen', nan(1,n_pics_per_cate), 'practice', nan(1,n_pics_practice));
file_list = struct("SHINEd", pre_file_list, "raw", pre_file_list);
cateories = ["bathroom", "kitchen", "practice"];
img_types = ["SHINEd", "raw"];

% Get the list of stimuli files
if isempty(expDir)
    currentDirectory = pwd;
    [expDir, ~, ~] = fileparts(currentDirectory);
end

% initialize loop varaibles
textures = (1:1000) + 10;
count = 0;

for type = img_types
    for cate = cateories
        stimuli_path = fullfile(expDir, 'stimuli', type, cate);
        file_list.(type).(cate) = dir(fullfile(stimuli_path, FILE_POSTFIX));
        for t = 1:length(file_list.(type).(cate))
            count = count + 1;
            file_list.(type).(cate)(t).texture = textures(count);
        end
    end
end

% Define trial matrix table
columnNames = ["sub_num", "trial", "block", "task", "is_practice", "category",...
    "image", "texture", "duration","blank", "mask", "mask_dur", "jitter"];
dataTypes = {'double', 'double', 'double', 'string', 'double', 'string',...
    'string', 'double', 'double', 'double', 'double', 'double', 'double'};

% Create an empty table with the specified column names and data types
tr_mat = table('Size', [0, numel(columnNames)], 'VariableNames', columnNames, 'VariableTypes', dataTypes);

% Create the jitter distribution:
jitter_mean = 1;
jitter_min = 0.7;
jitter_max = 2;
exp_dist = makedist("Exponential", "mu", jitter_mean);
jitter_distribution = truncate(exp_dist, jitter_min, jitter_max);

%% Creating the trials table:
for sub_num = first_sub_num:first_sub_num + (n-1)
    for task = tasks

        % Set parameters according to task (durations in ms)
        if strcmp(task, 'categorization')
            repeats = 12;
            pics_per_blk = 50;
            duration = 83.33;
            % images properties are normalized with SHINE toolbox
            img_type = 'SHINEd';
            blank = 33.33;
            mask = 1;
            mask_dur = 83.33;
        else
            repeats = 1;
            pics_per_blk = 25;
            duration = 1500;
            img_type = 'raw';
            blank = 0;
            mask = 0;
            mask_dur = 0;
        end

        % Create an empty table with the specified column names and data types
        task_mat = table('Size', [0, numel(columnNames)], 'VariableNames', columnNames, 'VariableTypes', dataTypes);

        % get all image names and textures
        count = 0;
        for cate = cateories
            % supress warnings (it will complain about the assign values in the
            % table)
            warning('off','all')
            for t = 1:length(file_list.(img_type).(cate))
                count = count + 1;
                task_mat.sub_num(count) = sub_num;
                task_mat.task(count) = task;
                task_mat.image{count} =  file_list.(img_type).(cate)(t).name;
                task_mat.texture(count) =  file_list.(img_type).(cate)(t).texture;
                task_mat.duration(count) =  duration;
                task_mat.blank(count) =  blank;
                task_mat.mask(count) =  mask;
                task_mat.mask_dur(count) =  mask_dur;

                if contains(file_list.(img_type).(cate)(t).name, 'practice')
                    task_mat.is_practice(count) = 1;

                    if contains(task_mat.image{count}, 'kitchen')
                        task_mat.category(count) = 'kitchen';
                    elseif contains(task_mat.image{count}, 'bathroom')
                        task_mat.category(count) = 'bathroom';
                    else
                        task_mat.category(count) = 'unkown';
                    end

                else
                    task_mat.category(count) = cate;
                    task_mat.is_practice(count) = 0;
                end
            end
            % turn back on warnings
            warning('on','all')
        end

        % split task and practice matrix
        practice_mat = task_mat(task_mat.is_practice == 1, :);
        task_mat = task_mat(task_mat.is_practice ~= 1, :);

        % repreat matrix according to number of repeats per image
        task_mat = repmat(task_mat, repeats, 1);

        % shuffle row order
        task_mat = task_mat(randperm(height(task_mat)),:);

        % add block and trial numbers
        practice_mat.block = zeros(height(practice_mat), 1);
        practice_mat.trial = (1:height(practice_mat))';

        task_mat.block = repelem(1:height(task_mat)/pics_per_blk, pics_per_blk)';
        task_mat.trial = repmat(1: pics_per_blk, 1, height(task_mat)/pics_per_blk)';

        % add new task matrix to trial matrix
        tr_mat = vertcat(tr_mat, practice_mat);
        tr_mat = vertcat(tr_mat, task_mat);

    end

    % Add the jitter:
    tr_mat.jitter = random(jitter_distribution, height(tr_mat), 1);

    % Save to file:
    % Create file name:
    target_dir = fullfile(expDir, 'trial_matrices');


    file_name = fullfile(target_dir, sprintf("sub-%d_%s_trials.csv", sub_num, 'wp4_beh'));
    writetable(tr_mat, file_name);

end

