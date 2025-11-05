#!/usr/bin/env python

import json
import subprocess
data = {}
output = subprocess.check_output("khal list now 7days --format \"{start-end-time-style} {title}\"", shell=True).decode("utf-8")
lines = output.split("\n")
new_lines = []
for line in lines:
    if len(line) and line[0].isalpha():
        line = '\n<span foreground="#bb9af7"><b>' + line + '</b></span>' 
    elif len(line) and line[0] == ' ':
        line = '<span foreground="#f8b369"><b>' + line + '</b></span>'
    else:
        # line = '<i>' + line +'</i>'
        line = '<small>' + line +'</small>'
    new_lines.append(line)
output = "\n".join(new_lines).strip()
if "Today" in output:
    # data['text'] = "󰃰 " + output.split('\n')[1]
    data['text'] = "<span foreground='#bb9af7'>󰃰</span> "
else:
    data['text'] = " "
data['tooltip'] = output
print(json.dumps(data))
