pragma circom 2.2.3;

// a, b - inputs
// out = in[0]^2 + in[1]^2 - public output

// (aw) * (bw) = cw

template Square() {
    signal input in;
    signal output out;

    out <== in * in;
}

template SumOfSquares() {
    signal input in[2];
    signal output out;

    component sq1 = Square();
    component sq2 = Square();
    
    sq1.in <== in[0];
    sq2.in <== in[1];

    out <== sq1.out + sq2.out;

}

component main = SumOfSquares();