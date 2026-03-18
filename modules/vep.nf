process VEP {
    publishDir "results/vep", mode: 'move' , pattern: "*.annotated.txt"

    tag "${vcf_file.simpleName}"

    cpus 64
    memory 64.GB

    input:
    path vcf_file
    path fasta
    path fasta_index

    path clinvar
    path clinvar_tbi

    path cadd_snv
    path cadd_snv_tbi

    path cadd_indels
    path cadd_indels_tbi

    path spliceai_snv
    path spliceai_snv_tbi

    path spliceai_indels
    path spliceai_indels_tbi

    path revel
    path revel_tbi
    
    path alpha
    path alpha_tbi

    path plugin_files

    output:
    path "${vcf_file.simpleName}.annotated.txt"

    script:
    """
    mkdir -p plugins
    cp ${plugin_files} plugins/

    ls -l plugins

    vep \
        --dir_plugins plugins \
        -i "${vcf_file}" \
        -o "${vcf_file.simpleName}.annotated.txt" \
        --assembly GRCh38 \
        --offline \
        --cache \
        --dir_cache /.vep \
        --fasta "${fasta}" \
        --force_overwrite \
        --everything \
        --hgvsg \
        --custom "${clinvar},ClinVar,vcf,exact,0,CLNSIG,CLNREVSTAT" \
        --plugin CADD,"${cadd_snv}","${cadd_indels}" \
        --plugin SpliceAI,snv="${spliceai_snv}",indel="${spliceai_indels}" \
        --plugin REVEL,"${revel}" \
        --plugin SpliceRegion \
        --plugin TSSDistance \
        --plugin AlphaMissense,file="${alpha}",cols=all \
        --fork 12 \
        --safe
    """
}




process RUN_VEP {
    tag "${vcf_file.simpleName}"

    input:
    path vcf_file

    output:
    path "${vcf_file.simpleName}.annotated.txt"

    cpus 50
    memory 50.GB

    script:
    """
    vep \
        -i "${vcf_file}" \
        -o "${vcf_file.simpleName}.annotated.txt" \
        --assembly GRCh38 \
        --offline \
        --cache \
        --dir_cache /.vep \
        --fasta "${params.fasta}" \
        --force_overwrite \
        --af_gnomad \
        --max_af \
        --hgvs \
        --protein --biotype --symbol \
        --custom "${params.clinvar},ClinVar,vcf,exact,0,CLNSIG,CLNREVSTAT" \
        --plugin CADD,"${params.cadd_snv}","${params.cadd_indels}" \
        --plugin SpliceAI,snv="${params.spliceai_snv}",indel="${params.spliceai_indels}" \
        --plugin REVEL,"${params.revel}" \
        --plugin SpliceVault,file="${params.splice_vault}" \
        --plugin SpliceRegion \
        --plugin TSSDistance \
        --plugin dbscSNV,"${params.dbscSNV}" \
        --plugin AlphaMissense,file="${params.alpha}",cols=all \
        --fork 4 
    """
}


process MINIMAL_RUN_VEP {
    tag "${vcf_file.simpleName}"

    input:
    path vcf_file

    output:
    path "${vcf_file.simpleName}.annotated.txt"

    cpus 10
    memory 10.GB

    script:
    """
    vep -i "${vcf_file}" -o "${vcf_file.simpleName}.annotated.txt" --assembly GRCh38 --offline --cache --dir_cache /.vep --force_overwrite --fork "${params.hp}" --safe
    """
}
