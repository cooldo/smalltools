#!/usr/bin/env python3
import os,sys
import shutil
import re
#sys.exit(0)

# For QT log
LOG_STRING="    qDebug() << Q_FUNC_INFO;\n"
# For weston log
#LOG_STRING="    weston_log(\"%s\\n\", __func__);\n"
# For common
#LOG_STRING="    fprintf(stderr,\"%s\\n\", __func___);\n"


# This function cannot be used becuase of the following
# function name cannot be recognized
# void function(int32_t x, int32_t y
#      int32_t x, int32_t y)
# {
# }
# Check () or ( * )
parenthese_pattern=(r'\(.*\)')
def check_the_start_of_function(line):
	if (re.search(parenthese_pattern, line)):
		return True
	else:
		return False
	return False

for index in range(len(sys.argv)):
	if index is 0:
		# skip the script itself
		continue
	if not os.path.isfile(sys.argv[index]):
		continue

	org_file = sys.argv[index]
	new_file = '.'+org_file
	line_list = []
	with open(org_file, 'r') as f:
		for line in f:
			line_list.append(line)

	new_list = []
	for index in range(len(line_list)):
		single_line = line_list[index]
		new_list.append(single_line)
		if single_line.rstrip() is '{':
			#if check_the_start_of_function(line_list[index-1]):
			new_list.append(LOG_STRING)


	with open(new_file, 'w') as f:
		for item in new_list:
			f.write(item)

	shutil.move(new_file, org_file)
