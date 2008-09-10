From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 10 Sep 2008 17:22:52 -0500
Subject: [PATCH] Fix mirror -> mirror up-converts
Message-ID: <1221085372.16141.13.camel@hydrogen>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Please refer to the following previous threads for history on this
subject:
https://www.redhat.com/archives/lvm-devel/2008-July/msg00026.html
https://www.redhat.com/archives/lvm-devel/2008-February/msg00007.html

Associated Bug:
https://bugzilla.redhat.com/show_bug.cgi?id=455670
(potentially others, including 460222)

The main issue is that with the current code, it is possible to activate
2 device-mapper tables that evaluate to the same thing... meaning you
can have 2 uncoordinated recovery processes happening at the same time
in conjunction with I/O streams.  (I.e.  corruption is a distinct
possibility.)  The attached patches prevent this "double activation".

There are 2 patches attached - one device-mapper patch adding the
'preload, but don't resume' function and another with the required LVM
changes.  (Please note that I've disallowed the resizing of LVs while
they have the 'CONVERTING' flag.)

 brassow


-------------- next part --------------
A non-text attachment was scrubbed...
Name: dm-fix-mirror-to-mirror-upconvert.patch
Type: text/x-patch
Size: 2842 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080910/89284be2/attachment.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-convert-fix.patch
Type: text/x-patch
Size: 2322 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080910/89284be2/attachment-0001.bin>
