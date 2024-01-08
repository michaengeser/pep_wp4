rsa.MDSConditions(RDM, userOptions)
%% 

userOptions = defineUserOptions;
userOptions.rootPath = fullfile(pwd, 'figures');
userOptions.analysisName = 'Micha';

RDM.RDM = RDM.RDM + 1;
RDM.RDM(1:size(RDM.RDM, 1)+1:end) = 0;


% 2nd order MDS
rsa.MDSRDMs({RDMs}, userOptions, struct('titleString', 'MDS of different RDMs', 'figureNumber', 13,'fileName','2ndOrderMDSplot'));



rsa.MDSConditions(RDM, userOptions,struct('titleString','ground-truth MDS',...
    'fileName','trueRDM_MDS','figureNumber',6));