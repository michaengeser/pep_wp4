function [all_mat, img_acc_table] = checkImgAcc(sub_nums)

%% get all performances

% loops through all existing data and extract matrices

% path to data folder
PreFolderName = fullfile(pwd, 'data');

% loop through all subjects
for sub = sub_nums
    % make subject directory
    SubFolderName = fullfile(PreFolderName, ['sub-',num2str(sub)]);

    % loop through sessions
    for ses = 1:3

        % make directory for session and task
        SesFolderName = fullfile(SubFolderName, ['ses-',num2str(ses)]);
        CateFolderName = fullfile(SesFolderName, 'categorization');

        % if exist, get file names
        if exist(CateFolderName, 'dir')
            file_names = dir(fullfile(CateFolderName, '*.mat'));

            % load file names that contain 'all'
            for file_name = {file_names.name}
                if contains(file_name, 'all')
                    input_mat = load(fullfile(CateFolderName, cell2mat(file_name)));
                    ses_mat = input_mat.input_table;

                    % concatanate matrices to one big one
                    if ~exist('all_mat', 'var')
                        all_mat = ses_mat;
                    else
                        all_mat = [all_mat; ses_mat];
                    end
                end
            end
        end
    end
end

%% analyis - image accuracy
% now we have the data, lets looks at accuracy of each image

% get image names
img_names = unique(all_mat.image);

% define column names
variable_names = ["image_name", "category", "mean_acc", "repetitions"];

% init table
img_acc_table = table(img_names, repmat("empty",length(img_names),1), nan(length(img_names),1), nan(length(img_names),1),...
    'VariableNames', variable_names);

% get category inforamtion and accuray
for row = 1: length(img_names)
    img_name = img_names{row};

    % get all trials with that image
    img_trial_mat = all_mat(contains(all_mat.image, img_name), :);

    % get image category
    img_acc_table.category{row} = img_trial_mat.category{1};

    % get image accuracy
    img_acc_table.mean_acc(row) = mean(img_trial_mat.trial_accuracy, 'omitnan');

    % get number of image repetitions
    img_acc_table.repetitions(row) = height(img_trial_mat);
end
end
