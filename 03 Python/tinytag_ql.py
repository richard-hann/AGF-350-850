#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script to plot a variable from the Tinytag.
"""

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
import datetime
import argparse
import sys
import tinytag_class

plt.close('all')

parser = argparse.ArgumentParser(description='Plot the tinytag data variable for the given period.')
parser.add_argument('start', help='A string in the format YYYYmmddHH.')
parser.add_argument('end', help='A string in the format YYYYmmddHH.')
parser.add_argument('path', help='A string specifying the path where the data is stored.')
parser.add_argument('mode', help='A string specifying the type of the sensor (TT, TH or CEB)')
parser.add_argument('sensor_nr', help='A string specifying the number of the sensor')
parser.add_argument('variable', help='A string specifying the variable to plot.')
args = parser.parse_args()

start = datetime.datetime.strptime(args.start, '%Y%m%d%H')
end = datetime.datetime.strptime(args.end, '%Y%m%d%H')
path = args.path
mode = args.mode
sensor_nr = args.sensor_nr

if start > end:
    print('Start of period must not be later than end!')
    sys.exit()

tinytag = tinytag_class.Tinytag(start, end, path, mode, sensor_nr)


if args.variable in tinytag.meta['variables']:
    tinytag.plot_variable(args.variable)
else:
    print('Chosen variable not included in the dataset.')
    print('The variables are:')
    print(tinytag.meta['variables'])
    sys.exit()
