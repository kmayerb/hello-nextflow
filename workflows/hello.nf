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

