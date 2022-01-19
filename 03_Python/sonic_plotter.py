#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Functions to plot data from the Sonic
"""

import datetime
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt


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



class Sonic_Plotter_flux:

    def plot_variable(self, variable):

        labelsize = 14
        timestamp = self.df_data['T_mid']

        fig, ax = plt.subplots(figsize=(18, 12))
        ax.plot(timestamp, self.df_data[variable], 'b')
        ax.set_xlim((timestamp.iloc[0] - 0.03 * (timestamp.iloc[-1] - timestamp.iloc[0]),
                     timestamp.iloc[-1] + 0.03 * (timestamp.iloc[-1] - timestamp.iloc[0])))
        ax.tick_params('both', labelsize=labelsize)
        ax.set_ylabel(variable, fontsize=labelsize)
        ax.set_title('Sonic flux {a}:    {b}  -  {c}'.format(a=variable, b=self.meta['start'], c=self.meta['end']), \
                     fontsize=labelsize + 4)
        ax.grid()
        plt.show()

        return


class Sonic_Plotter_raw:

    def plot_variable(self, variable):

        labelsize = 14
        timestamp = self.df_data['TIMESTAMP']

        fig, ax = plt.subplots(figsize=(18, 12))
        ax.plot(timestamp, self.df_data[variable], 'b')
        ax.set_xlim((timestamp.iloc[0] - 0.03 * (timestamp.iloc[-1] - timestamp.iloc[0]),
                     timestamp.iloc[-1] + 0.03 * (timestamp.iloc[-1] - timestamp.iloc[0])))
        ax.tick_params('both', labelsize=labelsize)
        ax.set_ylabel(variable, fontsize=labelsize)
        ax.set_title('Sonic raw {a}:    {b}  -  {c}'.format(a=variable, b=self.meta['start'], c=self.meta['end']), \
                     fontsize=labelsize + 4)
        ax.grid()
        plt.show()

        return