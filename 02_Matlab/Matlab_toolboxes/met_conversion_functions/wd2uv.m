function [u, v] = wd2uv(U,WD_deg)
% Convert u-, v- Windcomponent into compass winddirection in degrees

u = - U .* sind(WD_deg);
v = - U .* cosd(WD_deg);
