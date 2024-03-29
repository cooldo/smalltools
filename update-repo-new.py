#!/usr/bin/python3
import simplejson
import re
import os

ID="qiang1.gao"
IP="12.36.165.35:29414"
# get patch address from this command
# ssh -p 29418 gao@gerrit.wikimedia.org  gerrit query --format=JSON  --format=JSON status:open project:mediawiki/extensions/Cite --current-patch-set
input = r'input.txt'
repofile = r'repo.txt'

abs_path = os.path.split(os.path.realpath(__file__))[0]

fetch_path = 'git fetch "ssh://{0}@{1}/{2}" {3} && git cherry-pick FETCH_HEAD'

# run ./test.sh and generate repo.txt in current directory
return_value = os.system(abs_path+'/test.sh')
if (return_value != 0):
  print("get remote repo failed")
  exit(0)

# dict content:
# {
# key(string): repo name
# value(list): a list of commands needed to execute one by one
# }

dict = { \
'meta-qt-source/center-console':
['../../', 'asdfasfdasfd'],

'meta-qt-source/discovery-hud':
['../../','asdfasdf'],

'meta-qt-source/discovery-rse':
['../../','asdfasdf'],

'meta-qt-source/kria-cluster-2d':
['../../','asdfasdf'],

'discovery-qtappman':
['../','asdfasdf'],

'meta-samsung-discovery-baremetal':
['../','asdfasdfasfd']
}

with open(abs_path+'/'+input, 'r') as f:
  for line in f:
    url = line
    # input: http://12.36.165.35:8084/#/c/40310/
    # output: 40310
    pattern = url.strip().strip('/').split('/')[-1]
    if not pattern:
      continue
    with open(abs_path+'/'+repofile, 'r') as repo:
      for repoline in repo:
        if (re.search(pattern, repoline) != None):
          # found repo
          json = simplejson.loads(repoline)
          # get project name
          project_name = json["project"]
          #print(project_name)
          # get cherry pick addr
          cherry_pick_addr = json["currentPatchSet"]["ref"]
          for key in dict:
            # if project_name is Automotive/meta-samsung-discovery-baremetal
            # get the last item: meta-samsung-discovery-baremetal
            if project_name.split('/')[-1] in key:
              dict[key].append(fetch_path.format(ID,IP, project_name, cherry_pick_addr))


with open(abs_path + '/'+'update-repo.sh', 'w') as f:
  f.write('#!/bin/bash\n')
  f.write('#THIS FILE IS AUTOMATICALLY GENERATED by qiang1.gao, DON\'T MODIFY IT UNLESS YOU HAVE ENOUGH CONFIDENCE\n')
  f.write('set -e\n')

  for key in dict:
    LEN = len(dict[key])
    if LEN > 2:
      # 1.change to the specific directory
      f.write('cd ')
      f.write(key)
      f.write('\n')
      # 2.git reset --hard to the orignal commit
      f.write('git reset --hard ')
      f.write(dict[key][1])
      f.write('\n')
      # 3.git cherry-pick each of new commit
      for i in range(2,LEN):
        f.write(dict[key][i])
        f.write('\n')
      f.write('cd ')
      f.write(dict[key][0])
      f.write('\n')
