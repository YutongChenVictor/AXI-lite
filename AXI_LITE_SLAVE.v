module AXI_LITE_SLAVE
#(
    parameter integer   ADDR_WIDTH = 4        ,
    parameter integer   DATA_WIDTH = 32
)
(
    input                               ACLK        ,
    input                               ARST_N      ,
//写地址
    input       [ADDR_WIDTH-1:0]        AW_ADDR     ,
    input                               AW_VALID    ,
    output  reg                         AW_READY    ,
//写数据
    input       [DATA_WIDTH-1:0]        W_DATA      ,
    input       [(DATA_WIDTH/8)-1:0]    W_STRB      ,
    input                               W_VALID     ,
    output  reg                         W_READY     ,
//写响应
    output  reg [1:0]                   B_RESP      ,
    output  reg                         B_VALID     ,
    input                               B_READY     ,
//读地址
    input       [ADDR_WIDTH-1:0]        AR_ADDR     ,
    input                               AR_VALID    ,
    output  reg                         AR_READY    ,
//读数据
    output  reg [DATA_WIDTH-1:0]        R_DATA      ,
    output  reg [1:0]                   R_RESP      ,
    output  reg                         R_VALID     ,
    input                               R_READY
);

localparam LSB = DATA_WIDTH/32 + 1;//配合字节有效位

integer i;

reg [ADDR_WIDTH-1:0]    waddr       ;
reg [ADDR_WIDTH-1:0]    raddr       ;

reg [DATA_WIDTH-1:0]    W_DATA_reg0 ;
reg [DATA_WIDTH-1:0]    W_DATA_reg1 ;
reg [DATA_WIDTH-1:0]    W_DATA_reg2 ;
reg [DATA_WIDTH-1:0]    W_DATA_reg3 ;
reg [DATA_WIDTH-1:0]    R_DATA_reg  ;


//写地址通道
//AW_READY
always@(posedge ACLK or negedge ARST_N)begin
    if(!ARST_N)begin
        AW_READY <= 1'b0;
    end
    else if(B_READY && B_VALID)begin
        AW_READY <= 1'b0;
    end
    else if(!AW_READY && W_VALID && AW_VALID)begin
        AW_READY <= 1'b1;
    end
    else begin
        AW_READY <= 1'b0;
    end
end

//AW_ADDR
always@(posedge ACLK or negedge ARST_N)begin
    if(!ARST_N)begin
        waddr <= 'b0;
    end
    else if(!AW_READY && W_VALID && AW_VALID)begin
        waddr <= AW_ADDR;
    end
end

//写数据通道
//W_READY
always@(posedge ACLK or negedge ARST_N)begin
    if(!ARST_N)begin
        W_READY <= 1'b0;
    end
    else if(B_READY && B_VALID)begin
        W_READY <= 1'b0;
    end
    else if(!AW_READY && W_VALID && AW_VALID)begin
        W_READY <= 1'b1;
    end
    else begin
        W_READY <= 1'b0;
    end
end

//W_DATA
always@(posedge ACLK or negedge ARST_N)begin
    if(!ARST_N)begin
        W_DATA_reg0  <= 'b0;
        W_DATA_reg1  <= 'b0;
        W_DATA_reg2  <= 'b0;
        W_DATA_reg3  <= 'b0;
    end
    else if(!AW_READY && W_VALID && AW_VALID)begin
        case(waddr[ADDR_WIDTH-1:LSB])
            2'b00:begin
                for(i = 0;i < (DATA_WIDTH/8); i = i + 1)begin
                    if(W_STRB[i])begin
                        W_DATA_reg0[i*8 +: 8] <= W_DATA[i*8 +: 8];
                    end
                end
            end

                2'b01:begin
                for(i = 0;i < (DATA_WIDTH/8); i = i + 1)begin
                    if(W_STRB[i])begin
                        W_DATA_reg1[i*8 +: 8] <= W_DATA[i*8 +: 8];
                    end
                end
            end

            2'b10:begin
                for(i = 0;i < (DATA_WIDTH/8); i = i + 1)begin
                    if(W_STRB[i])begin
                        W_DATA_reg3[i*8 +: 8] <= W_DATA[i*8 +: 8];
                    end
                end
            end

            2'b11:begin
                for(i = 0;i < (DATA_WIDTH/8); i = i + 1)begin
                    if(W_STRB[i])begin
                        W_DATA_reg3[i*8 +: 8] <= W_DATA[i*8 +: 8];
                    end
                end
            end

            default: begin
                W_DATA_reg0  <= W_DATA_reg0;
                W_DATA_reg1  <= W_DATA_reg1;
                W_DATA_reg2  <= W_DATA_reg2;
                W_DATA_reg3  <= W_DATA_reg3;
            end
        endcase
    end
