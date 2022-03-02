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
          type: File
        - id: best_delay_cats
          type: File
        - id: logfiles
          type: File[]
      run: ./setup.cwl

#    - id: a-teamclip
#      in:
#        - id: input1
#          source: input1
#        - id: input2
#          source: input2
#      out:
#        - id: output1
#      run: ../steps/step1.cwl
#      label: step1
#
#    - id: concatenate
#      in:
#        - id: input1
#          source: input1
#        - id: input2
#          source: input2
#      out:
#        - id: output1
#      run: ../steps/step1.cwl
#      label: step1
#    
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
#    
#    - id: aoflagging
#      in:
#        - id: input1
#          source: input1
#        - id: input2
#          source: input2
#      out:
#        - id: output1
#      run: ../steps/step1.cwl
#      label: step1
#    
#    - id: phaseup
#      in:
#        - id: input1
#          source: input1
#        - id: input2
#          source: input2
#      out:
#        - id: output1
#      run: ../steps/step1.cwl
#      label: step1
#    
#    - id: concatenate
#      in:
#        - id: input1
#          source: input1
#        - id: input2
#          source: input2
#      out:
#        - id: output1
#      run: ../steps/step1.cwl
#      label: step1
#
#    - id: cleanup
#      in:
#        - id: input1
#          source: input1
#        - id: input2
#          source: input2
#      out:
#        - id: output1
#      run: ../steps/step1.cwl
#      label: step1

outputs:
  - id: output1
    outputSource: step1/output1
    type: Directory
