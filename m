From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Nov 2006 23:33:21 -0000
Subject: LVM2 ./WHATS_NEW tools/lvchange.c tools/lvconv ...
Message-ID: <20061102233321.13643.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-11-02 23:33:20

Modified files:
	.              : WHATS_NEW 
	tools          : lvchange.c lvconvert.c lvcreate.c toollib.c 
	                 toollib.h 

Log message:
	Fix mirror log LV writing to set all bits in whole LV.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.488&r2=1.489
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/WHATS_NEW	2006/11/01 18:25:26	1.488
+++ LVM2/WHATS_NEW	2006/11/02 23:33:20	1.489
@@ -1,5 +1,6 @@
 Version 2.02.14 - 
 ===================================
+  Fix mirror log LV writing to set all bits in whole LV.
   Fix clustered VG detection and default runlevels in clvmd_init_rhel4.
   Fix high-level free space check for partial allocations.
 
--- LVM2/tools/lvchange.c	2006/10/24 17:18:25	1.72
+++ LVM2/tools/lvchange.c	2006/11/02 23:33:20	1.73
@@ -294,7 +294,7 @@
 		}
 
 		log_very_verbose("Clearing log device %s", log_lv->name);
-		if (!set_lv(cmd, log_lv, 0)) {
+		if (!set_lv(cmd, log_lv, (size_t) log_lv->size, 0)) {
 			log_error("Unable to reset sync status for %s", lv->name);
 			if (!deactivate_lv(cmd, log_lv))
 				log_error("Failed to deactivate log LV after "
--- LVM2/tools/lvconvert.c	2006/10/18 18:01:53	1.22
+++ LVM2/tools/lvconvert.c	2006/11/02 23:33:20	1.23
@@ -455,7 +455,7 @@
 
 	if (!lp->zero)
 		log_error("WARNING: \"%s\" not zeroed", lv->name);
-	else if (!set_lv(cmd, lv, 0)) {
+	else if (!set_lv(cmd, lv, 0, 0)) {
 			log_error("Aborting. Failed to wipe snapshot "
 				  "exception store.");
 			return 0;
--- LVM2/tools/lvcreate.c	2006/10/26 18:22:10	1.129
+++ LVM2/tools/lvcreate.c	2006/11/02 23:33:20	1.130
@@ -773,7 +773,7 @@
 	}
 
 	if ((lp->zero || lp->snapshot) && activation()) {
-		if (!set_lv(cmd, lv, 0) && lp->snapshot) {
+		if (!set_lv(cmd, lv, 0, 0) && lp->snapshot) {
 			/* FIXME Remove the failed lv we just added */
 			log_error("Aborting. Failed to wipe snapshot "
 				  "exception store. Remove new LV and retry.");
--- LVM2/tools/toollib.c	2006/10/24 18:25:30	1.92
+++ LVM2/tools/toollib.c	2006/11/02 23:33:20	1.93
@@ -1188,7 +1188,8 @@
 /*
  * Initialize the LV with 'value'.
  */
-int set_lv(struct cmd_context *cmd, struct logical_volume *lv, int value)
+int set_lv(struct cmd_context *cmd, struct logical_volume *lv, size_t len,
+	   int value)
 {
 	struct device *dev;
 	char *name;
@@ -1221,7 +1222,7 @@
 	if (!dev_open_quiet(dev))
 		return 0;
 
-	dev_set(dev, UINT64_C(0), (size_t) 4096, value);
+	dev_set(dev, UINT64_C(0), len ?: (size_t) 4096, value);
 	dev_flush(dev);
 	dev_close_immediate(dev);
 
@@ -1336,7 +1337,8 @@
 		goto error;
 	}
 
-	if (activation() && !set_lv(cmd, log_lv, in_sync)) {
+	if (activation() && !set_lv(cmd, log_lv, (size_t) log_lv->size,
+				    in_sync ? -1 : 0)) {
 		log_error("Aborting. Failed to wipe mirror log. "
 			  "Remove new LV and retry.");
 		goto error;
--- LVM2/tools/toollib.h	2006/08/25 23:02:33	1.42
+++ LVM2/tools/toollib.h	2006/11/02 23:33:20	1.43
@@ -101,6 +101,7 @@
 					 const char *lv_name,
 					 int in_sync);
 
-int set_lv(struct cmd_context *cmd, struct logical_volume *lv, int value);
+int set_lv(struct cmd_context *cmd, struct logical_volume *lv, size_t len,
+	   int value);
 
 #endif


