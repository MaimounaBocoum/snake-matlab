function DurationTotal = SEQinfosPrint( SEQ )
% this functions returns ifnformation of the current sequence :
% created by maimouna bocoum 13-07-2017

%     Msg    = struct('name', 'get_status');
%     Status = remoteSendMessage(SEQ.Server, Msg) ;
    
%SEQ.Server     ;

% event informations :
 SEQ.InfoStruct.event.duration

 DurationTotal = 0 ; % us
 for Nevent = 1:length(SEQ.InfoStruct.event)
 DurationTotal  = DurationTotal  + SEQ.InfoStruct.event(Nevent).duration ;
 end

 fprintf('The sequence is about %f us long\r\n',DurationTotal)
 
 
 % movie on sequences
 figure;
 for i = 1:length(SEQ.InfoStruct.tx)
     size(SEQ.InfoStruct.tx(i).waveform)
     imagesc(SEQ.InfoStruct.tx(i).waveform)
     pause(0.2)
     drawnow
 end
 
% SEQ.InfoStruct.event.TrigOutDelay
% SEQ.InfoStruct.event.numSamples

%  SEQ.InfoStruct
% SEQ.InfoStruct.rx
% SEQ.InfoStruct.mode

%SEQ.InfoStruct.tx
%SEQ.InfoStruct.tx.repeat
% printout waveform or firt event 
% figure;
% imagesc(SEQ.InfoStruct.tx(10).waveform)
% title(['event 1 out of ',num2str( length(SEQ.InfoStruct.tx) )])
% xlabel('piezo element index')
% ylabel('Command voltage')
% colormap(gray)
% cb  = colorbar ;
% ylabel(cb,'piezo element index')

end

