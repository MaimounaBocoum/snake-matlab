% Sequence AO Plane Waves JB 30-04-15 ( d'apres 01-04-2015 JB)
% INITIALIZATION of the US Sequence
% ATTENTION !! M�me si la s�quence US n'�coute pas, il faut quand m�me
% d�finir les remote.fc et remote.rx, ainsi que les rxId des events.
% DO NOT USE CLEAR OR CLEAR ALL use clearvars instead

 clear ELUSEV EVENTList TWList TXList TRIG ACMO ACMOList SEQ
 AixplorerIP    = '192.168.1.16'; % IP address of the Aixplorer device


%% parameter for plane wave sequence :
% ======================================================================= %
        Volt        = 10;
        f0          = 2;
        NbHemicycle = 20;
        X0          = 0;
        ScanLength  = 38.5;
        NTrig       = 50;
        Prof        = 40;
        


%% System parameters import :
% ======================================================================= %
c           = common.constants.SoundSpeed ; %[m/s]
SampFreq    = system.hardware.ClockFreq; %NE PAS MODIFIER % emitted signal sampling = 180 in [MHz]
NbElemts    = system.probe.NbElemts ; 
pitch       = system.probe.Pitch ; % in mm
MinNoop     = system.hardware.MinNoop;

NoOp       = 500;             % �s minimum time between two US pulses

% ======================================================================= %

PropagationTime        = Prof/c*1e3 ;  % 1 / pulse frequency repetition [us]
TrigOut                = ceil(Prof/(c*1e-3));  %�s
Pause                  = max( NoOp-ceil(PropagationTime) , MinNoop ); % pause duration in �s

% ======================================================================= %
%% Codage en arbitrary : delay matrix and waveform
dt_s          = 1/(SampFreq);  % unit us
pulseDuration = NbHemicycle*(0.5/f0) ; % US inital pulse duration in us

%====================================================================== %
%% Arbitrary definition of US events
FC = remote.fc('Bandwidth', 90 , 0); %FIR receiving bandwidth [%] - center frequency = f0 : 90
RX = remote.rx('fcId', 1, 'RxFreq', 60 , 'QFilter', 2, 'RxElemts', 0, 0);

%% Codage en arbitrary : preparation des acmos

Pixel    = 0.2; % taille d'un pixel en mm
NbPixels = 128; % nombre de pixels
Xs       = (0:NbPixels-1)*Pixel; % Echelle de graduation en X
u        = 1.54; % vitesse de propagation en mm/us
NbZ      = 1;  %8; % Nb de composantes de Fourier en Z
NbX      = 20; %20 Nb de composantes de Fourier en X

freq0 = 50000; % Pas fr�quentiel de la modulation de phase (en Hz)
nuX0 = 1.0/(NbPixels*Pixel); % Pas fr�quence spatiale en X (en mm-1)

[NBX,NBZ] = meshgrid(-NbX:NbX,1:NbZ);
Nfrequencymodes = length(NBX(:));

for nbs = 1:Nfrequencymodes
    
        f   = NBZ(nbs)*freq0; % fr�quence de modulation de phase (en Hz) 
        nuX = NBX(nbs)*nuX0; % fr�quence spatiale (en mm-1)
        Arbitrary.Waveform = CalcMatHole(f0,f,nuX,Xs); % Calculer la matrice
       % Arbitrary.Waveform = zeros(50,192);
       
        imagesc(Arbitrary.Waveform);
        pause(0.1);
        
    EvtDur   = ceil(pulseDuration + max(max(Delay)) + PropagationTime);   
    
    % Flat TX
    TXList{nbs} = remote.tx_arbitrary('txClock180MHz', 1,'twId',1,'Delays',0);
    
    % Arbitrary TW
    TWList{nbs} = remote.tw_arbitrary( ...
        'Waveform',WFtmp', ...
        'RepeatCH', 0, ...
        'repeat',0 , ...
        'repeat256', 0, ...
        'ApodFct', 'none', ...
        'TxElemts',1:192, ...
        'DutyCycle', 1, ...
        0);
    
    
    % Event
    EVENTList{nbs} = remote.event( ...
        'txId', 1, ...
        'rxId', 1, ...
        'noop', Pause, ...
        'numSamples', 128, ...
        'skipSamples', 0, ... 128, ...
        'duration', EvtDur, ...
        0);
    
    %ELUSEV
ELUSEV{nbs} = elusev.elusev( ...
    'tx',           TXList{nbs}, ...
    'tw',           TWList{nbs}, ...
    'rx',           RX,...
    'fc',           FC,...
    'event',        EVENTList{nbs}, ...
    'TrigOut',      TrigOut, ... 0,...
    'TrigIn',       0,...
    'TrigAll',      1, ...
    'TrigOutDelay', 0, ...
    0);

    
end

% ======================================================================= %
%% ELUSEV and ACMO definition

ACMO = acmo.acmo( ...
    'elusev',           ELUSEV, ...
    'Ordering',         0, ...
    'Repeat' ,          1, ...
    'NbHostBuffer',     1, ...
    'NbLocalBuffer',    1, ...
    'ControlPts',       900, ...
    'RepeatElusev',     1, ...
    0);

ACMOList{1} = ACMO;

% ======================================================================= %
%% Build sequence

% Probe Param
TPC = remote.tpc( ...
    'imgVoltage', Volt, ...
    'imgCurrent', 1, ...    % security limit for imaging current [A]
    0);

% USSE for the sequence
SEQ = usse.usse( ...
    'TPC', TPC, ...
    'acmo', ACMOList, ...    'Loopidx',1, ...
    'Repeat', NTrig, ...  'Popup',0, ...
    'DropFrames', 0, ...
    'Loop', 0, ...
    'DataFormat', 'FF', ...
    'Popup', 0, ...
    0);

[SEQ NbAcq] = SEQ.buildRemote();
display('Build OK')

%% Do NOT CHANGE - Sequence execution

% Initialize remote on systems
SEQ = SEQ.initializeRemote('IPaddress',AixplorerIP);
display('Remote OK')

% Load sequequence :
tic
SEQ = SEQ.loadSequence();
toc



