#!/usr/bin/env python3
# folder.py - list all folders/subfloders/files
# Usage: folder.py <folder dir>

import os,sys
if len(sys.argv) is not 2 or os.path.isdir(sys.argv[1]) is not True:
    print('Usage: folder.py <folder dir>')
    sys.exit()

#sys.exit()
for folderName, subfolders, filenames in os.walk('.'):
    print('The current folder is ' + folderName)

    for subfolder in subfolders:
        print('SUBFOLDER OF ' + folderName + ': ' + subfolder)

    print('FILE INSIDE :'+ folderName + ': ')
    for filename in filenames:
        print(filename, end=' ')

    print('')
