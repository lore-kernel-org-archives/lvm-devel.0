From: Lars Sjöström <lars.sjostrom@redhat.com>
Date: Thu, 20 Jan 2011 13:49:29 +0100
Subject: liblvm Python/C extension (Python Liblvm)
Message-ID: <1295527769.24069.31.camel@ljonsson.local>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello,

I was missing a proper LVM2 interface to Python so I decided to write
one my self! I have wrapped all the liblvm C APIs (excluding the new
APIs committed in Dec). Doc strings are still missing, as well as proper
setup.py build env, so consider it as work in progress.

This might also be interesting to other projects like Anaconda for
example.

I would love to get your feedback on it!

Best regards,
Lars 

-----------------------------
Python example code:
-----------------------------

import liblvm

# create a new LVM instance 
lvm = liblvm.Liblvm()

# open a VG handle in write mode for 'myvg'
vg = lvm.vgOpen('myvg','w')

# remove a new LV (lv_foobar)
lv = vg.createLvLinear('lv_foobar',100000)

# print the uuid for the newly created LV
print lv.getUuid()

#print the size.
print lv.getSize()

# Add a tag to it.
lv.addTag("my_fance_tag")

# Print all tags.
print lv.getTags()

# Try to deactivate 
try:
	lv.deactivate()
except liblvm.LibLVMError:
	print "lets retry.."
	lv.deactivate()

# remove 
lv.remove()

# close VG handle
vg.close()

# close LVM handle
lvm.close()

-------------- next part --------------
A non-text attachment was scrubbed...
Name: liblvm.c
Type: text/x-csrc
Size: 28425 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110120/e7f5ebc1/attachment.bin>
