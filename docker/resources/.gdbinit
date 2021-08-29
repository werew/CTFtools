set disassembly-flavor intel
set history save on
set print max-symbolic-offset 4
set follow-fork-mode child
source /usr/share/gef/gef.py
gef config context.layout "-legend regs stack code args source -threads -trace extra memory"
