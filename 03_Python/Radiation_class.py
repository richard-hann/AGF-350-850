#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Functions to read data from a Campbell Weather Station.
"""

import glob
import os
import datetime
import numpy as np
import matplotlib as mpl
import Radiation_plotter



class Radiation(Radiation_plotter.Radiation_Plotter):
    """
    Contains a structure with the data for the period from start to end by calling read_file()
    """

    def __init__(self, start, end, path, logger):
        """"
        :param start: datetime object
        :param end: datetime object
        """

        self.start = start.replace(tzinfo=datetime.timezone.utc)
        self.end = end.replace(tzinfo=datetime.timezone.utc)
        self.path = path
        self.logger = logger

        self.starts_total = [self.start]
        self.ends_total = [self.end]

        self.data = {}
        self.meta = {}
        self.sorted_data = {}
        self.data_attr = {}
        
        avail_files = sorted(glob.glob('{a}/CR1000_unis_{b}_rad_*.dat'.format(a=self.path, b=self.logger)))

        file = avail_files.pop(0)
        data, meta = self.read_file(file)
        while bool(avail_files):
            file = avail_files.pop(0)
            data_new, _ = self.read_file(file)
            for i in meta['variables']:
                data[i] = np.append(data[i], data_new[i])
            data['time'] = np.append(data['time'], data_new['time'])
            data['time_num'] = np.append(data['time_num'], data_new['time_num'])


        for i in range(len(data['time'])):
            data['time'][i] = data['time'][i].replace(tzinfo=datetime.timezone.utc)

        ind = np.where((data['time'] >= self.start) & (data['time'] <= self.end))[0]
        for i in meta['variables']:
            data[i] = data[i][ind]
        data['time'] = data['time'][ind]
        data['time_num'] = data['time_num'][ind]

        meta['start'] = str(data['time'][0])
        meta['end'] = str(data['time'][-1])

        self.data = data
        self.meta = meta

        self.sorted_data = {}

        self.data_attr = {}







    def read_file(self, data_file):
        """
        Function to read one file of Campbell radiation data.
        """

        meta = {}
        data = {}

        meta['variables'] = ["SW_up", "SW_down", "T_rad", "LW_up", "LW_down", "BattV"]

        measurements = np.genfromtxt(data_file, delimiter=",", skip_header=4, usecols=(2,3,6,7,8,9))

        for i, vari in enumerate(meta['variables']):
            data[vari] = measurements[:,i]

        time = np.genfromtxt(data_file, delimiter=",", skip_header=4, usecols=0, dtype=str)
        data_datetime = []
        data_datetime_num = []
        for i in time:
            data_datetime.append(datetime.datetime.strptime(i[1:-1], "%Y-%m-%d %H:%M:%S"))
            data_datetime_num.append(mpl.dates.date2num(data_datetime[-1]))
        data['time'] = np.array(data_datetime)
        data['time_num'] = np.array(data_datetime_num)

        return [data, meta]




    def append_new_instance(self, new_instance):
        """
        Function to append a new instance of the campbellWS class at the end of this one.
        Make sure that the new instance is after the one you append it in time
        :param new_instance
        :return:
        """

        for i in self.meta['variables']:
            self.data[i] = np.append(self.data[i], new_instance.data[i])

        self.data['time'] = np.append(self.data['time'], new_instance.data['time'])
        self.data['time_num'] = np.append(self.data['time_num'], new_instance.data['time_num'])

        self.meta['end'] = new_instance.meta['end']

        self.end = new_instance.end

        self.starts_total.append(new_instance.start)
        self.ends_total.append(new_instance.end)

        return
