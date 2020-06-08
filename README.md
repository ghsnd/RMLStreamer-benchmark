An evaluation set-up for [RMLStreamer](https://github.com/RMLio/RMLStreamer).

## Requirements
- Docker
- Docker Compose
- Patience

## Building

The current setup includes demo data, adjust it to your needs.

### RML Streamer, local set-up

Building and running happens with the `run_rmlstreamer_benchmark.sh` script, which invokes `docker-compose`.
This will use the common components such as `stream-in` and the tool specific components to create a complete benchmark for the RML Streamer.

:bulb: Open `run_rmlstreamer_benchmark.sh`. Change the variables depending on the configuration you want to run.

See <RMLSTREAMER_TWITTER_BENCHMARK.md> for more details.

## Measurements processing

After the benchmark, the latency is calculated for each record if you run the `parseTimes.js` script from the `post-processing-scripts` directory.

`node parseTimes.js in.csv out.csv results.csv `
