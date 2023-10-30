% In this script, the experiment runtime parameters are being set. This
% is where the recording modes, hardware and physical parameters are being
% set. Before running the experiment, this file should be checked to be
% sure that the parameters are set correctly.
% This script has no input nor ouput. Every parameters being set are
% global variables. This means that they can be called by the different
% functions. 

function initRuntimeParameters
% Recording modalities:
global Behavior EYE_TRACKER 
% Photodiode parameters:
global PHOTODIODE DIOD_DURATION DIOD_SIZE DIOD_ON_COLOUR DIOD_OFF_COLOUR DIAL RESPONSE_BOX
% Eyetracker parameters:
global DISTANCE_SCREEN_TRACKER HEAD_FIXED
% Hardware parameters:
global SCREEN_SIZE_CM REF_RATE_OPTIMAL viewDistanceBottomTop viewDistance 
% Debugging and code parameters:
global VERBOSE NO_PRACTICE DEBUG RESOLUTION_FORCE NO_FULLSCREEN WINDOW_RESOLUTION NO_ERROR VERBOSE_PLUS SHOW_INSTRUCTIONS NO_CALIBRATION_TASK
 
%% Recording modalities
EYE_TRACKER = 0; % Must be set to 1 if recording with Eyetracker
Behavior = 1; %Set to 1 if recording with Behavior only

%% Hardware and physical parameters:
REF_RATE_OPTIMAL = 60; % in Hz. Screen refresh rate.
viewDistance = 70; % Default viewing distance (if no viewDist argument sent with the function call)
SCREEN_SIZE_CM = [53.2 29.8]; % screen [width, height] in centimeters, change it to fit your setting
viewDistanceBottomTop = [72 72]; % IN CM!! Distance between the participant head and the top and bottom of the screen. Only needed if HEAD_FIXED on.

%% Eyetracker parameters:
DISTANCE_SCREEN_TRACKER = 90; % Distance between the eyetracker lense and the computer screen. Only needed for REMOTE MODE!
HEAD_FIXED = 0; % Head fixed must be set to 0 if remote mode


%% Photodiode parameters:
PHOTODIODE = 0; % Must be set to 1 for the photodiode to be presented
DIOD_ON_COLOUR = 255; % Color of the photodiode when turned on (255 white, 0 black)
DIOD_OFF_COLOUR = 1;  % Color of the photodiode when off (255 white, 0 black)
DIOD_SIZE = 100; % Size of the square where the photodiode is presented (in pixels)
DIOD_DURATION = 3; % Duration of the photodiode flash when turned on (in frames)

%% DEBUG parameters
DEBUG = 0; % 0 = no debug | 1 = regular debug | 2 = fast debug
SHOW_INSTRUCTIONS = 1;
NO_PRACTICE = 1; % skip the practice run
RESOLUTION_FORCE = 0; % the program will complain if optimal refresh rate is not possible on this screen
NO_FULLSCREEN = 1; % enable windowed mode for dubugging
NO_ERROR = 0; % Disable testing program error throws
% Q: Do I need to fill this out? Pixels? Yoav: only if you want the debug scree to be of a different size
WINDOW_RESOLUTION = [10 10 1200 800];

end