class: Workflow
cwlVersion: v1.2
id: split-directions
label: split-directions

requirements:
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: ScatterFeatureRequirement

inputs:
    - id: msin
      type:
        type: array
        items:
          type: array
          items: Directory
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
    - id: numbands
      type: int?
      default: -1
      doc: The number of bands to process. -1 means all bands.
    - id: do_flagging
      type: boolean?
      default: false
      doc: Whether to flag the data before splitting.


steps:

    # - id: target_phaseup
    #   label: target_phaseup
    #   in:
    #     - id: msin
    #       source: msin
    #     - id: image_cat
    #       source: image_cat
    #     - id: delay_solset
    #       source: delay_solset
    #     - id: number_cores
    #       source: number_cores
    #   out: 
    #     - id: parset
    #   run: ../steps/target_phaseup.cwl
    #   scatter: msin

    # - id: dp3_target_phaseup
    #   label: dp3_target_phaseup
    #   in:
    #     - id: msin
    #       source: msin
    #     - id: parset
    #       source: target_phaseup/parset
    #     - id: delay_solset
    #       source: delay_solset
    #   out:
    #     - id: msout
    #   run: ../steps/dp3_target_phaseup.cwl
    #   scatter: [msin, parset]
    #   scatterMethod: dotproduct

    - id: order_by_direction
      label: order_by_direction
      in:
        - id: msin
          source: msin
      out: 
        - id: msout
      run: ../steps/order_by_direction.cwl

    - id: sort_concatmap
      label: sort_concatmap
      in:
        - id: msin
          source: order_by_direction/msout
        - id: numbands
          source: numbands
      out: 
        - id: filenames
        - id: groupnames
      run: ../steps/sort_concatmap.cwl
      scatter: msin

    - id: flatten_groupnames
      label: flatten_groupnames
      in:
        - id: nestedarray
          source: sort_concatmap/groupnames
      out:
        - id: flattenedarray
      run: ../steps/flatten.cwl
    
    # - id: dp3_target_concat
    #   label: dp3_target_concat
    #   in:
    #     - id: msin
    #       source: order_by_direction/msout
    #     - id: msin_filenames
    #       source: sort_concatmap/filenames
    #     - id: msout_name
    #       source: flatten_groupnames/flattenedarray
    #   out:
    #     - id: msout
    #   run: ../steps/dp3_concat.cwl
    #   scatter: [msin, msin_filenames, msout_name]
    #   scatterMethod: dotproduct

    # - id: concatenation
    #   label: concatenation
    #   in:
    #     - id: msin
    #       source: order_by_direction/msout
    #     - id: groups_specification
    #       source: sort_concatmap/filenames
    #     - id: group_id
    #       source: flatten_groupnames/flattenedarray
    #     - id: do_flagging
    #       source: do_flagging
    #   out:
    #     - id: msout
    #   run: ./subworkflows/concatenation.cwl
    #   scatter: [msin, groups_specification, group_id]
    #   scatterMethod: dotproduct


    # - id: target_selfcal
    #   label: target_selfcal
    #   in:
    #     - id: msin
    #       source: dp3_target_concat/msout
    #     - id: delay_solset
    #       source: delay_solset
    #     - id: number_cores
    #       source: number_cores
    #     - id: max_dp3_threads
    #       source: max_dp3_threads
    #   out:
    #     - id: msout
    #       source: msout
    #   run: ../steps/target_selfcal.cwl
    #   scatter: msin

outputs:
    # - id: groupnames
    #   type: 
    #     type: array 
    #     items:
    #       type: array
    #       items: string
    #   outputSource: sort_concatmap/groupnames
    - id: filenames
      type: File[]
      outputSource: sort_concatmap/filenames
    - id: groupnames
      type: string[]
      outputSource: flatten_groupnames/flattenedarray
    - id: ordered_array
      type: 
        type: array 
        items:
          type: array
          items: Directory
      outputSource: order_by_direction/msout
    # - id: msout
    #   type: Directory[]
    #   outputSource: concatenation/msout 


    