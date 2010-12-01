From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Dec 2010 13:01:38 -0000
Subject: LVM2 ./WHATS_NEW lib/mirror/mirrored.c
Message-ID: <20101201130138.13725.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-01 13:01:36

Modified files:
	.              : WHATS_NEW 
	lib/mirror     : mirrored.c 

Log message:
	Check lv_info() success
	
	Add log_error message for lv_info failure and exit from futher
	processing.
	
	Replace 'leg' occurence in debug message with 'image' which
	is used in other messages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1824&r2=1.1825
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80

--- LVM2/WHATS_NEW	2010/12/01 12:56:39	1.1824
+++ LVM2/WHATS_NEW	2010/12/01 13:01:36	1.1825
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Check lv_info() success in _mirrored_transient_status().
   Add backtraces for dev_set() and dev_close_immediate() errors in set_lv().
   Add logging for unlink() error in clvmd remove_lockfile().
   Add logging for pipe write() and close() error in clvmd child_init_signal().
--- LVM2/lib/mirror/mirrored.c	2010/11/30 11:53:32	1.79
+++ LVM2/lib/mirror/mirrored.c	2010/12/01 13:01:36	1.80
@@ -291,7 +291,11 @@
 	if (!strcmp(log_args[0], "disk")) {
 		char buf[32];
 		log = first_seg(lv)->log_lv;
-		lv_info(lv->vg->cmd, log, 0, &info, 0, 0);
+		if (!lv_info(lv->vg->cmd, log, 0, &info, 0, 0)) {
+			log_error("Check for existence of mirror log %s failed.",
+				  log->name);
+			return 0;
+		}
 		log_debug("Found mirror log at %d:%d", info.major, info.minor);
 		sprintf(buf, "%d:%d", info.major, info.minor);
 		if (strcmp(buf, log_args[1])) {
@@ -311,8 +315,12 @@
 
 	for (i = 0; i < seg->area_count; ++i) {
 		char buf[32];
-		lv_info(lv->vg->cmd, seg_lv(seg, i), 0, &info, 0, 0);
-		log_debug("Found mirror leg at %d:%d", info.major, info.minor);
+		if (!lv_info(lv->vg->cmd, seg_lv(seg, i), 0, &info, 0, 0)) {
+			log_error("Check for existence of mirror image %s failed.",
+				  seg_lv(seg, i)->name);
+			return 0;
+		}
+		log_debug("Found mirror image at %d:%d", info.major, info.minor);
 		sprintf(buf, "%d:%d", info.major, info.minor);
 		for (j = 0; j < num_devs; ++j) {
 			if (!strcmp(buf, args[j])) {


