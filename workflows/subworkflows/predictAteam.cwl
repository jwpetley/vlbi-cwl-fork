class: Workflow
cwlVersion: v1.2
id: predictAteam
label: predictAteam

inputs:
  - id: msin
    type: Directory
    doc: Input Measurement Set
 
        #linkMerge: merge_flattened
steps:
  - id: predict
    in:
      - id: msin
        source: msin
    out:
      - id: msout
      - id: logfile
    run: ../../steps/predict.cwl
    label: predict
  - id: concat_logfiles_predict
    in:
      - id: file_list
        linkMerge: merge_flattened
        source: predict/logfile
      - id: file_prefix
        default: predict
    out:
      - id: output
    run: ../../steps/concatenate_files.cwl
    label: concat_logfiles_predict

outputs:
  - id: logfiles
    outputSource: concat_logfiles_predict/output
    type: File
  - id: msout
    outputSource: predict/msout
    type: Directory

requirements:
#  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
