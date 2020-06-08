use std::env;
use std::fs::File;
use std::io::{BufReader, BufWriter, prelude::*, Write};
use std::str::FromStr;

fn main() {
    let args: Vec<String> = env::args().collect();
    let inpath = &args[1];
    let outpath = &args[2];

    let file_name_index = outpath.rfind('/').expect("Not a posix path given");
    let dir = &outpath[..file_name_index + 1];

    let mut diff_out = String::from(dir);
    diff_out.push_str("latency.csv");

    let mut one_sec_diff_out = String::from(dir);
    one_sec_diff_out.push_str("latency_throughput_one_sec_avg.csv");

    let mut stats_out = String::from(dir);
    stats_out.push_str("stats.csv");

    println!("In:  {}\nout: {}", inpath, outpath);

    let infile = File::open(inpath).expect("no such file");
    let inbuf = BufReader::new(infile);

    let outfile = File::open(outpath).expect("no such file");
    let outbuf = BufReader::new(outfile);

    let one_sec_diff_file = File::create(one_sec_diff_out).expect("Cannot create file");
    let mut one_sec_diff_writer = BufWriter::new(one_sec_diff_file);

    let diff_file = File::create(diff_out).expect("Cannot create file");
    let mut diff_writer = BufWriter::new(diff_file);

    let stat_file = File::create(stats_out).expect("Cannot create file");
    let mut stat_writer = BufWriter::new(stat_file);
    
    let in_iter = inbuf.lines();
    let out_iter = outbuf.lines();

    let zipped = in_iter.zip(out_iter);

    // data for one second.
    let mut second_data: Vec<usize> = Vec::new();
    let mut current_time: usize = 0;
    let mut first_time: usize = 0;
    let mut last_time: usize = 0;

    //let mut counter: u64 = 0;
    let mut total: usize = 0;
    let mut min: usize = 10000000000;
    let mut max: usize = 0;

    let mut diff_vec: Vec<usize> = zipped
    .map(|(time_in, time_out)| {
        //counter +=1;
        let ti = usize::from_str(&time_in.unwrap()).unwrap();
        if first_time == 0 {
            first_time = ti;
        }
        let to = usize::from_str(&time_out.unwrap()).unwrap();
        let diff = to - ti;
        if ti - current_time >= 1000 {
            if !second_data.is_empty() {
                let sum = second_data.iter().fold(0, |acc, x| acc + x);
                let avg = sum / second_data.len();
                // write delay
                one_sec_diff_writer.write(avg.to_string().as_bytes()).unwrap();
                one_sec_diff_writer.write(b"\t").unwrap();
                // write throughput (recs / sec):
                one_sec_diff_writer.write(second_data.len().to_string().as_bytes()).unwrap();
                one_sec_diff_writer.write(b"\n").unwrap();
                second_data.clear();
            }
            current_time = ti
        }
        last_time = to;
        second_data.push(diff);
        diff
    })
    .inspect(|diff| {
        // calculate min and max, and print diff
        if diff < &min {
            min = *diff;
        }
        if diff > &max {
            max = *diff;
        }
        total += *diff;
        diff_writer.write(diff.to_string().as_bytes()).unwrap();
        diff_writer.write(b"\n").unwrap();
    })
    .collect();

    if !second_data.is_empty() {
        let sum = second_data.iter().fold(0, |acc, x| acc + x);
        let avg = sum / second_data.len();
        one_sec_diff_writer.write(avg.to_string().as_bytes()).unwrap();
        one_sec_diff_writer.write(b"\t").unwrap();
        one_sec_diff_writer.write(second_data.len().to_string().as_bytes()).unwrap();
        one_sec_diff_writer.write(b"\n").unwrap();
        second_data.clear();
    }

    let nr_elements = diff_vec.len();

    // calculate median delay
    diff_vec.sort_unstable();
    let median = diff_vec[nr_elements / 2];
    let average_delay = total / nr_elements;

    // calculate avg throughput
    let throughput = nr_elements * 1000 / (last_time - first_time);

    println!("=== Stats ===\n");

    println!("* General");
    println!(" Nr:         {}", nr_elements);
    println!(" Throughput: {}", throughput);

    println!("\n* Delay");
    println!(" Sum:        {}", total);
    println!(" Average:    {}", average_delay);
    println!(" Median:     {}", median);
    println!(" Min:        {}", min);
    println!(" Max:        {}", max);

    stat_writer.write(b"nr_records,avg_throughput,avg_delay,med_delay,min_delay,max_delay\n").unwrap();
    stat_writer.write(nr_elements.to_string().as_bytes()).unwrap();
    stat_writer.write(b",").unwrap();
    stat_writer.write(throughput.to_string().as_bytes()).unwrap();
    stat_writer.write(b",").unwrap();
    stat_writer.write(average_delay.to_string().as_bytes()).unwrap();
    stat_writer.write(b",").unwrap();
    stat_writer.write(median.to_string().as_bytes()).unwrap();
    stat_writer.write(b",").unwrap();
    stat_writer.write(min.to_string().as_bytes()).unwrap();
    stat_writer.write(b",").unwrap();
    stat_writer.write(max.to_string().as_bytes()).unwrap();
    stat_writer.write(b"\n").unwrap();

}
