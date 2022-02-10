class: Workflow
cwlVersion: v1.2
id: prep_target
label: prep_target

requirements:
    - class: InlineJavascriptRequirement
    - class: SubworkflowFeatureRequirement
    - class: MultipleInputFeatureRequirement
    - class: InitialWorkDirRequirement
      listing:
        - entry: $(inputs.msin)
          writable: true

inputs:
    - id: parset
      type: File
    - id: msin
      type: Directory
    - id: solset
      type: File

steps:
    - id: dp3_prep_target
      label: dp3_prep_target
      in:
        - id: parset
          source: parset
        - id: msin
          source: msin
        - id: solset
          source: solset
      out:
        - id: logfile
      run: ../../steps/dp3_prep_target.cwl
    - id: concat_logfiles_prep_targ
      in:
        - id: file_list
          linkMerge: merge_flattened
          source:
            - dp3_prep_target/logfile
        - id: file_prefix
          default: dp3_prep_targ
      out:
        - id: output
      run: ../../steps/concatenate_files.cwl
      label: concat_logfiles_prep_target

outputs:
    - id: logfiles
      outputSource: 
        - concat_logfiles_prep_targ/output
      type: File
