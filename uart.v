module uart_tx(
    input clk,
    input rst,
    input [7:0] data_in,
    input start,
    output reg tx
);

reg [3:0] bit_index;
reg [9:0] shift_reg;
reg sending;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        tx <= 1;
        sending <= 0;
        bit_index <= 0;
    end else begin
        if (start && !sending) begin
            shift_reg <= {1'b1, data_in, 1'b0}; // stop + data + start
            sending <= 1;
            bit_index <= 0;
        end else if (sending) begin
            tx <= shift_reg[bit_index];
            bit_index <= bit_index + 1;

            if (bit_index == 9)
                sending <= 0;
        end
    end
end

endmodule
