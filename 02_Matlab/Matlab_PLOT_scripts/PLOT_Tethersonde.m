close all


%% First plot the altitude data so that you can see when the different profiles are taken:

close all

%% CHOSE FILE ID
qq = 1; % File ID

%% Plot altitude over index
figure(1)
plot(teth(qq).alt)
xlabel('Index')
ylabel('Altitude [m]')

%% Plot altitude over time
figure (2)
plot(teth(qq).time,teth(qq).alt)
datetick('x','yy-mm-dd HH:MM')
xlabel('Time')
ylabel('Altitude [m]')

%% Plot altitude over Temperature
figure (3)
plot(teth(qq).T,teth(qq).alt)
xlabel('Temperature [°C]')
ylabel('Altitude [m]')

%% Plot altitude over wind speed
figure (4)
plot(teth(qq).WS,teth(qq).alt)
xlabel('Wind speped [m/s]')
ylabel('Altitude [m]')