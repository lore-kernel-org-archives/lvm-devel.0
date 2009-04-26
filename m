From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 26 Apr 2009 08:12:13 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20090426081213.14961.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-04-26 08:12:12

Modified files:
	tools          : lvcreate.c 

Log message:
	Fix wrong arg in lv_is_virtual_origin call while creating snapshots.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.183&r2=1.184

--- LVM2/tools/lvcreate.c	2009/04/25 01:18:00	1.183
+++ LVM2/tools/lvcreate.c	2009/04/26 08:12:12	1.184
@@ -725,7 +725,7 @@
 					  lp->origin);
 				return 0;
 			}
-			if (lv_is_virtual_origin(lv)) {
+			if (lv_is_virtual_origin(org)) {
 				log_error("Can't share virtual origins. "
 					  "Use --virtualoriginsize.");
 				return 0;


