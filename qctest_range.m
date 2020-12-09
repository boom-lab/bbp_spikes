function [bbp_rt,flag] = qctest_range(bbp,varargin)
% Perform range test for a profile or whole float

% default values for range test (units m-1). A small negative value is
% allowed to account for sensor noise near zero (to avoid biasing low vals)
valid_range = [-0.000025, 0.1];

if nargin > 1
    valid_range = varargin{1};
    if length(valid_range) ~= 2 || ~isnumeric(valid_range)
        error('valid_range should be a two element array containing lower and upper limits');
    end
end

% value of 1 if outside of range
flag = false(size(bbp));
d = bbp(:) < valid_range(1) | bbp(:) > valid_range(2);
flag(d) = true;
bbp_rt = bbp;
bbp_rt(d) = NaN;

end

