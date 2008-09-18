From: agk@sourceware.org <agk@sourceware.org>
Date: 18 Sep 2008 19:09:47 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20080918190947.32654.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-18 19:09:47

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	Add missing LV error target activation in _remove_mirror_images.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.953&r2=1.954
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74

--- LVM2/WHATS_NEW	2008/09/18 18:51:58	1.953
+++ LVM2/WHATS_NEW	2008/09/18 19:09:47	1.954
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Add missing LV error target activation in _remove_mirror_images.
   Prevent resizing an LV while lvconvert is using it.
   Avoid repeatedly wiping cache while VG_GLOBAL is held in vgscan & pvscan.
   Fix pvresize to not allow resize if PV has two metadata areas.
--- LVM2/lib/metadata/mirror.c	2008/06/26 23:05:11	1.73
+++ LVM2/lib/metadata/mirror.c	2008/09/18 19:09:47	1.74
@@ -552,6 +552,17 @@
 
 	log_very_verbose("Updating \"%s\" in kernel", mirrored_seg->lv->name);
 
+	/*
+	 * Avoid having same mirror target loaded twice simultaneouly by first
+	 * activating the removed LV which now contains an error segment.
+	 * As it's now detached from mirrored_seg->lv we must activate it
+	 * explicitly.
+	 */
+	if (lv1 && !activate_lv(lv1->vg->cmd, lv1)) {
+		log_error("Problem reactivating removed %s", lv1->name);
+		return 0;
+	}
+
 	if (!resume_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv)) {
 		log_error("Problem reactivating %s", mirrored_seg->lv->name);
 		return 0;


