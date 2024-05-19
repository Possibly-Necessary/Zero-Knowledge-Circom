pragma circom 2.0.0;
 // Defining the logical operations 
template OR2() {
    signal input a;
    signal input b;
    signal output out;

    signal temp;
    temp <== a * b;
    out <== a + b - temp;
}

template AND2() {
    signal input a;
    signal input b;
    signal output out;

    out <== a * b;
}

template NOT() {
    signal input a;
    signal output out;

    out <== 1 - a;
}


// Using the operations above, construct the clauses 

// Clause 1 after simplification: C1 = 1 - b + ab + cb - abc
template Clause1() {
    signal input a;
    signal input b;
    signal input c;
    signal output out;

    signal ab;
    signal cb;
    signal abc;

    ab <== a * b;
    cb <== c * b;
    abc <== ab * c;

    out <== 1 - b + ab + cb - abc;
}

// Clause 2 after simplification: C2 = 1 -ad + abd
template Clause2() {
    signal input a;
    signal input b;
    signal input d;
    signal output out;

    signal ad;
    signal bda;

    ad <== a * d;
    bda <== b * ad;

    out <== 1 - ad + bda;
}

// Clause 3 after simplification: C3 = b + z - bz
template Clause3() {
    signal input b;
    signal input z;
    signal output out;

    signal bz;

    bz <== b * z;

    out <== b + z - bz;
}

// Combine the previous clauses together 

template CNF() {
    signal input a;
    signal input b;
    signal input c;
    signal input d;
    signal input z;
    signal output out;

    // Instantiate clause templates
    component clause1 = Clause1();
    component clause2 = Clause2();
    component clause3 = Clause3();

    // Set inputs for clauses
    clause1.a <== a;
    clause1.b <== b;
    clause1.c <== c;

    clause2.a <== a;
    clause2.b <== b;
    clause2.d <== d;

    clause3.b <== b;
    clause3.z <== z;

    // Combine clauses with AND operations
    signal clause12;
    component and1 = AND2();
    and1.a <== clause1.out;
    and1.b <== clause2.out;
    clause12 <== and1.out;

    component and2 = AND2();
    and2.a <== clause12;
    and2.b <== clause3.out;

    out <== and2.out;
}

// Call the final circuit
component main = CNF();

