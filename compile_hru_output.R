library(data.table)
library(openxlsx)   # for writing Excel
library(ggplot2)    # for plotting
library(patchwork)  # for multi-panel plots
library(ggplot2)

path = 'D:/AOI/huc14-11110105040301/Scenarios/'

bmp = c('Baseline','CoverCrop')

# Function to read and parse HRU output
read_hru <- function(scenario) {
  hru_file <- file.path(path, scenario, 'TxtInOut/output.hru')
  hru_txt <- readLines(hru_file)
  
  hru_data_list <- list()
  
  for(k in 10:length(hru_txt)){   # skip headers
    row <- hru_txt[k]
    
    lulc <- substr(row,1,4)
    hru <- substr(row,11,19)
    sub <- substr(row,22,24)
    YR <- substr(row,31,34)
    area <- substr(row,35,44) #km2
    precip <- substr(row,47,54) #mm
    et <- substr(row,95,104) #mm
    sw_int <- substr(row,106,114) #mm
    sw_end <- substr(row,118,124) #mm
    gw_rchg <-substr(row,138,144) #mm
    da_rchg <- substr(row,148,154) #mm
    surq_gen <- substr(row,207,214) #mm
    wyld <- substr(row,257,264) #mm
    syld <- substr(row,325,334) #metric tonnes/ha
    
    hru_data_list[[length(hru_data_list) + 1]] <- list(
      scenario = scenario,
      lulc = as.character(lulc),
      hru = as.numeric(hru),
      sub = as.numeric(sub),
      YR = as.numeric(YR),
      area_km2 = as.numeric(area),
      precip_mm = as.numeric(precip),
      et_mm = as.numeric(et),
      sw_int_mm = as.numeric(sw_int),
      sw_end_mm = as.numeric(sw_end),
      gw_rchg_mm = as.numeric(gw_rchg),
      da_rchg_mm = as.numeric(da_rchg),
      surq_gen_mm = as.numeric(surq_gen),
      wyld_mm = as.numeric(wyld),
      syld_mtonha = as.numeric(syld)
    )
  }
  
  return(rbindlist(hru_data_list))
}

# Read both scenarios
hru_data <- rbindlist(lapply(bmp, read_hru))

# ---------------------------
# 1. Volumetric Water Output (YR == 22, tidy format + benefit row)
# ---------------------------
vars_to_keep <- c("surq_gen_mm","wyld_mm","et_mm",
                  "syld_mtonha")

# Define  titles with units
titles <- c("Surface Runoff (mm)",
            "Water Yield (mm)",
            "Evapotranspiration (mm)",
            "Sediment Yield (t/ha)")

# filter to YR = 22 and only keep needed columns
yr22_tidy <- hru_data[YR == 22,
                      c("scenario", vars_to_keep),
                      with = FALSE]

# Calculate Benefit row
baseline_vals <- yr22_tidy[scenario == "Baseline", ..vars_to_keep]
covercrop_vals <- yr22_tidy[scenario == "CoverCrop", ..vars_to_keep]
benefit_vals <- baseline_vals - covercrop_vals
benefit_row <- data.table(scenario = "Benefit", benefit_vals)

# Combine rows
yr22_final <- rbindlist(list(yr22_tidy, benefit_row), use.names = TRUE, fill = TRUE)

# Rename columns 
setnames(yr22_final,
         old = c("scenario", vars_to_keep),
         new = c("Scenario", titles))

# Identify numeric columns (all except Scenario)
num_cols <- setdiff(names(yr22_final), "Scenario")

# Round numeric columns to 1 decimal place
yr22_final[, (num_cols) := lapply(.SD, function(x) round(x, 1)), .SDcols = num_cols]

# Write to Excel
write.xlsx(yr22_final, file = file.path(path, "VolumetricWaterOutputs_YR22.xlsx"))

# ---------------------------
# 2. Time-series plots (YR 2001-2022)
# ---------------------------


# Filter years
plot_data <- hru_data[YR %in% 2001:2022]

vars_to_plot <- c("surq_gen_mm","wyld_mm","et_mm")

titles <- c("Surface Runoff","Water Yield",
            "Evapotransipration")

# Melt water balance variables (line plots)
plot_long <- melt(plot_data,
                  id.vars = c("scenario","YR"),
                  measure.vars = vars_to_plot,
                  variable.name = "variable",
                  value.name = "value")

# Extract precipitation from Baseline only (bar plot)
precip_data <- plot_data[scenario == "Baseline", .(YR, precip_mm)]
precip_data[, type := "Precipitation"]  # for legend

# Create plots with custom titles
plots <- lapply(seq_along(vars_to_plot), function(i) {
  
  var <- vars_to_plot[i]
  panel_title <- titles[i]
  
  # Water variable max
  max_val <- max(plot_long[variable == var]$value, na.rm = TRUE)
  
  p <- ggplot()  # start with empty plot
  
  # Add precipitation bars only for the first plot
  if(i == 1){
    max_precip <- max(precip_data$precip_mm, na.rm = TRUE)
    scale_factor <- max_val / max_precip
    
    p <- p +
      geom_col(
        data = precip_data,
        aes(x = YR, y = precip_mm * scale_factor, fill = type),
        alpha = 0.5,
        inherit.aes = FALSE
      ) +
      scale_y_continuous(
        name = paste0(titles[i], " (mm)"),   # left axis label with units
        sec.axis = sec_axis(~ . / scale_factor, name = "Precipitation (mm)")
      ) +
      scale_fill_manual(values = c("skyblue"))
  } else {
    # Only left y-axis with units for other plots
    p <- p + scale_y_continuous(name = paste0(titles[i], " (mm)"))
  }
  
  # Add water variable line on top
  p <- p +
    geom_line(
      data = plot_long[variable == var],
      aes(x = YR, y = value, color = scenario),
      linewidth = 1.2
    ) +
    scale_color_manual(values = c("black", "red")) +
    labs(title = panel_title, x = "Year", color = "", fill = "") +  # remove "Scenario" title
    theme_minimal() +
    theme(legend.position = "bottom")
  
  return(p)
})

# Arrange 3-panel plot (3 rows x 1 columns)
final_plot <- wrap_plots(plots, ncol = 1)

# Save PNG
ggsave(filename = file.path(path, "WaterBalance_Timeseries.png"),
       plot = final_plot, width = 8, height = 11, dpi = 300)