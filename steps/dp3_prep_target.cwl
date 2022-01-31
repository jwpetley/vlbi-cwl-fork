class: CommandLineTool
cwlVersion: v1.2
id: dp3_prep_target
label: dp3_prep_target

baseCommand: DP3

inputs:
    # user specific inputs
    - id: filter_stations
      type: string
      doc: List of stations that have been pre-flagged, or international stations.
    - id: solset
      type: File
      doc: Prefactor solution set.
    - id: flag_baselines
      doc: Specify which baselines are flagged.
      type: string?
      default: "[]"
    - id: phasesol
      doc: Phase solution information.
      type: string?
      default: "TGSSphase"
    # pipeline specific inputs
    - id: 

ndppp_prep_target.control.max_per_node                  = {{ num_proc_per_node_limit }}
    - id: error_tolerance
      type boolean?
      default: false
      doc: Determines whether the step stops if any subband fails.
    - id: thread_number?
      type: int
      default: 2
      doc: Number of threads used in the step?
    -
ndppp_prep_target.argument.msin                         = createmap_target.output.mapfile  
ndppp_prep_target.argument.msin.datacolumn              = DATA
ndppp_prep_target.argument.msin.baseline                = check_station_mismatch.output.filter

ndppp_prep_target.argument.msout.datacolumn             = DATA
ndppp_prep_target.argument.msout.storagemanager         = dysco
ndppp_prep_target.argument.msout.writefullresflag       = False
ndppp_prep_target.argument.msout                        = .

ndppp_prep_target.argument.steps                        = [flag,flagamp,filter,applyPA,applybandpass,applyclock,applybeam,applyRM,applyphase,count]
ndppp_prep_target.argument.flag.type                    = preflagger
ndppp_prep_target.argument.flag.baseline                = {{ flag_baselines }}
ndppp_prep_target.argument.flagamp.type                 = preflagger
ndppp_prep_target.argument.flagamp.amplmin              = 1e-30

ndppp_prep_target.argument.filter.type                  = filter
ndppp_prep_target.argument.filter.baseline              = check_station_mismatch.output.filter
ndppp_prep_target.argument.filter.remove                = true

ndppp_prep_target.argument.applyclock.type              = applycal
ndppp_prep_target.argument.applyclock.parmdb            = {{ solutions }}
ndppp_prep_target.argument.applyclock.correction        = clock
ndppp_prep_target.argument.applyclock.solset            = calibrator

ndppp_prep_target.argument.applyPA.type                 = applycal
ndppp_prep_target.argument.applyPA.parmdb               = {{ solutions }}
ndppp_prep_target.argument.applyPA.correction           = polalign
ndppp_prep_target.argument.applyPA.solset               = calibrator

ndppp_prep_target.argument.applybandpass.type           = applycal
ndppp_prep_target.argument.applybandpass.parmdb         = {{ solutions }}
ndppp_prep_target.argument.applybandpass.correction     = bandpass
ndppp_prep_target.argument.applybandpass.updateweights  = True
ndppp_prep_target.argument.applybandpass.solset         = calibrator

ndppp_prep_target.argument.applybeam.type               = applybeam
ndppp_prep_target.argument.applybeam.usechannelfreq     = True
ndppp_prep_target.argument.applybeam.updateweights      = True

ndppp_prep_target.argument.applyRM.type                 = applycal
ndppp_prep_target.argument.applyRM.parmdb               = {{ solutions }}
ndppp_prep_target.argument.applyRM.correction           = RMextract
ndppp_prep_target.argument.applyRM.solset               = target

ndppp_prep_target.argument.applyphase.type              = applycal
ndppp_prep_target.argument.applyphase.parmdb            = {{ solutions }}
ndppp_prep_target.argument.applyphase.correction        = {{ phasesol }}
ndppp_prep_target.argument.applyphase.solset            = target

outputs:
    - id: msout
      doc: Output measurement set.
      type: Directory
    - id: logfile
      type: File[]
      outputBinding:
        glob: 'DP3*.log'

stdout: DP3.log
stderr: DP3_err.log

hints:
  DockerRequirement:
    dockerPull: vlbi-cwl
