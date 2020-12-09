function [f] = makefig_float(dac,wmo,nth_prof)
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


bbp0 = ncread(sprof_file,'BBP700');
[bbp1,irange] = qctest_range(bbp0);
noutrange = sum(irange(:));
p = ncread(sprof_file,'PRES');
nprof = size(bbp1,2);
[bbp2,isspike] = qctest_spike(bbp1,WINDOW_SIZE);
[bbp3, irange2] = qctest_range(bbp2,[0, 0.006]);



f = figure;
tiledlayout('flow','TileSpacing','none');
profs = 1:nth_prof:nprof;
for ii = profs   
    nexttile;
    hold on;
    title(['wmo: ', wmo, ' prof: ',num2str(ii)]);
    bbp_prof = bbp1(:,ii);
    bbp_clean_prof = bbp3(:,ii);
    p_prof = p(:,ii);
    d = ~isnan(bbp3(:,ii));
    ispk = d & isspike(:,ii);
    p1 = plot(bbp1(d,ii),p(d,ii),'-','Color',[0.5 0.5 0.5]);
    p2 = plot(bbp3(d,ii),p(d,ii),'.-k');
    plot(bbp_prof(ispk),p_prof(ispk),'.r','MarkerSize',10);
    plot(bbp_clean_prof(ispk),p_prof(ispk),'.g','MarkerSize',10);
    % if any outrange, plot at bbp = 0;
    if sum(irange(:,ii)) > 0
        irng = irange(:,ii) | irange2(:,ii);
        plot(0.*p_prof(irng),p_prof(irng),'.m','MarkerSize',10);
    end
    set(gca,'YDir','reverse');
end

end
