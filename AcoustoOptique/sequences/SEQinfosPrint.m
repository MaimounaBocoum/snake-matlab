function [  ] = SEQinfosPrint( SEQ )
% this functions returns ifnformation of the current sequence :
% created by maimouna bocoum 13-07-2017

    Msg    = struct('name', 'get_status');
    Status = remoteSendMessage(SEQ.Server, Msg) 
    
%SEQ.Server     ;

% event informations :
% SEQ.InfoStruct.event.DMA ??
% SEQ.InfoStruct.event.duration
% SEQ.InfoStruct.event.TrigOutDelay
% SEQ.InfoStruct.event.numSamples

%  SEQ.InfoStruct
% SEQ.InfoStruct.rx
% SEQ.InfoStruct.mode

%SEQ.InfoStruct.tx
%SEQ.InfoStruct.tx.repeat
% printout waveform or firt event 
% figure;
% imagesc(SEQ.InfoStruct.tx(1).waveform)
% title(['event 1 out of ',num2str( length(SEQ.InfoStruct.tx) )])
% xlabel('piezo element index')
% ylabel('Command voltage')
% colormap(gray)
% cb  = colorbar ;
% ylabel(cb,'piezo element index')

end

