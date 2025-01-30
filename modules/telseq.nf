process TELSEQ {
    tag "TELSEQ on $sample_id"
    publishDir params.stagedir, mode: 'symlink'

    input:
    tuple val(sample_id), path(alignment)

    output:
    tuple val(sample_id), path("telseq_${sample_id}_logs/${sample_id}.telseq.out")

    script:
    """
    mkdir telseq_${sample_id}_logs
    telseq -r 150 -o telseq_${sample_id}_logs/${sample_id}.telseq.out ${alignment}
    """
}

