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
params.hp              = 4

params.minimal = true
params.full    = false

include { MINIMAL_RUN_VEP } from './modules/vep.nf'
include { VEP }        from './modules/vep.nf'

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
        workflow {

    //vcf_ch = Channel.fromPath(params.vcf)

    fasta = file(params.fasta)
    fasta_index = file("${params.fasta}.fai")

    VEP(
        vcf_files,
        fasta,
        fasta_index,
        file(params.clinvar),
        file(params.cadd_snv),
        file(params.cadd_indels),
        file(params.spliceai_snv),
        file(params.spliceai_indels),
        file(params.revel),
        file(params.alpha)
    )
}
    }
}
