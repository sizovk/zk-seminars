pragma circom 2.2.3;

template Fibonacci(n) {
    signal input in[2];
    signal output out;

    signal fib[n];
    // ban
    for (var i = 0; i < n; i++) {
        if (i < 2) {
            fib[i] <== in[i];
        } else {
            fib[i] <== fib[i-1] + fib[i-2];
        }
    }
    out <== fib[n-1];
}

component main = Fibonacci(10);