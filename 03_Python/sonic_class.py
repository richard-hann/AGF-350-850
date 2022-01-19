#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Functions to read data from the Sonic
"""

import glob
import os
import re
import datetime
import numpy as np
from netCDF4 import Dataset
import matplotlib as mpl
import matplotlib.pyplot as plt
import pandas as pd
import sonic_plotter
import sys

pd.plotting.register_matplotlib_converters()



class Sonic_flux(sonic_plotter.Sonic_Plotter_flux):
    """
    Contains a structure with the data for the period from start to end by calling read_sonic_flux()
    """

    def __init__(self, start, end, path):
        """"
        :param start: datetime object
        :param end: datetime object
        """

        self.start = start
        self.end = end
        self.path = path

        self.starts_total = [start]
        self.ends_total = [end]

        self.data = {}
        self.meta = {}
        self.sorted_data = {}
        self.data_attr = {}

        avail_path = '{a}/AGF_213_2021_result_*.csv'.format(a=self.path)
        avail_files = sorted(glob.glob(avail_path))


        df_data = self.read_sonic_flux(avail_files.pop(0))
        for file in avail_files:
            df_data = df_data.append(self.read_sonic_flux(file), ignore_index=True, sort=False)

        self.df_data = df_data[(df_data.T_begin >= start) & (df_data.T_end <= end)].reset_index(drop=True).sort_values(by='T_mid')
        self.meta['variables'] = list(df_data.columns)
        self.meta['variables'] = [x for x in self.meta['variables'] if x not in ['T_mid', 'T_begin', 'T_end']]

        self.data['time'] = np.array([mpl.dates.date2num(i) for i in self.df_data['T_mid']])
        self.data['T_begin'] = np.array([mpl.dates.date2num(i) for i in self.df_data['T_begin']])
        self.data['T_end'] = np.array([mpl.dates.date2num(i) for i in self.df_data['T_end']])

        for variable in self.meta['variables']:
            self.data[variable] = self.df_data[variable]

        self.meta['start'] = str(mpl.dates.num2date(self.data['time'][0]))
        self.meta['end'] = str(mpl.dates.num2date(self.data['time'][-1]))



    def read_sonic_flux(self, data_file):
        """
        Reads the data for one given file, converts the timestamps into datetime objects and returns the data in a pandas dataframe
        :param file: file name
        :return df_data: Dataframe containing the data for the day in question
        """

        print('reading {a}'.format(a=os.path.basename(data_file)))

        column_names = ["T_begin", "T_end", "u[m/s]", "v[m/s]", "w[m/s]", "Ts[degC]", "Tp[degC]", "H2O[mmol/mol]",
                        "CO2[umol/mol]", "T_ref[degC]", "a_ref[g/m2]", "p_ref[hPa]", "Var[u]", "Var[v]", "Var[w]",
                        "Var[Ts]", "Var[Tp]", "Var[a]", "Var[CO2]", "Cov[u'v']", "Cov[v'w']", "Cov[u'w']", "Cov[u'Ts']",
                        "Cov[v'Ts']", "Cov[w'Ts']", "Cov[u'Tp']", "Cov[v'Tp']", "Cov[w'Tp']", "Cov[u'H2O']",
                        "Cov[v'H2O']", "Cov[w'H2O']", "Cov[u'CO2']", "Cov[v'CO2']", "Cov[w'CO2']", 'Nvalue', 'dir[deg]',
                        'ustar[m/s]', 'HTs[W/m2]', 'HTp[W/m2]', 'LvE[W/m2]', 'z/L', 'z/L-virt', 'Flag(ustar)',
                        'Flag(HTs)', 'Flag(HTp)', 'Flag(LvE)', 'Flag(wCO2)', 'T_mid', 'Fcstor[mmol/m2s]',
                        'NEE[mmol/m2s]', 'Ftprnt_trgt1[%]', 'Ftprnt_trgt2[%]', 'Ftprnt_xmax[m]', 'r_err_ustar[%]',
                        'r_err_HTs[%]', 'r_err_LvE[%]', 'r_err_co2[%]', 'noise_ustar[%]', 'noise_HTs[%]',
                        'noise_LvE[%]', 'noise_co2[%]', 'empty']

        df_data = pd.read_csv(data_file, header=0, names=column_names, delimiter=',', na_values=-9999.9003906)
        df_data['T_begin'] = pd.to_datetime(df_data['T_begin'], dayfirst=True)
        df_data['T_end'] = pd.to_datetime(df_data['T_end'], dayfirst=True)
        df_data['T_mid'] = pd.to_datetime(df_data['T_mid'], dayfirst=True)

        # calculate TKE
        df_data['TKE[J/kg]'] = 0.5 * (df_data['Var[u]'] + df_data['Var[v]'] + df_data['Var[w]'])

        return df_data


    def append_new_instance(self, new_instance):
        """
        Function to append a new instance of the sonic class at the end of this one.
        Make sure that the new instance is after the one you append it in time
        :param new_instance
        :return:
        """

        for i in self.meta['variables']:
            self.data[i] = np.hstack((self.data[i], new_instance.data[i]))

        for i in ['time', 'T_begin', 'T_end']:
            self.data[i] = np.hstack((self.data[i], new_instance.data[i]))

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
                                          np.arange(self.start + datetime.timedelta(minutes=time_res / 2), \
                                                    self.end, \
                                                    datetime.timedelta(minutes=time_res)).astype(datetime.datetime)])

        irreg_time_grid = self.data['time']

        for variable in self.meta['variables']:
            self.data[variable] = np.interp(reg_time_grid, irreg_time_grid, self.data[variable])

        self.data['time'] = np.array([mpl.dates.num2date(i) for i in reg_time_grid])
        self.data['T_begin'] = self.data['time'] - datetime.timedelta(minutes=time_res/2)
        self.data['T_end'] = self.data['time'] + datetime.timedelta(minutes=time_res/2)

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
        elif operator == '!=' and threshold == 'nan':
            ind = np.where(~np.isnan(self.data[variable][:]))[0]
        else:
            ind = True

        ind = sorted(ind)

        for i in self.meta['variables']:
            self.data[i] = self.data[i][ind]

        for i in ['time', 'T_begin', 'T_end']:
            self.data[i] = self.data[i][ind]

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
            ind_1 = list(np.where(self.data[variable] <= upper_limit)[0])
            ind_2 = list(np.where(self.data[variable] > lower_limit)[0])
            ind = np.array(list(set(ind_1).intersection(ind_2)), dtype=int)
        elif in_out == 'outside':
            ind_1 = list(np.where(self.data[variable] <= lower_limit)[0])
            ind_2 = list(np.where(self.data[variable] > upper_limit)[0])
            ind = np.array(ind_1 + ind_2, dtype=int)
        else:
            ind = True

        ind = sorted(ind)

        for i in self.meta['variables']:
            self.data[i] = self.data[i][ind]

        for i in ['time', 'T_begin', 'T_end']:
            self.data[i] = self.data[i][ind]

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

        for i in ['time', 'T_begin', 'T_end']:
            self.data[i] = self.data[i][ind]

        copy_data_attr = dict(self.data_attr)
        for i in copy_data_attr:
            if i not in self.data['time']:
                del self.data_attr[i]

        self.meta['start'] = str(self.data['time'][0])
        self.meta['end'] = str(self.data['time'][-1])

        return


    def apply_filter_by_index_nan(self, ind):
        """
        Function to filter the time series using the index filter obtained from another instrument timeseries
        :param ind:
        :return
        """

        for i in self.meta['variables']:
            self.data[i][ind] = np.nan

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
            for i in ['time', 'T_begin', 'T_end']:
                self.sorted_data[variable][c][i] = self.data[i][ind_dict[c]]

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
            for i in ['time', 'T_begin', 'T_end']:
                self.sorted_data[variable][c][i] = self.data[i][ind_dict[c]]

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
                    for i in ['time', 'T_begin', 'T_end']:
                        self.sorted_data[c][m][i] = self.data[i][ind]

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
                    for i in ['time', 'T_begin', 'T_end']:
                        self.sorted_data[c][t][i] = self.data[i][ind]

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



class Sonic_raw(sonic_plotter.Sonic_Plotter_raw):
    """
    Contains a structure with the data for the period from start to end by calling read_sonic_raw()
    """

    def __init__(self, start, end, path):
        """"
        :param start: datetime object
        :param end: datetime object
        """

        self.start = start
        self.end = end
        self.path = path

        self.meta = {}

        if start < datetime.datetime(2020,1,1):
            avail_path = '{a}/EC*/TOA5_2246_FLUX_ADV_*.dat'.format(a=self.path)
            avail_files = sorted(glob.glob(avail_path))

            files_to_read = []
            for i in range(len(avail_files)):
                file = os.path.basename(avail_files[i])
                date = file[-12:-4]
                date = datetime.datetime.strptime(date, '%Y%m%d')
                if (date >= start - datetime.timedelta(days=1)) and (date <= end + datetime.timedelta(days=1)):
                    files_to_read.append(file)

            files_to_read = sorted(files_to_read)

            df_data = self.read_sonic_raw_old(files_to_read.pop(0))
            for file in files_to_read:
                df_data = df_data.append(self.read_sonic_raw_old(file), ignore_index=True, sort=False)

        else:
            avail_path = '{a}/EC*/TOA5_7687_Flux_*.dat'.format(a=self.path)
            avail_files = sorted(glob.glob(avail_path))

            files_to_read = []
            for i in range(len(avail_files)):
                file = os.path.basename(avail_files[i])
                date = file[-12:-4]
                date = datetime.datetime.strptime(date, '%Y%m%d')
                if (date >= start - datetime.timedelta(days=1)) and (date <= end + datetime.timedelta(days=1)):
                    files_to_read.append(file)

            files_to_read = sorted(files_to_read)

            df_data = self.read_sonic_raw(files_to_read.pop(0))
            for file in files_to_read:
                df_data = df_data.append(self.read_sonic_raw(file), ignore_index=True, sort=False)


        self.df_data = df_data[(df_data.TIMESTAMP >= start) & (df_data.TIMESTAMP <= end)].reset_index(drop=True).sort_values(by='TIMESTAMP')
        self.meta['variables'] = df_data.columns
        self.meta['start'] = str(self.df_data['TIMESTAMP'].iloc[0])
        self.meta['end'] = str(self.df_data['TIMESTAMP'].iloc[-1])




    def read_sonic_raw_old(self, data_file):
        """
        Reads the data for one given file, converts the timestamps into datetime objects and returns the data in a pandas dataframe
        :param file: file name
        :return df_data: Dataframe containing the data for the day in question
        """

        data_path = '{a}/EC{b}/{c}'.format(a=self.path, b=data_file[-12:-8], c=data_file)
        data_file = sorted(glob.glob(data_path))[0]

        print('reading {a}'.format(a=os.path.basename(data_file)))

        column_names = ["TIMESTAMP","RECORD","Ux","Uy","Uz","Ts","CO2","H2O","Pa"]

        df_data = pd.read_csv(data_file, header=3, names=column_names, delimiter=',', na_values='NAN')
        df_data['TIMESTAMP'] = pd.to_datetime(df_data['TIMESTAMP'])

        return df_data


    def read_sonic_raw(self, data_file):
        """
        Reads the data for one given file, converts the timestamps into datetime objects and returns the data in a pandas dataframe
        :param file: file name
        :return df_data: Dataframe containing the data for the day in question
        """

        data_path = '{a}/EC{b}/{c}'.format(a=self.path, b=data_file[-12:-8], c=data_file)
        data_file = sorted(glob.glob(data_path))[0]

        print('reading {a}'.format(a=os.path.basename(data_file)))

        column_names = ["TIMESTAMP","RECORD","Ux","Uy","Uz","Ts","Diag_vind"]

        df_data = pd.read_csv(data_file, header=3, names=column_names, delimiter=',', na_values='NAN')
        df_data['TIMESTAMP'] = pd.to_datetime(df_data['TIMESTAMP'])

        return df_data
