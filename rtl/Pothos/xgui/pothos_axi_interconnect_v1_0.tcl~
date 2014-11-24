# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  set Component_Name  [  ipgui::add_param $IPINST -name "Component_Name" -display_name {Component Name}]
  set_property tooltip {Component Name} ${Component_Name}
  #Adding Page
  set Page_0  [  ipgui::add_page $IPINST -name "Page 0" -display_name {Page 0}]
  set_property tooltip {Page 0} ${Page_0}
  set FIFO_SIZE  [  ipgui::add_param $IPINST -name "FIFO_SIZE" -parent ${Page_0} -display_name {Fifo Size}]
  set_property tooltip {Fifo Size} ${FIFO_SIZE}
  set NUM_LANES  [  ipgui::add_param $IPINST -name "NUM_LANES" -parent ${Page_0} -display_name {Num Lanes}]
  set_property tooltip {Num Lanes} ${NUM_LANES}
  set NUM_OUTPUTS  [  ipgui::add_param $IPINST -name "NUM_OUTPUTS" -parent ${Page_0} -display_name {Num Outputs}]
  set_property tooltip {Num Outputs} ${NUM_OUTPUTS}
  set NUM_INPUTS  [  ipgui::add_param $IPINST -name "NUM_INPUTS" -parent ${Page_0} -display_name {Num Inputs}]
  set_property tooltip {Num Inputs} ${NUM_INPUTS}
  set DATA_WIDTH  [  ipgui::add_param $IPINST -name "DATA_WIDTH" -parent ${Page_0} -display_name {Data Width} -widget comboBox]
  set_property tooltip {Data Width} ${DATA_WIDTH}


}

proc update_PARAM_VALUE.FIFO_SIZE { PARAM_VALUE.FIFO_SIZE } {
	# Procedure called to update FIFO_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FIFO_SIZE { PARAM_VALUE.FIFO_SIZE } {
	# Procedure called to validate FIFO_SIZE
	return true
}

proc update_PARAM_VALUE.NUM_LANES { PARAM_VALUE.NUM_LANES } {
	# Procedure called to update NUM_LANES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_LANES { PARAM_VALUE.NUM_LANES } {
	# Procedure called to validate NUM_LANES
	return true
}

proc update_PARAM_VALUE.NUM_OUTPUTS { PARAM_VALUE.NUM_OUTPUTS } {
	# Procedure called to update NUM_OUTPUTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_OUTPUTS { PARAM_VALUE.NUM_OUTPUTS } {
	# Procedure called to validate NUM_OUTPUTS
	return true
}

proc update_PARAM_VALUE.NUM_INPUTS { PARAM_VALUE.NUM_INPUTS } {
	# Procedure called to update NUM_INPUTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_INPUTS { PARAM_VALUE.NUM_INPUTS } {
	# Procedure called to validate NUM_INPUTS
	return true
}

proc update_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to update DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to validate DATA_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.DATA_WIDTH { MODELPARAM_VALUE.DATA_WIDTH PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_WIDTH}] ${MODELPARAM_VALUE.DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.NUM_INPUTS { MODELPARAM_VALUE.NUM_INPUTS PARAM_VALUE.NUM_INPUTS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_INPUTS}] ${MODELPARAM_VALUE.NUM_INPUTS}
}

proc update_MODELPARAM_VALUE.NUM_OUTPUTS { MODELPARAM_VALUE.NUM_OUTPUTS PARAM_VALUE.NUM_OUTPUTS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_OUTPUTS}] ${MODELPARAM_VALUE.NUM_OUTPUTS}
}

proc update_MODELPARAM_VALUE.NUM_LANES { MODELPARAM_VALUE.NUM_LANES PARAM_VALUE.NUM_LANES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_LANES}] ${MODELPARAM_VALUE.NUM_LANES}
}

proc update_MODELPARAM_VALUE.FIFO_SIZE { MODELPARAM_VALUE.FIFO_SIZE PARAM_VALUE.FIFO_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FIFO_SIZE}] ${MODELPARAM_VALUE.FIFO_SIZE}
}

