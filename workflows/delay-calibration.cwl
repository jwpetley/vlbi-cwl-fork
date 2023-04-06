class: Workflow
cwlVersion: v1.2
id: delay-calibration
label: delay-calibration

requirements:
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement

inputs:
    - id: msin
      type: Directory[]
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
    - id: reference_stationSB
      type: int?
      default: 104
    - id: number_cores
      type: int?
      default: 12
      doc: Number of cores to use per job for tasks with high I/O or memory.
    - id: max_dp3_threads
      type: int?
      default: 5
      doc: The number of threads per DP3 process.

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
        - id: number_cores
          source: number_cores
      out:
        - id: parset
        - id: delay_calibrators
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
        - id: firstSB
          source: reference_stationSB
        - id: max_dp3_threads
          source: max_dp3_threads
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
          source: setup/delay_calibrators
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
        - id: max_dp3_threads
          source: max_dp3_threads
      out:
        - id: msout
        - id: solutions
        - id: pictures
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
    outputSource: setup/delay_calibrators
    type: File

  - id: logs
    outputSource: store_logs/dir
    type: Directory

  - id: pictures
    outputSource: phaseup/pictures
    type: File[]

  - id: solutions
    outputSource: phaseup/solutions
    type: File[]

#  - id: summary_file
#    outputSource: phaseup-concat.cwl
#    type: File
