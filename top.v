`timescale 1ns / 1ps

module top(
    input clk, rst_n, mode, 
    input dout,
    output reg cs_n, sclk, din,
    output reg [11:0] data,
    output clk_xk
);
    
    //400kHz clock instantiation
    Clock_xk u1(.clk(clk), .clk_xk(clk_xk), .rst_n(rst_n));
    
  reg [7:0] cnv_count, cs_count, addr;
    
    // cs_n counter logic
    always @(posedge clk_xk)
    begin
        if (!rst_n) 
        begin
            cs_count <= 8'd0;
        end
       
        else
        begin   
            if (cs_count <= 8'd32)
            begin
                cs_count <= cs_count + 1'b1;
            end
            
            else
            begin
                cs_count <= 8'd0;
            end
        end
    end
    
    // cnv_count logic
    always @(negedge clk_xk)
    begin
        if (!rst_n)
        begin
            cnv_count <= 8'd7;
        end
        
        else
        begin
            if (cs_n == 1'b0 && cnv_count > 8'd0 && sclk == 1'b0)
            begin
                cnv_count <= cnv_count - 1'b1;
            end
            else if (cs_n == 1'b0 && cnv_count == 8'd0)
            begin
                cnv_count <= cnv_count;
            end
            
            else if (cs_n == 1'b1)
            begin
                cnv_count <= 8'd7;
            end
            
            else
                cnv_count <= cnv_count; // cnv_count - 1'b1;
        end
    end
    
    // cs_n logic
    always @(posedge clk_xk)
    begin   
        if (!rst_n)
        begin
            cs_n <= 1'b1;
        end
        
        else
        begin
            if (cs_count == 8'd0);
            begin
                cs_n <= 1'b0;
            end
            
            if (cs_count > 8'd32)
            begin
                cs_n <= 1'b1;
            end
        end
    end
    
    // sclk logic
    always @(posedge clk_xk)
    begin
        if (!rst_n || cs_n == 1'b1)
        begin
            sclk <= 1'b1;
        end
        
        else
        begin
            if (cs_count >= 8'd1 && cs_n == 1'b0 && cs_count <= 8'd32)
            begin
                sclk <= ~sclk;
            end
            
            else 
            begin   
                sclk <= sclk;
            end
        end
                
    end
    
    // din logic
    always @(negedge sclk)
    begin
        if (cs_n == 1'b0)
        begin
            din <= addr[cnv_count]; 
        end
    end   
    
    // addr logic
    always @(posedge clk_xk)
    begin
        if (!rst_n) 
        begin
            addr <= 8'd0;
        end
        
        else
        begin
            if (cs_count == 8'd32 && addr < 8'd7)
            begin
                addr <= addr + 1'b1;
            end
            
            else if (cs_count == 8'd32 && addr >= 8'd7)
            begin
                addr <= 8'd0;
            end
        end
    end
    
    // dout logic
    always @(negedge sclk)
    begin
        if (cs_n == 1'b0)
        begin
            data <= {data, dout};
        end
        
        else 
        begin
            data <= 12'd0;
        end
    end
endmodule
