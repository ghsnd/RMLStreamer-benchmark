/**
 * author: Pieter Heyvaert (pheyvaer.heyvaert@ugent.be) & Dylan Van Assche (dylan.vanassche@ugent.be)
 * Ghent University - imec - IDLab
 */

//modules
const parse = require('csv-parse/lib/sync');
const fs    = require('fs');

//arguments
const inputFile   = process.argv[2];
const outputFile  = process.argv[3];
const resultFile  = process.argv[4];

//variables
const stream       = fs.createWriteStream(resultFile, {flags: 'a'});
const input        = fs.readFileSync(inputFile, {encoding: 'utf-8'});
const output       = fs.readFileSync(outputFile, {encoding: 'utf-8'});
const inputRecords  = parse(input, {columns: true});
const outputRecords = parse(output, {columns:true});
const arrSum = arr => arr.reduce((a,b) => a + b, 0);
const arrMax = arr => Math.max(...arr);
const arrMin = arr => Math.min(...arr);

// Results header
stream.write('id,in_time,out_time,diff\n');

// Results linking in/out
let diffArray = [];
inputRecords.forEach((ri) => {
    let id = ri['id'];
    outputRecords.forEach((ro) => {
        if(ri['id'] === ro['id']) {
            let diff = ro['time'] - ri['time']
            console.log(`${id}: ${diff} ms`);
            diffArray.push(diff);
            stream.write(`${id},${ri['time']},${ro['time']},${diff}\n`)
        }
    });
});

console.log('------------------------------------------');
console.log(`Average difference: ${arrSum(diffArray) / diffArray.length} ms`)
console.log(`Max difference: ${arrMax(diffArray)} ms`)
console.log(`Min difference: ${arrMin(diffArray)} ms`)
console.log('------------------------------------------');
