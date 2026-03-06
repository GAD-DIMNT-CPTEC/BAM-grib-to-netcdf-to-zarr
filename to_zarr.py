import os
import xarray as xr
import glob
import numpy as np
from dask.distributed import Client
import dask


def main():

    exp_id = os.environ["EXP_ID"]

    # ---------------- DASK ----------------

    dask.config.set({
        "distributed.worker.memory.target": 0.6,
        "distributed.worker.memory.spill": 0.7,
        "distributed.worker.memory.pause": 0.8,
        "distributed.worker.memory.terminate": 0.95,
    })

    client = Client(
        n_workers=32,
        threads_per_worker=1,
        memory_limit="3GB",
        dashboard_address=None
    )

    print(client)

    # ---------------- PATHS ----------------

    DATA_PATH = f"/mnt/beegfs/carlos.bastarz/SMNA_v3.0.x_check/anls_compare/pos/convert_to_netcdf/output/EXP{exp_id}/analysis_nc/GPOSCPT*P.*.TQ0299L064-attrs.nc"

    OUTPUT_PATH = f"/mnt/beegfs/carlos.bastarz/SMNA_v3.0.x_check/anls_compare/pos/convert_to_netcdf/output/zarr/EXP{exp_id}.zarr"

    files_all = sorted(glob.glob(DATA_PATH))
    files = [f for f in files_all if "icn" not in f]

    print(f"{len(files)} arquivos encontrados")

    # ---------------- OPEN ----------------

    ds = xr.open_mfdataset(
        files,
        combine="nested",
        concat_dim="time",
        engine="netcdf4",
        parallel=True,
        chunks={"time": 8}
    )

    # ---------------- ORGANIZAÇÃO ----------------

    n = len(ds.time)
    cycle = np.arange(n) // 4
    lead  = np.arange(n) % 4

    ds = ds.assign_coords(
        cycle=("time", cycle),
        lead=("time", lead)
    )

    ds = ds.set_index(time=["cycle", "lead"]).unstack("time")

    # ---------------- CHUNK FINAL ----------------

    ds = ds.chunk({
        "cycle": 16,
        "lead": 4,
        "lat": 256,
        "lon": 256
    })

    print("Iniciando escrita em Zarr...")

    ds.to_zarr(
        OUTPUT_PATH,
        mode="w",
        consolidated=True
    )

    print("Finalizado com sucesso.")


if __name__ == "__main__":
    main()
