class: Workflow
cwlVersion: v1.2
id: split-directions
label: split-directions

requirements:
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement

inputs:
    - id: msin
      type: Directory[]
    - id: delay_solset
      type: File
      doc: The solution set from the delay calibrator workflow.
    - id: image_cat
      type: File
      doc: The image catalogue to split to.
      default: lotss_catalogue.csv  
    - id: number_cores
      type: int?
      default: 12
      doc: Number of cores to use per job for tasks with high I/O or memory.
    - id: max_dp3_threads
      type: int?
      default: 5
      doc: The number of threads per DP3 process.


steps:
    - id: target_phaseup
      label: target_phaseup
      in:
        - id: msin
          source: msin
        - id: number_cores
          source: number_cores
        - id: max_dp3_threads
          source: max_dp3_threads
      out: 
        id: target_phaseup_dir
      run: ../steps/target_phaseup.cwl


    