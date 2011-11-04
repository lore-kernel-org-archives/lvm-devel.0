From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Nov 2011 22:49:54 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c lib/m ...
Message-ID: <20111104224954.4844.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-04 22:49:53

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c vg.c vg.h 
	tools          : lvresize.c 

Log message:
	Avoid lvextend to overflow
	
	Add extra check to extent_count overflow.
	Use internal define MAX_EXTENT_COUNT instead UINT32_MAX.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2177&r2=1.2178
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.471&r2=1.472
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.h.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.140&r2=1.141

--- LVM2/WHATS_NEW	2011/11/04 01:31:23	1.2177
+++ LVM2/WHATS_NEW	2011/11/04 22:49:53	1.2178
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix extent_count overflow with lvextend.
   Add missing lvrename mirrored log recursion in for_each_sub_lv.
   Improve lv_extend stack reporting.
   Increase virtual segment size instead of creating multiple segment list.
--- LVM2/lib/metadata/metadata.c	2011/10/28 20:12:55	1.471
+++ LVM2/lib/metadata/metadata.c	2011/11/04 22:49:53	1.472
@@ -276,12 +276,12 @@
 	if (!alloc_pv_segment_whole_pv(mem, pv))
 		return_0;
 
-	if ((uint64_t) vg->extent_count + pv->pe_count > UINT32_MAX) {
+	if ((uint64_t) vg->extent_count + pv->pe_count > MAX_EXTENT_COUNT) {
 		log_error("Unable to add %s to %s: new extent count (%"
 			  PRIu64 ") exceeds limit (%" PRIu32 ").",
 			  pv_name, vg->name,
 			  (uint64_t) vg->extent_count + pv->pe_count,
-			  UINT32_MAX);
+			  MAX_EXTENT_COUNT);
 		return 0;
 	}
 
@@ -1000,12 +1000,12 @@
 			  display_size(cmd, size));
 	}
 
-	if (size > (uint64_t) UINT32_MAX * extent_size) {
+	if (size > (uint64_t) MAX_EXTENT_COUNT * extent_size) {
 		log_error("Volume too large (%s) for extent size %s. "
 			  "Upper limit is %s.",
 			  display_size(cmd, size),
 			  display_size(cmd, (uint64_t) extent_size),
-			  display_size(cmd, (uint64_t) UINT32_MAX *
+			  display_size(cmd, (uint64_t) MAX_EXTENT_COUNT *
 				       extent_size));
 		return 0;
 	}
--- LVM2/lib/metadata/vg.c	2011/08/11 17:24:24	1.12
+++ LVM2/lib/metadata/vg.c	2011/11/04 22:49:53	1.13
@@ -261,7 +261,7 @@
 
 	size /= new_size;
 
-	if (size > UINT32_MAX) {
+	if (size > MAX_EXTENT_COUNT) {
 		log_error("New extent count %" PRIu64 " for %s%s exceeds "
 			  "32 bits.", size, desc1, desc2);
 		return 0;
--- LVM2/lib/metadata/vg.h	2011/08/11 17:24:24	1.15
+++ LVM2/lib/metadata/vg.h	2011/11/04 22:49:53	1.16
@@ -37,6 +37,8 @@
 	struct pvcreate_params *pp;
 };
 
+#define MAX_EXTENT_COUNT  (UINT32_MAX)
+
 struct volume_group {
 	struct cmd_context *cmd;
 	struct dm_pool *vgmem;
--- LVM2/tools/lvresize.c	2011/10/28 20:31:01	1.140
+++ LVM2/tools/lvresize.c	2011/11/04 22:49:53	1.141
@@ -459,8 +459,14 @@
 			break;
 	}
 
-	if (lp->sign == SIGN_PLUS)
+	if (lp->sign == SIGN_PLUS) {
+		if (lp->extents >= (MAX_EXTENT_COUNT - lv->le_count)) {
+			log_error("Unable to extend %s by %u extents, exceeds limit (%u).",
+				  lp->lv_name, lv->le_count, MAX_EXTENT_COUNT);
+			return EINVALID_CMD_LINE;
+		}
 		lp->extents += lv->le_count;
+	}
 
 	if (lp->sign == SIGN_MINUS) {
 		if (lp->extents >= lv->le_count) {


