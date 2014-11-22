------------------------------------------------------------------------
-- Pothos Interconnect AXI wrapper
--
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
--
-- Xilinx Vivado style wrapper
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;

entity pothos_axi_interconnect is
    generic(

        -- the data port widths
        DATA_WIDTH : positive;

        -- the number of input ports
        NUM_INPUTS : positive;

        -- the number of output ports
        NUM_OUTPUTS : positive;

        -- The number of internal lanes to generate:
        -- Additional lanes provide dedicated paths of data flow
        -- at the expense of increasing resource utilization.
        NUM_LANES : positive;

        -- Buffer depth for lane entry and exit:
        -- Small buffers are used within the interconnect to ease timing,
        -- and to prevent minor contention within the lane in/outgress.
        FIFO_SIZE : positive := 4
    );
    port(
        aclk : in std_logic;
        aresetn : in std_logic;

        -- configuration channel
        s_apb_paddr : in std_logic_vector(31 downto 0);
        s_apb_psel : in std_logic;
        s_apb_penable : in std_logic;
        s_apb_pwrite : in std_logic;
        s_apb_pwdata : in std_logic_vector(31 downto 0);
        s_apb_pready : out std_logic;
        s_apb_prdata : out std_logic_vector(31 downto 0);
        s_apb_pslverr : out std_logic;

        --slave 0 axi stream
        s0_axis_tvalid : in std_logic;
        s0_axis_tready : out std_logic;
        s0_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s0_axis_tlast : in std_logic := '1';
        s0_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 0 axi stream
        m0_axis_tvalid : out std_logic;
        m0_axis_tready : in std_logic;
        m0_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m0_axis_tlast : out std_logic;
        m0_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 1 axi stream
        s1_axis_tvalid : in std_logic;
        s1_axis_tready : out std_logic;
        s1_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s1_axis_tlast : in std_logic := '1';
        s1_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 1 axi stream
        m1_axis_tvalid : out std_logic;
        m1_axis_tready : in std_logic;
        m1_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m1_axis_tlast : out std_logic;
        m1_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 2 axi stream
        s2_axis_tvalid : in std_logic;
        s2_axis_tready : out std_logic;
        s2_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s2_axis_tlast : in std_logic := '1';
        s2_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 2 axi stream
        m2_axis_tvalid : out std_logic;
        m2_axis_tready : in std_logic;
        m2_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m2_axis_tlast : out std_logic;
        m2_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 3 axi stream
        s3_axis_tvalid : in std_logic;
        s3_axis_tready : out std_logic;
        s3_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s3_axis_tlast : in std_logic := '1';
        s3_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 3 axi stream
        m3_axis_tvalid : out std_logic;
        m3_axis_tready : in std_logic;
        m3_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m3_axis_tlast : out std_logic;
        m3_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 4 axi stream
        s4_axis_tvalid : in std_logic;
        s4_axis_tready : out std_logic;
        s4_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s4_axis_tlast : in std_logic := '1';
        s4_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 4 axi stream
        m4_axis_tvalid : out std_logic;
        m4_axis_tready : in std_logic;
        m4_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m4_axis_tlast : out std_logic;
        m4_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 5 axi stream
        s5_axis_tvalid : in std_logic;
        s5_axis_tready : out std_logic;
        s5_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s5_axis_tlast : in std_logic := '1';
        s5_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 5 axi stream
        m5_axis_tvalid : out std_logic;
        m5_axis_tready : in std_logic;
        m5_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m5_axis_tlast : out std_logic;
        m5_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 6 axi stream
        s6_axis_tvalid : in std_logic;
        s6_axis_tready : out std_logic;
        s6_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s6_axis_tlast : in std_logic := '1';
        s6_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 6 axi stream
        m6_axis_tvalid : out std_logic;
        m6_axis_tready : in std_logic;
        m6_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m6_axis_tlast : out std_logic;
        m6_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 7 axi stream
        s7_axis_tvalid : in std_logic;
        s7_axis_tready : out std_logic;
        s7_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s7_axis_tlast : in std_logic := '1';
        s7_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 7 axi stream
        m7_axis_tvalid : out std_logic;
        m7_axis_tready : in std_logic;
        m7_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m7_axis_tlast : out std_logic;
        m7_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 8 axi stream
        s8_axis_tvalid : in std_logic;
        s8_axis_tready : out std_logic;
        s8_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s8_axis_tlast : in std_logic := '1';
        s8_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 8 axi stream
        m8_axis_tvalid : out std_logic;
        m8_axis_tready : in std_logic;
        m8_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m8_axis_tlast : out std_logic;
        m8_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 9 axi stream
        s9_axis_tvalid : in std_logic;
        s9_axis_tready : out std_logic;
        s9_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s9_axis_tlast : in std_logic := '1';
        s9_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 9 axi stream
        m9_axis_tvalid : out std_logic;
        m9_axis_tready : in std_logic;
        m9_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m9_axis_tlast : out std_logic;
        m9_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 10 axi stream
        s10_axis_tvalid : in std_logic;
        s10_axis_tready : out std_logic;
        s10_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s10_axis_tlast : in std_logic := '1';
        s10_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 10 axi stream
        m10_axis_tvalid : out std_logic;
        m10_axis_tready : in std_logic;
        m10_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m10_axis_tlast : out std_logic;
        m10_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 11 axi stream
        s11_axis_tvalid : in std_logic;
        s11_axis_tready : out std_logic;
        s11_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s11_axis_tlast : in std_logic := '1';
        s11_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 11 axi stream
        m11_axis_tvalid : out std_logic;
        m11_axis_tready : in std_logic;
        m11_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m11_axis_tlast : out std_logic;
        m11_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 12 axi stream
        s12_axis_tvalid : in std_logic;
        s12_axis_tready : out std_logic;
        s12_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s12_axis_tlast : in std_logic := '1';
        s12_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 12 axi stream
        m12_axis_tvalid : out std_logic;
        m12_axis_tready : in std_logic;
        m12_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m12_axis_tlast : out std_logic;
        m12_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 13 axi stream
        s13_axis_tvalid : in std_logic;
        s13_axis_tready : out std_logic;
        s13_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s13_axis_tlast : in std_logic := '1';
        s13_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 13 axi stream
        m13_axis_tvalid : out std_logic;
        m13_axis_tready : in std_logic;
        m13_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m13_axis_tlast : out std_logic;
        m13_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 14 axi stream
        s14_axis_tvalid : in std_logic;
        s14_axis_tready : out std_logic;
        s14_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s14_axis_tlast : in std_logic := '1';
        s14_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 14 axi stream
        m14_axis_tvalid : out std_logic;
        m14_axis_tready : in std_logic;
        m14_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m14_axis_tlast : out std_logic;
        m14_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 15 axi stream
        s15_axis_tvalid : in std_logic;
        s15_axis_tready : out std_logic;
        s15_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s15_axis_tlast : in std_logic := '1';
        s15_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 15 axi stream
        m15_axis_tvalid : out std_logic;
        m15_axis_tready : in std_logic;
        m15_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m15_axis_tlast : out std_logic;
        m15_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 16 axi stream
        s16_axis_tvalid : in std_logic;
        s16_axis_tready : out std_logic;
        s16_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s16_axis_tlast : in std_logic := '1';
        s16_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 16 axi stream
        m16_axis_tvalid : out std_logic;
        m16_axis_tready : in std_logic;
        m16_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m16_axis_tlast : out std_logic;
        m16_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 17 axi stream
        s17_axis_tvalid : in std_logic;
        s17_axis_tready : out std_logic;
        s17_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s17_axis_tlast : in std_logic := '1';
        s17_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 17 axi stream
        m17_axis_tvalid : out std_logic;
        m17_axis_tready : in std_logic;
        m17_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m17_axis_tlast : out std_logic;
        m17_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 18 axi stream
        s18_axis_tvalid : in std_logic;
        s18_axis_tready : out std_logic;
        s18_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s18_axis_tlast : in std_logic := '1';
        s18_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 18 axi stream
        m18_axis_tvalid : out std_logic;
        m18_axis_tready : in std_logic;
        m18_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m18_axis_tlast : out std_logic;
        m18_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 19 axi stream
        s19_axis_tvalid : in std_logic;
        s19_axis_tready : out std_logic;
        s19_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s19_axis_tlast : in std_logic := '1';
        s19_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 19 axi stream
        m19_axis_tvalid : out std_logic;
        m19_axis_tready : in std_logic;
        m19_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m19_axis_tlast : out std_logic;
        m19_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 20 axi stream
        s20_axis_tvalid : in std_logic;
        s20_axis_tready : out std_logic;
        s20_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s20_axis_tlast : in std_logic := '1';
        s20_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 20 axi stream
        m20_axis_tvalid : out std_logic;
        m20_axis_tready : in std_logic;
        m20_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m20_axis_tlast : out std_logic;
        m20_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 21 axi stream
        s21_axis_tvalid : in std_logic;
        s21_axis_tready : out std_logic;
        s21_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s21_axis_tlast : in std_logic := '1';
        s21_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 21 axi stream
        m21_axis_tvalid : out std_logic;
        m21_axis_tready : in std_logic;
        m21_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m21_axis_tlast : out std_logic;
        m21_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 22 axi stream
        s22_axis_tvalid : in std_logic;
        s22_axis_tready : out std_logic;
        s22_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s22_axis_tlast : in std_logic := '1';
        s22_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 22 axi stream
        m22_axis_tvalid : out std_logic;
        m22_axis_tready : in std_logic;
        m22_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m22_axis_tlast : out std_logic;
        m22_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 23 axi stream
        s23_axis_tvalid : in std_logic;
        s23_axis_tready : out std_logic;
        s23_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s23_axis_tlast : in std_logic := '1';
        s23_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 23 axi stream
        m23_axis_tvalid : out std_logic;
        m23_axis_tready : in std_logic;
        m23_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m23_axis_tlast : out std_logic;
        m23_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 24 axi stream
        s24_axis_tvalid : in std_logic;
        s24_axis_tready : out std_logic;
        s24_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s24_axis_tlast : in std_logic := '1';
        s24_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 24 axi stream
        m24_axis_tvalid : out std_logic;
        m24_axis_tready : in std_logic;
        m24_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m24_axis_tlast : out std_logic;
        m24_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 25 axi stream
        s25_axis_tvalid : in std_logic;
        s25_axis_tready : out std_logic;
        s25_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s25_axis_tlast : in std_logic := '1';
        s25_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 25 axi stream
        m25_axis_tvalid : out std_logic;
        m25_axis_tready : in std_logic;
        m25_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m25_axis_tlast : out std_logic;
        m25_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 26 axi stream
        s26_axis_tvalid : in std_logic;
        s26_axis_tready : out std_logic;
        s26_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s26_axis_tlast : in std_logic := '1';
        s26_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 26 axi stream
        m26_axis_tvalid : out std_logic;
        m26_axis_tready : in std_logic;
        m26_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m26_axis_tlast : out std_logic;
        m26_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 27 axi stream
        s27_axis_tvalid : in std_logic;
        s27_axis_tready : out std_logic;
        s27_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s27_axis_tlast : in std_logic := '1';
        s27_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 27 axi stream
        m27_axis_tvalid : out std_logic;
        m27_axis_tready : in std_logic;
        m27_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m27_axis_tlast : out std_logic;
        m27_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 28 axi stream
        s28_axis_tvalid : in std_logic;
        s28_axis_tready : out std_logic;
        s28_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s28_axis_tlast : in std_logic := '1';
        s28_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 28 axi stream
        m28_axis_tvalid : out std_logic;
        m28_axis_tready : in std_logic;
        m28_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m28_axis_tlast : out std_logic;
        m28_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 29 axi stream
        s29_axis_tvalid : in std_logic;
        s29_axis_tready : out std_logic;
        s29_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s29_axis_tlast : in std_logic := '1';
        s29_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 29 axi stream
        m29_axis_tvalid : out std_logic;
        m29_axis_tready : in std_logic;
        m29_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m29_axis_tlast : out std_logic;
        m29_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 30 axi stream
        s30_axis_tvalid : in std_logic;
        s30_axis_tready : out std_logic;
        s30_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s30_axis_tlast : in std_logic := '1';
        s30_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 30 axi stream
        m30_axis_tvalid : out std_logic;
        m30_axis_tready : in std_logic;
        m30_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m30_axis_tlast : out std_logic;
        m30_axis_tuser : out std_logic_vector(0 downto 0);

        --slave 31 axi stream
        s31_axis_tvalid : in std_logic;
        s31_axis_tready : out std_logic;
        s31_axis_tdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
        s31_axis_tlast : in std_logic := '1';
        s31_axis_tuser : in std_logic_vector(0 downto 0) := (others => '0');

        --master 31 axi stream
        m31_axis_tvalid : out std_logic;
        m31_axis_tready : in std_logic;
        m31_axis_tdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m31_axis_tlast : out std_logic;
        m31_axis_tuser : out std_logic_vector(0 downto 0);

        --flow control signal bus for masters
        m_axis_tbegin : out std_logic_vector(NUM_INPUTS-1 downto 0);

        --flow control signal bus for slaves
        s_axis_tbegin : in std_logic_vector(NUM_INPUTS-1 downto 0) := (others => '1')
    );
