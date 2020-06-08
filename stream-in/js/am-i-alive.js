const http = require('http')
const fs = require('fs');
const port = 3000
const aliveFile = './i-am-alive'

const requestHandler = (request, response) => {
  fs.access(aliveFile, fs.F_OK, (err) => {
  if (err) {
    response.statusMessage = 'Booting up!';
    response.statusCode = 404;
    console.log('Service is booting up...');
    response.end('BOOTING\n');
    return;
  }
      response.statusMessage = 'Alive!';
      response.statusCode = 200;
      console.log('Service is ALIVE!');
      response.end('ALIVE\n');
  })
}

const server = http.createServer(requestHandler)

server.listen(port, (err) => {
  if (err) {
    return console.log('something bad happened', err)
  }

  console.log(`server is listening on ${port}`)
})
