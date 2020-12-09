function [f1,f2] = makefig_qc_stats(S)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
d = isnan(S.spk_all);
S.p_all(d) = [];
S.bbp_clean_all(d) = [];
S.iS.pk_all(d) = [];
S.spk_all(d) = [];

dbin = 2;
bin_edge = [0:dbin:2000];
binctr = bin_edge(1:end-1)+dbin/2;
[spk_count] = histcounts(S.p_all(logical(S.iS.pk_all)),bin_edge);
[all_count] = histcounts(S.p_all,bin_edge);

count_thresh = all_count > 1e3;
f1=figure;
plot(100.*spk_count(count_thresh)./all_count(count_thresh),binctr(count_thresh));
xlabel('Percent that were spikes');
set(gca,'YDir','reverse','FontSize',14,'LineWidth',1,'TickDir','out');
f2=figure;
plot(all_count,binctr);
xlabel('total number of obs in bin');
set(gca,'YDir','reverse','FontSize',14,'LineWidth',1,'TickDir','out');
end

