From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Feb 2011 01:41:03 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c
Message-ID: <20110203014103.8990.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-03 01:41:03

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 

Log message:
	Fix wipe size when seting up mda.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1899&r2=1.1900
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.153&r2=1.154

--- LVM2/WHATS_NEW	2011/02/03 01:24:46	1.1899
+++ LVM2/WHATS_NEW	2011/02/03 01:41:03	1.1900
@@ -1,5 +1,6 @@
 Version 2.02.83 - 
 ===================================
+  Fix wipe size when setting up mda.
   Remove unneeded checks for open_count in lv_info().
   Synchronize with udev before checking open_count in lv_info().
   Allow CLVMD_CMD_SYNC_NAMES to be propagated around the cluster if requested.
--- LVM2/lib/format_text/format-text.c	2010/12/20 13:32:49	1.153
+++ LVM2/lib/format_text/format-text.c	2011/02/03 01:41:03	1.154
@@ -1347,8 +1347,8 @@
 			return 0;
 
 		if (!dev_set((struct device *) pv->dev, start1,
-			     (size_t) (mda_size1 >
-				       wipe_size ? : mda_size1), 0)) {
+			     (size_t) ((mda_size1 > wipe_size) ?
+				       wipe_size : mda_size1), 0)) {
 			log_error("Failed to wipe new metadata area");
 			return 0;
 		}
@@ -1392,8 +1392,8 @@
 		if (!add_mda(fmt, fmt->cmd->mem, mdas, pv->dev, start2,
 			     mda_size2, metadataignore)) return 0;
 		if (!dev_set(pv->dev, start2,
-			     (size_t) (mda_size1 >
-				       wipe_size ? : mda_size1), 0)) {
+			     (size_t) ((mda_size2 > wipe_size) ?
+				       wipe_size : mda_size2), 0)) {
 			log_error("Failed to wipe new metadata area");
 			return 0;
 		}


