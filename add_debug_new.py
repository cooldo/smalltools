#!/usr/bin/env python3
import os,sys
import shutil
import re
#sys.exit(0)

# For QT log
#LOG_STRING ="    qDebug() << Q_FUNC_INFO;\n"
# For weston log
LOG_STRING="    weston_log(\"%s\\n\", __func__);\n"
# For common
#LOG_STRING="    fprintf(stderr,\"%s\\n\", __func___);\n"

tags_file = sys.argv[1]
org_file  = sys.argv[2]

print("ctags   file:", tags_file)
print("orginal file:", org_file)

# get the line_num line of ctag file
# ctags format
# for c++:
#      0                1                     2                  3             4
# <function_name> \t <file_name> \t <content_of_this_line> \t <type:f > \t <class_name>\n
# for c:
#      0                1                     2                  3
# <function_name> \t <file_name> \t <content_of_this_line> \t <type:f >\n
def get_function(tags_file, line_num):
    total_num = 0
    with open(tags_file, 'r') as f:
        for line in f:
            new_string = line.split('\t') 
            if len(new_string) > 3 and new_string[3].strip() == 'f':
                total_num += 1

    if (line_num > total_num):
        return

    curr_num = -1
    with open(tags_file, 'r') as f:
        for line in f:
            new_string = line.split('\t') 
            if len(new_string) > 3 and new_string[3].strip() == 'f':
                curr_num += 1
                if (line_num == curr_num):
                    function_key_word = new_string[2]
                    function_key_word = function_key_word[2:-4] 
                    return function_key_word

new_file = org_file+".new"
line_list = []
with open(org_file, 'r') as f:
    for line in f:
        line_list.append(line)

    new_list = []
    tag_num = 0
    index_max = len(line_list)
    index_cur = 0
    while(index_cur < index_max):
        single_line = line_list[index_cur]
        function_key_word = get_function(tags_file, tag_num)
        if function_key_word != None:
            function_key_word+=('\n')
        if (single_line == function_key_word):
            while True:
                brace_index = single_line.find("{")
                # we haven't found {
                if brace_index == -1:
                    new_list.append(single_line)
                    index_cur = index_cur + 1
                    single_line = line_list[index_cur]
                else:
                    str_list = list(single_line)
                    str_list.insert(brace_index + 1, LOG_STRING)
                    str_list_new = ''.join(str_list)
                    new_list.append(str_list_new)
                    break
            
            tag_num += 1
        else: 
            new_list.append(single_line)
        index_cur = index_cur + 1

    with open(new_file, 'w') as f:
        for item in new_list:
            f.write(item)

    shutil.move(new_file, org_file)

sys.exit(0)
