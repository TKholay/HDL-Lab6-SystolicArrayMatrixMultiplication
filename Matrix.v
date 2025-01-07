`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2024 12:38:15 PM
// Design Name: 
// Module Name: Matrix
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Matrix(clk, start, reset,
a00,a01,a02,a10,a11,a12,a20,a21,a22,
b00,b01,b02,b10,b11,b12,b20,b21,b22,
M1_out,M2_out,M3_out,M4_out,M5_out,M6_out,M7_out,M8_out,M9_out,
done);

    input clk, start, reset;
    input[8:0] a00,a01,a02,a10,a11,a12,a20,a21,a22;
    input[8:0] b00,b01,b02,b10,b11,b12,b20,b21,b22;
    output reg [8:0] M1_out,M2_out,M3_out,M4_out,M5_out,M6_out,M7_out,M8_out,M9_out;
    output reg done;
    
    reg [2:0] state;
    
    initial begin
        state <= 0;
        done <= 0;
        M1_out = 8'b0;
        M2_out = 8'b0;
        M3_out = 8'b0;
        M4_out = 8'b0;
        M5_out = 8'b0;
        M6_out = 8'b0;
        M7_out = 8'b0;
        M8_out = 8'b0;
        M9_out = 8'b0;
    end
    
    always @(posedge clk) begin
        if(reset == 1) begin
            M1_out <= 8'b0;
            M2_out <= 8'b0;
            M3_out <= 8'b0;
            M4_out <= 8'b0;
            M5_out <= 8'b0;
            M6_out <= 8'b0;
            M7_out <= 8'b0;
            M8_out <= 8'b0;
            M9_out <= 8'b0;
            state = 0;
        end
        else if(start) begin
            if(state >= 0 && state < 7) begin
                state = state + 1;
            end
        end
    end
    
    always @(state) begin
        if(!reset) begin
            if(start) begin
                case(state)
                    1: begin
                        M1_out = mac(a00, b00, M1_out);
                    end
                    2: begin
                        M1_out = mac(a01, b10, M1_out);
                        M2_out = mac(a00, b01, M2_out);
                        M4_out = mac(a10, b00, M4_out);
                    end
                    3: begin
                        M1_out = mac(a02, b20, M1_out); 
                        M2_out = mac(a01, b11, M2_out);
                        M4_out = mac(a11, b10, M4_out);
                        M3_out = mac(a00, b02, M3_out);
                        M5_out = mac(a10, b01, M5_out);
                        M7_out = mac(a20, b00, M7_out);
                    end
                    4: begin
                        M2_out = mac(a02, b21, M2_out);
                        M4_out = mac(a12, b20, M4_out);
                        M3_out = mac(a01, b12, M3_out);
                        M5_out = mac(a11, b11, M5_out);
                        M7_out = mac(a21, b10, M7_out);
                        M6_out = mac(a10, b02, M6_out);
                        M8_out = mac(a20, b01, M8_out);
                    end
                    5: begin
                        M3_out = mac(a02, b22, M3_out);
                        M5_out = mac(a12, b21, M5_out);
                        M7_out = mac(a22, b20, M7_out);
                        M6_out = mac(a11, b12, M6_out);
                        M8_out = mac(a21, b11, M8_out);
                        M9_out = mac(a20, b02, M9_out);
                    end
                    6: begin
                        M6_out = mac(a12, b22, M6_out);
                        M8_out = mac(a22, b21, M8_out);
                        M9_out = mac(a21, b12, M9_out);
                    end
                    7: begin
                        M9_out = mac(a22, b22, M9_out);
                    end
                    0: begin
                    end
                    default: begin
                    end
                endcase
            end
        end
    end
    
    function [7:0] mac;
        input [7:0] a, b;  // 8-bit floating-point inputs
        input [7:0] acc;   // 8-bit floating-point accumulator
        
        reg [7:0] big, sml;
        
        reg sign_a, sign_b, sign_mul_result, sign_acc;  // Sign bits
        reg [2:0] exp_a, exp_b, exp_mul_result, exp_acc, result_exp; // Exponent parts
        reg [4:0] mant_a, mant_b; // Mantissa parts (4 bits)
        reg [3:0] mant_mul_result, mant_add_result;
        reg [9:0] big_mant_mul_result;
        
        reg [7:0] mul_result, add_result;
        reg [3:0] diff_exp;
        reg [7:0] big_val, sml_val;
        reg [8:0] result_val;
    
        begin
            //$display("Mac called");
            //$display("a: %b", a);
            //$display("b: %b", b);
            //$display("acc: %b", acc);
            
            //mul a and b
            sign_a = a[7];
            sign_b = b[7];
            sign_mul_result = sign_a ^ sign_b;
            //$display("Sign Mul Result: %b", sign_mul_result);
            
            exp_a = a[6:4];
            exp_b = b[6:4];
            exp_mul_result = exp_a + exp_b - 3;
            //$display("Exp Mul Result: %b", exp_mul_result);
            
            mant_a = {1'b1, a[3:0]};
            mant_b = {1'b1, b[3:0]};
            big_mant_mul_result = mant_a * mant_b;
            //$display("Mant a: %b", mant_a);
            //$display("Mant b: %b", mant_b);
            //$display("Big Mant Mul Result: %b", big_mant_mul_result);
            
            if(big_mant_mul_result[9] == 1) begin
                mant_mul_result = big_mant_mul_result[8:5];
                exp_mul_result = exp_mul_result + 1;
            end
            else if(big_mant_mul_result[8] == 1) begin
                mant_mul_result = big_mant_mul_result[7:4];
            end
            else if(big_mant_mul_result[7] == 1) begin
                mant_mul_result = big_mant_mul_result[6:3];
                exp_mul_result = exp_mul_result - 1;
            end
            else if(big_mant_mul_result[6] == 1) begin
                mant_mul_result = big_mant_mul_result[5:2];
                exp_mul_result = exp_mul_result - 2;
            end
            else if(big_mant_mul_result[5] == 1) begin
                mant_mul_result = big_mant_mul_result[4:1];
                exp_mul_result = exp_mul_result - 3;
            end
            else if(big_mant_mul_result[4] == 1) begin
                mant_mul_result = big_mant_mul_result[3:0];
                exp_mul_result = exp_mul_result - 4;
            end
            else if(big_mant_mul_result[3] == 1) begin
                mant_mul_result = {big_mant_mul_result[2:0], 1'b0};
                exp_mul_result = exp_mul_result - 5;
            end
            else if(big_mant_mul_result[2] == 1) begin
                mant_mul_result = {big_mant_mul_result[1:0], 2'b00};
                exp_mul_result = exp_mul_result - 6;
            end
            else if(big_mant_mul_result[1] == 1) begin
                mant_mul_result = {big_mant_mul_result[0], 2'b000};
                exp_mul_result = exp_mul_result - 7;
            end
            else if(big_mant_mul_result[0] == 1) begin
                mant_mul_result = 4'b0000;
                exp_mul_result = exp_mul_result - 8;
            end
            //$display("Exp Mul Result: %b", exp_mul_result);
            
            if(a[7:0] == 0 || b[7:0] == 0) begin
                mul_result = 8'b0;
            end
            else begin
                mul_result = {sign_mul_result, exp_mul_result, mant_mul_result};
            end
            //$display("Mul Result: %b", mul_result);
            
            //add to acc
            sign_acc = acc[7];
            exp_acc = acc[6:4];
            //$display("Acc: %b", acc);
            
            if(mul_result[6:0] > acc[6:0])begin
                big = mul_result;
                big_val = {1'b1, mul_result[3:0], 3'b000};
                sml = acc;
                sml_val = {1'b1, acc[3:0], 3'b000};
            end
            else begin
                big = acc;
                big_val = {1'b1, acc[3:0], 3'b000};
                sml = mul_result;
                sml_val = {1'b1, mul_result[3:0], 3'b000};
            end
            
            result_exp = big[6:4];
            //$display("Result Val: %b", result_exp);
            //$display("Big Val: %b", big_val);
            
            diff_exp = big[6:4] - sml[6:4];
            sml_val = sml_val >> diff_exp;
            //$display("Small Val: %b", sml_val);
            
            if(mul_result[7] == acc[7])begin
                result_val = big_val + sml_val;
            end
            else begin
                result_val = big_val - sml_val;
            end
            //$display("Result Val: %b", result_val);
            
            if(result_val[8] == 1) begin
                mant_add_result = result_val[7:4];
                result_exp = result_exp + 1;
            end
            else if(result_val[7] == 1) begin
                mant_add_result = result_val[6:3];
            end
            else if(result_val[6] == 1) begin
                mant_add_result = result_val[5:2];
                result_exp = result_exp - 1;
            end
            else if(result_val[5] == 1) begin
                mant_add_result = result_val[4:1];
                result_exp = result_exp - 2;
            end
            else if(result_val[4] == 1) begin
                mant_add_result = result_val[3:0];
                result_exp = result_exp - 3;
            end
            else if(result_val[3] == 1) begin
                mant_add_result = {result_val[2:0], 1'b0};
                result_exp = result_exp - 4;
            end
            else if(result_val[2] == 1) begin
                mant_add_result = {result_val[1:0], 2'b00};
                result_exp = result_exp - 5;
            end
            else if(result_val[1] == 1) begin
                mant_add_result = {result_val[0], 2'b000};
                result_exp = result_exp - 6;
            end
            else if(result_val[0] == 1) begin
                mant_add_result = 4'b0000;
                result_exp = result_exp - 7;
            end
            //$display("Result Exp: %b", result_exp);
            
            if(acc[7:0] == 0) begin
                add_result = mul_result;
            end
            else begin
                add_result = {big[7], result_exp, mant_add_result};
            end
            $display("Result: %b", add_result);
            
            mac = add_result;
        end 
    endfunction

endmodule
