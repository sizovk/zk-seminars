pragma circom 2.2.3;

template Sum() {
    signal input a;
    signal input b;
    signal output c;

    c <== a + b;
}

component main = Sum();