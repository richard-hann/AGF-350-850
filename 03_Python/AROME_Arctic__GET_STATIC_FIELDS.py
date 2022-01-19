#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Module downloading the static fields of Arome Arctic
The results are used in "AROME_Arctic__READIN" and "AROME_Arctic__RETRIEVE"
"""

import matplotlib.pyplot as plt
import numpy as np
import datetime
from netCDF4 import Dataset
import copy
import os
import sys

if sys.platform == 'linux':
    if if os.path.isdir("/media/lukas/ACSI/Data/AROME_Arctic/static_fields/arome_arctic_full_2_5km_static_fields.nc"):
        out_path = "/media/lukas/ACSI/Data/AROME_Arctic/static_fields/arome_arctic_{a}_static_fields.nc"
    else:
        out_path = "/media/lukas/ACSI_backup/Data/AROME_Arctic/static_fields/arome_arctic_{a}_static_fields.nc"
elif sys.platform == "win32":
    out_path = "D:/Data/AROME_Arctic/static_fields/arome_arctic_{a}_static_fields.nc"


# # FOR 500m domain
# file = 'https://thredds.met.no/thredds/dodsC/aromearcticlatest/arome_arctic_full_500m_latest.nc'
# with Dataset(file) as f:
#     x = f.variables['x'][:]
#     y = f.variables['y'][:]
#     AA_longitude = f.variables['longitude'][:]
#     AA_latitude = f.variables['latitude'][:]
#     AA_topo_height = np.squeeze(f.variables['surface_geopotential'][0,:,:])
#     AA_lsm = np.squeeze(f.variables['land_area_fraction'][0,:,:])
#
# with Dataset(out_path.format(a="full_500m"), 'w', format="NETCDF4") as f:
#     f.Comments = "AROME-Arctic static fields of full data files with 500 m horizontal resolution"
#     f.createDimension('time', len(time))
#     f.createDimension('x', len(x))
#     f.createDimension('y', len(y))
#
#     var = f.createVariable('AA_longitude', 'f4', ('y', 'x',))
#     var.Unit = 'degree_north'
#     var.Longname = 'longitude'
#     var[:] = AA_longitude
#
#     var = f.createVariable('AA_latitude', 'f4', ('y', 'x',))
#     var.Unit = 'degree_east'
#     var.Longname = 'latitude'
#     var[:] = AA_latitude
#
#     var = f.createVariable('AA_topo_height', 'f4', ('y', 'x',))
#     var.Unit = 'm^2/s^2'
#     var.Longname = 'Surface geopotential'
#     var[:] = AA_topo_height[0,:,:]
#
#     var = f.createVariable('AA_lsm', 'f4', ('y', 'x',))
#     var.Unit = '1'
#     var.Longname = 'Land-Sea Mask'
#     var[:] = AA_lsm[0,:,:]



# for 2.5 km horizontal resolution
file = 'https://thredds.met.no/thredds/dodsC/aromearcticlatest/arome_arctic_full_2_5km_latest.nc'
with Dataset(file) as f:
    x = f.variables['x'][:]
    y = f.variables['y'][:]
    AA_longitude = f.variables['longitude'][:]
    AA_latitude = f.variables['latitude'][:]
    AA_topo_height = np.squeeze(f.variables['surface_geopotential'][0,:,:])
    AA_lsm = np.squeeze(f.variables['land_area_fraction'][0,:,:])

with Dataset(out_path.format(a="full_2_5km"), 'w', format="NETCDF4") as f:
    f.Comments = "AROME-Arctic static fields of full data files with 2.5 km horizontal resolution"
    f.createDimension('x', len(x))
    f.createDimension('y', len(y))

    var = f.createVariable('AA_longitude', 'f4', ('x', 'y',))
    var.Unit = 'degree_north'
    var.Longname = 'longitude'
    var[:] = np.transpose(AA_longitude)

    var = f.createVariable('AA_latitude', 'f4', ('x', 'y',))
    var.Unit = 'degree_east'
    var.Longname = 'latitude'
    var[:] = np.transpose(AA_latitude)

    var = f.createVariable('AA_topo_height', 'f4', ('x', 'y',))
    var.Unit = 'm^2/s^2'
    var.Longname = 'Surface geopotential'
    var[:] = np.transpose(AA_topo_height)

    var = f.createVariable('AA_lsm', 'f4', ('x', 'y',))
    var.Unit = '1'
    var.Longname = 'Land-Sea Mask'
    var[:] = np.transpose(AA_lsm)
