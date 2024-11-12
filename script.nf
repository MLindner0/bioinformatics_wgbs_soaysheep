/*
 * pipeline input parameters
 */

params.project = "/users/bi1ml/public/methylated_soay/soay_wgbs_full_data_set_sep2024/"

Channel
    .fromFilePairs('/users/bi1ml/public/methylated_soay/soay_wgbs_full_data_set_sep2024/raw_data_trimmed/001-1_*_{R1,R2}.fastq.gz')
    .view()

/*
 * pipeline log
 */

log.info """\
    R N A S E Q - N F   P I P E L I N E
    ===================================
    projectdir   : ${params.project}
    workdir      : $workDir
    """
    .stripIndent()

