class: CommandLineTool
cwlVersion: v1.2
id: make_parset
label: make_parset

baseCommand:
  - cp

arguments:
  - prefix: ''
    shellQuote: false
    position: 0
    valueFrom: input.parset
  - prefix: ''
    shellQuote: false
    position: 0
    valueFrom: dp3.parset

inputs:
  - id: flag_baselines
    type: string?
    default: "[]"
    doc: flag baseline pattern, eg "[ CS013HBA*&&* ]".
  - id: station_mismatch
    type: string?
    default: "*&"
    doc: Filter of mismatches between solset and MSs.
  - id: solset
    type: File
    doc: The solution set from the prefactor pipeline.
  - id: phasesol
    type: string?
    default: TGSSphase

outputs:
  - id: parset
    type: File
    outputBinding:
      glob: dp3.parset

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: input.parset
        entry: |+
          steps                               =   [flag,flagamp,filter,applyPA,applybandpass,applyclock,applybeam,applyRM,applyphase,count]
          #
          numthreads                          =   2
          #
          msin.datacolumn                     =   DATA
          msin.baseline                       =   $(inputs.station_mismatch)
          #
          msout                               =   .
          msout.storagemanager                =   "Dysco"
          msout.datacolumn                    =   DATA
          msout.writefullresflag              =   False
          #
          flag.type                           =   preflagger
          flag.baseline                       =   $(inputs.flag_baselines)
          #
          flagamp.type                        =   preflagger
          flagamp.amplmin                     =   1e-30
          #p
          filter.type                         =   filter
          filter.baseline                     =   $(inputs.station_mismatch)
          filter.remove                       =   true
          #
          applyPA.type                        =   applycal
          applyPA.correction                  =   polalign
          applyPA.solset                      =   calibrator
          #
          applybandpass.type                  =   applycal
          applybandpass.correction            =   bandpass
          applybandpass.updateweights         =   true
          applybandpass.solset                =   calibrator
          #
          applyclock.type                     =   applycal
          applyclock.correction               =   clock
          applyclock.solset                   =   calibrator
          #
          applybeam.type                      =   applybeam
          applybeam.usechannelfreq            =   true
          applybeam.updateweights             =   true
          #
          applyRM.type                        =   applycal
          applyRM.correction                  =   RMextract
          applyRM.solset                      =   target
          #
          applyphase.type                     =   applycal
          applyphase.correction               =   $(inputs.phasesol)
          applyphase.solset                   =   target
          #
