class: Workflow
cwlVersion: v1.2
id: vlbi-setup
label: vlbi-setup

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
    - id: download_cats
      in:
        - id: msin
          source: msin
      out:
        - id: best_delay_catalogue
        - id: logfile
      run: ../steps/download_cats.cwl
      label: download_cats
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
    - id: concat_logfiles_prep_target
      label: concat_logfiles_prep_target
      in:
        - id: file_list
          linkMerge: merge_flattened
          source:
            - prep_target/logfiles
        - id: file_prefix
          default: dp3_prep_target
      out:
        - id: output
      run: ../steps/concatenate_files.cwl
    - id: save_logfiles
      in:
        - id: files
          linkMerge: merge_flattened
          source:
            - check_station_mismatch/logfile
            - download_cats/logfile 
            - concat_logfiles_prep_target/output
        - id: sub_directory_name
          default: logs
      out:
        - id: dir
      run: ../steps/collectfiles.cwl
      label: save_logfiles

outputs:
    - id: logdir
      outputSource: save_logfiles/dir
      type: Directory
    - id: best_delay_cats
      outputSource: download_cats/best_delay_catalogue
      type: File
    - id: parset
      outputSource: dp3_make_parset/parset
      type: File
    - id: msout
      outputSource: prep_target/msout
      type: Directory[]
