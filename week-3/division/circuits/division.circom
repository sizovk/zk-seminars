pragma circom 2.2.3;

template Division() {
    signal input in[2];
    signal output out;

    // out = in[0] / in[1];
    out <-- in[0] / in[1];
    in[0] === out * in[1];

}

component main = Division();