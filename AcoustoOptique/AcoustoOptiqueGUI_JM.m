% clear all; close all; clc
% w = instrfind; if ~isempty(w) fclose(w); delete(w); end

%% parameter for plane wave sequence :
% ======================================================================= %
% adresse Jussieu : '192.168.1.16'
% adresse Bastille : '192.168.0.20'

 AixplorerIP    = '192.168.1.16'; % IP address of the Aixplorer device
 addpath('sequences');
 addpath('subfunctions');
 addpath('D:\legHAL');
 addPathLegHAL();
 
       TypeOfSequence = 'JM'; % 'OF' , 'OP' , 'JM'
 
        Volt        = 10;   % 'OF' , 'OP' , 'JM'
        FreqSonde   = 2;    % 'OF' , 'OP' , 'JM'
        NbHemicycle = 450;   % 'OF' , 'OP' , 'JM'
        Foc         = 23;   % 'OF' 
        AlphaM      = 20;   % 'OP' 
        dA          = 1;    % 'OP' 
        X0          = 0;    % 'OF' , 'OP' 
        X1          = 38 ;  % 'OF' , 'OP' 
        NTrig       = 500;  % 'OF' , 'OP' , 'JM'
        Prof        = 200;   % 'OF' , 'OP' , 'JM'
        NbZ         = 3;       % 8; % Nb de composantes de Fourier en Z, 'JM'
        NbX         = 2;      % 20 Nb de composantes de Fourier en X, 'JM'
        DurationWaveform = 20;
        
        SaveData = 0 ;      % set to 1 to save data


 % estiation of loading time 
 fprintf('Loading should take about %d seconds\n\r',NbX*NbZ*3);

%% ============================   Initialize AIXPLORER
% %% Sequence execution
% % ============================================================================ %

switch TypeOfSequence
    case 'OF'
[SEQ,MedElmtList] = AOSeqInit_OF(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc, X0 , X1 , Prof, NTrig);
    case 'OP'
[SEQ,MedElmtList,AlphaM] = AOSeqInit_OP(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , dA , X0 , X1 ,Prof, NTrig);
    case 'JM'
Volt = min(Volt,20) ; 
[SEQ] = AOSeqInit_OJM(AixplorerIP, Volt , FreqSonde , NbHemicycle , NbX , NbZ , X0 , X1 ,Prof, NTrig,DurationWaveform);

end


c = common.constants.SoundSpeed ; % sound velocity in m/s
                    
%%  ========================================== Init Gage ==================
% Possible return values for status are:
%   0 = Ready for acquisition or data transfer
%   1 = Waiting for trigger event
%   2 = Triggered but still busy acquiring
%   3 = Data transfer is in progress

     
     SampleRate    =   10;
     Range         =   1;
     GageActive = 'on' ; % on to activate external trig, off : will trig on timout value
     
 Nlines = length(SEQ.InfoStruct.event);   
 
[ret,Hgage,acqInfo,sysinfo] = InitOscilloGage(NTrig*Nlines,Prof,SampleRate,Range,GageActive);

fprintf(' Segments last %4.2f us \n\r',1e6*acqInfo.SegmentSize/acqInfo.SampleRate);

% Set transfer parameters
transfer.Mode           = CsMl_Translate('Default', 'TxMode');
transfer.Start          = -acqInfo.TriggerHoldoff;
transfer.Length         = acqInfo.SegmentSize;
transfer.Channel        = 1;

    raw   = zeros(acqInfo.Depth,acqInfo.SegmentCount);
    

    %% ======================== start acquisition =============================
    ret = CsMl_Capture(Hgage);
    CsMl_ErrorHandler(ret, 1, Hgage);
     
    SEQinfosPrint( SEQ )        % printout SEQ infos 
    
    SEQ = StartMySequence(SEQ);
    %SEQ = SEQ.startSequence('Wait',0);
    SEQinfosPrint( SEQ )        % printout SEQ infos 
    
    
    tic
    status = CsMl_QueryStatus(Hgage);
    
    while status ~= 0
        status = CsMl_QueryStatus(Hgage);
    end

    fprintf('Aquisition lasted %f s \n\r',toc);
    
    % Transfer data to Matlab
    % Z  = linspace(0,Prof,acqInfo.Depth); 
    % loop over segment counts:

    
    
    tic 
    for SegmentNumber = 1:acqInfo.SegmentCount
        
        transfer.Segment       = SegmentNumber;                     % number of the memory segment to be read
        [ret, datatmp, actual] = CsMl_Transfer(Hgage, transfer);    % transfer
                                                                    % actual contains the actual length of the acquisition that may be
                                                                    % different from the requested one.
       raw((1+actual.ActualStart):actual.ActualLength,SegmentNumber) = datatmp' ;
        
    end
    
    fprintf('Data Transfer lasted %f s \n\r',toc);
    
    CsMl_ErrorHandler(ret, 1, Hgage);
    SEQ = SEQ.stopSequence('Wait', 0);  
    
    
    
