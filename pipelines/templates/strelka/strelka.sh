mkdir ${sample_id}_strelka
configureStrelkaGermlineWorkflow.py \\
--targeted --callRegions ${TARGET_REPO_FOLDER}/${params.GENE_PANEL}  \\
--bam ${sample_id}_dedup.bam \\
--referenceFasta ${BWA_REPO_FOLDER}/${params.SPECIES} \\
--runDir ${sample_id}_strelka; ${sample_id}_strelka/runWorkflow.py --mode local --jobs 4