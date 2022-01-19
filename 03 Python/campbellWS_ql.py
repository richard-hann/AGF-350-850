#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script to plot a variable from the Campbell Weather Stations.
"""

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
import datetime
import argparse
import sys
import campbellWS_class

plt.close('all')

parser = argparse.ArgumentParser(description='Plot the weather station data variable for the given period.')
parser.add_argument('start', help='A string in the format YYYYmmddHH.')
parser.add_argument('end', help='A string in the format YYYYmmddHH.')
parser.add_argument('path', help='A string specifying the path where the data is stored.')
parser.add_argument('variable', help='A string specifying the variable to plot.')
args = parser.parse_args()

start = datetime.datetime.strptime(args.start, '%Y%m%d%H')
end = datetime.datetime.strptime(args.end, '%Y%m%d%H')
path = args.path

if start > end:
    print('Start of period must not be later than end!')
    sys.exit()

campbell = campbellWS_class.CampbellWS(start, end, path)
campbell.plot_variable(args.variable)
