#!/bin/bash
#$ -cwd

CHR=$1
CHUNK_START=`printf "%.0f" $2`
CHUNK_END=`printf "%.0f" $3`
RS_NUMBER=$4

# directories
ROOT_DIR=./
REF_DIR=/media/WD/common/imputation/data/
DATA_DIR=${ROOT_DIR}data_files/
RESULTS_DIR=${ROOT_DIR}results/
HAP_SAMP_DIR=${ROOT_DIR}sampled_haps/

# executable
IMPUTE2_EXEC=impute2

# parameters
K=80
ITER=30
BURNIN=10
NE=11500

# reference data files
GENMAP_FILE=${REF_DIR}ALL_1000G_phase1integrated_v3_impute/genetic_map_chr${CHR}_combined_b37.txt

# GWAS data files
GWAS_GTYPE_FILE=${DATA_DIR}koa-chr${CHR}.gen

# main output file
OUTPUT_FILE=${RESULTS_DIR}gwas_data-${RS_NUMBER}.phasing.impute2

## phase GWAS genotypes
impute2 \
    -m $GENMAP_FILE \
    -g $GWAS_GTYPE_FILE \
    -phase \
    -include_buffer_in_output \
    -stage_one \
    -hap_samp_dir $HAP_SAMP_DIR \
    -k $K \
    -iter $ITER \
    -burnin $BURNIN \
    -Ne $NE \
    -int $CHUNK_START $CHUNK_END \
    -o $OUTPUT_FILE
