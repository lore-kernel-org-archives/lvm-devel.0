From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Jul 2009 10:08:55 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20090709100855.11916.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-09 10:08:54

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : vgchange.c 

Log message:
	Add vg_set_alloc_policy() liblvm function and move vgchange logic inside.
	
	NOTE: vg_set_alloc_policy() returns success if you try to set a value that
	is already stored.  The behavior of vgchange is the same though - it fails.
	There is a fixme noted in the code about this inconsistency, which should
	be resolved if possible.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.239&r2=1.240
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80

--- LVM2/lib/metadata/metadata-exported.h	2009/07/09 10:07:47	1.85
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/09 10:08:54	1.86
@@ -437,6 +437,7 @@
 int vg_set_extent_size(vg_t *vg, uint32_t new_extent_size);
 int vg_set_max_lv(vg_t *vg, uint32_t max_lv);
 int vg_set_max_pv(vg_t *vg, uint32_t max_pv);
+int vg_set_alloc_policy(vg_t *vg, alloc_policy_t alloc);
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 		  struct volume_group *vg_to);
 
--- LVM2/lib/metadata/metadata.c	2009/07/09 10:07:47	1.239
+++ LVM2/lib/metadata/metadata.c	2009/07/09 10:08:54	1.240
@@ -829,6 +829,24 @@
 	return 1;
 }
 
+int vg_set_alloc_policy(vg_t *vg, alloc_policy_t alloc)
+{
+	if (alloc == ALLOC_INHERIT) {
+		log_error("Volume Group allocation policy cannot inherit "
+			  "from anything");
+		return 0;
+	}
+
+	if (alloc == vg->alloc) {
+		log_print("Volume group allocation policy is already %s",
+			  get_alloc_string(vg->alloc));
+		return 1;
+	}
+	vg->alloc = alloc;
+	return 1;
+}
+
+
 /*
  * Separate metadata areas after splitting a VG.
  * Also accepts orphan VG as destination (for vgreduce).
--- LVM2/tools/vgchange.c	2009/07/09 10:07:47	1.79
+++ LVM2/tools/vgchange.c	2009/07/09 10:08:54	1.80
@@ -179,23 +179,18 @@
 
 	alloc = arg_uint_value(cmd, alloc_ARG, ALLOC_NORMAL);
 
-	if (alloc == ALLOC_INHERIT) {
-		log_error("Volume Group allocation policy cannot inherit "
-			  "from anything");
-		return EINVALID_CMD_LINE;
-	}
+	if (!archive(vg))
+		return ECMD_FAILED;
 
+	/* FIXME: make consistent with vg_set_alloc_policy() */
 	if (alloc == vg->alloc) {
 		log_error("Volume group allocation policy is already %s",
 			  get_alloc_string(vg->alloc));
 		return ECMD_FAILED;
 	}
-
-	if (!archive(vg))
+	if (!vg_set_alloc_policy(vg, alloc))
 		return ECMD_FAILED;
 
-	vg->alloc = alloc;
-
 	if (!vg_write(vg) || !vg_commit(vg))
 		return ECMD_FAILED;
 


