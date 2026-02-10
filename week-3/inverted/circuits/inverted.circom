pragma circom 2.2.3;

// a
// a^(-1) mod p

function inverse(x) {
    return 1 / x;
}

template Inverted() {
    signal input in;
    signal output out;

    out <-- inverse(in);
    1 === out * in;
}

component main = Inverted();