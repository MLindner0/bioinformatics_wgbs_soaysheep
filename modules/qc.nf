process FASTQC {
    tag "FASTQC on $sample_id"

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

process FASTQCTRIMM {
    tag "FASTQC on $sample_id"

    input:
    tuple val(sample_id), path(reads)

    output:
    path "fastqc_trimm_${sample_id}_logs"

    script:
    """
    mkdir fastqc_trimm_${sample_id}_logs
    fastqc -o fastqc_trimm_${sample_id}_logs -f fastq -q ${reads}
    """
}

process TRIMGALORE {
    tag "TRIM_GALORE on $sample_id"
    
    memory { 1.GB * task.attempt }
    time { 3.hour * task.attempt }
    
    errorStrategy 'retry'
    maxRetries 2

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("trimgalore_*/*fq.gz")

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
