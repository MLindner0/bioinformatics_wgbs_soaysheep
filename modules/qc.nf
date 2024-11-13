process FASTQC {
    tag "FASTQC on $sample_id"
    memory { 250.MB * task.cpus }

    input:
    tuple val(sample_id), path(reads)

    output:
    path "fastqc_${sample_id}_logs"

    script:
    """
    mkdir fastqc_${sample_id}_logs
    fastqc -o fastqc_${sample_id}_logs -f fastq -q ${reads}
    """
}

process TRIMGALORE {
    tag "TRIM_GALORE on $sample_id"
    
    memory { 8.GB * task.attempt }
    time { 8.hour * task.attempt }
    
    errorStrategy { 'retry' }
    maxRetries 3

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path('trimgalore_${sample_id}_logs/${sample_id}_R1_val_1.fq.gz') path('trimgalore_${sample_id}_logs/${sample_id}_R2_val_2.fq.gz')

    script:
    """
    mkdir trimgalore_${sample_id}_logs
    trim_galore --2colour 20 -j 8 --paired --gzip -o trimgalore_${sample_id}_logs ${reads}
    """
}

process MULTIQC {
    publishDir params.qcdir, mode:'copy'

    input:
    path '*'

    output:
    path 'multiqc_report.html'

    script:
    """
    multiqc .
    """
}
