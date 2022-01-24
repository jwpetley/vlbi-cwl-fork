class: Workflow
cwlVersion: v1.2
id: vlbi
label: vlbi
inputs:
  - id: msin
    type: 'Directory[]'
outputs:
  - id: solutions
    outputSource:
      - vlbi/solutions
    type: File
steps:
  - id: VLBI
    in:
      - id: msin
        source:
          - msin
    out:
      - id: solutions
    run: ./vlbi.cwl
    label: vlbi
requirements:
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
