From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 26 Oct 2006 16:29:53 -0400
Subject: [PATCH LVM2] fix tools/Makefile to clean lvmcmdlib.o/lvm-static.o
Message-ID: <45411AC1.5060403@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Files specific to some build targets are declared as
part of CLEAN_TARGETS in tools/Makefile.
2 files (lvmcmdlib.o and lvm-static.o) are missing from it.

As a result, they are not removed after make clean or make distclean
and you'll see strange error if you moved build tree from
one environment to another and do make clean and make.

With this patch, I saw no *.o/*.a/*.so files in the build tree
after make clean.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-make-clean-fix.patch
Type: text/x-patch
Size: 559 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061026/20e711bc/attachment.bin>
