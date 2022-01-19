#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Functions to read data from the tinytag to get temperature time series from a low level
(can be used in combination with the Adventdalen AWS temperature data to estimate the suface-based inversion strength)
"""

import numpy as np
import datetime
import pandas as pd
import matplotlib as mpl
import glob
import os
import io
import sys
import requests
import tinytag_plotter





class Tinytag(tinytag_plotter.Tinytag_Plotter):
    """
    Contains a structure with the tinytag data for the period from start to end by calling the different AWS-functions
    """

    def __init__(self,  start=datetime.datetime(1900,1,1,0,0,0),
                                end=datetime.datetime(2100,12,31,23,59,59), path="/home/lukas/Schreibtisch", mode="TT", sensor_nr="3"):
        """"
        :param start: datetime object
        :param end: datetime object
        """

        self.start = start.replace(tzinfo=datetime.timezone.utc)
        self.end = end.replace(tzinfo=datetime.timezone.utc)
        self.path = path
        self.mode = mode
        self.sensor_nr = sensor_nr

        self.starts_total = [start]
        self.ends_total = [end]

        self.meta = {}

        self.sorted_data = {}

        self.data_attr = {}
            
            
        avail_files = sorted(glob.glob('{a}/*_{m}{s}.txt'.format(a=self.path, m=self.mode, s=self.sensor_nr)))

        file = avail_files.pop(0)
        data, meta = self.read_file(file)
        while bool(avail_files):
            file = avail_files.pop(0)
            data_new, _ = self.read_file(file)
            for i in meta['variables']:
                data[i] = np.append(data[i], data_new[i])
            data['time'] = np.append(data['time'], data_new['time'])
            
        
        for i in range(len(data['time'])):
            data['time'][i] = data['time'][i].replace(tzinfo=datetime.timezone.utc)
            
            
        ind = np.where((data['time'] >= self.start) & (data['time'] <= self.end))[0]
        for i in meta['variables']:
            data[i] = data[i][ind]
        data['time'] = data['time'][ind]
        
        meta['start'] = str(data['time'][0])
        meta['end'] = str(data['time'][-1])

        self.data = data
        self.meta = meta
        
        

    def read_file(self, file):
        """
        Function to read one file of Tinytag data.
        """
        
        print('reading {a}'.format(a=file))
        
        data = {}
        meta = {}
        meta["variables"] = []

        if self.mode == "CEB":
            df_data = pd.read_table(file, delimiter='\s', names = ["date", "time", "temperature"], header=5, usecols=[1,2,3], engine="python")     
        elif self.mode == "TT":
            df_data = pd.read_table(file, delimiter='\s', names = ["date", 'time', 'temperature_black', 'temperature_white'], header=5, engine="python", usecols=[1,2,3,5])
        elif self.mode == "TH":
            df_data = pd.read_table(file, delimiter='\s', names = ["date", 'time', 'temperature', 'humidity'], header=5, engine="python", usecols=[1,2,3,5])

        df_data["datetime"] = df_data["date"] + " " + df_data["time"]

        data['time'] = np.array([datetime.datetime.strptime(i, "%Y-%m-%d %H:%M:%S") for i in df_data["datetime"]])
        
        for k in df_data:
            if k != "time":  
                data[k] = df_data[k].to_numpy()
                meta['variables'].append(k)
                
        return [data, meta]




    def append_new_instance(self, new_instance):
        """
        Function to append a new instance of the tinytag class at the end of this one.
        Make sure that the new instance is after the one you append it in time
        :param new_instance
        :return:
        """

        for i in self.meta['variables']:
            self.data[i] = np.hstack((self.data[i], new_instance.data[i]))

        self.data['time'] = np.hstack((self.data['time'], new_instance.data['time']))

        self.meta['end'] = new_instance.meta['end']

        self.end = new_instance.end

        self.starts_total.append(new_instance.start)
        self.ends_total.append(new_instance.end)

        return


    def interp_onto_timegrid(self, time_res=10):
        """
        Function to interpolate the data onto a regular grid in time to enable direct comparison
        :param time_res
        """

        reg_time_grid = np.array([mpl.dates.date2num(i) for i in \
                                  np.arange(self.start + datetime.timedelta(minutes=time_res/2), \
                                            self.end, \
                                            datetime.timedelta(minutes=time_res)).astype(datetime.datetime)])

        irreg_time_grid = np.array([mpl.dates.date2num(i) for i in self.df_data['time']])

        self.data = {}

        for variable in self.meta['variables']:
            self.data[variable] = np.interp(reg_time_grid, irreg_time_grid, self.df_data[variable])

        self.data['time'] = np.array([mpl.dates.num2date(i) for i in reg_time_grid])

        self.meta['start'] = str(self.data['time'][0])
        self.meta['end'] = str(self.data['time'][-1])

        # set gaps to nan
        self.starts_total.pop(0)
        self.ends_total.pop()

        while bool(self.starts_total) == True:
            ind = np.where((self.data['time'] >= self.ends_total.pop(0).replace(tzinfo=datetime.timezone.utc)) & \
                           (self.data['time'] <= self.starts_total.pop(0).replace(tzinfo=datetime.timezone.utc)))[0]
            for variable in self.meta['variables']:
                self.data[variable][ind] = np.nan

        return


    def initialize_data_attr(self):
        """
        Function to initialze the data_attr dictionary and set the datetime-keys
        :return:
        """

        for i in self.data['time']:
            self.data_attr[i] = {}

        return



    def filter_by_variable(self, variable, operator, threshold):
        """
        Function to filter the time series for those timestamps, when variable exceeds threshold according to operator.
        :param variable:
        :param operator:
        :param threshold:
        :return ind: time indices of the timestamps fulfilling the threshold condition --> to be used for the other instruments
        """


        if operator == '<':
            ind = np.where(self.data[variable][:] < threshold)[0]
        elif operator == '<=':
            ind = np.where(self.data[variable][:] <= threshold)[0]
        elif operator == '>=':
            ind = np.where(self.data[variable][:] >= threshold)[0]
        elif operator == '>':
            ind = np.where(self.data[variable][:] > threshold)[0]
        else:
            ind = True

        ind = sorted(ind)

        for i in self.meta['variables']:
            self.data[i] = self.data[i][:, ind]

        self.data['time'] = self.data['time'][ind]

        copy_data_attr = dict(self.data_attr)
        for i in copy_data_attr:
            if i not in self.data['time']:
                del self.data_attr[i]

        self.meta['start'] = str(self.data['time'][0])
        self.meta['end'] = str(self.data['time'][-1])

        return ind


    def filter_by_variable_interval(self, variable, lower_limit, upper_limit, in_out):
        """
        Function to filter using only a certain data range of variable
        :param variable:
        :param lower_limit:
        :param upper_limit:
        :param in_out: switch to determine, if the data inside or outside the limits should be taken
        :return ind: time indices of the timestamps fulfilling the threshold condition --> to be used for the other instruments
        """

        if in_out == 'inside':
            ind_1 = list(np.where(self.data[variable] < upper_limit)[0])
            ind_2 = list(np.where(self.data[variable] > lower_limit)[0])
            ind = np.array(set(ind_1).intersection(ind_2), dtype=int)
        elif in_out == 'outside':
            ind_1 = list(np.where(self.data[variable] < lower_limit)[0])
            ind_2 = list(np.where(self.data[variable] > upper_limit)[0])
            ind = np.array(ind_1 + ind_2, dtype=int)
        else:
            ind = True

        ind = sorted(ind)

        for i in self.meta['variables']:
            self.data[i] = self.data[i][:, ind]

        self.data['time'] = self.data['time'][ind]

        copy_data_attr = dict(self.data_attr)
        for i in copy_data_attr:
            if i not in self.data['time']:
                del self.data_attr[i]

        self.meta['start'] = str(self.data['time'][0])
        self.meta['end'] = str(self.data['time'][-1])

        return ind



    def apply_filter_by_index(self, ind):
        """
        Function to filter the time series using the index filter obtained from another instrument timeseries
        :param ind:
        :return
        """

        for i in self.meta['variables']:
            self.data[i] = self.data[i][ind]

        self.data['time'] = self.data['time'][ind]

        copy_data_attr = dict(self.data_attr)
        for i in copy_data_attr:
            if i not in self.data['time']:
                del self.data_attr[i]

        self.meta['start'] = str(self.data['time'][0])
        self.meta['end'] = str(self.data['time'][-1])

        return



    def sort_into_classes(self, classes, variable):
        """
        Function to sort the data from the sonic into the given classes
        :param stability_classes:
        :return: ind_dict
        """

        ind_dict = {}

        for c in classes[variable]:
            ind_1 = list(np.where(self.data[variable] <= classes[variable][c][1])[0])
            ind_2 = list(np.where(self.data[variable] > classes[variable][c][0])[0])
            ind_dict[c] = np.array(list(set(ind_1).intersection(ind_2)), dtype=int)

        self.meta['sorting_categories'] = {variable: classes[variable]}

        self.sorted_data[variable] = {}

        for c in self.meta['sorting_categories'][variable]:
            self.sorted_data[variable][c] = {}
            for i in self.meta['variables']:
                self.sorted_data[variable][c][i] = self.data[i][ind_dict[c]]
            self.sorted_data[variable][c]['time'] = self.data['time'][ind_dict[c]]

            for i in self.sorted_data[variable][c]['time']:
                self.data_attr[i][variable] = c

        return ind_dict


    def apply_sorting_by_index(self, ind_dict, classes, variable):
        """
        Function to sort the data from the sonic into the given classes using the indices obtained by the sort_into_classes-function of the AWS
        :param ind_dict:
        :return:
        """

        self.meta['sorting_categories'] = {variable: classes[variable]}

        self.sorted_data[variable] = {}

        for c in self.meta['sorting_categories'][variable]:
            self.sorted_data[variable][c] = {}
            for i in self.meta['variables']:
                self.sorted_data[variable][c][i] = self.data[i][ind_dict[c]]
            self.sorted_data[variable][c]['time'] = self.data['time'][ind_dict[c]]

            for i in self.sorted_data[variable][c]['time']:
                self.data_attr[i][variable] = c

        return



    def sort_in_time(self, classes):
        """
        Function to sort the data into different categories in time, e.g. months, daytimes,
        :param classes:
        :return:
        """

        for c in classes:
            if c == 'months':
                self.meta['sorting_categories'] = {c: classes[c]}
                self.sorted_data[c] = {}
                for m in classes[c]:
                    self.sorted_data[c][m] = {}
                    ind = []
                    for i, timestamp in enumerate(self.data['time']):
                        if timestamp.month == classes[c][m]:
                            ind.append(i)
                    for i in self.meta['variables']:
                        self.sorted_data[c][m][i] = self.data[i][ind]
                    self.sorted_data[c][m]['time'] = self.data['time'][ind]

                    for i in self.sorted_data[c][m]['time']:
                        self.data_attr[i][c] = m

            elif c == 'daytimes':
                self.meta['sorting_categories'] = {c: classes[c]}
                self.sorted_data[c] = {}
                for ti, t in enumerate(classes[c]):
                    self.sorted_data[c][t] = {}
                    ind = []
                    for i, timestamp in enumerate(self.data['time']):
                        if ti == 0:
                            if (timestamp.hour) >= classes[c][t][0] or (timestamp.hour) < classes[c][t][1]:
                                ind.append(i)
                        else:
                            if (timestamp.hour) >= classes[c][t][0] and (timestamp.hour) < classes[c][t][1]:
                                ind.append(i)
                    for i in self.meta['variables']:
                        self.sorted_data[c][t][i] = self.data[i][ind]
                    self.sorted_data[c][t]['time'] = self.data['time'][ind]

                    for i in self.sorted_data[c][t]['time']:
                        self.data_attr[i][c] = t

        return



    def fill_empty_pixels_1D(self, variable, limit=1):
        """
        Fills missing pixels (interpolation in time, if not more than limit timesteps are missing)
        :param variable: string specifying the variable to plot
        :param limit: maximal number of consecutive pixels are allowed to be missing
        """

        def find_empty_slices(array):
            """
            A function to find the indices of missing data grid points.
            The returned list contains sub-lists, which contain the consecutive indices, for each height level
            """

            indices2 = []

            indices = list(np.where(np.isnan(array))[0])

            indices.reverse()

            while bool(indices) == True:
                index = [indices.pop()]
                while (bool(indices) == True) and (indices[-1] - index[-1] == 1):
                    index.append(indices.pop())
                indices2.append(index)

            return indices2



        indices_complete = find_empty_slices(self.data[variable])

        for ind in indices_complete:
            if len(ind) < (limit + 1):
                if 0 in ind:
                    if (~np.isnan(self.data[variable][ind[-1] + 1])):
                        self.data[variable][ind[0]:ind[-1] + 1] = \
                            np.interp(ind, [ind[-1] + 1, ind[-1] + 2], [self.data[variable][ind[-1] + 1], \
                                                                        self.data[variable][ind[-1] + 2]])
                elif len(self.data[variable]) - 1 in ind:
                    if (~np.isnan(self.data[variable][ind[0] - 1])):
                        self.data[variable][ind[0]:ind[-1] + 1] = \
                            np.interp(ind, [ind[0] - 2, ind[0] - 1], [self.data[variable][ind[0] - 2], \
                                                                      self.data[variable][ind[0] - 1]])
                else:
                    if (~np.isnan(self.data[variable][ind[0] - 1])) and (
                    ~np.isnan(self.data[variable][ind[-1] + 1])):
                        self.data[variable][ind[0]:ind[-1] + 1] = \
                            np.interp(ind, [ind[0] - 1, ind[-1] + 1], [self.data[variable][ind[0] - 1], \
                                                                       self.data[variable][ind[-1] + 1]])

        return
