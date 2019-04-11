%% -- run when first launching program

%    clear all; clc
%    w = instrfind; if ~isempty(w) fclose(w); delete(w); end
%   restoredefaultpath % restaure original path

%% addpath and parameter for wave sequences :
% ======================================================================= %

% adresse Bastille : '192.168.0.20'
% adresse Jussieu :  '192.168.1.16'

 AixplorerIP    = '192.168.1.16'; % IP address of the Aixplorer device
 % path at Jussieu :
 if strcmp(AixplorerIP,'192.168.1.16')
 addpath('D:\AO---softwares-and-developpement\radon inversion\shared functions folder')
 end
 % path at Bastille :
 if strcmp(AixplorerIP,'192.168.0.20')
 addpath('D:\GIT\AO---softwares-and-developpement\radon inversion\shared functions folder');
 end
 
 addpath('gui');
 addpath('sequences');
 addpath('subfunctions');
 addpath('C:\Program Files (x86)\Gage\CompuScope\CompuScope MATLAB SDK\CsMl')
 addpath('..\read and write files')
 addpath('D:\_legHAL_Marc')
 addPathLegHAL;
 % 'OP' : Ondes Planes
 % 'OS' : Ondes Structur�es
 % 'JM' : Ondes Jean-Michel
 % 'OC' : Ondes Chirp�es
 
        TypeOfSequence  = 'JM'; % 'OP','OS','JM','OC'
        Volt            = 15; %Volt
        % 2eme contrainte : 
        % soit FreqSonde congrue � NUZ0 , soit entier*FreqSonde = NUech(=180e6)
        FreqSonde       = 3; %MHz AO : 78 et 84 MHz to be multiple of 6
        FreqSonde       = 180/round(180/FreqSonde); %MHz
        NbHemicycle     = 5 ;
        
        AlphaM          = 0; %(-20:20)*pi/180; specific OP

        
        % the case NbX = 0 is automatically generated, so NbX should be an
        % integer list > 0
        NbZ         = 10;        % 8; % Nb de composantes de Fourier en Z, 'JM'
        NbX         = 0;        % 20 Nb de composantes de Fourier en X, 'JM'
        Phase       = [0,0.25,0.5,0.75] ; % phases per frequency in 2pi unit

        % note : Trep  = (20us)/Nbz
        %        NUrep =   Nbz*(50kHz)         
        
        % on choisira DurationWaveform telle que DurationWaveform*(180MHz)
        
        DurationWaveform = 20;
        
        % contrainte : 
        % soit un multiple de 180 MHz
        n_low = round( 180*DurationWaveform );
        NU_low = (180)/n_low;   % fundamental temporal frequency
        
        Tau_cam          = 20 ;% camera integration time (us)
        
        Foc             = 10; % mm
        X0              = -20; %0-40
        X1              = 40;
        
        NTrig           = 1500;
        Prof            = 150;
        SaveData        = 0 ; % set to 1 to save

%% default parameters for user input (used for saving)

nuX0 = 0; 
nuZ0 = 0;
                 

%% ============================   Initialize AIXPLORER
% %% Sequence execution
% % ============================================================================ %
clear SEQ ScanParam raw Datas ActiveLIST Alphas Delay Z_m
switch TypeOfSequence
    case 'OF'
Volt = min(50,Volt); % security for OP routine  
[SEQ,ScanParam] = AOSeqInit_OF(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc, X0 , X1 , Prof, NTrig);
    case 'OP'
Volt = min(50,Volt); % security for OP routine       
[SEQ,DelayLAWS,ScanParam,ActiveLIST,Alphas] = AOSeqInit_OPL(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM ,X0 , X1 ,Prof, NTrig);
%[SEQ,Delay,ScanParam,Alphas] = AOSeqInit_OP_arbitrary(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , dA , X0 , X1 ,Prof, NTrig);
    case 'OS'
Volt = min(50,Volt); % security for OP routine     
[SEQ,DelayLAWS,ScanParam,ActiveLIST,Alphas,dFx] = AOSeqInit_OS(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , NbX , X0 , X1 ,Prof, NTrig);
    case 'JM'
Volt = min(Volt,20) ; 
[SEQ,ActiveLIST,nuX0,nuZ0,NUX,NUZ,ParamList] = AOSeqInit_OJMLusmeasure(AixplorerIP, Volt , FreqSonde , NbHemicycle , NbX , NbZ , X0 , X1 ,NTrig ,NU_low,Tau_cam , Phase);
    case 'OC'
