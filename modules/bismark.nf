process ALIGN {
    tag "ALIGN on $sample_id"
    
    memory { 8.GB * task.attempt }
    time { 8.hour * task.attempt }
    
    errorStrategy { 'retry' }
    maxRetries 3

    input:
    tuple val(sample_id), path(reads)

    output:
    path 'align_${sample_id}_logs/'

    script:
    """
    mkdir align_${sample_id}_logs
    mkdir align_${sample_id}_logs/temp
    bismark -X 1000 --parallel 8 --genome ${params.genome} -1 ${reads[0]} -2 ${reads[1]} --temp_dir align_${sample_id}_logs/temp -o align_${sample_id}_logs
    """
}