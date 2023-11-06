% need to be done

function [ ] = instructions(task)

global sub_num
global RightKey LeftKey

intro_slide1 = "instructions_slide1.png";

% decide which slides to take (based on task and subject number)
if strcmp(task, 'introspection')
    if mod(sub_num, 2)
        % odd subject number
        intro_slide2 = "instructions_cate_odd.png";
    else
        % even subject number
        intro_slide2 = "instructions_cate_even.png";
    end

    % last slide
    intro_slide3 = "instructions_end_cate.png";
else
    if strcmp(task, 'typicality')
        intro_slide2 = "instructions_typ.png";
    elseif strcmp(task, 'familiarity')
        intro_slide2 = "instructions_fam.png";
    elseif strcmp(task, 'usability')
        intro_slide2 = "instructions_usa.png";
    elseif strcmp(task, 'aesthetic')
        intro_slide2 = "instructions_aes.png";
    end

    % last slide
    intro_slide3 = "instructions_end_rating.png";
end
        
InstructionsPaths = [intro_slide1;intro_slide2;intro_slide3];

% Setting the slide number to 1 to initiate the while loop
InstructionSlideNum = 1;

% displays all instruction screens
while InstructionSlideNum<= size(InstructionsPaths,1) % Looping until we went through all slides:
    
    % Showing instruction slide
    showInstructions(InstructionsPaths(InstructionSlideNum,:));
    WaitSecs(0.2);
    CorrectKey = 0; % Setting the CorrectKey to 0 to initiate the loop
    while ~CorrectKey % As long as a non-accepted key is pressed, keep on asking
        [~, ~, InstructionsResp] = KbCheck();
        if InstructionsResp(RightKey) % If the participant press the right key, increment by 1 the slide number
            InstructionSlideNum = InstructionSlideNum + 1;
            CorrectKey = 1;
        elseif InstructionsResp(LeftKey) % Else if the participant pressed the left key:
            if InstructionSlideNum == 1 % If we are at slide one, that doesn't work
                CorrectKey = 0;
            else % Otherwise, just go back one slide
                InstructionSlideNum = InstructionSlideNum - 1;
                CorrectKey = 1;
            end
        else
            CorrectKey = 0;
        end
    end
end
end
