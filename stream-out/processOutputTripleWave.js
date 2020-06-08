const fs = require('fs');
const WebSocket = require('ws');
const parse = require('csv-parse/lib/sync');
const path = require('path');

// process arguments
const wsPath = process.argv[2];
const outputFile = process.argv[3];
const triplesFile = process.argv[4]
const prefixURL = process.argv[5];

console.log('WS path: ' + wsPath);
console.log('Output file: ' + outputFile);
console.log('Triples file: ' + triplesFile);
console.log('Prefix URL: ' + prefixURL);

fs.writeFile(outputFile, '', function(){console.log('Emptied out file')})
fs.writeFile(triplesFile, '', function(){console.log('Emptied triples file')})
const stream = fs.createWriteStream(outputFile, {flags: 'a'});
const triplesDump = fs.createWriteStream(triplesFile, {flags: 'a'});
const ids = {};

function start() {
  const ws = new WebSocket(wsPath);
  fs.closeSync(fs.openSync('/i-am-alive', 'w'));
  let hasData = false;

  ws.on('error', (err) => {
    start();
  });

  ws.on('message', (data) => {
    console.log(data);
    hasData = true;
    // Dump triples
    triplesDump.write(data + '\n');

    // Format results
    data = JSON.parse(data)['@graph'];
    const id = data['@id'].replace(prefixURL, '');
    stream.write(`${id},${new Date().getTime()}\n`);
  });

  ws.on('close', async () => {
    if(hasData) {
      console.log('Data received, uploading to NextCloud...');
    }
  });
}

start();
