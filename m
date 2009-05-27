From: agk@sourceware.org <agk@sourceware.org>
Date: 27 May 2009 13:23:43 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c
Message-ID: <20090527132343.494.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-05-27 13:23:42

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c 

Log message:
	Skip virtual origins in process_each_lv_in_vg(). (mbroz)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1126&r2=1.1127
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.153&r2=1.154

--- LVM2/WHATS_NEW	2009/05/27 13:19:34	1.1126
+++ LVM2/WHATS_NEW	2009/05/27 13:23:41	1.1127
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Skip virtual origins in process_each_lv_in_vg().
   Fix counting of virtual origin LVs in vg_validate.
   Attempt to load dm-zero module if zero target needed but not present.
 
--- LVM2/tools/toollib.c	2009/05/21 03:04:53	1.153
+++ LVM2/tools/toollib.c	2009/05/27 13:23:42	1.154
@@ -122,6 +122,9 @@
 		if (lvl->lv->status & SNAPSHOT)
 			continue;
 
+		if (lv_is_virtual_origin(lvl->lv))
+			continue;
+
 		/* Should we process this LV? */
 		if (process_all)
 			process_lv = 1;


