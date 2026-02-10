const fs = require("fs");

function json2wtns(jsonPath, wtnsPath) {
    const witness = JSON.parse(fs.readFileSync(jsonPath));
    const n8 = 32;
    const prime = 21888242871839275222246405745257275088548364400416034343698204186575808495617n;
    const nWitness = witness.length;
    
    // Calculate correct buffer size:
    // Magic(4) + Version(4) + nSections(4) + 
    // Section1: sectionId(4) + sectionLen(8) + n8(4) + prime(32) + nWitness(4) +
    // Section2: sectionId(4) + sectionLen(8) + witness data(nWitness * 32)
    const buffLen = 4 + 4 + 4 + 4 + 8 + 4 + 32 + 4 + 4 + 8 + nWitness * 32;
    const buff = Buffer.alloc(buffLen);
    
    let pos = 0;
    
    // Magic "wtns"
    buff.write("wtns", pos); pos += 4;
    
    // Version = 2
    buff.writeUInt32LE(2, pos); pos += 4;
    
    // Number of sections = 2
    buff.writeUInt32LE(2, pos); pos += 4;
    
    // Section 1: Header
    buff.writeUInt32LE(1, pos); pos += 4;  // sectionId
    buff.writeBigUInt64LE(BigInt(4 + 32 + 4), pos); pos += 8;  // sectionLen = 40
    
    buff.writeUInt32LE(n8, pos); pos += 4;  // n8
    
    // Prime (little-endian)
    let p = prime;
    for (let i = 0; i < n8; i++) {
        buff[pos++] = Number(p & 0xFFn);
        p >>= 8n;
    }
    
    buff.writeUInt32LE(nWitness, pos); pos += 4;  // nWitness
    
    // Section 2: Witness data
    buff.writeUInt32LE(2, pos); pos += 4;  // sectionId
    buff.writeBigUInt64LE(BigInt(nWitness * 32), pos); pos += 8;  // sectionLen
    
    // Witness values (little-endian)
    for (const val of witness) {
        let v = BigInt(val);
        for (let i = 0; i < n8; i++) {
            buff[pos++] = Number(v & 0xFFn);
            v >>= 8n;
        }
    }
    
    fs.writeFileSync(wtnsPath, buff);
    console.log(`Converted ${jsonPath} → ${wtnsPath} (${buffLen} bytes, ${nWitness} witnesses)`);
}

const [,, jsonFile, wtnsFile] = process.argv;
if (!jsonFile || !wtnsFile) {
    console.log("Usage: node json2wtns.cjs <input.json> <output.wtns>");
    process.exit(1);
}
json2wtns(jsonFile, wtnsFile);
