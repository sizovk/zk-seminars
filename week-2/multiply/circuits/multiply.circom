pragma circom 2.2.3;

template Multiply() {
    signal input a;
    signal input b;
    signal output c;

    c <== a * b;
}

component main = Multiply();