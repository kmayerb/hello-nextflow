# hello-nextflow

## Run Local

```bash
nextflow run workflows/hello.nf -c configs/local.config -process.echo
```

## Run on the Cloud

Note: you must make two tweaks to the aws.config compared to what is in this repository

1. Change `IAM` to your actual AWS Identity and Access Management code, which will be something like `97478097478`
2. Change for `ROLE` to your compsci assigned roel, which will be soemthing like `fh-pi-Simpson-M-batchtask`
3. You should create a work directory in an S3 bucket you control. In the example below, we used `s3://fh-pi-Simpson-M/scratch/testwork/`.
4. You need to specify where in your bucket the results should be published

Note: `--` is used for passing params to the workflow while `-` is used for specifying nextflow settings. 

```bash
nextflow run workflows/hello.nf \
	--pub-dir s3://fh-pi-Simpson-M/scratch/testpub \
	-c configs/aws.config \
	-work-dir s3://fh-pi-Simpson-M/scratch/testwork \
	-process.echo \
```

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