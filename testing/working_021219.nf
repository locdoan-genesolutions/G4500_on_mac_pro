/*
The pipeline can start from fastq read files or
start from alignment .bam files
*/

if (!params.bams.use_existing) {
    // Starting from .fastq files
    Channel
        .fromFilePairs( params.reads )
        .ifEmpty { error "Cannot find any reads matching: ${params.reads}"  }
        .into {reads_preqc; reads_trimming}
}

// -----------------------------------------------------------------------------
//              PRE-PIPELINE QC
// -----------------------------------------------------------------------------
if (!params.bams.use_existing) {
    if (!params.skip.pre_qc) {
        process pre_fastqc {
            cache "deep"; tag "FASTQC on $sample_id"
            publishDir "${params.OUTDIR}/pre_fastqc", mode: 'copy'

            input:
                tuple sample_id, file(reads) from reads_preqc

            output:
                tuple sample_id, '*_fastqc.{zip,html}' into preqc_results

            script:
                template 'fastqc/paired.sh'
                
        }
    }
}

// -----------------------------------------------------------------------------
//                BEGIN PIPELINE
// -----------------------------------------------------------------------------
if (!params.bams.use_existing) {
/*
** Trimming
*/
    process bbmap_trimming {
        cache "deep"; tag "BBduk on $sample_id"
        publishDir "${params.OUTDIR}/${sample_id}/bbmap_trimming", mode: 'copy'
        // saveAs: {filename ->
        //       if (filename.indexOf("trimming_report.txt") > 0) filename
        //       else if (filename.indexOf("fastqc.html") > 0) filename
        //       else if (filename.indexOf("fastqc.zip") > 0) filename
        //       else if (params.fastqs.save) filename
        //       else null}

        input:
            tuple sample_id, file(reads) from reads_trimming

        output:
            tuple sample_id, '*fastq.gz' into trimmed_reads
            tuple sample_id, '*' into trim_galore_results

    script:
          template 'bbmap/paired.sh'
    } 
}
// -----------------------------------------------------------------------------

workflow.onComplete {

    println ( workflow.success ? """
        Pipeline execution summary
        ---------------------------
        Completed at: ${workflow.complete}
        Duration    : ${workflow.duration}
        Success     : ${workflow.success}
        workDir     : ${workflow.workDir}
        exit status : ${workflow.exitStatus}
        """ : """
        Failed: ${workflow.errorReport}
        exit status : ${workflow.exitStatus}
        """
    )
}