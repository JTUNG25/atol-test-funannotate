def lookup_predict_params(wildcards):
    return genome_config[wildcards.genome]


# container
bbmap = "docker://quay.io/biocontainers/bbmap:39.01--h92535d8_1"
funannotate = "docker://ghcr.io/tomharrop/container-funannotate:1.8.15_cv4"

# Funannotate data
db_path = "data/funannotate_db"
gm_key = "data/gm_key_64"

# config
header_length = 200
min_training_models = 20
genome_config = {
    "A_magna": {"busco_seed_species": "chicken", "busco_db": "passeriformes_odb10"},
    "E_pictum": {"busco_seed_species": "chicken", "busco_db": "passeriformes_odb10"},
    "R_gram": {
        "busco_seed_species": "botrytis_cinerea",
        "busco_db": "helotiales_odb10",
    },
    "X_john": {"busco_seed_species": "maize", "busco_db": "liliopsida_odb10"},
    "T_triandra": {"busco_seed_species": "maize", "busco_db": "poales_odb10"},
    "H_bino": {"busco_seed_species": "chicken", "busco_db": "sauropsida_odb10"},
    "P_vit": {"busco_seed_species": "chicken", "busco_db": "sauropsida_odb10"},
}


# this doesn't work with containall, writable-tmps and cleanenv.
rule target:
    input:
        expand(
            "results/{genome}/funannotate/predict_results/annot.gff3",
            genome=genome_config.keys(),
        ),


rule predict:
    input:
        fasta=("results/{genome}/reformat/genome.fa"),
        db=db_path,
        gm_key=gm_key,
    output:
        gff="results/{genome}/funannotate/predict_results/annot.gff3",
    params:
        predict_params=lookup_predict_params,
        fasta=lambda wildcards, input: Path(input.fasta).resolve(),
        db=lambda wildcards, input: Path(input.db).resolve(),
        wd=lambda wildcards, output: Path(output.gff).parent.parent.resolve(),
        header_length=header_length,
        min_training_models=min_training_models,
    log:
        "logs/predict_results/{genome}.log",
    threads: 32
    resources:
        runtime=int(24 * 60),
        mem_mb=int(64e3),
    container:
        funannotate
    shell:
        "export FUNANNOTATE_DB={params.db} ; "
        "cp {input.gm_key} ${{HOME}}/.gm_key ; "
        "funannotate predict "
        "--input {params.fasta} "
        "--out {params.wd} "
        "--species {wildcards.genome} "
        "--busco_seed_species {params.predict_params[busco_seed_species]} "
        "--busco_db {params.predict_params[busco_db]} "
        "--header_length {params.header_length} "
        "--database {params.db} "
        "--cpus {threads} "
        "--optimize_augustus "
        "--organism other "
        "--repeats2evm "
        "--max_intronlen 50000 "
        "--min_training_models {params.min_training_models} "
        "&> {log}"


rule reformat:
    input:
        "data/genomes/{genome}.fasta",
    output:
        temp("results/{genome}/reformat/genome.fa"),
    log:
        "logs/reformat/{genome}.log",
    threads: 1
    resources:
        runtime=10,
        mem_mb=int(4e3),
    container:
        bbmap
    shell:
        "reformat.sh in={input} out={output} 2>{log}"
