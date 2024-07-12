
// To verify using the terminal:
// snarkjs groth16 verify verification_key.json public.json proof.json

// To execute this script: node timing-verification.js
const snarkjs = require("snarkjs");
const fs = require("fs");

async function verifyProof() {
    // Load verification key, public signals, and proof from the files
    const verificationKey = JSON.parse(fs.readFileSync("verification_key.json", "utf8"));
    const publicSignals = JSON.parse(fs.readFileSync("public.json", "utf8"));
    const proof = JSON.parse(fs.readFileSync("proof.json", "utf8"));

    // Start time
    console.time("Verification Time");

    const isValid = await snarkjs.groth16.verify(verificationKey, publicSignals, proof);

    // End time
    console.timeEnd("Verification Time");

    // Log the result of the verification
    console.log("Verification result:", isValid ? "OK!" : "Invalid proof");
}

verifyProof().catch(error => {
    console.error("Error verifying the proof:", error);
});