%% Housekeeping:
% Clearing the command window before we start saving it
sca;
close all;
clear all;

% Hardware parameters:
global sub_num TRUE FALSE refRate compKbDevice task
global el EYE_TRACKER CalibrationKey ValidationKey EYETRACKER_CALIBRATION_MESSAGE SHOW_PRACTICE  session
global FRAME_ANTICIPATION PHOTODIODE DIOD_DURATION SHOW_INSTRUCTIONS
global ABORTED RESTART_KEY NO_KEY ABORT_KEY spaceBar RestartKey


% Add functions folder to path (when we separate all functions)
function_folder = [pwd,filesep,'functions\'];
addpath(function_folder)

% prompt user for information
sub_num = input('Subject number [101-199, default: 101]: '); if isempty(sub_num); sub_num = 101; end
session = input('Session number [default: 1]: '); if isempty(session); session = 1; end
task_num = input('Task [0: Slide show, 1: Categorization, 2: Typicality, 3: Familiarity, 4: Aesthetic, ..., default: 1]: ');
if isempty(task_num); task_num = 1; end

if task_num == 0; task = 'slide_show';
elseif task_num == 1; task = 'categorization';
elseif task_num == 2; task = 'typicality';
elseif task_num == 3; task = 'familiarity';
elseif task_num == 4; task = 'aesthetic';
    % to be extended
end

% initializing experimental parameters
initRuntimeParameters

% Logging everything that is printed into the command window! If the
% log file already exist, delete it, otherwise the logs will besub_num
% appended and it won't be specific to that participant. Moreover, the
% logs are always saved
dfile ='log_wp4_beh.txt';
if exist(dfile, 'file') ; delete(dfile); end
Str = CmdWinTool('getText');
dlmwrite(dfile,Str,'delimiter','');
% To get different seeds for matlab randomization functions.
rng('shuffle');

%% check if participant and session exists already

SubSesFolder = fullfile(pwd,'data',['sub-', num2str(sub_num)],['ses-',num2str(session)], task);
ExistFlag = exist(SubSesFolder,'dir');
if ExistFlag
    warning ('This participant number and session was already attributed!')
    proceedInput = questdlg({'This participant number and session was already attributed!', 'Are you sure you want to proceed?'},'RestartPrompt','yes','no','yes');
    if strcmp(proceedInput,'no')
        error('Program aborted by user')
    end
end

% Initializing PTB:
initPsychtooblox(); % initializes psychtoolbox window at correct resolution and refresh rate

%% Setup the trial matrix and log:
[tr_mat] = load_trial_matrix(sub_num);

% get trial matrix of the task 
task_mat = tr_mat(strcmp(tr_mat.task, task),:);

%% Load and prepare stimuli:

showMessage('Loading...');
loadStimuli()

% make jitter multiple of refresh rate
for tr_jit = 1:length(task_mat.trial)
    jit_multiplicator = round(task_mat.jitter(tr_jit)/refRate);
    task_mat.jitter(tr_jit) = refRate*jit_multiplicator;
end

%% Instructions
% displays instructions
if SHOW_INSTRUCTIONS
    instructions(task);
end

%% Main experimental loop:
try

    ABORTED = 0;

    %% save everything from command window
    Str = CmdWinTool('getText');
    dlmwrite(dfile,Str,'delimiter','');

    %%  Experiment
    % Experiment Prep
    showFixation('PhotodiodeOff');

    %% Block loop:
    blks = unique(task_mat.block);

    if SHOW_PRACTICE
        blk = 0;
    else
        blk = 1;
    end

    while blk <= blks(end)

% 
%         % Initialize the eyetracker with the block number and run the
%         % calibration:
% 
%         if EYE_TRACKER
%             % Initialize the eyetracker:
%             initEyetracker(sub_num, blk);
%             % Show the calibration message to give the option to perform
%             % the eyetracker calibration if needed:
%             showMessage(EYETRACKER_CALIBRATION_MESSAGE);
%             CorrectKey = 0; % Setting the CorrectKey to 0 to initiate the loop
%             while ~CorrectKey % As long as a non-accepted key is pressed, keep on asking
%                 [~, CalibrationResp, ~] = KbWait(compKbDevice,3);
%                 if CalibrationResp(CalibrationKey)
%                     % Run the calibration:
%                     EyelinkDoTrackerSetup(el);
%                     CorrectKey = 1;
%                 elseif CalibrationResp(ValidationKey)
%                     CorrectKey = 1;
%                 end
%             end
%             % Starting the recording
%             Eyelink('StartRecording');
%             % Wait for the recording to have started:
%             WaitSecs(0.1);
%         end

        % Extract the trial and log of this block only:
        blk_mat = task_mat(task_mat.block == blk, :);

        % Add the columns for logging:
        blk_mat = prepare_log(blk_mat);

        % check what block we´re in and informs user
        if blk == 0
            showMessage('Press a space to start the practice');
        elseif blk == 1
            showMessage('Press a space to start the experiment');
        else 
            showMessage('Press a space to start the next block');
        end
        
        % wait for response
        wait_resp = 0;
        while wait_resp == 0
            [~, ~, wait_resp] = KbCheck();
        end

        % Wait a random amount of time and show fixation:
        fixOnset = showFixation('PhotodiodeOff'); 
        WaitSecs(rand + 2);

        %% Trials loop:
        for tr = 1:length(blk_mat.trial)
            % flags needs to be initialized
            fixShown = FALSE;
            jitterLogged = FALSE;
            hasInput = FALSE;
            PauseTime = 0; % If the experiment is paused, the duration of the pause is stored to account for it.

            % show stimulus
            blk_mat.stim_time(tr) = showStimuli(blk_mat.texture(tr));
            DiodFrame = 0;

%             % Sending response trigger for the eyetracker
%             if EYE_TRACKER
%                 trigger_str = get_et_trigger('vis_onset', blk_mat.task_relevance{tr}, ...
%                     blk_mat.duration(tr), blk_mat.category{tr}, orientation, vis_stim_id, ...
%                     blk_mat.SOA(tr), blk_mat.SOA_lock(tr), blk_mat.pitch(tr));
%                 Eyelink('Message',trigger_str);
%             end

            % I then set a frame counter. The flip of the stimulus
            % presentation is frame 0. It is already the previous frame because it already occured:
            PreviousFrame = 0;
            % I then set a frame index. It is the same as the previous
            % frame for now
            FrameIndex = PreviousFrame;

            %--------------------------------------------------------

            %% TIME LOOP
            elapsedTime = 0;

            % define total trial duration
            min_trial_duration = blk_mat.duration(tr) - (refRate*FRAME_ANTICIPATION);
            
            while elapsedTime < min_trial_duration && ~hasInput

                %% Get response:
                if ~hasInput
                    % Ge the response:
                    [key,Resp_Time] = getInput();

                    % Handling the response:
                    % If the participant pressed a key that is different
                    % to the one of the previous iteration:
                    if key ~= NO_KEY

%                         % Sending response trigger for the eyetracker
%                         if EYE_TRACKER
%                             trigger_str = get_et_trigger('response', blk_mat.task_relevance{tr}, ...
%                                 blk_mat.duration(tr), blk_mat.category{tr}, orientation, vis_stim_id, ...
%                                 blk_mat.SOA(tr), blk_mat.SOA_lock(tr), blk_mat.pitch(tr));
%                             Eyelink('Message',trigger_str);
%                         end

                        if key == ABORT_KEY % If the experiment was aborted:
                            ABORTED = 1;
                            error('Experiment has been aborted');
                        end

                        % Log the response received:
                        blk_mat.trial_response(tr) = key;
                        blk_mat.time_of_resp(tr) =  Resp_Time;

                        % logging reaction
                        hasInput = TRUE;
                    end
                end

                %% Waiting for response

                % Present fixation while waiting for response
                if elapsedTime >= ((blk_mat.duration(tr)/1000) - refRate*FRAME_ANTICIPATION) && fixShown == FALSE
                    fix_time = showFixation('PhotodiodeOn');
                    DiodFrame = CurrentFrame;

%                     % Sending response trigger for the eyetracker
%                     if EYE_TRACKER
%                         trigger_str = get_et_trigger('fixation_onset', blk_mat.task_relevance{tr}, ...
%                             blk_mat.duration(tr), blk_mat.category{tr}, orientation, vis_stim_id, ...
%                             blk_mat.SOA(tr), blk_mat.SOA_lock(tr), blk_mat.pitch(tr));
%                         Eyelink('Message',trigger_str);
%                     end

                    % log fixation
                    blk_mat.fix_time(tr) = fix_time;
                    fixShown = TRUE;
                end

                % Updating clock:
                elapsedTime = GetSecs - blk_mat.stim_time(tr);

                % Updating the frame counter:
                CurrentFrame = floor(elapsedTime/refRate);

                % Check if a new frame started:
                if CurrentFrame > PreviousFrame
                    FrameIndex = FrameIndex +1;

                    % turn photodiode off again after diod duration
                    if PHOTODIODE && (CurrentFrame - DiodFrame == DIOD_DURATION - 1)
                        turnPhotoTrigger('off');
                    end
                    PreviousFrame = CurrentFrame;
                end
            end 


            %% Jitter TIME LOOP
            elapsedTime = 0;

            % define total trial duration
            jitter_duration = blk_mat.jitter(tr) - (refRate*FRAME_ANTICIPATION) ;
            
            while elapsedTime < jitter_duration

                % Present jitter
                if jitterLogged == FALSE

                    blk_mat.jit_onset(tr) = showFixation('PhotodiodeOn');
                    DiodFrame = CurrentFrame;

%                     % Sending response trigger for the eyetracker
%                     if EYE_TRACKER
%                         trigger_str = get_et_trigger('jitter_onset', blk_mat.task_relevance{tr}, ...
%                             blk_mat.duration(tr), blk_mat.category{tr}, orientation, vis_stim_id, ...
%                             blk_mat.SOA(tr), blk_mat.SOA_lock(tr), blk_mat.pitch(tr));
%                         Eyelink('Message',trigger_str);
%                     end

                    jitterLogged = TRUE;

                end
                % Updating clock:
                elapsedTime = GetSecs - blk_mat.jit_onset(tr);

            end

            % log end of trial
            blk_mat.trial_end(tr) = GetSecs;

            %% End of trial

            if(key==RESTART_KEY)
                break
            end
        end  % End of trial loop

        % Save the data of this block:
        saveTable(blk_mat, blk);

%         % Save the eyetracker data:
%         if EYE_TRACKER
%             saveEyetracker(task, blk);
%         end

        % Append the block log to the overall log:
        if ~exist('log_all', 'var')
            log_all = blk_mat;
        else
            log_all = [log_all; blk_mat];  % Not the most efficient but it is in a non critical part
        end

        %% Feedback

        % generate end of block message
        block_message = ['End of block ', num2str(blk_mat.block(1)), ' of ', num2str(task_mat.block(end))];

        if strcmp(task, 'categorization')

            % compute accuracy
            [blk_mat] = compute_performance(blk_mat);

            % get mean accuracy
            mean_acc = mean(blk_mat.trial_accuracy);
            
            % generate feedback message
            block_message = [block_message, newline, 'Your accuracy is: ', num2str(round(mean_acc*100)), '%'];

            % give option to repeat practice
            if blk_mat.is_practice

                % generate practice feedback message
                block_message = [block_message, newline, 'Press space to proceed to experiemt', newline, ...
                        'Press R to repeat practice'];

            end % ends practice message statement
        end % end of feedback 
       
       % show generated end of block message
       showMessage(block_message)

       % wait for response ("r" = repeats practice, space bar = proceed)
       key_pressed = 0;
       while key_pressed == 0
           [~, ~, Resp] = KbCheck();

           if Resp(RestartKey)
               key_pressed = 1;
               blk = blk - 1;
           elseif Resp(spaceBar)
               key_pressed = 1;
           else
               key_pressed = 0;
           end
       end

    blk = blk + 1;
    end  % End of block loop

    %% End of experiment

    % Letting the participant that it is over:
    end_message = ['THE END', newline, newline,'Thank you!'];

    % compute performances of tasks
    [log_all] = compute_performance(log_all);

    %% Save

    % Save the whole table:
    saveTable(log_all, "all");
    % Save the code:
    saveCode(task);
    
    showMessage(end_message);
    WaitSecs(2);

    showMessage('saving');
    % Mark the time of saving onset
    ttime = GetSecs;

    % save everything from command window
    Str = CmdWinTool('getText');
    dlmwrite(dfile,Str,'delimiter','');

    % Terminating teh experiment:
    safeExit()

catch e

    % Save the data:
    try
        % Save the beh data:
        saveTable(blk_mat, blk);

        % Save the eyetracker data:
%         if EYE_TRACKER
%             saveEyetracker(task, blk);
%         end

        % If the log all already exists, save it as well:
        if exist('log_all', 'var')
            [log_all] = compute_performance(log_all);
            saveTable(log_all, "all");
        end

        % Save the code:
        saveCode(task);
        safeExit()

    catch ee
        warning('-----  Data could not be saved!  ------')
        safeExit()
        rethrow(ee);
    end

    rethrow(e);
end