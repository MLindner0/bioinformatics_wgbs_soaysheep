/*
 * pipeline input parameters
 */

params.project = "/users/bi1ml/public/methylated_soay/soay_wgbs_full_data_set_sep2024"
params.qcdir = "${params.project}/bioinformatics/qc"
params.reads = "${params.project}/raw_data_trimmed/001-1_*_{R1,R2}.fastq.gz"

/*
Channel
    .fromFilePairs('/users/bi1ml/public/methylated_soay/soay_wgbs_full_data_set_sep2024/raw_data_trimmed/001-1_*_{R1,R2}.fastq.gz')
    .view()
*/

log.info """\
    R N A S E Q - N F   P I P E L I N E
    ===================================
    workdir      : $workDir
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
    fastqc_${sample_id}_logs
    fastqc -o fastqc_${sample_id}_logs -f fastq -q ${reads}
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
    MULTIQC(fastqc_ch.collect())
}
