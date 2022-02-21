
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ------------------------ READING TINYTAG DATA ---------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
clear

display('Reading TinyTag data')



%% INPUT: BEFORE RUNNING SCRIPT, MAKE SURE THAT THE PATH TO THE DATA IS CORRECT IN THE FILE set_filepaths.m

[filepath,~,~] = fileparts(mfilename('fullpath'));
cd(filepath)
run ./../set_filepaths


cd(TinyTags_path)


% LIST OF NAMES OF TINYTAGS 
% ttnames = {'CEB1','TT1','TH1'};
% ttnames = {'CEB1','TT1'};
% ttnames = {'TH6'};
% ttnames = {'TH2'};
% ttnames = {'CEB2'};
% ttnames = {'TT14','TT17'};
ttnames = {'TT2','TT12','TT4','TT7','TT8','TT3','TT13'};

% ttnames = {'TT2','TT7','TT9','TT5','TT4','TT8','TT11','TT10','TT6','TT12'};
% ttnames = {'TT2','TT11','TT13'};

%   CEB tinytags have one temperature sensor
%   TT tinytags have two temperature sensors
%   TH tinytags have one temperature and one humidity sensor

% Reading in TinyTag data:

for qq = 1:length(ttnames) % looping over the different TinyTags
    
    ttname = ttnames(qq);

    if contains(ttname,'CEB')
        fn = dir(['*' char(ttname) '.txt']);  % storing filenames in the fn structure
            TinyTag(1).(char(ttname))(1).timen = []; % preparing empty structure for inserting data
            TinyTag(1).(char(ttname))(1).Tn    = []; % preparing empty structure for inserting data
        
            
            for i = 1:length(fn) % looping over and reading files with CEB tinytag data
                dataArray = textscan(fopen(fn(i).name), '%*s%s%[^\n\r]', 'Delimiter', {'\t'}, 'TextType', 'string', 'HeaderLines' ,6, 'ReturnOnError', false, 'EndOfLine', '\r\n');
                timen = datenum(dataArray{1,1}); % this is the time stamp
                Tn   = str2num(char(regexprep(dataArray{1,2}, '[^a-z0-9_.\-]',''))); % this is the temperature data

                % concatenating (putting together) data from each of the data files from each of the tinytags
                TinyTag(1).(char(ttname))(1).timen = [TinyTag(1).(char(ttname))(1).timen(:)' timen(:)']; % time
                TinyTag(1).(char(ttname))(1).Tn  = [TinyTag(1).(char(ttname))(1).Tn(:)' Tn(:)'];         % temperature
            end
            
            % sorting data from the files in case they are not in the right order
            [a b] = sort(TinyTag(1).(char(ttname))(1).timen);
            TinyTag(1).(char(ttname))(1).time = TinyTag(1).(char(ttname))(1).timen(b);
            TinyTag(1).(char(ttname))(1).T    = TinyTag(1).(char(ttname))(1).Tn(b);

            % removing temporary fields in TinyTag structure
            TinyTag(1).(char(ttname)) = rmfield(TinyTag(1).(char(ttname)),'timen');
            TinyTag(1).(char(ttname)) = rmfield(TinyTag(1).(char(ttname)),'Tn');
            
            
    elseif contains(ttname,'TT') % Reading TT tinytag data. For comments to the code, see lines above for CEB tinytag data
            fn = dir(['*' char(ttname) '.txt']);
            TinyTag(1).(char(ttname))(1).timen    = [];
            TinyTag(1).(char(ttname))(1).T_blackn = []; 
            TinyTag(1).(char(ttname))(1).T_whiten = [];
        
        
            for i = 1:length(fn)
                dataArray = textscan(fopen(fn(i).name), '%*s%s%[^\n\r]', 'Delimiter', {'\t'}, 'TextType', 'string', 'HeaderLines' ,6, 'ReturnOnError', false, 'EndOfLine', '\r\n');
                timen = datenum(dataArray{1,1});
                tt = str2num(char(regexprep(dataArray{1,2}, '[^a-z0-9_.\t\-]','')));
                T_blackn = tt(:,1);
                T_whiten = tt(:,2);

                TinyTag(1).(char(ttname))(1).timen     = [TinyTag(1).(char(ttname))(1).timen(:)' timen(:)'];
                TinyTag(1).(char(ttname))(1).T_blackn  = [TinyTag(1).(char(ttname))(1).T_blackn(:)' T_blackn(:)'];
                TinyTag(1).(char(ttname))(1).T_whiten  = [TinyTag(1).(char(ttname))(1).T_whiten(:)' T_whiten(:)'];
            end
            

            [a b] = sort(TinyTag(1).(char(ttname))(1).timen);
            TinyTag(1).(char(ttname))(1).time       = TinyTag(1).(char(ttname))(1).timen(b);
            TinyTag(1).(char(ttname))(1).T_black    = TinyTag(1).(char(ttname))(1).T_blackn(b);
            TinyTag(1).(char(ttname))(1).T_white    = TinyTag(1).(char(ttname))(1).T_whiten(b);

            TinyTag(1).(char(ttname)) = rmfield(TinyTag(1).(char(ttname)),'timen');
            TinyTag(1).(char(ttname)) = rmfield(TinyTag(1).(char(ttname)),'T_blackn');
            TinyTag(1).(char(ttname)) = rmfield(TinyTag(1).(char(ttname)),'T_whiten');

     elseif contains(ttname,'TH') % Reading TH tinytag data. For comments to the code, see lines above for CEB tinytag data
            fn = dir(['*' char(ttname) '.txt']);
            TinyTag(1).(char(ttname))(1).timen    = []; 
            TinyTag(1).(char(ttname))(1).Tn       = [];
            TinyTag(1).(char(ttname))(1).RHn      = []; 
        
            for i = 1:length(fn)
                dataArray = textscan(fopen(fn(i).name), '%*s%s%[^\n\r]', 'Delimiter', {'\t'}, 'TextType', 'string', 'HeaderLines' ,6, 'ReturnOnError', false, 'EndOfLine', '\r\n');
                timen = datenum(dataArray{1,1});
                tt  = str2num(char(regexprep(dataArray{1,2}, '[^a-z0-9_.\t\-]','')));
                Tn  = tt(:,1);
                RHn = tt(:,2);

                TinyTag(1).(char(ttname))(1).timen     = [TinyTag(1).(char(ttname))(1).timen(:)' timen(:)'];
                TinyTag(1).(char(ttname))(1).Tn        = [TinyTag(1).(char(ttname))(1).Tn(:)' Tn(:)'];
                TinyTag(1).(char(ttname))(1).RHn       = [TinyTag(1).(char(ttname))(1).RHn(:)' RHn(:)'];
            end
            
            [a b] = sort(TinyTag(1).(char(ttname))(1).timen);
            TinyTag(1).(char(ttname))(1).time       = TinyTag(1).(char(ttname))(1).timen(b);
            TinyTag(1).(char(ttname))(1).T          = TinyTag(1).(char(ttname))(1).Tn(b);
            TinyTag(1).(char(ttname))(1).RH         = TinyTag(1).(char(ttname))(1).RHn(b);
            
            TinyTag(1).(char(ttname)) = rmfield(TinyTag(1).(char(ttname)),'timen');
            TinyTag(1).(char(ttname)) = rmfield(TinyTag(1).(char(ttname)),'Tn');
            TinyTag(1).(char(ttname)) = rmfield(TinyTag(1).(char(ttname)),'RHn');
    end

    
end


disp(['--------------------------------'])
disp(['Done reading files from TinyTags'])
disp(['--------------------------------'])


     
% clearvars -except RAD* CS* sonicdata* TinyTag*
