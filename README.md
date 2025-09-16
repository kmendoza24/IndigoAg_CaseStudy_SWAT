# Indigo_Ag_Case_Study

Model and code used for interview case study.

---

## Contents

### 1. `SWAT_model.7z`
Zipped folder containing the SWAT model and associated data:

- **Source data:**  
  - Land use: `huc14-11110105040301/Source/crop/landuse.tif`  
  - Soil: `huc14-11110105040301/Source/soil/soil.tif`  
  - Elevation: `huc14-11110105040301/Source/dem.tif`  

- **Watershed shapefiles:**  
  - Subbasins: `huc14-11110105040301/Watershed/Shapes/demwshed.shp`  
  - Channels: `huc14-11110105040301/Watershed/Shapes/channels.shp`  

- **Scenarios:**  
  - `Baseline`: `huc14-11110105040301/Scenarios/Baseline/TxtInOut`  
  - `CoverCrop`: `huc14-11110105040301/Scenarios/CoverCrop/TxtInOut`  

Each scenario folder contains:  
  - All input files, SWAT executable, and output files.  

- **Generated outputs:**  
  - Table: `huc14-11110105040301/Scenarios/VolumetricWaterOupputs_YR22.xlsx`  
  - Figure: `huc14-11110105040301/Scenarios/WaterBalance_Timeseries.png`  

> ⚠️ Note: This file must be downloaded and unzipped to access the full contents.  

---

### 2. `ArcGIS_Pro_data.7z`
Zipped folder containing the ArcGIS Pro project to visualize the SWAT model:

- ArcGIS project file  
- AOI shapefile  

> ⚠️ Note: This file must be downloaded and unzipped. You may need to repair the sources for the files found in the `SWAT_model.7z` folder to view all layers.

---

### 3. Python Scripts

- `updated_hru.fr.py`  
  Updates the HRU fraction (`hru_fr`) to simulate the AOI field size while maintaining the full watershed area.

- `add_WWHT_cover_crop_mgt.py`  
  Updates management for the AOI field with a winter wheat cover crop on pasture.

---

### 4. R Scripts

- `compile_hru_output.R`  
  Generates the table and figure for the cover crop volumetric water balance simulated with the SWAT model.

---

### 5. PowerPoint Presentation

- `Mendoza_CaseStudy.pptx`  
  Presentation detailing the creation of the SWAT model, generation of Baseline and Cover Crop scenarios, and analysis of outputs for the Volumetric Water Benefit (VWB) case study.
