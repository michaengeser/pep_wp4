% function to create trial matrices 
%
% Input the number of trials matrices you want to creat (n) and the first 
% subject number (first_sub_num).
%
% The task and categories can be adjusted in first few lines

function [tr_mat, file_list] = createTrialMatrices(first_sub_num, n)

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
file_postfix = '*tif';

% Get the list of stimuli files
currentDirectory = pwd;
[parentDirectory, ~, ~] = fileparts(currentDirectory);

% initialize loop varaibles
textures = (1:1000) + 10;
count = 0;

for type = img_types
    for cate = cateories
        stimuli_path = fullfile(parentDirectory, 'stimuli', type, cate);
        file_list.(type).(cate) = dir(fullfile(stimuli_path,file_postfix));
        for t = 1:length(file_list.(type).(cate))
        count = count + 1;
            file_list.(type).(cate)(t).texture = textures(count);
        end
    end
end

% Define trial matrix table
columnNames = ["sub_num", "trial", "block", "task", "is_practice", "category", "image", "texture", "duration", "jitter"];
dataTypes = {'double', 'double', 'double', 'string', 'double', 'string', 'string', 'double', 'double', 'double'};

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

    % How many repeats per picture
    if strcmp(task, 'categorization')
        repeats = 12;
        pics_per_blk = 50;
        duration = 83.33;
        % images properties are normalized with SHINE toolbox
        img_type = 'SHINEd';
    else
        repeats = 1;
        pics_per_blk = 25;
        duration = 1500;
        img_type = 'raw';
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

            if contains(file_list.(img_type).(cate)(t).name, 'practice')
                task_mat.is_practice(count) = 1;
                task_mat.category(count) = strtok(task_mat.image{count}, '_');

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
    if endsWith(pwd, 'trial_matrices')
        target_dir = pwd;
    else
        target_dir = fullfile(pwd, 'trial_matrices');
    end

    file_name = fullfile(target_dir, sprintf("sub-%d_%s_trials.csv", sub_num, 'wp4_beh'));
    writetable(tr_mat, file_name);

end

