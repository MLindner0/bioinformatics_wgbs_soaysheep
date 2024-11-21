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

process PICARDRG {
    tag "SAMTOOLSCOOR on $sample_id"

    input:
    tuple val(sample_id), val(sample_ref), val(lane), val(batch), path(alignment)

    output:
    tuple val(sample_id), path("align_RG_${sample_id}_logs/${sample_id}.deduplicated.withRG.bam")

    script:
    """
    mkdir align_RG_${sample_id}_logs
    mkdir align_RG_${sample_id}_logs/temp
    picard -Xmx4096m AddOrReplaceReadGroups I=${alignment} O=align_RG_${sample_id}_logs/${sample_id}.deduplicated.withRG.bam TMP_DIR=align_RG_${sample_id}_logs/temp ID=${batch}.${lane} LB=NEB_EM-Seq PL=illumina PU=${batch}.${lane} SM=${sample_ref} CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT SORT_ORDER=queryname
    """
}