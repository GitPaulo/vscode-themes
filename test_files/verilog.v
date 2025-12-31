/*
 * Comprehensive Verilog Test File
 * Tests all major language constructs for syntax highlighting
 */

// Timescale directive
`timescale 1ns / 1ps

// Define macros
`define WORD_SIZE 32
`define DATA_WIDTH 8
`define ADDR_WIDTH 16

// Include directive
`include "definitions.vh"

// Module with various port declarations
module comprehensive_design #(
    parameter WIDTH = 32,
    parameter DEPTH = 1024,
    parameter CLK_PERIOD = 10
) (
    // Clock and reset
    input wire clk,
    input wire rst_n,
    input wire enable,
    
    // Data inputs
    input wire [WIDTH-1:0] data_in,
    input wire [7:0] address,
    input wire write_enable,
    input wire read_enable,
    
    // Data outputs
    output reg [WIDTH-1:0] data_out,
    output wire valid_out,
    output reg error,
    
    // Bidirectional port
    inout wire [15:0] data_bus
);

    // Local parameters
    localparam IDLE = 3'b000;
    localparam READ = 3'b001;
    localparam WRITE = 3'b010;
    localparam WAIT = 3'b011;
    localparam ERROR = 3'b100;
    
    // Wire declarations
    wire [WIDTH-1:0] internal_data;
    wire overflow_flag;
    wire underflow_flag;
    
    // Reg declarations
    reg [2:0] state, next_state;
    reg [WIDTH-1:0] accumulator;
    reg [7:0] counter;
    reg [15:0] memory [0:DEPTH-1];
    
    // Integer and real declarations
    integer i, j;
    real temperature;
    
    // Tri-state buffer control
    reg bus_enable;
    assign data_bus = bus_enable ? data_out[15:0] : 16'bz;
    
    // Continuous assignments
    assign valid_out = (state == READ || state == WRITE) && !error;
    assign overflow_flag = (accumulator > {WIDTH{1'b1}});
    assign internal_data = data_in & {WIDTH{enable}};
    
    // Always block - Sequential logic (Flip-flops)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            data_out <= 32'd0;
            accumulator <= 32'h0000_0000;
            counter <= 8'b0000_0000;
            error <= 1'b0;
            bus_enable <= 1'b0;
        end else begin
            state <= next_state;
            
            // Counter with rollover
            if (counter == 8'd255)
                counter <= 8'd0;
            else if (enable)
                counter <= counter + 1'b1;
            
            // Accumulator logic
            case (state)
                READ: begin
                    data_out <= memory[address];
                    accumulator <= accumulator + data_out;
                end
                
                WRITE: begin
                    if (write_enable)
                        memory[address] <= data_in;
                end
                
                ERROR: begin
                    error <= 1'b1;
                    data_out <= 32'hDEADBEEF;
                end
                
                default: begin
                    data_out <= 32'h0;
                end
            endcase
        end
    end
    
    // Always block - Combinational logic (State machine)
    always @(*) begin
        next_state = state;
        
        case (state)
            IDLE: begin
                if (read_enable)
                    next_state = READ;
                else if (write_enable)
                    next_state = WRITE;
            end
            
            READ: begin
                if (overflow_flag)
                    next_state = ERROR;
                else if (!read_enable)
                    next_state = WAIT;
            end
            
            WRITE: begin
                if (!write_enable)
                    next_state = WAIT;
            end
            
            WAIT: begin
                next_state = IDLE;
            end
            
            ERROR: begin
                if (!rst_n)
                    next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // Always block with sensitivity list
    always @(posedge clk) begin
        if (enable && write_enable) begin
            $display("Time=%0t: Writing data 0x%h to address 0x%h", 
                     $time, data_in, address);
        end
    end
    
    // Initial block for simulation
    initial begin
        // Initialize memory
        for (i = 0; i < DEPTH; i = i + 1) begin
            memory[i] = 16'h0000;
        end
        
        // Display information
        $display("=== Comprehensive Design Module ===");
        $display("WIDTH = %0d", WIDTH);
        $display("DEPTH = %0d", DEPTH);
        $display("CLK_PERIOD = %0d ns", CLK_PERIOD);
        
        // Monitor signals
        $monitor("Time=%0t clk=%b rst_n=%b state=%b data_out=0x%h", 
                 $time, clk, rst_n, state, data_out);
    end
    
    // Generate block for parameterized instances
    genvar k;
    generate
        for (k = 0; k < 4; k = k + 1) begin : gen_registers
            always @(posedge clk) begin
                if (enable && address[7:6] == k[1:0]) begin
                    $display("Register bank %0d accessed", k);
                end
            end
        end
    endgenerate
    
    // Task definition
    task write_memory;
        input [7:0] addr;
        input [15:0] data;
        begin
            memory[addr] = data;
            $display("Task: Written 0x%h to address 0x%h", data, addr);
        end
    endtask
    
    // Function definition
    function [WIDTH-1:0] add_values;
        input [WIDTH-1:0] a;
        input [WIDTH-1:0] b;
        begin
            add_values = a + b;
        end
    endfunction
    
    function automatic integer factorial;
        input integer n;
        begin
            if (n <= 1)
                factorial = 1;
            else
                factorial = n * factorial(n - 1);
        end
    endfunction
    
    // Specify block for timing
    specify
        specparam tPD = 5.0;
        specparam tSU = 2.0;
        specparam tH = 1.0;
        
        (clk => data_out) = (tPD, tPD);
        $setup(data_in, posedge clk, tSU);
        $hold(posedge clk, data_in, tH);
    endspecify

endmodule

// Testbench module
module testbench;
    // Testbench signals
    reg clk;
    reg rst_n;
    reg enable;
    reg [31:0] data_in;
    reg [7:0] address;
    reg write_enable;
    reg read_enable;
    wire [31:0] data_out;
    wire valid_out;
    wire error;
    wire [15:0] data_bus;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Device Under Test
    comprehensive_design #(
        .WIDTH(32),
        .DEPTH(256),
        .CLK_PERIOD(10)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .data_in(data_in),
        .address(address),
        .write_enable(write_enable),
        .read_enable(read_enable),
        .data_out(data_out),
        .valid_out(valid_out),
        .error(error),
        .data_bus(data_bus)
    );
    
    // Test stimulus
    initial begin
        // Initialize signals
        rst_n = 0;
        enable = 0;
        data_in = 32'h0;
        address = 8'h0;
        write_enable = 0;
        read_enable = 0;
        
        // Reset sequence
        #20 rst_n = 1;
        #10 enable = 1;
        
        // Write operations
        @(posedge clk);
        write_enable = 1;
        data_in = 32'hCAFE_BABE;
        address = 8'h10;
        
        @(posedge clk);
        write_enable = 0;
        
        // Read operations
        #20;
        @(posedge clk);
        read_enable = 1;
        address = 8'h10;
        
        @(posedge clk);
        read_enable = 0;
        
        // Finish simulation
        #100;
        $display("=== Simulation Complete ===");
        $finish;
    end
    
    // Waveform dumping
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, testbench);
    end

endmodule
