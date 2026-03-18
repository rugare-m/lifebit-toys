process VEP {
    publishDir "results/vep", mode: 'move', pattern: "*.annotated.txt"

    tag "${vcf_file.simpleName}"

    cpus 16
    memory 92.GB

    input:
    path vcf_file

    tuple path(fasta),            path(fasta_index)
    tuple path(clinvar),          path(clinvar_tbi)
    tuple path(cadd_snv),         path(cadd_snv_tbi)
    tuple path(cadd_indels),      path(cadd_indels_tbi)
    tuple path(spliceai_snv),     path(spliceai_snv_tbi)
    tuple path(spliceai_indels),  path(spliceai_indels_tbi)
    tuple path(revel),            path(revel_tbi)
    tuple path(alpha),            path(alpha_tbi)

    path plugin_files

    output:
    path "${vcf_file.simpleName}.annotated.txt"

    script:
    """
    mkdir -p plugins
    cp ${plugin_files} plugins/

    # Force exact filenames for files that require sibling indexes
    cp "${spliceai_snv}"      spliceai_snv.vcf.gz
    cp "${spliceai_snv_tbi}"  spliceai_snv.vcf.gz.tbi

    cp "${spliceai_indels}"      spliceai_indels.vcf.gz
    cp "${spliceai_indels_tbi}"  spliceai_indels.vcf.gz.tbi

    cp "${clinvar}"      clinvar.vcf.gz
    cp "${clinvar_tbi}"  clinvar.vcf.gz.tbi

    cp "${cadd_snv}"      cadd_snv.tsv.gz
    cp "${cadd_snv_tbi}"  cadd_snv.tsv.gz.tbi

    cp "${cadd_indels}"      cadd_indels.tsv.gz
    cp "${cadd_indels_tbi}"  cadd_indels.tsv.gz.tbi

    cp "${revel}"      revel.tsv.gz
    cp "${revel_tbi}"  revel.tsv.gz.tbi

    cp "${alpha}"      alpha.tsv.gz
    cp "${alpha_tbi}"  alpha.tsv.gz.tbi

    echo "==== plugins ===="
    ls -l plugins

    echo "==== spliceai files ===="
    ls -l spliceai_snv.vcf.gz*
    ls -l spliceai_indels.vcf.gz*

    echo "==== other indexed files ===="
    ls -l clinvar.vcf.gz*
    ls -l cadd_snv.tsv.gz*
    ls -l cadd_indels.tsv.gz*
    ls -l revel.tsv.gz*
    ls -l alpha.tsv.gz*

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
        --custom "clinvar.vcf.gz,ClinVar,vcf,exact,0,CLNSIG,CLNREVSTAT" \
        --plugin CADD,"cadd_snv.tsv.gz","cadd_indels.tsv.gz" \
        --plugin SpliceAI,snv="spliceai_snv.vcf.gz",indel="spliceai_indels.vcf.gz" \
        --plugin REVEL,"revel.tsv.gz" \
        --plugin SpliceRegion \
        --plugin TSSDistance \
        --plugin AlphaMissense,file="alpha.tsv.gz",cols=all \
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
