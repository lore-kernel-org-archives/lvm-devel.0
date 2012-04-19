From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 19 Apr 2012 21:50:38 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20120419215038.7830.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-04-19 21:50:37

Modified files:
	tools          : lvconvert.c 

Log message:
	Fix for bug 807776: invalid lvconvert --merge output should mention raid1 now
	
	s/snapshot/mergeable volume/

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.189&r2=1.190

--- LVM2/tools/lvconvert.c	2012/03/30 08:58:02	1.189
+++ LVM2/tools/lvconvert.c	2012/04/19 21:50:37	1.190
@@ -1760,7 +1760,7 @@
 
 	if (lp->merge) {
 		if (!lv_is_cow(lv)) {
-			log_error("Logical volume \"%s\" is not a snapshot",
+			log_error("\"%s\" is not a mergeable logical volume",
 				  lv->name);
 			return ECMD_FAILED;
 		}


