nextflow run workflows/hello.nf \
	--pub-dir s3://fh-pi-Simpson-M/scratch/testpub \
	-c configs/aws.config \
	-work-dir s3://fh-pi-Simpson-M/scratch/testwork \
	-process.echo \