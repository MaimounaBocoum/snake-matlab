
%% include path
 addpath('commands');
 addpath('C:\Program Files (x86)\Gage\CompuScope\CompuScope MATLAB SDK\CsMl')
 %addpath('subfunctions');

 % VT-80 Pollus specs
 % motor-type : 2-phase bipolar
 % step angle 1.8�
 % steps 200
 % 1mm/rev
 % resolution/fullstep 0.005microns
 % resolution theorique : 1nm
 % 

%%  ========================= initialization of Pollux  ==

COM_Port   = 4 ;
Controller = PolluxOpenAndInitialize(COM_Port);
fprintf(Controller,['1' 'gnv']); 

%% ===============   calibration des rails

% command redefinit le zero
fprintf(Controller,['1','ncal']);
fprintf(Controller,['2','ncal']);
fprintf(Controller,['1','nrm']);
fprintf(Controller,['2','nrm']);

%% set current position as 0

GetPitch(Controller,'1');
GetPitch(Controller,'2');

%% get position
GetPosition(Controller,'1')
GetPosition(Controller,'2')

%% get velociy
GetVelocity(Controller,'1');
GetVelocity(Controller,'2');

%% set velocity
SetVelocity(Controller,50,'1'); % not working ??
SetVelocity(Controller,50,'1'); % not working ??


%% get accelaration
GetAccelerationRamp(Controller,'1');
GetAccelerationRamp(Controller,'2');

%% redefine zero position at current position :
SetZeroHere(Controller,'1')
SetZeroHere(Controller,'2')

%% absolute move
PolluxDepAbs(Controller,-30,'2')
PolluxDepAbs(Controller,0,'1')

%% relative move
PolluxDepRel(Controller,10,'2')
PolluxDepRel(Controller,-5,'1')

%% emmergency stop motion
StopMotion(Controller,'1')
StopMotion(Controller,'2')

%% move to calibrated limit switch (position 0 and redefines 0 as absolute reference)
% note : this motion does not account for software limit switches
PolluxMoveCal(Controller,'1')
PolluxMoveCal(Controller,'2')

%% move to Range measurement (position 151mm )
% note : this motion does not account for software limit switches
PolluxRangeCal(Controller,'1')
PolluxRangeCal(Controller,'2')


GetSwitchStatus(Controller,'1')% not working, suppose to return  [0 , 0] format

%% software limit switches 
% this function is overwritten after running PolluxMoveCal
% this function is not updated if one is outside of the limit range
Limits = GetSoftwareLim(Controller,'2');
SetLimitRange(Controller,-35,50,'2');
Limits = GetSoftwareLim(Controller,'1');
SetLimitRange(Controller,-35,50,'1');


%% get last error
code = GetLastError(Controller,'1');
code = GetLastError(Controller,'2');

%% Fermeture et nettoyage de la memoire
PolluxClose(Controller,COM_Port);
close all
clear all

%% ================================= quite remote ===========================================%%
%               SEQ = SEQ.quitRemote()      ;
%               ret = CsMl_FreeAllSystems   ;
%               restoredefaultpath 