end entity pothos_axi_interconnect;

architecture rtl of pothos_axi_interconnect is
    signal arst : std_ulogic;

    signal paddr : std_ulogic_vector(31 downto 0);
    signal pwdata : std_ulogic_vector(31 downto 0);
    signal prdata : std_ulogic_vector(31 downto 0);

    signal in_data : std_ulogic_vector((DATA_WIDTH*NUM_INPUTS)-1 downto 0);
    signal in_meta : std_ulogic_vector(NUM_INPUTS-1 downto 0);
    signal in_last : std_ulogic_vector(NUM_INPUTS-1 downto 0);
    signal in_valid : std_ulogic_vector(NUM_INPUTS-1 downto 0);
    signal in_ready : std_ulogic_vector(NUM_INPUTS-1 downto 0);
    signal in_begin : std_ulogic_vector(NUM_INPUTS-1 downto 0);

    signal out_data : std_ulogic_vector((DATA_WIDTH*NUM_OUTPUTS)-1 downto 0);
    signal out_meta : std_ulogic_vector(NUM_OUTPUTS-1 downto 0);
    signal out_last : std_ulogic_vector(NUM_OUTPUTS-1 downto 0);
    signal out_valid : std_ulogic_vector(NUM_OUTPUTS-1 downto 0);
    signal out_ready : std_ulogic_vector(NUM_OUTPUTS-1 downto 0);
    signal out_begin : std_ulogic_vector(NUM_OUTPUTS-1 downto 0);

