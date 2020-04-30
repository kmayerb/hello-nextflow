# hello-nextflow

This is a minimalist set of intructions for running the equivalent of 'Hello World' with [nextflow](https://www.nextflow.io/docs/) at Fred Hutch. 

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

Note: you must make two tweaks to the`aws.config` compared to what is in this repository.

1. Change `IAM` to your actual AWS Identity and Access Management code, which will be something like `97478097478`
2. Change for `ROLE` to your compsci assigned roel, which will be soemthing like `fh-pi-Simpson-M-batchtask`
3. You should create a work directory in an S3 bucket you control. In the example below, we used `s3://fh-pi-Simpson-M/scratch/testwork/`.
4. You need to specify where in your bucket the results should be published

if running on the shared cluster or gizmos:

```bash
ml nextflow
```

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

Then, the workflow is invoked by:

```bash
bash runs/run_hello.sh
```

Our hello world spun up and was finished in less than 2 minutes.

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

## Is anything happening.

Some times you might just see this:

```
N E X T F L O W  ~  version 20.01.0
Launching `workflows/hello.nf` [elegant_ride] - revision: 808173e715
executor >  awsbatch (1)
[84/48b400] process > my_first_process [  0%] 0 of 1
```

Is anything happening? There is a quick way to check if your job is just waiting its turn politely:

```bach
ml awscli
aws batch list-jobs --job-queue cpu-spot-20 --job-status RUNNABLE | grep -A 1 -B 1 my_first_process
```


If your job is waiting in the queue you should see this:
```
"jobId": "2fc08c20-6a53-496a-ad2b-0ad1efc335e0",
"jobName": "my_first_process_my_first_process",
"createdAt": 1588285195665,
```

You can find more info on your specific job, by typing the following using hte jobID from above

```bash
aws batch describe-jobs --jobs 2fc08c20-6a53-496a-ad2b-0ad1efc335e0
```

You can also check the status of the queues on the [Dashboard](https://batch-dashboard.fhcrc.org/). Even if a queue is not full, if you chose a spot queue the current spot pricing may not allow the job to be run immediately. If the jobs shows as runnable, go get a cup of coffee and check back on it later.


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


## Understanding hello.nf

There are a couple of additional things we can learn from inspecting even a simple 1-part workflow:

```groovy
params.pub_dir = "results"

my_first_channel = Channel.from("Hello World")

process my_first_process {
	tag 'my_first_process'

	label 'low_mem'

	container 'ubuntu:18.04'

	publishDir params.pub_dir
	
	input:
	val x from my_first_channel

	output:
	path 'message.txt' into result

	script:
	"""
	echo $x 
	echo $x > 'message.txt'
	"""
}
```

* params - `params.x` can allow any number of `--x` to be passed to the nextflow in a run command or in a param.json file. We used it here to allow specification of the publishDir.
* tag - using a tag allows one to provide more context 
* label - using a label allows one to control the amount of resources to allocate to all processes with that label. In nextflow resources can be specified to process or labels.
* container - this specifies the docker image that will serve as as the environment for this process. Each process can have its own container.
* publishDir - the path were outputs from this process will be written. 


# More Detailed Configs

### Example 1: update your config to make use of label

```
process.queue = 'cpu-spot-30'

aws {
    region = 'us-west-2'
    batch {
        cliPath = '/home/ec2-user/miniconda/bin/aws'
        jobRole = 'arn:aws:iam::[IAM]:role/[ROLE]'
        volumes = ['/docker_scratch:/tmp:rw']
    }
}

docker {
    enabled = true
    temp = 'auto'
}

process {
    withLabel: low_mem {
        cpus = 1
        memory = 1GB
    }
    withLabel: med_mem {
        cpus = 2
        memory = 4GB
    }
}
```

Note: all processes with the label 'low_mem' will only request 1 CPU and 1GB memory. 
This can be very useful if you need to specify different computational resources for different sets of processes. 

### Example 2: update your config to make use of retry strategies and escalating resource allocation. 

```
process.queue = 'cpu-spot-30'

aws {
    region = 'us-west-2'
    batch {
        cliPath = '/home/ec2-user/miniconda/bin/aws'
        jobRole = 'arn:aws:iam::[IAM]:role/[ROLE]'
        volumes = ['/docker_scratch:/tmp:rw']
    }
}

docker {
    enabled = true
    temp = 'auto'
}


process {
    withLabel: 'low_mem' {
        errorStrategy = {task.attempt <= 3 ? 'retry' : 'finish'}
        memory = {1.GB * task.attempt}
        maxRetries = 3
        cpus = 2
        time = {1.h * task.attempt}
    }
}
```

Note: in this case we specify that if the process fail, it should try again but with 1 GB more memory for each attempt. If you do this you must set the maxRetries to some reasonable number (e.g., 3).


## Doing the same thing using nexflow DSL2

Rewriting the Hello World using DSL2 is left as an exercise for the curious reader. 

