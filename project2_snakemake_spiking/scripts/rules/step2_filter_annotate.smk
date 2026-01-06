# step2_filter_annotate.smk

configfile: "config.yaml"

dataSources= config["dataSources"]
results= config["results"]
variant_list = ["original","spiked"]
samples = config["samples"]

rule filter_snps:
    input:
        vcf = "{results}/{sample}/{variant}/{sample}_raw_snps.vcf"
    output:
        filtered = "{results}/{sample}/{variant}/{sample}_filtered_snps.vcf",
        selected = "{results}/{sample}/{variant}/{sample}_analysis-ready-snps.vcf",
        filtered_gt = "{results}/{sample}/{variant}/{sample}_analysis-ready-snps-filteredGT.vcf"
    conda: "gatk4"
    shell:
        """
        gatk VariantFiltration \
            -R {ref} \
            -V {input.vcf} \
            -O {output.filtered} \
            -filter-name "QD_filter" -filter "QD < 2.0" \
            -filter-name "FS_filter" -filter "FS > 60.0" \
            -filter-name "MQ_filter" -filter "MQ < 40.0" \
            -filter-name "SOR_filter" -filter "SOR > 4.0" \
            -filter-name "MQRankSum_filter" -filter "MQRankSum < -12.5" \
            -filter-name "ReadPosRankSum_filter" -filter "ReadPosRankSum < -8.0" \
            -genotype-filter-expression "DP < 10" \
            -genotype-filter-name "DP_filter" \
            -genotype-filter-expression "GQ < 10" \
            -genotype-filter-name "GQ_filter" &&

        gatk SelectVariants \
            --exclude-filtered \
            -V {output.filtered} \
            -O {output.selected} &&

        grep -v -E "DP_filter|GQ_filter" {output.selected} > {output.filtered_gt}
        """

rule filter_indels:
    input:
        vcf = "{results}/{sample}/{variant}/{sample}_raw_indels.vcf"
    output:
        filtered = "{results}/{sample}/{variant}/{sample}_filtered_indels.vcf",
        selected = "{results}/{sample}/{variant}/{sample}_analysis-ready-indels.vcf",
        filtered_gt = "{results}/{sample}/{variant}/{sample}_analysis-ready-indels-filteredGT.vcf"
    conda: "gatk4"
    shell:
        """
        gatk VariantFiltration \
            -R {ref} \
            -V {input.vcf} \
            -O {output.filtered} \
            -filter-name "QD_filter" -filter "QD < 2.0" \
            -filter-name "FS_filter" -filter "FS > 200.0" \
            -filter-name "SOR_filter" -filter "SOR > 10.0" \
            -genotype-filter-expression "DP < 10" \
            -genotype-filter-name "DP_filter" \
            -genotype-filter-expression "GQ < 10" \
            -genotype-filter-name "GQ_filter" &&

        gatk SelectVariants \
            --exclude-filtered \
            -V {output.filtered} \
            -O {output.selected} &&

        grep -v -E "DP_filter|GQ_filter" {output.selected} > {output.filtered_gt}
        """

rule annotate:
    input:
        snps = "{results}/{sample}/{variant}/{sample}_analysis-ready-snps-filteredGT.vcf",
        indels = "{results}/{sample}/{variant}/{sample}_analysis-ready-indels-filteredGT.vcf"
    output:
        snps_annotated = "{results}/{sample}/{variant}/{sample}_analysis-ready-snps-filteredGT-functotated.vcf",
        indels_annotated = "{results}/{sample}/{variant}/{sample}_analysis-ready-indels-filteredGT-functotated.vcf"
    conda: "gatk4"
    shell:
        """
        gatk Funcotator \
            --variant {input.snps} \
            --reference {ref} \
            --ref-version hg38 \
            --data-sources-path {dataSources} \
            --output {output.snps_annotated} \
            --output-file-format VCF &&

        gatk Funcotator \
            --variant {input.indels} \
            --reference {ref} \
            --ref-version hg38 \
            --data-sources-path {dataSources} \
            --output {output.indels_annotated} \
            --output-file-format VCF
        """