module tb;

//  1. Signals
reg clk = 0;
reg rst;
reg start;
reg [7:0] data_in;
wire tx;

//  2. Scoreboard storage
reg [7:0] expected_queue [0:10];
integer write_ptr = 0;
integer read_ptr = 0;

//  3. DUT
uart_tx uut (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .start(start),
    .tx(tx)
);

//  4. Dumpfile
initial begin
    $dumpfile("dump.vcd");
  $dumpvars(0, tb);
end

  integer file;

initial begin
    file = $fopen("uart.csv", "w");

    $fwrite(file, "time,clk,rst,start,tx,data_in\n");

    forever begin
        #10;
        $fwrite(file, "%0t,%b,%b,%b,%b,%h\n",
                 $time, clk, rst, start, tx, data_in);
    end
end
//  5. Clock
always #5 clk = ~clk;

//  6. Stimulus 
initial begin
    rst = 1;
    start = 0;
    #10 rst = 0;

    repeat (5) begin
        data_in = $random;

        // store expected value
        expected_queue[write_ptr] = data_in;
        write_ptr = write_ptr + 1;

        start = 1;
        #10 start = 0;
        #100;
    end

    #200 $finish;
end
//  7. SCOREBOARD 

reg [7:0] received;
integer i;

initial begin
    forever begin
        @(negedge tx);   // detect start bit

        #5;              // move to center

        #10;             // skip start bit

        // capture data
        for (i = 0; i < 8; i = i + 1) begin
            received[i] = tx;
            #10;
        end

        // check stop bit
        if (tx != 1)
            $display(" Stop bit error");
        else
            $display("Stop bit correct");

        // compare data
        if (received == expected_queue[read_ptr])
            $display("PASS: %h", received);
        else
            $display(" FAIL: Expected=%h Got=%h",
                     expected_queue[read_ptr], received);

        read_ptr = read_ptr + 1;
    end
end

endmodule
