#!/bin/bash -x
#SBATCH --job-name=ExpConvert
#SBATCH --output=/mnt/beegfs/carlos.bastarz/SMNA_v3.0.x_check/anls_compare/pos/convert_to_netcdf/logs/exp_%A_%a.out
#SBATCH --error=/mnt/beegfs/carlos.bastarz/SMNA_v3.0.x_check/anls_compare/pos/convert_to_netcdf/logs/exp_%A_%a.err
#SBATCH --time=02:00:00
#SBATCH --ntasks=32
#SBATCH --cpus-per-task=1
#SBATCH --mem=128G
#SBATCH --array=1-800
#SBATCH --partition=PESQ1

bpath=/mnt/beegfs/carlos.bastarz/SMNA_v3.0.x_check/anls_compare/pos/
expname=EXP6

module load cdo-2.0.4-gcc-9.4.0-bjulvnd

yyyymm=202511

#FILES=($(find ${bpath}/${expname}/dataout/TQ0299L064 -name *icn*.grb | sort))
FILES=($(find ${bpath}/${expname}/dataout/TQ0299L064 -name GPOSCPT${yyyymm}*P.*.TQ0299L064.grb | sort))

INPUT=${FILES[$SLURM_ARRAY_TASK_ID-1]}
BASENAME=$(basename $INPUT .grb)
OUTPUT=${bpath}/convert_to_netcdf/output/${expname}/${BASENAME}.nc
OUTPUT2=${bpath}/convert_to_netcdf/output/${expname}/${BASENAME}-attrs.nc

type=$(echo $INPUT | awk -F "." '{print $5}')

mkdir -p ${bpath}/convert_to_netcdf/output/${expname}/analysis_nc

# Conserta o grib do BAM 
cdo setgrid,/mnt/beegfs/carlos.bastarz/SMNA_v3.0.x_check/anls_compare/pos/convert_to_netcdf/grid_900x450.txt ${INPUT} ${bpath}/convert_to_netcdf/output/${expname}/${BASENAME}-fixed.grb

# Converte para NetCDF
cdo -f nc copy ${bpath}/convert_to_netcdf/output/${expname}/${BASENAME}-fixed.grb ${OUTPUT}

# Conserta os nomes das variáveis no arquivo NetCDF

if [ "$type" == icn -o "$type" == inz ]
then        

  cdo \
    -chname,var132,topo \
    -chname,var81,lsmk \
    -chname,var135,pslc \
    -chname,var33,uvel \
    -chname,var34,vvel \
    -chname,var39,omeg \
    -chname,var35,fcor \
    -chname,var36,potv \
    -chname,var7,zgeo \
    -chname,var2,psnm \
    -chname,var11,temp \
    -chname,var51,umes \
    -chname,var54,agpl \
    -chname,var187,tsfc \
    -chname,var161,tp2m \
    -chname,var199,q02m \
    -chname,var130,u10m \
    -chname,var131,v10m \
    -chname,var227,liqp \
    -chname,var233,icep \
    -setattribute,topo@standard_name="topography" \
    -setattribute,lsmk@standard_name="land_sea_mask" \
    -setattribute,pslc@standard_name="surface_pressure" \
    -setattribute,uvel@standard_name="zonal_wind" \
    -setattribute,vvel@standard_name="meridional_wind" \
    -setattribute,omeg@standard_name="omega" \
    -setattribute,fcor@standard_name="stream_function" \
    -setattribute,potv@standard_name="velocity_potential" \
    -setattribute,zgeo@standard_name="geopotential_height" \
    -setattribute,psnm@standard_name="pressure_reduced_to_msl" \
    -setattribute,temp@standard_name="absolute_temperature" \
    -setattribute,umes@standard_name="specific_humidity" \
    -setattribute,agpl@standard_name="inst_precipitable_water" \
    -setattribute,tsfc@standard_name="surface_temperature" \
    -setattribute,tp2m@standard_name="temperature_at_2_m_from_surface" \
    -setattribute,q02m@standard_name="specific_humidity_at_2_m_from_surface" \
    -setattribute,u10m@standard_name="10_metre_u_wind_component" \
    -setattribute,v10m@standard_name="10_metre_v_wind_component" \
    -setattribute,liqp@standard_name="liquid_mixing_ratio" \
    -setattribute,icep@standard_name="ice_mixing_ratio" \
    -setattribute,topo@units="m" \
    -setattribute,lsmk@units="0,1" \
    -setattribute,pslc@units="hPa" \
    -setattribute,uvel@units="m/s" \
    -setattribute,vvel@units="m/s" \
    -setattribute,omeg@units="Pa/s-1" \
    -setattribute,fcor@units="m2/s" \
    -setattribute,potv@units="m2/s" \
    -setattribute,zgeo@units="gpm" \
    -setattribute,psnm@units="hPa" \
    -setattribute,temp@units="K" \
    -setattribute,umes@units="kg/kg" \
    -setattribute,agpl@units="kg/m2" \
    -setattribute,tsfc@units="K" \
    -setattribute,tp2m@units="K" \
    -setattribute,q02m@units="kg/kg" \
    -setattribute,u10m@units="m/s" \
    -setattribute,v10m@units="m/s" \
    -setattribute,liqp@units="kg/kg" \
    -setattribute,icep@units="kg/kg" \
    -setattribute,global@experiment="$expname" \
    "$OUTPUT" "$OUTPUT2"

