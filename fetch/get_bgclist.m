function [dac,wmo] = get_bgclist(gdac_path,varargin)

if nargin > 1
    param = varargin{1};
else
    param = 'TEMP';
end

T = readtable(fullfile(gdac_path,'argo_synthetic-profile_index.txt'));
d = contains(T.parameters,param);
T = T(d,:);
x = split(T.file,'/');
T.dac = x(:,1);
T.wmo = x(:,2);
[wmo,iwmo] = unique(T.wmo);
dac = T.dac(iwmo);

end

