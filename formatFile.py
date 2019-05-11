import sys

# strip space and \t at the begining and end

with open(sys.argv[1], 'r') as f:
	# save file into a list
	text_lines=f.readlines()

output=[]

for i in text_lines:
	# strip the tab and space
	output.append(i.strip())

# generate output file
outfile=".{}".format(sys.argv[1])

with open(".{}".format(sys.argv[1]), 'w') as f:
	f.write('\n'.join(output))
