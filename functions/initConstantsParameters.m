
% INITCONSTANTSPARAMETERS this function defines all the constants and parameters of
% the program. Please note was can be changed, and what cannot, without
% breaking the program.
% The codes used to designate stimuli:
% stimuli are coded as a 4 digit number.
% 1st digit = stimulus type (1 = face; 2 = object; 3 = letter; 4 = false font)
% 2nd digit = stimulus orientation (1 = center; 2 = left; 3 = right)
% 3rd & 4th digits = stimulus id (1...20; for faces 1...10 is male, 11...20 is female)
% e.g., "1219" = 1 is face, 2 is left orientation and 19 is a female stimulus #19
% Duration is encoded by the first decimal so that 1219.1 has duration 0.5,
% 1219.2 has duration 1 s and 1219.3 has duration 1.5 s
function initConstantsParameters()

disp('')
disp('WELCOME TO initConstantsParameters')
disp('')
%% Header
% GOBAL CONSTANTS
% -----------------------------------------------------
% Text and messages
global TRUE FALSE 
global fontType fontSize fontColor 
global EXPERIMENT_NAME 
global  CalibrationKey ValidationKey VIS_TARGET_KEY WRONG_KEY NO_KEY RESTART_KEY ABORT_KEY abortKey upKey downKey PauseKey RestartKey YesKey
global oneKey twoKey threeKey fourKey spaceBar MINIBLOCK_RESTART_KEY BLOCK_RESTART_KEY
global DEBUG 
global FRAME_WIDTH MAX_VISUAL_ANGEL VIEWING_DISTANCE FRAME_COLOR  viewDistance FIXATION_COLOR FIXATION_FONT_SIZE  DIAMOUT_FIXATION DIAMIN_FIXATION
global CODE_FOLDER  DATA_FOLDER FILE_POSTFIX  EXP_DATE
global NO_TRIAL


%%  PARAMETERS THAT MAY BE ALTERED
EXPERIMENT_NAME = 'ReconTime';
FILE_POSTFIX = '*.png';
%add date as a separate column 5 years rewind
t=datenum(date);
EXP_DATE=datestr(t);

% Add a frame for the bebug mode to not mix things up:
FRAME_WIDTH = 0; % 0 for delete
if DEBUG FRAME_WIDTH = 1; end
FRAME_COLOR = [39,241,44];


% TEXT
fontType = 'David';
fontSize = 50; % general text size, not target
FIXATION_COLOR = [205 33 42];
FIXATION_FONT_SIZE = 20;
fontColor = 0; % black;

VIEWING_DISTANCE = viewDistance; % in centimeters
MAX_VISUAL_ANGEL = [6,6]; % in degrees | "on a rectangular aperture at an average visual angle of 6? by 4?"

% Size of the fixation in DVA:
DIAMOUT_FIXATION = 0.6; % diameter of outer circle (degrees)
DIAMIN_FIXATION = 0.1; % diameter of inner circle (degrees)

% Response params
KbName('UnifyKeyNames');
CalibrationKey = KbName('C');
upKey         =  KbName('UpArrow');
downKey       =  KbName('DownArrow');
PauseKey      =  KbName('Q');
RestartKey    =  KbName('R');
abortKey      =  KbName('ESCAPE'); % ESC aborts experiment
MEGbreakKey   =  KbName('F5');
YesKey        =  KbName('Y');
spaceBar      =  KbName('SPACE');
oneKey        =  KbName('1!');
twoKey        =  KbName('2@');
threeKey      =  KbName('3#');
fourKey       =  KbName('4$');
ValidationKey = KbName('V');

MINIBLOCK_RESTART_KEY = KbName('M');
BLOCK_RESTART_KEY = KbName('B');


%%  PARAMETERS THAT SHOULD NOT BE ALTERED, BUT SHOULD BE USED AS REFERENCE

% Folders
DATA_FOLDER = 'data';
CODE_FOLDER = 'code';

% program codes
ABORT_KEY = 4;
RESTART_KEY = 3;
WRONG_KEY = 2;
VIS_TARGET_KEY = 1; % to mark if up was pressed
NO_KEY = 0;

TRUE = 1;
FALSE = 0;

NO_TRIAL = nan;


end % end of initConstantParameters function
