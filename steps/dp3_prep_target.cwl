class: CommandLineTool
cwlVersion: v1.2
id: template_id
label: template_label

baseCommand: echo

inputs:
    - id: hello
      type: string?
      default: 'test'#'$PREFACTOR_DATA_ROOT'

outputs:
    []

#requirements:
hints:
  DockerRequirement:
    dockerPull: vlbi-cwl
