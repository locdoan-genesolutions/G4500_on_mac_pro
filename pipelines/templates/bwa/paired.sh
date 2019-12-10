bwa mem -t 5 -M -R \\
'@RG\\tID:${sample_id}\\tLB:${sample_id}\\tPL:ILLUMINA\\tPM:MINISEQ\\tSM:${sample_id}' \\
${BWA_REPO_FOLDER}/${params.SPECIES} \\
${sample_id}_*_trim75.fastq.gz > ${sample_id}.sam