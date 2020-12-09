function [A,S,errors] = spike_stats(dac_list,wmo_list)
% Perform range test for a profile or whole float

% Process. a list of floats by wmo
% accumulate statistics on spikes
% may take a while to run if doing lots of floats (a few mins)
%
% INPUTS:
% dac_list: list of dacs (e.g., 'coriolis', 'aoml')
% wmo_list: list o wmo strings (e.g., '6902953')
%

local_config;
% a list of wmos - here using all the soccom floats
%load soccom_wmo.mat;
bbp_var = 'BBP700';
bbp_range1 = [-0.000025, 0.1];
bbp_range2 = [0 0.006];
WINDOW_SIZE = 11;

nfloat = length(wmo_list);
good_count = false(nfloat,1);
A.p_all = [];
A.bbp_clean_all = [];
A.bbp_all = [];
A.ispk_all = false(0,0);
A.spk_all = [];
A.wmo_all = [];
A.isoutrange_all = [];
A.isoutrange2_all = [];
errors = cell(nfloat,1);
for ii = 1:nfloat
    sprof_file = fullfile(gdac_path,'dac',dac_list{ii},wmo_list{ii},[wmo_list{ii},'_Sprof.nc']);
    try
        bbp0 = ncread(sprof_file,bbp_var);
        p = ncread(sprof_file,'PRES');
        % range test performed prior to despiking
        [bbp1,isoutrange] = qctest_range(bbp0,bbp_range1);
        bbp2 = qctest_spike(bbp1,WINDOW_SIZE);
        % perform 3rd QC step with tighter range
        [bbp3,isoutrange2] = qctest_range(bbp2,bbp_range2);
        ispike = abs(bbp1-bbp2) > 0;
        good_count(ii) = true;
        
        % accumulate arrays and store in output structure
        A.p_all = [A.p_all;p(:)];
        A.ispk_all = [A.ispk_all;ispike(:)];
        A.isoutrange_all = [A.isoutrange_all;isoutrange(:)];
        A.isoutrange2_all = [A.isoutrange2_all;isoutrange2(:)];
        A.bbp_all = [A.bbp_all;bbp1(:)];
        A.bbp2_all = [A.bbp2_all;bbp2(:)];
        A.bbp3_all = [A.bbp3_all;bbp3(:)];
        A.spk_all = [A.spk_all;bbp1(:)-bbp2(:)];
        A.wmo_all = [A.wmo_all;repmat(wmo_list{ii},length(p(:)),1)];
        
    catch ME
        errors{ii} = ME.message;
   end
end

S.dbin = 2;
S.bin_edge = 0:S.dbin:2000;
S.binctr = S.bin_edge(1:end-1)+S.dbin/2;
[S.spk_count] = histcounts(A.p_all(logical(A.ispk_all)),S.bin_edge);
[S.rng_count] = histcounts(A.p_all(logical(A.isoutrange_all)),S.bin_edge);
[S.rng2_count] = histcounts(A.p_all(logical(A.isoutrange2_all)),S.bin_edge);
[S.all_count] = histcounts(A.p_all,S.bin_edge);
S.spk_pct = sum(S.spk_count)./sum(S.all_count);
S.rng_pct = sum(S.rng_count)./sum(S.all_count);
S.rng2_pct = sum(S.rng2_count)./sum(S.all_count);
disp([num2str(100.*S.rng_pct), '% of ', num2str(sum(S.all_count)), ' points were flagged during initial range rest :', num2str(bbp_range1), ' (m^-1)']);
disp([num2str(100.*S.spk_pct), '% of ', num2str(sum(S.all_count)), ' points were flagged as spikes']);
disp([num2str(100.*S.rng2_pct), '% of ', num2str(sum(S.all_count)), ' points were flagged during second range rest :', num2str(bbp_range2), ' (m^-1)']);


% %% helper function to despike a single float
% function [bbp_clean,iS.pike] = despike(bbp)
%     [iS.pike,U,L,C] = isoutlier(bbp,'movmedian',11);
%     bbp_clean = bbp;
%     bbp_clean(iS.pike) = C(iS.pike);
% 
% end
