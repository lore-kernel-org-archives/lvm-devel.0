From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Jan 2011 14:19:06 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20110124141906.6197.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-01-24 14:19:05

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c mirror.c 
	lib/misc       : lvm-globals.c 

Log message:
	Fix lvchange --test to exit cleanly.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1887&r2=1.1888
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.244&r2=1.245
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.140&r2=1.141
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/WHATS_NEW	2011/01/24 13:38:31	1.1887
+++ LVM2/WHATS_NEW	2011/01/24 14:19:05	1.1888
@@ -1,5 +1,6 @@
 Version 2.02.82 -
 ===================================
+  Fix lvchange --test to exit cleanly.
   Add change_tag to toollib.
   Allow multiple pvchange command line options to be specified together.
   Add -f (don't fork) option to clvmd and fix clvmd -d<num> description.
--- LVM2/lib/metadata/lv_manip.c	2011/01/12 20:42:51	1.244
+++ LVM2/lib/metadata/lv_manip.c	2011/01/24 14:19:05	1.245
@@ -3321,6 +3321,11 @@
 
 	backup(vg);
 
+	if (test_mode()) {
+		log_verbose("Test mode: Skipping activation and zeroing.");
+		goto out;
+	}
+
 	init_dmeventd_monitor(lp->activation_monitoring);
 
 	if (lp->snapshot) {
@@ -3399,6 +3404,7 @@
 	/* FIXME out of sequence */
 	backup(vg);
 
+out:
 	log_print("Logical volume \"%s\" created", lv->name);
 
 	/*
--- LVM2/lib/metadata/mirror.c	2011/01/11 17:21:01	1.140
+++ LVM2/lib/metadata/mirror.c	2011/01/24 14:19:05	1.141
@@ -285,6 +285,11 @@
 	uint64_t orig_status = log_lv->status;
 	int was_active = 0;
 
+	if (test_mode()) {
+		log_verbose("Test mode: Skipping mirror log initialisation.");
+		return 1;
+	}
+
 	if (!activation() && in_sync) {
 		log_error("Aborting. Unable to create in-sync mirror log "
 			  "while activation is disabled.");
--- LVM2/lib/misc/lvm-globals.c	2010/10/13 15:40:39	1.7
+++ LVM2/lib/misc/lvm-globals.c	2011/01/24 14:19:05	1.8
@@ -51,7 +51,7 @@
 void init_test(int level)
 {
 	if (!_test && level)
-		log_print("Test mode: Metadata will NOT be updated.");
+		log_print("Test mode: Metadata will NOT be updated and volumes will not be (de)activated.");
 	_test = level;
 }
 


