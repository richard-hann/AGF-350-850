#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Functions to plot data from a Campbell Weather Station
"""

import datetime
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from pandas.plotting import register_matplotlib_converters
register_matplotlib_converters()


class CampbellWS_Plotter:

    def plot_variable(self, variable):
        """
        Plots the time series of data given to the function
        :param variable: string specifying the variable to plot
        """

        if variable in self.meta['variables_1s']:
            time = self.data['time_1s']
        else:
            time = self.data['time_10s']

        labelsize = 16

        fig, ax = plt.subplots(figsize=(18, 12))
        ax.plot(time, self.data[variable], 'b')
        ax.xaxis.set_major_formatter(mpl.dates.DateFormatter('%H:%M\n%d.%m.%y'))
        #        ax.set_xlabel('time', fontsize=labelsize)
        ax.set_ylabel('{a}'.format(a=variable), fontsize=labelsize)
        ax.tick_params(axis='both', labelsize=labelsize)
        ax.set_title('Campbell {a}:    {b}  -  {c}'.format(a=variable, b=str(self.start), c=str(self.end)), fontsize=labelsize + 4)
        ax.grid()
        plt.show()

        return
