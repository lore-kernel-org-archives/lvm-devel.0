From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 19 May 2009 10:12:41 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20090519101241.16877.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-19 10:12:41

Modified files:
	tools          : lvconvert.c 

Log message:
	Fix compilation warning.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74

--- LVM2/tools/lvconvert.c	2009/05/13 21:21:59	1.73
+++ LVM2/tools/lvconvert.c	2009/05/19 10:12:41	1.74
@@ -442,7 +442,7 @@
 	int r = 0;
 	struct logical_volume *log_lv;
 	int failed_mirrors = 0, failed_log = 0;
-	struct dm_list *old_pvh, *remove_pvs = NULL;
+	struct dm_list *old_pvh = NULL, *remove_pvs = NULL;
 
 	seg = first_seg(lv);
 	existing_mirrors = lv_mirror_count(lv);