end

//写响应
//B_RESP
always@(posedge ACLK or negedge ARST_N)begin
    if(!ARST_N)begin
        B_RESP <= 2'b00;
    end
    else if(!B_VALID && W_READY && AW_READY && W_VALID && AW_VALID)begin
        B_RESP <= 2'b00;
    end
end

//B_VALID
always@(posedge ACLK or negedge ARST_N)begin
    if(!ARST_N)begin
        B_VALID <= 1'b0;
    end
    else if(!B_VALID && W_READY && AW_READY && W_VALID && AW_VALID)begin
        B_VALID <= 1'b1;
    end
    else if(B_READY && B_VALID)begin
        B_VALID <= 1'b0;
    end
end

//读地址
//AR_READY
always@(posedge ACLK or negedge ARST_N)begin
    if(!ARST_N)begin
        AR_READY <= 1'b0;
    end
    else if(!AR_READY && AR_VALID && R_VALID)begin
        AR_READY <= 1'b1;
    end
    else begin
        AR_READY <= 1'b0;
    end
end

//R_ADDR
always@(posedge ACLK or negedge ARST_N)begin
    if(!ARST_N)begin
        raddr <= 'b0;
    end
    else if(!AR_READY && AR_VALID)begin
        raddr <= AR_ADDR;
    end
end

//读数据
//R_VALID
always@(posedge ACLK or negedge ARST_N)begin
    if(!ARST_N)begin
        R_VALID <= 1'b0;
    end
    else if(R_READY && R_VALID)begin
        R_VALID <= 1'b0;
    end
    else if(!R_VALID && AR_VALID)begin
        R_VALID <= 1'b0;
    end
end

//R_RESP
always@(posedge ACLK or negedge ARST_N)begin
    if(!ARST_N)begin
        R_RESP <= 2'b00;
    end
    else if(R_READY && R_VALID)begin
        R_RESP <= 2'b00;
    end
    else if(!R_VALID && AR_VALID)begin
        R_RESP <= 2'b00;
    end
end

//R_DATA
always@(*)begin
    if(!ARST_N)begin
        R_DATA_reg <= 'b0;
    end
    else if(!R_READY && R_VALID && AR_VALID)begin
        case(raddr[ADDR_WIDTH-1:LSB])
            2'b00:begin
                R_DATA_reg <= W_DATA_reg0;
            end

            2'b01:begin
                R_DATA_reg <= W_DATA_reg1;
            end

            2'b10:begin
                R_DATA_reg <= W_DATA_reg2;
            end

            2'b11:begin
                R_DATA_reg <= W_DATA_reg3;
            end
            default begin
                R_DATA_reg <= 'b0;
            end
        endcase
    end
end

always@(posedge ACLK or negedge ARST_N)
    if(~ARST_N)
        R_DATA <= 'd0;
    else if(~R_READY && R_VALID && AR_VALID)begin
        R_DATA <= R_DATA_reg;
    end
    else begin
        R_DATA <= 'd0;
    end
endmodule
