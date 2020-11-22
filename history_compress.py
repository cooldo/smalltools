#!/usr/bin/env python3
# remove duplicated bash_history
import os
import shutil
history = os.path.expandvars('$HOME') + '/.bash_history'
history_compressed = os.path.expandvars('$HOME') + '/.bash_history_compressed'
# store ~/.bash_history into a list
history_list = []
# store compressed history into a list
history_compressed_list = []
with open(history, 'r') as f:
	for line in f:
		history_list.append(line)
	history_list.reverse()

	for item in history_list:
		if item not in history_compressed_list:
			history_compressed_list.append(item)
	history_compressed_list.reverse()

with open(history_compressed, 'w') as f:
	for item in history_compressed_list:
		f.write(item)

shutil.move(history_compressed, history)
