nextflow.enable.dsl=2

params.vcf_dir        = null
params.cache          = null
params.fasta          = null

params.clinvar        = null
params.cadd_snv        = null
params.cadd_indels     = null
params.spliceai_snv    = null
params.spliceai_indels = null
params.revel           = null
params.splice_vault    = null
params.dbscSNV         = null
params.alpha           = null
params.hp              = null

params.minimal = true
params.full    = false

include { MINIMAL_RUN_VEP } from './modules/vep.nf'
include { RUN_VEP }        from './modules/vep.nf'

workflow {

    Channel
        .fromPath("${params.vcf_dir}/*.{vcf,vcf.gz}")
        .set { vcf_files }

    // optional sanity check
    if( params.minimal && params.full )
        exit 1, "ERROR: --minimal and --full cannot both be true"

    if( params.minimal ) {
        MINIMAL_RUN_VEP(vcf_files)
    }

    if( params.full ) {
        RUN_VEP(vcf_files)
    }
}
