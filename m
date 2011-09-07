From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Sep 2011 08:41:49 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c tools/vgchange.c
Message-ID: <20110907084149.13250.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-07 08:41:48

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c vgchange.c 

Log message:
	Support break for vgchange and vgrefresh operation
	
	Allow to break some lengthy vgchange and vgrefresh operation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2096&r2=1.2097
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.229&r2=1.230
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.121&r2=1.122

--- LVM2/WHATS_NEW	2011/09/07 08:34:21	1.2096
+++ LVM2/WHATS_NEW	2011/09/07 08:41:47	1.2097
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Support break for vgchange and vgrefresh operation.
   Switch int to unsigned type for pvmetadatacopies for pv_create().
   Replace :space: with [\t ] for awk in vgimportclone (not widely supported).
   Begin using 64-bit status field flags.
--- LVM2/tools/toollib.c	2011/08/30 14:55:19	1.229
+++ LVM2/tools/toollib.c	2011/09/07 08:41:48	1.230
@@ -1323,10 +1323,17 @@
 	struct lv_list *lvl;
 	int r = 1;
 
-	dm_list_iterate_items(lvl, &vg->lvs)
+	sigint_allow();
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (sigint_caught())
+			return_0;
+
 		if (lv_is_visible(lvl->lv))
 			if (!lv_refresh(cmd, lvl->lv))
 				r = 0;
+	}
+
+	sigint_restore();
 
 	return r;
 }
--- LVM2/tools/vgchange.c	2011/06/11 00:03:08	1.121
+++ LVM2/tools/vgchange.c	2011/09/07 08:41:48	1.122
@@ -90,7 +90,11 @@
 	struct logical_volume *lv;
 	int count = 0, expected_count = 0;
 
+	sigint_allow();
 	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (sigint_caught())
+			return_0;
+
 		lv = lvl->lv;
 
 		if (!lv_is_visible(lv))
@@ -160,6 +164,8 @@
 		count++;
 	}
 
+	sigint_restore();
+
 	if (expected_count)
 		log_verbose("%s %d logical volumes in volume group %s",
 			    (activate == CHANGE_AN || activate == CHANGE_ALN)?


