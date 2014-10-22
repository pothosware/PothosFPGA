# The Pothos Interconnect FPGA library

The PothosInterconnect library provides a top level interconnect module.
The interconnect has a configurable design complexity in-terms of
resource usage, stream width, number of input and output ports.

## Support modules

* Interconnect - Top level input/output port interconnect.
* StreamFifo - Single clock domain configurable stream buffer.
* StreamInspector - Utility for stateful stream information.
* StreamCombiner - Combine multiple input streams into one.
* StreamSplitter - Duplicate a single input stream into many.

## Bus standard

The interconnect uses the Avalon streaming specification:
http://www.altera.com/literature/manual/mnl_avalon_spec.pdf
