function [log_table, performance_struct] = compute_performance(log_table)
%%

% keys
global  CalibrationKey ValidationKey WRONG_KEY NO_KEY RESTART_KEY ABORT_KEY abortKey upKey downKey PauseKey RestartKey YesKey KITCHEN_KEY BATHROOM_KEY
global oneKey twoKey threeKey fourKey fiveKey sixKey sevenKey eightKey spaceBar F_Key H_Key MINIBLOCK_RESTART_KEY BLOCK_RESTART_KEY

%%
disp('WELCOME TO compute_performance');


log_table = log_table(~isnan(log_table.texture), :);

for tr = 1:length(log_table.trial)

    log_table.trial_accuracy(tr) = nan;
     if strcmp(log_table.task{tr}, 'categorization')

        % compute correctness for categorization task task
        if (log_table.aud_resp(tr) == LOW_PITCH_KEY && log_table.pitch(tr) == 1000) ||...
                (log_table.aud_resp(tr) == HIGH_PITCH_KEY && log_table.pitch(tr) == 1100)
            log_table.trial_accuracy(tr) = 1;

        elseif (log_table.aud_resp(tr) == HIGH_PITCH_KEY && log_table.pitch(tr) == 1000) ||...
                (log_table.aud_resp(tr) == LOW_PITCH_KEY && log_table.pitch(tr) == 1100)
            log_table.trial_accuracy(tr) = 0;
        end 
     end 


        % get RT auditory response 
        log_table.RT_aud(tr) = log_table.time_of_resp_aud(tr) - log_table.aud_stim_time(tr);
        % make it a nan when RT is negative 
        if log_table.RT_aud(tr) < 0
            log_table.RT_aud(tr) = nan;
        end

end
performance_struct.aud_mean_accuracy = mean(log_table.trial_accuracy, 'omitnan');
end

% log_table.has_response_vis(:) = 0;
% for tr = 1:length(log_table.trial)
%     if log_table.trial_first_button_press(tr) == 1 || log_table.trial_second_button_press(tr) == 1
%         log_table.has_response_vis(tr) = 1;
%     end
% end
