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
import campbellWS_plotter



class CampbellWS(campbellWS_plotter.CampbellWS_Plotter):
    """
    Contains a structure with the data for the period from start to end by calling read_file()
    """

    def __init__(self, start, end, path):
        """"
        :param start: datetime object
        :param end: datetime object
        """

        self.start = start.replace(tzinfo=datetime.timezone.utc)
        self.end = end.replace(tzinfo=datetime.timezone.utc)
        self.path = path

        self.starts_total = [start]
        self.ends_total = [end]

        self.data = {}
        self.meta = {}
        self.sorted_data = {}
        self.data_attr = {}

        avail_files_1s = sorted(glob.glob('{a}/1207_{b}*.dat'.format(a=self.path, b="1_s")))

        file_1s = avail_files_1s.pop(0)
        data, meta = self.read_1s_file(file_1s)
        while bool(avail_files_1s):
            file_1s = avail_files_1s.pop(0)
            data_new, _ = self.read_1s_file(file_1s)
            for i in meta['variables_1s']:
                data[i] = np.append(data[i], data_new[i])
            data['time_1s'] = np.append(data['time_1s'], data_new['time_1s'])
            data['time_1s_num'] = np.append(data['time_1s_num'], data_new['time_1s_num'])


        avail_files_10s = sorted(glob.glob('{a}/1207_{b}*.dat'.format(a=self.path, b="10_s")))

        file_10s = avail_files_10s.pop(0)
        data_10s, meta_10s = self.read_10s_file(file_10s)
        while bool(avail_files_10s):
            file_10s = avail_files_10s.pop(0)
            data_new, _ = self.read_10s_file(file_10s)
            for i in meta_10s['variables_10s']:
                data_10s[i] = np.append(data_10s[i], data_new[i])
            data_10s['time_10s'] = np.append(data_10s['time_10s'], data_new['time_10s'])
            data_10s['time_10s_num'] = np.append(data_10s['time_10s_num'], data_new['time_10s_num'])


        data.update(data_10s)
        meta.update(meta_10s)

        for i in range(len(data['time_1s'])):
            data['time_1s'][i] = data['time_1s'][i].replace(tzinfo=datetime.timezone.utc)
        for i in range(len(data['time_10s'])):
            data['time_10s'][i] = data['time_10s'][i].replace(tzinfo=datetime.timezone.utc)

        ind = np.where((data['time_1s'] >= self.start) & (data['time_1s'] <= self.end))[0]
        for i in meta['variables_1s']:
            data[i] = data[i][ind]
        data['time_1s'] = data['time_1s'][ind]
        data['time_1s_num'] = data['time_1s_num'][ind]

        ind = np.where((data['time_10s'] >= self.start) & (data['time_10s'] <= self.end))[0]
        for i in meta['variables_10s']:
            data[i] = data[i][ind]
        data['time_10s'] = data['time_10s'][ind]
        data['time_10s_num'] = data['time_10s_num'][ind]

        meta['start'] = str(data['time_1s'][0])
        meta['end'] = str(data['time_1s'][-1])

        self.data = data
        self.meta = meta

        self.sorted_data = {}

        self.data_attr = {}







    def read_1s_file(self, data_file):
        """
        Function to read one 1s-file of Campbell (wind) data.
        """

        meta = {}
        data = {}

        meta['variables_1s'] = ["wspeed_1", "wdir_1", "wspeed_2", "wdir_2"]

        wind = np.genfromtxt(data_file, delimiter=",", skip_header=4, usecols=(3,4,5,6))

        for i, vari in enumerate(meta['variables_1s']):
            data[vari] = wind[:,i]

        time = np.genfromtxt(data_file, delimiter=",", skip_header=4, usecols=0, dtype=str)
        data_datetime = []
        data_datetime_num = []
        for i in time:
            data_datetime.append(datetime.datetime.strptime(i[1:-1], "%Y-%m-%d %H:%M:%S"))
            data_datetime_num.append(mpl.dates.date2num(data_datetime[-1]))
        data['time_1s'] = np.array(data_datetime)
        data['time_1s_num'] = np.array(data_datetime_num)

        return [data, meta]


    def read_10s_file(self, data_file):
        """
        Function to read one 10s-file of Campbell (temperature & humidity) data.
        """

        meta = {}
        data = {}

        meta['variables_10s'] = ["temperature_1", "humidty_1", "temperature_2", "humidity_2"]

        temperature = np.genfromtxt(data_file, delimiter=",", skip_header=4, usecols=(4,5,6,7))

        for i, vari in enumerate(meta['variables_10s']):
            data[vari] = temperature[:,i]

        time = np.genfromtxt(data_file, delimiter=",", skip_header=4, usecols=0, dtype=str)
        data_datetime = []
        data_datetime_num = []
        for i in time:
            data_datetime.append(datetime.datetime.strptime(i[1:-1], "%Y-%m-%d %H:%M:%S"))
            data_datetime_num.append(mpl.dates.date2num(data_datetime[-1]))
        data['time_10s'] = np.array(data_datetime)
        data['time_10s_num'] = np.array(data_datetime_num)

        return [data, meta]


    def append_new_instance(self, new_instance):
        """
        Function to append a new instance of the campbellWS class at the end of this one.
        Make sure that the new instance is after the one you append it in time
        :param new_instance
        :return:
        """

        for i in self.meta['variables_1s']:
            self.data[i] = np.append(self.data[i], new_instance.data[i])
        for i in self.meta['variables_10s']:
            self.data[i] = np.append(self.data[i], new_instance.data[i])

        self.data['time_1s'] = np.append(self.data['time_1s'], new_instance.data['time_1s'])
        self.data['time_10s'] = np.append(self.data['time_10s'], new_instance.data['time_10s'])
        self.data['time_1s_num'] = np.append(self.data['time_1s_num'], new_instance.data['time_1s_num'])
        self.data['time_10s_num'] = np.append(self.data['time_10s_num'], new_instance.data['time_10s_num'])

        self.meta['end'] = new_instance.meta['end']

        self.end = new_instance.end

        self.starts_total.append(new_instance.start)
        self.ends_total.append(new_instance.end)

        return
