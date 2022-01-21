function [hfs,hfl] = hfb2hfsl(hfb,dtheta,dr,T)
% function [hfs,hfl] = hfb2hfsl(hfb,dtheta,dr,p)
% convert buoyancy flux to sensible and latent heat flux applying the bowen
% ratio
% hfb = buoyancy flux
% hfs = sensible heat flux
% hfl = latent heat flux
% dtheta = potential temperature difference
% dr = mixing ratio difference
% p = atmopsheric pressure
% T_K = atmospheric temperature

lambda = 2.26e6; % J kg-1
cp = 1004; % J kg-1 K-1  

gamma = cp./lambda; % K-1
Bo = gamma .* dtheta./dr; % 1

hfs = hfb ./ (1 + .51 .* T .* cp ./ lambda ./ Bo);
hfl = hfs ./ Bo;