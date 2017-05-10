function [signal, signalTgrid] = makeSinPulse(fe, f_central, dureeSignal)

% Cree un signal sinusoidal de frequence centrale F_CENTRAL, echantillone �
% FE, de NB_PERIODE, normalis� avec maximum � 1,
%
% FE : frequence d'�chantillonage
% F_CENTRAL : frequence centrale du pulse
% TGRID : vecteur temps sur lequel est calcul� le signal

signalTgrid = (0:1/fe:dureeSignal);

signal = sin(signalTgrid*2*pi*f_central).*hanning(length(signalTgrid))';
signal = signal/max(signal(:));

ls = length(signal);

end