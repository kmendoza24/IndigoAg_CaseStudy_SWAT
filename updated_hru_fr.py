from pathlib import Path

# Base folder
base_folder = Path(r'D:\AOI\huc14-11110105040301\Scenarios\Baseline\TxtInOut')

# Input files 
filenames = [
    "000010042.hru",
    "000010102.hru"
]

# Corresponding new HRU_FR values
new_hru_fr_values = [
    "0.0050708",
    "0.1842056"
]

# Combine filenames and values
files_and_values = [(base_folder / fname, value) for fname, value in zip(filenames, new_hru_fr_values)]

# Loop through files and replace HRU_FR values
for infile, new_hru_fr in files_and_values:
    with open(infile, 'r') as f_in:
        lines = f_in.readlines()

    newlines = []
    for line in lines:
        if 'HRU_FR' in line:  # find the line containing HRU_FR
            parts = line.split('|')
            # Left-align the value and fill 20 spaces
            parts[0] = f"{new_hru_fr:<20}"
            line = '|'.join(parts)
        newlines.append(line)

    # Overwrite the original file
    with open(infile, 'w') as f_out:
        f_out.writelines(newlines)

    print(f"Updated {infile.name}")