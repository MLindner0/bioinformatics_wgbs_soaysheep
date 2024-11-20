process SAMTOOLSSAM {
    tag "SAMTOOLSSAM on $sample_id"

    input:
    tuple val(sample_id), path(alignment)

    output:
    tuple val(sample_id), path("sam_${sample_id}_logs/${sample_id}.sam")

    script:
    """
    mkdir sam_${sample_id}_logs
    mkdir sam_${sample_id}_logs/temp
    samtools view -h ${alignment} | samtools sort -n -O sam -T sam_${sample_id}_logs/temp > sam_${sample_id}_logs/${sample_id}.sam
    """
}

process SAMTOOLSCOOR {
    tag "SAMTOOLSCOOR on $sample_id"

    input:
    tuple val(sample_id), path(alignment)

    output:
    tuple val(sample_id), path("sam_${sample_id}_logs/${sample_id}.deduplicated.coordinates.bam")

    script:
    """
    mkdir sam_${sample_id}_logs
    mkdir sam_${sample_id}_logs/temp
    samtools view -h ${alignment} | samtools sort -O bam -T sam_${sample_id}_logs/temp > sam_${sample_id}_logs/${sample_id}.deduplicated.coordinates.bam
    """
}