%% ======================== data post processing =============================
    Hf = figure;
    set(Hf,'WindowStyle','docked');
    
    switch TypeOfSequence
        
        case 'OF'
            
    Datas = RetreiveDatas(raw,NTrig,Nlines,MedElmtList);
    z = (1:actual.ActualLength)*(c/(1e6*SampleRate))*1e3;
    x = (1:Nlines)*system.probe.Pitch;
    imagesc(x,z,1e3*Datas)
    xlabel('x (mm)')
    ylabel('z (mm)')
%     axis equal
%     axis tight

        case 'OP'
            
    Datas = RetreiveDatas(raw,NTrig,Nlines,MedElmtList);
    z = (1:actual.ActualLength)*(c/(1e6*SampleRate))*1e3;
    x = AlphaM;
    imagesc(x,z,1e3*Datas)
    xlabel('angle (�)')
    ylabel('z (mm)')
    title('Averaged raw datas')
    cb = colorbar;
    ylabel(cb,'AC tension (mV)')
    colormap(parula)
    set(findall(Hf,'-property','FontSize'),'FontSize',15) 


   % ylim([0 50])
   
   case 'JM'
       
        Datas = RetreiveDatas(raw,NTrig,Nlines,1:Nlines);
        % Calcul composante de Fourier
        z = (1:actual.ActualLength)*(c/(1e6*SampleRate))*1e3;
        x = (1:Nlines)*system.probe.Pitch;
        
            imagesc(x,z,1e3*Datas)
            xlabel('lines Nbx, Nbz')
            ylabel('z (mm)')    
            title('Averaged raw datas')
            cb = colorbar;
            ylabel(cb,'AC tension (mV)')
            colormap(parula)
            set(findall(Hf,'-property','FontSize'),'FontSize',15)

        XLambda = DurationWaveform*1e-6*1e3*c;
        CalcDelay = 2*XLambda;
        IntDelay = 3*XLambda;
                  
        tDum = [];

        nbs = 1;
  
   [NBX,NBZ] = meshgrid(-NbX:NbX,1:NbZ);
   Nfrequencymodes = length(NBX(:));

   for nbs = 1:Nfrequencymodes
                
            ExpFunc                         =  exp(2*1i*z*NBZ(nbs)*pi/XLambda);
            ExpFunc(z<=CalcDelay)           =   0;
            ExpFunc(z>(CalcDelay+IntDelay)) =   0;    
            
            F = Datas(:,nbs);
                
                %plot(z,F/max(F));
                %hold;
                %plot(z,real(ExpFunc),'r');
            tR = ExpFunc*F;
            tDum = [tDum tR];
      
   end
               
        DecalZ=0.5;
        NtF=32;
       [I X Y]=Reconstruct(tDum,NbX,NbZ,SampleRate,DecalZ,NtF,DurationWaveform,c);   

       figure(100);
       imagesc(X,Y,I);
    end

    
 
   
%% save datas :
%% save datas :
if SaveData == 1
MainFolderName = 'D:\Data\mai';
SubFolderName  = generateSubFolderName(MainFolderName);
CommentName    = 'PVA';
FileName       = generateSaveName(SubFolderName ,'name',CommentName,'TypeOfSequence',TypeOfSequence,'Volt',Volt,'AlphaM',AlphaM);


save([MainFolderName,FileName],'Volt','FreqSonde','NbHemicycle','Foc','DurationWaveform','NbZ','NbX',...
               'X0','X1','NTrig','Nlines','Prof','MedElmtList','raw','SampleRate','c','Range','TypeOfSequence');
savefig(Hf,[MainFolderName,FileName]);
saveas(Hf,[MainFolderName,FileName],'png');

fprintf('Data has been saved under : \r %s \r\n',FileName);

end

%% ================================= command line to force a trigger on Gage :
%  CsMl_ForceCapture(Hgage);
%% ================================= quite remote ===========================================%%
  %            SEQ = SEQ.quitRemote();

