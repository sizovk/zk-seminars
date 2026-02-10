pragma circom 2.2.3;

template IsZero() {
    signal input in;
    signal output out;
    signal k;

    // if (in == 0) {
    //     out <== 1;
    // } else {
    //     out <== 0;
    // }

    k <-- in != 0 ? -1 / in : 0;
    out <-- in == 0 ? 1 : 0;

    out === k * in + 1;
    out * in === 0;

    // in = 0 => out = 1
    // in != 0 => out = 0
}

component main = IsZero();