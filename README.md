# BAM-grib-to-netcdf-to-zarr

Scripts para converter as previsões pós-processadas do BAM de Grib para NetCDF (e depois para Zarr).

## Uso

### Pós-processamento em Grib

Utilize o script `run_qsub_pos_cycle.sh` para pós-processar as previsões espectrais do BAM para o formato Grib. Este script cria o script de submissão `qsub_pos_cycle.qsb` e o namelist `POSTIN-GRIB` para o(s) experimento(s) escolhido(s) - modifique o script conforme necessário.

**Notas:** 

  1. O script de submissão gerado utiliza um array para pós-processar várias datas de referência ao mesmo tempo. Por exemplo, se o modelo foi executado para as datas de referência entre 2025090100 a 2025110100 a cada dia, o script de submissão criará um array de submissões para os n dias dentro do período (vide diretiva `#SBATCH --array=1-${ncycles}` no script, onde `ncycles é o número de dias`);
    Uso:
        ```bash
        ./run_qsub_pos_cycle.sh
        ```
  2. O arquivo `grid_900x450.txt` é necessário para a conversão.
  3. Caso seja necessário, utilize o script `fix_ctl_files.sh` para consertar eventuais falhas na criação dos arquivos `.ctl` e `.idx`.
    Uso:
        ```bash
        ./fix_ctl_files.sh
        ```

### Pós-processamento em NetCDF

Utilize o script `run_convert_to_netcdf.sh` para converter os arquivos Grib do BAM para o formato NetCDF. Para isto, o script utiliza o programa `cdo` e ajusta os nomes das variáveis e unidades no arquivo NetCDF criado.

**Nota:**

  * O script `run_convert_to_netcdf.sh` cria um array para converter todos os arquivos Grib encontrados para NetCDF, o valor 800 pode ser alterado, mas caso existam menos de 800 arquivos a serem processados, o job será concluído ao final do processamento do último arquivo.
    Uso:
        ```bash
        sbatch run_convert_to_netcdf.sh
        ```

### Pós-processamento em Zarr

Utilize os script `to_zarr.sbatch` e `to_zarr.py` para converter as previsões de NetCDF para Zarr.

Uso:
```bash
sbatch to_zarr.sbatch
```

**Nota:**

* O script `to_zarr.py` é utilizado pelo script de submissão `to_zarr.sbatch`. 
