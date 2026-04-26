module mainfsm (
    input  logic       clk,
    input  logic       reset,
    input  logic [6:0] op,
    output logic       Branch,
    output logic       PCUpdate,
    output logic       RegWrite,
    output logic       MemWrite,
    output logic       IRWrite,
    output logic [1:0] ResultSrc,
    output logic [1:0] ALUSrcB,
    output logic [1:0] ALUSrcA,
    output logic       AdrSrc,
    output logic [1:0] ALUOp
);

   
    typedef enum logic [3:0] {
        FETCH, DECODE, MEMADR, MEMREAD, MEMWB, MEMWRITE, EXECUTER, ALUWB, EXECUTEI, JAL, BEQ
    } statetype;

    statetype state, nextstate;

   
    always_ff @(posedge clk or posedge reset) begin
        if (reset) state <= FETCH;
        else       state <= nextstate;
    end


    always_comb begin
        case (state)
            FETCH:    nextstate = DECODE;
            DECODE: begin
                case (op)
                    7'b0000011: nextstate = MEMADR;   // lw
                    7'b0100011: nextstate = MEMADR;   // sw
                    7'b0110011: nextstate = EXECUTER; // R-type
                    7'b0010011: nextstate = EXECUTEI; // I-type ALU
                    7'b1101111: nextstate = JAL;      // jal
                    7'b1100011: nextstate = BEQ;      // beq
                    default:    nextstate = FETCH;    
                endcase
            end
            MEMADR: begin
                case (op)
                    7'b0000011: nextstate = MEMREAD;  // lw
                    7'b0100011: nextstate = MEMWRITE; // sw
                    default:    nextstate = FETCH;
                endcase
            end
            MEMREAD:  nextstate = MEMWB;
            MEMWB:    nextstate = FETCH;
            MEMWRITE: nextstate = FETCH;
            EXECUTER: nextstate = ALUWB;
            EXECUTEI: nextstate = ALUWB;
            ALUWB:    nextstate = FETCH;
            JAL:      nextstate = ALUWB;
            BEQ:      nextstate = FETCH;
            default:  nextstate = FETCH;
        endcase
    end

    always_comb begin

        Branch    = 0;
        PCUpdate  = 0;
        RegWrite  = 0;
        MemWrite  = 0;
        IRWrite   = 0;
        ResultSrc = 2'b00;
        ALUSrcB   = 2'b00;
        ALUSrcA   = 2'b00;
        AdrSrc    = 0;
        ALUOp     = 2'b00;

        case (state)
            FETCH: begin
                AdrSrc    = 0;
                IRWrite   = 1;
                ALUSrcA   = 2'b00;
                ALUSrcB   = 2'b10;
                ALUOp     = 2'b00;
                ResultSrc = 2'b10;
                PCUpdate  = 1;
            end
            DECODE: begin
                ALUSrcA   = 2'b01;
                ALUSrcB   = 2'b01;
                ALUOp     = 2'b00;
            end
            MEMADR: begin
                ALUSrcA   = 2'b10;
                ALUSrcB   = 2'b01;
                ALUOp     = 2'b00;
            end
            MEMREAD: begin
                ResultSrc = 2'b00;
                AdrSrc    = 1;
            end
            MEMWB: begin
                ResultSrc = 2'b01;
                RegWrite  = 1;
            end
            MEMWRITE: begin
                ResultSrc = 2'b00;
                AdrSrc    = 1;
                MemWrite  = 1;
            end
            EXECUTER: begin
                ALUSrcA   = 2'b10;
                ALUSrcB   = 2'b00;
                ALUOp     = 2'b10;
            end
            EXECUTEI: begin
                ALUSrcA   = 2'b10;
                ALUSrcB   = 2'b01;
                ALUOp     = 2'b10;
            end
            ALUWB: begin
                ResultSrc = 2'b00;
                RegWrite  = 1;
            end
            JAL: begin
                ALUSrcA   = 2'b01;
                ALUSrcB   = 2'b10;
                ALUOp     = 2'b00;
                ResultSrc = 2'b00;
                PCUpdate  = 1;
            end
            BEQ: begin
                ALUSrcA   = 2'b10;
                ALUSrcB   = 2'b00;
                ALUOp     = 2'b01;
                ResultSrc = 2'b00;
                Branch    = 1;
            end
        endcase
    end
endmodule
