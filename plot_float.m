function [f] = plot_float(dac,wmo,nth_prof)
% Plot profiles for a single float
% removed spikes are red dots and the corresponding filled median values 
% are green
%
% INPUTS
% dac: string for dac 'e.g., 'coriolis','aoml','bodc'
% wmo: string for the float wmo number

% try to convert numeric wmo
if isnumeric(wmo)
    wmo = num2str(wmo);
end

WINDOW_SIZE = 11;

% local settings with root directory for gdac
local_config;
sprof_file = fullfile(gdac_path,'dac',dac,wmo,[wmo,'_Sprof.nc']);


bbp = ncread(sprof_file,'BBP700');
p = ncread(sprof_file,'PRES');
nprof = size(bbp,2);
bbp_clean = remove_spike(bbp,WINDOW_SIZE);
isspike = abs(bbp-bbp_clean) > 1e-8;


f = figure;
tiledlayout('flow','TileSpacing','none');
for ii = 1:nth_prof:nprof
    title(['wmo: ', wmo, ' prof: ',num2str(ii)]);
    bbp_prof = bbp(:,ii);
    bbp_clean_prof = bbp_clean(:,ii);
    p_prof = p(:,ii);
    d = ~isnan(bbp_clean(:,ii));
    ispk = d & isspike(:,ii);
    p1 = plot(bbp(d,ii),p(d,ii),'-','Color',[0.5 0.5 0.5]);
    p2 = plot(bbp_clean(d,ii),p(d,ii),'.-k');
    hold on;
    plot(bbp_prof(ispk),p_prof(ispk),'.r','MarkerSize',10);
    plot(bbp_clean_prof(ispk),p_prof(ispk),'.g','MarkerSize',10);
    nexttile;
    set(gca,'YDir','reverse');
    hold on;
    
end

% %% helper function to despike a single float
% function [bbp_clean,isspike] = despike(bbp)
%     [isspike,U,L,C] = isoutlier(bbp,'movmedian',11);
%     bbp_clean = bbp;
%     bbp_clean(isspike) = C(isspike);
% 
% end
end
