% SYSTEM.PROBE
%   Class containing probe constants (Stanford).
%
%   Constants:
%     - NAME corresponds to the name of probe.
%     - TYPE corresponds to the type of probe.
%     - NBELEMTS corresponds to the number of elements.
%     - PITCH corresponds to size of the pitch (mm).
%     - WIDTH corresponds to width between 2 elements (mm).
%     - RADIUS corresponds to curvature radius (mm).
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without a system with a REMOTE SERVER running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/02/24

classdef probe
   
% ============================================================================ %
% ============================================================================ %

% Probe description
properties ( Constant = true )
    
    % Probe description
    Name = 'Liver';
    Tag  = 'LIVER';
    Type = 'custom';
    
    % Physical variables
    NbElemts = 256; % # of elements
    Pitch    = 0.2; % probe pitch [mm]
    Width    = 0.2; % width of each element [mm]
    Radius   = 0; % probe radius [mm]
    
end
    
% ============================================================================ %
% ============================================================================ %

end