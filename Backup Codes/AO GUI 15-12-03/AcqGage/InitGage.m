function [ret,handle,actNTrig,Nlignes] = InitGage(AO)
% Set the acquisition, channel and trigger parameters for the system and
% commit the parameters to the driver.
% AO     = structure with the different parameters
% ret    = positive is setup is successful, negative corresponding to the
% error code else.
% handle = handle for the acq. card
% actNTrig = actual number of averaging. Considering the US depth and the
% number of US pulses as fixed, the init code will reduce the number of
% averaging if the number of corresponding overloads the GAGE memory and
% returns this value in order to correctly average later. If nothing
% happens, actNTrig is equal to NTrig


% AddPath %add path for the different subfunction
SEQ=AO.SEQ;
% EvtDur=SEQ.InfoStruct.event(1).duration; %Attention, all event must take the same time

systems = CsMl_Initialize; % Initialize driver
CsMl_ErrorHandler(systems);


[ret, handle] = CsMl_GetSystem; % Get ready to use Gage handle
try
    % If error, try to free cards and try to get handle again
    CsMl_ErrorHandler(ret);
    
catch exception
    warning(exception.message,exception.identifier)
    display('Attempting to free system')
    ret=CsMl_FreeAllSystems; %frees all systems
    
    try
        CsMl_ErrorHandler(ret); % If no error, system freed
        display('System Freed')
        
    catch exception
        %else, clear all and return
        warning(exception.message,exception.identifier)
        clear all
        return
    end
    
    [ret, handle] = CsMl_GetSystem; %try to get handle again
    
    try
        CsMl_ErrorHandler(ret); % If no error, got handle
        
    catch exception
        %else, clear all and return
        errordlg(exception.message,exception.identifier)
        clear all
        return
    end
end

[ret, sysinfo] = CsMl_GetSystemInfo(handle); % Get card infos
CsMl_ErrorHandler(ret, 1, handle);

s = sprintf('-----Board name: %s\n', sysinfo.BoardName);
disp(s);

% ======================================================================= %
%% Acquisition parameters

%Customed Parameters
switch AO.val
    case 1
        % case focused waves
        Nlignes         = round(AO.ScanLength/system.probe.Pitch); % Number of lines of the scan
    case 2
        % case plane waves
        Nlignes         = length(-AO.AlphaM:AO.dA:AO.AlphaM); % Number of lines of the scan
end

acqInfo.SegmentCount    = AO.NTrig(AO.val)*Nlignes; % Number of memory segments (Nlines*Nmoy)
acqInfo.SampleRate      = AO.SamplingRate*1e6;%Max = 50 MHz, must be divider of 50;
%acqInfo.Depth           = ceil((acqInfo.SampleRate*1e-3*AO.Prof/(common.constants.SoundSpeed))/32)*32; % Must be a multiple of 32
acqInfo.Depth           = ceil((acqInfo.SampleRate*1e-6*ceil(AO.Prof(AO.val)/(common.constants.SoundSpeed*1e-3)))/32)*32; % Must be a multiple of 32


% checks that the memory of the card will not be overloaded
if acqInfo.SegmentCount*acqInfo.Depth>sysinfo.MaxMemory
    actNTrig=floor(sysinfo.MaxMemory/Nlignes);
    warning(['Card memory will be overloaded : averaging was set to ' num2str(actNTrig)])
    acqInfo.SegmentCount = Nlignes*actNTrig;
else
    actNTrig=AO.NTrig(AO.val);
end

%"Do not change" Parameters
acqInfo.ExtClock        = 0;
acqInfo.Mode            = CsMl_Translate('Single', 'Mode');%  Single, Dual, Quad or Octal
acqInfo.SegmentSize     = acqInfo.Depth; % Must be a multiple of 32
acqInfo.TriggerTimeout  = 2e6; % in �s
acqInfo.TriggerHoldoff  = 0; % Number of points during which the card ignores trigs
acqInfo.TriggerDelay    = 0; % Number of points
acqInfo.TimeStampConfig = 1; % Get the time at which each waveform was acquired
% if non-zero, restart the time stamp counter at each acq.

[ret] = CsMl_ConfigureAcquisition(handle, acqInfo);% config acq parameters
CsMl_ErrorHandler(ret, 1, handle);

% initializes all the channels even though
% they might not all be used.
for i = 1:sysinfo.ChannelCount
    chan(i).Channel     = i;
    chan(i).Coupling    = CsMl_Translate('DC', 'Coupling');
    chan(i).DiffInput   = 0;
    chan(i).InputRange  = 2000;%2000; Vpp in mV
    chan(i).Impedance   = 50; % 50 Ohms or 1 MOhms
    chan(i).DcOffset    = 0;
    chan(i).DirectAdc   = 0;
    chan(i).Filter      = 0;
end

% Sets channel 1
chan(1).InputRange      = 2*AO.Range*1e3; % Vpp in mV
chan(1).Coupling        = CsMl_Translate('DC', 'Coupling');


[ret] = CsMl_ConfigureChannel(handle, chan); % config chan parameters
CsMl_ErrorHandler(ret, 1, handle);

% Sets trigger parameters
trig.Trigger            = 1;
trig.Slope              = CsMl_Translate('Negative', 'Slope'); % Aixplorer Trig has a neg slope
trig.Level              = 10; % in percent of the trig range (-100 to +100)
trig.Source             = CsMl_Translate('External', 'Source');
trig.ExtCoupling        = CsMl_Translate('DC', 'ExtCoupling');
trig.ExtRange           = 10000; % Vpp in mV, +-5V

[ret] = CsMl_ConfigureTrigger(handle, trig); % config Trig parameters
CsMl_ErrorHandler(ret, 1, handle);

ret = CsMl_Commit(handle);
CsMl_ErrorHandler(ret, 1, handle);

ret = 1;