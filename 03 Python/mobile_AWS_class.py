"""
Created on Sat Apr 10 12:21:23 2021

@author: lukas
"""


import numpy as np
import datetime
from netCDF4 import Dataset
import sys
import os
import utm
import pandas as pd


class mobile_AWS():

    def __init__(self,  station=1,                        # station number: 1 or 2
                        resolution="1min",                # temporal resolution of the data
                        starttime="202104090800",         # INPUT Define start- and end-points in time for retrieving the data
                        endtime="202104091800",           # Format: YYYYmmddHHMM
                        variables=['temperature', 'pressure', 'relative_humidity', 'wind_speed', 'wind_speed_raw', 'wind_direction_raw', 'wind_direction', 'latitude', 'longitude'],
                        file_type="nc", total_time=datetime.timedelta(days=1), path=False
                        ):

        self.starttime = datetime.datetime.strptime(starttime, "%Y%m%d%H%M").replace(tzinfo=datetime.timezone.utc)
        self.endtime = datetime.datetime.strptime(endtime, "%Y%m%d%H%M").replace(tzinfo=datetime.timezone.utc)
        day_vector = list(np.arange(self.starttime, self.endtime+datetime.timedelta(hours=1), datetime.timedelta(days=1), dtype=datetime.datetime))

        self.total_time = total_time
        self.file_type = file_type

        self.variables = variables
        self.resolution = resolution
        self.station = station

        if not path:
            # determine path to data files depending on system
            if sys.platform == 'linux':
                if os.path.isdir("/media/lukas/ACSI/Data/mobile_AWS/"):
                    self.path = "/media/lukas/ACSI/Data/mobile_AWS/"
                else:
                    self.path = "/media/lukas/ACSI_backup/Data/mobile_AWS/"
            elif sys.platform == "win32":
                self.path = "D:/Data/mobile_AWS/"
        else:
            self.path = path

        # Load all files needed
        self.data = self.read_mobile_AWS(day_vector.pop(0), file_type)
        if file_type == "nc":
            for day in day_vector:
                new_data = self.read_mobile_AWS(day, file_type)
                for vari in self.variables:
                    self.data[vari] = np.concatenate((self.data[vari], new_data[vari]), axis=0)
                self.data['time'] = np.append(self.data['time'], new_data['time'])

        self.resolution_min = (self.data['time'][-1] - self.data['time'][-2]).seconds / 60.


        ind = np.where((self.data['time'] >= self.starttime) & (self.data['time'] <= self.endtime))[0]
        for vari in self.variables:
            self.data[vari] = self.data[vari][ind]
        self.data['time'] = self.data['time'][ind]
        self.data['local_time'] = self.data['local_time'][ind]





    def read_mobile_AWS(self, day, file_type='nc'):
        """
        Method to read CARRA data for the given day
        """

        data = {}

        if self.file_type == 'nc':
            data_file = '{a}mobile_AWS_{s}/{b}{c:02d}{d:02d}/nc/{b}{c:02d}{d:02d}_mobile_AWS_{s}_Table_{r}.nc'.format(a=self.path, s=self.station, b=day.year, c=day.month, d=day.day, r=self.resolution)
            print('reading {a}'.format(a=os.path.basename(data_file)))

            with Dataset(data_file, 'r') as f:

                for vari in self.variables:
                    data[vari] = np.array(f.variables[vari][:])

                data['time'] = np.array([datetime.datetime.utcfromtimestamp(int(i)) for i in f.variables['time'][:]], dtype=datetime.datetime)
                data['local_time'] = np.array([datetime.datetime.fromtimestamp(int(i)) for i in f.variables['time'][:]], dtype=datetime.datetime)

        elif self.file_type == 'raw':
            data_file = '{a}mobile_AWS_{s}/mobile_AWS_{s}_Table_{r}.dat'.format(a=self.path, s=self.station, r=self.resolution)
            print('reading {a}'.format(a=os.path.basename(data_file)))

            col_names = pd.read_csv(data_file, header=1, sep=",", nrows=1).to_dict('records')[0]

            df_data = pd.read_csv(data_file, header=4, sep=",", na_values="NAN", names=list(col_names.keys()))

            # transfer timestamps into Python datetime objects
            df_data["time"] = pd.to_datetime(df_data["TIMESTAMP"]).dt.to_pydatetime()
            df_data['wind_speed_max_timestamp'] = pd.to_datetime(df_data["Wind_Speed_corrected_TMx"]).dt.to_pydatetime()
            df_data['wind_speed_max_raw_timestamp'] = pd.to_datetime(df_data["Wind_Speed_raw_TMx"]).dt.to_pydatetime()

            # extract lat, lon and lat from GPS Location
            latitude = np.ones((len(df_data["TIMESTAMP"]))) * np.nan
            longitude = np.ones((len(df_data["TIMESTAMP"]))) * np.nan
            altitude = np.ones((len(df_data["TIMESTAMP"]))) * np.nan
            for c, gps in enumerate(df_data["GPS_Location"]):
                if type(gps) == float:
                    latitude[c] = np.nan
                    longitude[c] = np.nan
                    altitude[c] = np.nan
                else:
                    latitude[c] = float(gps.split(":")[0])
                    longitude[c] = float(gps.split(":")[1])
                    altitude[c] = float(gps.split(":")[2])

                    if ((latitude[c] < 77.95926) or (latitude[c] > 78.85822) or (longitude[c] < 13.38286) or (longitude[c] > 17.46182)):
                        latitude[c] = np.nan
                        longitude[c] = np.nan
                        altitude[c] = np.nan

            df_data['latitude'] = latitude
            df_data['longitude'] = longitude
            df_data['altitude'] = altitude

            df_data = df_data.rename({"Ambient_Temperature": 'temperature',
                                "Ambient_Temperature_Max": 'temperature_max',
                                "Ambient_Temperature_Min": 'temperature_min',
                                "Barometric_Pressure": 'pressure',
                                "Relative_Humidity": 'relative_humidity',
                                "Relative_Humidity_Max": 'relative_humidity_max',
                                "Relative_Humidity_Min": 'relative_humidity_min',
                                "Sensor_Dewpoint": 'dewpoint',
                                "Wind_Speed_Corrected_S_WVT": 'wind_speed',
                                "Wind_Speed_corrected_Max": 'wind_speed_max',
                                "Wind_Speed_S_WVT": 'wind_speed_raw',
                                "Wind_Speed_raw_Max": 'wind_speed_max_raw',
                                "Wind_Direction_Corrected_D1_WVT": 'wind_direction',
                                "Wind_Direction_Corrected_SDI_WVT": 'wind_direction_std',
                                "Wind_Direction_D1_WVT": 'wind_direction_raw',
                                "Wind_Direction_SDI_WVT": 'wind_direction_std_raw'}, axis='columns')

            df_data = df_data.dropna()

            data_all = df_data.to_dict('list')

            for vari in self.variables:
                data[vari] = np.array(data_all[vari])

            data['time'] = np.array(data_all['time'])
            for i in range(len(data['time'])):
                data['time'][i] = data['time'][i].replace(tzinfo=datetime.timezone.utc)
            data['local_time'] = np.array([i.tz_convert("Europe/Berlin") for i in data["time"]])

        return data


    def only_latest_data(self, period):
        """
        Method to use only the latest data, starting from 'period' before the last value.
        """

        ind = np.where((self.data['time'] >= self.data['time'][-1]-period))[0]
        for vari in self.variables:
            self.data[vari] = self.data[vari][ind]
        self.data['time'] = self.data['time'][ind]
        self.data['local_time'] = self.data['local_time'][ind]

        return


    def filter_GPScoverage(self):
        """
        Method to delete time steps with missing GPS coverage
        """

        ind = np.where((~np.isnan(self.data['latitude'])) & (~np.isnan(self.data['longitude'])))[0]

        for vari in self.variables:
            self.data[vari] = self.data[vari][ind]
        self.data['time'] = self.data['time'][ind]
        self.data['local_time'] = self.data['local_time'][ind]

        return



    def delete_harbors(self):
        """
        Method to delete time steps when the station was in one of the 3 harbors (LYR, BB, PYR)
        """

        # LYR
        ind = list(np.where((self.data['latitude'] > 78.22745) & (self.data['latitude'] < 78.22878) & (self.data['longitude'] > 15.60521) & (self.data['longitude'] < 15.61387))[0])

        for vari in self.variables:
            self.data[vari] = np.delete(self.data[vari], ind)
        self.data['time'] = np.delete(self.data['time'], ind)

        # BB
        ind = list(np.where((self.data['latitude'] > 78.06336) & (self.data['latitude'] < 78.06433) & (self.data['longitude'] > 14.19790) & (self.data['longitude'] < 14.20329))[0])

        for vari in self.variables:
            self.data[vari] = np.delete(self.data[vari], ind)
        self.data['time'] = np.delete(self.data['time'], ind)

        # PYR
        ind = list(np.where((self.data['latitude'] > 78.65447) & (self.data['latitude'] < 78.65518) & (self.data['longitude'] > 16.37723) & (self.data['longitude'] < 16.38635))[0])

        for vari in self.variables:
            self.data[vari] = np.delete(self.data[vari], ind)
        self.data['time'] = np.delete(self.data['time'], ind)

        return



    def masks_for_harbors(self):
        """
        Method to get bool arrays marking the time steps when the station was in one of the 3 harbors (LYR, BB, PYR)
        """

        # LYR
        self.data["mask_LYR"] = np.zeros_like(self.data['time'], dtype=bool)
        ind = np.where((self.data['latitude'] > 78.22745) & (self.data['latitude'] < 78.22878) & (self.data['longitude'] > 15.60521) & (self.data['longitude'] < 15.61387))[0]
        self.data["mask_LYR"][ind] = True

        # BB
        self.data["mask_BB"] = np.zeros_like(self.data['time'], dtype=bool)
        ind = np.where((self.data['latitude'] > 78.06336) & (self.data['latitude'] < 78.06433) & (self.data['longitude'] > 14.19790) & (self.data['longitude'] < 14.20329))[0]
        self.data["mask_BB"][ind] = True

        # PYR
        self.data["mask_PYR"] = np.zeros_like(self.data['time'], dtype=bool)
        ind = np.where((self.data['latitude'] > 78.65447) & (self.data['latitude'] < 78.65518) & (self.data['longitude'] > 16.37723) & (self.data['longitude'] < 16.38635))[0]
        self.data["mask_PYR"][ind] = True

        # sailing: True, when the boat is out
        self.data["mask_sailing"] = ~(self.data['mask_LYR'] | self.data['mask_PYR'] | self.data['mask_BB'])

        self.variables.extend(['mask_LYR', 'mask_PYR', 'mask_BB', 'mask_sailing'])

        return



    def calculate_windvector_components(self, corrected=True):
        """
        Method to calculate wind speed and wind direction from the vectorial components u and v.
        """

        if corrected:
            self.data['u'] = -np.abs(self.data['wind_speed']) * np.sin(np.deg2rad(self.data['wind_direction']))
            self.data['v'] = -np.abs(self.data['wind_speed']) * np.cos(np.deg2rad(self.data['wind_direction']))
            self.variables.extend(['u', 'v'])

        else:
            self.data['u_raw'] = -np.abs(self.data['wind_speed_raw']) * np.sin(np.deg2rad(self.data['wind_direction_raw']))
            self.data['v_raw'] = -np.abs(self.data['wind_speed_raw']) * np.cos(np.deg2rad(self.data['wind_direction_raw']))
            self.variables.extend(['u_raw', 'v_raw'])

        return


    def calculate_specific_humidity(self):
        """
        Method to calulate the specific humidity (g/kg) from the specific humidity, temperature and pressure measurements.
        """

        e = 0.01*self.data['relative_humidity']*(6.112 * np.exp((17.62*self.data['temperature'])/(243.12+self.data['temperature'])))

        self.data['specific_humidity'] = 1000.*(0.622*e)/(self.data['pressure']-0.378*e)
        self.variables.append('specific_humidity')

        return



    def calculate_wind_sector(self, corrected=True):
        """
        Method to calculate the wind direction sector (N, NE, E, SE, ...).
        """

        if corrected:
            self.data['wind_sector'] = (np.array((self.data['wind_direction']/45.)+.5, dtype=int) % 8) + 1
            self.variables.append('wind_sector')
        else:
            self.data['wind_sector_raw'] = (np.array((self.data['wind_direction_raw']/45.)+.5, dtype=int) % 8) + 1
            self.variables.append('wind_sector_raw')
        return


    def calculate_wind_in_knots(self, corrected=True):
        """
        Method to calculate the wind speeds (u, v, wspeed) in knots.
        Must be called after the components are calculated.
        """

        if corrected:
            self.data['u_knts'] = 1.94384 * self.data['u']
            self.data['v_knts'] = 1.94384 * self.data['v']
            self.data['wind_speed_knts'] = np.sqrt(self.data['u_knts']**2. + self.data['v_knts']**2.)
            self.variables.extend(['u_knts', 'v_knts', 'wind_speed_knts'])

        else:
            self.data['u_knts_raw'] = 1.94384 * self.data['u_raw']
            self.data['v_knts_raw'] = 1.94384 * self.data['v_raw']
            self.data['wind_speed_knts_raw'] = np.sqrt(self.data['u_knts_raw']**2. + self.data['v_knts_raw']**2.)
            self.variables.extend(['u_knts_raw', 'v_knts_raw', 'wind_speed_knts_raw'])

        return
