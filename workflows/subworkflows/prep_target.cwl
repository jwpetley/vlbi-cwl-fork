class: Workflow
cwlVersion: v1.2
id: prep_target
label: prep_target

requirements:
    - class: InlineJavascriptRequirement
    - class: SubworkflowFeatureRequirement
    - class: StepInputExpressionRequirement
    - class: MultipleInputFeatureRequirement

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
        - id: msout_name
          source: msin
          valueFrom: $("out_"+self.basename)
        - id: solset
          source: solset
      out:
        - id: logfile
        - id: msout
        - id: flag_statistics_before
        - id: flag_statistics_after
      run: ../../steps/dp3_prep_target.cwl
    - id: concat_logfiles_prep_targ
      label: concat_logfiles_prep_target
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

outputs:
    - id: logfiles
      outputSource: 
        - concat_logfiles_prep_targ/output
      type: File
    - id: msout
      outputSource:
        - dp3_prep_target/msout
      type: Directory
    - id: flag_statistics_before
      outputSource:
        - dp3_prep_target/flag_statistics_before
      type: string
    - id: flag_statistics_after
      outputSource:
        - dp3_prep_target/flag_statistics_after
      type: string
