# hello-nextflow

## Run Local

```bash
nextflow run workflows/hello.nf -c configs/local.config -process.echo -resume
```

## Run on the Cloud

Note: you must make two tweaks to the aws.config compared to what is in this repository

1. IAM  will be something like `97478097478`
2. ROLE will be soemthing like `fh-pi-Simpson-M-batchtask`

```bash
nextflow run workflows/hello.nf -c configs/aws.config -process.echo -resume
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




