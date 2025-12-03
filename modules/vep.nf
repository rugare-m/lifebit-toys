process RUN_VEP {
    tag "${vcf_file.simpleName}"

    input:
    path vcf_file

    output:
    path "${vcf_file.simpleName}.annotated.txt"

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
        --fork 12 
    """
}


process MINIMAL_RUN_VEP {
    tag "${vcf_file.simpleName}"

    input:
    path vcf_file

    output:
    path "${vcf_file.simpleName}.annotated.txt"

    script:
    """
    vep \
        -i "${vcf_file}" \
        -o "${vcf_file.simpleName}.annotated.txt" \
        --assembly GRCh38 \
        --offline \
        --cache \
        --dir_cache /.vep \
        --force_overwrite \
        --af_gnomad \
        --symbol --protein --biotype \
        --max_af \
        --fork "${params.hp}"
    """
}