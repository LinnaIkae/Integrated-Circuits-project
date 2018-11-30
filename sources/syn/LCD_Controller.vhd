LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;



ENTITY LCD_CONTROLLER IS
PORT( 
   CLK_I           : IN  STD_LOGIC;
   RST_I           : IN  STD_LOGIC;
   AVS             : IN  STD_LOGIC;
   DAY             : IN  STD_LOGIC;
   MAX             : IN  STD_LOGIC;
   TIM             : IN  STD_LOGIC;
   POINT           : IN  STD_LOGIC;
   COLON           : IN  STD_LOGIC;
   KMH             : IN  STD_LOGIC_VECTOR(0 downto 0);
   LOWER1_ASCII    : IN  STD_LOGIC_VECTOR(7 downto 0);
   LOWER10_ASCII   : IN  STD_LOGIC_VECTOR(7 downto 0);
   LOWER100_ASCII  : IN  STD_LOGIC_VECTOR(7 downto 0);
   LOWER1000_ASCII : IN  STD_LOGIC_VECTOR(7 downto 0);
   UPPER1_ASCII    : IN  STD_LOGIC_VECTOR(7 downto 0);
   UPPER10_ASCII   : IN  STD_LOGIC_VECTOR(7 downto 0);
   RES_N_o         : OUT STD_LOGIC;
   SCL_o           : OUT STD_LOGIC;
   SI_o            : OUT STD_LOGIC;
   CS1_N_o         : OUT STD_LOGIC;
   A0_o            : OUT STD_LOGIC;          
   C86_o           : OUT STD_LOGIC;
   LED_A_o         : OUT STD_LOGIC);
end LCD_CONTROLLER;



ARCHITECTURE Behavioral1 OF LCD_CONTROLLER IS


COMPONENT BICYCLE_LCD_MASTER
PORT(
   CLK_I           : IN    STD_LOGIC;
   RST_I           : IN    STD_LOGIC;
   AVS             : IN    STD_LOGIC;
   DAY             : IN    STD_LOGIC;
   MAX             : IN    STD_LOGIC;
   TIM             : IN    STD_LOGIC;
   POINT           : IN    STD_LOGIC;
   COLON           : IN    STD_LOGIC;
   KMH             : IN    STD_LOGIC_VECTOR(0 downto 0);
   LOWER1_ASCII    : IN    STD_LOGIC_VECTOR(7 downto 0);
   LOWER10_ASCII   : IN    STD_LOGIC_VECTOR(7 downto 0);
   LOWER100_ASCII  : IN    STD_LOGIC_VECTOR(7 downto 0);
   LOWER1000_ASCII : IN    STD_LOGIC_VECTOR(7 downto 0);
   UPPER1_ASCII    : IN    STD_LOGIC_VECTOR(7 downto 0);
   UPPER10_ASCII   : IN    STD_LOGIC_VECTOR(7 downto 0);
   WB_ACK_I        : IN    STD_LOGIC;    
   WB_CYC_IO       : INOUT STD_LOGIC;      
   WB_WE_O         : OUT   STD_LOGIC;
   WB_STB_O        : OUT   STD_LOGIC;
   WB_Addr_O       : OUT   STD_LOGIC_VECTOR(7 downto 0);
   WB_DATA_OUT     : OUT   STD_LOGIC_VECTOR(7 downto 0));
END COMPONENT;

COMPONENT LCD_CMD_DECODER
PORT(	 
   CLK_i            : IN  STD_LOGIC;
   RST_N_i          : IN  STD_LOGIC;
   WB_RDY_o         : OUT STD_LOGIC;
   WB_DATA_i        : IN  STD_LOGIC_VECTOR(7 downto 0);
   WB_ADR_i         : IN  STD_LOGIC_VECTOR(3 downto 0);
   WB_WR_i          : IN  STD_LOGIC;
   MEM_RDY_i        : IN  STD_LOGIC;
   MEM_ASCII_CODE_o : OUT UNSIGNED(7 downto 0);
   MEM_OFFSET_o     : OUT UNSIGNED(4 downto 0);
   MEM_MODE_o       : OUT STD_LOGIC_VECTOR(2 downto 0);
   MEM_WR_o         : OUT STD_LOGIC;
   MEM_RD_o         : OUT STD_LOGIC;
   MEM_DATA_i       : IN  STD_LOGIC_VECTOR(7 downto 0);
   LCD_IF_RDY_i     : IN  STD_LOGIC;
   LCD_IF_DATA_o    : OUT STD_LOGIC_VECTOR(7 downto 0);
   LCD_IF_A0_o      : OUT STD_LOGIC;
   LCD_IF_WR_o      : OUT STD_LOGIC;
   LCD_IF_RS_o      : OUT STD_LOGIC_VECTOR(2 downto 0));
END COMPONENT;

COMPONENT LCD_SIGNAL_IF
GENERIC(
   CLK_DIV_COUNT_WIDTH          : NATURAL;
   RESET_WAIT_COUNT_WIDTH       : NATURAL;
   RESET_WAIT_COUNTER_END       : NATURAL;
   RESET_WAIT_AFTER_COUNTER_END : NATURAL);
PORT(
   CLK_i   : IN    STD_LOGIC;
   RST_N_i : IN    STD_LOGIC;
   RDY_o   : OUT   STD_LOGIC;
   DATA_i  : IN    STD_LOGIC_VECTOR(7 downto 0);
   A0_i    : IN    STD_LOGIC;
   WR_i    : IN    STD_LOGIC;
   RS_i    : IN    STD_LOGIC_VECTOR(2 downto 0);
   RES_N_o : OUT   STD_LOGIC;
   SCL_o   : INOUT STD_LOGIC;
   SI_o    : OUT   STD_LOGIC;
   CS1_N_o : OUT   STD_LOGIC;
   A0_o    : OUT   STD_LOGIC;          
   C86_o   : OUT   STD_LOGIC;
   LED_A_o : OUT   STD_LOGIC);
END COMPONENT;
	
COMPONENT LCD_MEM_CONTROL 
PORT(	 
   CLK_i            : IN  STD_LOGIC;
   RST_N_i          : IN  STD_LOGIC;
   MEM_RDY_o        : OUT STD_LOGIC;
   MEM_ASCII_CODE_i : IN  UNSIGNED(7 downto 0);
   MEM_OFFSET_i     : IN  UNSIGNED(4 downto 0);
   MEM_MODE_i       : IN  STD_LOGIC_VECTOR(2 downto 0);
   MEM_WR_i         : IN  STD_LOGIC;
   MEM_RD_i         : IN  STD_LOGIC;
   MEM_DATA_o       : OUT STD_LOGIC_VECTOR(7 downto 0));
END COMPONENT;

TYPE wb_if_state_type IS ( WB_IDLE , WB_WAIT_READ , WB_WAIT_WRITE , WB_GEN_ACK , WB_WAIT_1 , WB_WAIT_2 );
SIGNAL wb_if_state : wb_if_state_type := WB_IDLE;

SIGNAL RST_N_i : STD_LOGIC;
SIGNAL LCD_IF_RDY , LCD_IF_A0 , LCD_IF_WR : STD_LOGIC;
SIGNAL LCD_IF_DATA : STD_LOGIC_VECTOR(7 downto 0);
SIGNAL LCD_IF_RS : STD_LOGIC_VECTOR(2 downto 0);
SIGNAL MEM_RDY , MEM_WR , MEM_RD : STD_LOGIC;
SIGNAL MEM_MODE : STD_LOGIC_VECTOR(2 downto 0);
SIGNAL MEM_DATA_OUT : STD_LOGIC_VECTOR(7 downto 0);
SIGNAL MEM_ASCII_CODE : UNSIGNED(7 downto 0);
SIGNAL MEM_CURSOR : UNSIGNED(15 downto 0);
SIGNAL MEM_OFFSET : UNSIGNED(4 downto 0);
SIGNAL iWB_DATA_i : STD_LOGIC_VECTOR(7 downto 0);
SIGNAL iWB_ADR_i :  STD_LOGIC_VECTOR(3 downto 0);
SIGNAL iWB_RDY_o :  STD_LOGIC;
SIGNAL WB_ACK_o : STD_LOGIC;
SIGNAL WB_DATA_i : STD_LOGIC_VECTOR(7 downto 0);
SIGNAL WB_ADR_long : STD_LOGIC_VECTOR(7 downto 0);
SIGNAL WB_ADR_i : STD_LOGIC_VECTOR(3 downto 0);
SIGNAL WB_WR_i : STD_LOGIC;
SIGNAL WB_STB_i : STD_LOGIC;
SIGNAL RES_N , SCL , SI , CS1_N , A0 , A0_1, C86 , LED_A : STD_LOGIC;


BEGIN


-- To get all signals equaly delayed, place register and use display clock
--OUT_REG : PROCESS(SCL)
--BEGIN
--   IF falling_edge(SCL) THEN
      RES_N_o <= RES_N;
      SI_o    <= SI;
      CS1_N_o <= CS1_N;
      A0_1    <= A0;
      A0_o    <= A0_1;
      C86_o   <= C86;
      LED_A_o <= LED_A;
--   END IF;
--END PROCESS;
SCL_o <= SCL;

RST_N_i <= NOT(RST_i);

WB_ADR_i <= WB_ADR_long(3 downto 0);
BICYCLE_LCD_MASTER_INST: BICYCLE_LCD_MASTER 
PORT MAP(
   CLK_i           => CLK_i,
   RST_i           => RST_i,
   AVS             => AVS,
   DAY             => DAY,
   MAX             => MAX,
   TIM             => TIM,
   POINT           => POINT,
   COLON           => COLON,
   KMH             => KMH,
   LOWER1_ASCII    => LOWER1_ASCII,
   LOWER10_ASCII   => LOWER10_ASCII,
   LOWER100_ASCII  => LOWER100_ASCII,
   LOWER1000_ASCII => LOWER1000_ASCII,
   UPPER1_ASCII    => UPPER1_ASCII,
   UPPER10_ASCII   => UPPER10_ASCII,
   WB_ACK_I        => WB_ACK_o,
   WB_WE_O         => WB_WR_i,
   WB_CYC_IO       => open,
   WB_STB_O        => WB_STB_i,
   WB_Addr_O       => WB_ADR_long,
   WB_DATA_OUT     => WB_DATA_I);

WB_IF_PROC : PROCESS(CLK_i)
BEGIN
   IF rising_edge(CLK_i) THEN
      -- DEFAULT VALUES
      WB_ACK_o   <= '0';
      --iWB_WR_i   <= '0';
      iWB_ADR_i  <= iWB_ADR_i;
      if (RST_N_i = '0') then
         wb_if_state <= WB_IDLE;
         iWB_ADR_i   <= (others => '0');
		 iWB_DATA_i  <= (others => '0');
      else
         case wb_if_state is
            when WB_IDLE => --check for write/read requeset
               if(WB_STB_i = '1' and WB_WR_i = '1') then
                  wb_if_state <= WB_WAIT_WRITE;
               elsif (WB_STB_i = '1' and WB_WR_i = '0') then
                  wb_if_state <= WB_WAIT_READ;
               end if;
            when WB_WAIT_WRITE => --wait for cmd_decoder to be ready
               if(iWB_RDY_o = '1') then
                  wb_if_state <= WB_GEN_ACK;
                  iWB_DATA_i <= WB_DATA_i;
                  iWB_ADR_i <= WB_ADR_i;					
               else
                  wb_if_state <= WB_WAIT_WRITE;
               end if;
            when WB_WAIT_READ =>
               if(iWB_RDY_o = '1') then
                  wb_if_state <= WB_GEN_ACK;
               else
                  wb_if_state <= WB_WAIT_WRITE;
               end if;
            when WB_GEN_ACK =>
               wb_if_state <= WB_WAIT_1;
               WB_ACK_o <= '1';
               --iWB_WR_i <= '1';
            when WB_WAIT_1 =>
               wb_if_state <= WB_WAIT_2;
            when WB_WAIT_2 =>
               wb_if_state <= WB_IDLE;
		end case;			
		end if;
   END IF;
END PROCESS;

LCD_CMD_DECODER_INST : LCD_CMD_DECODER 
PORT MAP(
   CLK_i            => CLK_i,
   RST_N_i          => RST_N_i,
   WB_RDY_o         => iWB_RDY_o,
   WB_DATA_i        => iWB_DATA_i,
   WB_ADR_i         => iWB_ADR_i,
   WB_WR_i          => WB_ACK_o,
   MEM_RDY_i        => MEM_RDY,
   MEM_ASCII_CODE_o => MEM_ASCII_CODE,
   MEM_OFFSET_o     => MEM_OFFSET,
   MEM_MODE_o       => MEM_MODE,
   MEM_WR_o         => MEM_WR,
   MEM_RD_o         => MEM_RD ,
   MEM_DATA_i       => MEM_DATA_OUT,
   LCD_IF_RDY_i     => LCD_IF_RDY,
   LCD_IF_DATA_o    => LCD_IF_DATA,
   LCD_IF_A0_o      => LCD_IF_A0,
   LCD_IF_WR_o      => LCD_IF_WR,
   LCD_IF_RS_o      => LCD_IF_RS);  

LCD_SIGNAL_IF_INST : LCD_SIGNAL_IF 
GENERIC MAP(
   CLK_DIV_COUNT_WIDTH           => 8,
   RESET_WAIT_COUNT_WIDTH        => 10,
   RESET_WAIT_COUNTER_END        => 1020,
   RESET_WAIT_AFTER_COUNTER_END  => 150)
PORT MAP(
   CLK_i   => CLK_i,
   RST_N_i => RST_N_i,
   RDY_o   => LCD_IF_RDY,
   DATA_i  => LCD_IF_DATA,
   A0_i    => LCD_IF_A0,
   WR_i    => LCD_IF_WR,
   RS_i    => LCD_IF_RS,
   RES_N_o => RES_N,
   SCL_o   => SCL,
   SI_o    => SI,
   CS1_N_o => CS1_N,
   A0_o    => A0,
   C86_o   => C86,
   LED_A_o => LED_A);
	
LCD_MEM_CONTROL_INST : LCD_MEM_CONTROL 
PORT MAP(
   CLK_i            => CLK_i,
   RST_N_i          => RST_N_i,
   MEM_RDY_o        => MEM_RDY,
   MEM_ASCII_CODE_i => MEM_ASCII_CODE,
   MEM_OFFSET_i     => MEM_OFFSET, 
   MEM_MODE_i       => MEM_MODE,
   MEM_WR_i         => MEM_WR,
   MEM_RD_i         => MEM_RD,
   MEM_DATA_o       => MEM_DATA_OUT);
	
	
END Behavioral1;






LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;



ENTITY BLOCK_RAM_CORE_ASCII_LUT_SMALL_BIG_2K_ZYBO IS
PORT(
   CLKA  : IN  STD_LOGIC;
   ENA   : IN  STD_LOGIC;
   WEA   : IN  STD_LOGIC_VECTOR(0 downto 0);
   ADDRA : IN  STD_LOGIC_VECTOR(10 downto 0);
   DINA  : IN  STD_LOGIC_VECTOR(7 downto 0);
   DOUTA : OUT STD_LOGIC_VECTOR(7 downto 0));
END BLOCK_RAM_CORE_ASCII_LUT_SMALL_BIG_2K_ZYBO;



