#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    qbic-pipelines/rnadeseq
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/qbic-pipelines/rnadeseq
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    GENOME PARAMETER VALUES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//Either genome needs to be set or the parameters gtf (for rsem/salmon) and organism, library and keytype
//(for pathway analysis) have to be provided separately
//-->gtf is necessary for rsem and salmon
if (params.input_type in ["rsem", "salmon"]) {
    if (!params.genome && !params.gtf) { exit 1, 'Please provide either genome or gtf file!' }
    else if (!params.gtf) {
        params.gtf = WorkflowMain.getGenomeAttribute(params, 'gtf')
        if (!params.gtf) {
            exit 1, 'It seems that for your genome, no gtf file is defined. Please provide a gtf with the --gtf parameter or open a github issue: https://github.com/qbic-pipelines/rnadeseq/issues'
        }
    }
}
//-->organism, library and keytype are necessary for pathway analysis
if (!params.skip_pathway_analysis) {
    if (!params.genome && !params.organism) { exit 1, 'Please provide either genome or organism!' }
    else if (!params.organism) {
        params.organism = WorkflowMain.getGenomeAttribute(params, 'organism')
        if (!params.organism) {
            exit 1, 'It seems that for your genome, no organism is defined. Please provide the organism with the --organism parameter or open a github issue: https://github.com/qbic-pipelines/rnadeseq/issues'
        }
    }
    if (!params.genome && !params.library) { exit 1, 'Please provide either genome or library!' }
    else if (!params.library) {
        params.library = WorkflowMain.getGenomeAttribute(params, 'library')
        if (!params.library) {
            exit 1, 'It seems that for your genome, no library is defined. Please provide the library with the --library parameter or open a github issue: https://github.com/qbic-pipelines/rnadeseq/issues'
        }
    }
    if (!params.genome && !params.keytype) { exit 1, 'Please provide either genome or keytype!' }
    else if (!params.keytype) {
        params.keytype = WorkflowMain.getGenomeAttribute(params, 'keytype')
        if (!params.keytype) {
            exit 1, 'It seems that for your genome, no keytype is defined. Please provide the keytype with the --keytype parameter or open a github issue: https://github.com/qbic-pipelines/rnadeseq/issues'
        }
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE & PRINT PARAMETER SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
WorkflowMain.initialise(workflow, params, log)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOW FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


include { RNADESEQ } from './workflows/rnadeseq'
//
// WORKFLOW: Run main qbic-pipelines/rnadeseq analysis pipeline
//
workflow QBIC_RNADESEQ {
    RNADESEQ ()
}
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Execute a single named workflow for the pipeline
// See: https://github.com/nf-core/rnaseq/issues/619
//
workflow {
    QBIC_RNADESEQ ()
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
