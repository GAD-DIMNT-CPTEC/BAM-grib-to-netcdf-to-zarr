#!/bin/bash
#SBATCH --job-name=ExpConvert
#SBATCH --output=/mnt/beegfs/carlos.bastarz/SMNA_v3.0.x_check/anls_compare/pos/convert_to_netcdf/logs/exp_%A_%a.out
#SBATCH --error=/mnt/beegfs/carlos.bastarz/SMNA_v3.0.x_check/anls_compare/pos/convert_to_netcdf/logs/exp_%A_%a.err
#SBATCH --time=02:00:00
#SBATCH --ntasks=32
#SBATCH --cpus-per-task=1
#SBATCH --mem=128G
#SBATCH --array=1-800
#SBATCH --partition=batch

set -euo pipefail

# ==============================
# CONFIG
# ==============================
bpath=/mnt/beegfs/carlos.bastarz/SMNA_v3.0.x_check/anls_compare/pos
expname=EXP2
yyyymm=202510

module load cdo-2.0.4-gcc-9.4.0-bjulvnd

OUTDIR=${bpath}/convert_to_netcdf/output/${expname}/analysis_nc
mkdir -p "$OUTDIR"

# ==============================
# FILE LIST
# ==============================
FILES=($(find ${bpath}/${expname}/dataout/TQ0299L064 -name "GPOSCPT${yyyymm}*P.*.TQ0299L064.grb" | sort))

INPUT=${FILES[$SLURM_ARRAY_TASK_ID-1]}
BASENAME=$(basename "$INPUT" .grb)

FIXED=${OUTDIR}/${BASENAME}-fixed.grb
OUTPUT=${OUTDIR}/${BASENAME}.nc
TMP=${OUTDIR}/${BASENAME}-tmp.nc
FINAL=${OUTDIR}/${BASENAME}-attrs.nc

echo "=============================="
echo "Processing: $INPUT"
echo "=============================="

# ==============================
# FIX GRID
# ==============================
cdo setgrid,${bpath}/convert_to_netcdf/grid_900x450.txt "$INPUT" "$FIXED"

# ==============================
# GRIB → NETCDF
# ==============================
cdo -f nc copy "$FIXED" "$OUTPUT"

# ==============================
# COMMON RENAME
# ==============================
CHNAME_COMMON="
-chname,var132,topo
-chname,var81,lsmk
-chname,var135,pslc
-chname,var33,uvel
-chname,var34,vvel
-chname,var39,omeg
-chname,var35,fcor
-chname,var36,potv
-chname,var7,zgeo
-chname,var2,psnm
-chname,var11,temp
-chname,var51,umes
-chname,var54,agpl
-chname,var187,tsfc
-chname,var161,tp2m
-chname,var199,q02m
-chname,var130,u10m
-chname,var131,v10m
-chname,var227,liqp
-chname,var233,icep
"

# ==============================
# EXTRA VARS (forecast only)
# ==============================
CHNAME_FCT="
-chname,var61,prec
-chname,var63,prcv
-chname,var122,cssf
-chname,var121,clsf
-chname,var207,olis
-chname,var211,oles
-chname,var114,role
-chname,var209,ocis
-chname,var212,oces
-chname,var214,roce
-chname,var166,o3mr
"

# ==============================
# ATTRIBUTES (COMMON)
# ==============================
ATTR_COMMON="
-setattribute,topo@standard_name=topography -setattribute,topo@units=m
-setattribute,lsmk@standard_name=land_sea_mask -setattribute,lsmk@units=1
-setattribute,pslc@standard_name=surface_pressure -setattribute,pslc@units=hPa
-setattribute,uvel@standard_name=zonal_wind -setattribute,uvel@units=m/s
-setattribute,vvel@standard_name=meridional_wind -setattribute,vvel@units=m/s
-setattribute,omeg@standard_name=omega -setattribute,omeg@units=Pa/s
-setattribute,fcor@standard_name=stream_function -setattribute,fcor@units=m2/s
-setattribute,potv@standard_name=velocity_potential -setattribute,potv@units=m2/s
-setattribute,zgeo@standard_name=geopotential_height -setattribute,zgeo@units=gpm
-setattribute,psnm@standard_name=pressure_reduced_to_msl -setattribute,psnm@units=hPa
-setattribute,temp@standard_name=air_temperature -setattribute,temp@units=K
-setattribute,umes@standard_name=specific_humidity -setattribute,umes@units=kg/kg
-setattribute,agpl@standard_name=precipitable_water -setattribute,agpl@units=kg/m2
-setattribute,tsfc@standard_name=surface_temperature -setattribute,tsfc@units=K
-setattribute,tp2m@standard_name=air_temperature -setattribute,tp2m@units=K
-setattribute,q02m@standard_name=specific_humidity -setattribute,q02m@units=kg/kg
-setattribute,u10m@standard_name=10m_u_component_of_wind -setattribute,u10m@units=m/s
-setattribute,v10m@standard_name=10m_v_component_of_wind -setattribute,v10m@units=m/s
-setattribute,liqp@standard_name=cloud_liquid_water_mixing_ratio -setattribute,liqp@units=kg/kg
-setattribute,icep@standard_name=cloud_ice_mixing_ratio -setattribute,icep@units=kg/kg
"

# ==============================
# ATTRIBUTES (FORECAST)
# ==============================
ATTR_FCT="
-setattribute,prec@standard_name=precipitation_flux -setattribute,prec@units=kg/m2/day
-setattribute,prcv@standard_name=convective_precipitation_flux -setattribute,prcv@units=kg/m2/day
-setattribute,cssf@standard_name=sensible_heat_flux -setattribute,cssf@units=W/m2
-setattribute,clsf@standard_name=latent_heat_flux -setattribute,clsf@units=W/m2
-setattribute,olis@standard_name=downwelling_longwave_flux_in_air -setattribute,olis@units=W/m2
-setattribute,oles@standard_name=upwelling_longwave_flux_in_air -setattribute,oles@units=W/m2
-setattribute,role@standard_name=toa_outgoing_longwave_flux -setattribute,role@units=W/m2
-setattribute,ocis@standard_name=downwelling_shortwave_flux_in_air -setattribute,ocis@units=W/m2
-setattribute,oces@standard_name=upwelling_shortwave_flux_in_air -setattribute,oces@units=W/m2
-setattribute,roce@standard_name=toa_outgoing_shortwave_flux -setattribute,roce@units=W/m2
-setattribute,o3mr@standard_name=mass_mixing_ratio_of_ozone_in_air -setattribute,o3mr@units=kg/kg
"

# ==============================
# TYPE DETECTION
# ==============================
if [[ "$INPUT" == *".fct."* ]]; then
    TYPE="fct"
else
    TYPE="analysis"
fi

echo "Type: $TYPE"

# ==============================
# PROCESS
# ==============================
if [[ "$TYPE" == "fct" ]]; then
    cdo $CHNAME_COMMON $CHNAME_FCT "$OUTPUT" "$TMP"
    cdo $ATTR_COMMON $ATTR_FCT -setattribute,global@experiment="$expname" "$TMP" "$FINAL"
else
    cdo $CHNAME_COMMON "$OUTPUT" "$TMP"
    cdo $ATTR_COMMON -setattribute,global@experiment="$expname" "$TMP" "$FINAL"
fi

# ==============================
# CLEANUP
# ==============================
rm -f "$FIXED" "$OUTPUT" "$TMP"

echo "Done: $FINAL"
