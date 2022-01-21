


%run ./../../../set_filepaths
% cd(cmap_files_path)
%cd('C:\AGF-350\Fieldwork\Scripts\Matlab\Matlab_toolboxes\COLORMAPS\CLIMATE_REANALYZER\cmap_files')

vv = {'msl','prec','SIC','T2','WS10'};

for i = 1:length(vv)

 I = im2double(imread(['colormap_' char(vv{i}) '_climatereanalyzer.png']));


    I = I(1,:,:); % we just need each color once, so we just need one column
    cmapnn = reshape(I, [], 3); % convert to N x 3 color map format
    cmapn = cmapnn(1:end,:);

    k1 = round(cmapn(:,1).*1000)./1000; 
    k2 = round(cmapn(:,2).*1000)./1000; 
    k3 = round(cmapn(:,3).*1000)./1000; 

    k11 = diff(k1);
        k111 = find(k11==0);
        id1 = k111;
    k22 = diff(k2);
        k222 = find(k22==0);
        id2 = k222;
    k33 = diff(k3);
        k333 = find(k33==0);
        id3 = k333;
    idd1 = intersect(id1,id2);
    idd2 = intersect(idd1,id3);

    cmap_cr(1).(vv{i}) = cmapn(idd2,:);

end




vv = {'WS10'};

for i = 1:length(vv)

 I = im2double(imread(['colormap_' char(vv{i}) '_windy.png']));


    I = I(1,:,:); % we just need each color once, so we just need one column
    cmapnn = reshape(I, [], 3); % convert to N x 3 color map format
    cmapn = cmapnn(1:end,:);

    k1 = round(cmapn(:,1).*1000)./1000; 
    k2 = round(cmapn(:,2).*1000)./1000; 
    k3 = round(cmapn(:,3).*1000)./1000; 

%     k11 = diff(k1);
%         k111 = find(k11==0);
%         id1 = k111;
%     k22 = diff(k2);
%         k222 = find(k22==0);
%         id2 = k222;
%     k33 = diff(k3);
%         k333 = find(k33==0);
%         id3 = k333;
%     idd1 = intersect(id1,id2);
%     idd2 = intersect(idd1,id3);

%     cmap_wi(1).(vv{i}) = cmapn(idd2,:);
    cmap_wi(1).(vv{i}) = cmapn;

end

% clc
% close all

% hold on
% plot(cmap_mslnn(:,2))
% plot(id2,cmap_mslnn(id2,2),'.r')



