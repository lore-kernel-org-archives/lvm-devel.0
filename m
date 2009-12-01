From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 1 Dec 2009 19:10:24 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c
Message-ID: <20091201191024.9255.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-12-01 19:10:23

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 

Log message:
	Fix memory leak in lv_info_by_lvid
	
	The lv_from_lvid calls internally vg_read(),
	we must release vg structure afterwards.
	
	Code is called only from clvmd.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1335&r2=1.1336
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.158&r2=1.159

--- LVM2/WHATS_NEW	2009/11/27 14:35:38	1.1335
+++ LVM2/WHATS_NEW	2009/12/01 19:10:23	1.1336
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Fix clvmd memory leak in lv_info_by_lvid.
   Do not allow creating mirrors of more than 8 images.
   Use locking_type 3 (compiled in cluster locking) in lvmconf.
   Remove duplicate dm_list macros and functions.
--- LVM2/lib/activate/activate.c	2009/10/30 13:07:49	1.158
+++ LVM2/lib/activate/activate.c	2009/12/01 19:10:23	1.159
@@ -486,12 +486,16 @@
 int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s,
 		    struct lvinfo *info, int with_open_count, int with_read_ahead)
 {
+	int r;
 	struct logical_volume *lv;
 
 	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
 		return 0;
 
-	return _lv_info(cmd, lv, 0, info, with_open_count, with_read_ahead, 0);
+	r = _lv_info(cmd, lv, 0, info, with_open_count, with_read_ahead, 0);
+	vg_release(lv->vg);
+
+	return r;
 }
 
 /*


