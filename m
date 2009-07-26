From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 02:34:10 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20090726023410.16989.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 02:34:09

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : lvcreate.c 

Log message:
	Move extents_from_size from lvcreate into internal library so we can reuse.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.100&r2=1.101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.266&r2=1.267
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.206&r2=1.207

--- LVM2/lib/metadata/metadata-exported.h	2009/07/26 02:33:35	1.100
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/26 02:34:09	1.101
@@ -495,6 +495,9 @@
 int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 	      const char *new_name);
 
+uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
+			   uint32_t extent_size);
+
 /* FIXME: refactor and reduce the size of this struct! */
 struct lvcreate_params {
 	/* flags */
--- LVM2/lib/metadata/metadata.c	2009/07/26 02:02:22	1.266
+++ LVM2/lib/metadata/metadata.c	2009/07/26 02:34:09	1.267
@@ -680,6 +680,28 @@
 	return NULL;
 }
 
+uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
+			   uint32_t extent_size)
+{
+	if (size % extent_size) {
+		size += extent_size - size % extent_size;
+		log_print("Rounding up size to full physical extent %s",
+			  display_size(cmd, size));
+	}
+
+	if (size > (uint64_t) UINT32_MAX * extent_size) {
+		log_error("Volume too large (%s) for extent size %s. "
+			  "Upper limit is %s.",
+			  display_size(cmd, size),
+			  display_size(cmd, (uint64_t) extent_size),
+			  display_size(cmd, (uint64_t) UINT32_MAX *
+				       extent_size));
+		return 0;
+	}
+
+	return (uint64_t) size / extent_size;
+}
+
 static int _recalc_extents(uint32_t *extents, const char *desc1,
 			   const char *desc2, uint32_t old_size,
 			   uint32_t new_size)
--- LVM2/tools/lvcreate.c	2009/07/26 02:33:35	1.206
+++ LVM2/tools/lvcreate.c	2009/07/26 02:34:09	1.207
@@ -25,9 +25,6 @@
 	int pv_count;
 };
 
-static uint64_t _extents_from_size(struct cmd_context *cmd, uint64_t size,
-				   uint32_t extent_size);
-
 static int _lvcreate_name_params(struct lvcreate_params *lp,
 				 struct cmd_context *cmd,
 				 int *pargc, char ***pargv)
@@ -136,12 +133,12 @@
 	uint32_t pv_extent_count;
 
 	if (lcp->size &&
-	    !(lp->extents = _extents_from_size(vg->cmd, lcp->size,
+	    !(lp->extents = extents_from_size(vg->cmd, lcp->size,
 					       vg->extent_size)))
 		return_0;
 
 	if (lp->voriginsize &&
-	    !(lp->voriginextents = _extents_from_size(vg->cmd, lp->voriginsize,
+	    !(lp->voriginextents = extents_from_size(vg->cmd, lp->voriginsize,
 						      vg->extent_size)))
 		return_0;
 
@@ -573,28 +570,6 @@
 	return 1;
 }
 
-static uint64_t _extents_from_size(struct cmd_context *cmd, uint64_t size,
-				   uint32_t extent_size)
-{
-	if (size % extent_size) {
-		size += extent_size - size % extent_size;
-		log_print("Rounding up size to full physical extent %s",
-			  display_size(cmd, size));
-	}
-
-	if (size > (uint64_t) UINT32_MAX * extent_size) {
-		log_error("Volume too large (%s) for extent size %s. "
-			  "Upper limit is %s.",
-			  display_size(cmd, size),
-			  display_size(cmd, (uint64_t) extent_size),
-			  display_size(cmd, (uint64_t) UINT32_MAX *
-				       extent_size));
-		return 0;
-	}
-
-	return (uint64_t) size / extent_size;
-}
-
 int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 {
 	int r = ECMD_PROCESSED;


