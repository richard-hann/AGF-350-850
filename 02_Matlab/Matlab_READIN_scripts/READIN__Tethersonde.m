clear
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ------------------------ READING DATA FROM TETHERSONDE -------------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% INPUT: BEFORE RUNNING SCRIPT, MAKE SURE THAT THE PATH TO THE DATA IS CORRECT IN THE FILE set_filepaths.m
[filepath,~,~] = fileparts(mfilename('fullpath'));
cd(filepath)


run ./../set_filepaths
addpath(genpath(toolboxpath))
gg = Tethersonde_path; 


% Changing directory to where data files reside 
cd(gg);

% Storing data filenames in structure fn
fn = dir('*.0*');


qq=1;

% Looping over filenames
for tt=1:length(fn)
    
    cd([gg char(fn(tt).name)])
    

    f=dir('*.DAT');
    if isempty(f)==0
        
    st=char(f(1).name);
    fid = fopen(st);
    
    disp(['reading file ' st])
    
    stt=char(fn(tt).name);
    
    stn = textscan(fid, '%s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','HeaderLines',3);

    if isempty(stn{2})==0
  

        t2 = stn{1}; % Get hour, min, sec


        for k=1:length(t2)
            teth(qq).time(k) = datenum([stt(7:8) '.' stt(5:6) '.' stt(1:4) ' ' char(t2(k))], 'dd.mm.yyyy HH:MM:SS'); % 
        end

        teth(qq).file = stt;

        teth(qq).P   = stn{2};                           % PRESSURE
        teth(qq).T   = stn{3};                           % TEMPERATURE IN CELCIUS
        teth(qq).RH  = stn{4};                           % RELATIVE HUMIDITY IN %
        teth(qq).alt = stn{5};                           % ALTITUDE ABOVE GROUND LEVEL
        teth(qq).WS  = stn{6};                           % WIND SPEED IN METRES/SECOND
        teth(qq).WD  = stn{7};                           % WIND DIRECTION IN DEGREES
        teth(qq).BAT = stn{8};                           % BATTERY LEVEL IN VOLTAGE
        teth(qq).TP  = stn{9};                           % POTENTIAL TEMPERATURE IN CELCIUS
        teth(qq).TD  = stn{10};                          % DEW POINT IN CELCIUS
        % teth(qq).SH = stn{11};                          
        % teth(qq).MR = stn{12};                         % MIXING RATIO
        % teth(qq).QQ = teth(qq).MR./(1 + teth(qq).MR);  % SPECIFIC HUMIDITY IN g/kg

            % CALCULATING SPECIFIC HUMIDITY
            teth(qq).Q2 = calc_spec_humid(teth(qq).T,teth(qq).RH,teth(qq).P);

        ttime = mean(teth(qq).time); % "mean time" for each sounding


        qq=qq+1;
    end

    end

end

% Removing unphysical values (spikes)

for i=1:length(teth)
    
  teth(i).alt(teth(i).alt > 1500 | teth(i).alt < -40)=nan;
    
  teth(i).P(teth(i).P > 1100 | teth(i).P < 500)=nan;
  teth(i).TC(teth(i).T > 50 | teth(i).T < -50)=nan;
  teth(i).RH(teth(i).RH < 0 | teth(i).RH > 100)=nan;
  teth(i).WS(teth(i).WS <= 0 | teth(i).WS > 40)=nan;
  teth(i).WD(teth(i).WD < 0 | teth(i).WD > 360)=nan;
  teth(i).TP(teth(i).TP > 100 | teth(i).TP < -100)=nan;
  teth(i).TD(teth(i).TD > 100 | teth(i).TD < -100)=nan;
  
end


clearvars -except teth

disp(['-----------------------------------'])
disp(['Done reading files from Tethersonde'])
disp(['-----------------------------------'])



