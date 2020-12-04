function [Bout,Uout,Lout] = remove_spike(B,varargin)
% REMOVE_SPIKE 
% replaces spikes using a running median filter. Any spike values are
% replaced with the median value of a window of size 'win' centered on the
% spike. Outliers are identified using ISOOUTLIER based on a median
% absolute difference test.
%
% INPUTS
% B:  a 2D array of observations of shape NOBS x NPROF. NaN values are okay
% win (optional): scalar value for window size. Must be odd so it is centered 
%       [default = 11]
% method (optional): outlier method for isoutlier [default = 'median']
% 
% OUTPUTS
% Bout: Array with 
%
% USAGE:
% BBP_clean = remove_spike(BBP);
%
% [BBP_clean,U,L] = remove_spike(BBP,13,'grubbs')
%
% AUTHOR:
% David Nicholson // dnicholson@whoi.edu // 02 Dec 2020
% -------------------------------------------------------------------------

% preallocate output arrays
Bout = B;
Uout = nan.*B;
Lout = nan.*B;
dimB = size(Bout);
nprof = dimB(2);

%% validate inputs

% default values 
win = 11;
method = 'median';

B_valid = dimB(1) > win;
win_valid = mod(win,2) & win > 0 & isscalar(win); 
method_valid = ismember(method,{'median','mean','quartiles','grubbs','gesd'});

if ~B_valid
    error('B profile length must be longer than win');
end

if nargin > 1
    if ~win_valid
        error('win must be an odd scalar');
    else
        win = varargin{1};
    end
end
if nargin > 2
    if ~method_valid
        error("method must be 'median','mean','quartiles','grubbs','gesd'")
    else
        method = varargin{2};
    end
end
    


%% loop through each profile
for it = 1:nprof
    d = ~isnan(Bout(:,it));
    bprof = Bout(d,it);
    bprof_corr = bprof;
    hi = nan.*bprof;
    lo = hi;
    nb = length(bprof);
    if nb > 2*win
        % loop through each measurement
        for ip = 1:nb
            % Outlier test 
            [iwin,pos] = window_index(ip,win,nb);
            [TF,L,U,C] = isoutlier(bprof(iwin),method);
            isout = TF(pos);
            hi(ip) = U;
            lo(ip) = L;
            % replace outlier with median value of window
            if isout
                bprof_corr(ip) = C;
            end
            
        end
        Uout(d,it) = hi;
        Lout(d,it) = lo;
    end
    Bout(d,it) = bprof_corr;    
    
end

% WINDOW_INDEX
% creates 'skewed' windows at the top and bottom of profiles
% e.g., the top points all use the window from 1:win until profile point
% win/2 + 1. The same for the bottom. returns the indices for the window
% and the position in the window where a spike is evaluated. 
function [winind, pos] = window_index(ctr,win,nobs)
    % default centered window for all of the middle section of profile
    side = (win-1)/2;
    pos = side + 1;
    winind = ctr-side:ctr+side;
    % skew the window at top of profile
    if winind(1) < 1
        % shift is positive
        shift = 1 - winind(1);
        winind = winind + shift;
        pos = pos - shift;
    % skew the profile at bottom of profile
    elseif winind(end) > nobs
        shift = nobs - winind(end);
        winind = winind + shift;
        pos = pos - shift;
    end
end
end
