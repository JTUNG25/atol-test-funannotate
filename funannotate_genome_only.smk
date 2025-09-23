#!/usr/bin/env python3

from pathlib import Path
import tempfile

########
# NOTE #
########

# The funannotate container doesn't work with the usual --containall --cleanenv
# --writable-tmpfs arguments.

###########
# GLOBALS #
###########


# fa_snakefile = "../modules/funannotate/Snakefile"
fa_snakefile = github(
    "tomharrop/smk-modules",
    path="modules/funannotate/Snakefile",
    tag="0.0.40",
)

# from https://usegalaxy.org.au/api/datasets/a6e389a98c2d1678c28e1f5543997b40/display?to_ext=fasta
genome = Path("test-data", "funannotate", "AcanthornisMagna408025.fa.gz")
db_path = Path("test-data", "funannotate", "db")


# this is the path to the included adaptors file in bbmap
bbmap_adaptors = Path(
    "/usr", "local", "opt", "bbmap-39.01-1", "resources", "adapters.fa"
)

outdir = Path(
    "test-output",
    "funannotate_genome_only",
)
logdir = Path(outdir, "logs")
# avoid rerunning steps
run_tmpdir = Path(outdir, "tmp")

################################################################################
# Example configuration for the funannotate module
################################################################################

# Set interproscan_container to False to disable interproscan. If you don't
# provide gm_key, the module will try to use one from the container. This will
# fail if that key has expired.
#
# Optional config keys:
#   - protein_evidence
#   - transctipt_evidence
#   - rnaseq
#   - min_training_models (default 200, set lower for test data)
#   - header_length (default 16)
#
# Configuring busco:
#   - run funannotate species to find a list of species for busco_seed_species
#   - run funannotate database --show-buscos to find a list of species you can
#     use for busco_db
#   - you can add busco lineages to the db folder to make them available

fa_config = {
    "db_path": db_path,
    "gm_key": Path("test-data", "funannotate", "gm_key"),
    "header_length": 200,
    "min_training_models": 20,
    "outdir": results/funannotate/,
    "query_genome": genome,
    "run_tmpdir": run_tmpdir,
    "species_name": "AcanthornisMagna",
    "busco_seed_species": "chicken",
    "busco_db": "eukaryota_odb10",
}

################################################################################

#########
# RULES #
#########
input_genomes = [
    "A_magna",
    "E_pictum",
    "R_gram",
    "X_john",
    "T_triandra",
    "H_bino",
    "P_vit",
]
busco_seed_species = [
    "chicken",
    "chicken",
    "botrytis_cinerea",
    "maize",
    "maize",
    "chicken",
    "chicken",
]
input_busco_db = [
    "passeriformes",
    "passeriformes",
    "helotiales",
    "liliopsida",
    "poales",
    "sauropsida ",
    "sauropsida ",
]

rule target:
    input:
        expand("results/funannotate/{genome}.gtf", genome=input_genomes),


rule funannotate_genome_only:
    input:
        fasta="data/{genome}.fasta",
        model="",
        expand("{busco_seed_species}", busco_seed_species=input_busco_seed_species),
        expand("{busco_db}", busco_db=input_busco_db),

    output:
        gtf="results/funannotate/{genome}.gtf",
  
    log:
        "logs/funannotate/{genome}.log",

module funannotate:
    snakefile:
        fa_snakefile
    config:
        fa_config


use rule * from funannotate as funannotate_*


