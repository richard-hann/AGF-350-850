#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Functions to plot data from the Tinytag
"""

import datetime
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
from pandas.plotting import register_matplotlib_converters

register_matplotlib_converters()


# set the colormap and centre the colorbar
class MidpointNormalize(mpl.colors.Normalize):
    """
    Normalise the colorbar so that diverging bars work there way either side from a prescribed midpoint value)

    e.g. im=ax1.imshow(array, norm=MidpointNormalize(midpoint=0.,vmin=-100, vmax=100))
    """

    def __init__(self, vmin=None, vmax=None, midpoint=None, clip=False):
        self.midpoint = midpoint
        mpl.colors.Normalize.__init__(self, vmin, vmax, clip)

    def __call__(self, value, clip=None):
        # I'm ignoring masked values and all kinds of edge cases to make a
        # simple example...
        x, y = [self.vmin, self.midpoint, self.vmax], [0, 0.5, 1]
        return np.ma.masked_array(np.interp(value, x, y), np.isnan(value))



class Tinytag_Plotter:

    def plot_variable(self, variable):

        labelsize = 14

        fig, ax = plt.subplots(figsize=(18, 12))
        ax.plot(self.data["time"], self.data[variable], 'b')
        ax.xaxis.set_major_formatter(mpl.dates.DateFormatter('%H:%M\n%d.%m.%y'))
        ax.tick_params('both', labelsize=labelsize)
        ax.set_ylabel(variable, fontsize=labelsize)
        ax.set_title('{m}{s} {a}:    {b}  -  {c}'.format(a=variable, m=self.mode, s=self.sensor_nr, b=self.start, c=self.end), \
                     fontsize=labelsize + 4)
        ax.grid()
        plt.show()


        return