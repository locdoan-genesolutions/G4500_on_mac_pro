picard MarkDuplicates \\
INPUT=${sample_id}_sorted.bam \\
OUTPUT=${sample_id}_dedup.bam METRICS_FILE=${sample_id}_dedup_metrics.txt \\
use_jdk_deflater=true use_jdk_inflater=true\\
&& picard BuildBamIndex INPUT=${sample_id}_dedup.bam