perl /opt/vep/src/ensembl-vep/INSTALL.pl -a p -g dbNSFP,CADD,G2P
vep --fork 5 --verbose --cache \\
--dir_cache ${WORKING_FOLDER} --refseq \\
--buffer_size 500 --use_transcript_ref --use_given_ref --force_overwrite \\
--fasta ${WORKING_FOLDER}/fasta/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz --everything --flag_pick \\
--custom ${WORKING_FOLDER}/custom/clinvar_20191118.vcf.gz,ClinVar,vcf,exact,0,ALLELEID,CLNSIG,GENEINFO,CLNREVSTAT,CLNDN,CLNHGVS \\
--plugin dbNSFP,${WORKING_FOLDER}/dbNSFP4.0c/dbNSFP4.0c.txt.gz,SIFT4G_pred,LRT_pred,MutationTaster_pred,MutationAssessor_pred,FATHMM_pred,PROVEAN_pred,MetaSVM_pred,MetaLR_pred,M-CAP_pred,PrimateAI_pred,DEOGEN2_pred,Aloft_pred,fathmm-MKL_coding_pred,fathmm-XF_coding_pred \\
-i ${sample_id}_strelka/results/variants/variants.vcf.gz  \\
-o ${sample_id}_vep98.txt --offline