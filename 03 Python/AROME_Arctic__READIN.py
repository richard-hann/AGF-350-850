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
import AROME_Arctic__RETRIEVE



AROME = AROME_Arctic__RETRIEVE.AROME_Arctic(data_type="PRESSURE_LEVELS",        # INPUT Settings for what type of data to retrieve.
                                                            # select from ["NEARSURFACE", "PROFILES", "HORIZONTAL_2D", "CROSSECTION", "PRESSURE_LEVELS"]

                            starttime="2020030600",         # INPUT Define start- and end-points in time for retrieving the historical data
                            endtime="2020030600",           # Format: YYYYmmddHH

                            high_resolution=False,          # INPUT Retrieve 2.5 km data (set the variable to False) or 500 m data (high_resolution=True)

                            latest=False,                   # INPUT Setting for what type of files to retrieve (historical forecast --> False)
                                                            # note, if selecting historical forecast, remember to define the start-time and end-times below
                                                            # !!!!! NB: LATEST = True ONLY WORKS FOR 2.5 km DATA, and NOT 500m DATA !!!!
                                                            # If False, set start- and end-time below.

                            p_levels = [1000, 850, 500],    # Pressure levels in hPa in descending order

                            start_h=0,                      # INPUT Settings for what time stamps to retrieve, start time index in each data file
                            num_h=3,                       # Number of data-points (hours) to retrieve from each data file
                            int_h=1,                        # Time interval between data points in each data file
                            int_f=3,                       # Time interval in hours between each data file if retrieving historical data. This is typically the same as num_h.

                            int_x=1,                        # INPUT If retrieving horizontal2d data, set the intervals between the x and y coordinates here
                            int_y=1,                        # (higher number = coarser grid selection), for example, 1 = every grid point. 3 = every third grid point.

                            stt_lon = [11.9312], #, 13.61439, 19.0050],     # INPUT Station list for point data
                            stt_lat = [78.9243], #, 78.06150, 74.51677],    # [Ny Alesund, Isfjord Radio, Bjoernoeya]

                            lonlims = [5, 40],              # INPUT Geographic domain for horizontal 2d data
                            latlims = [75, 80],             # Specify min and max longitude and latitudes

                            crossec_start = [15.00, 78.35], # INPUT Start- and end-points for vertical cross section
                            crossec_end = [15.98, 78.18]    # [lon, lat]
                            )


if AROME.data_type == 'PROFILES':
    AROME.retrieve_profiles()

elif AROME.data_type == 'NEARSURFACE':
    AROME.retrieve_nearsurface()

elif AROME.data_type == 'HORIZONTAL_2D':
    AROME.retrieve_horizontal_2d()

elif AROME.data_type == 'CROSSECTION':
    AROME.retrieve_crossection()

elif AROME.data_type == 'PRESSURE_LEVELS':
    AROME.retrieve_pressure_levels()
