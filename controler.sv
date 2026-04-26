module controller (
    input  logic       clk,
    input  logic       reset,
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic       funct7b5,
    input  logic       zero,
    output logic [1:0] immsrc,
    output logic [1:0] alusrca, alusrcb,
    output logic [1:0] resultsrc,
    output logic       adrsrc,
    output logic [2:0] alucontrol,
    output logic       irwrite, pcwrite,
    output logic       regwrite, memwrite
);

    // Alt modüller arasında haberleşmeyi sağlayacak iç kablolar (Şekil 1'deki mavi oklar)
    logic [1:0] aluop;
    logic       branch;
    logic       pcupdate;

    // 1. Ana Durum Makinesi (Şef) Bağlantısı
    mainfsm mainfsm_inst (
        .clk(clk),
        .reset(reset),
        .op(op),
        .Branch(branch),
        .PCUpdate(pcupdate),
        .RegWrite(regwrite),
        .MemWrite(memwrite),
        .IRWrite(irwrite),
        .ResultSrc(resultsrc),
        .ALUSrcB(alusrcb),
        .ALUSrcA(alusrca),
        .AdrSrc(adrsrc),
        .ALUOp(aluop)
    );

    // 2. ALU Çözücü Bağlantısı
    aludec aludec_inst (
        .opb5(op[5]),            // op kodunun 5. biti
        .funct3(funct3),
        .funct7b5(funct7b5),
        .ALUOp(aluop),           // mainfsm'den gelen kablo
        .ALUControl(alucontrol)
    );

    // 3. Komut Çözücü Bağlantısı
    instrdec instrdec_inst (
        .op(op),
        .ImmSrc(immsrc)
    );

    // Şekil 1'deki en üstte bulunan Mantık Kapıları (PCWrite'ı oluşturan kısım)
    assign pcwrite = pcupdate | (branch & zero);

endmodule