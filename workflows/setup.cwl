class: Workflow
cwlVersion: v1.2
id: vlbi-setup
label: vlbi-setup

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
    - id: min_separation
      type: int?
      default: 30
    - id: number_cores
      type: int?
      default: 12
    - id: max_dp3_threads
      type: int?
      default: 5
      doc: The maximum number of threads DP3 should use per process.

requirements:
    - class: SubworkflowFeatureRequirement
    - class: MultipleInputFeatureRequirement
    - class: ScatterFeatureRequirement

steps:
    - id: check_station_mismatch
      in:
        - id: msin
          source: msin
        - id: solset
          source: solset
        - id: filter_baselines
          source: filter_baselines
      out:
        - id: filter_out
        - id: logfile
      run: ../steps/check_station_mismatch.cwl
      label: check_station_mismatch
    - id: check_ateam_separation
      in: 
        - id: ms
          source:
            - msin
        - id: min_separation
          source: min_separation
      out:
        - id: output_image
        - id: output_json
        - id: logfile
      run: ../steps/check_ateam_separation.cwl
      label: check_Ateam_separation
    - id: dp3_make_parset
      in:
        - id: flag_baselines
          source: flag_baselines
        - id: station_mismatch
          source: check_station_mismatch/filter_out
        - id: solset
          source: solset
        - id: phasesol
          source: phasesol
      out:
        - id: parset
      run: ../steps/dp3_make_parset.cwl
    - id: clip_A-team
      in:
        - id: parset
          source: dp3_make_parset/parset
        - id: msin
          linkMerge: merge_flattened
          source: 
            - msin
        - id: solset
          source: solset
        - id: number_cores
          source: number_cores
        - id: max_dp3_threads
          source: max_dp3_threads
      out:
        - id: logfiles
        - id: flag_statistics_before
        - id: flag_statistics_after
        - id: msout
      run: ./subworkflows/clip_A-team.cwl
      scatter: msin
      label: clip_A-team
    - id: concat_logfiles_clip_A-team
      label: concat_logfiles_clip_A-team
      in:
        - id: file_list
          linkMerge: merge_flattened
          source:
            - clip_A-team/logfiles
        - id: file_prefix
          default: clip_A-team
      out:
        - id: output
      run: ../steps/concatenate_files.cwl
    - id: initial_flags_join
      in:
        - id: flagged_fraction_dict
          source:
            - clip_A-team/flag_statistics_before
        - id: filter_station
          default: ''
        - id: state
          default: initial
      out:
        - id: flagged_fraction_antenna
        - id: logfile
      run: ../steps/findRefAnt_join.cwl
      label: initial_flags_join
    - id: prep_target_flags_join
      in:
        - id: flagged_fraction_dict
          source:
            - clip_A-team/flag_statistics_after
        - id: filter_station
          default: ''
        - id: state
          default: prep_target
      out:
        - id: flagged_fraction_antenna
        - id: logfile
      run: ../steps/findRefAnt_join.cwl
      label: prep_target_flags_join
    - id: save_logfiles
      in:
        - id: files
          linkMerge: merge_flattened
          source:
            - check_station_mismatch/logfile
            - concat_logfiles_clip_A-team/output
            - check_ateam_separation/logfile
        - id: sub_directory_name
          default: setup
      out:
        - id: dir
      run: ../steps/collectfiles.cwl
      label: save_logfiles

outputs:
    - id: logdir
      outputSource: save_logfiles/dir
      type: Directory
    - id: parset
      outputSource: dp3_make_parset/parset
      type: File
    - id: msout
      outputSource: clip_A-team/msout
      type: Directory[]
    - id: initial_flags
      outputSource: initial_flags_join/flagged_fraction_antenna
      type: File
    - id: prep_target_flags
      outputSource: prep_target_flags_join/flagged_fraction_antenna
      type: File
    - id: check_Ateam_separation_file
      outputSource: check_ateam_separation/output_json
      type: File