elif [ "$type" == fct ]
then        

  cdo \
    -chname,var132,topo \
    -chname,var81,lsmk \
    -chname,var135,pslc \
    -chname,var33,uvel \
    -chname,var34,vvel \
    -chname,var39,omeg \
    -chname,var35,fcor \
    -chname,var36,potv \
    -chname,var7,zgeo \
    -chname,var2,psnm \
    -chname,var11,temp \
    -chname,var51,umes \
    -chname,var54,agpl \
    -chname,var187,tsfc \
    -chname,var161,tp2m \
    -chname,var199,q02m \
    -chname,var130,u10m \
    -chname,var131,v10m \
    -chname,var227,liqp \
    -chname,var233,icep \
    -chname,var61,prec \
    -chname,var63,prcv \
    -chname,var122,cssf \
    -chname,var121,clsf \
    -chname,var207,olis \
    -chname,var211,oles \
    -chname,var114,role \
    -chname,var209,ocis \
    -chname,var212,oces \
    -chname,var214,roce \
    -chname,var166,o3mr \
    -setattribute,topo@standard_name="topography" \
    -setattribute,lsmk@standard_name="land_sea_mask" \
    -setattribute,pslc@standard_name="surface_pressure" \
    -setattribute,uvel@standard_name="zonal_wind" \
    -setattribute,vvel@standard_name="meridional_wind" \
    -setattribute,omeg@standard_name="omega" \
    -setattribute,fcor@standard_name="stream_function" \
    -setattribute,potv@standard_name="velocity_potential" \
    -setattribute,zgeo@standard_name="geopotential_height" \
    -setattribute,psnm@standard_name="pressure_reduced_to_msl" \
    -setattribute,temp@standard_name="absolute_temperature" \
    -setattribute,umes@standard_name="specific_humidity" \
    -setattribute,agpl@standard_name="inst_precipitable_water" \
    -setattribute,tsfc@standard_name="surface_temperature" \
    -setattribute,tp2m@standard_name="temperature_at_2_m_from_surface" \
    -setattribute,q02m@standard_name="specific_humidity_at_2_m_from_surface" \
    -setattribute,u10m@standard_name="10_metre_u_wind_component" \
    -setattribute,v10m@standard_name="10_metre_v_wind_component" \
    -setattribute,liqp@standard_name="liquid_mixing_ratio" \
    -setattribute,icep@standard_name="ice_mixing_ratio" \
    -setattribute,prec@standard_name="total_precipitation" \
    -setattribute,prcv@standard_name="convective_precipitation" \
    -setattribute,cssf@standard_name="sensible_heat_flux_from_surface" \
    -setattribute,clsf@standard_name="latent_heat_flux_from_surface" \
    -setattribute,olis@standard_name="downward_long_wave_at_bottom" \
    -setattribute,oles@standard_name="upward_long_wave_at_bottom" \
    -setattribute,role@standard_name="outgoing_long_wave_at_top" \
    -setattribute,ocis@standard_name="downward_short_wave_at_ground" \
    -setattribute,oces@standard_name="upward_short_wave_at_ground" \
    -setattribute,roce@standard_name="upward_short_wave_at_top" \
    -setattribute,o3mr@standard_name="ozone_mixing_ratio" \
    -setattribute,topo@units="m" \
    -setattribute,lsmk@units="0,1" \
    -setattribute,pslc@units="hPa" \
    -setattribute,uvel@units="m/s" \
    -setattribute,vvel@units="m/s" \
    -setattribute,omeg@units="Pa/s-1" \
    -setattribute,fcor@units="m2/s" \
    -setattribute,potv@units="m2/s" \
    -setattribute,zgeo@units="gpm" \
    -setattribute,psnm@units="hPa" \
    -setattribute,temp@units="K" \
    -setattribute,umes@units="kg/kg" \
    -setattribute,agpl@units="kg/m2" \
    -setattribute,tsfc@units="K" \
    -setattribute,tp2m@units="K" \
    -setattribute,q02m@units="kg/kg" \
    -setattribute,u10m@units="m/s" \
    -setattribute,v10m@units="m/s" \
    -setattribute,liqp@units="kg/kg" \
    -setattribute,icep@units="kg/kg" \
    -setattribute,prec@units="kg/m2/day" \
    -setattribute,prcv@units="kg/m2/day" \
    -setattribute,cssf@units="W/m2" \
    -setattribute,clsf@units="W/m2" \
    -setattribute,olis@units="W/m2" \
    -setattribute,oles@units="W/m2" \
    -setattribute,role@units="W/m2" \
    -setattribute,ocis@units="W/m2" \
    -setattribute,oces@units="W/m2" \
    -setattribute,roce@units="W/m2" \
    -setattribute,o3mr@units="kg/kg" \
    -setattribute,global@experiment="$expname" \
    "$OUTPUT" "$OUTPUT2"

fi

rm ${bpath}/convert_to_netcdf/output/${expname}/${BASENAME}-fixed.grb
rm ${bpath}/convert_to_netcdf/output/${expname}/${OUTPUT}

exit 0
