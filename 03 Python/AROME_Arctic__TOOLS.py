#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Module containing tools for Arome Arctic data
The scripts are used in "AROME_Arctic__READIN" and "AROME_Arctic__RETRIEVE"
"""

import matplotlib.pyplot as plt
import numpy as np
import datetime
from netCDF4 import Dataset
import copy


def Rotate_uv_components_Arome_Arctic(ur,vr,cordsx,cordsy,longitude,type):

    # type = 1: point data
    # type = 2: horizontal data

    truelat1 = 77.5 # true latitude
    stdlon   = -25  # standard longitude
    cone     = np.sin(np.abs(np.deg2rad(truelat1))) # cone factor

    diffn = stdlon - longitude
    diffn[diffn>180.] -= 360
    diffn[diffn<-180.] += 360

    alpha  = np.deg2rad(diffn) * cone

    if type == 1:
        alphan = alpha[cordsx,cordsy]
    elif type == 2:
        alphan = alpha[cordsx,:][:,cordsy]

    u = np.squeeze(ur) * np.cos(alphan) - np.squeeze(vr) * np.sin(alphan)
    v = np.squeeze(vr) * np.cos(alphan) + np.squeeze(ur) * np.sin(alphan)

    return [u,v]


def lonlat2xy_Arome_Arctic(lon,lat,lons,lats,type):

    # type = 1: point data
    # type = 2: horizontal data

    if type == 1: # then point data

        # output1 = coords_xx
        # output2 = coords_yy
        # output3 = lon_closest
        # output4 = lat_closest

        latt2 = lats
        lonn2 = lons

        latt1 = lat
        lonn1 = lon

        radius = 6371;
        lat1 = latt1 * (np.pi/180)
        lat2 = latt2 * (np.pi/180)
        lon1 = lonn1 * (np.pi/180)
        lon2 = lonn2 * (np.pi/180)
        deltaLat = lat2 - lat1
        deltaLon = lon2 - lon1
        a = np.sin(deltaLat/2.)**2. + np.cos(lat1) * np.cos(lat2) * np.sin(deltaLon/2.)**2.
        c = 2. * np.arctan2(np.sqrt(a), np.sqrt(1-a))
        d1km = radius * c    # Haversine distance

        x = deltaLon * np.cos((lat1+lat2)/2.)
        y = deltaLat
        d2km = radius * np.sqrt(x**2. + y**2.)

        xx, yy = np.unravel_index(d2km.argmin(), d2km.shape)

        output1 = xx
        output2 = yy
        output3 = lons[xx, yy]
        output4 = lats[xx, yy]


    elif type == 2: # then 2D data

        # output1 = start_lonlat
        # output2 = count_lonlat
        # output3 = stride_lonlat
        # output4 = dummy


        lon1 = lon[0]
        lon2 = lon[1]
        lat1 = lat[0]
        lat2 = lat[1]

        lon_corners  = [lon1, lon2, lon2, lon1]
        lat_corners  = [lat1, lat1, lat2, lat2]

        coords_xx = np.zeros(len(lon_corners))
        coords_yy = np.zeros(len(lon_corners))

        for qq in range(len(lon_corners)):
            latt2 = lats
            lonn2 = lons

            lonn1 = lon_corners[qq]
            latt1 = lat_corners[qq]

            radius = 6371;
            lat1 = latt1 * (np.pi/180)
            lat2=latt2 * (np.pi/180)
            lon1=lonn1 * (np.pi/180)
            lon2=lonn2 * (np.pi/180)
            deltaLat = lat2 - lat1
            deltaLon = lon2 - lon1
            a = np.sin(deltaLat/2.)**2. + np.cos(lat1) * np.cos(lat2) * np.sin(deltaLon/2.)**2.
            c = 2. * np.arctan2(np.sqrt(a), np.sqrt(1-a))
            d1km = radius * c   # Haversine distance

            x = deltaLon * np.cos((lat1+lat2)/2.)
            y = deltaLat
            d2km = radius * np.sqrt(x**2. + y**2.)

            coords_xx[qq], coords_yy[qq] = np.unravel_index(d2km.argmin(), d2km.shape)

        lonmin_id = int(np.min(coords_xx))
        lonmax_id = int(np.max(coords_xx))
        latmin_id = int(np.min(coords_yy))
        latmax_id = int(np.max(coords_yy))

#        start_lonlat = [lonmin_id latmin_id]; count_lonlat = [abs(lonmax_id-lonmin_id) abs(latmax_id-latmin_id)]; stride_lonlat=[1 1];

        output1 = np.array([lonmin_id, latmin_id])
        output2 = np.array([np.abs(lonmax_id-lonmin_id), np.abs(latmax_id-latmin_id)])
        output3 = [1,1]
        output4 = np.nan


    return [output1, output2, output3, output4]





def Calculate_height_levels_and_pressure_Arome_Arctic(hybrid,ap,b,t0,PSFC,T):

    R = 287. # ideal gas constant
    g = 9.81 # acceleration of gravity

    PN = np.zeros(len(T)+1)

    # Calculating pressure levels
    for n in range(len(T)):
        PN[n] = ap[n] + b[n]*PSFC

    # Adding surface data as the lowest level
    PN[-1] = PSFC
    TN = copy.copy(T)
    TN = np.append(TN, t0)

    heightt = np.zeros(len(hybrid)+1)

    # Calculating height levels (in metres) based on the hypsometric equation and assuming a dry atmosphere
    for n in range(len(T),0,-1):
        pd = PN[n]/PN[n-1]
        TM = np.mean([TN[n], TN[n-1]])
        heightt[n-1] = heightt[n] + R*TM/g*np.log(pd)

    height = heightt[:-1]
    P = PN[:-1]

    return [height,P]


def Calculate_height_levels_and_pressure_Arome_Arctic_3D(hybrid,ap,b,t0,PSFC,T):

    R = 287. # ideal gas constant
    g = 9.81 # acceleration of gravity

    PN = np.zeros((T.shape[0], T.shape[1], T.shape[2]+1))

    # Calculating pressure levels
    for k in range(T.shape[2]):
        PN[:,:,k] = ap[k] + b[k]*PSFC

    # Adding surface data as the lowest level
    PN[:,:,-1] = PSFC[:,:]
    TN = np.concatenate((T[:,:,:], np.expand_dims(t0, axis=2)), axis=2)

    heightt = np.zeros((T.shape[0], T.shape[1], T.shape[2]+1))

    # Calculating height levels (in metres) based on the hypsometric equation assuming a dry atmosphere
    for n in range(T.shape[2],0,-1):
        pd = PN[:,:,n]/PN[:,:,n-1]
        TM = np.mean(np.array([TN[:,:,n], TN[:,:,n-1]]), axis=0)
        heightt[:,:,n-1] = heightt[:,:,n] + R*TM/g*np.log(pd)

    height = heightt[:,:,:-1]
    P = PN[:,:,:-1]

    return [height,P]
