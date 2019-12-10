/*
 * Defines some parameters in order to specify the refence genomes
 */

BWA_REPO_FOLDER = file("${params.BWA_REPO}")
TARGET_REPO_FOLDER = file("${params.TARGET_REPO}")

WORKING_FOLDER = file("/Volumes/GSSD01/vep_data")

R_SCRIPT = file("/Volumes/GSSD01/vep_data/r_script/vep_filter_EASAF.R")

println """\
         G S - G 4 5 0 0  P I P E L I N E    
         ===================================
         reads directory        : ${params.INDIR}
         output directory       : ${params.OUTDIR}
         """
         .stripIndent()

Channel
    .fromFilePairs( params.reads )
    .ifEmpty { error "Cannot find any reads matching: ${params.reads}"  }
    .into {reads_preqc; reads_trimming}


// -----------------------------------------------------------------------------
//              PRE-PIPELINE QC
// -----------------------------------------------------------------------------

process fastqc {
    cache "deep"; tag "FASTQC on $sample_id"
    publishDir "${params.OUTDIR}/${sample_id}/fastqc", mode: 'copy'

    input:
        tuple sample_id, file(reads) from reads_preqc

    output:
        tuple sample_id, '*_fastqc.{zip,html}' into preqc_results

    script:
        template 'fastqc/paired.sh'
}

// -----------------------------------------------------------------------------
//                BEGIN PIPELINE
// -----------------------------------------------------------------------------

/*
** Trimming
*/
process trim {
    cache "deep"; tag "BBduk on $sample_id"
    publishDir "${params.OUTDIR}/${sample_id}/trim75", mode: 'copy'

    input:
        tuple sample_id, file(reads) from reads_trimming

    output:
        tuple sample_id, "${sample_id}_*_trim75.fastq.gz" into trimmed_reads

    script:
          template 'bbmap/paired.sh'
} 

/*
** Mapping
*/

process align_bwa {

    storeDir "/Volumes/loc/storeDir"

    cache "deep"; tag "bwa on $sample_id"
    publishDir "${params.OUTDIR}/${sample_id}/align_bwa", mode: "copy"

    input:
        tuple sample_id, "${sample_id}_*_trim75.fastq.gz" from trimmed_reads
        file BWA_REPO_FOLDER

    output:
        tuple sample_id, "${sample_id}.sam" into mapping_results

    script:
        template 'bwa/paired.sh'
}

/*
** Sorting
*/

process picard_SortSam {
    cache "deep"; tag "picard SortSam on $sample_id"
    publishDir "${params.OUTDIR}/${sample_id}/picard_SortSam", mode: "copy"

    input:
        tuple sample_id, "${sample_id}.sam" from mapping_results

    output:
        tuple sample_id, "${sample_id}_sorted.bam" into picard_SortSam_ch  

    script:
        template 'picard/picard_SortSam.sh'
}

/*
** Duplicating
*/

process picard_MarkDuplicates {
    cache "deep"; tag "picard MarkDuplicates on $sample_id"
    publishDir "${params.OUTDIR}/${sample_id}/picard_MarkDuplicates", mode: "copy"

    input:
        tuple sample_id, "${sample_id}_sorted.bam" from picard_SortSam_ch

    output:
        tuple sample_id, "${sample_id}_dedup_metrics.txt", "${sample_id}_dedup.bam", "${sample_id}_dedup.bai" into picard_MarkDuplicates_ch

    script:
        template 'picard/picard_MarkDuplicates.sh'
}

/*
** Calling germline small variants
*/

process strelka {
    cache "deep"; tag "Calling germline small variants on $sample_id"
    publishDir "${params.OUTDIR}/${sample_id}/strelka", mode: "copy"
      
    input:
        tuple sample_id, "${sample_id}_dedup_metrics.txt", "${sample_id}_dedup.bam", "${sample_id}_dedup.bai" from picard_MarkDuplicates_ch
        file BWA_REPO_FOLDER
        file TARGET_REPO_FOLDER

    output:
        tuple sample_id, file("${sample_id}_strelka") into strelka_ch

    script:
        template 'strelka/strelka.sh'
}

/*
** Determining the effect of variants
*/

process vep {
    cache "deep"; tag "Determining the effect of the variants of $sample_id"
    publishDir "${params.OUTDIR}/${sample_id}/vep", mode: "copy"

    input:
        tuple sample_id, file("${sample_id}_strelka") from strelka_ch
        file WORKING_FOLDER

    output:
        tuple sample_id, "${sample_id}_vep98.txt" into vep_ch

    script:
        template 'vep/syntax.sh'
}

process vep_filter_using_R {
    cache "deep"; tag "Filtering by using R on $sample_id"
    publishDir "${params.OUTDIR}/${sample_id}/vep_filter_using_R", mode: "copy"

    input:
        tuple sample_id, "${sample_id}_vep98.txt" from vep_ch
        file R_SCRIPT

    output:
        file("${sample_id}_filtered_vep98.tsv") into r_ch

    script:
        template 'vep_filter_using_R/syntax.sh'
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