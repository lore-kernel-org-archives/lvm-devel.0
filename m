From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Oct 2008 10:50:16 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20081017105016.26596.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-10-17 10:50:15

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	In resume_mirror_images replace activate_lv with resume_lv as workaround.
	
	(The resume has the side-effect of resuming all of the original
	mirror's sub-lvs in addition to the new 'error' target middle layer.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.975&r2=1.976
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78

--- LVM2/WHATS_NEW	2008/10/17 00:55:46	1.975
+++ LVM2/WHATS_NEW	2008/10/17 10:50:14	1.976
@@ -1,5 +1,6 @@
 Version 2.02.41 -
 =====================================
+  In resume_mirror_images replace activate_lv with resume_lv as workaround.
   Avoid overwriting in-use on-disk text metadata by forgetting MDA_HEADER_SIZE.
   Fix snapshot monitoring library to not cancel monitoring invalid snapshot.
   Generate man pages from templates and include version.
--- LVM2/lib/metadata/mirror.c	2008/09/19 04:30:02	1.77
+++ LVM2/lib/metadata/mirror.c	2008/10/17 10:50:14	1.78
@@ -598,13 +598,13 @@
 	log_very_verbose("Updating \"%s\" in kernel", mirrored_seg->lv->name);
 
 	/*
-	 * Avoid having same mirror target loaded twice simultaneouly by first
-	 * activating the removed LV which now contains an error segment.
-	 * As it's now detached from mirrored_seg->lv we must activate it
+	 * Avoid having same mirror target loaded twice simultaneously by first
+	 * resuming the removed LV which now contains an error segment.
+	 * As it's now detached from mirrored_seg->lv we must resume it
 	 * explicitly.
 	 */
-	if (lv1 && !activate_lv(lv1->vg->cmd, lv1)) {
-		log_error("Problem reactivating removed %s", lv1->name);
+	if (lv1 && !resume_lv(lv1->vg->cmd, lv1)) {
+		log_error("Problem resuming temporary LV, %s", lv1->name);
 		return 0;
 	}
 


