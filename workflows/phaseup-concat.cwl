class: Workflow
cwlVersion: v1.2
id: phaseup-concat
label: phaseup-concat

inputs:
  - id: msin
    type: Directory[]
    doc: Input measurement sets.
  - id: delay_calibrator
    type: File
    doc: Catalogue file with information on in-field calibrator.
  - id: numbands
    type: int?
    default: -1
    doc: The number of files that have to be grouped together.
  - id: DP3fill
    type: boolean?
    default: True
    doc: Add dummy file names for missing frequencies, so that DP3 can fill the data with flagged dummy data.
  - id: stepname
    type: string?
    default: '.dp3-phaseup-concat'
    doc: Add this stepname into the file names of the output files.
  - id: mergeLastGroup
    type: boolean?
    default: False
    doc: Add dummy file names for missing frequencies, so that DP3 can fill the data with flagged dummy data.
  - id: truncateLastSBs
    type: boolean?
    default: False
    doc: Add dummy file names for missing frequencies, so that DP3 can fill the data with flagged dummy data.
  - id: firstSB
    type: int?
    default: null
    doc: If set, reference the grouping of files to this station subband.
  - id: do_flagging
    type: boolean?
    default: false
  - id: configfile
    type: File
    doc: Settings for the delay calibration in delay_solve.
  - id: selfcal
    type: Directory
    doc: Path of external calibration scripts.
  - id: h5merger
    type: Directory
    doc: External LOFAR helper scripts for mergin h5 files.

  - id: flags
    type: File[]
  - id: pipeline
    type: string?
    default: 'VLBI'
  - id: run_type
    type: string?
    default: ''
  - id: filter_baselines
    type: string?
    default: '[CR]S*&'
  - id: bad_antennas
    type: string?
    default: '[CR]S*&'
  - id: compare_stations_filter
    type: string?
    default: '[CR]S*&'
  - id: check_Ateam_separation.json
    type: File
  - id: clip_sources
    type: string[]?
    default: []
  - id: removed_bands
    type: string[]?
    default: []
  - id: min_unflagged_fraction
    type: float?
    default: 0.5
  - id: refant
    type: string?
    default: 'CS001HBA0'


steps:
  - id: prep_delay
    in:
      - id: delay_calibrator
        source: delay_calibrator
    out:
      - id: source_id
      - id: coordinates
      - id: logfile
    run: ../steps/prep_delay.cwl
    label: prep_delay
  - id: dp3_phaseup
    in:
      - id: msin
        source: msin
      - id: phase_center
        source: prep_delay/coordinates
      - id: beam_direction
        source: prep_delay/coordinates
      - id: msout_name
        source: prep_delay/source_id
    out:
      - id: msout
      - id: logfile
      - id: errorfile
    run: ../steps/dp3_phaseup.cwl
    scatter: msin
    label: dp3_phaseup
  - id: sort_concatenate
    in:
      - id: msin
        source: dp3_phaseup/msout
      - id: numbands
        source: numbands
      - id: DP3fill
        source: DP3fill
      - id: stepname
        source: stepname
      - id: mergeLastGroup
        source: mergeLastGroup
      - id: truncateLastSBs
        source: truncateLastSBs
      - id: firstSB
        source: firstSB
    out:
      - id: filenames
      - id: groupnames
      - id: logfile
    run: ../steps/sort_concatmap.cwl
    label: sort_concatmap
  - id: phaseup_concatenate
    in:
      - id: msin
        source:
          - dp3_phaseup/msout
      - id: group_id
        source: sort_concatenate/groupnames
      - id: groups_specification
        source: sort_concatenate/filenames
      - id: do_flagging
        source: do_flagging
    out:
      - id: msout
      - id: concat_flag_statistics
      - id: concatenate_logfile
      - id: aoflag_logfile
    run: ./subworkflows/concatenation.cwl
    scatter: group_id
    label: phaseup_concatenate
  - id: phaseup_flags_join
    in:
      - id: flagged_fraction_dict
        source:
          - phaseup_concatenate/concat_flag_statistics
      - id: filter_station
        default: ''
      - id: state
        default: phaseup_concat
    out:
      - id: flagged_fraction_antenna
      - id: logfile
    run: ../steps/findRefAnt_join.cwl
    label: prep_target_flags_join
  - id: concat_logfiles_phaseup
    label: concat_logfiles_phaseup
    in:
      - id: file_list
        linkMerge: merge_flattened
        source:
          - dp3_phaseup/logfile
      - id: file_prefix
        default: dp3_phaseup
    out:
      - id: output
    run: ../steps/concatenate_files.cwl
  - id: concat_logfiles_concatenate
    label: concat_logfiles_concatenate
    in:
      - id: file_list
        linkMerge: merge_flattened
        source:
          - phaseup_concatenate/concatenate_logfile
      - id: file_prefix
        default: phaseup_concatenate
    out:
      - id: output
    run: ../steps/concatenate_files.cwl
  - id: delay_cal_model
    label: delay_cal_model
    in:
      - id: msin
        source: phaseup_concatenate/msout
        valueFrom: $(self[0])
      - id: delay_calibrator
        source: delay_calibrator
    out:
      - id: msout
      - id: logfile
    run: ../steps/delay_cal_model.cwl

  - id: delay_solve
    in:
      - id: msin
        source: delay_cal_model/msout
        #source: phaseup_concatenate/msout
        #valueFrom: $(self[0])
      - id: configfile
        source: configfile
      - id: selfcal
        source: selfcal
      - id: h5merger
        source: h5merger
    out:
      - id: h5parm
      - id: logfile
    run: ../steps/delay_solve.cwl
    label: delay_solve

#  - id: summary
#    in:
#      - id: flagFiles
#        source:
#          - flags
#          - prep_target_flags_join/flagged_fraction_antenna
#        linkMerge: merge_flattened
#      - id: pipeline
#        source: pipeline
#      - id: run_type
#        source: run_type
#      - id: filter
#        source: filter_baselines
#      - id: bad_antennas
#        source:
#          - bad_antennas
#          - compare_stations_filter
#        valueFrom: $(self.join(''))
#      - id: Ateam_separation_file
#        source: check_Ateam_separation.json
#      - id: solutions
#        source: delay_solve/h5parm
#      - id: clip_sources
#        source: clip_sources
#        valueFrom: "$(self.join(','))"
#      - id: removed_bands
#        source: removed_bands
#        valueFrom: "$(self.join(','))"
#      - id: min_unflagged_fraction
#        source: min_unflagged_fraction
#      - id: refant
#        source: refant
#    out:
#      - id: summary_file
#      - id: logfile
#    run: ../steps/summary.cwl
#    label: summary

  - id: save_logfiles
    in:
      - id: files
        linkMerge: merge_flattened
        source:
          - prep_delay/logfile
          - concat_logfiles_phaseup/output 
          - sort_concatenate/logfile
          - concat_logfiles_phaseup/output
          - delay_cal_model/logfile
          - delay_solve/logfile
#          - summary/logfile
      - id: sub_directory_name
        default: phaseup
    out:
      - id: dir
    run: ../steps/collectfiles.cwl
    label: save_logfiles

outputs:
  - id: msout
    outputSource: delay_cal_model/msout
    type: Directory
  - id: solutions
    outputSource: delay_solve/h5parm
    type: File[]
  - id: phaseup_flags
    type: File
    outputSource: phaseup_flags_join/flagged_fraction_antenna
  - id: logdir
    outputSource: save_logfiles/dir
    type: Directory
#  - id: summary_file
#    type: File
#    outputSource: summary/summary_file


requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