Volt = min(Volt,15) ; 
[SEQ,MedElmtList,nuX0,nuZ0,NUX,NUZ,ParamList] = AOSeqInit_OC(AixplorerIP, Volt , FreqSonde , NbHemicycle , NbX , NbZ , X0 , X1 , NTrig ,DurationWaveform,Tau_cam);

end


c = common.constants.SoundSpeed ; % sound velocity in m/s

%% view sequence GUI
fprintf('============================= SEQ ANALYSIS =======================\n');

Nactive = 1;

% total number of sequences :
Nevent = length(SEQ.InfoStruct.event);
fprintf('Total number of event is %d\n',Nevent);

NbElemts    = system.probe.NbElemts ; 
SampFreq    = system.hardware.ClockFreq ;

% emission block event evaluated on Nactive over NbElemts transducers
WaveF = SEQ.InfoStruct.tx(Nactive).waveform(:,1:NbElemts) ;
figure;
imagesc( 1:NbElemts , (1:size(WaveF,1))/SampFreq , WaveF )
colormap(parula)
cb = colorbar;
ylabel(cb,'Logic Tension ')
xlabel('N element Index')
ylabel('Emission Time ( \mu s)')
title(['shot Number = ',num2str(Nactive)])

SEQ.InfoStruct.event(Nactive).duration

%% write log file to share between applications (Labview)

% list of data type : isDataType
% isfloat
% islogical
% isstring
MainFolderName     = 'D:\Data\Mai';
SubFolderName      = generateSubFolderName(MainFolderName);
% FileName_txt       = [SubFolderName,'\LogFile.txt'];
FileName_csv       = [SubFolderName,'\LogFile.csv'];

%  fid = fopen(FileName_txt,'w');
%  [rows,cols]=size(ParamList);
 
%  fprintf(fid,'%s\n','=========== begin header in SI units ========');
%  fprintf(fid,'TypeOfSequence : %s \n',TypeOfSequence);
%  fprintf(fid,'Volt           : %f \n',Volt);
%  fprintf(fid,'FreqSonde      : %E \n',FreqSonde*1e6);
%  fprintf(fid,'NbHemicycle    : %f \n',NbHemicycle);
%  fprintf(fid,'Tau_cam        : %E \n',Tau_cam*1e-6);
%  fprintf(fid,'DurWaveform    : %E \n',DurationWaveform*1e-6);
%  fprintf(fid,'Prof           : %E \n',Prof*1e-3);
%  fprintf(fid,'Nevent         : %i \n',Nevent);
%  fprintf(fid,'NTrig          : %i \n',NTrig);
%  fprintf(fid,'X0             : %E \n',X0*1e-3);
%  fprintf(fid,'X1             : %E \n',X1*1e-3);
%  fprintf(fid,'Foc            : %E \n',Foc*1e-3); %nuX0,nuZ0
 
 HearderCell(:,1) = {'TypeOfSequence';TypeOfSequence};
 HearderCell(:,2) = {'Volt';Volt};
 HearderCell(:,2) = {'FreqSonde';FreqSonde*1e6};
 HearderCell(:,3) = {'NbHemicycle';NbHemicycle};
 HearderCell(:,4) = {'Tau_cam';Tau_cam};
 HearderCell(:,5) = {'DurWaveform';DurationWaveform*1e-6};
 HearderCell(:,6) = {'Prof';Prof*1e-3};
 HearderCell(:,7) = {'Nevent';Nevent};
 HearderCell(:,8) = {'NTrig';NTrig};
 HearderCell(:,9) = {'X0'; X0};
 HearderCell(:,10) = {'nuX0'; nuX0};
 HearderCell(:,11) = {'nuZ0'; nuZ0};
 
 FinalCell = joincell( HearderCell , ParamList ) ;
 
 cell2csv(FileName_csv,  FinalCell , ';' ,'2015' ,'.' ) ;
 
 switch TypeOfSequence
     case {'OC','JM'}
% fprintf(fid,'nuX0           : %f\n', nuX0); %   
% fprintf(fid,'nuZ0           : %f \n',nuZ0); % 
% fprintf(fid,'%s\n','=========== end header========');
 


% xlswrite(FileName_xls ,HearderCell,1);
% xlswrite(FileName_xls ,ParamList,1,'J1');
 
%    for r=1:rows
%       fprintf(fid,'%5s %5s %5s %8s %8s\n',ParamList{r,:});
%    end
%    
  end
%  
% fclose(fid);



%fwritecell('exptable.txt',ParamList);
%%
% SEQ = SEQ.startSequence();
% SEQ = SEQ.stopSequence('Wait', 0);






