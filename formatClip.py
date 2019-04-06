import pyperclip

# strip space and \t at the begining and end

# save clip board to a list
input = pyperclip.paste().split('\n')

output = []

for i in input:
	# strip space and \t aht the begining and end of each string
	output.append(i.strip())

# transform list to string and copy back to clipboard
pyperclip.copy('\n'.join(output))
