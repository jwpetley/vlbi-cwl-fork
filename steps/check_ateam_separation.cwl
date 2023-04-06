class: CommandLineTool
cwlVersion: v1.2
id: check_ateam_separation
baseCommand:
  - check_Ateam_separation.py
inputs:
  - id: ms
    type:
      - Directory
      - type: array
        items: Directory
    inputBinding:
      position: 0
    doc: Input measurement set
  - default: Ateam_separation.png
    id: output_image_name
    type: string?
    inputBinding:
      position: 2
      prefix: --outputimage
  - id: min_separation
    type: int?
    inputBinding:
      position: 1
      prefix: --min_separation
outputs:
  - id: output_image
    doc: Output image
    type: File
    outputBinding:
      glob: $(inputs.output_image_name)
  - id: output_json
    doc: Output JSON
    type: File
    outputBinding:
      glob: '*.json'
  - id: logfile
    type: File
    outputBinding:
      glob: Ateam_separation.log
label: check_Ateam_separation
hints:
  - class: DockerRequirement
    dockerPull: astronrd/linc
  - class: InlineJavascriptRequirement
stdout: Ateam_separation.log
