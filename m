From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Jul 2009 10:04:53 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20090709100453.4679.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-09 10:04:52

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : vgchange.c 

Log message:
	Rename vg_change_pesize to vg_set_extent_size and use vg_t.
	
	In liblvm, we will reserve the word 'change' to mean an API that
	both sets one or more values, and commits to disk.  This will be
	consistent with the LVM commandline.  The existing vg_change_pesize()
	function does not commit to disk, but just changes the extent_size
	and ensures all internal structures are updated.  This logic should
	be contained in a function that sets the value.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.82&r2=1.83
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.236&r2=1.237
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77

--- LVM2/lib/metadata/metadata-exported.h	2009/07/09 10:03:37	1.82
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/09 10:04:52	1.83
@@ -434,7 +434,7 @@
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
-int vg_change_pesize(struct volume_group *vg, uint32_t new_extent_size);
+int vg_set_extent_size(vg_t *vg, uint32_t new_extent_size);
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 		  struct volume_group *vg_to);
 
--- LVM2/lib/metadata/metadata.c	2009/07/09 10:03:37	1.236
+++ LVM2/lib/metadata/metadata.c	2009/07/09 10:04:52	1.237
@@ -624,7 +624,7 @@
 	return 1;
 }
 
-int vg_change_pesize(struct volume_group *vg, uint32_t new_size)
+int vg_set_extent_size(vg_t *vg, uint32_t new_size)
 {
 	uint32_t old_size = vg->extent_size;
 	struct pv_list *pvl;
--- LVM2/tools/vgchange.c	2009/07/09 10:03:37	1.76
+++ LVM2/tools/vgchange.c	2009/07/09 10:04:52	1.77
@@ -397,7 +397,7 @@
 	if (!archive(vg))
 		return ECMD_FAILED;
 
-	if (!vg_change_pesize(vg, extent_size)) {
+	if (!vg_set_extent_size(vg, extent_size)) {
 		stack;
 		return EINVALID_CMD_LINE;
 	}


