class: Workflow
cwlVersion: v1.2
id: clipAteam
label: clipAteam

inputs:
  - id: input1
    type: 'Directory[]'

steps:
  - id: step1
    in:
      - id: input1
        source: input1
      - id: input2
        source: input2
    out:
      - id: output1
    run: ../steps/step1.cwl
    label: step1

outputs:
  - id: output1
    outputSource: step1/output1
    type: Directory

requirements:
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
