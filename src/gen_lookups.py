import numpy as np
import apytypes as apy
from apytypes.vhdl import generate_rom


def save_lookup(arr):
    apy_arr = apy.fx(arr, int_bits=8, frac_bits=0)
    generate_rom(apy_arr)


def gen_lookups():
    inputs = np.asarray(list(range(256)))
    sine = (np.sin(np.pi*inputs/255)+1)*255/2
    save_lookup(sine)
    

gen_lookups()