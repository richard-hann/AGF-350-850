function  [y_bin_mean, y_bin_std, x_bin_center, x_bin_mean] = bin_avg(y, x, x_bin_edges)
%[y_bin_mean, y_bin_std, x_bin_center, x_bin_mean] = bin_avg(y, x, x_bin_edges)

[~, bin] = histc(x, x_bin_edges);
n = length(x_bin_edges)-1;
bin(bin==n+1) = n; % move x==xbinedges(end) to bin spanning from xbinedges(end-1):xbinedges(end), the same is done when using histcounts in newer releases of MATLAB

y_bin_mean = NaN(n,1);
y_bin_std = y_bin_mean; 
x_bin_mean = y_bin_mean; 
x_bin_center = x_bin_edges(1:end-1)+.5*diff(x_bin_edges);

for k = 1:max(bin)
    y_bin_mean(k) = nanmean(y(bin==k));
    y_bin_std(k)  = nanstd (y(bin==k));
    x_bin_mean(k) = nanmean(x(bin==k));
end