
// Testing whether a circuit can have multiple outputs
// A ZK circuit that proves knowledge of 'k' s.t h = PoseidonHash(k) and c = (k*k)^2 without revealing it.

pragma circom 2.0.0;

// Relative path of where circom library is included
include "/home/arthur-merlin/node_modules/circomlib/circuits/poseidon.circom";

template HashAndCommit(){

    signal input k;
    signal temp; // For the intermmediate result of k*k
    signal output h;   // Both h and c are publicy known
    signal output c; 

    
    // Hashing k using Poseidon
    component poseidon = Poseidon(1);
    poseidon.inputs[0] <== k; 
    h <== poseidon.out; 


    // Let's say we want to prove knowledge of k in c where c = (k * k)^2
    temp <== k*k;
    c <== temp * temp;
}

component main = HashAndCommit(); // Call the circuit 