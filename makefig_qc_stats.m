function [f1] = makefig_qc_stats(S)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

count_thresh = S.all_count > 1e3;
f1=figure;
t = tiledlayout(1,2,'TileSpacing','Compact');
nexttile;
plot(100.*S.spk_count(count_thresh)./S.all_count(count_thresh),S.binctr(count_thresh));
xlabel('Percent that were spikes');
ylabel('PRES (dbar)');
set(gca,'YDir','reverse','FontSize',14,'LineWidth',1,'TickDir','out');
xlim([0 15]);

nexttile;
plot(S.all_count,S.binctr);
xlabel('total number of obs in bin');
set(gca,'YDir','reverse','FontSize',14,'LineWidth',1,'TickDir','out');
end

