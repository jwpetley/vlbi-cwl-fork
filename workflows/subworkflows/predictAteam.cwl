class: Workflow
cwlVersion: v1.2
id: predictAteam
label: predictAteam

inputs:
  - id: msin
    type: Directory
    doc: Input Measurement Set
  - id: solset
    type: File
    doc: LINC target solutions file.
 
steps:
    - id: prep_target
      in:
        - id: parset
          source: dp3_make_parset/parset
        - id: msin
          linkMerge: merge_flattened
          source: 
            - msin
        - id: solset
          source: solset
      out:
        - id: logfiles
        - id: msout
      run: ./subworkflows/prep_target.cwl
      scatter: msin
      label: prep_target

  - id: predict
    in:
      - id: msin
        source: msin
    out:
      - id: msout
      - id: logfile
    run: ../../steps/predict.cwl
    label: predict
  - id: Ateamcliptar
    in:
      - id: msin
        source: predict/msout
    out:
      - id: msout
      - id: logfile
      - id: output
    run: ../../steps/Ateamclipper.cwl
    label: Ateamcliptar
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
  - id: concat_logfiles_cliptar
    in:
      - id: file_list
        linkMerge: merge_flattened
        source: Ateamcliptar/logfile
      - id: file_prefix
        default: Ateamcliptar
    out:
      - id: output
    run: ../../steps/concatenate_files.cwl
    label: concat_logfiles_cliptar

outputs:
  - id: predict_logfile
    outputSource: concat_logfiles_predict/output
    type: File
  - id: cliptar_logfile
    outputSource: concat_logfiles_cliptar/output
    type: File
  - id: msout
    outputSource: Ateamcliptar/msout
    type: Directory

requirements:
  - class: MultipleInputFeatureRequirement
