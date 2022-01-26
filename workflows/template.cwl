class: Workflow
cwlVersion: v1.2
id: vlbi
label: vlbi

inputs:
  - id: msin
    type: 'Directory[]'
  - id: solset
    type: File
    doc: The solution set from the prefactor pipeline.
  - id: filter_baselines
    type: string?
    default: "*&"

outputs:
  - id: log_file
    outputSource: check_station_mismatch/logfile
    type: File[]

steps:
  - id: check_station_mismatch
    in:
      - id: step_msin
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

requirements:
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
