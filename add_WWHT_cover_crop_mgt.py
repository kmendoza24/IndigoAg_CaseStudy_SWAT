
from pathlib import Path

cover = '''Initial Plant Growth Parameters
1                   | IGRO: Land cover status: 0-none growing; 1-growing
28                  | PLANT_ID: Land cover ID number (IGRO = 1)
1.00                | LAI_INIT: Initial leaf are index (IGRO = 1)
1000.00             | BIO_INIT: Initial biomass (kg/ha) (IGRO = 1)
2000.00             | PHU_PLT: Number of heat units to bring plant to maturity (IGRO = 1)
General Management Parameters
0.20                | BIOMIX: Biological mixing efficiency
%s               | CN2: Initial SCS CN II value
1.00                | USLE_P: USLE support practice factor
1200.00             | BIO_MIN: Minimum biomass for grazing (kg/ha)
0.000               | FILTERW: width of edge of field filter strip (m)
Urban Management Parameters
0                   | IURBAN: urban simulation code, 0-none, 1-USGS, 2-buildup/washoff
0                   | URBLU: urban land type
Irrigation Management Parameters
0                   | IRRSC: irrigation code
0                   | IRRNO: irrigation source location
0.000               | FLOWMIN: min in-stream flow for irr diversions (m^3/s)
0.000               | DIVMAX: max irrigation diversion from reach (+mm/-10^4m^3)
0.000               | FLOWFR: : fraction of flow allowed to be pulled for irr
Tile Drain Management Parameters
0.000               | DDRAIN: depth to subsurface tile drain (mm)
0.000               | TDRAIN: time to drain soil to field capacity (hr)
0.000               | GDRAIN: drain tile lag time (hr)
Management Operations
1                   | NROT: number of years of rotation
Operation Schedule
 03 31           5                  
 04 01           1   12          1800.00000  
 04 02           3    1           100.00000
 09 30           7
 10 02           1   28          1600.00000
                 0
'''

##
# WWHT 28
# PAST 12


# Cover Crop Mgt File
infile = Path(r'D:\AOI\huc14-11110105040301\Scenarios\Baseline\TxtInOut\000010042.mgt')

with open(infile, 'r') as f_in:
    txt = f_in.read()

# get cn2 value
for line in txt.split('\n'):
    if 'CN2' in line:
        cn2 = line.split('|')[0].strip()
        pretxt = txt.split('Initial Plant Growth Parameters')[0]

newtxt = pretxt + (cover % (cn2))
print(newtxt)

# Output folder + same filename
outpath = Path(r'D:\AOI\huc14-11110105040301\Scenarios\CoverCrop\TxtInOut')
outpath.mkdir(parents=True, exist_ok=True)

outfile = outpath / infile.name

with open(outfile, 'w') as f_out:
    f_out.write(newtxt)