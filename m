From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Jul 2008 12:28:51 -0000
Subject: LVM2 ./WHATS_NEW tools/pvchange.c
Message-ID: <20080731122851.5251.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-07-31 12:28:51

Modified files:
	.              : WHATS_NEW 
	tools          : pvchange.c 

Log message:
	Fix pvchange to handle PVs without mdas.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.937&r2=1.938
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61

--- LVM2/WHATS_NEW	2008/07/31 10:50:12	1.937
+++ LVM2/WHATS_NEW	2008/07/31 12:28:50	1.938
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Fix pvchange to handle PVs without mdas.
   Refactor _text_pv_read and always return mda list if requested.
   Fix configure to work w/o readline unless --enable-readline used. (2.02.39)
   Remove is_lvm_partition template which has not yet been coded.
--- LVM2/tools/pvchange.c	2008/07/16 10:46:12	1.60
+++ LVM2/tools/pvchange.c	2008/07/31 12:28:51	1.61
@@ -54,7 +54,6 @@
 	}
 
 	/* If in a VG, must change using volume group. */
-	/* FIXME: handle PVs with no MDAs */
 	if (!is_orphan(pv)) {
 		vg_name = pv_vg_name(pv);
 
@@ -233,8 +232,6 @@
 	struct list *pvslist;
 	struct list mdas;
 
-	list_init(&mdas);
-
 	if (arg_count(cmd, allocatable_ARG) + arg_count(cmd, addtag_ARG) +
 	    arg_count(cmd, deltag_ARG) + arg_count(cmd, uuid_ARG) != 1) {
 		log_error("Please give exactly one option of -x, -uuid, "
@@ -256,12 +253,34 @@
 		log_verbose("Using physical volume(s) on command line");
 		for (; opt < argc; opt++) {
 			pv_name = argv[opt];
-			/* FIXME Read VG instead - pv_read will fail */
+			list_init(&mdas);
 			if (!(pv = pv_read(cmd, pv_name, &mdas, NULL, 1))) {
 				log_error("Failed to read physical volume %s",
 					  pv_name);
 				continue;
 			}
+			/*
+			 * If a PV has no MDAs it may appear to be an
+			 * orphan until the metadata is read off
+			 * another PV in the same VG.  Detecting this
+			 * means checking every VG by scanning every
+			 * PV on the system.
+			 */
+			if (is_orphan(pv) && !list_size(&mdas)) {
+				if (!scan_vgs_for_pvs(cmd)) {
+					log_error("Rescan for PVs without "
+						  "metadata areas failed.");
+					continue;
+				}
+				if (!(pv = pv_read(cmd, pv_name,
+						   NULL, NULL, 1))) {
+					log_error("Failed to read "
+						  "physical volume %s",
+						  pv_name);
+					continue;
+				}
+			}
+
 			total++;
 			done += _pvchange_single(cmd, pv, NULL);
 		}


