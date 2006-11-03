From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Nov 2006 21:07:17 -0000
Subject: LVM2 lib/metadata/metadata.h tools/lvchange.c ...
Message-ID: <20061103210717.22155.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-11-03 21:07:15

Modified files:
	lib/metadata   : metadata.h 
	tools          : lvchange.c toollib.c toollib.h 

Log message:
	fix last check-in: lv->size is in sectors

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.150&r2=1.151
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/lib/metadata/metadata.h	2006/10/08 12:01:12	1.150
+++ LVM2/lib/metadata/metadata.h	2006/11/03 21:07:14	1.151
@@ -285,7 +285,7 @@
 	int32_t major;
 	int32_t minor;
 
-	uint64_t size;
+	uint64_t size;		/* Sectors */
 	uint32_t le_count;
 
 	uint32_t origin_count;
--- LVM2/tools/lvchange.c	2006/11/02 23:33:20	1.73
+++ LVM2/tools/lvchange.c	2006/11/03 21:07:15	1.74
@@ -294,7 +294,7 @@
 		}
 
 		log_very_verbose("Clearing log device %s", log_lv->name);
-		if (!set_lv(cmd, log_lv, (size_t) log_lv->size, 0)) {
+		if (!set_lv(cmd, log_lv, log_lv->size, 0)) {
 			log_error("Unable to reset sync status for %s", lv->name);
 			if (!deactivate_lv(cmd, log_lv))
 				log_error("Failed to deactivate log LV after "
--- LVM2/tools/toollib.c	2006/11/02 23:33:20	1.93
+++ LVM2/tools/toollib.c	2006/11/03 21:07:15	1.94
@@ -1188,8 +1188,8 @@
 /*
  * Initialize the LV with 'value'.
  */
-int set_lv(struct cmd_context *cmd, struct logical_volume *lv, size_t len,
-	   int value)
+int set_lv(struct cmd_context *cmd, struct logical_volume *lv,
+	   uint64_t sectors, int value)
 {
 	struct device *dev;
 	char *name;
@@ -1222,7 +1222,8 @@
 	if (!dev_open_quiet(dev))
 		return 0;
 
-	dev_set(dev, UINT64_C(0), len ?: (size_t) 4096, value);
+	dev_set(dev, UINT64_C(0),
+		sectors ? (size_t) sectors >> SECTOR_SHIFT : (size_t) 4096, value);
 	dev_flush(dev);
 	dev_close_immediate(dev);
 
@@ -1337,7 +1338,7 @@
 		goto error;
 	}
 
-	if (activation() && !set_lv(cmd, log_lv, (size_t) log_lv->size,
+	if (activation() && !set_lv(cmd, log_lv, log_lv->size,
 				    in_sync ? -1 : 0)) {
 		log_error("Aborting. Failed to wipe mirror log. "
 			  "Remove new LV and retry.");
--- LVM2/tools/toollib.h	2006/11/02 23:33:20	1.43
+++ LVM2/tools/toollib.h	2006/11/03 21:07:15	1.44
@@ -101,7 +101,7 @@
 					 const char *lv_name,
 					 int in_sync);
 
-int set_lv(struct cmd_context *cmd, struct logical_volume *lv, size_t len,
-	   int value);
+int set_lv(struct cmd_context *cmd, struct logical_volume *lv,
+	   uint64_t sectors, int value);
 
 #endif


