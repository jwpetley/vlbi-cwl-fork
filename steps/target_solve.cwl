cwlVersion: v1.2
class: CommandLineTool
id: delay_solve
label: delay_solve

baseCommand:
    - python3
    - delay_solve.py

inputs:
    - id: msin
      type: Directory
      doc: Delay calibrator measurement set.
    - id: configfile
      type: File
      doc: Configuration options for self-calibration.
    - id: selfcal
      type: Directory
      doc: External self-calibration script.
    - id: h5merger
      type: Directory
      doc: External LOFAR helper scripts for merging h5 files.

outputs:
    - id: images
      type: File[]
      outputBinding:
        glob: '*.png'
    - id: fits_images
      type: File[]
      outputBinding:
        glob: '*MFS-image.fits'
    - id: logfile
      type: File[]
      outputBinding:
         glob: target_solve*.log

requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.configfile)
      - entry: $(inputs.msin)
#      - entry: $(inputs.h5merger)
      - entryname: delay_solve.py
        entry: |
          import subprocess
          import sys
          import json

          inputs = json.loads(r"""$(inputs)""")
            
          msin = inputs['msin']['basename']
          configfile = inputs['configfile']['path']
          #skymodel = inputs['skymodel']['path']
          selfcal = inputs['selfcal']['path']
          h5merge = inputs['h5merger']['path']

          imagename = msin.split('.')[0]

          subprocess.run(f'python3 {selfcal}/facetselfcal.py {msin} --helperscriptspath {selfcal} --helperscriptspathh5merge {h5merge} --auto --imagename {imagename}', shell = True)
          #.format(os.path.join(helperscriptspath,'facetselfcal.py'), msin ) )

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl
  - class: ResourceRequirement
    coresMin: 6

stdout: target_solve.log
stderr: target_solve_err.log
