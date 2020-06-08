FROM node

ADD package.json .
ADD processOutputTripleWave.js /processOutputTripleWave.js
ADD processOutputRMLStreamer.js /processOutputRMLStreamer.js
ADD upload.js /upload.js
ADD am-i-alive.js /am-i-alive.js
ADD run.sh /run.sh

RUN npm i
RUN npm i n3
