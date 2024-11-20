process SAMTOOLSSAM {
    tag "SAMTOOLSSAM on $sample_id"
    
    memory { 5.GB * task.attempt }
    time { 5.hour * task.attempt }
    
    errorStrategy 'retry'
    maxRetries 2

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