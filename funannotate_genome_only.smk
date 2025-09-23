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
dmnd_db = Path("test-data", "funannotate", "eggnog", "eggnog_proteins.dmnd")
eggnog_db = Path("test-data", "funannotate", "eggnog", "eggnog.db")

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
    "dmnd_db": dmnd_db,
    "eggnog_db": eggnog_db,
    "gm_key": Path("test-data", "funannotate", "gm_key"),
    "header_length": 200,
    "interproscan_container": False,
    "interproscan_container": "interproscan_5.65-97.0_cv3.sif",
    "min_training_models": 20,
    "outdir": outdir,
    "query_genome": genome,
    "run_tmpdir": run_tmpdir,
    "species_name": "AcanthornisMagna408025",
    "busco_seed_species": "chicken",
    "busco_db": "eukaryota_odb10",
}

################################################################################

#########
# RULES #
#########


module funannotate:
    snakefile:
        fa_snakefile
    config:
        fa_config


use rule * from funannotate as funannotate_*


