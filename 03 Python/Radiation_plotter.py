#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Functions to plot data from a Campbell Weather Station
"""

import datetime
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import sys

from pandas.plotting import register_matplotlib_converters
register_matplotlib_converters()


class Radiation_Plotter:

    def plot_variable(self, variable):
        """
        Plots the time series of data given to the function
        :param variable: string specifying the variable to plot
        """

        labelsize = 16

        fig, ax = plt.subplots(figsize=(18, 12))
        if variable == "RAD":
            ax.plot(self.data["time"], self.data["SW_down"], 'b', label="SW_down")
            ax.plot(self.data["time"], self.data["SW_up"], 'r', label="SW_up")
            ax.plot(self.data["time"], self.data["LW_down"], 'g', label="LW_down")
            ax.plot(self.data["time"], self.data["LW_up"], 'c', label="LW_up")
        elif variable == "T":
            ax.plot(self.data["time"], self.data["T_rad"], 'b', label="brightness temperature")
        else:
            print("The specified variable is not available!")
            sys.exit()
        ax.xaxis.set_major_formatter(mpl.dates.DateFormatter('%H:%M\n%d.%m.%y'))
        #        ax.set_xlabel('time', fontsize=labelsize)
        ax.set_ylabel('{a}'.format(a=variable), fontsize=labelsize)
        ax.tick_params(axis='both', labelsize=labelsize)
        ax.legend(loc=0, fontsize=labelsize)
        ax.set_title('Radiation measurements {a}:    {b}  -  {c}'.format(a=variable, b=str(self.start), c=str(self.end)), fontsize=labelsize + 4)
        ax.grid()
        plt.show()

        return
