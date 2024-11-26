/*
 * define pipeline input parameters
 */
params.project = "/users/bi1ml/public/methylated_soay/soay_wgbs_main_sep2024"
params.seqbatch = "first_batch"
params.pipelinebatch = "b1.1" 
params.readsfile = "/users/bi1ml/pipelines/${params.seqbatch}_batches/read_pairs_${params.seqbatch}.csv"
params.readsdir = "${params.project}/data_${params.seqbatch}"
params.genome = "/users/bi1ml/public/genomes/ARS-UI_Ramb_v2.0/GCF_016772045.1"
params.rginfofile = "/users/bi1ml/pipelines/${params.seqbatch}_batches/read_group_info_${params.seqbatch}.csv"
params.stagedir = "${params.project}/nextflow_pipeline/stage"

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
        .fromFilePairs(params.reads, checkIfExists: true)
        .set { read_pairs_ch }
    Channel
        .fromPath(params.readsfile, checkIfExists: true)
        .splitCsv( header: true )
        .map { row -> [row.nextflow_id, [row.file.R1, row.file.R2]] }
        .view()
    /*
        .set { read_pairs_ch }

    * --- quality control & read trimming ---
    *
    * fastqc on read pairs (already trimmed using cutadapt by Liverpool)
    *
    FASTQC(read_pairs_ch)
    FASTQC.out.view { "fastqc: $it" }

    *
    * redo trimming of read pairs using trimgalore
    *
    TRIMGALORE(read_pairs_ch)
    TRIMGALORE.out.view { "trimming: $it" }

    *
    * redo fastqc on "trimmed" read pairs
    *
    trimgalore_ch = TRIMGALORE.out
    FASTQCTRIMM(trimgalore_ch)
    FASTQCTRIMM.out.view { "fastqc_trimm: $it" }

    *
    * create multiqc report for 'raw' and trimmed read pairs
    *
    fastqc_ch = FASTQC.out
    trimmed_fastqc_ch = FASTQCTRIMM.out
    MULTIQC(fastqc_ch.mix(trimmed_fastqc_ch).collect())

    *
    * --- alignment & alignment formatting ---
    *
    * bismark alignment
    *
    ALIGN(trimgalore_ch)
    ALIGN.out.bam.view { "align.bam: $it" }
    ALIGN.out.report.view { "align.rep: $it" }

    *
    * convert bismark alignment to .sam format (recommended for deduplication of wgbs data)
    *
    first_align_ch = ALIGN.out.bam
    SAMTOOLSSAM(first_align_ch)
    SAMTOOLSSAM.out.view { "samtools_sam: $it" }

    *
    * deduplication
    *
    sam_align_ch = SAMTOOLSSAM.out
    DEDUP(sam_align_ch)
    DEDUP.out.view { "dedup: $it" }

    *
    * sort alignments by coordinates
    *  
    dedup_align_ch = DEDUP.out
    SAMTOOLSCOOR(dedup_align_ch)
    SAMTOOLSCOOR.out.view { "samtools_coor: $it" }

    *
    * prepare input chanel for adding read group information
    *   1 - reformat tuple from SAMTOOLSCOOR.out --> rg_file_ch
    *   2 - read read group information and format --> rg_info_ch
    *   3 - combine and format file and read group channles --> add_rg_input_ch
    *
    SAMTOOLSCOOR.out
        .map { sample, file -> [sample, file]}
        .set { rg_file_ch }
    */
    Channel
        .fromPath(params.rginfo, checkIfExists: true)
        .splitCsv( header: true )
        .map { row -> [row.nextflow_id, row.sample_ref, row.lane, row.batch] }
        .view()
    /*
        .set { rg_meta_ch }

    rg_file_ch.join(rg_meta_ch)
        .map { sample, file, sample_ref, lane, batch -> [sample, sample_ref, lane, batch, [file]] }
        .set { add_rg_input_ch }
    
    *
    * add read group information
    *
    PICARDRG(add_rg_input_ch)
    PICARDRG.out.view { "picard_RG: $it" }

    *
    * prepare input chanel for mergin alignments
    *   each sample was sequenced on 3 runs
    *   now the three alignments for each samples are merged into one alignment
    *       change key in tuple from sample_run to sample
    *       group the three alignments for each samples based on the new key
    *       --> merge_input_ch
    *
    PICARDRG.out
        .map { sample, file -> [sample.tokenize('_').get(0), file]}
        .groupTuple()
        .set { merge_align_input_ch }

    *
    * merge alignments
    *
    PICARDMERGE(merge_align_input_ch)
    PICARDMERGE.out.view { "picard_merge: $it" }

    *
    * --- methylation calling ---
    *
    * call methylation
    *
    merge_align_out_ch = PICARDMERGE.out
    METHYLATION(merge_align_out_ch)
    METHYLATION.out.view { "meth: $it" }

    *
    * --- EXTRA STEPS ---
    *
    * 1 - samtools alignment stats (samtools)
    *
    SAMTOOLSSTATS(merge_align_out_ch)
    SAMTOOLSSTATS.out.view { "samtools_stats: $it" }

    *
    * 2 - sort alignmet & get genome coverage (average depth) and genome breadth
    *   genome breadth is estimates for various coverage thresholds
    *
    PICARDCOOR(merge_align_out_ch)
    PICARDCOOR.out.view { "picard_coor: $it" }

    cov_input_ch = PICARDCOOR.out
    SAMTOOLSDEPTH(cov_input_ch)
    SAMTOOLSDEPTH.out.view { "cov_depth: $it" }

    cov_thresh = ['2', '4', '5', '6', '8', '10', '15', '20', '25', '30']
    SAMTOOLSBREADTH(cov_input_ch, cov_thresh)
    SAMTOOLSBREADTH.out.view { "cov_breadth: $it" }

    *
    * 3 - get estimate of bisulfite conversion from bismark alignment report
    *
    align_report_ch = ALIGN.out.report
    BSCONVERSION(align_report_ch)
    BSCONVERSION.out.view { "bs_conversion: $it" }
}