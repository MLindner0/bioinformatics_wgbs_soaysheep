process BSCONVERSION {
    tag "BSCONVERSION on $sample_id"
    publishDir params.stagedir, mode: 'symlink'

    input:
    tuple val(sample_id), path(report)

    output:
    tuple val(sample_id), path("bs_conversion_${sample_id}_logs/${sample_id}.BS-conversion.txt")

    script:
    """
    mkdir bs_conversion_${sample_id}_logs
    grep 'C methylated in CHG context:' ${report} | sed -e 's/%//g' | awk -v OFS='\t' '{print \$6,(100-\$6),"${sample_id}"}' > bs_conversion_${sample_id}_logs/${sample_id}.BS-conversion.txt
    """
}
