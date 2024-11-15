process ALIGN {
    tag "ALIGN on $sample_id"
    
    memory { 30.GB * task.attempt }
    time { 16.hour * task.attempt }
    
    errorStrategy { 'retry' }
    maxRetries 3

    input:
    tuple val(sample_id), path(reads)

    output:
    path "align_${sample_id}_logs/${sample_id}_R1_val_1_bismark_bt2_pe.bam", emit: bam
    path "align_${sample_id}_logs/${sample_id}_R1_val_1_bismark_bt2_PE_report.txt", emit: report

    script:
    """
    mkdir align_${sample_id}_logs
    mkdir align_${sample_id}_logs/temp
    bismark -X 1000 --parallel 4 --genome ${params.genome} -1 ${reads[0]} -2 ${reads[1]} --temp_dir align_${sample_id}_logs/temp -o align_${sample_id}_logs
    """
}