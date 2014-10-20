------------------------------------------------------------------------
-- Simulation harness foreign functions
------------------------------------------------------------------------

package ExternalFunctionsPkg is

    procedure initProxyServer (zero : integer);
    attribute foreign of initProxyServer : procedure is "VHPIDIRECT PothosFPGA_initProxyServer";

    function setupSource (portNum : integer) return integer;
    attribute foreign of setupSource : function is "VHPIDIRECT PothosFPGA_setupSource";

    function sourceHasData (handle : integer) return boolean;
    attribute foreign of sourceHasData : function is "VHPIDIRECT PothosFPGA_sourceHasData";

    procedure sourcePopData (handle : integer);
    attribute foreign of sourcePopData : procedure is "VHPIDIRECT PothosFPGA_sourcePopData";

    function sourceFrontData (handle : integer) return integer;
    attribute foreign of sourceFrontData : function is "VHPIDIRECT PothosFPGA_sourceFrontData";

    function setupSink (portNum : integer) return integer;
    attribute foreign of setupSink : function is "VHPIDIRECT PothosFPGA_setupSink";

    function sinkHasSpace (handle : integer) return boolean;
    attribute foreign of sinkHasSpace : function is "VHPIDIRECT PothosFPGA_sinkHasSpace";

    procedure sinkPushData (handle : integer; data : integer);
    attribute foreign of sinkPushData : procedure is "VHPIDIRECT PothosFPGA_sinkPushData";
end ExternalFunctionsPkg;

-- empty function definitions to satisfy the tools
package body ExternalFunctionsPkg is

    procedure initProxyServer (zero : integer) is begin
    end procedure initProxyServer;

    function setupSource (portNum : integer) return integer is begin
    end function setupSource;

    function sourceHasData (handle : integer) return boolean is begin
    end function sourceHasData;

    procedure sourcePopData (handle : integer) is begin
    end procedure sourcePopData;

    function sourceFrontData (handle : integer) return integer is begin
    end function sourceFrontData;

    function setupSink (portNum : integer) return integer is begin
    end function setupSink;

    function sinkHasSpace (handle : integer) return boolean is begin
    end function sinkHasSpace;

    procedure sinkPushData (handle : integer; data : integer) is begin
    end procedure sinkPushData;
end ExternalFunctionsPkg;
