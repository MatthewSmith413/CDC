module CDCtesting(
	input reset, TXData, TXClk, RXClk,
	output RXData, TXReady, RXReady
);
	// use this line to connect a CDC module to the testbench
	FIFO cdcmodule(reset, TXData, TXClk, RXClk, RXData, TXReady, RXReady);
endmodule

module failAll(
	input reset, TXData, TXClk, RXClk,
	output RXData, TXReady, RXReady
);
	// this module will fail all tests.
	assign RXData = 1'b0;
	assign TXReady = 1'b1;
	assign RXReady = 1'b1;
endmodule

module stallAll(
	input reset, TXData, TXClk, RXClk,
	output RXData, TXReady, RXReady
);
	// this module will stall indefinitely.
	assign RXData = 1'b0;
	assign TXReady = 1'b0;
	assign RXReady = 1'b0;
endmodule


module FIFO #(parameter WIDTH = 8)(
	input reset, TXData, TXClk, RXClk,
	output RXData, TXReady, RXReady
);
	// this module will pass all tests
	logic [WIDTH-1:0] TXIndex, RXIndex, diff;
	logic [0:0] ram[1<<WIDTH];
	always @(posedge TXClk) begin
		ram[TXIndex] <= TXData;
	end
	always @(posedge TXClk or posedge reset) begin
		TXIndex <= reset?0:TXReady?TXIndex+1:TXIndex;
	end
	always @(posedge RXClk or posedge reset) begin
		RXIndex <= reset?0:RXReady?RXIndex+1:RXIndex; // if reset, turn off. if RXReady, increment.
	end
	assign RXData = ram[RXIndex];
	assign RXReady = RXIndex != TXIndex;
	assign TXReady = diff!=3;
	assign diff = RXIndex-TXIndex;
	
endmodule
