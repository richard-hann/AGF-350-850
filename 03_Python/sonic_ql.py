#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script to plot a variable from the Sonic.
"""

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
import datetime
import argparse
import sys
import sonic_class

plt.close('all')

parser = argparse.ArgumentParser(description='Plot the sonic data variable for the given period.')
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

variables_raw = ["TIMESTAMP","RECORD","Ux","Uy","Uz","Ts","CO2","H2O","Pa","Diag_vind"]

variables_flux = ["T_begin", "T_end", "u[m/s]", "v[m/s]", "w[m/s]", "Ts[degC]", "Tp[degC]", "H2O[mmol/mol]",
                        "CO2[umol/mol]", "T_ref[degC]", "a_ref[g/m2]", "p_ref[hPa]", "Var[u]", "Var[v]", "Var[w]",
                        "Var[Ts]", "Var[Tp]", "Var[a]", "Var[CO2]", "Cov[u'v']", "Cov[v'w']", "Cov[u'w']", "Cov[u'Ts']",
                        "Cov[v'Ts']", "Cov[w'Ts']", "Cov[u'Tp']", "Cov[v'Tp']", "Cov[w'Tp']", "Cov[u'H2O']",
                        "Cov[v'H2O']", "Cov[w'H2O']", "Cov[u'CO2']", "Cov[v'CO2']", "Cov[w'CO2']", 'Nvalue', 'dir[deg]',
                        'ustar[m/s]', 'HTs[W/m2]', 'HTp[W/m2]', 'LvE[W/m2]', 'z/L', 'z/L-virt', 'Flag(ustar)',
                        'Flag(HTs)', 'Flag(HTp)', 'Flag(LvE)', 'Flag(wCO2)', 'T_mid', 'Fcstor[mmol/m2s]',
                        'NEE[mmol/m2s]', 'Ftprnt_trgt1[%]', 'Ftprnt_trgt2[%]', 'Ftprnt_xmax[m]', 'r_err_ustar[%]',
                        'r_err_HTs[%]', 'r_err_LvE[%]', 'r_err_co2[%]', 'noise_ustar[%]', 'noise_HTs[%]',
                        'noise_LvE[%]', 'noise_co2[%]', 'empty']


if args.variable in variables_raw:
    sonic_raw = sonic_class.Sonic_raw(start, end, path)
    sonic_raw.plot_variable(args.variable)
if args.variable in variables_flux:
    sonic_flux = sonic_class.Sonic_flux(start, end, path)
    sonic_flux.plot_variable(args.variable)
if (args.variable not in variables_raw) and (args.variable not in variables_flux):
    print('Chosen variable not included in the dataset.')
    print('The raw variables are:')
    print(variables_raw)
    print('')
    print('The processed variables are:')
    print(variables_flux)
    sys.exit()
