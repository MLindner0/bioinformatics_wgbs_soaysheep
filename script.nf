/*
 * pipeline input parameters
 */

params.project = "/users/bi1ml/public/methylated_soay/soay_wgbs_full_data_set_sep2024"
params.qcdir = "${params.project}/bioinformatics/qc"
params.reads = "${params.project}/raw_data_trimmed/001-1_*_{R1,R2}.fastq.gz"
params.readsdir = "${params.project}/raw_data_trimmed"

log.info """\
    W G B S - N F   P I P E L I N E
    ===============================
    workdir      : $workDir
    reads        : ${params.readsdir}
    projectdir   : ${params.project}
    QCout        : ${params.qcdir}
    """
    .stripIndent()

include { FASTQC as FASTQC } from './modules/qc.nf'
include { FASTQC as FASTQC_TRIMMED } from './modules/qc.nf'
include { TRIMGALORE as TRIMGALORE } from './modules/qc.nf'
include { MULTIQC as MULTIQC } from './modules/qc.nf'

workflow {
    Channel
        .fromFilePairs(params.reads, checkIfExists: true)
        .set { read_pairs_ch }

    fastqc_ch = FASTQC(read_pairs_ch)
    trimgalore_ch = TRIMGALORE(read_pairs_ch)
    trimmed_fastqc_ch = FASTQC_TRIMMED(trimgalore_ch.groupTuple())
    MULTIQC(fastqc_ch.mix(trimmed_fastqc_ch).collect())
    
}
