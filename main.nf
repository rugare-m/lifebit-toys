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
params.hp              = 8

params.minimal = false
params.full    = false

include { MINIMAL_RUN_VEP } from './modules/vep.nf'
include { VEP }             from './modules/vep.nf'

workflow {

    Channel
        .fromPath("${params.vcf_dir}/*.{vcf,vcf.gz}")
        .set { vcf_files }

    if (params.minimal && params.full)
        exit 1, "ERROR: --minimal and --full cannot both be true"

    if (params.minimal) {
        MINIMAL_RUN_VEP(vcf_files)
    }

    if (params.full) {
        VEP(
            vcf_files,
            file(params.fasta),
            file("${params.fasta}.fai"),

            file(params.clinvar),
            file("${params.clinvar}.tbi"),

            file(params.cadd_snv),
            file ("${params.cadd_snv}.tbi"),

            file(params.cadd_indels),
            file("${params.cadd_indels}.tbi"),

            file(params.spliceai_snv),
            file(params.spliceai_indels),


            file(params.revel),

            file(params.alpha),
            file("${params.alpha}.tbi")
        )
    }
}
