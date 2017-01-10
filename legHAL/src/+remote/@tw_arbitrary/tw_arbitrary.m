% REMOTE.TW_ARBITRARY (REMOTE.TW)
%   Create a REMOTE.TW_ARBITRARY instance.
%
%   OBJ = REMOTE.TW_ARBITRARY() creates a generic REMOTE.TW_ARBITRARY instance.
%
%   OBJ = REMOTE.TW_ARBITRARY(NAME, DESC, DEBUG) creates a REMOTE.TW_ARBITRARY
%   instance with its name and description values set to NAME and DESC
%   (character values) and using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = REMOTE.TW_ARBITRARY(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates
%   a REMOTE.TW_ARBITRARY instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - WAVEFORM (single) sets the waveform for each channels.
%       [-1 1] - default = 0
%     - REPEATCH (int32) enables the waveform repetition for each channels.
%       0 = waveform defined for all, 1 = waveform to be repeated - default = 0
%
%   Inherited parameters:
%     - REPEAT (int32) sets the number of waveform repetitions.
%       0 = no repetition, [1 1023] = number of repetition - default = 0
%     - REPEAT256 (int32) enables the 256-repetitions mode.
%       0 = none, 1 = 256-repetition mode - default = 0
%     - APODFCT (char) sets the apodisation function.
%       none, bartlett, blackman, connes, cosine, gaussian, hamming, hanning,
%       welch - default = none
%     - TXELEMTS (int32) sets the TX channels.
%       [1 system.probe.NbElemts]
%     - DUTYCYLE (single) sets the maximum duty cycle.
%       [0 1]
%
%   Inherited variables:
%     - NAME contains the name of the object.
%     - TYPE contains the type of the object.
%     - DESC contains a description of the object.
%     - DEBUG enables the debugging mode.
%
%   Dedicated functions:
%     - INITIALIZE builds the remoteclass REMOTE.TW_ARBITRARY.
%     - SETWAVEFORM builds the REMOTE.TW_ARBITRARY waveform.
%
%   Inherited functions:
%     - BUILDREMOTE builds the associated remote structure.
%     - SETAPODIZATION applies apodisation and pwm to the waveform.
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the remoteclass REMOTE.TW_ARBITRARY.
%     - ADDPARAM adds a parameter/object (explicit definition and cell array
%       definition) to the remoteclass REMOTE.TW_ARBITRARY.
%     - GETPARAM retrieves the value/object of a REMOTE.TW_ARBITRARY parameter.
%     - SETPARAM sets the value of a REMOTE.TW_ARBITRARY parameter.
%     - ISEMPTY checks if all REMOTE.TW_ARBITRARY parameters are correctly
%       defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the remoteclass REMOTE.TW_ARBITRARY and its
%   superclass REMOTE.TW developed by SuperSonic Imagine and without a system
%   with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/10/28

classdef tw_arbitrary < remote.tw
   
% ============================================================================ %
% ============================================================================ %

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
    varargout = initalize(obj, varargin)   % build remoteclass REMOTE.TW_ARBITRARY
    varargout = setWaveform(obj, varargin) % build the REMOTE.TW_ARBITRARY waveform
    
end

% ============================================================================ %

% Class contructor
methods ( Access = 'public' )
    function obj = tw_arbitrary(varargin)
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
                varargin = { ...
                    'TW_ARBITRARY', ...
                    'default arbitrary waveform', ...
                    varargin{1:end}};
            else
                varargin{1} = upper(varargin{1});
            end
        else
            varargin = { ...
                'TW_ARBITRARY', ...
                'default arbitrary waveform', ...
                varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@remote.tw(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end