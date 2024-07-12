
// The command to generate the proof without this script:
// snarkjs groth16 prove zk-proof_0001.zkey witness.wtns proof.json public.json

// Must initialize node init -y, then install snarkjs in the project's directory 
// To execute this script: node timing-proof-gen.js

const snarkjs = require("snarkjs");
const fs = require("fs");

async function generateProof() {
    // Load data from files
    const zkeyFileName = "zk-proof_0001.zkey";
    const wtnsFileName = "witness.wtns";
    const proofFileName = "proof.json";
    const publicFileName = "public.json";

    const zkeyData = fs.readFileSync(zkeyFileName);
    const wtnsData = fs.readFileSync(wtnsFileName);

    // Start time
    console.time("Proof Generation");

    // Generate the proof
    const { proof, publicSignals } = await snarkjs.groth16.prove(zkeyData, wtnsData);

    // End time
    console.timeEnd("Proof Generation");

    // Save the proof and the public signals to files
    fs.writeFileSync(proofFileName, JSON.stringify(proof, null, 2));
    fs.writeFileSync(publicFileName, JSON.stringify(publicSignals, null, 2));

    console.log("Proof and public signals have been written to files.");
}

generateProof().catch(error => {
    console.error("Error generating the proof:", error);
});
