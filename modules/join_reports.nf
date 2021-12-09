process join_mob_typer_and_abricate_reports {

    tag { sample_id }

    publishDir "${params.outdir}/${sample_id}", pattern: "${sample_id}_resistance_plasmids.tsv", mode: 'copy'

    executor 'local'

    input:
      tuple val(sample_id),  path(mob_typer_report), path(abricate_report)

    output:
      tuple val(sample_id), path("${sample_id}_resistance_plasmids.tsv")

    script:
      """
      join_mob_typer_and_abricate_reports.py --sample-id ${sample_id} --mob-typer-report ${mob_typer_report} --abricate-report ${abricate_report} > ${sample_id}_resistance_plasmids.tsv
      """
}


process join_resistance_plasmid_and_snp_reports {

    tag { sample_id + " / " + plasmid_id }

    publishDir "${params.outdir}/${sample_id}", pattern: "${sample_id}_${plasmid_id}_resistance_plasmids.tsv", mode: 'copy'

    executor 'local'

    input:
      tuple val(sample_id), path(resistance_plasmid_report), val(plasmid_id), path(snp_report), path(coverage_report)

    output:
      tuple val(sample_id), path("${sample_id}_${plasmid_id}_resistance_plasmids.tsv")

    script:
      """
      join_resistance_plasmid_and_snp_reports.py --sample-id ${sample_id} --resistance-plasmid-report ${resistance_plasmid_report} --snp-report ${snp_report} --coverage-report ${coverage_report} > ${sample_id}_${plasmid_id}_resistance_plasmids.tsv
      """
}
