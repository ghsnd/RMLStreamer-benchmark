# Benchmarking the RMLStreamer: tweets

This benchmark feeds the RMLStreamer with a sample of Twitter's
[sampled stream](https://developer.twitter.com/en/docs/labs/sampled-stream/overview)
of messages. The goal is to test how well the RMLStreamer scales while applying some mappings.

Open `run_rmlstreamer_benchmark.sh` and change the variable config according to the tests.

## Configurations

|Nr |Name of test         | PARALLELISM | TASK_MANAGER_NUMBER_OF_TASK_SLOTS | NUMBER_OF_TASK_MANAGERS | Comments |
|---|---------------------|-------------|-----------------------------------|-------------------------|----------|
|1  |p1_s1_t1_d${DELAY}   | 1           | 1                                 | 1                       | Single node runs|
|2  |p2_s2_t1_d${DELAY}   | 2           | 2                                 | 1                       ||
|3  |p4_s4_t1_d${DELAY}   | 4           | 4                                 | 1                       ||
|4  |p8_s8_t1_d${DELAY}   | 8           | 8                                 | 1                       ||
|5  |p16_s16_t1_d${DELAY} | 16          | 16                                | 1                       | Only if cores / machine available|
|6  |p4_s2_t2_d${DELAY}   | 4           | 2                                 | 2                       | multiple node runs|
|7  |p8_s2_t4_d${DELAY}   | 8           | 2                                 | 4                       ||
|8  |p16_s2_t8_d${DELAY}  | 16          | 2                                 | 8                       ||

For every configuration, test with the following values for `DELAY`:
* `1000000000`: 1 message / s
* `100000000`: ~10 messages / s
* `10000000`: ~100 / s
* `1000000`: ~1000 / s
* `100000`: ~10000 / s
* `0`  : as fast as possible
