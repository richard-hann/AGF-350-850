#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script to plot a variable from the Radiometer.
"""

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
import datetime
import argparse
import sys
import Radiation_class

plt.close('all')

parser = argparse.ArgumentParser(description='Plot the radiation data for the given period.')
parser.add_argument('start', help='A string in the format YYYYmmddHH.')
parser.add_argument('end', help='A string in the format YYYYmmddHH.')
parser.add_argument('path', help='A string specifying the path where the data is stored.')
parser.add_argument('variable', help='A string specifying the variable to plot. (Either "RAD" for the 4 radiation components or "T" for the brightness temperature)')
parser.add_argument('logger', help='A string specifying the logger. (Either "agf212" or "radiation".')
args = parser.parse_args()

start = datetime.datetime.strptime(args.start, '%Y%m%d%H')
end = datetime.datetime.strptime(args.end, '%Y%m%d%H')
path = args.path
logger = args.logger

if start > end:
    print('Start of period must not be later than end!')
    sys.exit()

radiation = Radiation_class.Radiation(start, end, path, logger=logger)
radiation.plot_variable(args.variable)
