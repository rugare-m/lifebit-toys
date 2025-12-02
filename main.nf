#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.bam ?: exit 1, "ERROR: Please provide --bam <file.bam>"

process index_bam {
    tag "$bam"

    input:
    path bam

    output:
    path "${bam}.bai"

    """
    samtools index $bam
    """
}

workflow {
    take_bam = file(params.bam)
    index_bam(take_bam)
}
