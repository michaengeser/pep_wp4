rsa.MDSConditions(RDM, userOptions)
%% 

userOptions = defineUserOptions;
userOptions.rootPath = fullfile(pwd, 'figures');
userOptions.analysisName = 'Micha';

RDM.RDM = RDM.RDM + 1;
RDM.RDM(1:size(RDM.RDM, 1)+1:end) = 0;

dotColours = repmat([1,0,0],length(RDMs),1);

% 2nd order MDS
rsa.MDSRDMs({RDMs}, userOptions, struct('titleString', 'MDS of different RDMs', 'figureNumber', 13,'fileName','2ndOrderMDSplot', 'dotColours',dotColours));

rsa.MDSConditions(RDM, userOptions,struct('titleString','ground-truth MDS',...
    'fileName','trueRDM_MDS','figureNumber',6,'dotColours',dotColours, 'alternativeConditionLabels', string(d.subNums)));