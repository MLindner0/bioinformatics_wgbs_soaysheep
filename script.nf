/*
 * pipeline input parameters
 */

params.project = "/users/bi1ml/public/methylated_soay/soay_wgbs_full_data_set_sep2024"
params.qcdir = "${params.project}/bioinformatics/qc"
params.reads = "${params.project}/raw_data_trimmed/001-1_*_{R1,R2}.fastq.gz"
params.readsdir = "${params.project}/raw_data_trimmed"

/*
Channel
    .fromFilePairs('/users/bi1ml/public/methylated_soay/soay_wgbs_full_data_set_sep2024/raw_data_trimmed/001-1_*_{R1,R2}.fastq.gz')
    .view()
*/

log.info """\
    W G B S - N F   P I P E L I N E
    ===============================
    workdir      : $workDir
    reads        : ${params.readsdir}
    projectdir   : ${params.project}
    QCout        : ${params.qcdir}
    """
    .stripIndent()

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
    path "trimgalore_${sample_id}_logs/${sample_id}_R1_val_1.fq.gz"
    path "trimgalore_${sample_id}_logs/${sample_id}_R2_val_2.fq.gz"

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

workflow {
    Channel
        .fromFilePairs(params.reads, checkIfExists: true)
        .set { read_pairs_ch }

    fastqc_ch = FASTQC(read_pairs_ch)
    trimgalore_ch = TRIMGALORE(read_pairs_ch)
    MULTIQC(fastqc_ch.mix(trimgalore_ch).collect())
    
}
