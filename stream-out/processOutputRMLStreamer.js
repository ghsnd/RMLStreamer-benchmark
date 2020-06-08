const fs = require('fs');
const net = require('net');
const path = require('path');

// process arguments
const tcpPort = process.argv[2];
const outputFile = process.argv[3];
const triplesFile = process.argv[4]

console.log('TCP port: ' + tcpPort);
console.log('Output file: ' + outputFile);
console.log('Triples file: ' + triplesFile);

fs.writeFile(outputFile, '', function(){console.log('Emptied out file')})
fs.writeFile(triplesFile, '', function(){console.log('Emptied triples file')})
const stream = fs.createWriteStream(outputFile, {flags: 'a'});
const triplesDump = fs.createWriteStream(triplesFile, {flags: 'a'});

function start() {
  fs.closeSync(fs.openSync('/i-am-alive', 'w'));

  const server = net.createServer(async (socket) => {
    let currentId = '';
    let remainingData = ''; // if chunck doesn't end with newline, buffere everything after the last newline here.
    socket.on('data', function(data) {
      const ts = new Date();
      data = remainingData + data.toString();

      // handle chunked data
      let newlineIndex = data.lastIndexOf('\n');
      if (newlineIndex == -1) {
        remainingData = data;
        return;
      } else if (newlineIndex == data.length - 1) {
        remainingData = '';
      } else {
        remainingData = data.substring(newlineIndex + 1);
        data = data.substring(0, newlineIndex);
      }
      
      //console.log(ts + ' Received data:' + data);    
      // Dump triples
      triplesDump.write(data + '\n');

      const lines = data.split('\n');
      lines.forEach(function handle(value, index, array) {
         const line = value.trim();
         if (line != '') {
           // we assume the subject is formatted as "<some_url>"
           const subject = line.substring(1, line.indexOf('>'));
           const id = subject.substring(subject.lastIndexOf('/') + 1);
           if(currentId != id) { // Avoid duplicates when subject is multiple times in data
             currentId = id;
             stream.write(`${id},${ts.getTime()}\n`);
             //console.log('Written: ' + id);
           }
         }
      });
    }); 

    socket.on('close', async function() {
      console.log('Socket closed! Shutting down server.');
      server.close();
    });
  });

  server.listen(tcpPort);
  console.log('Stream-out is listening on port: ' + tcpPort);
}

start();
