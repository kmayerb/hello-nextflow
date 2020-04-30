# hello-nextflow

This is minimalist set of intructions for running the equivalent of 'Hello World' with [nextflow](https://www.nextflow.io/docs/) at Fred Hutch. 

## Install nextflow on a linux or OSX system.

Nextflow can be used on any POSIX compatible system (Linux, OS X, etc). It requires Bash 3.2 (or later) and [Java 8 (or later, up to 11)](http://www.oracle.com/technetwork/java/javase/downloads/index.html) to be installed.

Install nextflow with the following bash command:

```
wget -qO- https://get.nextflow.io | bash
```

## Run the hello.nf workflow locally

```bash
nextflow run workflows/hello.nf -c configs/local.config -process.echo
```

##  Run the hello.nf workflow using AWS batch

Note: you must make two tweaks to the aws.config compared to what is in this repository

1. Change `IAM` to your actual AWS Identity and Access Management code, which will be something like `97478097478`
2. Change for `ROLE` to your compsci assigned roel, which will be soemthing like `fh-pi-Simpson-M-batchtask`
3. You should create a work directory in an S3 bucket you control. In the example below, we used `s3://fh-pi-Simpson-M/scratch/testwork/`.
4. You need to specify where in your bucket the results should be published

```bash
nextflow run workflows/hello.nf \
	--pub-dir s3://fh-pi-Simpson-M/scratch/testpub \
	-c configs/aws.config \
	-work-dir s3://fh-pi-Simpson-M/scratch/testwork \
	-process.echo 
```

Note: `--` is used for passing params to the workflow while `-` is used for specifying nextflow settings. 

* `--pub_dir` argument is specific to this workflow and controls where the outputs of the process will be saved
* `-c` specificies the path to the config you wish to use
* `-work-dir` specifies were the cached intermediate steps in your workflow will be saved
* `-process.echo` optionally prints the stdout as nextflow executes. This is primarily a debugging tool.


Instead of using the commandline it is good practice to save your runs as a bash script. See `runs/run_hello.sh`.


Hello world spun up and was finished in less than 2 minutes.

```
N E X T F L O W  ~  version 19.10.0
Launching `workflows/hello.nf` [marvelous_plateau] - revision: 808173e715
Monitor the execution with Nextflow Tower using this url https://tower.nf/watch/LQEEGEQw
executor >  awsbatch (1)
[bd/0abe2e] process > my_first_process (my_first_process) [100%] 1 of 1 ✔
Hello World

Completed at: 30-Apr-2020 12:48:14
Duration    : 1m 5s
CPU hours   : (a few seconds)
Succeeded   : 1
```

## Getting Setup to Run on the Cloud

Contact scicomp to get your user specific credentials.

Note in your home directory you must have:

`~/.aws/credentials`

```
[default]
aws_access_key_id = 
aws_secret_access_key = 
```

`~/.aws/config`

```
region = us-west-2
s3 =
        max_concurrent_requests = 100
        max_queue_size = 10000
        multipart_threshold = 64MB
        multipart_chunksize = 16MB
```


## Getting Tower

You need to get a free [tower.nf](https://tower.nf) account to monitor you job in real time from anywhere. This is a must-have feature, but it take a couple of days to get authenticated. Once you have a tower token you can add the following to your config. Replace `YOUR TOKEN` with your actual token.


```
tower {
  accessToken = 'YOUR TOKEN'
  enabled = true
}
```