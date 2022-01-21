function [WD_deg,U] = uv2wd(u,v)
% Convert u-, v- Windcomponent into compass winddirection in degrees

WD_deg = wrapTo360(atan2d(-u, -v)) ;
U=abs(u+1i*v);
