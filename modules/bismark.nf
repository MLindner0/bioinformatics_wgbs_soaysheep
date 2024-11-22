process ALIGN {
    tag "ALIGN on $sample_id"
    
    memory { 80.GB * task.attempt }
    time { 20.hour * task.attempt }
    
    errorStrategy 'retry'
    maxRetries 2

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("align_${sample_id}_logs/${sample_id}_R1_val_1_bismark_bt2_pe.bam"), emit: bam
    tuple val(sample_id), path("align_${sample_id}_logs/${sample_id}_R1_val_1_bismark_bt2_PE_report.txt"), emit: report

    script:
    """
    mkdir align_${sample_id}_logs
    mkdir align_${sample_id}_logs/temp
    bismark -X 1000 --parallel 4 --genome ${params.genome} -1 ${reads[0]} -2 ${reads[1]} --temp_dir align_${sample_id}_logs/temp -o align_${sample_id}_logs
    """
}

process DEDUP {
    tag "DEDUP on $sample_id"
    
    input:
    tuple val(sample_id), path(alignment)

    output:
    tuple val(sample_id), path("dedup_${sample_id}_logs/${sample_id}.deduplicated.bam")

    script:
    """
    mkdir dedup_${sample_id}_logs
    deduplicate_bismark -p --output_dir dedup_${sample_id}_logs -o ${sample_id} ${alignment}
    """
}

process METHYLATION {
    tag "METHYLATION on $sample_id"
    publishDir params.stagedir, mode: 'symlink'

    input:
    tuple val(sample_id), path(alignment)

    output:
    tuple val(sample_id), path("meth_${sample_id}_logs/${sample_id}.merged.bismark.cov.gz")

    script:
    """
    mkdir meth_${sample_id}_logs
    bismark_methylation_extractor -p --parallel 4 --no_overlap --report --bedGraph --scaffolds --cytosine_report --ignore 3 --ignore_r2 4 --ignore_3prime 3 --ignore_3prime_r2 2 -o meth_${sample_id}_logs --genome_folder ${params.genome} ${alignment}
    """
}