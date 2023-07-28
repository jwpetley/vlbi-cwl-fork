class: Workflow
cwlVersion: v1.2
id: split-directions
label: split-directions
doc: This is a large workflow for the LOFAR-VLBI pipeline that 
  splits a LOFAR Measurement Set into various target directions. 
  This step should be run after the delay calibration workflow. 
  The inputs below should be specified but we endeavour to create a script
  that will create suitable YAML input for the user.
   

requirements:
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: ScatterFeatureRequirement

inputs:
    - id: msin
      type: Directory[]
      doc: The input MSs to split.
    - id: delay_solset
      type: File
      doc: The solution set from the delay calibrator workflow.
    - id: image_cat
      type: File
      doc: The image catalogue to split to.
      default: lotss_catalogue.csv  
    - id: number_cores
      type: int?
      default: 16
      doc: Number of cores to use per job for tasks with high I/O or memory.
    - id: max_dp3_threads
      type: int?
      default: 4
      doc: Number of cores to use per job for tasks with high I/O or memory.
    - id: numbands
      type: int?
      default: -1
      doc: The number of bands to process. -1 means all bands.
    - id: do_flagging
      type: boolean?
      default: false
      doc: Whether to flag the data before splitting.
    - id: truncateLastSBs
      type: boolean?
      default: true
      doc: Whether to truncate the last subbands of the MSs to the same length.
    - id: datacolumn_in
      type: string?
      default: DATA
      doc: The datacolumn to use as input for the concatenation.
    - id: do_selfcal
      type: boolean?
      default: false
      doc: Whether to do selfcal on the direction concat MSs.
    - id: configfile
      type: File
      doc: The configuration file for the workflow.
    - id: h5merger
      type: Directory
      doc: The h5merger directory.
    - id: selfcal
      type: Directory
      doc: The selfcal directory.

steps:

    - id: target_phaseup
      label: target_phaseup
      in:
        - id: msin
          source: msin
        - id: image_cat
          source: image_cat
        - id: delay_solset
          source: delay_solset
        - id: number_cores
          source: number_cores
      out: 
        - id: parset
      run: ../steps/target_phaseup.cwl
      scatter: msin

    - id: dp3_target_phaseup
      label: dp3_target_phaseup
      in:
        - id: msin
          source: msin
        - id: parset
          source: target_phaseup/parset
        - id: delay_solset
          source: delay_solset
        - id: max_dp3_threads
          source: max_dp3_threads
      out:
        - id: msout
      run: ../steps/dp3_target_phaseup.cwl
      scatter: [msin, parset]
      scatterMethod: dotproduct

    - id: order_by_direction
      label: order_by_direction
      in:
        - id: msin
          source: dp3_target_phaseup/msout
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
        - id: truncateLastSBs
          source: truncateLastSBs
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
    

    - id: concatenation
      label: concatenation
      in:
        - id: msin
          source: order_by_direction/msout
        - id: groups_specification
          source: sort_concatmap/filenames
        - id: group_id
          source: flatten_groupnames/flattenedarray
        - id: do_flagging
          source: do_flagging
        - id: datacolumn_in
          source: datacolumn_in
      out:
        - id: msout
      run: ./subworkflows/concatenation.cwl
      scatter: [msin, groups_specification, group_id]
      scatterMethod: dotproduct

    - id: target_selfcal
      label: target_selfcal
      in:
        - id: msin
          source: concatenation/msout
        - id: configfile
          source: configfile
        - id: h5merger
          source: h5merger
        - id: selfcal
          source: selfcal
        - id: do_selfcal
          source: do_selfcal
      out:
        - id: images
        - id: fits_images
      when: $(inputs.do_selfcal)
      run: ../steps/target_solve.cwl
      scatter: msin

outputs:
    - id: msout_phaseup
      type: 
        type: array 
        items:
          type: array
          items: Directory
      outputSource: dp3_target_phaseup/msout
    - id: msout_concat
      type: Directory[] 
      outputSource: concatenation/msout
    - id: images
      type: 
        type: array 
        items:
          type: array
          items: File
      outputSource: target_selfcal/images
      pickValue: all_non_null
    - id: fits_images
      type: 
        type: array 
        items:
          type: array
          items: File
      outputSource: target_selfcal/fits_images
      pickValue: all_non_null

    