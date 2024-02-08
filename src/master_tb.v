`timescale 1ns / 1ps
`include"Master.v"
module tb_SPI_Master();

    reg clk;
    reg rst;
    wire SPI_MOSI;
    wire SPI_SCLK;
    wire SPI_CS;
    wire SPI_MISO;
    reg [7:0] sendData;
    wire[7:0] recvData;
    reg sendStart;

    Master spimaster (
        .clk(clk),
        .rst(rst),
        .sendStart(sendStart),
        .sendData(sendData),
        .recvData(recvData),
        .SPI_SCLK(SPI_SCLK),
        .SPI_CS(SPI_CS),
	.SPI_MOSI(SPI_MOSI),
        .SPI_MISO(SPI_MISO)
    );

    //pseud slave device  


    reg [7:0] slaveData;
    reg [7:0] MOSIReg;
    assign SPI_MISO = slaveData[7];
    // pseud slave device
    always @ (posedge SPI_SCLK or negedge rst)begin
        if(rst == 1'b0)begin
            slaveData <= 8'b10000011;
            MOSIReg <= 8'b00000000;
        end else begin
            slaveData <= {slaveData[6:0],1'b0};
            MOSIReg <= {MOSIReg[6:0],SPI_MOSI};
        end
    end


    always #10
    if(rst == 1'b0)
        clk <= 1'b0;
    else
        clk <= ~clk;

    initial begin
        #0
        rst <= 1'b0;
        sendData <= 8'b11000010;
        sendStart <= 1'b0;
        MOSIReg <= 8'b00000000;

        #30
        rst <= 1'b0;
        #50
        rst <= 1'b1;
	$display("Begin --> Data to send : %b, MOSI_REG : %b", sendData , MOSIReg);
        #50
        sendStart <= 1'b1;
        #2500
	$display("End --> Data to send : %b, MOSI_REG : %b", slaveData , MOSIReg);
        $finish;    

    end

endmodule