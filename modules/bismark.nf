process ALIGN {
    tag "ALIGN on $sample_run"
    
    memory { 80.GB * task.attempt }
    time { 20.hour * task.attempt }
    
    errorStrategy 'retry'
    maxRetries 2

    input:
    tuple val(sample_run), path(reads)

    output:
    tuple val(sample_run), path("align_${sample_run}_logs/${sample_run}_R1_val_1_bismark_bt2_pe.bam"), emit: bam
    tuple val(sample_run), path("align_${sample_run}_logs/${sample_run}_R1_val_1_bismark_bt2_PE_report.txt"), emit: report

    script:
    """
    mkdir align_${sample_run}_logs
    mkdir align_${sample_run}_logs/temp
    bismark -X 1000 --parallel 4 --genome ${params.genome} -1 ${reads[0]} -2 ${reads[1]} --temp_dir align_${sample_run}_logs/temp -o align_${sample_run}_logs
    """
}

process DEDUP {
    tag "DEDUP on $sample_run"
    
    memory { 10.GB * task.attempt }
    time { 10.hour * task.attempt }
    
    errorStrategy 'retry'
    maxRetries 2

    input:
    tuple val(sample_run), path(alignment)

    output:
    tuple val(sample_run), path("align_${sample_run}_logs/${sample_run}.deduplicated.bam")

    script:
    """
    mkdir dedup_${sample_run}_logs
    deduplicate_bismark -p --output_dir dedup_${sample_run}_logs -o ${sample_run} ${alignment}
    """
}