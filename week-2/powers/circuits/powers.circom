pragma circom 2.2.3;

template Powers(n) {
    // n = 6
    // input a
    // output a, a^2, a^3, ..., a^n
    signal input a;
    signal output powers[n];

    powers[0] <== a;
    for (var i = 1; i < n; i++) {
        powers[i] <== powers[i - 1] * a;
    }
}

component main = Powers(6);