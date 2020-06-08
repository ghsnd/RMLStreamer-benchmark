const fs = require('fs');
const c = require('nextcloud-node-client');
const client = new c['default']();
const path = require('path');

const storageDir = process.argv[2];
const outputFile = process.argv[3];

console.log('Storage dir: ' + storageDir);
console.log('Output file: ' + outputFile);

(async() => {
    // Create experiment folder if needed
    console.log('Uploading started...');
    const folder = await client.createFolder(storageDir);
    const file1 = await folder.createFile(path.basename(outputFile), fs.readFileSync(outputFile));
    console.log('Uploading done!');
})();