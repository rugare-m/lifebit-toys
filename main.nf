nextflow.enable.dsl=2

params.vcf_dir         = null
params.cache           = null
params.fasta           = null

params.clinvar         = null
params.cadd_snv        = null
params.cadd_indels     = null
params.spliceai_snv    = null
params.spliceai_indels = null
params.revel           = null
params.splice_vault    = null
params.dbscSNV         = null
params.alpha           = null


params.spliceai_snv_tbi    = null
params.spliceai_indels_tbi = null
params.clinvar_tbi         = null
params.cadd_snv_tbi        = null
params.cadd_indels_tbi     = null
params.revel_tbi           = null
params.alpha_tbi           = null
params.fasta_fai           = null


params.hp              = 8

params.minimal = false
params.full    = false

include { MINIMAL_RUN_VEP } from './modules/vep.nf'
include { VEP }             from './modules/vep.nf'

workflow {
    Channel
        .fromPath("$projectDir/pm/*.pm")
        .collect()
        .set { plugin_files }

    Channel
        .fromPath("${params.vcf_dir}/*.{vcf,vcf.gz}")
        .set { vcf_files }

    def fasta_tuple = tuple(
        file(params.fasta),
        file("${params.fasta}.fai")
    )

    def clinvar_tuple = tuple(
        file(params.clinvar),
        file("${params.clinvar}.tbi")
    )

    def cadd_snv_tuple = tuple(
        file(params.cadd_snv),
        file("${params.cadd_snv}.tbi")
    )

    def cadd_indels_tuple = tuple(
        file(params.cadd_indels),
        file("${params.cadd_indels}.tbi")
    )

    def spliceai_snv_tuple = tuple(
        file(params.spliceai_snv),
        file("${params.spliceai_snv}.tbi")
    )

    def spliceai_indels_tuple = tuple(
        file(params.spliceai_indels),
        file("${params.spliceai_indels}.tbi")
    )

    def revel_tuple = tuple(
        file(params.revel),
        file("${params.revel}.tbi")
    )

    def alpha_tuple = tuple(
        file(params.alpha),
        file("${params.alpha}.tbi")
    )

    if (params.minimal && params.full)
        exit 1, "ERROR: --minimal and --full cannot both be true"

    if (params.minimal) {
        MINIMAL_RUN_VEP(vcf_files)
    }

    if (params.full) {
    VEP(
        vcf_files,

        tuple(file(params.fasta),            file(params.fasta_fai)),
        tuple(file(params.clinvar),          file(params.clinvar_tbi)),
        tuple(file(params.cadd_snv),         file(params.cadd_snv_tbi)),
        tuple(file(params.cadd_indels),      file(params.cadd_indels_tbi)),
        tuple(file(params.spliceai_snv),     file(params.spliceai_snv_tbi)),
        tuple(file(params.spliceai_indels),  file(params.spliceai_indels_tbi)),
        tuple(file(params.revel),            file(params.revel_tbi)),
        tuple(file(params.alpha),            file(params.alpha_tbi)),

        plugin_files
    )
}
}