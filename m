From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Feb 2012 13:50:37 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20120201135037.23123.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-01 13:50:37

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	Add synchornization point in mirror log init.
	
	Put extra sync point when mirror log is deactivated and before
	it's activated for the second time.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2253&r2=1.2254
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.174&r2=1.175

--- LVM2/WHATS_NEW	2012/02/01 13:47:27	1.2253
+++ LVM2/WHATS_NEW	2012/02/01 13:50:36	1.2254
@@ -1,5 +1,6 @@
 Version 2.02.90 - 
 ===================================
+  Add synchronization point in mirror log initialization.
   Disable partial activation for thin LVs and LVs with all missing segments.
   Do not print warning for pv_min_size set in range between 512KB and 2MB.
   Clean up systemd unit ordering and requirements.
--- LVM2/lib/metadata/mirror.c	2011/10/25 13:17:04	1.174
+++ LVM2/lib/metadata/mirror.c	2012/02/01 13:50:37	1.175
@@ -325,6 +325,8 @@
 
 	backup(log_lv->vg);
 
+	// FIXME: Wait here explicitly, so deactivation of log_lv is finished
+	sync_local_dev_names(cmd);
 	if (!activate_lv(cmd, log_lv)) {
 		log_error("Aborting. Failed to activate mirror log.");
 		goto revert_new_lv;
@@ -437,7 +439,8 @@
 	if (!_activate_lv_like_model(lv, lv))
 		return_0;
 
-	sync_local_dev_names(lv->vg->cmd);
+	// FIXME: Wait here should not be need
+	sync_local_dev_names(cmd);
 	if (!deactivate_lv(cmd, lv))
 		return_0;
 


