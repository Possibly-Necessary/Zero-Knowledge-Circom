pragma circom 2.0.0;

// Relative path of where circom library is located
include "/home/arthur-merlin/node_modules/circomlib/circuits/poseidon.circom";
include "/home/arthur-merlin/node_modules/circomlib/circuits/bitify.circom";

// Circuit template to perform the square and multiply for g**k mod p --- (square & multiply method might need revision)
template SquareMult(N){ // Template accepts N bit binray length

    signal input base;   // generator g
    signal input power;  // Secret exponent k

    signal output out;   // g**k mod p

    component powerBits = Num2Bits(N);  // Call the Num2Bits Circuit
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

// Identity Circuit/template computes the user's identity I = g^(sku) mod p, where sku is the secret key of the user

template Identity(){

signal input sku;
signal input g;
signal output I

// Call the squareMult circuit to compute g^sku mod p
component squareMult = SquareMult(255)
squareMult.base <== g;
squareMult.power <== sku;

I <== squareMult.out;

}

// The template/Circuit Commit computes the user's commitment C = g^(r)Y^(sku) mod p

template Commit(){

signal input r;
signal input sku;
signal input Y;
signal input g;
signal output C;
signal gr;
signal Ysku;

// Call the squareMult circuit
componrt squareMult = SquareMult(255) // Using 255 field bits

// Compute g^r mod p
squareMult.base <== g;
squareMult.power <== r;

gr <== squareMult.out;

// Compute Y^sku
squareMult.base <== Y;
squareMult.power <== sku;

Ysku <== squareMult.out;

C <== gr * Ysku; // (gr * Ysku) mode p

}


// This cricuit generates the proof that both the Identity and Commitment (I & C) are created by the user who knows secret key sku

template Proof(){

// Private inputs
signal input r;
signal input sku;

// Public Iputs
signal input g;
signal input Y;
signal input Cpublic;
signal input Ipublic;

// Intermediate values;
signal I;
signal C;
signal validC;
signal validI;

// For the final proof
signal output P;

// Call the identity Circuit
component Ident = Identity();
// Compute I = g^sku
Ident.g <== g;
Ident.sku <== sku;
I <== Ident.I;

// Call the Commitment circuit
component Com = Commit();
// Compute C = g^r * Y^sku

Com.r <== r;
Com.sku <== sku;
Com.g <== g; 
Com.Y <== Y;

C <== Com.C;

// Verify equality of C and I against the publicly known ones
validC <== (C === Cpublic); // If both of these are ture, then validC and validI will have '1' "stored" in them
validI <== (I === Ipublic); 

P <== validC * validI; // Both must be valid for P to be valid

// Possible alternative approach
// P <== (C === Cpublic) && (I === Ipublic);

}

component main {public [g, Y, Ipublic, Cpublic]} = Proof();