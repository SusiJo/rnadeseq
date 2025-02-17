/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE INPUTS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Validate input parameters
WorkflowRnadeseq.initialise(params, log)

// TODO nf-core: Add all file path parameters for the pipeline to the list below
// Check input path parameters to see if they exist
def checkPathParamList = [
    params.metadata, params.model,
    params.project_summary, params.versions,
    params.multiqc
    ]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Check mandatory parameters
if (!(params.input_type in ["featurecounts", "salmon", "rsem"])) { exit 1, 'Wrong input type ' + params.input_type + ', must be one of "featurecounts", "salmon", "rsem"!' }

if (params.gene_counts) { ch_counts_path = Channel.fromPath(params.gene_counts) } else { exit 1, 'Please provide input file/dir!' }
if (params.metadata) { ch_metadata_file = Channel.fromPath(params.metadata) } else { exit 1, 'Please provide metadata file!' }
if (params.model) { ch_model_file = Channel.fromPath(params.model) } else { exit 1, 'Please provide linear model file!' }
if (params.project_summary) { ch_proj_summary_file = Channel.fromPath(params.project_summary) } else { exit 1, 'Please provide project summary file!' }
if (params.versions) { ch_softwareversions_file = Channel.fromPath(params.versions) } else { exit 1, 'Please provide software versions file!' }
if (params.multiqc) { ch_multiqc_file = Channel.fromPath(params.multiqc) } else { exit 1, 'Please provide multiqc.zip folder!' }

// Create channel for genome parameter gtf (the other genome params are not files)
if (params.input_type in ["rsem", "salmon"]) { ch_gtf = Channel.fromPath(params.gtf) } else { ch_gtf = Channel.fromPath("FALSE") }

// Create channels for optional parameters
ch_contrast_matrix = Channel.fromPath(params.contrast_matrix)
ch_contrast_list = Channel.fromPath(params.contrast_list)
ch_contrast_pairs = Channel.fromPath(params.contrast_pairs)
ch_relevel = Channel.fromPath(params.relevel)
ch_quote_file = Channel.fromPath(params.quote)
ch_genes = Channel.fromPath(params.genelist)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
//
// MODULE: Loaded from modules/local/
//
include { DESEQ2 } from '../modules/local/deseq2'
include { PATHWAY_ANALYSIS } from '../modules/local/pathway_analysis'
include { REPORT } from '../modules/local/report'

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { CUSTOM_DUMPSOFTWAREVERSIONS } from '../modules/nf-core/modules/custom/dumpsoftwareversions/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Info required for completion email and summary
workflow RNADESEQ {


    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    //

//
//  MODULE: DE analysis
    DESEQ2 (
        ch_counts_path,
        ch_metadata_file,
        ch_model_file,
        ch_contrast_matrix,
        ch_relevel,
        ch_contrast_list,
        ch_contrast_pairs,
        ch_genes,
        ch_gtf
    )
    ch_deseq2 = DESEQ2.out.deseq2
    ch_contrnames = DESEQ2.out.contrnames

//
//  MODULE: Pathway analysis
//
    ch_pathway_analysis = Channel.fromPath("FALSE")
    if (!params.skip_pathway_analysis) {
        PATHWAY_ANALYSIS (
            ch_deseq2,
            ch_metadata_file,
            ch_model_file,
            ch_genes
        )
        ch_pathway_analysis = PATHWAY_ANALYSIS.out.pathway_analysis
    }

//
//  MODULE: RNAseq Report
//

    REPORT (
        ch_proj_summary_file,
        ch_softwareversions_file,
        ch_model_file,
        ch_contrnames,
        ch_deseq2,
        ch_multiqc_file,
        ch_genes,
        ch_pathway_analysis,
        ch_quote_file
    )

    //TODO: Enable this:
    // This channel contains the versions of all tools of the current module
//    CUSTOM_DUMPSOFTWAREVERSIONS (
//        ch_softwareversions_file.unique().collectFile(name: 'collated_versions.yml')
//    )

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
//TODO: Have a look at email_on_fail
//Here I have to change the params?

/*
//TODO: Remove multiqc and also edit /lib/nfcoretemplate to add deseq report instead of multiqc
workflow.onComplete {
    if (params.email || params.email_on_fail) {
        NfcoreTemplate.email(workflow, params, summary_params, projectDir, log, multiqc_report)
    }
    NfcoreTemplate.summary(workflow, params, log)
}
*/
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
