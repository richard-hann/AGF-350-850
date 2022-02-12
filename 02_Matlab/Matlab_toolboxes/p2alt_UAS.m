function [z, p] = p2alt_UAS(p_hPa, dp_hPa, T_degC, t_dn, z_m, z0_m, select, detrend)
% function [z, p] = p2alt_UAS(p_hPa, dp_hPa, T_degC, t_dn, z_m, z0_m, select, detrend)
%
% function to convert pressure into altitude based on hypsomatic equation
% solved for pressure intervals of dp_hPa and the mean ambient temperature
% within this interval
% input:
% - p_hPa: pressure vector in hPa (typically time series)
% - dp_hPa: pressure increment (scalar) in hPa for which a layer thickness will be calculated, e.g. 0.05 hPa
% - T_degC: tempereature vector in degC (time series)
% - t_dn: time vector in datenum (optional) computation of height vector as a function of time (assumed to be sampled every 1sec if no input is provided)
% - z_m: height vector in m (optional for manual selection and detrending)
% - z0_m: height of start and end altitude in m (optional, default 0m)
% - select: boolean for manual selection of start and end point from p time series
% - detrend: boolend for applying linear pressure detrending to align start and end altitudes

narginchk(3,8)
nargoutchk(1,2)

%%
% constants
R=287.0583;
g=9.81;
T_K=T_degC+273.15;

% inputs
if ~exist('z0_m','var')
    z0_m = 0;
end
if ~exist('t_dn','var')
    t_dn = 1:length(p_hPa)/24/3600;
end
if ~exist('z_m','var')
    z_m = z0_m + R.*T_K./g .* log(nanmax(p_hPa)./p_hPa);
elseif isempty(z_m)
    z_m = z0_m + R.*T_K./g .* log(nanmax(p_hPa)./p_hPa);  
end
if ~exist('select','var')
    select = 0;
end
if ~exist('detrend','var')
    detrend = 0;
end
%%

% detrend pressure
if select~=0 && detrend~=0
    figure(87), set(gcf,'units','normalized','outerposition',[0 0 1 1])
    s(1) = subplot(2,1,1); set(gca,'ydir','reverse')
    plot(t_dn, p_hPa); title('select takeoff and landing times'), datetick, ylabel p[hPa]
    s(2) = subplot(2,1,2);

    plot(t_dn, z_m); datetick, ylabel z[m]
    linkaxes(s,'x')
    [x,~] = ginput(2);
    % if isempty(x)
    %     input('provide something')
    % end
    ix = zeros(2,1);
    if length(x) == 2
        [~,ix(1)] = nanmin(abs(x(1)-t_dn));
        [~,ix(2)] = nanmin(abs(x(2)-t_dn));
        ip = find(~isnan(p_hPa)); ip = intersect(ip,ix(1):ix(2));
        ix = ip([1,end]);
    end
    if length(x)~=2 || diff(ix)==0
        ix = [find(~isnan(p_hPa),1,'first'),find(~isnan(p_hPa),1,'last')];
        detrend = 0;
        z_0m = nanmin(z_m);
    end
else
    ix = [find(~isnan(p_hPa),1,'first'),find(~isnan(p_hPa),1,'last')];
end
if detrend~=0
    tx = t_dn(ix(1):ix(end)); px = p_hPa(ix(1):ix(end));
    t_f = tx(~isnan(px)); p_f = px(~isnan(px));
    P1 = polyfit(t_f([1,end]),p_f([1,end]),1);
    p_offs = polyval(P1,t_dn) - nanmean(p_hPa(ix));
    p = p_hPa-p_offs;
else
    p = p_hPa;
end
    
% hypsomatic equation (solved for z)
T = NaN(size(T_K));
T(ix(1):ix(2)) = T_K(ix(1):ix(2));
% p_bins = round(nanmin(p_hPa)/dp_hPa)*dp_hPa-dp_hPa/2 : dp_hPa : round(nanmax(p_hPa)/dp_hPa)*dp_hPa+dp_hPa/2;
% [~,~,bin_idx] = histcounts(p_hPa,p_bins);
p_bins = round(nanmax(p)/dp_hPa)*dp_hPa+dp_hPa/2 : -dp_hPa : round(nanmin(p)/dp_hPa)*dp_hPa-dp_hPa/2;
dz_m(1) = 0;
Tm = bin_avg(T,-p,-p_bins);
Tm(isnan(Tm)) = interp1(p_bins(~isnan(Tm)),Tm(~isnan(Tm)),p_bins(isnan(Tm)),'linear','extrap');
for pp = 1:length(p_bins)-1
    dz_m(pp+1) = dp_hPa.*R.*Tm(pp)/g./(p_bins(pp)+dp_hPa/2);
end
z_bins = cumsum(dz_m);

% create time series of z
z = interp1(log(p_bins-dp_hPa/2),z_bins,log(p),'linear','extrap');
z = z - z(ix(1)) + z0_m;

if select~=0
    z(nanmin(1,ix(1)):nanmax(1,ix(1))) = nan;
    z(nanmin(length(z),ix(2)):nanmax(length(z),ix(1))) = nan;
end    
% plot
% hold(s(1),'on'), plot(s(1),t_dn,p), hold off
% hold(s(2),'on'), plot(s(2),t_dn,z), hold off


