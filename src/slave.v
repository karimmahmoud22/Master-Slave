module Slave(

input clk,
      rst,
      sendStart,
input[7:0] sendData,
output [7:0] recvData,
output SPI_SCLK,
[2:0]  SPI_CS,
input SPI_MOSI,
output  SPI_MISO
);
// chip select here

    localparam STATE_INITIALIZE  = 2'b00;
    localparam STATE_SENDMSG     = 2'b01;
    localparam STATE_FINALIZE    = 2'b11;
    parameter SPI_DATALENGTH = 4'd8;

    reg [1:0] currentState;
    reg [1:0] nextState;
    reg sendStart_reg;
    wire sendComplete;
    
    
    SPI_Transmitter22 #(SPI_DATALENGTH) transmitter33(
        .clk(clk),
        .rst(sendStart_reg),
        .sendComplete(sendComplete),
        .MISO(SPI_MISO),
        .SCLK(SPI_SCLK),
        .CS(SPI_CS),
        .MOSI(SPI_MOSI),
        .sendData(sendData),
        .recvData(recvData)
    );
    
    always @ (posedge clk or negedge rst) begin
        if(rst == 1'b0)begin
            currentState <= STATE_INITIALIZE;
            sendStart_reg <= 1'b0;
        end else begin
            case (currentState)
                STATE_INITIALIZE : begin
                    if(sendStart == 1'b1)begin
                        currentState <= STATE_SENDMSG;
                        sendStart_reg <= 1'b1;
                    end else begin
                        currentState <= currentState;
                        sendStart_reg <= 1'b0;
                    end
                end
                STATE_SENDMSG : begin
                    if(sendComplete == 1'b1) begin
                        currentState <= STATE_FINALIZE;
                        sendStart_reg <= 1'b1;
                    end else begin
                        currentState <= currentState;
                        sendStart_reg <= 1'b1;
                    end
                end
                STATE_FINALIZE : begin
                    if(sendStart == 1'b0)begin
                        currentState <= STATE_INITIALIZE;
                        sendStart_reg <= 1'b0;
                    end else begin
                        currentState <= currentState;
                        sendStart_reg <= 1'b1;
                    end
                end
            endcase
        end
    end
    
endmodule
