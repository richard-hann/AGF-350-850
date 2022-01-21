

cd('/mnt/Data/Google Drive/DATA_AND_SCRIPTS/SCRIPTS/COLORMAPS/NCL/cmap_files')

[a b c] = textread('CBR_wet.rgb','%f %f %f','headerlines',2);
    nn = ([a';b';c']')./255;    
    nc = 100;
    cmap_ncl(1).wet = interp1(linspace(1, nc, size(nn,1)),nn,[1:1:nc]);
    clear a b c nn nc
    
[a b c] = textread('sunshine_9lev.rgb','%f %f %f','headerlines',6);
    nn = ([a';b';c']')./255;    
    nc = 100;
    cmap_ncl(1).sun = interp1(linspace(1, nc, size(nn,1)),nn,[1:1:nc]);
    clear a b c nn nc





