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
    source:
        - check_station_mismatch/logfile

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
        - id: logfile
        - id: filter_out
      run: ../steps/check_station_mismatch.cwl
      label: check_station_mismatch

requirements:
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
