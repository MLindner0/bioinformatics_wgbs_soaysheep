/*
 * define pipeline input parameters
 */
params.project = "/mnt/parscratch/users/bi1ml/public/methylated_soay/soay_wgbs_main_sep2024"
params.data = "/mnt/parscratch/users/bi1ml/public/methylated_soay/soay_wgbs_main_sep2024"
params.userdir = "/users/bi1ml/pipelines"
params.seqbatch = "first_batch"
params.pipelinebatch = "b1.1" 
params.readsfile = "${params.userdir}/${params.seqbatch}_batches/read_pairs_${params.pipelinebatch}.csv"
params.readsdir = "${params.data}/data_${params.seqbatch}"
params.genome = "/mnt/parscratch/users/bi1ml/public/genomes/ARS-UI_Ramb_v3.0_sc_rmv/GCF_016772045.2"
params.rginfofile = "${params.userdir}/${params.seqbatch}_batches/read_group_info_${params.pipelinebatch}.csv"
params.stagedir = "${params.project}/nextflow_pipeline/stage"

/*
 * Note on genome version: here, a version of Ramb v3 is used where all scaffolds have been removed from the fasta file
 */

log.info """\
    W G B S - N F   P I P E L I N E
    ===============================
    seqbatch      : ${params.seqbatch}
    pipelinebatch : ${params.pipelinebatch}
    
    workdir       : $workDir
    projectdir    : ${params.project}
    stagedir      : ${params.stagedir}
    readsdir      : ${params.readsdir}   
    genomedir     : ${params.genome}

    readsfile     : ${params.readsfile}
    rginfofile    : ${params.rginfofile}   
    """
    .stripIndent()

/*
* load processes from modules
* 1 - QC processes
* 2 - bismark steps (alignment, deduplication, methylation calling)
*   note: genome already prepared (in silico bisulfite converted)
* 3 - alignment tools
* 4 - add ons
* 5 - telomere length estimates
*/
include { FASTQC as FASTQC } from './modules/qc.nf'
include { FASTQCTRIMM as FASTQCTRIMM } from './modules/qc.nf'
include { TRIMGALORE as TRIMGALORE } from './modules/qc.nf'
include { MULTIQC as MULTIQC } from './modules/qc.nf'

include { ALIGN as ALIGN } from './modules/bismark.nf'
include { DEDUP as DEDUP } from './modules/bismark.nf'
include { METHYLATION as METHYLATION } from './modules/bismark.nf'

include { SAMTOOLSSAM as SAMTOOLSSAM } from './modules/alignment_tools.nf'
include { SAMTOOLSCOOR as SAMTOOLSCOOR } from './modules/alignment_tools.nf'
include { PICARDRG as PICARDRG } from './modules/alignment_tools.nf'
include { PICARDMERGE as PICARDMERGE } from './modules/alignment_tools.nf'
include { SAMTOOLSSTATS as SAMTOOLSSTATS } from './modules/alignment_tools.nf'
include { PICARDCOOR as PICARDCOOR } from './modules/alignment_tools.nf'
include { SAMTOOLSDEPTH as SAMTOOLSDEPTH } from './modules/alignment_tools.nf'
include { SAMTOOLSBREADTH as SAMTOOLSBREADTH } from './modules/alignment_tools.nf'

include { BSCONVERSION as BSCONVERSION } from './modules/add_ons.nf'

include { TELSEQ as TELSEQ } from './modules/telseq.nf'

/*
* define workflow
*/
workflow {
    
    /*
    * --- MAIN STEPS ---
    *
    * define input: read pairs
    */
    Channel
        .fromPath(params.readsfile, checkIfExists: true)
        .splitCsv( header: true )
        .map { row -> [row.nextflow_id, [row.file_R1, row.file_R2]] }
        .view()

}
