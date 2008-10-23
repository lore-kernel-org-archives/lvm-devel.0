From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Oct 2008 11:21:05 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20081023112105.5250.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-10-23 11:21:04

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Fix temp table activation in mirror conversions not to happen in other cmds.
	Fix temp table in mirror conversions to use always-present error not zero.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.979&r2=1.980
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.157&r2=1.158

--- LVM2/WHATS_NEW	2008/10/17 17:48:10	1.979
+++ LVM2/WHATS_NEW	2008/10/23 11:21:04	1.980
@@ -1,5 +1,7 @@
 Version 2.02.42 - 
 ===================================
+  Fix temp table activation in mirror conversions not to happen in other cmds.
+  Fix temp table in mirror conversions to use always-present error not zero.
 
 Version 2.02.41 - 17th October 2008
 ===================================
--- LVM2/lib/metadata/lv_manip.c	2008/10/17 10:57:15	1.157
+++ LVM2/lib/metadata/lv_manip.c	2008/10/23 11:21:04	1.158
@@ -2380,30 +2380,29 @@
 		return NULL;
 	}
 
-	if (strstr(name, "_mimagetmp")) {
-		log_very_verbose("Creating transient 'zero' LV"
-				 " for Mirror -> mirror up-convert.");
+	if (lv_is_active(lv_where) && strstr(name, "_mimagetmp")) {
+		log_very_verbose("Creating transient LV %s for mirror conversion in VG %s.", name, lv_where->vg->name);
 
-		segtype = get_segtype_from_string(cmd, "zero");
+		segtype = get_segtype_from_string(cmd, "error");
 
 		if (!lv_add_virtual_segment(layer_lv, 0, lv_where->le_count, segtype)) {
-			log_error("Creation of intermediate layer LV failed.");
+			log_error("Creation of transient LV %s for mirror conversion in VG %s failed.", name, lv_where->vg->name);
 			return NULL;
 		}
 
 		if (!vg_write(lv_where->vg)) {
-			log_error("Failed to write intermediate VG metadata");
+			log_error("Failed to write intermediate VG %s metadata for mirror conversion.", lv_where->vg->name);
 			return NULL;
 		}
 
 		if (!vg_commit(lv_where->vg)) {
-			log_error("Failed to commit intermediate VG metadata");
+			log_error("Failed to commit intermediate VG %s metadata for mirror conversion.", lv_where->vg->name);
 			vg_revert(lv_where->vg);
 			return NULL;
 		}
 
 		if (!activate_lv(cmd, layer_lv)) {
-			log_error("Failed to resume intermediate 'zero' LV, %s", name);
+			log_error("Failed to resume transient error LV %s for mirror conversion in VG %s.", name, lv_where->vg->name);
 			return NULL;
 		}
 	}


