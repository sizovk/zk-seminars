pragma circom 2.2.3;

template MultiplyThree() {
    signal input a;
    signal input b;
    signal input c;
    signal t;
    signal output d;

    t <== a * b;
    d <== t * c;
}

component main {public [a, c]} = MultiplyThree();