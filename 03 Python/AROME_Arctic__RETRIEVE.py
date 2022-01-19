#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script to retrieve AROME-Arctic data
"""

import matplotlib.pyplot as plt
import numpy as np
import datetime
from netCDF4 import Dataset
import AROME_Arctic__TOOLS
import sys
import os
from scipy import interpolate
import utm

import warnings
warnings.filterwarnings("ignore")

#########################################################################################
# ------------------------- READING DATA FROM AROME ARCTIC -----------------------------#
#########################################################################################

class AROME_Arctic():

    def __init__(self,  data_type="PROFILES",           # INPUT Settings for what type of data to retrieve.
                                                        # select from ["NEARSURFACE", "PROFILES", "HORIZONTAL_2D", "CROSSECTION", "PRESSURE_LEVELS"]

                        starttime="2020070500",         # INPUT Define start- and end-points in time for retrieving the historical data
                        endtime="2020070500",           # Format: YYYYmmddHH

                        high_resolution=False,          # INPUT Retrieve 2.5 km data (set the variable to False) or 500 m data (high_resolution=True)

                        latest=False,                   # INPUT Setting for what type of files to retrieve (historical forecast --> False)
                                                        # note, if selecting historical forecast, remember to define the start-time and end-times below
                                                        # !!!!! NB: LATEST = True ONLY WORKS FOR 2.5 km DATA, and NOT 500m DATA !!!!
                                                        # If False, set start- and end-time below.
                        p_levels = [1000, 850, 500], # Pressure levels in hPa in descending order

                        start_h=0,                      # INPUT Settings for what time stamps to retrieve, start time index in each data file
                        num_h=3,                       # Number of data-points (hours) to retrieve from each data file

                        int_h=1,                        # Time interval between data points in each data file
                        int_f=3,                        # Time interval in hours between each data file if retrieving historical data. This is typically the same as num_h.

                        int_x=1,                        # INPUT If retrieving horizontal2d data, set the intervals between the x and y coordinates here
                        int_y=1,                        # (higher number = coarser grid selection), for example, 1 = every grid point. 3 = every third grid point.

                        stt_lon = [11.9312], #, 13.61439, 19.0050],     # INPUT Station list for point data
                        stt_lat = [78.9243], #, 78.06150, 74.51677],    # [Ny Alesund, Isfjord Radio, Bjoernoeya]

                        lonlims = [5, 40],              # INPUT Geographic domain for horizontal 2d data
                        latlims = [75, 80],             # Specify min and max longitude and latitudes

                        crossec_start = [15.00, 78.35], # INPUT Start- and end-points for vertical cross section
                        crossec_end = [15.98, 78.18]    # [lon, lat]
                        ):


###############################################################################
#--------------- Take over input into attributes ------------------------------
###############################################################################

        self.high_resolution = high_resolution
        self.latest = latest
        self.data_type = data_type
        self.p_levels = p_levels
        self.start_h = start_h
        self.num_h = num_h
        self.int_h = int_h
        self.int_f = int_f
        self.int_x = int_x
        self.int_y = int_y

        if not self.latest:
            self.starttime = datetime.datetime.strptime(starttime, "%Y%m%d%H")
            self.endtime   = datetime.datetime.strptime(endtime, "%Y%m%d%H")
            self.timevec   = np.arange(self.starttime, self.endtime, datetime.timedelta(hours=int(self.int_f)), dtype=datetime.datetime)

        self.time_ind = np.arange(self.start_h, self.start_h+self.num_h, self.int_h, dtype=int)

        self.STT = {'lon': stt_lon, 'lat': stt_lat}
        self.domain_limits = {'lon': lonlims, 'lat': latlims}
        self.crossec = {'start': crossec_start, 'end': crossec_end}


###############################################################################
#--------------- Specify variables to be retrieved ----------------------------
###############################################################################

        if self.data_type == "NEARSURFACE":
            # Names as given in the netcdf files on the MET server
            self.varnames = ['x_wind_10m','y_wind_10m','surface_air_pressure','air_temperature_2m','relative_humidity_2m', 'specific_humidity_2m']
            # Define corresponding variable names for Matlab structure
            self.fldnames = ['u10r','v10r','PSFC','T2','RH2','Q2']

        elif self.data_type == "PROFILES":
            # Names as given in the netcdf files on the MET server
            self.varnames = ['x_wind_ml','y_wind_ml','air_temperature_ml','surface_air_pressure','air_temperature_0m','specific_humidity_ml']
            # Define corresponding variable names for Matlab structure
            self.fldnames = ['ur','vr','T','PSFC','t0','Q']

        elif self.data_type == "HORIZONTAL_2D":
            # Names as given in the netcdf files on the MET server
            self.varnames = ['x_wind_10m','y_wind_10m','air_temperature_2m','relative_humidity_2m','surface_air_pressure','specific_humidity_2m']
            # Define corresponding variable names for Matlab structure
            self.fldnames = ['u10r','v10r','T2','RH2','PSFC','Q2']

        elif self.data_type == "PRESSURE_LEVELS":
            # Names as given in the netcdf files on the MET server
            self.varnames = ['x_wind_pl','y_wind_pl']#,'air_temperature_pl','specific_humidity_pl','relative_humidity_pl']
            self.p_levels_model = np.array(['50','100','150','200','250','300','400','500','700','800','850','925','1000'])
            self.ind_p_levels = [np.where(self.p_levels_model == str(i))[0][0] for i in self.p_levels]
            # Define corresponding variable names for Matlab structure
            self.fldnames = ['ur','vr']#,'T','Q','RH']

        elif self.data_type == "CROSSECTION":
            # Names as given in the netcdf files on the MET server
            self.varnames = ['x_wind_ml','y_wind_ml','air_temperature_ml','surface_air_pressure','air_temperature_0m','specific_humidity_ml']
            # Define corresponding variable names for Matlab structure
            self.fldnames = ['ur','vr','T','PSFC','t0','Q']



###############################################################################
###############################################################################
###############################################################################
###############################################################################
## --------------- THIS SECTION IS NORMALLY NOT CHANGED -----------------------
###############################################################################


        # Loading static fields
        if sys.platform == 'linux':
            if os.path.isdir("/media/lukas/ACSI/Data/AROME_Arctic/static_fields/arome_arctic_full_2_5km_static_fields.nc"):
                in_path = "/media/lukas/ACSI/Data/AROME_Arctic/static_fields/arome_arctic_{a}_static_fields.nc"
            else:
                in_path = "/media/lukas/ACSI_backup/Data/AROME_Arctic/static_fields/arome_arctic_{a}_static_fields.nc"
        elif sys.platform == "win32":
            in_path = "D:/Data/AROME_Arctic/static_fields/arome_arctic_{a}_static_fields.nc"

        if self.high_resolution:
            self.file = in_path.format(a="full_500m")
        else:
            self.file = in_path.format(a="full_2_5km")

        self.static = {}
        with Dataset(self.file, 'r') as f:
            self.static['LON'] = f.variables["AA_longitude"][:]
            self.static['LAT'] = f.variables["AA_latitude"][:]
            self.static['HGT'] = f.variables["AA_topo_height"][:]/9.81
            self.static['LSM'] = f.variables["AA_lsm"][:]




        # Storing names of data files in a structure called 'fileurls'
        self.fileurls = []

        if self.latest: # MOST RECENT FILES
            if self.data_type == "PRESSURE_LEVELS":
                self.fileurls.append('https://thredds.met.no/thredds/dodsC/aromearcticlatest/arome_arctic_extracted_2_5km_latest.nc')
            else:
                self.fileurls.append('https://thredds.met.no/thredds/dodsC/aromearcticlatest/arome_arctic_full_2_5km_latest.nc')

        else: # THEN HISTORICAL (ARCHIVED FILES)
            for i in range(len(self.timevec)):
                if self.high_resolution:
                    if self.data_type == "PRESSURE_LEVELS":
                        self.fileurls.append('https://thredds.met.no/thredds/dodsC/metusers/yuriib/AGF-DCCCL/AS500_{a}.nc'.format(a=datetime.datetime.strftime(self.timevec[i],'%Y%m%d%H')))
                    else:
                        self.fileurls.append('https://thredds.met.no/thredds/dodsC/metusers/yuriib/AGF-DCCCL/AS500_{a}_fp.nc'.format(a=datetime.datetime.strftime(self.timevec[i],'%Y%m%d%H')))

                else:
                    if self.data_type == "PRESSURE_LEVELS":
                        self.fileurls.append('https://thredds.met.no/thredds/dodsC/aromearcticarchive/{a}/arome_arctic_extracted_2_5km_{b}T{c}Z.nc'.format(a=datetime.datetime.strftime(self.timevec[i], '%Y/%m/%d'),
                                                                                                                                                    b=datetime.datetime.strftime(self.timevec[i], '%Y%m%d'),
                                                                                                                                                    c=datetime.datetime.strftime(self.timevec[i], '%H')))
                    else:
                        self.fileurls.append('https://thredds.met.no/thredds/dodsC/aromearcticarchive/{a}/arome_arctic_full_2_5km_{b}T{c}Z.nc'.format(a=datetime.datetime.strftime(self.timevec[i], '%Y/%m/%d'),
                                                                                                                                                    b=datetime.datetime.strftime(self.timevec[i], '%Y%m%d'),
                                                                                                                                                    c=datetime.datetime.strftime(self.timevec[i], '%H')))





###############################################################################
###############################################################################
#---------------- methods to retrieve different products ----------------------
###############################################################################
###############################################################################



    def retrieve_nearsurface(self):

        # Finding nearest model grid points (x,y) to the longitude and latitude coordinates of the stations in the station list
        self.lon_model = np.zeros(len(self.STT['lon']))
        self.lat_model = np.zeros(len(self.STT['lon']))
        self.lon_actual = np.zeros(len(self.STT['lon']))
        self.lat_actual = np.zeros(len(self.STT['lon']))
        self.HGT_model = np.zeros(len(self.STT['lon']))
        self.LSM_model = np.zeros(len(self.STT['lon']))

        self.coords_xx = np.zeros(len(self.STT['lon']), dtype=int)
        self.coords_yy = np.zeros(len(self.STT['lon']), dtype=int)
        self.lon_closest = np.zeros(len(self.STT['lon']))
        self.lat_closest = np.zeros(len(self.STT['lon']))

        for i in range(len(self.STT['lon'])):
            self.coords_xx[i], self.coords_yy[i], self.lon_closest[i], self.lat_closest[i] = AROME_Arctic__TOOLS.lonlat2xy_Arome_Arctic(self.STT['lon'][i], self.STT['lat'][i], self.static['LON'], self.static['LAT'])

            self.lon_model[i] = self.lon_closest
            self.lat_model[i] = self.lat_closest

            self.lon_actual[i] = self.STT['lon'][i]
            self.lat_actual[i] = self.STT['lat'][i]

            self.HGT_model[i] = self.static['HGT'][self.coords_xx,self.coords_yy]
            self.LSM_model[i] = self.static['LSM'][self.coords_xx,self.coords_yy]


        self.time = []
        self.data = {'nearsurface': {}}

        # determine overall size of time dimension
        len_time = 0                                          # overall time index
        for filename in self.fileurls:                 # loop over files --> time in the order of days
            for a in range(self.num_h):                     # loop over timesteps --> time in the order of hours
                len_time += 1

        for qr in range(len(self.STT['lon'])):              # loop over stations
            self.data['nearsurface'][qr] = {}
            nn = 0                                          # overall time index

            for vari in self.fldnames:
                self.data['nearsurface'][qr][vari] = np.zeros((len_time))
            self.data['nearsurface'][qr]['u10'] = np.zeros((len_time))
            self.data['nearsurface'][qr]['v10'] = np.zeros((len_time))
            self.data['nearsurface'][qr]['WS10'] = np.zeros((len_time))
            self.data['nearsurface'][qr]['WD10'] = np.zeros((len_time))

            for filename in self.fileurls:                 # loop over files --> time in the order of days

                for qrr in self.time_ind:                      # loop over timesteps --> time in the order of hours

                    with Dataset(filename, 'r') as f:
                        if qr == 0:
                            self.time.append(datetime.datetime.utcfromtimestamp(int(f.variables['time'][qrr])))

                        # Retrieving variables from MET Norway server thredds.met.no
                        for i in range(len(self.varnames)):
                            self.data['nearsurface'][qr][self.fldnames[i]][nn] = np.squeeze(f.variables[self.varnames[i]][qrr,0,self.coords_yy[qr],self.coords_xx[qr]],1)

                            print('Done reading variable {a} from file {b} on thredds server'.format(a=self.fldnames[i], b=filename))


                    nn += 1

            # Wind u and v components in the original data are grid-related.
            # Therefore, we rotate here the wind components from grid- to earth-related coordinates.
            self.data['nearsurface'][qr]['u10'][:], self.data['nearsurface'][qr]['v10'][:] = AROME_Arctic__TOOLS.Rotate_uv_components_Arome_Arctic(self.data['nearsurface'][qr]['u10r'][:], self.data['nearsurface'][qr]['v10r'][:], self.coords_xx[qr], self.coords_yy[qr], self.static['LON'],1)

            # Calculating wind direction
            self.data['nearsurface'][qr]['WD10'][:] = (np.rad2deg(np.arctan2(-self.data['nearsurface'][qr]['u10'][:], -self.data['nearsurface'][qr]['v10'][:]))+360.) % 360.

            # Calculating wind speed
            self.data['nearsurface'][qr]['WS10'][:] = np.sqrt((self.data['nearsurface'][qr]['u10r'][:]**2.) + (self.data['nearsurface'][qr]['v10r'][:]**2.))

            # Calculating potential temperature
            self.data['nearsurface'][qr]['TP2'] = (self.data['nearsurface'][qr]['T2'])*((1000./(self.data['nearsurface'][qr]['PSFC']/100.))**(287./1005.))

            # Converting pressure from Pa to hPa
            self.data['nearsurface'][qr]['PSFC'] /= 100.

            # Converting temperature from Kelvin to Celcius
            self.data['nearsurface'][qr]['T2']  -= 273.15
            self.data['nearsurface'][qr]['TP2'] -= 273.15

            # Converting specific humidity from kg/kg to g/kg
            self.data['nearsurface'][qr]['Q2'] *= 1000.

            # Converting relative humidity from unitless to percent
            self.data['nearsurface'][qr]['RH2'] *= 100.


            # Deleting unnecessary keys from dict
            del self.data['nearsurface'][qr]['u10r']
            del self.data['nearsurface'][qr]['v10r']

        self.time = np.array(self.time)

        return





    def retrieve_profiles(self):

        self.lon_model = np.zeros(len(self.STT['lon']))
        self.lat_model = np.zeros(len(self.STT['lon']))
        self.lon_actual = np.zeros(len(self.STT['lon']))
        self.lat_actual = np.zeros(len(self.STT['lon']))
        self.HGT_model = np.zeros(len(self.STT['lon']))
        self.LSM_model = np.zeros(len(self.STT['lon']))

        self.coords_xx = np.zeros(len(self.STT['lon']), dtype=int)
        self.coords_yy = np.zeros(len(self.STT['lon']), dtype=int)
        self.lon_closest = np.zeros(len(self.STT['lon']))
        self.lat_closest = np.zeros(len(self.STT['lon']))

        for i in range(len(self.STT['lon'])):
            self.coords_xx[i], self.coords_yy[i], self.lon_closest[i], self.lat_closest[i] = AROME_Arctic__TOOLS.lonlat2xy_Arome_Arctic(self.STT['lon'][i], self.STT['lat'][i], self.static['LON'], self.static['LAT'], 1)

            self.lon_model[i] = self.lon_closest[i]
            self.lat_model[i] = self.lat_closest[i]

            self.lon_actual[i] = self.STT['lon'][i]
            self.lat_actual[i] = self.STT['lat'][i]

            self.HGT_model[i] = self.static['HGT'][self.coords_xx[i],self.coords_yy[i]]
            self.LSM_model[i] = self.static['LSM'][self.coords_xx[i],self.coords_yy[i]]


        self.time = []
        self.data = {'profile': {}}

        # determine overall size of time dimension
        len_time = 0                                          # overall time index
        for filename in self.fileurls:                 # loop over files --> time in the order of days
            for a in range(self.num_h):                     # loop over timesteps --> time in the order of hours
                len_time += 1

        for qr in range(len(self.STT['lon'])):              # loop over stations
            self.data['profile'][qr] = {}
            nn = 0                                          # overall time index

            for vari in self.fldnames:
                if vari in ['PSFC','t0']:
                    self.data['profile'][qr][vari] = np.zeros(len_time)
                else:
                    self.data['profile'][qr][vari] = np.zeros((65,len_time))
            self.data['profile'][qr]['z'] = np.zeros((65, len_time))
            self.data['profile'][qr]['P'] = np.zeros((65,len_time))
            self.data['profile'][qr]['u'] = np.zeros((65,len_time))
            self.data['profile'][qr]['v'] = np.zeros((65,len_time))
            self.data['profile'][qr]['WS'] = np.zeros((65,len_time))
            self.data['profile'][qr]['WD'] = np.zeros((65,len_time))

            for filename in self.fileurls:                 # loop over files --> time in the order of days

                for qrr in self.time_ind:                      # loop over timesteps --> time in the order of hours

                    with Dataset(filename, 'r') as f:
                        if qr == 0:
                            self.time.append(datetime.datetime.utcfromtimestamp(int(f.variables['time'][qrr])))

                        # Retrieving variables from MET Norway server thredds.met.no
                        for i in range(len(self.varnames)):
                            if f.variables[self.varnames[i]].shape[1] == 1:
                                self.data['profile'][qr][self.fldnames[i]][nn] = np.squeeze(f.variables[self.varnames[i]][qrr,:,self.coords_yy[qr],self.coords_xx[qr]])
                            else:
                                self.data['profile'][qr][self.fldnames[i]][:,nn] = np.squeeze(f.variables[self.varnames[i]][qrr,:,self.coords_yy[qr],self.coords_xx[qr]])


                            print('Done reading variable {a} from file {b} on thredds server'.format(a=self.fldnames[i], b=filename))

                    # Wind u and v components in the original data are grid-related.
                    # Therefore, we rotate here the wind components from grid- to earth-related coordinates.
                    self.data['profile'][qr]['u'][:,nn], self.data['profile'][qr]['v'][:,nn] = AROME_Arctic__TOOLS.Rotate_uv_components_Arome_Arctic(self.data['profile'][qr]['ur'][:,nn], self.data['profile'][qr]['vr'][:,nn], self.coords_xx[qr], self.coords_yy[qr], self.static['LON'],1)

                    # Calculating wind direction
                    self.data['profile'][qr]['WD'][:,nn] = (np.rad2deg(np.arctan2(-self.data['profile'][qr]['u'][:,nn], -self.data['profile'][qr]['v'][:,nn]))+360.) % 360.

                    # Calculating wind speed
                    self.data['profile'][qr]['WS'][:,nn] = np.sqrt((self.data['profile'][qr]['ur'][:,nn]**2.) + (self.data['profile'][qr]['vr'][:,nn]**2.))

                    # Calculating height levels and pressure
                    with Dataset(filename, 'r') as f:
                        hybrid = f.variables['hybrid'][:]
                        ap = f.variables['ap'][:]
                        b = f.variables['b'][:]

                    self.data['profile'][qr]['z'][:,nn], self.data['profile'][qr]['P'][:,nn] = AROME_Arctic__TOOLS.Calculate_height_levels_and_pressure_Arome_Arctic(hybrid,ap,b, self.data['profile'][qr]['t0'][nn], self.data['profile'][qr]['PSFC'][nn], self.data['profile'][qr]['T'][:,nn])



                    nn += 1

            # Converting specific humidity from kg/kg to g/kg
            self.data['profile'][qr]['Q'] *= 1000

            # Calculating potential temperature
            self.data['profile'][qr]['TP'] = (self.data['profile'][qr]['T'])*((1000./(self.data['profile'][qr]['P']/100.))**(287./1005.))

            # Converting pressure from Pa to hPa
            self.data['profile'][qr]['P'] /= 100.

            # Converting temperature from Kelvin to Celcius
            self.data['profile'][qr]['T']  -= 273.15
            self.data['profile'][qr]['TP'] -= 273.15

            # Deleting unnecessary keys from dict
            del self.data['profile'][qr]['ur']
            del self.data['profile'][qr]['vr']

        self.time = np.array(self.time)

        return



    def retrieve_horizontal_2d(self):

        start_lonlat, count_lonlat, _, _ = AROME_Arctic__TOOLS.lonlat2xy_Arome_Arctic(self.domain_limits['lon'], self.domain_limits['lat'], self.static['LON'], self.static['LAT'], 2)

        idx = np.arange(start_lonlat[0], (start_lonlat[0]+count_lonlat[0]+1))
        idy = np.arange(start_lonlat[1], (start_lonlat[1]+count_lonlat[1]+1))
        idxx = idx[::self.int_x]
        idyy = idy[::self.int_y]

        self.LON = self.static['LON'][idxx,:][:,idyy]
        self.LAT = self.static['LAT'][idxx,:][:,idyy]
        self.HGT = self.static['HGT'][idxx,:][:,idyy]
        self.LSM = self.static['LSM'][idxx,:][:,idyy]

        self.time = []
        self.data = {'horizontal2d': {}}
        nn = 0                                          # overall time index

        # determine overall size of time dimension
        len_time = 0                                          # overall time index
        for filename in self.fileurls:                 # loop over files --> time in the order of days
            for a in range(self.num_h):                     # loop over timesteps --> time in the order of hours
                len_time += 1



        for vari in self.fldnames:
            self.data['horizontal2d'][vari] = np.zeros((self.LON.shape[0], self.LON.shape[1],len_time))
        self.data['horizontal2d']['u10'] = np.zeros((self.LON.shape[0], self.LON.shape[1],len_time))
        self.data['horizontal2d']['v10'] = np.zeros((self.LON.shape[0], self.LON.shape[1],len_time))

        for filename in self.fileurls:                 # loop over files --> time in the order of days

            for qrr in self.time_ind:                      # loop over timesteps --> time in the order of hours

                with Dataset(filename, 'r') as f:
                    self.time.append(datetime.datetime.utcfromtimestamp(int(f.variables['time'][qrr])))

                    # Retrieving variables from MET Norway server thredds.met.no
                    for i in range(len(self.varnames)):
                        self.data['horizontal2d'][self.fldnames[i]][:,:,nn] = np.transpose(np.squeeze(f.variables[self.varnames[i]][qrr,0,idyy,idxx]))

                        print('Done reading variable {a} from file {b} on thredds server'.format(a=self.fldnames[i], b=filename))

                # Wind u and v components in the original data are grid-related.
                # Therefore, we rotate here the wind components from grid- to earth-related coordinates.
                self.data['horizontal2d']['u10'][:,:,nn], self.data['horizontal2d']['v10'][:][:,:,nn] = AROME_Arctic__TOOLS.Rotate_uv_components_Arome_Arctic(self.data['horizontal2d']['u10r'][:,:,nn], self.data['horizontal2d']['v10r'][:,:,nn], np.arange(self.LON.shape[0]), np.arange(self.LON.shape[1]), self.LON,2)

                nn += 1


        # Calculating wind direction
        self.data['horizontal2d']['WD10'] = (np.rad2deg(np.arctan2(-self.data['horizontal2d']['u10'], -self.data['horizontal2d']['v10']))+360.) % 360.

        # Calculating wind speed
        self.data['horizontal2d']['WS10'] = np.sqrt((self.data['horizontal2d']['u10r']**2.) + (self.data['horizontal2d']['v10r']**2.))

        # Calculating potential temperature
        self.data['horizontal2d']['TP2'] = (self.data['horizontal2d']['T2'])*((1000./(self.data['horizontal2d']['PSFC']/100.))**(287./1005.))

        # Converting pressure from Pa to hPa
        self.data['horizontal2d']['PSFC'] /= 100.

        # Converting temperature from Kelvin to degC
        self.data['horizontal2d']['T2']  -= 273.15
        self.data['horizontal2d']['TP2'] -= 273.15

        # Converting specific humidity from kg/kg to g/kg
        self.data['horizontal2d']['Q2'] *= 1000.

        # Converting relative humidity from unitless to percent
        self.data['horizontal2d']['RH2'] *= 100.


        # Deleting unnecessary keys from dict
        del self.data['horizontal2d']['u10r']
        del self.data['horizontal2d']['v10r']

        self.time = np.array(self.time)

        return





    def retrieve_pressure_levels(self):

        start_lonlat, count_lonlat, _, _ = AROME_Arctic__TOOLS.lonlat2xy_Arome_Arctic(self.domain_limits['lon'], self.domain_limits['lat'], self.static['LON'], self.static['LAT'], 2)

        idx = np.arange(start_lonlat[0], (start_lonlat[0]+count_lonlat[0]+1))
        idy = np.arange(start_lonlat[1], (start_lonlat[1]+count_lonlat[1]+1))
        idxx = idx[::self.int_x]
        idyy = idy[::self.int_y]

        self.LON = self.static['LON'][idxx,:][:,idyy]
        self.LAT = self.static['LAT'][idxx,:][:,idyy]
        self.HGT = self.static['HGT'][idxx,:][:,idyy]
        self.LSM = self.static['LSM'][idxx,:][:,idyy]

        self.time = []
        self.data = {'pressure_levels': {}}
        nn = 0                                          # overall time index

        # determine overall size of time dimension
        len_time = 0                                          # overall time index
        for filename in self.fileurls:                 # loop over files --> time in the order of days
            for a in range(self.num_h):                     # loop over timesteps --> time in the order of hours
                len_time += 1



        for vari in self.fldnames:
            self.data['pressure_levels'][vari] = np.zeros((self.LON.shape[0], self.LON.shape[1],len(self.ind_p_levels),len_time))
        self.data['pressure_levels']['u'] = np.zeros((self.LON.shape[0], self.LON.shape[1],len(self.ind_p_levels),len_time))
        self.data['pressure_levels']['v'] = np.zeros((self.LON.shape[0], self.LON.shape[1],len(self.ind_p_levels),len_time))

        for filename in self.fileurls:                 # loop over files --> time in the order of days

            for qrr in self.time_ind:                      # loop over timesteps --> time in the order of hours

                for lc, l in enumerate(self.ind_p_levels):  # loop over p levels

                    with Dataset(filename, 'r') as f:
                        if lc == 0:
                            self.time.append(datetime.datetime.utcfromtimestamp(int(f.variables['time'][qrr])))

                        # Retrieving variables from MET Norway server thredds.met.no
                        for i in range(len(self.varnames)):
                            self.data['pressure_levels'][self.fldnames[i]][:,:,lc,nn] = np.transpose(np.squeeze(f.variables[self.varnames[i]][qrr,l,idyy,idxx]))

                            print('Done reading variable {a} from file {b} at p-level {c} hPa on thredds server'.format(a=self.fldnames[i], b=filename, c=self.p_levels[lc]))

                    # Wind u and v components in the original data are grid-related.
                    # Therefore, we rotate here the wind components from grid- to earth-related coordinates.
                    self.data['pressure_levels']['u'][:,:,lc,nn], self.data['pressure_levels']['v'][:][:,:,lc,nn] = AROME_Arctic__TOOLS.Rotate_uv_components_Arome_Arctic(self.data['pressure_levels']['ur'][:,:,lc,nn], self.data['pressure_levels']['vr'][:,:,lc,nn], np.arange(self.LON.shape[0]), np.arange(self.LON.shape[1]), self.LON,2)

                nn += 1


        # Calculating wind direction
        self.data['pressure_levels']['WD'] = (np.rad2deg(np.arctan2(-self.data['pressure_levels']['u'], -self.data['pressure_levels']['v']))+360.) % 360.

        # Calculating wind speed
        self.data['pressure_levels']['WS'] = np.sqrt((self.data['pressure_levels']['ur']**2.) + (self.data['pressure_levels']['vr']**2.))

        # # Converting temperature from Kelvin to Celcius
        # self.data['pressure_levels']['T']  -= 273.15
        #
        # # Converting specific humidity from kg/kg to g/kg
        # self.data['pressure_levels']['Q'] *= 1000.
        #
        # # Converting relative humidity from unitless to percent
        # self.data['pressure_levels']['RH'] *= 100.


        # Deleting unnecessary keys from dict
        del self.data['pressure_levels']['ur']
        del self.data['pressure_levels']['vr']

        self.time = np.array(self.time)

        return


    def retrieve_crossection(self):

        lonlims=[np.min([self.crossec['start'][0], self.crossec['end'][0]]), np.max([self.crossec['start'][0], self.crossec['end'][0]])]
        latlims=[np.min([self.crossec['start'][1], self.crossec['end'][1]]), np.max([self.crossec['start'][1], self.crossec['end'][1]])]
        start_lonlat, count_lonlat, _, _ = AROME_Arctic__TOOLS.lonlat2xy_Arome_Arctic(lonlims, latlims, self.static['LON'], self.static['LAT'], 2)
        start_lonlat = start_lonlat - 2
        count_lonlat = count_lonlat + 5

        idx = np.arange(start_lonlat[0], (start_lonlat[0]+count_lonlat[0]+1))
        idy = np.arange(start_lonlat[1], (start_lonlat[1]+count_lonlat[1]+1))
        idxx = idx[::self.int_x]
        idyy = idy[::self.int_y]

        self.LON = self.static['LON'][idxx,:][:,idyy]
        self.LAT = self.static['LAT'][idxx,:][:,idyy]
        self.HGT = self.static['HGT'][idxx,:][:,idyy]
        self.LSM = self.static['LSM'][idxx,:][:,idyy]

        # plt.close("all")
        # plt.figure()
        # plt.contourf(self.LON, self.LAT, self.HGT)
        # plt.plot([self.crossec['start'][0], self.crossec['end'][0]], [self.crossec['start'][1], self.crossec['end'][1]], 'r-') # marking location of cross section
        # plt.plot(self.LON, self.LAT, 'ok') # marking model grid points with dots
        # plt.show()


        self.time = []
        self.data = {'crossection': {}}

        # determine overall size of time dimension
        len_time = 0                                          # overall time index
        for filename in self.fileurls:                 # loop over files --> time in the order of days
            for a in range(self.num_h):                     # loop over timesteps --> time in the order of hours
                len_time += 1

        nn = 0                                          # overall time index

        for vari in self.fldnames:
            if vari in ['PSFC','t0']:
                self.data['crossection'][vari] = np.zeros((self.LON.shape[0], self.LON.shape[1], len_time))
            else:
                self.data['crossection'][vari] = np.zeros((self.LON.shape[0], self.LON.shape[1], 65, len_time))
        self.data['crossection']['u'] = np.zeros((self.LON.shape[0], self.LON.shape[1], 65, len_time))
        self.data['crossection']['v'] = np.zeros((self.LON.shape[0], self.LON.shape[1], 65, len_time))
        self.data['crossection']['z'] = np.zeros((self.LON.shape[0], self.LON.shape[1], 65, len_time))
        self.data['crossection']['P'] = np.zeros((self.LON.shape[0], self.LON.shape[1], 65, len_time))

        for filename in self.fileurls:                 # loop over files --> time in the order of days

            for qrr in self.time_ind:                      # loop over timesteps --> time in the order of hours

                with Dataset(filename, 'r') as f:
                    self.time.append(datetime.datetime.utcfromtimestamp(int(f.variables['time'][qrr])))

                    # Retrieving variables from MET Norway server thredds.met.no
                    for i in range(len(self.varnames)):
                        if f.variables[self.varnames[i]].shape[1] == 1:
                            self.data['crossection'][self.fldnames[i]][:,:,nn] = np.transpose(np.squeeze(f.variables[self.varnames[i]][qrr,:,idyy,idxx]))
                        else:
                            self.data['crossection'][self.fldnames[i]][:,:,:,nn] = np.transpose(np.squeeze(f.variables[self.varnames[i]][qrr,:,idyy,idxx]), (2,1,0))

                        print('Done reading variable {a} from file {b} on thredds server'.format(a=self.fldnames[i], b=filename))

                for i in range(65):
                    # Wind u and v components in the original data are grid-related.
                    # Therefore, we rotate here the wind components from grid- to earth-related coordinates.
                    self.data['crossection']['u'][:,:,i,nn], self.data['crossection']['v'][:,:,i,nn] = AROME_Arctic__TOOLS.Rotate_uv_components_Arome_Arctic(self.data['crossection']['ur'][:,:,i,nn], self.data['crossection']['vr'][:,:,i,nn], np.arange(self.LON.shape[0]), np.arange(self.LON.shape[1]), self.LON, 2)

                # Calculating height levels and pressure
                with Dataset(filename, 'r') as f:
                    hybrid = f.variables['hybrid'][:]
                    ap = f.variables['ap'][:]
                    b = f.variables['b'][:]

                self.data['crossection']['z'][:,:,:,nn], self.data['crossection']['P'][:,:,:,nn] = AROME_Arctic__TOOLS.Calculate_height_levels_and_pressure_Arome_Arctic_3D(hybrid,ap,b, self.data['crossection']['t0'][:,:,nn], self.data['crossection']['PSFC'][:,:,nn], self.data['crossection']['T'][:,:,:,nn])

                nn += 1

        # Calculating wind direction
        self.data['crossection']['WD'] = (np.rad2deg(np.arctan2(-self.data['crossection']['u'], -self.data['crossection']['v']))+360.) % 360.

        # Calculating wind speed
        self.data['crossection']['WS'] = np.sqrt((self.data['crossection']['ur']**2.) + (self.data['crossection']['vr']**2.))

        # Converting specific humidity from kg/kg to g/kg
        self.data['crossection']['Q'] *= 1000

        # Calculating potential temperature
        self.data['crossection']['TP'] = (self.data['crossection']['T'])*((1000./(self.data['crossection']['P']/100.))**(287./1005.))

        # Converting pressure from Pa to hPa
        self.data['crossection']['P'] /= 100.

        # Converting temperature from Kelvin to Celcius
        self.data['crossection']['T']  -= 273.15
        self.data['crossection']['TP'] -= 273.15

        # Deleting unnecessary keys from dict
        del self.data['crossection']['ur']
        del self.data['crossection']['vr']


        # Calculating distance between end and start points
        # using that (d2km) to find out how many points to use for the
        # interpolation

        latlon1 = self.crossec['start'][::-1]
        latlon2 = self.crossec['end'][::-1]

        radius = 6371.
        lat1 = latlon1[0] * (np.pi/180)
        lat2 = latlon2[0] * (np.pi/180)
        lon1 = latlon1[1] * (np.pi/180)
        lon2 = latlon2[1] * (np.pi/180)
        deltaLat = lat2 - lat1
        deltaLon = lon2 - lon1
        a = np.sin((deltaLat)/2.)**2. + np.cos(lat1) * np.cos(lat2) * np.sin(deltaLon/2.)**2.
        c = 2. * np.arctan2(np.sqrt(a), np.sqrt(1-a))
        d1km = radius * c    # Haversine distance

        x = deltaLon * np.cos((lat1+lat2)/2.)
        y = deltaLat
        d2km = radius * np.sqrt(x**2. + y**2.) # Pythagoran distance

        if self.high_resolution:
            dd = int(d2km/0.5)
        else:
            dd = int(d2km/2.5)

        lons = np.linspace(self.crossec['start'][0], self.crossec['end'][0], dd)
        lats = np.linspace(self.crossec['start'][1], self.crossec['end'][1], dd)

        # infer new x-axis as distances between the new lat-lon-points
        basepoints_x, basepoints_y, _, _ = utm.from_latlon(lats, lons)
        delta_x = basepoints_x - basepoints_x[0]
        delta_y = basepoints_y - basepoints_y[0]
        xx = np.sqrt(delta_x**2. + delta_y**2.) / 1000.

        # Interpolating the surface height on to the cross section
        hgs = interpolate.interp2d(self.LON, self.LAT, self.HGT, kind='linear')
        hgss = np.diagonal(np.transpose(hgs(lons, lats)))


        nlevels  = 20       # number of vertical levels to retrieve
        oz = np.zeros((len(lons), len(lats), nlevels, len_time))
        ti = np.zeros((len(lons), nlevels, len_time))
        tpi = np.zeros((len(lons), nlevels, len_time))
        wsi = np.zeros((len(lons), nlevels, len_time))
        wdi = np.zeros((len(lons), nlevels, len_time))
        qi = np.zeros((len(lons), nlevels, len_time))

        for nn in range(len(self.time)):
            # Interpolating the atmospheric data on to the cross section

            zz = 0
            for i in range(64,(65-nlevels-1),-1):

                s = interpolate.interp2d(self.LON, self.LAT, np.squeeze(self.data['crossection']['z'][:,:,i,nn]), kind='linear')
                oz[:,:,zz,nn] = s(lons, lats)

                ti[:,zz,nn] = np.diagonal(interpolate.griddata((self.LON.flatten(), self.LAT.flatten(), np.squeeze(self.data['crossection']['z'][:,:,i,nn]).flatten()), self.data['crossection']['T'][:,:,i,nn].flatten(), (lons, lats, oz[:,:,zz,nn]), method="linear"), axis1=0, axis2=1)
                tpi[:,zz,nn] = np.diagonal(interpolate.griddata((self.LON.flatten(), self.LAT.flatten(), np.squeeze(self.data['crossection']['z'][:,:,i,nn]).flatten()), self.data['crossection']['TP'][:,:,i,nn].flatten(), (lons, lats, oz[:,:,zz,nn]), method="linear"), axis1=0, axis2=1)
                wsi[:,zz,nn] = np.diagonal(interpolate.griddata((self.LON.flatten(), self.LAT.flatten(), np.squeeze(self.data['crossection']['z'][:,:,i,nn]).flatten()), self.data['crossection']['WS'][:,:,i,nn].flatten(), (lons, lats, oz[:,:,zz,nn]), method="linear"), axis1=0, axis2=1)
                wdi[:,zz,nn] = np.diagonal(interpolate.griddata((self.LON.flatten(), self.LAT.flatten(), np.squeeze(self.data['crossection']['z'][:,:,i,nn]).flatten()), self.data['crossection']['WD'][:,:,i,nn].flatten(), (lons, lats, oz[:,:,zz,nn]), method="linear"), axis1=0, axis2=1)
                qi[:,zz,nn] = np.diagonal(interpolate.griddata((self.LON.flatten(), self.LAT.flatten(), np.squeeze(self.data['crossection']['z'][:,:,i,nn]).flatten()), self.data['crossection']['Q'][:,:,i,nn].flatten(), (lons, lats, oz[:,:,zz,nn]), method="linear"), axis1=0, axis2=1)

                zz = zz+1;

        oz = np.transpose(np.diagonal(oz, axis1=0, axis2=1), (2,0,1))

        hg = np.repeat(hgss[:,np.newaxis], oz.shape[1], axis=1)
        hg = np.repeat(hg[:,:,np.newaxis], oz.shape[2], axis=2)
        oz = oz+hg

        self.data['crossection']['ti']  = ti
        self.data['crossection']['tpi'] = ti
        self.data['crossection']['wsi'] = wsi
        self.data['crossection']['wdi'] = wdi
        self.data['crossection']['qi']  = qi

        self.data['crossection']['oz']  = oz
        self.data['crossection']['xx']  = xx


        return


    def neglect_land_gridpoints(self):
        """
        Apply additional restrictions for the lsm (dimension reduced to 1 for horizontal)
        To be called at the very end, after all calculations that need gridded data as input
        """
        if self.LSM.ndim == 1:
            ind = np.where(self.LSM == 0)[0]
            if self.data_type == "HORIZONTAL_2D":
                for vari in list(self.data["horizontal2d"].keys()):
                    self.data["horizontal2d"][vari] = self.data["horizontal2d"][vari][ind,:]
            elif self.data_type == "PRESSURE_LEVELS":
                for vari in list(self.data["pressure_levels"].keys()):
                    self.data["pressure_levels"][vari] = self.data["pressure_levels"][vari][ind,:,:]
            else:
                print("neglecting land gridpoints not feasible for selected data type")
        else:
            ind = np.where(self.LSM == 0)
            if self.data_type == "HORIZONTAL_2D":
                for vari in list(self.data["horizontal2d"].keys()):
                    self.data["horizontal2d"][vari] = self.data["horizontal2d"][vari][ind[0],ind[1],:]
            elif self.data_type == "PRESSURE_LEVELS":
                for vari in list(self.data["pressure_levels"].keys()):
                    self.data["pressure_levels"][vari] = self.data["pressure_levels"][vari][ind[0],ind[1],:,:]
            else:
                print("neglecting land gridpoints not feasible for selected data type")
        self.LAT = self.LAT[ind]
        self.LON = self.LON[ind]
        self.HGT = self.HGT[ind]
        self.LSM = self.LSM[ind]

        return
