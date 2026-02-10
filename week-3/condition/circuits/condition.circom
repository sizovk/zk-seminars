pragma circom 2.2.3;

// w = [a, b, cond, out, 1]
// aw * bw - cw = 0

template Select() {
    signal input a;
    signal input b;
    signal input cond;
    signal output out;

    // if (cond) {
    //     out <== a;
    // } else {
    //     out <== b;
    // }

    cond * (cond - 1) === 0;

    out <== (cond) * (a - b) + b;
}

component main = Select();