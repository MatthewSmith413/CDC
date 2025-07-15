module testbench();
	logic runTest, reset;
	logic [63:0] TXbitCtr, RXbitCtr;
	logic [1:0] numberIndex;
	logic TXData, TXClk, RXClk, RXData, TXReady, RXReady;
	logic [299:0] received, receiveBitMask;
	logic [2:0] TXClkMode, RXClkMode;
	logic slowclk, fastclk, medclk, fastskew, fastjitter;
	
	CDCtesting DUT(reset, TXData, TXClk, RXClk, RXData, TXReady, RXReady);
	
	initial begin
		
		$display("starting all clocks");
		fastclk = 1'b0;
		medclk = 1'b0;
		slowclk = 1'b0;
		fastskew = 1'b0;
		fastjitter = 1'b0;
		
		$display("Test 1: TX is 10x the frequency of RX.");
		#5 runTest = 1'b0;
		#5 runTest = 1'b1;
		TXClkMode = 3'h2; // 200 us per cycle
		RXClkMode = 3'h1; // 2000 us per cycle
		
		wait (runTest == 1'b0);
		$display("Test 2: RX is 10x the frequency of TX.");
		#5 runTest = 1'b1;
		TXClkMode = 3'h1; // 2000 us per cycle
		RXClkMode = 3'h2; // 200 us per cycle
		
		wait (runTest == 1'b0);
		$display("Test 3: TX is 1.001x the frequency of RX.");
		#5 runTest = 1'b1;
		TXClkMode = 3'h1; // 2000 us per cycle
		RXClkMode = 3'h0; // 2002 us per cycle
		
		wait (runTest == 1'b0);
		$display("Test 4: RX is 1.001x the frequency of TX.");
		#5 runTest = 1'b1;
		TXClkMode = 3'h0; // 2002 us per cycle
		RXClkMode = 3'h1; // 2000 us per cycle
		
		wait (runTest == 1'b0);
		$display("Test 5: TX is skewed ahead of RX.");
		#5 runTest = 1'b1;
		TXClkMode = 3'h3; // 200 us per cycle, skewed early
		RXClkMode = 3'h2; // 200 us per cycle
		
		wait (runTest == 1'b0);
		$display("Test 6: RX is skewed ahead of TX.");
		#5 runTest = 1'b1;
		TXClkMode = 3'h2; // 200 us per cycle
		RXClkMode = 3'h3; // 200 us per cycle, skewed early
		
		wait (runTest == 1'b0);
		$display("Test 7: TX is steady and RX is jittery.");
		#5 runTest = 1'b1;
		TXClkMode = 3'h2; // 200 us per cycle
		RXClkMode = 3'h4; // 200 us per cycle, jittery
		
		wait (runTest == 1'b0);
		$display("Test 8: RX is steady and TX is jittery.");
		#5 runTest = 1'b1;
		TXClkMode = 3'h4; // 200 us per cycle, jittery
		RXClkMode = 3'h2; // 200 us per cycle
		
		wait (runTest == 1'b0);
		$display("end of tests");
		$stop;
	end
	
	// start all the clocks
	always begin
		#100 fastclk = 1'b1;
		#100 fastclk = 1'b0;
	end
	always begin
		#1001 slowclk = 1'b1;
		#1001 slowclk = 1'b0;
	end
	always begin
		#1000 medclk = 1'b1;
		#1000 medclk = 1'b0;
	end
	always begin
		// fastskew runs 10 us faster than fastclk
		#90 fastskew = 1'b1;
		#100 fastskew = 1'b0;
		#10 fastskew = 1'b0;
	end
	always begin
		#90 fastjitter = 1'b1; // 10 us ahead
		#90 fastjitter = 1'b0; // 20 us ahead
		#110 fastjitter = 1'b1; // 10 us ahead
		#100 fastjitter = 1'b0; // 10 us ahead
		#90 fastjitter = 1'b1; // 20 us ahead
		#120 fastjitter = 1'b0; // on time
		#110 fastjitter = 1'b1; // 10 us behind
		#120 fastjitter = 1'b0; // 30 us behind
		#90 fastjitter = 1'b1; // 20 us behind
		#80 fastjitter = 1'b0; // on time
	end
	
	// connect clocks to clk inputs
	always_comb begin
		case(TXClkMode)
			3'h0: TXClk = slowclk;
			3'h1: TXClk = medclk;
			3'h2: TXClk = fastclk;
			3'h3: TXClk = fastskew;
			3'h4: TXClk = fastjitter;
			default: TXClk = fastclk;
		endcase
	end
	
	always_comb begin
		case(RXClkMode)
			3'h0: RXClk = slowclk;
			3'h1: RXClk = medclk;
			3'h2: RXClk = fastclk;
			3'h3: RXClk = fastskew;
			3'h4: RXClk = fastjitter;
			default: RXClk = fastclk;
		endcase
	end
	
	// begin each test when runTest turns low
	always @(posedge runTest) begin
		$display("sending first word: 0xdeadbeef");
		reset = 1'b1;
		#5 reset = 1'b0;
		numberIndex = 2'h0;
		wait (RXbitCtr == 64'h021);
		$display("received: 0x%0h", received);
		if(32'hdeadbeef ^ received) $display("failed");
		else $display("passed");
		$display("sending second word: 0xc0ffee");
		reset = 1'b1;
		#5 reset = 1'b0;
		numberIndex = 2'h1;
		wait (RXbitCtr == 64'h019);
		$display("received: 0x%0h", received);
		if(24'hc0ffee ^ received) $display("failed");
		else $display("passed");
		$display("sending third word: 0x31415926535897932384626433832795028841971693993751058209749445923");
		reset = 1'b1;
		#5 reset = 1'b0;
		numberIndex = 2'h2;
		wait (RXbitCtr == 64'h0105);
		$display("received: 0x%0h", received);
		if(260'h31415926535897932384626433832795028841971693993751058209749445923 ^ received) $display("failed");
		else $display("passed");
		runTest = 1'b0;
	end
	
	always @(posedge TXClk or posedge reset) begin
		TXbitCtr <=	reset?0 :
						TXReady?TXbitCtr+1 :
						TXbitCtr;
	end
	always @(posedge RXClk or posedge reset) begin
		RXbitCtr =	reset?0 :
						RXReady?RXbitCtr+1 :
						RXbitCtr;
		received <=	reset?0 :
						(received & ~receiveBitMask) | (RXData?receiveBitMask:0);
	end
	
	always_comb begin
		case(numberIndex)
			2'h0: TXData = (32'hdeadbeef >> TXbitCtr);
			2'h1: TXData = (24'hc0ffee >> TXbitCtr);
			2'h2: TXData = (260'h31415926535897932384626433832795028841971693993751058209749445923 >> TXbitCtr);
			default: TXData = 1'b0;
		endcase
	end
	
	assign receiveBitMask = 1 << RXbitCtr;
endmodule
