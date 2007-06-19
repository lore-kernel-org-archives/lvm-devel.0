From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 19 Jun 2007 00:33:44 -0000
Subject: LVM2 lib/metadata/metadata.c lib/metadata/meta ...
Message-ID: <20070619003344.20121.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-19 00:33:43

Modified files:
	lib/metadata   : metadata.c metadata.h 
	tools          : vgextend.c 

Log message:
	Make vg_extend() format_instance * parameter internal to vg_extend()

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.118&r2=1.119
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.163&r2=1.164
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31

--- LVM2/lib/metadata/metadata.c	2007/06/15 22:16:55	1.118
+++ LVM2/lib/metadata/metadata.c	2007/06/19 00:33:43	1.119
@@ -245,14 +245,13 @@
 	return 1;
 }
 
-int vg_extend(struct format_instance *fid,
-	      struct volume_group *vg, int pv_count, char **pv_names)
+int vg_extend(struct volume_group *vg, int pv_count, char **pv_names)
 {
 	int i;
 
 	/* attach each pv */
 	for (i = 0; i < pv_count; i++)
-		if (!_add_pv_to_vg(fid, vg, pv_names[i])) {
+		if (!_add_pv_to_vg(vg->fid, vg, pv_names[i])) {
 			log_error("Unable to add physical volume '%s' to "
 				  "volume group '%s'.", pv_names[i], vg->name);
 			return 0;
@@ -352,7 +351,7 @@
 	}
 
 	/* attach the pv's */
-	if (!vg_extend(vg->fid, vg, pv_count, pv_names))
+	if (!vg_extend(vg, pv_count, pv_names))
 		goto_bad;
 
 	return vg;
--- LVM2/lib/metadata/metadata.h	2007/06/15 22:16:55	1.163
+++ LVM2/lib/metadata/metadata.h	2007/06/19 00:33:43	1.164
@@ -461,8 +461,7 @@
 int vg_remove(struct volume_group *vg);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
-int vg_extend(struct format_instance *fi, struct volume_group *vg,
-	      int pv_count, char **pv_names);
+int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
 int vg_change_pesize(struct cmd_context *cmd, struct volume_group *vg,
 		     uint32_t new_extent_size);
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
--- LVM2/tools/vgextend.c	2007/06/06 19:40:28	1.30
+++ LVM2/tools/vgextend.c	2007/06/19 00:33:43	1.31
@@ -74,7 +74,7 @@
 		goto error;
 
 	/* extend vg */
-	if (!vg_extend(vg->fid, vg, argc, argv))
+	if (!vg_extend(vg, argc, argv))
 		goto error;
 
 	/* ret > 0 */


