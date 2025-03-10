process FASTQC {
    tag "FASTQC on $sample_id"

    errorStrategy 'retry'
    maxRetries 2

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

    errorStrategy 'retry'
    maxRetries 2
    
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
    
    memory { 10.GB * task.attempt }
    time { 16.hour * task.attempt }
    
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
    publishDir params.stagedir, mode:'symlink'

    errorStrategy 'retry'
    maxRetries 2
    
    input:
    path '*'

    output:
    path "multiqc_data_${params.pipelinebatch}/multiqc_report_${params.pipelinebatch}.html"
    path "multiqc_data_${params.pipelinebatch}/multiqc_report_${params.pipelinebatch}_data/multiqc_fastqc.txt"

    script:
    """
    multiqc . -n multiqc_report_${params.pipelinebatch}.html -o multiqc_data_${params.pipelinebatch}
    """
}
