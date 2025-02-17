process PATHWAY_ANALYSIS {

    input:
    path deseq_output
    path metadata
    path model
    path genelist

    output:
    path 'pathway_analysis', emit: pathway_analysis

    script:
    def genelistopt = genelist.name != 'NO_FILE' ? "--genelist $genelist" : ''
    def basepath = 'differential_gene_expression/gene_counts_tables/'
    def normInput = params.use_vst ? basepath + 'vst_transformed_gene_counts.tsv' : basepath + 'rlog_transformed_gene_counts.tsv'
    """
    pathway_analysis.R --dirContrasts 'differential_gene_expression/DE_genes_tables/' --metadata $metadata \
    --model $model --normCounts $normInput \
    --species $params.organism --species_library $params.library --keytype $params.keytype \
    $genelistopt --min_DEG_pathway $params.min_DEG_pathway
    """
}
