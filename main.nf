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


// Import the process from the module file
include { MINIMAL_RUN_VEP } from './modules/vep.nf'


workflow {

    Channel
        .fromPath("${params.vcf_dir}/*.{vcf,vcf.gz}")
        .set { vcf_files }

    MINIMAL_RUN_VEP(vcf_files)
}
