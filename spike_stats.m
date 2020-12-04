% Process a list of floats by wmo
% accumulate statistics on spikes
% may take a while to run if doing lots of floats (a few mins)
local_config;
% a list of wmos - here using all the soccom floats
load soccom_wmo.mat;

WINDOW_SIZE = 11;

nfloat = length(wmo_list);
good_count = false(nfloat,1);
p_all = [];
bbp_clean_all = [];
bbp_all = [];
isspk_all = false(0,0);
spk_all = [];
errors = cell(nfloat,1);
for ii = 1:nfloat
    sprof_file = fullfile(gdac_path,'dac','aoml',wmo_list{ii},[wmo_list{ii},'_Sprof.nc']);
    try
        bbp = ncread(sprof_file,'BBP700');
        p = ncread(sprof_file,'PRES');
        bbp_clean = remove_spike(bbp,WINDOW_SIZE);
        isspike = abs(bbp-bbp_clean) > 0;
        %[bbp_clean,isspike] = despike(bbp);
        good_count(ii) = true;
        % accumulate arrays
        p_all = [p_all;p(:)];
        isspk_all = [isspk_all;isspike(:)];
        bbp_clean_all = [bbp_clean_all;bbp_clean(:)];
        bbp_all = [bbp_all;bbp(:)];
        spk_all = [spk_all;bbp(:)-bbp_clean(:)];
        
    catch ME
        errors{ii} = ME.message;
   end
end

%% bin and plot results
d = isnan(spk_all);
p_all(d) = [];
bbp_clean_all(d) = [];
isspk_all(d) = [];
spk_all(d) = [];

dbin = 2;
bin_edge = [0:dbin:2000];
binctr = bin_edge(1:end-1)+dbin/2;
[spk_count] = histcounts(p_all(logical(isspk_all)),bin_edge);
[all_count] = histcounts(p_all,bin_edge);

count_thresh = all_count > 1e3;
figure;plot(100.*spk_count(count_thresh)./all_count(count_thresh),binctr(count_thresh));
xlabel('Percent that were spikes');
set(gca,'YDir','reverse','FontSize',14,'LineWidth',1,'TickDir','out');
figure;plot(all_count,binctr);
xlabel('total number of obs in bin');
set(gca,'YDir','reverse','FontSize',14,'LineWidth',1,'TickDir','out');

%% helper function to despike a single float
function [bbp_clean,isspike] = despike(bbp)
    [isspike,U,L,C] = isoutlier(bbp,'movmedian',11);
    bbp_clean = bbp;
    bbp_clean(isspike) = C(isspike);

end
