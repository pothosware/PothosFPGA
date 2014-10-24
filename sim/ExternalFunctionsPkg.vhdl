------------------------------------------------------------------------
-- Simulation harness foreign functions
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
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

    function setupControl (id : integer) return integer;
    attribute foreign of setupControl : function is "VHPIDIRECT PothosFPGA_setupControl";

    function controlGetAction (handle : integer) return integer;
    attribute foreign of controlGetAction : function is "VHPIDIRECT PothosFPGA_controlGetAction";

    function controlGetAddr (handle : integer) return integer;
    attribute foreign of controlGetAddr : function is "VHPIDIRECT PothosFPGA_controlGetAddr";

    function controlGetData (handle : integer) return integer;
    attribute foreign of controlGetData : function is "VHPIDIRECT PothosFPGA_controlGetData";

    procedure controlPutData (handle : integer; data : integer);
    attribute foreign of controlPutData : procedure is "VHPIDIRECT PothosFPGA_controlPutData";

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

    function setupControl (id : integer) return integer is begin
    end function setupControl;

    function controlGetAction (handle : integer) return integer is begin
    end function controlGetAction;

    function controlGetAddr (handle : integer) return integer is begin
    end function controlGetAddr;

    function controlGetData (handle : integer) return integer is begin
    end function controlGetData;

    procedure controlPutData (handle : integer; data : integer) is begin
    end procedure controlPutData;

end ExternalFunctionsPkg;
