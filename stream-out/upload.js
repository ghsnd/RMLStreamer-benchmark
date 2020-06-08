const fs = require('fs');
const c = require('nextcloud-node-client');
const path = require('path');

const storageDir = process.argv[2];
const outputFile = process.argv[3];
const triplesFile = process.argv[4];

console.log('Storage dir: ' + storageDir);
console.log('Output file: ' + outputFile);
console.log('Triples file: ' + triplesFile);

(async() => {
    try {
    const client = new c["default"]();

    // Create experiment folder if needed
    const folder = await client.createFolder(storageDir);
    const file1 = await folder.createFile(path.basename(triplesFile), fs.readFileSync(triplesFile));
    const file2 = await folder.createFile(path.basename(outputFile), fs.readFileSync(outputFile));
    console.log('Uploading done!');
  } catch (e) {
    // some error handling
    console.log(e);
  }
})();
