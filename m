From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Nov 2006 21:23:06 -0000
Subject: LVM2/tools toollib.c
Message-ID: <20061103212306.31759.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-11-03 21:23:06

Modified files:
	tools          : toollib.c 

Log message:
	fix shift

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95

--- LVM2/tools/toollib.c	2006/11/03 21:07:15	1.94
+++ LVM2/tools/toollib.c	2006/11/03 21:23:06	1.95
@@ -1223,7 +1223,8 @@
 		return 0;
 
 	dev_set(dev, UINT64_C(0),
-		sectors ? (size_t) sectors >> SECTOR_SHIFT : (size_t) 4096, value);
+		sectors ? (size_t) sectors << SECTOR_SHIFT : (size_t) 4096,
+		value);
 	dev_flush(dev);
 	dev_close_immediate(dev);
 