begin

    --unused
    s_apb_pslverr <= '0';

    --activate high reset
    arst <= not aresetn;

    --control bus
    paddr <= std_ulogic_vector(s_apb_paddr);
    pwdata <= std_ulogic_vector(s_apb_pwdata);
    s_apb_prdata <= std_logic_vector(prdata);

    --flow control
    out_begin <= std_ulogic_vector(s_axis_tbegin);
    m_axis_tbegin <= std_logic_vector(in_begin);

    --multi bus signals
    gen_slave_bus0:
    if 0 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(0+1))-1) downto DATA_WIDTH*0) <= std_ulogic_vector(s0_axis_tdata);
        in_meta(0) <= s0_axis_tuser(0);
        in_last(0) <= s0_axis_tlast;
        in_valid(0) <= s0_axis_tvalid;
        s0_axis_tready <= in_ready(0);
    end generate gen_slave_bus0;

    gen_master_bus0:
    if 0 < NUM_INPUTS generate
        m0_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(0+1))-1) downto DATA_WIDTH*0));
        m0_axis_tuser(0) <= out_meta(0);
        m0_axis_tlast <= out_last(0);
        m0_axis_tvalid <= out_valid(0);
        out_ready(0) <= m0_axis_tready;
    end generate gen_master_bus0;

    gen_slave_bus1:
    if 1 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(1+1))-1) downto DATA_WIDTH*1) <= std_ulogic_vector(s1_axis_tdata);
        in_meta(1) <= s1_axis_tuser(0);
        in_last(1) <= s1_axis_tlast;
        in_valid(1) <= s1_axis_tvalid;
        s1_axis_tready <= in_ready(1);
    end generate gen_slave_bus1;

    gen_master_bus1:
    if 1 < NUM_INPUTS generate
        m1_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(1+1))-1) downto DATA_WIDTH*1));
        m1_axis_tuser(0) <= out_meta(1);
        m1_axis_tlast <= out_last(1);
        m1_axis_tvalid <= out_valid(1);
        out_ready(1) <= m1_axis_tready;
    end generate gen_master_bus1;

    gen_slave_bus2:
    if 2 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(2+1))-1) downto DATA_WIDTH*2) <= std_ulogic_vector(s2_axis_tdata);
        in_meta(2) <= s2_axis_tuser(0);
        in_last(2) <= s2_axis_tlast;
        in_valid(2) <= s2_axis_tvalid;
        s2_axis_tready <= in_ready(2);
    end generate gen_slave_bus2;

    gen_master_bus2:
    if 2 < NUM_INPUTS generate
        m2_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(2+1))-1) downto DATA_WIDTH*2));
        m2_axis_tuser(0) <= out_meta(2);
        m2_axis_tlast <= out_last(2);
        m2_axis_tvalid <= out_valid(2);
        out_ready(2) <= m2_axis_tready;
    end generate gen_master_bus2;

    gen_slave_bus3:
    if 3 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(3+1))-1) downto DATA_WIDTH*3) <= std_ulogic_vector(s3_axis_tdata);
        in_meta(3) <= s3_axis_tuser(0);
        in_last(3) <= s3_axis_tlast;
        in_valid(3) <= s3_axis_tvalid;
        s3_axis_tready <= in_ready(3);
    end generate gen_slave_bus3;

    gen_master_bus3:
    if 3 < NUM_INPUTS generate
        m3_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(3+1))-1) downto DATA_WIDTH*3));
        m3_axis_tuser(0) <= out_meta(3);
        m3_axis_tlast <= out_last(3);
        m3_axis_tvalid <= out_valid(3);
        out_ready(3) <= m3_axis_tready;
    end generate gen_master_bus3;

    gen_slave_bus4:
    if 4 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(4+1))-1) downto DATA_WIDTH*4) <= std_ulogic_vector(s4_axis_tdata);
        in_meta(4) <= s4_axis_tuser(0);
        in_last(4) <= s4_axis_tlast;
        in_valid(4) <= s4_axis_tvalid;
        s4_axis_tready <= in_ready(4);
    end generate gen_slave_bus4;

    gen_master_bus4:
    if 4 < NUM_INPUTS generate
        m4_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(4+1))-1) downto DATA_WIDTH*4));
        m4_axis_tuser(0) <= out_meta(4);
        m4_axis_tlast <= out_last(4);
        m4_axis_tvalid <= out_valid(4);
        out_ready(4) <= m4_axis_tready;
    end generate gen_master_bus4;

    gen_slave_bus5:
    if 5 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(5+1))-1) downto DATA_WIDTH*5) <= std_ulogic_vector(s5_axis_tdata);
        in_meta(5) <= s5_axis_tuser(0);
        in_last(5) <= s5_axis_tlast;
        in_valid(5) <= s5_axis_tvalid;
        s5_axis_tready <= in_ready(5);
    end generate gen_slave_bus5;

    gen_master_bus5:
    if 5 < NUM_INPUTS generate
        m5_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(5+1))-1) downto DATA_WIDTH*5));
        m5_axis_tuser(0) <= out_meta(5);
        m5_axis_tlast <= out_last(5);
        m5_axis_tvalid <= out_valid(5);
        out_ready(5) <= m5_axis_tready;
    end generate gen_master_bus5;

    gen_slave_bus6:
    if 6 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(6+1))-1) downto DATA_WIDTH*6) <= std_ulogic_vector(s6_axis_tdata);
        in_meta(6) <= s6_axis_tuser(0);
        in_last(6) <= s6_axis_tlast;
        in_valid(6) <= s6_axis_tvalid;
        s6_axis_tready <= in_ready(6);
    end generate gen_slave_bus6;

    gen_master_bus6:
    if 6 < NUM_INPUTS generate
        m6_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(6+1))-1) downto DATA_WIDTH*6));
        m6_axis_tuser(0) <= out_meta(6);
        m6_axis_tlast <= out_last(6);
        m6_axis_tvalid <= out_valid(6);
        out_ready(6) <= m6_axis_tready;
    end generate gen_master_bus6;

    gen_slave_bus7:
    if 7 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(7+1))-1) downto DATA_WIDTH*7) <= std_ulogic_vector(s7_axis_tdata);
        in_meta(7) <= s7_axis_tuser(0);
        in_last(7) <= s7_axis_tlast;
        in_valid(7) <= s7_axis_tvalid;
        s7_axis_tready <= in_ready(7);
    end generate gen_slave_bus7;

    gen_master_bus7:
    if 7 < NUM_INPUTS generate
        m7_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(7+1))-1) downto DATA_WIDTH*7));
        m7_axis_tuser(0) <= out_meta(7);
        m7_axis_tlast <= out_last(7);
        m7_axis_tvalid <= out_valid(7);
        out_ready(7) <= m7_axis_tready;
    end generate gen_master_bus7;

    gen_slave_bus8:
    if 8 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(8+1))-1) downto DATA_WIDTH*8) <= std_ulogic_vector(s8_axis_tdata);
        in_meta(8) <= s8_axis_tuser(0);
        in_last(8) <= s8_axis_tlast;
        in_valid(8) <= s8_axis_tvalid;
        s8_axis_tready <= in_ready(8);
    end generate gen_slave_bus8;

    gen_master_bus8:
    if 8 < NUM_INPUTS generate
        m8_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(8+1))-1) downto DATA_WIDTH*8));
        m8_axis_tuser(0) <= out_meta(8);
        m8_axis_tlast <= out_last(8);
        m8_axis_tvalid <= out_valid(8);
        out_ready(8) <= m8_axis_tready;
    end generate gen_master_bus8;

    gen_slave_bus9:
    if 9 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(9+1))-1) downto DATA_WIDTH*9) <= std_ulogic_vector(s9_axis_tdata);
        in_meta(9) <= s9_axis_tuser(0);
        in_last(9) <= s9_axis_tlast;
        in_valid(9) <= s9_axis_tvalid;
        s9_axis_tready <= in_ready(9);
    end generate gen_slave_bus9;

    gen_master_bus9:
    if 9 < NUM_INPUTS generate
        m9_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(9+1))-1) downto DATA_WIDTH*9));
        m9_axis_tuser(0) <= out_meta(9);
        m9_axis_tlast <= out_last(9);
        m9_axis_tvalid <= out_valid(9);
        out_ready(9) <= m9_axis_tready;
    end generate gen_master_bus9;

    gen_slave_bus10:
    if 10 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(10+1))-1) downto DATA_WIDTH*10) <= std_ulogic_vector(s10_axis_tdata);
        in_meta(10) <= s10_axis_tuser(0);
        in_last(10) <= s10_axis_tlast;
        in_valid(10) <= s10_axis_tvalid;
        s10_axis_tready <= in_ready(10);
    end generate gen_slave_bus10;

    gen_master_bus10:
    if 10 < NUM_INPUTS generate
        m10_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(10+1))-1) downto DATA_WIDTH*10));
        m10_axis_tuser(0) <= out_meta(10);
        m10_axis_tlast <= out_last(10);
        m10_axis_tvalid <= out_valid(10);
        out_ready(10) <= m10_axis_tready;
    end generate gen_master_bus10;

    gen_slave_bus11:
    if 11 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(11+1))-1) downto DATA_WIDTH*11) <= std_ulogic_vector(s11_axis_tdata);
        in_meta(11) <= s11_axis_tuser(0);
        in_last(11) <= s11_axis_tlast;
        in_valid(11) <= s11_axis_tvalid;
        s11_axis_tready <= in_ready(11);
    end generate gen_slave_bus11;

    gen_master_bus11:
    if 11 < NUM_INPUTS generate
        m11_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(11+1))-1) downto DATA_WIDTH*11));
        m11_axis_tuser(0) <= out_meta(11);
        m11_axis_tlast <= out_last(11);
        m11_axis_tvalid <= out_valid(11);
        out_ready(11) <= m11_axis_tready;
    end generate gen_master_bus11;

    gen_slave_bus12:
    if 12 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(12+1))-1) downto DATA_WIDTH*12) <= std_ulogic_vector(s12_axis_tdata);
        in_meta(12) <= s12_axis_tuser(0);
        in_last(12) <= s12_axis_tlast;
        in_valid(12) <= s12_axis_tvalid;
        s12_axis_tready <= in_ready(12);
    end generate gen_slave_bus12;

    gen_master_bus12:
    if 12 < NUM_INPUTS generate
        m12_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(12+1))-1) downto DATA_WIDTH*12));
        m12_axis_tuser(0) <= out_meta(12);
        m12_axis_tlast <= out_last(12);
        m12_axis_tvalid <= out_valid(12);
        out_ready(12) <= m12_axis_tready;
    end generate gen_master_bus12;

    gen_slave_bus13:
    if 13 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(13+1))-1) downto DATA_WIDTH*13) <= std_ulogic_vector(s13_axis_tdata);
        in_meta(13) <= s13_axis_tuser(0);
        in_last(13) <= s13_axis_tlast;
        in_valid(13) <= s13_axis_tvalid;
        s13_axis_tready <= in_ready(13);
    end generate gen_slave_bus13;

    gen_master_bus13:
    if 13 < NUM_INPUTS generate
        m13_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(13+1))-1) downto DATA_WIDTH*13));
        m13_axis_tuser(0) <= out_meta(13);
        m13_axis_tlast <= out_last(13);
        m13_axis_tvalid <= out_valid(13);
        out_ready(13) <= m13_axis_tready;
    end generate gen_master_bus13;

    gen_slave_bus14:
    if 14 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(14+1))-1) downto DATA_WIDTH*14) <= std_ulogic_vector(s14_axis_tdata);
        in_meta(14) <= s14_axis_tuser(0);
        in_last(14) <= s14_axis_tlast;
        in_valid(14) <= s14_axis_tvalid;
        s14_axis_tready <= in_ready(14);
    end generate gen_slave_bus14;

    gen_master_bus14:
    if 14 < NUM_INPUTS generate
        m14_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(14+1))-1) downto DATA_WIDTH*14));
        m14_axis_tuser(0) <= out_meta(14);
        m14_axis_tlast <= out_last(14);
        m14_axis_tvalid <= out_valid(14);
        out_ready(14) <= m14_axis_tready;
    end generate gen_master_bus14;

    gen_slave_bus15:
    if 15 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(15+1))-1) downto DATA_WIDTH*15) <= std_ulogic_vector(s15_axis_tdata);
        in_meta(15) <= s15_axis_tuser(0);
        in_last(15) <= s15_axis_tlast;
        in_valid(15) <= s15_axis_tvalid;
        s15_axis_tready <= in_ready(15);
    end generate gen_slave_bus15;

    gen_master_bus15:
    if 15 < NUM_INPUTS generate
        m15_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(15+1))-1) downto DATA_WIDTH*15));
        m15_axis_tuser(0) <= out_meta(15);
        m15_axis_tlast <= out_last(15);
        m15_axis_tvalid <= out_valid(15);
        out_ready(15) <= m15_axis_tready;
    end generate gen_master_bus15;

    gen_slave_bus16:
    if 16 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(16+1))-1) downto DATA_WIDTH*16) <= std_ulogic_vector(s16_axis_tdata);
        in_meta(16) <= s16_axis_tuser(0);
        in_last(16) <= s16_axis_tlast;
        in_valid(16) <= s16_axis_tvalid;
        s16_axis_tready <= in_ready(16);
    end generate gen_slave_bus16;

    gen_master_bus16:
    if 16 < NUM_INPUTS generate
        m16_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(16+1))-1) downto DATA_WIDTH*16));
        m16_axis_tuser(0) <= out_meta(16);
        m16_axis_tlast <= out_last(16);
        m16_axis_tvalid <= out_valid(16);
        out_ready(16) <= m16_axis_tready;
    end generate gen_master_bus16;

    gen_slave_bus17:
    if 17 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(17+1))-1) downto DATA_WIDTH*17) <= std_ulogic_vector(s17_axis_tdata);
        in_meta(17) <= s17_axis_tuser(0);
        in_last(17) <= s17_axis_tlast;
        in_valid(17) <= s17_axis_tvalid;
        s17_axis_tready <= in_ready(17);
    end generate gen_slave_bus17;

    gen_master_bus17:
    if 17 < NUM_INPUTS generate
        m17_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(17+1))-1) downto DATA_WIDTH*17));
        m17_axis_tuser(0) <= out_meta(17);
        m17_axis_tlast <= out_last(17);
        m17_axis_tvalid <= out_valid(17);
        out_ready(17) <= m17_axis_tready;
    end generate gen_master_bus17;

    gen_slave_bus18:
    if 18 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(18+1))-1) downto DATA_WIDTH*18) <= std_ulogic_vector(s18_axis_tdata);
        in_meta(18) <= s18_axis_tuser(0);
        in_last(18) <= s18_axis_tlast;
        in_valid(18) <= s18_axis_tvalid;
        s18_axis_tready <= in_ready(18);
    end generate gen_slave_bus18;

    gen_master_bus18:
    if 18 < NUM_INPUTS generate
        m18_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(18+1))-1) downto DATA_WIDTH*18));
        m18_axis_tuser(0) <= out_meta(18);
        m18_axis_tlast <= out_last(18);
        m18_axis_tvalid <= out_valid(18);
        out_ready(18) <= m18_axis_tready;
    end generate gen_master_bus18;

    gen_slave_bus19:
    if 19 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(19+1))-1) downto DATA_WIDTH*19) <= std_ulogic_vector(s19_axis_tdata);
        in_meta(19) <= s19_axis_tuser(0);
        in_last(19) <= s19_axis_tlast;
        in_valid(19) <= s19_axis_tvalid;
        s19_axis_tready <= in_ready(19);
    end generate gen_slave_bus19;

    gen_master_bus19:
    if 19 < NUM_INPUTS generate
        m19_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(19+1))-1) downto DATA_WIDTH*19));
        m19_axis_tuser(0) <= out_meta(19);
        m19_axis_tlast <= out_last(19);
        m19_axis_tvalid <= out_valid(19);
        out_ready(19) <= m19_axis_tready;
    end generate gen_master_bus19;

    gen_slave_bus20:
    if 20 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(20+1))-1) downto DATA_WIDTH*20) <= std_ulogic_vector(s20_axis_tdata);
        in_meta(20) <= s20_axis_tuser(0);
        in_last(20) <= s20_axis_tlast;
        in_valid(20) <= s20_axis_tvalid;
        s20_axis_tready <= in_ready(20);
    end generate gen_slave_bus20;

    gen_master_bus20:
    if 20 < NUM_INPUTS generate
        m20_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(20+1))-1) downto DATA_WIDTH*20));
        m20_axis_tuser(0) <= out_meta(20);
        m20_axis_tlast <= out_last(20);
        m20_axis_tvalid <= out_valid(20);
        out_ready(20) <= m20_axis_tready;
    end generate gen_master_bus20;

    gen_slave_bus21:
    if 21 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(21+1))-1) downto DATA_WIDTH*21) <= std_ulogic_vector(s21_axis_tdata);
        in_meta(21) <= s21_axis_tuser(0);
        in_last(21) <= s21_axis_tlast;
        in_valid(21) <= s21_axis_tvalid;
        s21_axis_tready <= in_ready(21);
    end generate gen_slave_bus21;

    gen_master_bus21:
    if 21 < NUM_INPUTS generate
        m21_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(21+1))-1) downto DATA_WIDTH*21));
        m21_axis_tuser(0) <= out_meta(21);
        m21_axis_tlast <= out_last(21);
        m21_axis_tvalid <= out_valid(21);
        out_ready(21) <= m21_axis_tready;
    end generate gen_master_bus21;

    gen_slave_bus22:
    if 22 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(22+1))-1) downto DATA_WIDTH*22) <= std_ulogic_vector(s22_axis_tdata);
        in_meta(22) <= s22_axis_tuser(0);
        in_last(22) <= s22_axis_tlast;
        in_valid(22) <= s22_axis_tvalid;
        s22_axis_tready <= in_ready(22);
    end generate gen_slave_bus22;

    gen_master_bus22:
    if 22 < NUM_INPUTS generate
        m22_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(22+1))-1) downto DATA_WIDTH*22));
        m22_axis_tuser(0) <= out_meta(22);
        m22_axis_tlast <= out_last(22);
        m22_axis_tvalid <= out_valid(22);
        out_ready(22) <= m22_axis_tready;
    end generate gen_master_bus22;

    gen_slave_bus23:
    if 23 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(23+1))-1) downto DATA_WIDTH*23) <= std_ulogic_vector(s23_axis_tdata);
        in_meta(23) <= s23_axis_tuser(0);
        in_last(23) <= s23_axis_tlast;
        in_valid(23) <= s23_axis_tvalid;
        s23_axis_tready <= in_ready(23);
    end generate gen_slave_bus23;

    gen_master_bus23:
    if 23 < NUM_INPUTS generate
        m23_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(23+1))-1) downto DATA_WIDTH*23));
        m23_axis_tuser(0) <= out_meta(23);
        m23_axis_tlast <= out_last(23);
        m23_axis_tvalid <= out_valid(23);
        out_ready(23) <= m23_axis_tready;
    end generate gen_master_bus23;

    gen_slave_bus24:
    if 24 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(24+1))-1) downto DATA_WIDTH*24) <= std_ulogic_vector(s24_axis_tdata);
        in_meta(24) <= s24_axis_tuser(0);
        in_last(24) <= s24_axis_tlast;
        in_valid(24) <= s24_axis_tvalid;
        s24_axis_tready <= in_ready(24);
    end generate gen_slave_bus24;

    gen_master_bus24:
    if 24 < NUM_INPUTS generate
        m24_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(24+1))-1) downto DATA_WIDTH*24));
        m24_axis_tuser(0) <= out_meta(24);
        m24_axis_tlast <= out_last(24);
        m24_axis_tvalid <= out_valid(24);
        out_ready(24) <= m24_axis_tready;
    end generate gen_master_bus24;

    gen_slave_bus25:
    if 25 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(25+1))-1) downto DATA_WIDTH*25) <= std_ulogic_vector(s25_axis_tdata);
        in_meta(25) <= s25_axis_tuser(0);
        in_last(25) <= s25_axis_tlast;
        in_valid(25) <= s25_axis_tvalid;
        s25_axis_tready <= in_ready(25);
    end generate gen_slave_bus25;

    gen_master_bus25:
    if 25 < NUM_INPUTS generate
        m25_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(25+1))-1) downto DATA_WIDTH*25));
        m25_axis_tuser(0) <= out_meta(25);
        m25_axis_tlast <= out_last(25);
        m25_axis_tvalid <= out_valid(25);
        out_ready(25) <= m25_axis_tready;
    end generate gen_master_bus25;

    gen_slave_bus26:
    if 26 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(26+1))-1) downto DATA_WIDTH*26) <= std_ulogic_vector(s26_axis_tdata);
        in_meta(26) <= s26_axis_tuser(0);
        in_last(26) <= s26_axis_tlast;
        in_valid(26) <= s26_axis_tvalid;
        s26_axis_tready <= in_ready(26);
    end generate gen_slave_bus26;

    gen_master_bus26:
    if 26 < NUM_INPUTS generate
        m26_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(26+1))-1) downto DATA_WIDTH*26));
        m26_axis_tuser(0) <= out_meta(26);
        m26_axis_tlast <= out_last(26);
        m26_axis_tvalid <= out_valid(26);
        out_ready(26) <= m26_axis_tready;
    end generate gen_master_bus26;

    gen_slave_bus27:
    if 27 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(27+1))-1) downto DATA_WIDTH*27) <= std_ulogic_vector(s27_axis_tdata);
        in_meta(27) <= s27_axis_tuser(0);
        in_last(27) <= s27_axis_tlast;
        in_valid(27) <= s27_axis_tvalid;
        s27_axis_tready <= in_ready(27);
    end generate gen_slave_bus27;

    gen_master_bus27:
    if 27 < NUM_INPUTS generate
        m27_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(27+1))-1) downto DATA_WIDTH*27));
        m27_axis_tuser(0) <= out_meta(27);
        m27_axis_tlast <= out_last(27);
        m27_axis_tvalid <= out_valid(27);
        out_ready(27) <= m27_axis_tready;
    end generate gen_master_bus27;

    gen_slave_bus28:
    if 28 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(28+1))-1) downto DATA_WIDTH*28) <= std_ulogic_vector(s28_axis_tdata);
        in_meta(28) <= s28_axis_tuser(0);
        in_last(28) <= s28_axis_tlast;
        in_valid(28) <= s28_axis_tvalid;
        s28_axis_tready <= in_ready(28);
    end generate gen_slave_bus28;

    gen_master_bus28:
    if 28 < NUM_INPUTS generate
        m28_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(28+1))-1) downto DATA_WIDTH*28));
        m28_axis_tuser(0) <= out_meta(28);
        m28_axis_tlast <= out_last(28);
        m28_axis_tvalid <= out_valid(28);
        out_ready(28) <= m28_axis_tready;
    end generate gen_master_bus28;

    gen_slave_bus29:
    if 29 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(29+1))-1) downto DATA_WIDTH*29) <= std_ulogic_vector(s29_axis_tdata);
        in_meta(29) <= s29_axis_tuser(0);
        in_last(29) <= s29_axis_tlast;
        in_valid(29) <= s29_axis_tvalid;
        s29_axis_tready <= in_ready(29);
    end generate gen_slave_bus29;

    gen_master_bus29:
    if 29 < NUM_INPUTS generate
        m29_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(29+1))-1) downto DATA_WIDTH*29));
        m29_axis_tuser(0) <= out_meta(29);
        m29_axis_tlast <= out_last(29);
        m29_axis_tvalid <= out_valid(29);
        out_ready(29) <= m29_axis_tready;
    end generate gen_master_bus29;

    gen_slave_bus30:
    if 30 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(30+1))-1) downto DATA_WIDTH*30) <= std_ulogic_vector(s30_axis_tdata);
        in_meta(30) <= s30_axis_tuser(0);
        in_last(30) <= s30_axis_tlast;
        in_valid(30) <= s30_axis_tvalid;
        s30_axis_tready <= in_ready(30);
    end generate gen_slave_bus30;

    gen_master_bus30:
    if 30 < NUM_INPUTS generate
        m30_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(30+1))-1) downto DATA_WIDTH*30));
        m30_axis_tuser(0) <= out_meta(30);
        m30_axis_tlast <= out_last(30);
        m30_axis_tvalid <= out_valid(30);
        out_ready(30) <= m30_axis_tready;
    end generate gen_master_bus30;

    gen_slave_bus31:
    if 31 < NUM_INPUTS generate
        in_data(((DATA_WIDTH*(31+1))-1) downto DATA_WIDTH*31) <= std_ulogic_vector(s31_axis_tdata);
        in_meta(31) <= s31_axis_tuser(0);
        in_last(31) <= s31_axis_tlast;
        in_valid(31) <= s31_axis_tvalid;
        s31_axis_tready <= in_ready(31);
    end generate gen_slave_bus31;

    gen_master_bus31:
    if 31 < NUM_INPUTS generate
        m31_axis_tdata <= std_logic_vector(out_data(((DATA_WIDTH*(31+1))-1) downto DATA_WIDTH*31));
        m31_axis_tuser(0) <= out_meta(31);
        m31_axis_tlast <= out_last(31);
        m31_axis_tvalid <= out_valid(31);
        out_ready(31) <= m31_axis_tready;
    end generate gen_master_bus31;

    interconnect: entity work.Interconnect
    generic map (
        NUM_INPUTS => NUM_INPUTS,
        NUM_OUTPUTS => NUM_OUTPUTS,
        NUM_LANES => NUM_LANES,
        FIFO_SIZE => FIFO_SIZE
    )
    port map (
        clk => aclk,
        rst => arst,

        paddr => paddr,
        psel => s_apb_psel,
        penable => s_apb_penable,
        pwrite => s_apb_pwrite,
        pwdata => pwdata,
        pready => s_apb_pready,
        prdata => prdata,

        in_data => in_data,
        in_meta => in_meta,
        in_last => in_last,
        in_valid => in_valid,
        in_ready => in_ready,
        in_begin => in_begin,

        out_data => out_data,
        out_meta => out_meta,
        out_last => out_last,
        out_valid => out_valid,
        out_ready => out_ready,
        out_begin => out_begin
    );

end architecture rtl;
