From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Apr 2010 14:54:38 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20100401145438.18583.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-01 14:54:38

Modified files:
	lib/metadata   : mirror.c 

Log message:
	A few more log_error to log_warn changes for mirrors.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110

--- LVM2/lib/metadata/mirror.c	2010/03/26 22:15:43	1.109
+++ LVM2/lib/metadata/mirror.c	2010/04/01 14:54:37	1.110
@@ -1080,15 +1080,15 @@
 	/* FIXME: Use lvconvert rather than duplicating its code */
 
 	if (mirrored_seg->area_count < num_mirrors) {
-		log_error("WARNING: Failed to replace mirror device in %s/%s",
-			  mirrored_seg->lv->vg->name, mirrored_seg->lv->name);
+		log_warn("WARNING: Failed to replace mirror device in %s/%s",
+			 mirrored_seg->lv->vg->name, mirrored_seg->lv->name);
 
 		if ((mirrored_seg->area_count > 1) && !mirrored_seg->log_lv)
-			log_error("WARNING: Use 'lvconvert -m %d %s/%s --corelog' to replace failed devices",
-				  num_mirrors - 1, lv->vg->name, lv->name);
+			log_warn("WARNING: Use 'lvconvert -m %d %s/%s --corelog' to replace failed devices",
+				 num_mirrors - 1, lv->vg->name, lv->name);
 		else
-			log_error("WARNING: Use 'lvconvert -m %d %s/%s' to replace failed devices",
-				  num_mirrors - 1, lv->vg->name, lv->name);
+			log_warn("WARNING: Use 'lvconvert -m %d %s/%s' to replace failed devices",
+				 num_mirrors - 1, lv->vg->name, lv->name);
 		r = 0;
 
 		/* REMEMBER/FIXME: set in_sync to 0 if a new mirror device was added */
@@ -1101,11 +1101,11 @@
 	 */
 	if ((mirrored_seg->area_count > 1) && !mirrored_seg->log_lv &&
 	    (log_policy != MIRROR_REMOVE)) {
-		log_error("WARNING: Failed to replace mirror log device in %s/%s",
-			  lv->vg->name, lv->name);
+		log_warn("WARNING: Failed to replace mirror log device in %s/%s",
+			 lv->vg->name, lv->name);
 
-		log_error("WARNING: Use 'lvconvert -m %d %s/%s' to replace failed devices",
-			  mirrored_seg->area_count - 1 , lv->vg->name, lv->name);
+		log_warn("WARNING: Use 'lvconvert -m %d %s/%s' to replace failed devices",
+			 mirrored_seg->area_count - 1 , lv->vg->name, lv->name);
 		r = 0;
 	}
 
@@ -1150,8 +1150,8 @@
 
 	if (!r)
 		/* Failed to replace device(s) */
-		log_error("WARNING: Unable to find substitute device for mirror volume, %s/%s",
-			  mirrored_seg->lv->vg->name, mirrored_seg->lv->name);
+		log_warn("WARNING: Unable to find substitute device for mirror volume, %s/%s",
+			 mirrored_seg->lv->vg->name, mirrored_seg->lv->name);
 	else if (r > 0)
 		/* Success in replacing device(s) */
 		log_warn("WARNING: Mirror volume, %s/%s restored - substitute for failed device found.",


