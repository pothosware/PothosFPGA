# The Pothos Interconnect FPGA library

The PothosInterconnect library provides a top level interconnect module.
The interconnect has a configurable design complexity in-terms of
resource usage, stream width, number of input and output ports.

## Support modules

* Interconnect - Top level input/output port interconnect.
* StreamFifo - Single clock domain configurable stream buffer.
* StreamValve - Control a stream's flow using an external signal.
* StreamInspector - Utility for stateful stream information.
* StreamCombiner - Combine multiple input streams into one.
* StreamSplitter - Duplicate a single input stream into many.
* LaneIngress - mux an input stream into a multi-lane busway.
* LaneOutgress - demux a multi-lane busway into an output stream.

## Bus standard

The interconnect uses the Avalon streaming specification:
http://www.altera.com/literature/manual/mnl_avalon_spec.pdf

## Streams

We use the following streaming bus convention from the Avalon streaming specification:

* data - the data bus of abitrary width
* valid - source says valid data on the bus
* ready - sink says ready to accept data

The data and valid signals are source driven, and the ready signal is sink driven backpressure.
The source and sink block both agree that a transfer occured on any cycle that is both ready and valid.

## Packets

We use the following extra signals to indicate information about packet transfers:

* meta - indicates that this tranfer is metadata
* last - indicates this transfer ends a packet

The meta signal indicates that the data bus contains packet metadata.
The mata signal allows the sink to easily separate packet headers from payloads
without any knowledge of how to interpret the packet.
Therefore, we can create processing IP that can operate identically on
regular streaming data, and packet based streaming data using the meta signal.

The last signal indicates that this cycle is the last in a packet transfer.
When not using packets, the last signal should be disconnected or set to '1'.
In essence, non-packet based streaming is just a new packet on every cycle.

The last signal is an abbreviation for the Avalon streaming endofpacket.
In addition, we dont use the Avalon streaming startofpacket signal.
The packet start signal is ignored by most implementations,
and can be reproduced given the last and other bus signals.
