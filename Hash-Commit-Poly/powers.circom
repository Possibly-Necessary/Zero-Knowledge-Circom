
pragma circom 2.0.0;

// Relative path of where circom library is located
include "/home/arthur-merlin/node_modules/circomlib/circuits/poseidon.circom";
include "/home/arthur-merlin/node_modules/circomlib/circuits/bitify.circom";

// Circuit template to perform the square and multiply for g**k mod p
template SquareMult(N){ // Template accepts N bit binray length

    signal input base;   // generator g
    signal input power;  // Secret exponent k

    signal output out;   // g**k mod p

    component powerBits = Num2Bits(N);
    powerBits.in <== power;

    signal powers[N];

    powers[0] <== base;
    for (var i = 1; i < N; i++) {
        powers[i] <== powers[i - 1] * powers[i - 1];
    }

    signal arr[N];
    arr[0] <== powers[0] * powerBits.out[0];
    for (var i = 1; i < N; i++) {
        arr[i] <== arr[i - 1] + powers[i] * powerBits.out[i];
    }

    out <== arr[N - 1];
}

// Template circuit for the ZK statement: the prover has knowledge of k s.t h = Hash(k), c = g^k mod p, and p = 5k^3 + 2k^2 + k + 3

template HashCommitPoly(){

    signal input k;  // Secret
    signal input g;  // Public

    // Temporary variables to construct the polynomial equations
    signal temp1;
    signal temp2;

    signal output c;   
    signal output h;   
    signal output p; 

    // Hash the secret input k using poseidon
    component poseidon = Poseidon(1);
    poseidon.inputs[0] <== k; 
    h <== poseidon.out;

    // Square and multiply for g^k
    component squareMult = SquareMult(14); // 14 is the bit length of k
    squareMult.base <== g;
    squareMult.power <== k;
    c <== squareMult.out;

    // Compute the polynomial
    temp1 <== k*k;
    temp2 <== temp1 * k;
    p <== 5*temp2+2*temp2+k+3;

}

// Call the ZK circuit and declaring the input g as public -- by default, all input signals are private
component main {public [g]} = HashCommitPoly(); 