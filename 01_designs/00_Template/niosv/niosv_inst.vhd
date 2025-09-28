	component niosv is
		port (
			clk_50m_clk       : in  std_logic := 'X'; -- clk
			key_export        : in  std_logic := 'X'; -- export
			led_export        : out std_logic;        -- export
			reset_50m_reset_n : in  std_logic := 'X'  -- reset_n
		);
	end component niosv;

	u0 : component niosv
		port map (
			clk_50m_clk       => CONNECTED_TO_clk_50m_clk,       --   clk_50m.clk
			key_export        => CONNECTED_TO_key_export,        --       key.export
			led_export        => CONNECTED_TO_led_export,        --       led.export
			reset_50m_reset_n => CONNECTED_TO_reset_50m_reset_n  -- reset_50m.reset_n
		);

