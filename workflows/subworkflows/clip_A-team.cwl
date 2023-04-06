class: Workflow
cwlVersion: v1.2
id: clip_A-team
label: clip_A-team

requirements:
    - class: InlineJavascriptRequirement
    - class: StepInputExpressionRequirement

inputs:
    - id: parset
      doc: DP3 parset.
      type: File
    - id: msin
      doc: input measurement set.
      type: Directory
    - id: solset
      doc: H5 solutions file.
      type: File
    - id: number_cores
      type: int?
      default: 12
    - id: max_dp3_threads
      type: int?
      default: 5
      doc: The maximum number of threads DP3 should use per process.

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
    - id: predict
      in:
        - id: msin
          source: dp3_prep_target/msout
        - id: max_dp3_threads
          source: max_dp3_threads
      out:
        - id: msout
        - id: logfile
      run: ../../steps/predict.cwl
      label: predict
    - id: Ateamcliptar
      in:
        - id: msin
          source: predict/msout
        - id: number_cores
          source: number_cores
      out:
        - id: msout
        - id: logfile
        - id: output
      run: ../../steps/Ateamclipper.cwl
      label: Ateamcliptar
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
    - id: concat_logfiles_clip_A-team
      in:
        - id: file_list
          linkMerge: merge_flattened
          source:
            - concat_logfiles_prep_targ/output
            - concat_logfiles_predict/output
            - concat_logfiles_cliptar/output
        - id: file_prefix
          default: Ateamcliptar
      out:
        - id: output
      run: ../../steps/concatenate_files.cwl
      label: concat_logfiles_clip_A-team

outputs:
    - id: logfiles
      outputSource:
        - concat_logfiles_clip_A-team/output
      type: File
    - id: msout
      outputSource:
        - Ateamcliptar/msout
      type: Directory
    - id: flag_statistics_before
      outputSource:
        - dp3_prep_target/flag_statistics_before
      type: string
    - id: flag_statistics_after
      outputSource:
        - dp3_prep_target/flag_statistics_after
      type: string
