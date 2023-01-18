class: Workflow
cwlVersion: v1.2
id: delay-calibration
label: delay-calibration

requirements:
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement

inputs:
    - id: msin
      type: 'Directory[]'
    - id: solset
      type: File
      doc: The solution set from the prefactor pipeline.
    - id: filter_baselines
      type: string?
      default: "*&"
    - id: flag_baselines
      type: string?
      default: "[]"
    - id: phasesol
      type: string?
      default: TGSSphase

    - id: configfile
      type: File
      doc: Settings for the delay calibration in delay_solve.
    - id: selfcal
      type: Directory
      doc: Path of external calibration scripts.
    - id: h5merger
      type: Directory
      doc: External LOFAR helper scripts for mergin h5 files.


steps:
    - id: setup
      label: setup
      in:
        - id: msin
          source: msin
        - id: solset
          source: solset
        - id: filter_baselines
          source: filter_baselines
        - id: flag_baselines
          source: flag_baselines
        - id: phasesol
          source: phasesol
      out:
        - id: parset
        - id: best_delay_cats
        - id: logdir
        - id: msout
        - id: initial_flags
        - id: prep_target_flags
        - id: check_Ateam_separation_file
      run: ./setup.cwl

    - id: sort-concatenate-flag
      in:
        - id: msin
          source: setup/msout
      out:
        - id: logdir
        - id: concat_flags
        - id: msout
      run: ./concatenate-flag.cwl
      label: sort-concatenate-flag

#    - id: apply-ddf
#      in:
#        - id: input1
#          source: input1
#        - id: input2
#          source: input2
#      out:
#        - id: output1
#      run: ../steps/step1.cwl
#      label: step1
    
    - id: phaseup
      in:
        - id: msin
          source: sort-concatenate-flag/msout
        - id: delay_calibrator
          source: setup/best_delay_cats
        - id: configfile
          source: configfile
        - id: selfcal
          source: selfcal
        - id: h5merger
          source: h5merger
        - id: flags
          source:
            - setup/initial_flags
            - setup/prep_target_flags
            - sort-concatenate-flag/concat_flags
        - id: check_Ateam_separation.json
          source: setup/check_Ateam_separation_file
      out:
        - id: msout
        - id: solutions
        - id: phaseup_flags
        - id: logdir
#        - id: summary_file
      run: ./phaseup-concat.cwl
      label: phaseup
    
    - id: store_logs
      in:
        - id: files
          linkMerge: merge_flattened
          source:
            - setup/logdir
            - sort-concatenate-flag/logdir
            - phaseup/logdir
        - id: sub_directory_name
          default: logs
      out:
        - id: dir
      run: ../steps/collectfiles.cwl
      label: store_logs

outputs:
  - id: msout
    outputSource: sort-concatenate-flag/msout
    type: Directory[]

  - id: delay_cat
    outputSource: setup/best_delay_cats
    type: File

  - id: logs
    outputSource: store_logs/dir
    type: Directory

#  - id: summary_file
#    outputSource: phaseup-concat.cwl
#    type: File
