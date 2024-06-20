[![Tests](https://github.com/BCCDC-PHL/plasmid-screen/actions/workflows/tests.yml/badge.svg)](https://github.com/BCCDC-PHL/plasmid-screen/actions/workflows/tests.yml)

# plasmid-screen

## Usage

This pipeline is designed to take either raw reads alone, or assemblies plus raw reads as input. If only reads are provided, they will be assembled with [unicycler](https://github.com/rrwick/Unicycler).

```
nextflow run BCCDC-PHL/plasmid-screen \
  --fastq_input </path/to/fastqs> \
  --mob_db </path/to/mob-suite-db> \
  --outdir </path/to/outdir> 
```

If assemblies are already available, they can be provided by adding the `--pre_assembled` flag, and supplying the assemblies to the `--assembly_input` flag.

```
nextflow run BCCDC-PHL/plasmid-screen \
  --pre_assembled \
  --assembly_input </path/to/assemblies> \
  --fastq_input </path/to/fastqs> \
  --mob_db </path/to/mob-suite-db> \
  --outdir </path/to/outdir> 
```

Alternatively, a 'samplesheet.csv' file may be provided with fields `ID`, `R1`, `R2`:

```csv
ID,R1,R2
sample-01,/path/to/sample-01_R1.fastq.gz,/path/to/sample-01_R2.fastq.gz
sample-02,/path/to/sample-02_R1.fastq.gz,/path/to/sample-02_R2.fastq.gz
...
```

```
nextflow run BCCDC-PHL/plasmid-screen \
  --samplesheet_input </path/to/samplesheet.csv> \
  --mob_db </path/to/mob-suite-db> \
  --outdir </path/to/outdir> 
```

...or if assemblies are available, the `samplesheet.csv` file may also include the field `ASSEMBLY`:

```csv
ID,R1,R2,ASSEMBLY
sample-01,/path/to/sample-01_R1.fastq.gz,/path/to/sample-01_R2.fastq.gz,/path/to/sample-01.fa
sample-02,/path/to/sample-02_R1.fastq.gz,/path/to/sample-02_R2.fastq.gz,/path/to/sample-01.fa
...
```

```
nextflow run BCCDC-PHL/plasmid-screen \
  --pre_assembled \
  --samplesheet_input </path/to/samplesheet.csv> \
  --mob_db </path/to/mob-suite-db> \
  --outdir </path/to/outdir> 
```

## Outputs

The main output of the pipeline is the 'Resistance gene report', which summarizes where the resistance gene was located (contig and position), the quality of the resitance gene match (% identity and
% coverage) and a characterization of the plasmid reconstruction. The report includes the following fields:

```
sample_id
assembly_file
resistance_gene_contig_id
resistance_gene_contig_size
resistance_gene_id
resistance_gene_contig_position_start
resistance_gene_contig_position_end
percent_resistance_gene_coverage
percent_resistance_gene_identity
num_contigs_in_plasmid_reconstruction
plasmid_reconstruction_size
replicon_types
mob_suite_primary_cluster_id
mob_suite_secondary_cluster_id
mash_nearest_neighbor
mash_neighbor_distance
alignment_ref_plasmid
depth_coverage_threshold
percent_ref_plasmid_coverage_above_depth_threshold
num_snps_vs_ref_plasmid
```

### Additional Output Files

For each sample, the following output files are created:

```
sample-01/
├── sample-01_20211207163723_provenance.yml
├── sample-01_abricate_ncbi.tsv
├── sample-01_abricate_plasmidfinder.tsv
├── sample-01_chromosome.fasta
├── sample-01_fastp.csv
├── sample-01_mash_screen.tsv
├── sample-01_mobtyper_contig_report.tsv
├── sample-01_mobtyper_plasmid_report.tsv
├── sample-01_resistance_gene_report.tsv
├── sample-01_NC_019152.1.snps.vcf
├── sample-01_NC_019152.1.sorted.bam
├── sample-01_NC_019152.1.sorted.bam.bai
├── sample-01_plasmid_AA023.fasta
├── sample-01_plasmid_AA026.fasta
├── sample-01_quast.csv
└── NC_019152.1.fa
```

| filename suffix                  | Generated by  | Description                                                                                          |
|:---------------------------------|:--------------|:-----------------------------------------------------------------------------------------------------|
| `_abricate_ncbi.tsv`             | `abricate`    | All resistance genes found in the entire assembly                                                    |
| `_abricate_plasmidfinder.tsv`    | `abricate`    | All replicon genes found in the entire assembly                                                      |
| `_chromosome.fasta`              | `mob_recon`   | The set of contigs determined by mob_recon to belong to the chromosome (non-plasmid)                 |
| `_plasmid_<cluster_id>_.fasta`   | `mob_recon`   | Plasmid reconstructions. Groups of contigs that were determined to be part of the same plasmid       |
| `_fastp.csv`                     | `fastp`       | Read QC info                                                                                         |
| `_quast.csv`                     | `quast`       | Assembly QC info                                                                                     |
| `_mash_screen.tsv`               | `mash`        | [Containment](https://genomeinformatics.github.io/mash-screen/) of reference plasmids in reads       |
| `_mobtyper_contig_report.csv`    | `mob_typer`   | MOB Typer results for all contigs in the assembly (both chromosome and plasmid)                      |
| `_mobtyper_plasmid_report.csv`   | `mob_typer`   | MOB Typer results for all plasmid reconstructions (including those that do not have resistance genes |
| `_<plasmid_id>.sorted.bam{.bai}` | `bwa`         | Alignment of reads against a reference plasmid                                                       |
| `.snps.vcf`                      | `freebayes`   | SNPs found in alignment of reads against a reference plasmid                                         |
| `<plasmid_id>.fa`                | `seqkit`      | Reference plasmid used for alignments                                                                |


### Provenance

Each analysis will create a provenance.yml file for each sample. The filename of the `provenance.yml` file includes a timestamp with format `YYYYMMDDHHMMSS` to ensure
that a unique file will be produced if a sample is re-analyzed and outputs are stored to the same directory.

Example provenance output:

```yml
- pipeline_name: BCCDC-PHL/plasmid-screen
  pipeline_version: 0.2.3
  nextflow_session_id: c0cc6250-c767-4bfe-9254-0b49ff6dab91
  nextflow_run_name: mighty_panini
  timestamp_analysis_start: 2024-06-18T16:09:15.659426-07:00
- input_filename: sample-01_R1.fastq.gz
  input_path: /path/to/sample-01_R1.fastq.gz
  sha256: 497c99c5665bd0b89666c5fa625ae966f2ffaf218186db0e1ae95a15dac3ac76
- input_filename: sample-01_R2.fastq.gz
  input_path: /path/to/sample-01_R2.fastq.gz
  sha256: 46ec4c473b613d36c7ce109808c4510a10b205aaebcfe837eb542999fdbdf11f
- input_filename: sample-01_unicycler_short.fa
  input_path: /path/to/sample-01_unicycler_short.fa
  sha256: b0d012b23057095b305cf57a687d90406e7383051d2c845717f6e99fdb4d4ad7
- process_name: trim_reads
  tools:
    - tool_name: fastp
      tool_version: 0.22.0
      parameters:
        - parameter: cut_tail
          value: true
- process_name: quast
  tools:
    - tool_name: quast
      tool_version: 5.0.2
- process_name: mash_screen
  tools:
    - tool_name: mash
      tool_version: 2.3
      parameters
        - name: threshold
          value: 0.996
- process_name: mob_recon
  tools:
    - tool_name: mob_recon
      tool_version: 3.0.3
      parameters
        - parameter: database_directory
          value: /path/to/mob-suite/db
        - parameter: filter_db
          value: /path/to/mob-suite/chromosomes/2019-11-NCBI-Enterobacteriacea-Chromosomes.fasta
        - parameter: min_con_cov
          value: 95
- process_name: abricate
  tools:
    - tool_name: abricate
      tool_version: 1.0.1
      parameters:
        - parameter: db
          value: ncbi
- process_name: abricate
  tools:
    - tool_name: abricate
      tool_version: 1.0.1
      parameters:
        - parameter: db
          value: plasmidfinder
- process_name: align_reads_to_reference_plasmid
  process_tags:
    ref_plasmid_id: NZ_CP023897.1
    resistance_gene: blaOXA-181
  tools:
    - tool_name: bwa
      tool_version: 0.7.17-r1188
      subcommand: mem
      parameters:
        - parameter: output_all_alignments
          value: true
        - parameter: use_soft_clipping_for_supplementary_alignments
          value: true
        - parameter: mark_shorter_split_hits_as_secondary
          value: true
    - tool_name: samtools
      tool_version: 1.13
      subcommand: view
      parameters:
        - parameter: exclude_flags
          value: 1540
- process_name: call_snps
  process_tags:
    ref_plasmid_id: NZ_CP023897.1
    resistance_gene: blaOXA-181
  tools:
    - tool_name: freebayes
      tool_version: 1.3.5
      parameters:
        - parameter: ploidy
          value: 1
        - parameter: min_base_quality
          value: 20
        - parameter: min_mapping_quality
          value: 60
        - parameter: min_coverage
          value: 10
        - parameter: min_alternate_fraction
          value: 0.8
        - parameter: min_repeat_entropy
          value: 1.0
    - tool_name: bcftools
      tool_version: 1.20
      subcommand: view
      parameters:
        - parameter: include
          value: INFO/TYPE=snp
```
