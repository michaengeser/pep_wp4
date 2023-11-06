
% LOADSTIMULI loads all the stimuli in all types and orientation from HD. Wasteful and should be used before the experiment is running.
% output:
% -------
% loads all textures from HD, and puts them into the global textures
% structure (texture_struct) matching the folder structure of the stimuli
% folder

function [] = loadStimuli()

disp('WELCOME to loadStimuli')

global texture_struct w

% path to stimuli folder
PreFolderName = [pwd,filesep,'stimuli\'];
cate_names = {'kitchen', 'bathroom', 'practice'};
texture_struct = struct('kitchen', [], 'bathroom', [], 'practice', []);

% loops through the folders an loads all stimuli
for j = 1:length(cate_names)

    FolderName = fullfile(PreFolderName, cate_names{j});
    new_textures = getTexturesFromHD(FolderName, w);
    texture_struct.(cate_names{j}) = new_textures;

end
end
