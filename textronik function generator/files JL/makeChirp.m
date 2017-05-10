function [signal , signalTgrid] = makeChirp(fe, deltaF, dureeSignal)

 % [signal , signalTgrid] = makeChirp(fe, deltaF, dureeSignal)
 %
 % Cette fonction calcul un signal chirp
 % 
 % FE : fr�quence d'echantillonage du signal
 % DELTAF : vecteur contenant [ fmin max ], fr�quence minimale et maximale
 % du chirp
 % DUREESIGNAL : duree en micro seconde du signal

 %Vecteur temporel
signalTgrid = 0:(1/(fe)):dureeSignal;

%Les deux fr�quences max et min
fmin = deltaF(1);
fmax = deltaF(2);

%V�rifier que f mini est inf�rieur � f maxi
if fmin >=fmax
    disp('fmin est superieur � fmax')
else
    %Calcul l'enveloppe
    enveloppe = 0.5*(1-cos(2*pi*(1:length(signalTgrid))/length(signalTgrid)));

    %Calcule la rampe en fr�quence
    ff = fmin + (fmax-fmin)/dureeSignal*signalTgrid;

    %Calcule le signal brut
    lfm = real(exp(1i*2*pi*ff.*signalTgrid));

    %Multiplie le signal brut par l'enveloppe
    signal = lfm.*enveloppe;
    
    signal = (signal./max(abs(signal)));
end

figure, plot(signalTgrid,signal),grid on


