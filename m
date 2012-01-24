From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Jan 2012 14:54:00 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20120124145400.9008.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-01-24 14:53:59

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Caller is still entitled to reference an LV that's unlinked, so don't
	tamper with struct contents.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.347&r2=1.348

--- LVM2/lib/metadata/lv_manip.c	2012/01/24 14:15:52	1.347
+++ LVM2/lib/metadata/lv_manip.c	2012/01/24 14:53:59	1.348
@@ -3111,8 +3111,6 @@
 
 	dm_list_del(&lvl->list);
 
-	lv->status = 0;   /* Reset */
-
 	return 1;
 }
 


