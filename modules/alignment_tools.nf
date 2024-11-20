process SAMTOOLSSAM {
    tag "SAMTOOLSSAM on $sample_run"
    
    memory { 5.GB * task.attempt }
    time { 5.hour * task.attempt }
    
    errorStrategy 'retry'
    maxRetries 2

    input:
    tuple val(sample_run), path(alignment)

    output:
    tuple val(sample_run), path("sam_${sample_run}_logs/${sample_run}.sam")

    script:
    """
    mkdir sam_${sample_run}_logs
    mkdir sam_${sample_run}_logs/temp
    samtools view -h ${alignment} | samtools sort -n -O sam -T sam_${sample_run}_logs/temp > sam_${sample_run}_logs/${sample_run}.sam
    """
}

process SAMTOOLSCOOR {
    tag "SAMTOOLSCOOR on $sample_run"
    
    memory { 5.GB * task.attempt }
    time { 5.hour * task.attempt }
    
    errorStrategy 'retry'
    maxRetries 2

    input:
    tuple val(sample_run), path(alignment)

    output:
    tuple val(sample_run), path("sam_${sample_run}_logs/${sample_run}.deduplicated.coordinates.bam")

    script:
    """
    mkdir sam_${sample_run}_logs
    mkdir sam_${sample_run}_logs/temp
    samtools view -h ${alignment} | samtools sort -O bam -T sam_${sample_run}_logs/temp > sam_${sample_run}_logs/${sample_run}.deduplicated.coordinates.bam
    """
}