ARCHITECTURE syn OF BLOCK_RAM_CORE_ASCII_LUT_SMALL_BIG_2K_ZYBO IS


   TYPE ram_type IS ARRAY (0 to 2047) OF STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL RAM: ram_type := (
   X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"3E", X"45", X"51", X"45", X"3E", X"00", X"00", X"00", X"3E", X"6B", X"6F",
   X"6B", X"3E", X"00", X"00", X"00", X"1C", X"3E", X"7C", X"3E", X"1C", X"00", X"00", X"00", X"18", X"3C", X"7E", X"3C", X"18", X"00", X"00",
   X"00", X"30", X"36", X"7F", X"36", X"30", X"00", X"00", X"00", X"18", X"5C", X"7E", X"5C", X"18", X"00", X"00", X"00", X"00", X"18", X"18",
   X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
   X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"30", X"48", X"4A", X"36", X"0E", X"00", X"00", X"00", X"06", X"29", X"79",
   X"29", X"06", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"60", X"7E", X"0A", X"35", X"3F", X"00", X"00",
   X"00", X"2A", X"1C", X"36", X"1C", X"2A", X"00", X"00", X"00", X"00", X"7F", X"3E", X"1C", X"08", X"00", X"00", X"00", X"08", X"1C", X"3E",
   X"7F", X"00", X"00", X"00", X"00", X"14", X"36", X"7F", X"36", X"14", X"00", X"00", X"00", X"00", X"5F", X"00", X"5F", X"00", X"00", X"00",
   X"00", X"06", X"09", X"7F", X"01", X"7F", X"00", X"00", X"00", X"22", X"4D", X"55", X"59", X"22", X"00", X"00", X"00", X"60", X"60", X"60",
   X"60", X"00", X"00", X"00", X"00", X"14", X"B6", X"FF", X"B6", X"14", X"00", X"00", X"00", X"04", X"06", X"7F", X"06", X"04", X"00", X"00",
   X"00", X"10", X"30", X"7F", X"30", X"10", X"00", X"00", X"00", X"08", X"08", X"3E", X"1C", X"08", X"00", X"00", X"00", X"08", X"1C", X"3E",
   X"08", X"08", X"00", X"00", X"00", X"78", X"40", X"40", X"40", X"40", X"00", X"00", X"00", X"08", X"3E", X"08", X"3E", X"08", X"00", X"00",
   X"00", X"30", X"3C", X"3F", X"3C", X"30", X"00", X"00", X"00", X"03", X"0F", X"3F", X"0F", X"03", X"00", X"00", X"00", X"00", X"00", X"00",
   X"00", X"00", X"00", X"00", X"00", X"00", X"06", X"5F", X"06", X"00", X"00", X"00", X"00", X"07", X"03", X"00", X"07", X"03", X"00", X"00",
   X"00", X"24", X"7E", X"24", X"7E", X"24", X"00", X"00", X"00", X"24", X"2B", X"6A", X"12", X"00", X"00", X"00", X"00", X"63", X"13", X"08",
   X"64", X"63", X"00", X"00", X"00", X"36", X"49", X"56", X"20", X"50", X"00", X"00", X"00", X"00", X"07", X"03", X"00", X"00", X"00", X"00",
   X"00", X"00", X"3E", X"41", X"00", X"00", X"00", X"00", X"00", X"00", X"41", X"3E", X"00", X"00", X"00", X"00", X"00", X"08", X"3E", X"1C",
   X"3E", X"08", X"00", X"00", X"00", X"08", X"08", X"3E", X"08", X"08", X"00", X"00", X"00", X"00", X"E0", X"60", X"00", X"00", X"00", X"00",
   X"00", X"08", X"08", X"08", X"08", X"08", X"00", X"00", X"00", X"00", X"60", X"60", X"00", X"00", X"00", X"00", X"00", X"20", X"10", X"08",
   X"04", X"02", X"00", X"00", X"00", X"3E", X"51", X"49", X"45", X"3E", X"00", X"00", X"00", X"00", X"42", X"7F", X"40", X"00", X"00", X"00",
   X"00", X"62", X"51", X"49", X"49", X"46", X"00", X"00", X"00", X"22", X"49", X"49", X"49", X"36", X"00", X"00", X"00", X"18", X"14", X"12",
   X"7F", X"10", X"00", X"00", X"00", X"2F", X"49", X"49", X"49", X"31", X"00", X"00", X"00", X"3C", X"4A", X"49", X"49", X"30", X"00", X"00",
   X"00", X"01", X"71", X"09", X"05", X"03", X"00", X"00", X"00", X"36", X"49", X"49", X"49", X"36", X"00", X"00", X"00", X"06", X"49", X"49",
   X"29", X"1E", X"00", X"00", X"00", X"00", X"6C", X"6C", X"00", X"00", X"00", X"00", X"00", X"00", X"EC", X"6C", X"00", X"00", X"00", X"00",
   X"00", X"08", X"14", X"22", X"41", X"00", X"00", X"00", X"00", X"24", X"24", X"24", X"24", X"24", X"00", X"00", X"00", X"00", X"41", X"22",
   X"14", X"08", X"00", X"00", X"00", X"02", X"01", X"59", X"09", X"06", X"00", X"00", X"00", X"3E", X"41", X"5D", X"55", X"1E", X"00", X"00",
   X"00", X"7E", X"11", X"11", X"11", X"7E", X"00", X"00", X"00", X"7F", X"49", X"49", X"49", X"36", X"00", X"00", X"00", X"3E", X"41", X"41",
   X"41", X"22", X"00", X"00", X"00", X"7F", X"41", X"41", X"41", X"3E", X"00", X"00", X"00", X"7F", X"49", X"49", X"49", X"41", X"00", X"00",
   X"00", X"7F", X"09", X"09", X"09", X"01", X"00", X"00", X"00", X"3E", X"41", X"49", X"49", X"7A", X"00", X"00", X"00", X"7F", X"08", X"08",
   X"08", X"7F", X"00", X"00", X"00", X"00", X"41", X"7F", X"41", X"00", X"00", X"00", X"00", X"30", X"40", X"40", X"40", X"3F", X"00", X"00",
   X"00", X"7F", X"08", X"14", X"22", X"41", X"00", X"00", X"00", X"7F", X"40", X"40", X"40", X"40", X"00", X"00", X"00", X"7F", X"02", X"04",
   X"02", X"7F", X"00", X"00", X"00", X"7F", X"02", X"04", X"08", X"7F", X"00", X"00", X"00", X"3E", X"41", X"41", X"41", X"3E", X"00", X"00",
   X"00", X"7F", X"09", X"09", X"09", X"06", X"00", X"00", X"00", X"3E", X"41", X"51", X"21", X"5E", X"00", X"00", X"00", X"7F", X"09", X"09",
   X"19", X"66", X"00", X"00", X"00", X"26", X"49", X"49", X"49", X"32", X"00", X"00", X"00", X"01", X"01", X"7F", X"01", X"01", X"00", X"00",
   X"00", X"3F", X"40", X"40", X"40", X"3F", X"00", X"00", X"00", X"1F", X"20", X"40", X"20", X"1F", X"00", X"00", X"00", X"3F", X"40", X"3C",
   X"40", X"3F", X"00", X"00", X"00", X"63", X"14", X"08", X"14", X"63", X"00", X"00", X"00", X"07", X"08", X"70", X"08", X"07", X"00", X"00",
   X"00", X"71", X"49", X"45", X"43", X"00", X"00", X"00", X"00", X"00", X"7F", X"41", X"41", X"00", X"00", X"00", X"00", X"02", X"04", X"08",
   X"10", X"20", X"00", X"00", X"00", X"00", X"41", X"41", X"7F", X"00", X"00", X"00", X"00", X"04", X"02", X"01", X"02", X"04", X"00", X"00",
   X"80", X"80", X"80", X"80", X"80", X"80", X"00", X"00", X"00", X"00", X"03", X"07", X"00", X"00", X"00", X"00", X"00", X"20", X"54", X"54",
   X"54", X"78", X"00", X"00", X"00", X"7F", X"44", X"44", X"44", X"38", X"00", X"00", X"00", X"38", X"44", X"44", X"44", X"28", X"00", X"00",
   X"00", X"38", X"44", X"44", X"44", X"7F", X"00", X"00", X"00", X"38", X"54", X"54", X"54", X"08", X"00", X"00", X"00", X"08", X"7E", X"09",
   X"09", X"00", X"00", X"00", X"00", X"18", X"A4", X"A4", X"A4", X"7C", X"00", X"00", X"00", X"7F", X"04", X"04", X"78", X"00", X"00", X"00",
   X"00", X"00", X"00", X"7D", X"40", X"00", X"00", X"00", X"00", X"40", X"80", X"84", X"7D", X"00", X"00", X"00", X"00", X"7F", X"10", X"28",
   X"44", X"00", X"00", X"00", X"00", X"00", X"00", X"7F", X"40", X"00", X"00", X"00", X"00", X"7C", X"04", X"18", X"04", X"78", X"00", X"00",
   X"00", X"7C", X"04", X"04", X"78", X"00", X"00", X"00", X"00", X"38", X"44", X"44", X"44", X"38", X"00", X"00", X"00", X"FC", X"44", X"44",
   X"44", X"38", X"00", X"00", X"00", X"38", X"44", X"44", X"44", X"FC", X"00", X"00", X"00", X"44", X"78", X"44", X"04", X"08", X"00", X"00",
   X"00", X"08", X"54", X"54", X"54", X"20", X"00", X"00", X"00", X"04", X"3E", X"44", X"24", X"00", X"00", X"00", X"00", X"3C", X"40", X"20",
   X"7C", X"00", X"00", X"00", X"00", X"1C", X"20", X"40", X"20", X"1C", X"00", X"00", X"00", X"3C", X"60", X"30", X"60", X"3C", X"00", X"00",
   X"00", X"6C", X"10", X"10", X"6C", X"00", X"00", X"00", X"00", X"9C", X"A0", X"60", X"3C", X"00", X"00", X"00", X"00", X"64", X"54", X"54",
   X"4C", X"00", X"00", X"00", X"00", X"08", X"3E", X"41", X"41", X"00", X"00", X"00", X"00", X"00", X"00", X"77", X"00", X"00", X"00", X"00",
   X"00", X"00", X"41", X"41", X"3E", X"08", X"00", X"00", X"00", X"02", X"01", X"02", X"01", X"00", X"00", X"00", X"00", X"3C", X"26", X"23",
   X"26", X"3C", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
   X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
   X"7C", X"FF", X"FF", X"7C", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"33", X"33", X"00",
   X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"3C", X"3C", X"00", X"00", X"3C", X"3C", X"00", X"00", X"00",
   X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
   X"00", X"00", X"10", X"90", X"F0", X"7E", X"1E", X"90", X"F0", X"7E", X"1E", X"10", X"00", X"00", X"00", X"00", X"00", X"02", X"1E", X"1F",
   X"03", X"02", X"1E", X"1F", X"03", X"02", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"FF", X"33", X"66", X"CC",
   X"98", X"F0", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"06", X"0F", X"0F", X"07", X"00", X"30", X"78", X"79", X"3F", X"00", X"00",
   X"00", X"00", X"00", X"00", X"00", X"00", X"38", X"38", X"38", X"00", X"80", X"C0", X"E0", X"70", X"38", X"1C", X"00", X"00", X"00", X"00",
   X"00", X"30", X"38", X"1C", X"0E", X"07", X"03", X"01", X"38", X"38", X"38", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"B8",
   X"FC", X"C6", X"E2", X"3E", X"1C", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"1F", X"3F", X"31", X"21", X"37", X"1E",
   X"1C", X"36", X"22", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"27", X"3F", X"1F", X"00", X"00", X"00", X"00", X"00",
   X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
   X"00", X"00", X"00", X"F0", X"FC", X"FE", X"07", X"01", X"01", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"03",
   X"0F", X"1F", X"38", X"20", X"20", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"01", X"01", X"07", X"FE", X"FC",
   X"F0", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"20", X"20", X"38", X"1F", X"0F", X"03", X"00", X"00", X"00",
   X"00", X"00", X"00", X"00", X"00", X"00", X"98", X"B8", X"E0", X"F8", X"F8", X"E0", X"B8", X"98", X"00", X"00", X"00", X"00", X"00", X"00",
   X"00", X"00", X"0C", X"0E", X"03", X"0F", X"0F", X"03", X"0E", X"0C", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"80", X"80",
   X"80", X"F0", X"F0", X"80", X"80", X"80", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"01", X"01", X"01", X"0F", X"0F", X"01",
   X"01", X"01", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
   X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"B8", X"F8", X"78", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
   X"00", X"00", X"80", X"80", X"80", X"80", X"80", X"80", X"80", X"80", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"01", X"01",
   X"01", X"01", X"01", X"01", X"01", X"01", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
   X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"38", X"38", X"38", X"00", X"00", X"00", X"00", X"00",
   X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"80", X"C0", X"E0", X"70", X"38", X"1C", X"0E", X"00", X"00", X"00", X"00",
   X"00", X"18", X"1C", X"0E", X"07", X"03", X"01", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"F8", X"FE", X"06",
   X"03", X"83", X"C3", X"63", X"33", X"1E", X"FE", X"F8", X"00", X"00", X"00", X"00", X"00", X"07", X"1F", X"1E", X"33", X"31", X"30", X"30",
   X"30", X"18", X"1F", X"07", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"0C", X"0C", X"0E", X"FF", X"FF", X"00", X"00", X"00", X"00",
   X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"30", X"30", X"30", X"3F", X"3F", X"30", X"30", X"30", X"00", X"00", X"00", X"00", X"00",
   X"00", X"1C", X"1E", X"07", X"03", X"03", X"83", X"C3", X"E3", X"77", X"3E", X"1C", X"00", X"00", X"00", X"00", X"00", X"30", X"38", X"3C",
   X"3E", X"37", X"33", X"31", X"30", X"30", X"30", X"30", X"00", X"00", X"00", X"00", X"00", X"0C", X"0E", X"07", X"C3", X"C3", X"C3", X"C3",
   X"C3", X"E7", X"7E", X"3C", X"00", X"00", X"00", X"00", X"00", X"0C", X"1C", X"38", X"30", X"30", X"30", X"30", X"30", X"39", X"1F", X"0E",
   X"00", X"00", X"00", X"00", X"00", X"C0", X"E0", X"70", X"38", X"1C", X"0E", X"07", X"FF", X"FF", X"00", X"00", X"00", X"00", X"00", X"00",
   X"00", X"03", X"03", X"03", X"03", X"03", X"03", X"03", X"3F", X"3F", X"03", X"03", X"00", X"00", X"00", X"00", X"00", X"3F", X"7F", X"63",
   X"63", X"63", X"63", X"63", X"63", X"E3", X"C3", X"83", X"00", X"00", X"00", X"00", X"00", X"0C", X"1C", X"38", X"30", X"30", X"30", X"30",
   X"30", X"38", X"1F", X"0F", X"00", X"00", X"00", X"00", X"00", X"C0", X"F0", X"F8", X"DC", X"CE", X"C7", X"C3", X"C3", X"C3", X"80", X"00",
   X"00", X"00", X"00", X"00", X"00", X"0F", X"1F", X"39", X"30", X"30", X"30", X"30", X"30", X"39", X"1F", X"0F", X"00", X"00", X"00", X"00",
   X"00", X"03", X"03", X"03", X"03", X"03", X"03", X"C3", X"F3", X"3F", X"0F", X"03", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
   X"30", X"3C", X"0F", X"03", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"BC", X"FE", X"E7", X"C3", X"C3", X"C3",
   X"E7", X"FE", X"BC", X"00", X"00", X"00", X"00", X"00", X"00", X"0F", X"1F", X"39", X"30", X"30", X"30", X"30", X"30", X"39", X"1F", X"0F",
   X"00", X"00", X"00", X"00", X"00", X"3C", X"7E", X"E7", X"C3", X"C3", X"C3", X"C3", X"C3", X"E7", X"FE", X"FC", X"00", X"00", X"00", X"00",
   X"00", X"00", X"00", X"30", X"30", X"30", X"38", X"1C", X"0E", X"07", X"03", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
   X"70", X"70", X"70", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"1C", X"1C", X"1C", X"00",
   X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"70", X"70", X"70", X"00", X"00", X"00", X"00", X"00",
   X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"9C", X"FC", X"7C", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
   X"00", X"00", X"C0", X"E0", X"F0", X"38", X"1C", X"0E", X"07", X"03", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"01",
   X"03", X"07", X"0E", X"1C", X"38", X"30", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"60", X"60", X"60", X"60", X"60", X"60",
   X"60", X"60", X"60", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"06", X"06", X"06", X"06", X"06", X"06", X"06", X"06", X"06", X"00",
   X"00", X"00", X"00", X"00", X"00", X"00", X"03", X"07", X"0E", X"1C", X"38", X"F0", X"E0", X"C0", X"00", X"00", X"00", X"00", X"00", X"00",
   X"00", X"00", X"30", X"38", X"1C", X"0E", X"07", X"03", X"01", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"1C", X"1E", X"07",
   X"03", X"83", X"C3", X"E3", X"77", X"3E", X"1C", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"37", X"37", X"00",
   X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");

   SIGNAL output_reg : STD_LOGIC_VECTOR(7 downto 0);
   
   
BEGIN


   PROCESS (clka)
   BEGIN
      IF clka'event and clka = '1' THEN
         if ena = '1' then
            if wea(0) = '1' then
               RAM(conv_integer(addra)) <= dina;
               output_reg <= dina;
            else
               output_reg <= RAM(conv_integer(addra));
            end if;
            douta <= output_reg;
         end if;
      END IF;
   END PROCESS;
      
	  
END syn;






LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;



ENTITY BLOCK_RAM_CORE_ZYBO IS
PORT(
   clka  : IN  STD_LOGIC;
   wea   : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
   ena   : IN  STD_LOGIC;
   addra : IN  STD_LOGIC_VECTOR(9 downto 0);
   dina  : IN  STD_LOGIC_VECTOR(7 downto 0);
   douta : OUT STD_LOGIC_VECTOR(7 downto 0));
END BLOCK_RAM_CORE_ZYBO;



ARCHITECTURE syn OF BLOCK_RAM_CORE_ZYBO IS

   TYPE ram_type IS ARRAY (0 TO 1023) OF STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL RAM: ram_type := (
   X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"3E", X"45", X"51", X"45", X"3E", X"00", X"00", X"00", X"3E", X"6B", X"6F",
   X"6B", X"3E", X"00", X"00", X"00", X"1C", X"3E", X"7C", X"3E", X"1C", X"00", X"00", X"00", X"18", X"3C", X"7E", X"3C", X"18", X"00", X"00",
   X"00", X"30", X"36", X"7F", X"36", X"30", X"00", X"00", X"00", X"18", X"5C", X"7E", X"5C", X"18", X"00", X"00", X"00", X"00", X"00", X"00",
   X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
   X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"30", X"48", X"4A", X"36", X"0E", X"00", X"00", X"00", X"06", X"29", X"79",
   X"29", X"06", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"60", X"7E", X"0A", X"35", X"3F", X"00", X"00",
   X"00", X"2A", X"1C", X"36", X"1C", X"2A", X"00", X"00", X"00", X"00", X"7F", X"3E", X"1C", X"08", X"00", X"00", X"00", X"08", X"1C", X"3E",
   X"7F", X"00", X"00", X"00", X"00", X"14", X"36", X"7F", X"36", X"14", X"00", X"00", X"00", X"00", X"5F", X"00", X"5F", X"00", X"00", X"00",
   X"00", X"06", X"09", X"7F", X"01", X"7F", X"00", X"00", X"00", X"22", X"4D", X"55", X"59", X"22", X"00", X"00", X"00", X"60", X"60", X"60",
   X"60", X"00", X"00", X"00", X"00", X"14", X"B6", X"FF", X"B6", X"14", X"00", X"00", X"00", X"04", X"06", X"7F", X"06", X"04", X"00", X"00",
   X"00", X"10", X"30", X"7F", X"30", X"10", X"00", X"00", X"00", X"08", X"08", X"3E", X"1C", X"08", X"00", X"00", X"00", X"08", X"1C", X"3E",
   X"08", X"08", X"00", X"00", X"00", X"78", X"40", X"40", X"40", X"40", X"00", X"00", X"00", X"08", X"3E", X"08", X"3E", X"08", X"00", X"00",
   X"00", X"30", X"3C", X"3F", X"3C", X"30", X"00", X"00", X"00", X"03", X"0F", X"3F", X"0F", X"03", X"00", X"00", X"00", X"00", X"00", X"00",
   X"00", X"00", X"00", X"00", X"00", X"00", X"06", X"5F", X"06", X"00", X"00", X"00", X"00", X"07", X"03", X"00", X"07", X"03", X"00", X"00",
   X"00", X"24", X"7E", X"24", X"7E", X"24", X"00", X"00", X"00", X"24", X"2B", X"6A", X"12", X"00", X"00", X"00", X"00", X"63", X"13", X"08",
   X"64", X"63", X"00", X"00", X"00", X"36", X"49", X"56", X"20", X"50", X"00", X"00", X"00", X"00", X"07", X"03", X"00", X"00", X"00", X"00",
   X"00", X"00", X"3E", X"41", X"00", X"00", X"00", X"00", X"00", X"00", X"41", X"3E", X"00", X"00", X"00", X"00", X"00", X"08", X"3E", X"1C",
   X"3E", X"08", X"00", X"00", X"00", X"08", X"08", X"3E", X"08", X"08", X"00", X"00", X"00", X"00", X"E0", X"60", X"00", X"00", X"00", X"00",
   X"00", X"08", X"08", X"08", X"08", X"08", X"00", X"00", X"00", X"00", X"60", X"60", X"00", X"00", X"00", X"00", X"00", X"20", X"10", X"08",
   X"04", X"02", X"00", X"00", X"00", X"3E", X"51", X"49", X"45", X"3E", X"00", X"00", X"00", X"00", X"42", X"7F", X"40", X"00", X"00", X"00",
   X"00", X"62", X"51", X"49", X"49", X"46", X"00", X"00", X"00", X"22", X"49", X"49", X"49", X"36", X"00", X"00", X"00", X"18", X"14", X"12",
   X"7F", X"10", X"00", X"00", X"00", X"2F", X"49", X"49", X"49", X"31", X"00", X"00", X"00", X"3C", X"4A", X"49", X"49", X"30", X"00", X"00",
   X"00", X"01", X"71", X"09", X"05", X"03", X"00", X"00", X"00", X"36", X"49", X"49", X"49", X"36", X"00", X"00", X"00", X"06", X"49", X"49",
   X"29", X"1E", X"00", X"00", X"00", X"00", X"6C", X"6C", X"00", X"00", X"00", X"00", X"00", X"00", X"EC", X"6C", X"00", X"00", X"00", X"00",
   X"00", X"08", X"14", X"22", X"41", X"00", X"00", X"00", X"00", X"24", X"24", X"24", X"24", X"24", X"00", X"00", X"00", X"00", X"41", X"22",
   X"14", X"08", X"00", X"00", X"00", X"02", X"01", X"59", X"09", X"06", X"00", X"00", X"00", X"3E", X"41", X"5D", X"55", X"1E", X"00", X"00",
   X"00", X"7E", X"11", X"11", X"11", X"7E", X"00", X"00", X"00", X"7F", X"49", X"49", X"49", X"36", X"00", X"00", X"00", X"3E", X"41", X"41",
   X"41", X"22", X"00", X"00", X"00", X"7F", X"41", X"41", X"41", X"3E", X"00", X"00", X"00", X"7F", X"49", X"49", X"49", X"41", X"00", X"00",
   X"00", X"7F", X"09", X"09", X"09", X"01", X"00", X"00", X"00", X"3E", X"41", X"49", X"49", X"7A", X"00", X"00", X"00", X"7F", X"08", X"08",
   X"08", X"7F", X"00", X"00", X"00", X"00", X"41", X"7F", X"41", X"00", X"00", X"00", X"00", X"30", X"40", X"40", X"40", X"3F", X"00", X"00",
   X"00", X"7F", X"08", X"14", X"22", X"41", X"00", X"00", X"00", X"7F", X"40", X"40", X"40", X"40", X"00", X"00", X"00", X"7F", X"02", X"04",
   X"02", X"7F", X"00", X"00", X"00", X"7F", X"02", X"04", X"08", X"7F", X"00", X"00", X"00", X"3E", X"41", X"41", X"41", X"3E", X"00", X"00",
   X"00", X"7F", X"09", X"09", X"09", X"06", X"00", X"00", X"00", X"3E", X"41", X"51", X"21", X"5E", X"00", X"00", X"00", X"7F", X"09", X"09",
   X"19", X"66", X"00", X"00", X"00", X"26", X"49", X"49", X"49", X"32", X"00", X"00", X"00", X"01", X"01", X"7F", X"01", X"01", X"00", X"00",
   X"00", X"3F", X"40", X"40", X"40", X"3F", X"00", X"00", X"00", X"1F", X"20", X"40", X"20", X"1F", X"00", X"00", X"00", X"3F", X"40", X"3C",
   X"40", X"3F", X"00", X"00", X"00", X"63", X"14", X"08", X"14", X"63", X"00", X"00", X"00", X"07", X"08", X"70", X"08", X"07", X"00", X"00",
   X"00", X"71", X"49", X"45", X"43", X"00", X"00", X"00", X"00", X"00", X"7F", X"41", X"41", X"00", X"00", X"00", X"00", X"02", X"04", X"08",
   X"10", X"20", X"00", X"00", X"00", X"00", X"41", X"41", X"7F", X"00", X"00", X"00", X"00", X"04", X"02", X"01", X"02", X"04", X"00", X"00",
   X"80", X"80", X"80", X"80", X"80", X"80", X"00", X"00", X"00", X"00", X"03", X"07", X"00", X"00", X"00", X"00", X"00", X"20", X"54", X"54",
   X"54", X"78", X"00", X"00", X"00", X"7F", X"44", X"44", X"44", X"38", X"00", X"00", X"00", X"38", X"44", X"44", X"44", X"28", X"00", X"00",
   X"00", X"38", X"44", X"44", X"44", X"7F", X"00", X"00", X"00", X"38", X"54", X"54", X"54", X"08", X"00", X"00", X"00", X"08", X"7E", X"09",
   X"09", X"00", X"00", X"00", X"00", X"18", X"A4", X"A4", X"A4", X"7C", X"00", X"00", X"00", X"7F", X"04", X"04", X"78", X"00", X"00", X"00",
   X"00", X"00", X"00", X"7D", X"40", X"00", X"00", X"00", X"00", X"40", X"80", X"84", X"7D", X"00", X"00", X"00", X"00", X"7F", X"10", X"28",
   X"44", X"00", X"00", X"00", X"00", X"00", X"00", X"7F", X"40", X"00", X"00", X"00", X"00", X"7C", X"04", X"18", X"04", X"78", X"00", X"00",
   X"00", X"7C", X"04", X"04", X"78", X"00", X"00", X"00", X"00", X"38", X"44", X"44", X"44", X"38", X"00", X"00", X"00", X"FC", X"44", X"44",
   X"44", X"38", X"00", X"00", X"00", X"38", X"44", X"44", X"44", X"FC", X"00", X"00", X"00", X"44", X"78", X"44", X"04", X"08", X"00", X"00",
   X"00", X"08", X"54", X"54", X"54", X"20", X"00", X"00", X"00", X"04", X"3E", X"44", X"24", X"00", X"00", X"00", X"00", X"3C", X"40", X"20",
   X"7C", X"00", X"00", X"00", X"00", X"1C", X"20", X"40", X"20", X"1C", X"00", X"00", X"00", X"3C", X"60", X"30", X"60", X"3C", X"00", X"00",
   X"00", X"6C", X"10", X"10", X"6C", X"00", X"00", X"00", X"00", X"9C", X"A0", X"60", X"3C", X"00", X"00", X"00", X"00", X"64", X"54", X"54",
   X"4C", X"00", X"00", X"00", X"00", X"08", X"3E", X"41", X"41", X"00", X"00", X"00", X"00", X"00", X"00", X"77", X"00", X"00", X"00", X"00",
   X"00", X"00", X"41", X"41", X"3E", X"08", X"00", X"00", X"00", X"02", X"01", X"02", X"01", X"00", X"00", X"00", X"00", X"3C", X"26", X"23",
   X"26", X"3C", X"00", X"00");

   SIGNAL output_reg : STD_LOGIC_VECTOR(7 downto 0);
   
   
BEGIN


   PROCESS (clka)
   BEGIN
      IF clka'event and clka = '1' THEN
         if ena = '1' then
            if wea(0) = '1' then
               RAM(conv_integer(addra)) <= dina;
               output_reg <= dina;
            else
               output_reg <= RAM(conv_integer(addra));
            end if;
            douta <= output_reg;
         end if;
      END IF;
   END PROCESS;


END syn;






LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;



ENTITY SMALL_FIFO_ZYBO IS
PORT(
   clk   : IN  STD_LOGIC;
   rst   : IN  STD_LOGIC;
   din   : IN  STD_LOGIC_VECTOR(7 downto 0);
   wr_en : IN  STD_LOGIC;
   rd_en : IN  STD_LOGIC;
   dout  : OUT STD_LOGIC_VECTOR(7 downto 0);
   empty : OUT STD_LOGIC;
   full  : OUT STD_LOGIC);
END SMALL_FIFO_ZYBO;



ARCHITECTURE Behavioral OF SMALL_FIFO_ZYBO IS


   SIGNAL readPTR, writePTR : STD_LOGIC_VECTOR(3 downto 0);
  
   SUBTYPE wrdtype IS std_logic_vector(7 downto 0);
   TYPE regtype IS ARRAY(0 TO ((2**(readPTR'length))-1)) OF wrdtype;
   SIGNAL fifoMEM : regtype;
  
   SIGNAL storage_delay_0, storage_delay_1 : STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL writePTR_delay_0, writePTR_delay_1 : STD_LOGIC_VECTOR(3 downto 0);

   SIGNAL storage_done_0, storage_done_1 : STD_LOGIC;
   SIGNAL full_i, empty_i : STD_LOGIC;
   --SIGNAL dout_i : STD_LOGIC_VECTOR(7 downto 0);

  
BEGIN

   --dout <= dout_i;
   full <= full_i;
   empty <= empty_i;

   PROCESS (rst, clk)
   BEGIN
      IF rst = '1' THEN
         readPTR <= (others => '0');
		 writePTR <= (others => '0');
		 writePTR_delay_0 <= (others => '0');
		 writePTR_delay_1 <= (others => '0');
		 storage_delay_0 <= (others => '0');
		 storage_delay_1 <= (others => '0');
		 empty_i <= '1';
		 storage_done_0 <= '0';
		 storage_done_1 <= '0';
		 full_i <= '0';
      ELSIF rising_edge(clk) THEN
         if full_i = '0' then
            writePTR_delay_1 <= writePTR_delay_0;
            storage_delay_1 <= storage_delay_0;
            storage_done_0 <= '0';
            storage_done_1 <= storage_done_0;
         end if;
         if storage_done_1 = '1' then
            empty_i <= '0';
            if (readPTR = writePTR_delay_1) and (empty_i = '0') then
               full_i <= '1';
            else
               if full_i = '0' then
                  fifoMEM(conv_integer(writePTR_delay_1)) <= storage_delay_1;
               end if;
            end if;
         else
            if full_i = '0' then
               fifoMEM(conv_integer(writePTR_delay_1)) <= storage_delay_1;
            end if;
         end if;
         if wr_en = '1' and full_i = '0' then
            writePTR_delay_0 <= writePTR;
            storage_delay_0 <= din;
            storage_done_0 <= '1';
            writePTR <= writePTR + '1';
         end if;
         if rd_en = '1' then
            if readPTR = writePTR_delay_1 and full_i = '0' and storage_done_1 = '0' then
               empty_i <= '1';
            end if;
            full_i <= '0';
            readPTR <= readPTR + '1';
         end if;
         if empty_i = '0' and not (wr_en = '1' and rd_en = '1') then
            dout <= fifoMEM(conv_integer(readPTR));
         end if;
      END IF;
   END PROCESS;

   --dout_i <= fifoMEM(conv_integer(readPTR)) when (empty_i = '0') and not (wr_en = '1' and rd_en = '1') else dout_i;

   
END Behavioral;






LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;



ENTITY BICYCLE_LCD_MASTER IS
PORT( 
   CLK_i           : IN    STD_LOGIC;
   RST_i           : IN    STD_LOGIC;
   AVS             : IN    STD_LOGIC;
   DAY             : IN    STD_LOGIC;
   MAX             : IN    STD_LOGIC;
   TIM             : IN    STD_LOGIC;
   POINT           : IN    STD_LOGIC;				
   colon           : IN    STD_LOGIC;
   KMH             : IN    STD_LOGIC_VECTOR(0 downto 0);
   LOWER1_ASCII    : IN    STD_LOGIC_VECTOR(7 downto 0);
   LOWER10_ASCII   : IN    STD_LOGIC_VECTOR(7 downto 0);
   LOWER100_ASCII  : IN    STD_LOGIC_VECTOR(7 downto 0);
   LOWER1000_ASCII : IN    STD_LOGIC_VECTOR(7 downto 0);
   UPPER1_ASCII    : IN    STD_LOGIC_VECTOR(7 downto 0);
   UPPER10_ASCII   : IN    STD_LOGIC_VECTOR(7 downto 0);
   WB_ACK_I        : IN    STD_LOGIC;
   WB_WE_O         : OUT   STD_LOGIC;
   WB_CYC_IO       : INOUT STD_LOGIC; 
   WB_STB_O        : OUT   STD_LOGIC;
   WB_Addr_O       : OUT   STD_LOGIC_VECTOR(7 downto 0);
   WB_DATA_OUT     : OUT   STD_LOGIC_VECTOR(7 downto 0));
END BICYCLE_LCD_MASTER;



ARCHITECTURE Behavioral2 OF BICYCLE_LCD_MASTER IS


FUNCTION or_reduce (v : IN STD_LOGIC_VECTOR) RETURN STD_LOGIC IS
 VARIABLE result : STD_LOGIC := '0';
BEGIN
   for i in v'RANGE loop
      result := result or v(i);
   end loop;
RETURN result;
END FUNCTION or_reduce;

COMPONENT CMD_FIFO_TO_WB_MASTER
PORT(
   CLK          : IN    STD_LOGIC;
   RESET        : IN    STD_LOGIC;
   FIFO_DATA_IN : IN    STD_LOGIC_VECTOR(7 downto 0);
   FIFO_EMPTY   : IN    STD_LOGIC;
   FIFO_RD_EN   : OUT   STD_LOGIC;
   ACK_I        : IN    STD_LOGIC;    
   CYC_IO       : INOUT STD_LOGIC;	
   WE_O         : OUT   STD_LOGIC;
   STB_O        : OUT   STD_LOGIC;
   Addr_O       : OUT   STD_LOGIC_VECTOR(7 downto 0);
   BUS_DATA_OUT : OUT   STD_LOGIC_VECTOR(7 downto 0));
END COMPONENT;

COMPONENT SMALL_FIFO_ZYBO
PORT(
   CLK   : IN  STD_LOGIC;
   RST   : IN  STD_LOGIC;
   DIN   : IN  STD_LOGIC_VECTOR(7 downto 0);
   WR_EN : IN  STD_LOGIC;	
   RD_EN : IN  STD_LOGIC;
   DOUT  : OUT STD_LOGIC_VECTOR(7 downto 0);	
   FULL  : OUT STD_LOGIC;
   EMPTY : OUT STD_LOGIC);
END COMPONENT;

TYPE state_type IS ( RESET , INIT1 , INIT2 , INIT3 , INIT4 , INIT5 , INIT6 , DEBUG_STATE , DISP_INIT_VALUES , CHECK_SIG_CHANGE , FIND_SIG_CHANGE , SET_UP_TRANSFER ,
					      SET_CH_MODE , SET_CURSOR_X_POS , SET_CURSOR_Y_POS , TANSMITT_CHAR , WAIT_FOR_WB_FIFO_ADDR , WAIT_FOR_WB_FIFO_CMD , TANSMITT_WB_ADDR , TRANSMITT_WB_DATA ); 
SIGNAL state , next_state , state2 , next_state2 , stateAfterTransmitt , next_stateAfterTransmitt , stateAfterSetup , next_stateAfterSetup : state_type;

--TYPE state_type IS ( RESET , INIT2 , INIT3 , INIT4 , INIT5 , INIT6 , DEBUG_STATE , DISP_INIT_VALUES , CHECK_SIG_CHANGE , SET_UP_TRANSFER , SET_CURSOR_X_POS , SET_CURSOR_Y_POS , TANSMITT_CHAR); 
--SIGNAL state2 , next_state2 , stateAfterTransmitt , next_stateAfterTransmitt , stateAfterSetup , next_stateAfterSetup : state_type;

SIGNAL iFIFO_DIN : STD_LOGIC_VECTOR(7 downto 0);
SIGNAL iFIFO_DOUT : STD_LOGIC_VECTOR(7 downto 0);
SIGNAL iFIFO_WR_EN , iFIFO_RD_EN : STD_LOGIC;
SIGNAL iFIFO_FULL, iFIFO_EMPTY : STD_LOGIC;
--SIGNAL iwb_addr : STD_LOGIC_VECTOR(7 downto 0);
SIGNAL iwb_addr : STD_LOGIC_VECTOR(2 downto 0);
SIGNAL iwb_data : STD_LOGIC_VECTOR(7 downto 0);

TYPE disp_str_type IS ARRAY (9 downto 0) OF STD_LOGIC_VECTOR(7 downto 0);
SIGNAL display_string : disp_str_type;

SIGNAL iCH_counter : UNSIGNED(3 downto 0);
SIGNAL iSegCounter : UNSIGNED(1 downto 0);
SIGNAL iCh_y_pos : UNSIGNED(7 downto 0);
SIGNAL iCh_x_pos : UNSIGNED(7 downto 0);
SIGNAL imode_reg : STD_LOGIC_VECTOR(2 downto 0);
SIGNAL iSig_change_detector , iSig_change_reg : STD_LOGIC_VECTOR(13 downto 0);
SIGNAL iSig_change_idx : UNSIGNED(3 downto 0);
SIGNAL iAVS : STD_LOGIC;
SIGNAL iDAY : STD_LOGIC;
SIGNAL iMAX : STD_LOGIC;
SIGNAL iTIM : STD_LOGIC;
SIGNAL iPOINT : STD_LOGIC;				
SIGNAL icolon : STD_LOGIC;
SIGNAL iLOWER1_ASCII : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL iLOWER10_ASCII : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL iLOWER100_ASCII : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL iLOWER1000_ASCII : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL iUPPER1_ASCII : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL iUPPER10_ASCII : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL newSigValues : STD_LOGIC_VECTOR(13 downto 0);

TYPE disp_def_entry_type IS RECORD		
   disp_string : STRING(10 downto 1);
   str_len     : NATURAL;
   num_seg     : NATURAL;
   pos_x       : NATURAL;
   pos_y       : NATURAL;
   char_mode   : STD_LOGIC_VECTOR(2 downto 0);
END RECORD disp_def_entry_type;
TYPE disp_def_type IS ARRAY (13 downto 0) OF disp_def_entry_type;

TYPE disp_signal_entry_type IS RECORD		
   disp_string : disp_str_type;
   str_len     : UNSIGNED(3 downto 0);
   num_seg     : UNSIGNED(1 downto 0);
   pos_x       : UNSIGNED(7	downto 0);
   pos_y       : UNSIGNED(7 downto 0);
   char_mode   : STD_LOGIC_VECTOR(2 downto 0);
END RECORD disp_signal_entry_type;

FUNCTION setDisplDef(seg_num, show_kmh : in NATURAL range 3 downto 0) RETURN disp_def_type IS
 VARIABLE retVal : disp_def_type;	
BEGIN
   if(seg_num = 0) then
      --DAY
      retVal(0).disp_string(3 downto 1) := "DAY";
      retVal(0).str_len := 3;
      retVal(0).num_seg := 1;
      retVal(0).pos_x := 2;
      retVal(0).pos_y := 2;
      retVal(0).char_mode := "010";
      --AVS
      retVal(1).disp_string(3 downto 1) := "AVS";
      retVal(1).str_len := 3;
      retVal(1).num_seg := 1;
      retVal(1).pos_x := 2;
      retVal(1).pos_y := 3;
      retVal(1).char_mode := "010";
      --TIM
      retVal(2).disp_string(3 downto 1) := "TIM";
      retVal(2).str_len := 3;
      retVal(2).num_seg := 1;
      retVal(2).pos_x := 2;
      retVal(2).pos_y := 4;
      retVal(2).char_mode := "010";
      --MAX
      retVal(3).disp_string(3 downto 1) := "MAX";
      retVal(3).str_len := 3;
      retVal(3).num_seg := 1;
      retVal(3).pos_x := 2;
      retVal(3).pos_y := 5;
      retVal(3).char_mode := "010";
      --HighSpeed
      retVal(13).disp_string(1 downto 1) := " "; --not used
      retVal(13).str_len := 1;
      retVal(13).num_seg := 1;
      retVal(13).pos_x := 1;
      retVal(13).pos_y := 1;
      retVal(13).char_mode := "010";
      --DECIMAL POINT
      retVal(4).disp_string(1 downto 1) := ".";
      retVal(4).str_len := 1;
      retVal(4).num_seg := 1;
      retVal(4).pos_x := 16;
      retVal(4).pos_y := 6;
      retVal(4).char_mode := "010";
      --COLON : num_seg = 2 --> definition of 2. seg is at the end below
      --1. seg (upper dot)
      retVal(5).disp_string(1) := BEL;--character'val(7); --use special made character at pos 7 in ascii table
      retVal(5).str_len := 1;
      retVal(5).num_seg := 2;
      retVal(5).pos_x := 13;
      retVal(5).pos_y := 5;
      retVal(5).char_mode := "010";
      --Lower1
      retVal(6).str_len := 1;
      retVal(6).pos_x := 17;
      retVal(6).num_seg := 1;
      retVal(6).pos_y := 5;
      retVal(6).char_mode := "100";
      --Lower10
      retVal(7).str_len := 1;
      retVal(7).pos_x := 14;
      retVal(7).num_seg := 1;
      retVal(7).pos_y := 5;
      retVal(7).char_mode := "100";
      --Lower100
      retVal(8).str_len := 1;
      retVal(8).pos_x := 11;
      retVal(8).num_seg := 1;
      retVal(8).pos_y := 5;
      retVal(8).char_mode := "100";
      --Lower1000
      retVal(9).str_len := 1;
      retVal(9).pos_x := 8;
      retVal(9).num_seg := 1;
      retVal(9).pos_y := 5;
      retVal(9).char_mode := "100";
      --upper1
      retVal(10).str_len := 1;
      retVal(10).pos_x := 14;
      retVal(10).num_seg := 1;
      retVal(10).pos_y := 1;
      retVal(10).char_mode := "100";
      --upper10
      retVal(11).str_len := 1;
      retVal(11).pos_x := 12;
      retVal(11).num_seg := 1;
      retVal(11).pos_y := 1;
      retVal(11).char_mode := "100";
      if (show_kmh = 1) then
         retVal(12).disp_string(3 downto 1) := "kmh";
      else
         retVal(12).disp_string(3 downto 1) := "   ";
      end if;
      retVal(12).str_len := 3;
      retVal(12).num_seg := 1;
      retVal(12).pos_x := 17;
      retVal(12).pos_y := 2;
      retVal(12).char_mode := "010";
   elsif(seg_num = 1) then
      --COLON
      -- 2. seg of colon (lower dot)
      retVal(5).disp_string(1) :=  BEL;--character'val(7); --use special made character at pos 7 in ascii table
      retVal(5).str_len := 1;
      retVal(5).num_seg := 1;
      retVal(5).pos_x := 13;
      retVal(5).pos_y := 6;
      retVal(5).char_mode := "010";
   end if;
RETURN retVal;
END FUNCTION setDisplDef;

FUNCTION convDispDefToDispSig(inVal : in disp_def_entry_type) RETURN disp_signal_entry_type IS
 VARIABLE retVal : disp_signal_entry_type;
BEGIN
   --AVS
   for i in 0 to inVal.disp_string'length-1 loop
      retVal.disp_string(i) := STD_LOGIC_VECTOR(to_unsigned(character'pos(inVal.disp_string(i+1)),retVal.disp_string(0)'length));
   end loop;
   retVal.str_len := to_unsigned(inVal.str_len,retVal.str_len'length); 
   retVal.num_seg := to_unsigned(inVal.num_seg,retVal.num_seg'length); 
   retVal.pos_x := to_unsigned(inVal.pos_x,retVal.pos_x'length); 
   retVal.pos_y := to_unsigned(inVal.pos_y,retVal.pos_y'length); 
   retVal.char_mode := inVal.char_mode;
RETURN retVal;
END FUNCTION convDispDefToDispSig;


BEGIN


   newSigValues(0) <= DAY;
   newSigValues(1) <= AVS;
   newSigValues(2) <= TIM;
   newSigValues(3) <= MAX;
   newSigValues(13) <= '0';
   newSigValues(4) <= POINT;
   newSigValues(5) <= colon;
   newSigValues(6) <= '0';
   newSigValues(7) <= '0';
   newSigValues(8) <= '0';
   newSigValues(9) <= '0';
   newSigValues(10) <= '0';
   newSigValues(11) <= '0';
   newSigValues(12) <= '1'; 
   iSig_change_detector(0)  <= '1' when ((iDAY /= DAY)) else '0';
   iSig_change_detector(1)  <= '1' when (iAVS /= AVS) else '0';
   iSig_change_detector(2)  <= '1' when ((iTIM /= TIM)) else '0';
   iSig_change_detector(3)  <= '1' when ((iMAX /= MAX)) else '0';
   iSig_change_detector(13) <= '0';
   iSig_change_detector(4)  <= '1' when ((iPOINT /= POINT)) else '0';
   iSig_change_detector(5)  <= '1' when ((icolon /= colon)) else '0';
   iSig_change_detector(6)  <= '1' when ((iLOWER1_ASCII /= LOWER1_ASCII)) else '0';
   iSig_change_detector(7)  <= '1' when ((iLOWER10_ASCII /= LOWER10_ASCII)) else '0';
   iSig_change_detector(8)  <= '1' when ((iLOWER100_ASCII /= LOWER100_ASCII)) else '0';
   iSig_change_detector(9)  <= '1' when ((iLOWER1000_ASCII /= LOWER1000_ASCII)) else '0';
   iSig_change_detector(10) <= '1' when ((iUPPER1_ASCII /= UPPER1_ASCII)) else '0';
   iSig_change_detector(11) <= '1' when ((iUPPER10_ASCII /= UPPER10_ASCII)) else '0';
   iSig_change_detector(12) <= '0'; --kmh tag only printed initially but never changes
					
   WB_CMD_FIFO_TO_WB_MASTER : CMD_FIFO_TO_WB_MASTER
   PORT MAP(
      CLK          => CLK_i,
      RESET        => RST_i,
      FIFO_DATA_IN => iFIFO_DOUT,
      FIFO_RD_EN   => iFIFO_RD_EN,
      FIFO_EMPTY   => iFIFO_EMPTY,
      ACK_I        => WB_ACK_I,
      WE_O         => WB_WE_O,
      CYC_IO       => WB_CYC_IO,
      STB_O        => WB_STB_O,
      Addr_O       => WB_Addr_O,
      BUS_DATA_OUT => WB_DATA_OUT);

   WB_CMD_FIFO: SMALL_FIFO_ZYBO
   PORT MAP(
      clk   => CLK_i,
      rst   => RST_i,
      din   => iFIFO_DIN,
      wr_en => iFIFO_WR_EN,
      rd_en => iFIFO_RD_EN,
      dout  => iFIFO_DOUT,
      full  => iFIFO_FULL,
      empty => iFIFO_EMPTY);
      
   NEXT_STATE_PROC: PROCESS (CLK_i,RST_i)
   BEGIN
      IF (RST_i = '1') THEN
         state <= RESET;	
         state2 <= RESET;	
         stateAfterTransmitt <= RESET;
         stateAfterSetup <= RESET;
      ELSIF rising_edge(CLK_i) THEN
         state <= next_state;	
         state2 <= next_state2;
         stateAfterTransmitt <= next_stateAfterTransmitt;
         stateAfterSetup <= next_stateAfterSetup;
      END IF;
   END PROCESS;
    
   SYNC_OUTPUT_PROC: PROCESS (CLK_i,RST_i)
    VARIABLE char_table : character;
    VARIABLE currDispSigEntry : disp_signal_entry_type;
   BEGIN 		
      IF (RST_i = '1') THEN
         iFIFO_DIN <= (others => '0');
         iFIFO_WR_EN <= '0';
         iwb_addr <= (others => '0');
         iwb_data <= (others => '0');
         display_string <= (others => "00100000");
         iCH_counter <= to_unsigned(1,iCH_counter'length);
         iSegCounter <= to_unsigned(1,iSegCounter'length);
         iCh_y_pos <= (others => '0');
         iCh_x_pos <= (others => '0');
         imode_reg <= "010";
         iSig_change_idx <= (others => '0');
         iSig_change_reg <= (others => '0');
         iAVS <= '0';
         iDAY <= '0';
         iMAX <= '0';
         iTIM <= '0';
         iPOINT <= '0';
         icolon <= '0';
         iLOWER1_ASCII <= (others => '0');
         iLOWER10_ASCII <= (others => '0');
         iLOWER100_ASCII <= (others => '0');
         iLOWER1000_ASCII <= (others => '0');
         iUPPER1_ASCII <= (others => '0');
         iUPPER10_ASCII <= (others => '0');
      ELSIF rising_edge(CLK_i) THEN
         iFIFO_WR_EN <= '0';
         iAVS <= iAVS;
         iMAX <= iMAX;
         iTIM <= iTIM;
         iPOINT <= iPOINT;
         icolon <= icolon;
         iLOWER1_ASCII <= iLOWER1_ASCII;
         iLOWER10_ASCII <= iLOWER10_ASCII;
         iLOWER100_ASCII <= iLOWER100_ASCII;
         iUPPER1_ASCII <= iUPPER1_ASCII;
         iUPPER10_ASCII <= iUPPER10_ASCII;
         case (next_state) is
            when RESET =>
               iSig_change_idx <= (others => '0');
               iSig_change_reg  <= (others => '0');			
            when INIT1 => 						
               --iwb_addr <= "0000" & "0100";
               iwb_addr <= "010";
               iwb_data <= "0" & "00011" & "10";		
            when INIT2 => 
               --iwb_addr <= "0000" & "0100";
               iwb_addr <= "010";
               iwb_data <= "0" & "00010" & "00";	
            when INIT3 =>
               --iwb_addr <= "0000" & "1100";
               iwb_addr <= "110";
               iwb_data <= "10000001";				
            when INIT4 => 
               --iwb_addr <= "0000" & "1100";
               iwb_addr <= "110";
               iwb_data <= "00111111";
            when INIT5 => 
               --iwb_addr <= "0000" & "0100";
               iwb_addr <= "010";
               iwb_data <=  "0" & "00101" & "00" ;	
            when INIT6 =>
               --iwb_addr <= "0000" & "1110";
               iwb_addr <= "111";
               iwb_data <= "00000" & "100";
            when DEBUG_STATE =>
               iCH_counter <= to_unsigned(2,iCH_counter'length);					
               display_string(1) <= std_logic_vector(to_unsigned(character'pos('B'),display_string(0)'length));	
               display_string(0) <= std_logic_vector(to_unsigned(character'pos('C'),display_string(0)'length));					
            when DISP_INIT_VALUES =>
               iSig_change_reg <= (others => '0');				
               iSig_change_reg(to_integer(iSig_change_idx))  <= '1';
               if(iSegCounter = 1) then						
                  iSig_change_idx <= iSig_change_idx + 1;						
               end if;
            when CHECK_SIG_CHANGE =>		
               iSig_change_reg <= iSig_change_detector;		
               iSig_change_idx <= (others => '0');
            when FIND_SIG_CHANGE =>
               iSig_change_idx <= iSig_change_idx + 1;
            when SET_UP_TRANSFER =>
               currDispSigEntry := convDispDefToDispSig(setDisplDef(to_integer(iSegCounter - 1),to_integer(unsigned(KMH)))(to_integer(iSig_change_idx-1)));				
               iCH_counter <= currDispSigEntry.str_len;					
               iSegCounter <= currDispSigEntry.num_seg;
               iCh_y_pos <=  currDispSigEntry.pos_y;	
               iCh_x_pos <=  currDispSigEntry.pos_x;
               imode_reg <=  currDispSigEntry.char_mode;
               if(newSigValues(to_integer(iSig_change_idx-1)) = '1') then
                  display_string <= currDispSigEntry.disp_string;
               else
                  display_string <= (others => "00100000");
               end if;
               if(currDispSigEntry.num_seg = 1) then
                  case(to_integer(iSig_change_idx-1)) is	
                     when 0 =>						
                        iDAY <= DAY;
                     when 1=>						
                        iAVS <= AVS;												
                     when 2 =>						
                        iTIM <= TIM;						
                     when 3 =>						
                        iMAX <= MAX;						
                     when 4 =>
                        iPOINT  <= POINT ;					
                     when 5 =>						
                        icolon <= colon;	
                     when others =>
                        null;
                  end case;		
               end if;
               case(to_integer(iSig_change_idx-1)) is					
                  when 6 =>
                     iLOWER1_ASCII  <= LOWER1_ASCII ;					
                     display_string(0) <= std_logic_vector(RESIZE(unsigned(LOWER1_ASCII),8));	
                  when 7 =>
                     iLOWER10_ASCII <=LOWER10_ASCII;
                     display_string(0) <= std_logic_vector(RESIZE(unsigned(LOWER10_ASCII),8));	
                  when 8 =>
                     iLOWER100_ASCII <= LOWER100_ASCII;
                     display_string(0) <= std_logic_vector(RESIZE(unsigned(LOWER100_ASCII),8));	
                  when 9 =>
                     iLOWER1000_ASCII <= LOWER1000_ASCII;
                     display_string(0) <= std_logic_vector(RESIZE(unsigned(LOWER1000_ASCII),8));	
                  when 10 =>
                     iUPPER1_ASCII <= UPPER1_ASCII;
                     display_string(0) <= std_logic_vector(RESIZE(unsigned(UPPER1_ASCII),8));	
                  when 11 =>
                     iUPPER10_ASCII <= UPPER10_ASCII;
                     display_string(0) <= std_logic_vector(RESIZE(unsigned(UPPER10_ASCII),8));				
                  when others =>
                     null;
               end case;
            when SET_CH_MODE =>
               --iwb_addr <= "0000" & "1110";
               iwb_addr <= "111";
               iwb_data <= std_logic_vector(RESIZE(unsigned(imode_reg),iwb_data'length));
            when SET_CURSOR_X_POS =>
               --iwb_addr <= "0000" & "1000";
               iwb_addr <= "100";
               iwb_data <= std_logic_vector(iCh_x_pos);
               --if(std_logic_vector(iCh_x_pos) = "XXXXXXXX") then
                  --iwb_data <= iwb_data;
               --end if;
            when SET_CURSOR_Y_POS =>
               --iwb_addr <= "0000" & "1010";
               iwb_addr <= "101";
               iwb_data <= std_logic_vector(iCh_y_pos);
               --if(std_logic_vector(iCh_y_pos) = "XXXXXXXX") then
                  --iwb_data <= iwb_data;
               --end if;
            when TANSMITT_CHAR =>
               --iwb_addr <= "0000" & "0000";
               iwb_addr <= "000";
               iwb_data <= std_logic_vector(display_string(to_integer(iCH_counter - 1)));
               iCH_counter <= iCH_counter-1; 
               --if(std_logic_vector(display_string(to_integer(iCH_counter - 1))) = "XXXXXXXX") then
                  --iwb_data <= iwb_data;
               --end if;
            when TANSMITT_WB_ADDR =>
               iFIFO_DIN <= "0000" & iwb_addr & "0";
               iFIFO_WR_EN <= '1';			
            when TRANSMITT_WB_DATA =>
               iFIFO_DIN <= iwb_data;
               iFIFO_WR_EN <= '1';	
            when others =>
               null;
         end case;     
      END IF;		
   END PROCESS;
    
   NEXT_STATE_DECODE: PROCESS (state , state2 , stateAfterTransmitt , stateAfterSetup , iCH_counter , iFIFO_FUll , iSig_change_reg , iSig_change_idx , iSegCounter)
   BEGIN
      --declare default state for next_state to avoid latches
      next_state <= state;  --default is to stay in current state
      next_state2 <= state2;
      next_stateAfterTransmitt <= stateAfterTransmitt;
      next_stateAfterSetup <= stateAfterSetup;
      case (state) is
         when RESET =>
            next_state <= INIT1; 
         when INIT1 => 		
            --next_state <= DISP_INIT_VALUES; 
            next_state <= WAIT_FOR_WB_FIFO_ADDR; 
            next_state2 <= INIT2; 
         when INIT2 =>
            next_state <= WAIT_FOR_WB_FIFO_ADDR; 
            next_state2 <= INIT3; 
         when INIT3 => 
            next_state <= WAIT_FOR_WB_FIFO_ADDR; 
            next_state2 <= INIT4; 
         when INIT4 => 
            next_state <= WAIT_FOR_WB_FIFO_ADDR; 
            next_state2 <= INIT5; 
         when INIT5 => 
            next_state <= WAIT_FOR_WB_FIFO_ADDR; 
            next_state2 <= INIT6;
         when INIT6 => 
            next_state <= WAIT_FOR_WB_FIFO_ADDR; 
            next_state2 <= DISP_INIT_VALUES; 
         when DEBUG_STATE => 
            next_state <= TANSMITT_CHAR; 
            next_stateAfterTransmitt <= DEBUG_STATE; 
         when DISP_INIT_VALUES =>
            next_state <= SET_UP_TRANSFER;
            if(to_integer(iSig_change_idx) >= 14) then					
               next_stateAfterSetup <= CHECK_SIG_CHANGE;
            else					
               next_stateAfterSetup <= DISP_INIT_VALUES;
            end if;
         when CHECK_SIG_CHANGE =>
            if(or_reduce(iSig_change_reg) = '1') then
               next_state <= FIND_SIG_CHANGE;
               next_stateAfterSetup <= CHECK_SIG_CHANGE;					
            else
               next_state <= CHECK_SIG_CHANGE; 
            end if;
         when FIND_SIG_CHANGE =>
            if(iSig_change_reg(to_integer(iSig_change_idx-1)) = '1')then
               next_state <= SET_UP_TRANSFER; 
            elsif(to_integer(iSig_change_idx) >= 14) then
               next_state <= SET_UP_TRANSFER; 
            else
               next_state <= FIND_SIG_CHANGE; 
            end if;
         when SET_UP_TRANSFER =>
            next_state <= SET_CH_MODE;
            --do multiple setup to transmitt loops if more than one segments
            --if last seg --> go to state defined previously for afterSetup
            if(iSegCounter = 1) then
               --last segment
               next_stateAfterTransmitt <= stateAfterSetup;
            else
               --segments left --> go to setup again
               next_stateAfterTransmitt <= SET_UP_TRANSFER;
            end if;					
         when SET_CH_MODE =>
            next_state <= WAIT_FOR_WB_FIFO_ADDR;
            next_state2 <= SET_CURSOR_X_POS; 
         when SET_CURSOR_X_POS =>
            next_state <= WAIT_FOR_WB_FIFO_ADDR;
            next_state2 <= SET_CURSOR_Y_POS; 			
         when SET_CURSOR_Y_POS =>
            next_state <= WAIT_FOR_WB_FIFO_ADDR;
            next_state2 <= TANSMITT_CHAR; 			
         when TANSMITT_CHAR => 
            next_state <= WAIT_FOR_WB_FIFO_ADDR;
            if(iCH_counter /= to_unsigned(0,iCH_counter'length)) then				
               next_state2 <= TANSMITT_CHAR;
            else --finshed transmitt_char after this one was! transmitted
               next_state2 <= stateAfterTransmitt;
            end if;
         when WAIT_FOR_WB_FIFO_ADDR =>
            if(iFIFO_FULL = '0') then
               next_state <= TANSMITT_WB_ADDR;
            else  --wait
               next_state <= WAIT_FOR_WB_FIFO_ADDR;
            end if;
         when WAIT_FOR_WB_FIFO_CMD =>
            if(iFIFO_FULL = '0') then
               next_state <= TRANSMITT_WB_DATA;
            else  --wait
               next_state <= WAIT_FOR_WB_FIFO_CMD;
            end if;
         when TANSMITT_WB_ADDR => 				
            next_state <= WAIT_FOR_WB_FIFO_CMD;
         when TRANSMITT_WB_DATA =>	
            next_state <= state2;
         when others =>
            null;
      end case;      
   END PROCESS;
	
   
END Behavioral2;	






LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;



ENTITY CMD_FIFO_TO_WB_MASTER IS
PORT( 
   CLK          : IN    STD_LOGIC;
   RESET        : IN    STD_LOGIC;
   FIFO_DATA_IN : IN    STD_LOGIC_Vector(7 downto 0);
   FIFO_RD_EN   : OUT   STD_LOGIC;
   FIFO_EMPTY   : IN    STD_LOGIC;
   ACK_I        : IN    STD_LOGIC;
   WE_O         : OUT   STD_LOGIC;
   CYC_IO       : INOUT STD_LOGIC; 
   STB_O        : OUT   STD_LOGIC;
   Addr_O       : OUT   STD_LOGIC_VECTOR(7 downto 0);
   BUS_DATA_OUT : OUT   STD_LOGIC_VECTOR(7 downto 0));
END CMD_FIFO_TO_WB_MASTER;



ARCHITECTURE Behavioral3 OF CMD_FIFO_TO_WB_MASTER IS


   TYPE state_type IS (Idle , Read_addr1 , Read_addr2 , Read_data1 , Read_data2 , Wait_Bus , Write_Bus , Wait_Ack) ;
   SIGNAL next_state , current_state : state_type;

   --SIGNAL Temp_Addr , Temp_Data : STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL Temp_Data : STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL Temp_Addr : STD_LOGIC_VECTOR(3 downto 0);


BEGIN
	

   PROCESS (CLK,RESET)
   BEGIN
      IF rising_edge(CLK) THEN
         if RESET = '1' then 
            current_state <= Idle ;
         else 
            current_state <= next_state ;
         end if ;
      END IF;
   END PROCESS;
	
	PROCESS ( current_state , FIFO_EMPTY , ACK_I , CYC_IO )
   BEGIN
      case current_state is 
         when Idle =>
            if ( FIFO_EMPTY = '1' ) then 
               next_state <= Idle ;
            else -- FIFO_EMPTY = '0'
               next_state <= Read_addr1 ;
            end if ;
         when Read_addr1 =>
            next_state <= Read_addr2 ;
         when Read_addr2 =>
            if(FIFO_EMPTY = '1') then
               next_state <= Read_addr2;
            else -- FIFO_EMPTY = '0'
               next_state <= Read_data1 ;
            end if;
         when Read_data1 =>
            next_state <= Read_data2 ;
         when Read_data2 =>
            if ( CYC_IO = '1' ) then 
               next_state <= Wait_Bus ;
            else 
               next_state <= Write_Bus ;						
            end if ;
         when Wait_Bus =>
            if ( CYC_IO = '1' ) then 
               next_state <= Wait_Bus ;
            else
               next_state <= Write_Bus ;
            end if ;
         when Write_Bus =>				
            next_state <= Wait_Ack ;
         when Wait_Ack =>
            if ( ACK_I = '0' ) then 
               next_state <= Wait_Ack ;
            else
               next_state <= Idle ;
            end if ;		
      end case ;
   END PROCESS;
	
   PROCESS (current_state)
   BEGIN 
      case current_state is 
         when Idle =>
            FIFO_RD_EN <= '0' ;		
            WE_O <= '0' ;
            CYC_IO <= '0' ;
            STB_O <= '0' ;					
         when Read_addr1 =>
            FIFO_RD_EN <= '1' ;				
            WE_O <= '0' ;
            CYC_IO <= '0' ;
            STB_O <= '0' ;
         when Read_addr2 =>
            FIFO_RD_EN <= '0' ;				
            WE_O <= '0' ;
            CYC_IO <= '0' ;
            STB_O <= '0' ;
         when Read_data1 =>
            FIFO_RD_EN <= '1' ;					
            WE_O <= '0' ;
            CYC_IO <= '0' ;
            STB_O <= '0' ;
         when Read_data2 =>  
            FIFO_RD_EN <= '0' ;				
            WE_O <= '0' ;
            CYC_IO <= '0' ;
            STB_O <= '0' ;
         when Wait_Bus =>
            FIFO_RD_EN <= '0' ;					
            WE_O <= '0' ;
            CYC_IO <= '0' ;
            STB_O <= '0' ;
         when Write_Bus =>
            FIFO_RD_EN <= '0' ;					
            WE_O <= '1' ;
            CYC_IO <= '1' ;
            STB_O <= '1' ;
         when Wait_Ack =>
            FIFO_RD_EN <= '0' ;					
            WE_O <= '1' ;
            CYC_IO <= '1' ;
            STB_O <= '1' ;
      end case ;
   END PROCESS;
		
   PROCESS (CLK)
   BEGIN 
      IF rising_edge(CLK) THEN 
         Temp_Data <= Temp_Data ;
         Temp_Addr <= Temp_Addr;
         if( RESET = '1' ) then
            Temp_Data <= (others => '0');
            Temp_Addr <= (others => '0');
         else 
            case current_state is 
               when Read_addr1 => --fetch the addr 						
                  Temp_Addr <= FIFO_DATA_IN(3 downto 0);	
               when Read_data1 => --fetch the data
                  Temp_Data <= FIFO_DATA_IN ;									
               when others  =>				
						null;
            end case;
         end if;
      END IF;
   END PROCESS;		 
	 
   BUS_DATA_OUT <= Temp_Data when (current_state = Write_Bus) or (current_state = Wait_Ack) else "ZZZZZZZZ";		
	Addr_O       <= "0000" & Temp_Addr when (current_state = Write_Bus) or (current_state = Wait_Ack) else "ZZZZZZZZ";
							
end Behavioral3;





LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;



ENTITY LCD_CMD_DECODER IS
PORT(	 
   CLK_i            : IN  STD_LOGIC;
   RST_N_i          : IN  STD_LOGIC;
   WB_RDY_o         : OUT STD_LOGIC;
   WB_DATA_i        : IN  STD_LOGIC_VECTOR(7 downto 0);
   WB_ADR_i         : IN  STD_LOGIC_VECTOR(3 downto 0);
   WB_WR_i          : IN  STD_LOGIC;
   MEM_RDY_i        : IN  STD_LOGIC;
   MEM_ASCII_CODE_o : OUT UNSIGNED(7 downto 0);
   MEM_OFFSET_o     : OUT UNSIGNED(4 downto 0);
   MEM_MODE_o       : OUT std_logic_vector(2 downto 0);
   MEM_WR_o         : OUT STD_LOGIC;
   MEM_RD_o         : OUT STD_LOGIC;
   MEM_DATA_i       : IN  STD_LOGIC_VECTOR(7 downto 0);
   LCD_IF_RDY_i     : IN  STD_LOGIC;
   LCD_IF_DATA_o    : OUT STD_LOGIC_VECTOR(7 downto 0);
   LCD_IF_A0_o      : OUT STD_LOGIC;
   LCD_IF_WR_o      : OUT STD_LOGIC;
   LCD_IF_RS_o      : OUT STD_LOGIC_VECTOR(2 downto 0));
END LCD_CMD_DECODER;



ARCHITECTURE Behavioral4 OF LCD_CMD_DECODER IS


TYPE state_type IS (	RESET_START , RESET_WAIT , WAIT_ON_CMD , DECODE , DECODE_CMD , DECODE_DATA , TRANSMIT_TO_LCD , WAIT_FOR_LCD , LCD_INIT1 , LCD_INIT2 , LCD_INIT3 , LCD_INIT4 , LCD_INIT5 , LCD_INIT6 ,
							WAIT_FOR_MEM , FETCH_ASCII_CHAR , WRITE_ASCII_CHAR_TO_LCD , ASCII_CHAR_GO_TO_SECOND_LINE , FINISH_ASCII_CHAR , PAGE_ADDRESS_SET , COLUMN_ADDRESS_SET_H , COLUMN_ADDRESS_SET_L ,
                     CURSOR_CH_X_TO_CURSOR_PX_X , CLEAR_DISP_START , CLEAR_DISP_CONTINUE , CLEAR_DISP_SET_CURSOR , CLEAR_DISP_FINISH);
SIGNAL state , state2 , state3 , next_state , next_state2 , next_state3 : state_type; 

SIGNAL reset_wait_count_reg : UNSIGNED(7 downto 0); 
SIGNAL reset_wait_count_end : UNSIGNED(7 downto 0);
--SIGNAL cmd_reg_L , cmd_reg_H , data_reg_L , data_reg_H  : STD_LOGIC_VECTOR(7 downto 0);
-- cmd_reg_L braucht keine 8 bits
SIGNAL cmd_reg_L : STD_LOGIC_VECTOR(2 downto 0);
SIGNAL data_reg_L : STD_LOGIC_VECTOR(6 downto 0);
SIGNAL cmd_reg_H , data_reg_H  : STD_LOGIC_VECTOR(7 downto 0);
SIGNAL native_cmd_reg , native_data_reg : STD_LOGIC_VECTOR(7 downto 0);
SIGNAL lcd_cursor_ch_x_reg , lcd_cursor_ch_y_reg : UNSIGNED(7 downto 0);
SIGNAL lcd_cursor_px_x_reg , lcd_cursor_px_y_reg : UNSIGNED(7 downto 0);
SIGNAL lcd_ctrl_mode_reg : STD_LOGIC_VECTOR(2 downto 0); 
SIGNAL cursor_shift_en , cursor_shift_dir : STD_LOGIC; 
SIGNAL iLCD_IF_DATA_o :  STD_LOGIC_VECTOR(7 downto 0);
SIGNAL iLCD_IF_RS_o :  STD_LOGIC_VECTOR(2 downto 0);
SIGNAL iLCD_IF_WR_o :  STD_LOGIC;
SIGNAL iLCD_IF_A0_o :  STD_LOGIC;
SIGNAL iWB_RDY_o : STD_LOGIC;
SIGNAL iWB_DATA_i :STD_LOGIC_VECTOR(7 downto 0);
SIGNAL iWB_ADR_i : STD_LOGIC_VECTOR(3 downto 0);
SIGNAL iMEM_ASCII_CODE_o : UNSIGNED(7 downto 0);
SIGNAL iMEM_OFFSET_o : UNSIGNED(4 downto 0);
SIGNAL iMEM_MODE_o : STD_LOGIC_VECTOR(2 downto 0);
SIGNAL iMEM_WR_o : STD_LOGIC;
SIGNAL iMEM_RD_o : STD_LOGIC;
SIGNAL iMEM_DATA_i : STD_LOGIC_VECTOR(7 downto 0);


BEGIN


   WB_RDY_o <= iWB_RDY_o;
   LCD_IF_DATA_o <= iLCD_IF_DATA_o;
   LCD_IF_A0_o  <= iLCD_IF_A0_o;
   LCD_IF_WR_o  <= iLCD_IF_WR_o;
   LCD_IF_RS_o  <= iLCD_IF_RS_o;
   MEM_ASCII_CODE_o  <= iMEM_ASCII_CODE_o;
   MEM_OFFSET_o <= iMEM_OFFSET_o;
   MEM_MODE_o <= iMEM_MODE_o;
   MEM_WR_o <= iMEM_WR_o;
   MEM_RD_o <= iMEM_RD_o;

   NEXT_STATE_PROC: PROCESS (CLK_i,RST_N_i)
   BEGIN
      IF (RST_N_i = '0') THEN
         state  <= RESET_START;	
         state2 <= RESET_START;
         state3 <= RESET_START;
      ELSIF rising_edge(CLK_i) THEN
         state <= next_state;		
         state2 <= next_state2;	
         state3 <= next_state3;						
      END IF;
   END PROCESS; 

   SYNC_OUTPUT_PROC: PROCESS (CLK_i,RST_N_i)
   BEGIN 		
      IF (RST_N_i = '0') THEN
         iWB_RDY_o <= '0';
         iWB_DATA_i <= (others => '0');
         iWB_ADR_i <= (others => '0');
         reset_wait_count_reg <= (others => '0');
         reset_wait_count_end	<= (others => '0');
         lcd_ctrl_mode_reg <= "000";
         native_cmd_reg <= (others => '0');
         native_data_reg <= (others => '0');
         cmd_reg_L <= (others => '0');
         cmd_reg_H <= (others => '0');
         data_reg_L <= (others => '0');
         data_reg_H <= (others => '0');
         lcd_cursor_ch_x_reg <= (others => '0');
         lcd_cursor_ch_y_reg <= (others => '0'); 
         lcd_cursor_px_x_reg <= to_unsigned(0,lcd_cursor_px_x_reg'length) + 2;
         lcd_cursor_px_y_reg <= (others => '0');
         cursor_shift_en <= '1';
         cursor_shift_dir <= '1'; --to the right by default
         iMEM_ASCII_CODE_o  <= (others => '0');
         iMEM_OFFSET_o <= (others => '0');
         iMEM_MODE_o <= "000";
         iMEM_WR_o <= '0';
         iMEM_RD_o <= '0';
         iMEM_DATA_i <= (others => '0');
         iLCD_IF_DATA_o <= (others => '0');
         iLCD_IF_RS_o  <= (others => '0');
         iLCD_IF_WR_o <= '0';
         iLCD_IF_A0_o <= '0';
      ELSIF rising_edge(CLK_i) THEN
         iWB_RDY_o <= '0';
         iLCD_IF_WR_o <= '0';
         iMEM_WR_o <= '0';
         iMEM_RD_o <= '0';
         case (next_state) is
            when RESET_START =>
               reset_wait_count_reg		<= (others => '0');
               reset_wait_count_end <= to_unsigned(8, reset_wait_count_end'length);
            when RESET_WAIT => 					
               --hold reset for specified time           
               reset_wait_count_reg		<= reset_wait_count_reg +1;
            when WAIT_ON_CMD =>
               iWB_RDY_o <= '1'; -- this is they only state we are ready to receive cmds
               --continuously register data and adress
               iWB_DATA_i <= WB_DATA_i;  
               iWB_ADR_i <= WB_ADR_i;
            when DECODE =>
               case (iWB_ADR_i) is				
                  when "0000" => 
                     --data_reg_L <= iWB_DATA_i;
                     data_reg_L <= iWB_DATA_i(6 downto 0);
                  when "0010" =>  
                     data_reg_H <= iWB_DATA_i;
                  when "0100" => 
                     cmd_reg_L <= iWB_DATA_i(4 downto 2);
                  when "0110" =>  
                     cmd_reg_H <= iWB_DATA_i;
                  when "1000" => 
                     lcd_cursor_ch_x_reg <= unsigned(iWB_DATA_i);
                  when "1010" =>  
                     lcd_cursor_ch_y_reg <= unsigned(iWB_DATA_i);
                  when "0001" => 
                     lcd_cursor_px_x_reg <= unsigned(iWB_DATA_i);
                  when "0011" =>  
                     lcd_cursor_px_y_reg <= unsigned(iWB_DATA_i);
                  when "1100" =>
                     native_cmd_reg <= iWB_DATA_i;	
                     iLCD_IF_DATA_o <= iWB_DATA_i;
                     iLCD_IF_DATA_o(0) <= '1';
                     iLCD_IF_A0_o <= '0'; --	cmd
                     iLCD_IF_RS_o  <= "000";
                  when "0111" =>
                     native_data_reg <= iWB_DATA_i;
                     iLCD_IF_DATA_o <= iWB_DATA_i;
                     iLCD_IF_A0_o <= '1'; -- data
                     iLCD_IF_RS_o  <= "000";
                  when "1110" => 
                     lcd_ctrl_mode_reg <= iWB_DATA_i(2 downto 0);	
                     if(iWB_DATA_i(2 downto 0) = "010") then
                        iMEM_MODE_o <= "000";												
                     elsif(iWB_DATA_i(2 downto 0) = "100") then
                        iMEM_MODE_o <= "001";						
                     end if;
                  when others => --unsupported
                     null;
               end case; 
            when DECODE_DATA =>
               case (lcd_ctrl_mode_reg) is				
                  when "010" =>  
                     --iMEM_ASCII_CODE_o  <= unsigned(data_reg_L);
                     iMEM_ASCII_CODE_o  <= unsigned("0" & data_reg_L);
                     iMEM_OFFSET_o <= (others => '0');
                  when "100" =>  
                     --iMEM_ASCII_CODE_o  <= unsigned(data_reg_L);
                     iMEM_ASCII_CODE_o  <= unsigned("0" & data_reg_L);
                     iMEM_OFFSET_o <= (others => '0');
                  when others => --unsupported MODE
                     null;
               end case;   
            when DECODE_CMD =>
-- cmd_reg_L braucht keine 8 bits
--               case (cmd_reg_L(6 downto 2)) is
--               --case (cmd_reg_L) is
--                  when "00001" => 
--                     iLCD_IF_RS_o  <= "100";
--                  when "00011" =>
--                     iLCD_IF_RS_o  <= "101";
--                     iLCD_IF_DATA_o(0) <= iWB_DATA_i(1); --backlight bit is bit:0
--                  when "00100" => 
--                     iLCD_IF_RS_o  <= "001";
--                     iLCD_IF_DATA_o <= cmd_reg_H;
                case (cmd_reg_L) is
                    when "001" => 
                        iLCD_IF_RS_o  <= "100";
                    when "011" =>
                        iLCD_IF_RS_o  <= "101";
                        iLCD_IF_DATA_o(0) <= iWB_DATA_i(1); --backlight bit is bit:0
                    when "100" => 
                        iLCD_IF_RS_o  <= "001";
                        iLCD_IF_DATA_o <= cmd_reg_H;
                    when others =>
                        null;
               end case;  		
            when WAIT_FOR_LCD =>
               null;
            when TRANSMIT_TO_LCD =>
               iLCD_IF_WR_o <= '1';  --only time to assert iLCD_IF_WR_o
            when LCD_INIT1  => -- lcd bias setting
               iLCD_IF_RS_o  <= "000";
               iLCD_IF_DATA_o <= "10100010"; --1/9 bias (for 1/65 duty) 
               iLCD_IF_A0_o <= '0'; --cmd
            when LCD_INIT2  => -- ADC Select
               iLCD_IF_RS_o  <= "000";
               iLCD_IF_DATA_o <= "10100000"; -- normal operation (not reversed "10100001")
               iLCD_IF_A0_o <= '0'; --cmd
            when LCD_INIT3  => -- COM output select
               iLCD_IF_RS_o  <= "000";
               iLCD_IF_DATA_o <= "11001000";  -- reversed operation (not normal "11000000")
               iLCD_IF_A0_o <= '0'; --cmd
            when LCD_INIT4  => -- setting built-in resistance ratio
               iLCD_IF_RS_o  <= "000";
               iLCD_IF_DATA_o <= "00100100";  -- 5.0 (default) --> V0 = 5.0* Vref(=2.1) * 1- ((63-a)/162)
               iLCD_IF_A0_o <= '0'; --cmd
            when LCD_INIT5  => -- power setup :  V/B ,V/R , V/F
               iLCD_IF_RS_o  <= "000";
               iLCD_IF_DATA_o <= "00101111";  --all on (last 3 bit) --> complete internal power supply 
               iLCD_IF_A0_o <= '0'; --cmd
            when LCD_INIT6  => --turn the display ON
               iLCD_IF_RS_o  <= "000";
               iLCD_IF_DATA_o <= "10101111";  --OFF by 10101110
               iLCD_IF_A0_o <= '0'; --cmd
            when CURSOR_CH_X_TO_CURSOR_PX_X =>
               lcd_cursor_px_x_reg <= RESIZE(lcd_cursor_ch_x_reg*to_unsigned(6,lcd_cursor_ch_x_reg'length) + 2,lcd_cursor_px_x_reg'length);
            when PAGE_ADDRESS_SET =>
               iLCD_IF_RS_o  <= "000";
               iLCD_IF_DATA_o <= "1011" & std_logic_vector(lcd_cursor_ch_y_reg(3 downto 0)); 
               iLCD_IF_A0_o <= '0'; --cmd
            when COLUMN_ADDRESS_SET_H =>
               iLCD_IF_RS_o  <= "000";
               iLCD_IF_DATA_o <= "0001" & std_logic_vector(lcd_cursor_px_x_reg(7 downto 4)); 
               iLCD_IF_A0_o <= '0'; --cmd
            when COLUMN_ADDRESS_SET_L =>	
               iLCD_IF_RS_o  <= "000";
               iLCD_IF_DATA_o <= "0000" & std_logic_vector(lcd_cursor_px_x_reg(3 downto 0)); 
               iLCD_IF_A0_o <= '0'; --cmd
            when CLEAR_DISP_START =>			
               lcd_cursor_px_x_reg <= (others => '0');
               lcd_cursor_ch_y_reg <= (others => '0');
            when CLEAR_DISP_SET_CURSOR =>
               null;
            when CLEAR_DISP_CONTINUE =>
               --transmitt current column to lcd
               iLCD_IF_RS_o  <= "000";
               iLCD_IF_DATA_o <= (others => '0'); 
               iLCD_IF_A0_o <= '1'; --data
               --prepare for next column
               if(lcd_cursor_px_x_reg >= to_unsigned(127, lcd_cursor_px_x_reg'length)) then
                  lcd_cursor_px_x_reg <= (others => '0'); --line wrap around
                  if(lcd_cursor_ch_y_reg >= to_unsigned(7, lcd_cursor_px_x_reg'length)) then
                     lcd_cursor_ch_y_reg <= (others => '0'); --page wrap around
                  else
                     lcd_cursor_ch_y_reg <= lcd_cursor_ch_y_reg + 1;
                  end if;
               else
                  lcd_cursor_px_x_reg <= lcd_cursor_px_x_reg +1;
               end if;
            when CLEAR_DISP_FINISH =>
               --restore cursor position
               lcd_cursor_px_x_reg <= to_unsigned(0,lcd_cursor_px_x_reg'length) + 2;
               lcd_cursor_ch_x_reg <= (others => '0');
               lcd_cursor_ch_y_reg <= (others => '0');
            when FETCH_ASCII_CHAR =>			
                  iMEM_RD_o <= '1';
            when WAIT_FOR_MEM =>
               iMEM_DATA_i(7 downto 0) <= MEM_DATA_i;			
            when WRITE_ASCII_CHAR_TO_LCD =>	
               --transmitt current column to lcd
               iLCD_IF_RS_o  <= "000";
               iLCD_IF_DATA_o <= iMEM_DATA_i; 
               iLCD_IF_A0_o <= '1'; --data
               --prepare for next column
               iMEM_OFFSET_o <= iMEM_OFFSET_o + 1;
            when ASCII_CHAR_GO_TO_SECOND_LINE =>
               --a big character consists of two lines and thus needs line increment at half
               lcd_cursor_ch_y_reg <= lcd_cursor_ch_y_reg + 1;
               iMEM_OFFSET_o <= to_unsigned(16,iMEM_OFFSET_o'length);					
            when FINISH_ASCII_CHAR => 
               if(iMEM_MODE_o = "000") then
                  --increment the cursor position and line if end of line reached
                  if(lcd_cursor_ch_x_reg >= to_unsigned(20,lcd_cursor_ch_x_reg'length)) then
                     --end of line reached
                     lcd_cursor_ch_x_reg <= (others => '0');
                     lcd_cursor_px_x_reg <= to_unsigned(0,lcd_cursor_px_x_reg'length) + 2;
                     if(lcd_cursor_ch_y_reg >= to_unsigned(7, lcd_cursor_ch_y_reg'length)) then
                        lcd_cursor_ch_y_reg <= (others => '0');
                     else
                        lcd_cursor_ch_y_reg <= lcd_cursor_ch_y_reg + 1;
                     end if;			
                  else
                     --no line end: inc cursor in x and keep line
                     lcd_cursor_ch_x_reg <= lcd_cursor_ch_x_reg + 1;
                     lcd_cursor_px_x_reg <= lcd_cursor_px_x_reg + to_unsigned(6,lcd_cursor_px_x_reg'length);
                  end if;
               elsif(iMEM_MODE_o = "001" ) then
                  --increment the cursor position and line if end of line reached
                  if(lcd_cursor_ch_x_reg >= to_unsigned(18,lcd_cursor_ch_x_reg'length)) then
                     --end of line reached
                     lcd_cursor_ch_x_reg <= (others => '0');
                     lcd_cursor_px_x_reg <= to_unsigned(0,lcd_cursor_px_x_reg'length) + 2;
                     if(lcd_cursor_ch_y_reg >= to_unsigned(7, lcd_cursor_ch_y_reg'length)) then
                        lcd_cursor_ch_y_reg <= (others => '0');
                     else
                        lcd_cursor_ch_y_reg <= lcd_cursor_ch_y_reg + 1;
                     end if;			
                  else
                     --no line end: inc cursor in x and keep line (go back to first row of character)
                     lcd_cursor_ch_x_reg <= lcd_cursor_ch_x_reg + 2; --as big character consists of TWO small ones
                     lcd_cursor_px_x_reg <= lcd_cursor_px_x_reg + to_unsigned(12,lcd_cursor_px_x_reg'length);
                     lcd_cursor_ch_y_reg <= lcd_cursor_ch_y_reg - 1; --go back to first line of next character 
                  end if;
               end if;
         end case;     
      END IF;		
   END PROCESS;
    
   NEXT_STATE_DECODE: PROCESS (state,state2,state3,WB_WR_i,iWB_RDY_o,MEM_RDY_i,LCD_IF_RDY_i,iWB_ADR_i,lcd_ctrl_mode_reg,cmd_reg_L,iMEM_OFFSET_o,iMEM_MODE_o,lcd_cursor_ch_x_reg,lcd_cursor_ch_y_reg,lcd_cursor_px_x_reg,next_state2)
   BEGIN
      --declare default state for next_state to avoid latches
      next_state  <= state;  --default is to stay in current state
      next_state2 <= state2;
      next_state3 <= state3;
      case (state) is	
         when RESET_START =>
            next_state <= RESET_WAIT;     			        
         when RESET_WAIT =>
            -- wait for MEM controller and lcd signal if to get ready
            if (MEM_RDY_i = '1' and LCD_IF_RDY_i = '1') then
               next_state <= WAIT_ON_CMD;
            end if;				
         when WAIT_ON_CMD =>
            --wait for new cmd from cmd_decoder
            if (WB_WR_i = '1' and iWB_RDY_o = '1') then
               next_state <= DECODE;
            end if;
         when DECODE =>
            --check out which reg is written
            case (iWB_ADR_i) is				
               when "0000" => 
                  next_state <= DECODE_DATA;     			        
               when "0010" =>  
                  next_state <= WAIT_ON_CMD; --wait for LOW Nibble before processing
               when "0100" => 
                  next_state <= DECODE_CMD; 
               when "0110" =>  
                  next_state <= WAIT_ON_CMD; --wait for LOW Nibble before processing
               when "1000" => 
                  next_state <= CURSOR_CH_X_TO_CURSOR_PX_X; 
                  next_state3 <= WAIT_ON_CMD;
               when "1010" =>  
                  next_state <= PAGE_ADDRESS_SET;
                  next_state2 <= WAIT_ON_CMD;
               when "0001" => 
                  next_state <= COLUMN_ADDRESS_SET_H; 
                  next_state3 <= WAIT_ON_CMD;
               when "0011" =>  
                  next_state <= PAGE_ADDRESS_SET;
                  next_state2 <= WAIT_ON_CMD;
               when "1100" =>
                  next_state <= WAIT_FOR_LCD;
                  next_state2 <= WAIT_ON_CMD;	
               when "0111" =>
                  next_state <= WAIT_FOR_LCD;
                  next_state2 <= WAIT_ON_CMD;
               when "1110" =>  
                  --init the cursor position again 
                  next_state <= PAGE_ADDRESS_SET; 
                  next_state2 <=	CURSOR_CH_X_TO_CURSOR_PX_X;
                  next_state3 <=	WAIT_ON_CMD;
               when others => --unsupported
                  next_state <= WAIT_ON_CMD;
            end case; 
         when DECODE_DATA =>
            case (lcd_ctrl_mode_reg) is				
               when "000" => 
                  next_state <= WAIT_ON_CMD; 
               when "010" =>  
                  next_state <= FETCH_ASCII_CHAR;
               when "100" =>  
                  next_state <= FETCH_ASCII_CHAR; 
               when "110" =>  
                  next_state <= WAIT_ON_CMD;
               when "001" => 
                  next_state <= WAIT_ON_CMD; 
               when "011" =>  
                  next_state <= WAIT_ON_CMD; 						
               when others => --unsupported MODE
                  next_state <= WAIT_ON_CMD;
            end case; 
         when DECODE_CMD  =>
-- cmd_reg_L braucht keine 8 bits
--            case (cmd_reg_L(6 downto 2)) is
--            --case (cmd_reg_L) is
--               when "00001" => 
--                  next_state <= WAIT_FOR_LCD;
--                  next_state2 <= WAIT_ON_CMD;
--               when "00010" => 
--                  next_state <= LCD_INIT1;
--               when "00011" => 
--                  next_state <= WAIT_FOR_LCD;
--                  next_state2 <= WAIT_ON_CMD;
--               when "00100" => 
--                  next_state <= WAIT_FOR_LCD;
--                  next_state2 <= WAIT_ON_CMD;
--               when "00101" => 
--                  next_state <= CLEAR_DISP_START;
            case (cmd_reg_L) is
               when "001" => 
                  next_state <= WAIT_FOR_LCD;
                  next_state2 <= WAIT_ON_CMD;
               when "010" => 
                  next_state <= LCD_INIT1;
               when "011" => 
                  next_state <= WAIT_FOR_LCD;
                  next_state2 <= WAIT_ON_CMD;
               when "100" => 
                  next_state <= WAIT_FOR_LCD;
                  next_state2 <= WAIT_ON_CMD;
               when "101" => 
                  next_state <= CLEAR_DISP_START;
               when others =>
                  next_state <= WAIT_ON_CMD;
            end case;    
         when WAIT_FOR_LCD =>
            if (LCD_IF_RDY_i ='1') then 
               next_state <= TRANSMIT_TO_LCD;
            end if;
         when TRANSMIT_TO_LCD =>
            next_state <= next_state2; 
         when LCD_INIT1  => 
            next_state <= WAIT_FOR_LCD;
            next_state2 <= LCD_INIT2;
         when LCD_INIT2  => 
            next_state <= WAIT_FOR_LCD;
            next_state2 <= LCD_INIT3;
         when LCD_INIT3  => 
            next_state <= WAIT_FOR_LCD;
            next_state2 <= LCD_INIT4;
         when LCD_INIT4  => 
            next_state <= WAIT_FOR_LCD;
            next_state2 <= LCD_INIT5;
         when LCD_INIT5  => 
            next_state <= WAIT_FOR_LCD;
            next_state2 <= LCD_INIT6;
         when LCD_INIT6  => 
            next_state <= WAIT_FOR_LCD;
            next_state2 <= WAIT_ON_CMD;
         when CURSOR_CH_X_TO_CURSOR_PX_X =>
            next_state <= COLUMN_ADDRESS_SET_H;
            next_state3 <= state3;
         when PAGE_ADDRESS_SET =>
            next_state <= WAIT_FOR_LCD;
            next_state2 <= state2;
         when COLUMN_ADDRESS_SET_H =>
            next_state <= WAIT_FOR_LCD;
            next_state2 <= COLUMN_ADDRESS_SET_L;
         when COLUMN_ADDRESS_SET_L =>
            next_state <= WAIT_FOR_LCD;
            next_state2 <= state3;			
         when CLEAR_DISP_START =>
            next_state <= CLEAR_DISP_SET_CURSOR;
         when CLEAR_DISP_SET_CURSOR =>
            next_state <= PAGE_ADDRESS_SET;
            next_state2 <= COLUMN_ADDRESS_SET_H;
            next_state3 <= CLEAR_DISP_CONTINUE;
         when CLEAR_DISP_CONTINUE =>
            next_state <= WAIT_FOR_LCD;				
            --default next_state2
            next_state2 <= CLEAR_DISP_CONTINUE;
            if(lcd_cursor_px_x_reg = to_unsigned(0,lcd_cursor_px_x_reg'length)) then
               next_state2 <= CLEAR_DISP_SET_CURSOR;
               if(lcd_cursor_ch_y_reg = to_unsigned(0,lcd_cursor_ch_y_reg'length)) then
                  next_state2 <= CLEAR_DISP_FINISH;
               end if;
            end if;
         when CLEAR_DISP_FINISH =>
            --reset coursor to start
            next_state <= PAGE_ADDRESS_SET;
            next_state2 <= COLUMN_ADDRESS_SET_H;
            next_state3 <= WAIT_ON_CMD;
         when FETCH_ASCII_CHAR =>
            next_state <= WAIT_FOR_MEM;
            next_state2 <= WRITE_ASCII_CHAR_TO_LCD;
         when WAIT_FOR_MEM =>
            if (MEM_RDY_i ='1') then
               next_state <= state2;
            end if;
         when WRITE_ASCII_CHAR_TO_LCD =>
            next_state <= WAIT_FOR_LCD;				
            --small_ch
            if(iMEM_MODE_o = "000") then
               if(iMEM_OFFSET_o < to_unsigned(6,iMEM_OFFSET_o'length)) then
                  next_state2 <= FETCH_ASCII_CHAR;
               else
                  next_state2 <= FINISH_ASCII_CHAR;
               end if;	
               --big_ch
            elsif(iMEM_MODE_o = "001") then
               if(iMEM_OFFSET_o < to_unsigned(12,iMEM_OFFSET_o'length)) then
                  next_state2 <= FETCH_ASCII_CHAR;
               elsif (iMEM_OFFSET_o = to_unsigned(12,iMEM_OFFSET_o'length)) then
                  next_state2 <= ASCII_CHAR_GO_TO_SECOND_LINE;
               elsif (iMEM_OFFSET_o < to_unsigned(28,iMEM_OFFSET_o'length)) then
                  next_state2 <= FETCH_ASCII_CHAR;
               else
                  next_state2 <= FINISH_ASCII_CHAR;
               end if;					
            end if;
         when ASCII_CHAR_GO_TO_SECOND_LINE => 
            next_state <= PAGE_ADDRESS_SET;
            next_state2 <= CURSOR_CH_X_TO_CURSOR_PX_X;
            next_state3 <= FETCH_ASCII_CHAR;
         when FINISH_ASCII_CHAR => 
            --default
            next_state <= WAIT_ON_CMD;
            --new line if end of line was reached
            if(iMEM_MODE_o = "000") then
               if(lcd_cursor_ch_x_reg = to_unsigned(0,lcd_cursor_ch_x_reg'length)) then
                  next_state <= PAGE_ADDRESS_SET;
                  next_state2 <= COLUMN_ADDRESS_SET_H;
                  next_state3 <= WAIT_ON_CMD;
               end if;
            elsif(iMEM_MODE_o = "001" ) then
               --cursor set is always needed
               next_state <= PAGE_ADDRESS_SET;
               next_state2 <= CURSOR_CH_X_TO_CURSOR_PX_X;
               next_state3 <= WAIT_ON_CMD;
            end if;
      end case;      
   END PROCESS;
   
   
END Behavioral4;






LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;



ENTITY LCD_MEM_CONTROL IS
PORT(	 
   CLK_i            : IN  STD_LOGIC;
   RST_N_i          : IN  STD_LOGIC;
   MEM_RDY_o        : OUT STD_LOGIC;
   MEM_ASCII_CODE_i : IN  UNSIGNED(7 downto 0);
   MEM_OFFSET_i     : IN  UNSIGNED(4 downto 0);
   MEM_MODE_i       : IN  STD_LOGIC_VECTOR(2 downto 0);
   MEM_WR_i         : IN  STD_LOGIC;
   MEM_RD_i         : IN  STD_LOGIC;
   MEM_DATA_o       : OUT STD_LOGIC_VECTOR(7 downto 0));
END LCD_MEM_CONTROL;



ARCHITECTURE Behavioral5 OF LCD_MEM_CONTROL IS


COMPONENT BLOCK_RAM_CORE_ASCII_LUT_SMALL_BIG_2K_ZYBO
PORT(
   CLKA  : IN  STD_LOGIC;
   ENA   : IN  STD_LOGIC;
   WEA   : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
   ADDRA : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
   DINA  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
   DOUTA : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END COMPONENT;

COMPONENT BLOCK_RAM_CORE_ZYBO
PORT(
   CLKA  : IN  STD_LOGIC;
   ENA   : IN  STD_LOGIC;
   WEA   : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
   ADDRA : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
   DINA  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
   DOUTA : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END COMPONENT;

TYPE state_type IS (WAIT_ON_CMD , PROCESS_ASCII_LUT , READ_ASCII_LUT_WAIT_1 , READ_ASCII_LUT_WAIT_2 , READ_ASCII_LUT_WAIT_3 , PROCESS_DISPLAY_COPY , READ_DISPLAY_COPY , RESET_RAM , RESET_START); 
SIGNAL state , next_state : state_type; 

SIGNAL ASCII_LUT_EN : STD_LOGIC;
SIGNAL ASCII_LUT_WE : STD_LOGIC_VECTOR(0 DOWNTO 0);
SIGNAL ASCII_LUT_ADDR : UNSIGNED(10 DOWNTO 0);
SIGNAL ASCII_LUT_DOUT : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL DISPLAY_COPY_EN : STD_LOGIC;
SIGNAL DISPLAY_COPY_WE : STD_LOGIC_VECTOR(0 DOWNTO 0);
SIGNAL DISPLAY_COPY_ADDR : UNSIGNED(9 DOWNTO 0);
--SIGNAL DISPLAY_COPY_DIN , DISPLAY_COPY_DOUT : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL DISPLAY_COPY_DOUT : STD_LOGIC_VECTOR(7 DOWNTO 0);
--SIGNAL iMEM_ASCII_CODE_i : UNSIGNED(7 downto 0);
SIGNAL iMEM_ASCII_CODE_i : UNSIGNED(6 downto 0);
SIGNAL iMEM_OFFSET_i : UNSIGNED(4 downto 0);
SIGNAL iMEM_MODE_i : STD_LOGIC;
--SIGNAL iMEM_MODE_i : STD_LOGIC_VECTOR(2 downto 0);
SIGNAL iMEM_WR_NOT_RD_i : STD_LOGIC;  
SIGNAL iMEM_RDY_o : STD_LOGIC;
SIGNAL iMEM_DATA_o : STD_LOGIC_VECTOR (7 downto 0);


BEGIN

  
   ASCII_LUT_BRAM : BLOCK_RAM_CORE_ASCII_LUT_SMALL_BIG_2K_ZYBO
   PORT MAP(
      CLKA  => CLK_i,
      ENA   => ASCII_LUT_EN,
      WEA   => ASCII_LUT_WE,
      ADDRA => STD_LOGIC_VECTOR(ASCII_LUT_ADDR),
      DINA  => (others => '0'),
      DOUTA => ASCII_LUT_DOUT);
 
   DISPLAY_COPY_BRAM : BLOCK_RAM_CORE_ZYBO
   PORT MAP(
      CLKA  => CLK_i,
      ENA   => DISPLAY_COPY_EN,
      WEA   => DISPLAY_COPY_WE,
      ADDRA => STD_LOGIC_VECTOR(DISPLAY_COPY_ADDR),
      DINA  => (others => '0'),
      DOUTA => DISPLAY_COPY_DOUT);

   MEM_RDY_o <= iMEM_RDY_o;
   MEM_Data_o <= iMEM_DATA_o;

   NEXT_STATE_PROC: PROCESS (CLK_i,RST_N_i)
   BEGIN
      IF (RST_N_i = '0') THEN
         state <= RESET_START;				
      ELSIF rising_edge(CLK_i) THEN
         state <= next_state;			
      END IF;
   END PROCESS;
    
   SYNC_OUTPUT_PROC: PROCESS (CLK_i,RST_N_i)
   BEGIN 		
      IF (RST_N_i = '0')  THEN
         ASCII_LUT_EN <= '0';
         ASCII_LUT_WE <= (others => '0');
         ASCII_LUT_ADDR <= (others => '0');
         DISPLAY_COPY_EN <= '0';
         DISPLAY_COPY_WE <= (others => '0');
         DISPLAY_COPY_ADDR <= (others => '0');
         --DISPLAY_COPY_DIN <= (others => '0');
         iMEM_ASCII_CODE_i <= (others => '0');
         iMEM_OFFSET_i <= (others => '0');
         iMEM_MODE_i <= '0';
         iMEM_WR_NOT_RD_i <= '0';
         iMEM_DATA_o <= (others => '0');
         iMEM_RDY_o <= '0'; --not ready by default
      ELSIF rising_edge(CLK_i) THEN
         ASCII_LUT_EN <= '1';
         ASCII_LUT_WE <= (others => '0');
         DISPLAY_COPY_EN <= '0';
         DISPLAY_COPY_WE <= (others => '0');
         iMEM_RDY_o <= '0'; --not ready by default
         case (next_state) is
            when RESET_START =>
               DISPLAY_COPY_ADDR <= (others => '0');
            when RESET_RAM => -- resets the display_copy_mem to 'all zeros'
               DISPLAY_COPY_ADDR <= DISPLAY_COPY_ADDR + 1;
               DISPLAY_COPY_EN <= '1';
               DISPLAY_COPY_WE <= "1";
               --DISPLAY_COPY_DIN <= (others => '0');
            when WAIT_ON_CMD =>
               iMEM_RDY_o <= '1'; -- only state to assert ready signal
               --iMEM_MODE_i <= MEM_MODE_i;
               iMEM_MODE_i <= MEM_MODE_i(0);
               if (MEM_WR_i = '1') then
                  iMEM_WR_NOT_RD_i <= ('1');
               elsif (MEM_RD_i = '1') then 
                  iMEM_WR_NOT_RD_i <= ('0');
               else
                  iMEM_WR_NOT_RD_i <= '-';
               end if;
               iMEM_ASCII_CODE_i <=  MEM_ASCII_CODE_i(6 downto 0);
               iMEM_OFFSET_i <= (MEM_OFFSET_i);
            when PROCESS_ASCII_LUT => --only ASCII 0 to 127 are implemented
               --if(iMEM_MODE_i = "000") then
               if(iMEM_MODE_i = '0') then
                  --ASCII_LUT_ADDR <=RESIZE( ( "000" & iMEM_ASCII_CODE_i(6 downto 0) & "000" ) + (to_unsigned(0,ASCII_LUT_ADDR'length-iMEM_OFFSET_i'length) & iMEM_OFFSET_i),ASCII_LUT_ADDR'length );
                  ASCII_LUT_ADDR <=RESIZE( ( "000" & iMEM_ASCII_CODE_i & "000" ) + (to_unsigned(0,ASCII_LUT_ADDR'length-iMEM_OFFSET_i'length) & iMEM_OFFSET_i),ASCII_LUT_ADDR'length );
               --elsif (iMEM_MODE_i = "001") then
               elsif (iMEM_MODE_i = '1') then
                  --ASCII_LUT_ADDR <= RESIZE( ((iMEM_ASCII_CODE_i(6 downto 0) - to_unsigned(32,7))  & "00000")  + (to_unsigned(0,ASCII_LUT_ADDR'length-iMEM_OFFSET_i'length) & iMEM_OFFSET_i)+ (to_unsigned(1024,ASCII_LUT_ADDR'length)) ,ASCII_LUT_ADDR'length );
                  ASCII_LUT_ADDR <= RESIZE( ((iMEM_ASCII_CODE_i - to_unsigned(32,7))  & "00000")  + (to_unsigned(0,ASCII_LUT_ADDR'length-iMEM_OFFSET_i'length) & iMEM_OFFSET_i)+ (to_unsigned(1024,ASCII_LUT_ADDR'length)) ,ASCII_LUT_ADDR'length );
               else
                  ASCII_LUT_ADDR <= (others => '0'); -- unsupported
               end if;
               ASCII_LUT_EN <= '1';
               if(iMEM_WR_NOT_RD_i = '1') then
                  ASCII_LUT_WE <= "1";
               else
                  ASCII_LUT_WE <= "0";
               end if ;
            when READ_ASCII_LUT_WAIT_1 =>
               null;
            when READ_ASCII_LUT_WAIT_2 =>
               null;
            when READ_ASCII_LUT_WAIT_3 =>
               iMEM_DATA_o <= ASCII_LUT_DOUT ;
            when PROCESS_DISPLAY_COPY =>
               DISPLAY_COPY_ADDR <= (others => '0');
               DISPLAY_COPY_EN <= '1';
               if(iMEM_WR_NOT_RD_i = '1')  then
                  DISPLAY_COPY_WE <= "1";
               else
                  DISPLAY_COPY_WE <= "0";
               end if ;
               --DISPLAY_COPY_DIN <= (others => '0');			
            when READ_DISPLAY_COPY =>
               iMEM_DATA_o <= DISPLAY_COPY_DOUT;
         end case;     
      END IF;		
   END PROCESS;

   NEXT_STATE_DECODE: PROCESS (state,DISPLAY_COPY_ADDR,MEM_WR_i,MEM_RD_i,iMEM_RDY_o,MEM_MODE_i,iMEM_WR_NOT_RD_i)
   BEGIN
      --declare default state for next_state to avoid latches
      next_state <= state;  --default is to stay in current state
      --insert statements to decode next_state
      --below is a simple example
      case (state) is
         when RESET_START =>
            next_state <= RESET_RAM;     			        
         when RESET_RAM =>
            if (DISPLAY_COPY_ADDR >= to_unsigned(1023,DISPLAY_COPY_ADDR'length)) then
               next_state <= WAIT_ON_CMD;
            else
               next_state <= RESET_RAM;
            end if;
         when WAIT_ON_CMD =>
            --wait for new cmd from cmd_decoder
            if ((MEM_WR_i = '1' or MEM_RD_i = '1') and iMEM_RDY_o = '1') then
               if(MEM_MODE_i = "000" or MEM_MODE_i = "001") then
                  next_state <= PROCESS_ASCII_LUT;
               elsif (MEM_MODE_i = "010") then
                  next_state <= PROCESS_DISPLAY_COPY;
               else
                  next_state <= WAIT_ON_CMD; --unsuported
               end if;
            end if;		
         when PROCESS_ASCII_LUT =>
            if(iMEM_WR_NOT_RD_i = '1') then
               next_state <= WAIT_ON_CMD; --only one state for write
            else 
               next_state <= READ_ASCII_LUT_WAIT_1; -- two states to read data are needed
            end if;
         when READ_ASCII_LUT_WAIT_1 =>
            next_state <= READ_ASCII_LUT_WAIT_2;
         when READ_ASCII_LUT_WAIT_2 =>
            next_state <= READ_ASCII_LUT_WAIT_3;
         when READ_ASCII_LUT_WAIT_3 =>
            next_state <= WAIT_ON_CMD;
         when PROCESS_DISPLAY_COPY =>
            if(iMEM_WR_NOT_RD_i = '1') then
               next_state <= WAIT_ON_CMD; --only one state for write
            else
               next_state <= READ_DISPLAY_COPY; -- two states to read data are needed
            end if;
         when READ_DISPLAY_COPY =>
            next_state <= WAIT_ON_CMD;
      end case;      
   END PROCESS;

      
END Behavioral5;




LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
Library UNISIM;
USE UNISIM.vcomponents.ALL;



ENTITY LCD_SIGNAL_IF IS
GENERIC(
   CLK_DIV_COUNT_WIDTH          : NATURAL := 8;
   RESET_WAIT_COUNT_WIDTH       : NATURAL := 10;
   RESET_WAIT_COUNTER_END       : NATURAL := 1020;
   RESET_WAIT_AFTER_COUNTER_END : NATURAL := 150);
PORT(	 
   CLK_i   : IN    STD_LOGIC;
   RST_N_i : IN    STD_LOGIC;
   RDY_o   : OUT   STD_LOGIC;
   DATA_i  : IN    STD_LOGIC_VECTOR(7 downto 0);
   A0_i    : IN    STD_LOGIC;
   WR_i    : IN    STD_LOGIC;
   RS_i    : IN    STD_LOGIC_VECTOR(2 downto 0);
   RES_N_o : OUT   STD_LOGIC;
   SCL_o   : INOUT STD_LOGIC;
   SI_o    : OUT   STD_LOGIC;
   CS1_N_o : OUT   STD_LOGIC;
   A0_o    : OUT   STD_LOGIC;          
   C86_o   : OUT   STD_LOGIC;
   LED_A_o : OUT   STD_LOGIC);        
END LCD_SIGNAL_IF;



ARCHITECTURE Behavioral6 OF LCD_SIGNAL_IF IS


TYPE state_type IS (WAIT_ON_CMD , DECODE_CMD , DECODE_INT_CMD , RESET_WAIT , RESET_WAIT_START , RESET_WAIT_AFTER , RESET_WAIT_AFTER_START , SET_CLK_DIV_TH_REG , ENABLE_DISABLE_IF ,
                    ENABLE_DISABLE_BACKLIGHT_LED , WRITE_LCD_CMD_START , WRITE_LCD_CMD_NEXT , WRITE_LCD_CMD_WAIT , WRITE_LCD_CMD_STOP); 
SIGNAL state , next_state : state_type; 

SIGNAL clk_div_count_reg : UNSIGNED(CLK_DIV_COUNT_WIDTH-1 downto 0); 
SIGNAL clk_div_th_reg : UNSIGNED(CLK_DIV_COUNT_WIDTH-1 downto 0); 
SIGNAL reset_wait_count_reg : UNSIGNED(RESET_WAIT_COUNT_WIDTH-1 downto 0); 
SIGNAL reset_wait_count_end : UNSIGNED(RESET_WAIT_COUNT_WIDTH-1 downto 0); 
SIGNAL scl_clk_en : STD_LOGIC;
SIGNAL scl_clk_rising : STD_LOGIC;
SIGNAL lcd_cmd_idx : UNSIGNED(2 downto 0);
SIGNAL iDATA_i : STD_LOGIC_VECTOR (7 downto 0);
SIGNAL iRS_i : STD_LOGIC_VECTOR(2 downto 0);
SIGNAL iIF_EN : STD_LOGIC;
SIGNAL iA0_i : STD_LOGIC;
SIGNAL RST_i : STD_LOGIC;	--high active reset input
SIGNAL iRES_N_o : STD_LOGIC;  -- example output signal
SIGNAL iSCL_o : STD_LOGIC;  -- example output signal
SIGNAL iSI_o  : STD_LOGIC;  -- example output signal
SIGNAL iCS1_N_o : STD_LOGIC;  -- example output signal
SIGNAL iA0_o : STD_LOGIC;  -- example output signal
SIGNAL iC86_o : STD_LOGIC;  -- example output signal
SIGNAL iLED_A_o : STD_LOGIC;  -- example output signal
SIGNAL iRDY_o :  STD_LOGIC;


BEGIN


   RES_N_o <= iRES_N_o;
   SI_o <= iSI_o;
   CS1_N_o <= iCS1_N_o;
   A0_o <= iA0_o ;
   C86_o <= iC86_o ;
   LED_A_o <= iLED_A_o;
   RDY_o <= iRDY_o;
   RST_i <= not(RST_N_i); --high active reset input

   --use a ODDR2 Register in the FPGA'S IOB 
   --to get predictable latancies from risign clock to output
   SCL_ODDR2_INST : ODDR2 --is used as single rate OFF
   GENERIC MAP(
      DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1" 
      INIT          => '0', -- Sets initial state of the Q output to '0' or '1'
      SRTYPE        => "SYNC") -- Specifies "SYNC" or "ASYNC" set/reset
   PORT MAP(
      Q  => SCL_o, -- 1-bit output data
      --Q  => open, -- 1-bit output data
      C0 => clk_i, -- 1-bit clock input
      C1 => '0', -- 1-bit clock input
      CE => scl_clk_en, -- 1-bit clock enable input
      D0 => scl_clk_rising, -- 1-bit data input (associated with C0)
      D1 => '0', -- 1-bit data input (associated with C1)
      R  => RST_i, -- 1-bit reset input
      S  => '0'); -- 1-bit set input
      
   --CLK_GEN : PROCESS(CLK_i)
   --BEGIN
   --   IF rising_edge(CLK_i) THEN
   --      if scl_clk_en = '1' then
   --         SCL_o <= not(SCL_o);
   --      end if;
   --   END IF;
   --END PROCESS;

   clock_divider_proc : PROCESS(CLK_i,RST_N_i)
   BEGIN
      IF RST_N_i = '0' THEN
         clk_div_count_reg <= (others => '0');
         scl_clk_en <= '0';
         scl_clk_rising <= '0';	
         iSCL_o <= '0';		
      ELSIF rising_edge(CLK_i) THEN
         if iIF_EN = '1' then --only do something if enabled
            if (clk_div_count_reg = clk_div_th_reg - 1) then
               --signal clk_en and type of edge which will happen in "next" cycle
               clk_div_count_reg <=  clk_div_count_reg + 1;
               --scl_clk_en <= '1' after 100 ps;
               scl_clk_en <= '1';
               scl_clk_rising <= not(scl_clk_rising); -- every second edge is a rising edge
            elsif (clk_div_count_reg >= clk_div_th_reg) then
               --edge is performed one cycle later
               --scl_clk_en <= '0' after 100 ps;
               scl_clk_en <= '0';
               clk_div_count_reg <=  (others =>'0');
               if (scl_clk_rising = '1') then
                  iSCL_o <= '1'; 
               else
                  iSCL_o <= '0';
               end if;
            else
               --scl_clk_en <= '0' after 100 ps;
               scl_clk_en <= '0';
               clk_div_count_reg <=  clk_div_count_reg + 1;
            end if;	
         end if;	
      END IF;
   END PROCESS;

   NEXT_STATE_PROC: PROCESS (CLK_i,RST_N_i)
   BEGIN
      IF (RST_N_i = '0') THEN
         state <= RESET_WAIT_START;				
      ELSIF rising_edge(CLK_i) THEN
         state <= next_state;			
      END IF;
   END PROCESS;
    
   SYNC_OUTPUT_PROC: PROCESS (CLK_i,RST_N_i)
   BEGIN 		
      IF (RST_N_i = '0') THEN
         --diable and reset all except the scl_clk
         iRES_N_o <= '0'; --reset active
         iSI_o <= '0';
         iCS1_N_o <= '1'; --chipselect diabled
         iA0_o <= '0';        
         iC86_o <= '0';
         iLED_A_o <= '0';
         reset_wait_count_reg <= (others => '0');
         --> flcd = finput/(2*scl_clk_prescal_default) 
         --> finput = 60 MHz
         --> scl_clk_prescal_default = 16
         --> flcd ~ 1.9 Mhz 
         -->(flcd,max = 8 MHz !!!)
         -->here, for the 125MHz Input Clock scl_clk_prescal_default=7, see below.
         clk_div_th_reg <= to_unsigned(7,clk_div_th_reg'length); -- set threshold to max value --> slowest scl_clk
         reset_wait_count_end	<= (others => '0');
         iDATA_i <= (others => '0');
         iRS_i <= (others => '0');    
         iIF_EN <= '1'; -- enable scl_clk	
         iRDY_o <= '0';
         iA0_i <= '0';
         lcd_cmd_idx <= (others => '0');
      ELSIF rising_edge(CLK_i) THEN
         iRES_N_o <= '1'; --no reset
         iCS1_N_o <= '1'; 
         iC86_o <= '0';
         iRDY_o <= '0'; --default is not ready
         case (next_state) is
            when RESET_WAIT_START =>
               iRES_N_o <= '0'; --reset active 
               reset_wait_count_reg		<= (others => '0');
               reset_wait_count_end <= to_unsigned(RESET_WAIT_COUNTER_END, reset_wait_count_end'length);
            when RESET_WAIT => 					
               --hold reset for specified time
               iRES_N_o <= '0';   --reset active 
               reset_wait_count_reg		<= reset_wait_count_reg +1;
            when RESET_WAIT_AFTER_START =>
               iRES_N_o <= '1';   
               reset_wait_count_reg		<= (others => '0');
               reset_wait_count_end <= to_unsigned(RESET_WAIT_AFTER_COUNTER_END, reset_wait_count_end'length);
            when RESET_WAIT_AFTER => 
               iRES_N_o <= '1';			
               reset_wait_count_reg		<= reset_wait_count_reg +1;	
            when WAIT_ON_CMD =>
               iRDY_o <= '1'; -- this is they only state we are ready to receive cmds
            when DECODE_CMD =>
                 --fetch data and flags
               iDATA_i <= DATA_i;  
               iRS_i <= RS_i;
               iA0_i <= A0_i;
            when SET_CLK_DIV_TH_REG =>
               clk_div_th_reg (CLK_DIV_COUNT_WIDTH-1 downto 0) <= unsigned(iDATA_i(CLK_DIV_COUNT_WIDTH-1 downto 0));
            when ENABLE_DISABLE_IF =>
               iIF_EN <= iDATA_i(0); 
            when ENABLE_DISABLE_BACKLIGHT_LED =>
               iLED_A_o <= iDATA_i(0);
            when WRITE_LCD_CMD_START => 				
               iCS1_N_o <= '1'; -- chipselect still disabled
               iA0_o <= iA0_i;
               lcd_cmd_idx <= (others => '1'); --init bitcounter
            when WRITE_LCD_CMD_NEXT =>					
               iSI_o <= iDATA_i(to_integer(lcd_cmd_idx)); -- put  bits to the lines
               iCS1_N_o <= '0'; --keep the chip enabled from now on
               iA0_o <= iA0_i;
               lcd_cmd_idx <= lcd_cmd_idx - 1; 		
            when WRITE_LCD_CMD_WAIT => 	
               iCS1_N_o <= '0'; --keep the chip enabled
               iA0_o <= iA0_i;
            when WRITE_LCD_CMD_STOP =>					
               iCS1_N_o <= '1'; --disable the chip again (defualt)		         
            when others =>
               null;
         end case;     
      END IF;		
   END PROCESS;
    
   NEXT_STATE_DECODE: PROCESS (state, reset_wait_count_reg,reset_wait_count_end, WR_i,iRDY_o,iRS_i,iDATA_i,scl_clk_en,scl_clk_rising,lcd_cmd_idx)
   BEGIN
      --declare default state for next_state to avoid latches
      next_state <= state;  --default is to stay in current state
      --insert statements to decode next_state
      --below is a simple example
      case (state) is
         when RESET_WAIT_START =>
            next_state <= RESET_WAIT;     			        
         when RESET_WAIT =>
            if (reset_wait_count_reg >= reset_wait_count_end) then
               next_state <= RESET_WAIT_AFTER_START;
            end if;
         when RESET_WAIT_AFTER_START =>
            next_state <= RESET_WAIT_AFTER;					
         when RESET_WAIT_AFTER =>
            if(reset_wait_count_reg >= reset_wait_count_end) then
               next_state <= WAIT_ON_CMD;
            end if;
         when WAIT_ON_CMD =>
            --wait for new cmd from cmd_decoder
            if (WR_i = '1' and iRDY_o = '1') then
               next_state <= DECODE_CMD;
            end if;
         when DECODE_CMD =>
            --check out which reg is written
            case (iRS_i) is			
               when "000" => -- 8 bit cmd for lcd
                  next_state <= WRITE_LCD_CMD_START;     			        
               when "001" =>  -- set clk_div_th_reg 
                  next_state <= SET_CLK_DIV_TH_REG;
               when "011" =>  -- enable/disable the IF
                  next_state <= ENABLE_DISABLE_IF; 
               when "100" =>  -- writing to this RS initiates a Reset of the LCD
                  next_state <= RESET_WAIT_START;
               when "101" =>  -- enable/disable Backligth LED
                  next_state <= ENABLE_DISABLE_BACKLIGHT_LED; 
               when "111" =>  -- internal cmd received
                  next_state <= DECODE_INT_CMD; 
               when others => --unsupported
                  next_state <= WAIT_ON_CMD;
            end case;   
         when SET_CLK_DIV_TH_REG			=> 
            next_state <= RESET_WAIT_START; -- go to reset after scl_clk speed changed
         when ENABLE_DISABLE_IF  => 
            next_state <= WAIT_ON_CMD; 
         when ENABLE_DISABLE_BACKLIGHT_LED  => 
            next_state <= WAIT_ON_CMD; 
         when DECODE_INT_CMD  => --TODO implement this
            case (iDATA_i) is				
               when "00000000" => 
                  next_state <= WAIT_ON_CMD;     			        
               when others =>
                  next_state <= WAIT_ON_CMD;
            end case;              
         when WRITE_LCD_CMD_START => 
            --write next bit on falling edge of scl_clk
            if (scl_clk_en ='1' and scl_clk_rising = '0') then
               next_state <= WRITE_LCD_CMD_NEXT;
            else
               next_state <= WRITE_LCD_CMD_START;
            end if;
         when WRITE_LCD_CMD_NEXT =>
            next_state <= WRITE_LCD_CMD_WAIT;
         when WRITE_LCD_CMD_WAIT =>
            --write next bit on falling edge of scl_clk, or finish
            if (scl_clk_en ='1' and scl_clk_rising = '0') then
               if (lcd_cmd_idx = "111") then --if the lcd_cmd_idx is 111 while entering wait state 
                  next_state <= WRITE_LCD_CMD_STOP;
               else
                  next_state <= WRITE_LCD_CMD_NEXT;	
               end if;
            else
               next_state <= WRITE_LCD_CMD_WAIT;
            end if;
         when WRITE_LCD_CMD_STOP =>
            next_state <= WAIT_ON_CMD;         
         when others =>
            null;
      end case;      
   END PROCESS;
      
      
END Behavioral6;
