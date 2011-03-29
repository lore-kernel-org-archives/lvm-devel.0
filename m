From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 29 Mar 2011 12:52:00 -0000
Subject: LVM2 lib/format_text/flags.c lib/metadata/lv.c ...
Message-ID: <20110329125200.16039.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-03-29 12:51:58

Modified files:
	lib/format_text: flags.c 
	lib/metadata   : lv.c lv_manip.c metadata-exported.h mirror.c 
	tools          : lvchange.c lvconvert.c 

Log message:
	s/MIRROR_NOTSYNCED/LV_NOTSYNCED/ - Flag will may refer to more than just mirrors

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/flags.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.252&r2=1.253
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.187&r2=1.188
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.145&r2=1.146
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.158&r2=1.159

--- LVM2/lib/format_text/flags.c	2010/12/20 13:12:56	1.43
+++ LVM2/lib/format_text/flags.c	2011/03/29 12:51:57	1.44
@@ -55,7 +55,7 @@
 	{VISIBLE_LV, "VISIBLE", STATUS_FLAG},
 	{PVMOVE, "PVMOVE", STATUS_FLAG},
 	{LOCKED, "LOCKED", STATUS_FLAG},
-	{MIRROR_NOTSYNCED, "NOTSYNCED", STATUS_FLAG},
+	{LV_NOTSYNCED, "NOTSYNCED", STATUS_FLAG},
 	{MIRROR_IMAGE, NULL, 0},
 	{MIRROR_LOG, NULL, 0},
 	{MIRRORED, NULL, 0},
--- LVM2/lib/metadata/lv.c	2011/03/09 12:44:43	1.22
+++ LVM2/lib/metadata/lv.c	2011/03/29 12:51:57	1.23
@@ -236,7 +236,7 @@
 		repstr[0] = (lv_is_merging_origin(lv)) ? 'O' : 'o';
 	}
 	else if (lv->status & MIRRORED) {
-		repstr[0] = (lv->status & MIRROR_NOTSYNCED) ? 'M' : 'm';
+		repstr[0] = (lv->status & LV_NOTSYNCED) ? 'M' : 'm';
 	}else if (lv->status & MIRROR_IMAGE)
 		repstr[0] = (_lv_mimage_in_sync(lv)) ? 'i' : 'I';
 	else if (lv->status & MIRROR_LOG)
--- LVM2/lib/metadata/lv_manip.c	2011/03/25 22:02:27	1.252
+++ LVM2/lib/metadata/lv_manip.c	2011/03/29 12:51:57	1.253
@@ -3586,7 +3586,7 @@
 		if (lp->nosync) {
 			log_warn("WARNING: New mirror won't be synchronised. "
 				  "Don't read what you didn't write!");
-			status |= MIRROR_NOTSYNCED;
+			status |= LV_NOTSYNCED;
 		}
 	}
 
--- LVM2/lib/metadata/metadata-exported.h	2011/03/11 14:56:56	1.187
+++ LVM2/lib/metadata/metadata-exported.h	2011/03/29 12:51:57	1.188
@@ -61,7 +61,7 @@
 //#define VIRTUAL			0x00010000U	/* LV - internal use only */
 #define MIRROR_LOG		0x00020000U	/* LV */
 #define MIRROR_IMAGE		0x00040000U	/* LV */
-#define MIRROR_NOTSYNCED	0x00080000U	/* LV */
+#define LV_NOTSYNCED		0x00080000U	/* LV */
 //#define ACTIVATE_EXCL		0x00100000U	/* LV - internal use only */
 //#define PRECOMMITTED		0x00200000U	/* VG - internal use only */
 #define CONVERTING		0x00400000U	/* LV */
--- LVM2/lib/metadata/mirror.c	2011/03/24 12:28:02	1.145
+++ LVM2/lib/metadata/mirror.c	2011/03/29 12:51:57	1.146
@@ -701,7 +701,7 @@
 		if (!remove_layer_from_lv(lv, sub_lv))
 			return_0;
 		lv->status &= ~MIRRORED;
-		lv->status &= ~MIRROR_NOTSYNCED;
+		lv->status &= ~LV_NOTSYNCED;
 	}
 
 	if (!vg_write(mirrored_seg->lv->vg)) {
@@ -882,7 +882,7 @@
                  */
                 if (lv_mirror_count(lv) == 1) {
                     lv->status &= ~MIRRORED;
-                    lv->status &= ~MIRROR_NOTSYNCED;
+                    lv->status &= ~LV_NOTSYNCED;
                 }
 		mirrored_seg = first_seg(lv);
 		if (remove_log && !detached_log_lv)
@@ -894,7 +894,7 @@
 		 * It can happen for vgreduce --removemissing. */
 		detached_log_lv = detach_mirror_log(mirrored_seg);
 		lv->status &= ~MIRRORED;
-		lv->status &= ~MIRROR_NOTSYNCED;
+		lv->status &= ~LV_NOTSYNCED;
 		if (!replace_lv_with_error_segment(lv))
 			return_0;
 	} else if (remove_log)
@@ -1671,7 +1671,7 @@
 		init_mirror_in_sync(1);
 	else {
 		/* A full resync will take place */
-		lv->status &= ~MIRROR_NOTSYNCED;
+		lv->status &= ~LV_NOTSYNCED;
 		init_mirror_in_sync(0);
 	}
 
--- LVM2/tools/lvchange.c	2011/01/24 13:38:32	1.128
+++ LVM2/tools/lvchange.c	2011/03/29 12:51:58	1.129
@@ -245,7 +245,7 @@
 	 * it to reset the sync status.  We only need to
 	 * worry about persistent logs.
 	 */
-	if (!log_lv && !(lv->status & MIRROR_NOTSYNCED)) {
+	if (!log_lv && !(lv->status & LV_NOTSYNCED)) {
 		if (active && !activate_lv(cmd, lv)) {
 			log_error("Failed to reactivate %s to resynchronize "
 				  "mirror", lv->name);
@@ -254,7 +254,7 @@
 		return 1;
 	}
 
-	lv->status &= ~MIRROR_NOTSYNCED;
+	lv->status &= ~LV_NOTSYNCED;
 
 	if (log_lv) {
 		/* Separate mirror log so we can clear it */
--- LVM2/tools/lvconvert.c	2011/03/11 14:56:56	1.158
+++ LVM2/tools/lvconvert.c	2011/03/29 12:51:58	1.159
@@ -1052,7 +1052,7 @@
 	 * Up-convert m-way mirror to n-way mirror
 	 */
 	if (new_mimage_count > old_mimage_count) {
-		if (lv->status & MIRROR_NOTSYNCED) {
+		if (lv->status & LV_NOTSYNCED) {
 			log_error("Can't add mirror to out-of-sync mirrored "
 				  "LV: use lvchange --resync first.");
 			return 0;


