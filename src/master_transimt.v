
`timescale 1ns / 1ps

module SPI_Transmitter #(
    parameter SPI_DATALENGTH = 4'd8 //
)
(
    input clk,
    input rst,
    output reg sendComplete,
    output MOSI,
    output reg SCLK,
    output reg CS,
    input MISO,
    input [7:0] sendData,
    output reg [7:0] recvData
);
    reg [7:0] sendData_reg;
reg [7:0] recvData_reg;  //
    reg[4:0] counter;
    reg[1:0] state;
    localparam DEFSTATE   = 2'b00;
    localparam CLKUP      = 2'b01;
    localparam CLKDOWN    = 2'b10;
    localparam DATACHANGE = 2'b11;
    
    assign MOSI = sendData_reg[7];
    assign MISO = recvData_reg[7]; //
    reg[7:0] recvData_tmp;
    reg[7:0] sentData_tmp;        //

    always @(posedge clk or negedge rst)begin
        if(rst == 1'b0)begin
            sendComplete <= 1'b0;
            recvData <= 8'b0000_0000;
            recvData_tmp <= 8'b0000_0000;
            SCLK     <= 1'b0;
            CS       <= 1'b1;
            counter  <= 4'b0000;
            sendData_reg <= sendData; // default 0 or leavin it as shown
            state <= DEFSTATE;
        end else begin
            case (state)
                DEFSTATE : begin
                    sendComplete <= 1'b0;
                    SCLK  <= 1'b0;
                    CS    <= 1'b0;
                    state <= CLKUP;
                    recvData_reg <= recvData;
		    sendData_reg <= sendData;
                    recvData_tmp <= recvData;
                    sentData_tmp <= sendData;
                end
                CLKUP : begin
                    sendComplete <= 1'b0;
                    SCLK  <= 1'b1;
                    CS    <= 1'b0;
                    state <= CLKDOWN;
                    recvData <= recvData;         // 
                    recvData_tmp <= recvData_tmp;
                    sentData_tmp <= sentData_tmp; //
                end
                CLKDOWN : begin
                    sendComplete <= 1'b0;
                    SCLK  <= 1'b0;
                    CS    <= 1'b0;
                    state <= DATACHANGE;
                    recvData_tmp <= {recvData_tmp[6:0],MISO};
		    sentData_tmp <= {sentData_tmp[6:0],MOSI};
                    recvData <= recvData;
                end
                DATACHANGE : begin
                    SCLK <= SCLK;
                    recvData_tmp <= recvData_tmp;
		    sentData_tmp <= sentData_tmp;
                    if (counter == SPI_DATALENGTH - 4'b0001)begin
                        sendComplete <= 1'b1;
                        CS           <= 1'b1;
                        state        <= DATACHANGE;
                        counter      <= counter;
                        recvData     <= recvData_tmp;
                    end else begin
                        sendComplete <= 1'b0;
                        sendData_reg <= sentData_tmp;
                        recvData_reg <= recvData_tmp;
                        state        <= CLKUP;
                        counter      <= counter + 4'b0001;
                        recvData     <= recvData;
                    end
                end
                default :
                    SCLK <= 1'b0;
            endcase
        end
    end
endmodule
