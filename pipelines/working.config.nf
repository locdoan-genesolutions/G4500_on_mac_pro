params {

// -----------------------------------
// Standard Parameters
// -----------------------------------
    INDIR  = "/Volumes/GSSD01/repo/testing_strelka/G4500_raw"
    OUTDIR = "/Volumes/GSSD01/output"

    reads = "${params.INDIR}/*_R{1,2}_*.fastq.gz"
    
    REPO_LOCATION = "/Volumes/GSSD01/repo/resources"
    BWA_REPO = "$REPO_LOCATION/bwa"
    GENOME_REPO = '$REPO_LOCATION/genomes'
    TARGET_REPO = "$REPO_LOCATION/target_genes"
    SPECIES = "hg38_selected.fa"
    GENE_PANEL = "sorted_G4500.targets.hg38.bed.gz"

// -----------------------------------
// Process Skipping
// -----------------------------------

    //bams.use_existing = false
    //bams.path = "${params.INDIR}/ggal_bams.csv"

// Keep Temporary Files

    //fastqs.save = false
    //bams.save  = true

    //skip.pre_qc      = false
    //skip.counting    = false
    //skip.rseqc       = false
    //skip.multiqc     = false
    //skip.eset        = true
}

process {
    withName:fastqc {
        container = 'quay.io/biocontainers/fastqc:0.11.8--2'
        cpus = 1
        memory = 1.GB
    }
    withName:trim {
        container = 'quay.io/biocontainers/bbmap:38.73--h516909a_0'
        cpus = 2
        memory = 1.GB
    }
    withName:align_bwa {
        container = 'quay.io/biocontainers/bwa:0.7.8--hed695b0_5'
        cpus = 5
        memory = 7.GB
    }
    withName:picard_SortSam {
        container = 'quay.io/biocontainers/picard:2.21.4--0'
        cpus = 1
        memory = 2.GB
    }
    withName:picard_MarkDuplicates {
        container = 'quay.io/biocontainers/picard:2.21.4--0'
        cpus = 2
        memory = 3.GB
    }
    withName:strelka {
        container = 'quay.io/biocontainers/strelka:2.9.10--0'
        cpus = 4
        memory = 20.GB
    }
    withName:vep {
        container = 'ensemblorg/ensembl-vep:latest'
        cpus = 5 
        memory = 30.GB
    }
    withName:vep_filter_using_R {
        container = 'full_packages:Dockerfile'
        cpus = 2
        memory = 2.GB
    }
}
docker {
    enabled = true
}