bbduk.sh \\
-Xmx1g \\
forcetrimright=75 \\
in1=${reads[0]} \\
in2=${reads[1]} \\
out1=${sample_id}_1_trim75.fastq.gz out2=${sample_id}_2_trim75.fastq.gz