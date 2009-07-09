From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Jul 2009 10:03:38 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20090709100338.26981.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-09 10:03:37

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : vgchange.c 

Log message:
	Remove unused 'cmd' from vg_change_pesize().
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.235&r2=1.236
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76

--- LVM2/lib/metadata/metadata-exported.h	2009/07/08 14:33:17	1.81
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/09 10:03:37	1.82
@@ -434,8 +434,7 @@
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
-int vg_change_pesize(struct cmd_context *cmd, struct volume_group *vg,
-		     uint32_t new_extent_size);
+int vg_change_pesize(struct volume_group *vg, uint32_t new_extent_size);
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 		  struct volume_group *vg_to);
 
--- LVM2/lib/metadata/metadata.c	2009/07/09 10:02:15	1.235
+++ LVM2/lib/metadata/metadata.c	2009/07/09 10:03:37	1.236
@@ -624,8 +624,7 @@
 	return 1;
 }
 
-int vg_change_pesize(struct cmd_context *cmd __attribute((unused)),
-		     struct volume_group *vg, uint32_t new_size)
+int vg_change_pesize(struct volume_group *vg, uint32_t new_size)
 {
 	uint32_t old_size = vg->extent_size;
 	struct pv_list *pvl;
--- LVM2/tools/vgchange.c	2009/07/09 10:02:15	1.75
+++ LVM2/tools/vgchange.c	2009/07/09 10:03:37	1.76
@@ -397,7 +397,7 @@
 	if (!archive(vg))
 		return ECMD_FAILED;
 
-	if (!vg_change_pesize(cmd, vg, extent_size)) {
+	if (!vg_change_pesize(vg, extent_size)) {
 		stack;
 		return EINVALID_CMD_LINE;
 	}


