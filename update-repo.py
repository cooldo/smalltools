#!/usr/bin/env python3

#from selenium import webdriver
#from selenium.webdriver.support.ui import WebDriverWait
#from selenium.webdriver.common.keys import keys
#import pyperclip

#browser = webdriver.Firefox()
#url = 'https://codereview.qt-project.org/c/qt/qtbase/+/273639'
#browser.get(url)
#WebDriverWait(browser, 100).until(lambda browser:browser.find_element_by_id("qt-header"))
#browser.find_element_by_xpath("/html/body/gr-app/main/gr-change-view/div[2]/section[2]/div/gr-file-list-header/div/div[2]/span[3]/gr-button").click()

#user=browser.find_element_by_xpath("/html/body/gr-app/main/gr-change-view/gr-overlay[1]/gr-download-dialog/section[2]/gr-download-commands/div[2]/gr-shell-command[2]/div/gr-copy-clipboard/div/gr-button/paper-button").click()

#browser.send_keys("XXXX")
#browser.find_element_by_name("login").click()

#print(pyperclip.paste())
#browser.close()

# dict content: [ direcotry needed to cherry-pick , how to go out of the current directory, git commit id needed to reset ]
dict = { \
'meta-qt-source/center-console':\
['../../', 'asdfasfdasfd'], \
\
'meta-qt-source/discovery-hud':\
['../../','asdfasdf'],\
\
'meta-qt-source/rse-demo':\
['../../','asdfasdf'],\
\
'meta-qt-source/kria-cluster-2d':\
['../../','asdfasdf'], \
\
'meta-samsung-discovery-baremetal':\
['../','asdfasdfasfd'] \
}

with open('test', 'r') as f:
	for line in f:
		# line should be replaced to real network address and open the address
		newLine = line.split(' ')
		for key in dict:
			# newLine[0] should be replaced to repo name
			if newLine[0] in key:
				# newLine[1] should be replaced to cherry-pick address
				dict[key].append(newLine[1])

with open('update-repo.sh', 'w') as f:
	f.write('#!/bin/bash\n')
	f.write('#DONT MODIFY THIS FILE, IT IS AUTOMATICALLY GENERATED\n')
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
			f.write('cd ')
			f.write(dict[key][0])
			f.write('\n')
