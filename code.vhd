----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2018 17:48:56
-- Design Name: 
-- Module Name: progetto_reti_logiche - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity project_reti_logiche is 
	port(
		i_clk		: in	std_logic;		
		i_start		: in	std_logic;		
		i_rst		: in 	std_logic;
		i_data		: in 	std_logic_vector(7 downto 0);
		o_address	: out	std_logic_vector(15 downto 0);
		o_done		: out 	std_logic;
		o_en		: out 	std_logic;
		o_we		: out 	std_logic;
		o_data		: out 	std_logic_vector(7 downto 0)
		);
end project_reti_logiche;

architecture fsm of project_reti_logiche is
    type state is (reset, empty, S0, S1, S2, S3, S4, S5, S6, S7, S8, S9);
    signal state_curr : state;
    signal colonne, righe, soglia, sx, dx, h, l, curr_col, curr_rig : std_logic_vector(7 downto 0);    
    signal valido : std_logic;
    signal last_out_add, area : std_logic_vector(15 downto 0);
    
    
    
begin
    oneprocess: process(i_clk, i_rst)
    
    begin
        if(i_rst = '1') then
            state_curr <= reset;
            
        elsif(rising_edge(i_clk)) then
            case state_curr is
                when reset =>
                    if(i_start = '1') then
                        o_en <= '1';
                        o_we <= '0';
                        state_curr <= empty;
                        o_address <= "0000000000000010";
                    else
                        state_curr <= reset;
                    end if;
                when empty =>
                    o_address <= "0000000000000011";
                    state_curr <= S0;
                when S0 =>
                        o_address <= "0000000000000100";
                        last_out_add <= "0000000000000110";
                        colonne <= i_data;
                        o_en <= '1';
                        o_we <= '0';
                        state_curr <= S1;
                when S1 =>
                    righe <= i_data;
                    
                    o_en <= '1';
                    o_we <= '0';
                    state_curr <= S2;
                when S2 =>
                    soglia <= i_data;
                    o_address <= "0000000000000101";
                    o_en <= '1';
                    o_we <= '0';
                    state_curr <= S3;
                when S3 =>
                    
                    sx <= colonne;
                    dx <= "00000000";
                    h <= righe;
                    l <= "00000000";
                    o_address <= "0000000000000110";
                    o_en <= '1';
                    o_we <= '0';
                    curr_col <= "00000001";
                    curr_rig <= "00000001";
                    valido <= '0';
                    state_curr <= S4;
                when S4 =>
                    if( unsigned(curr_col)= unsigned(colonne) AND unsigned(curr_rig)  = unsigned(righe)) then
                        if( unsigned(i_data) >= unsigned(soglia)) then
                            valido <= '1';
                            if( unsigned(curr_col) > unsigned(dx)) then
                                dx <= curr_col;
                            
                            end if;
                            if( unsigned(curr_col) < unsigned(sx)) then
                                sx <= curr_col;
                                
                            end if;
                            if( unsigned(curr_rig) < unsigned(h)) then
                                h <= curr_rig;
                            
                            end if;
                            if( unsigned(curr_rig) > unsigned(l)) then
                                l <= curr_rig;
                            
                            end if;
                        end if;
                                
                        o_en <= '0';
                        state_curr <= S5;
                    elsif( unsigned(curr_col)= unsigned(colonne) AND unsigned(curr_rig) < unsigned(righe)) then  
                        if( unsigned(i_data) >= unsigned(soglia)) then
                            valido <= '1';
                            if( unsigned(curr_col) > unsigned(dx)) then
                                dx <= curr_col;
                            end if;
                            if( unsigned(curr_col) < unsigned(sx)) then
                                sx <= curr_col;
                            end if;
                            if( unsigned(curr_rig) < unsigned(h)) then
                                h <= curr_rig;
                            end if;
                            if( unsigned(curr_rig) > unsigned(l)) then
                                l <= curr_rig;
                            end if;
                        end if;
                        curr_rig <= std_logic_vector(unsigned(curr_rig) + "00000001");
                        curr_col <= "00000001";
                        o_address <= std_logic_vector(unsigned(last_out_add) + "0000000000000001");
                        last_out_add <= std_logic_vector(unsigned(last_out_add) + "0000000000000001");
                        o_en <= '1';
                        state_curr <= S4;
                    
                    elsif(unsigned(curr_col) > unsigned(colonne) OR unsigned(curr_rig) > unsigned(righe)) then
                        o_en <= '0';
                        state_curr <= S5;
                    else
                        if( unsigned(i_data) >= unsigned(soglia)) then
                            valido <= '1';
                            if( unsigned(curr_col) > unsigned(dx)) then
                                dx <= curr_col;
                            end if;
                            if( unsigned(curr_col) < unsigned(sx)) then
                                sx <= curr_col;
                            end if;
                            if( unsigned(curr_rig) < unsigned(h)) then
                                h <= curr_rig;
                            end if;
                            if( unsigned(curr_rig) > unsigned(l)) then
                                l <= curr_rig;
                            end if;
                        end if;
                        curr_col <= std_logic_vector(unsigned(curr_col) + "00000001");
                        o_address <= std_logic_vector(unsigned(last_out_add) + "0000000000000001");
                        last_out_add <= std_logic_vector(unsigned(last_out_add) + "0000000000000001");
                        o_en <= '1';
                        state_curr <= S4;
                    end if;
                when S5 =>
                    if( valido = '1') then
                        area <= std_logic_vector((unsigned(dx) - unsigned(sx) + 1) * (unsigned(l)-unsigned(h)+1));
                        state_curr <= S6;
                    else
                        area <= "0000000000000000";
                        state_curr <= S6;
                    end if;
                when S6 =>
                    o_data <= area(15 downto 8);
                    o_address <= "0000000000000001";
                    o_en <= '1';
                    o_we <= '1';
                    state_curr <= S7;
                when S7 =>
                    o_data <= area(7 downto 0);
                    o_address <= "0000000000000000";
                    o_en <= '1';
                    o_we <= '1';
                    state_curr <= S8;
                when S8 =>
                    o_done <= '1';
                    o_en <= '1';
                    o_we <= '0';
                    state_curr <= S9;
                when S9 =>
                    o_done <= '0';
                    o_en <= '1';
                    --state_curr <= reset;
        end case;
        end if;
    end process;  
end architecture;