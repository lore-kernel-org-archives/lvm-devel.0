From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 24 Feb 2010 18:15:07 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20100224181507.13932.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-02-24 18:15:06

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : vgchange.c 

Log message:
	Refactor _vgchange_tag() to vg_change_tag() library function.
	
	Pull out common code to be called from tools as well as lvm2app.
	Leave archive() at tool level so we can use from vgcreate
	as well as vgchange.  Should be no functional change.
	- add stack macro in vgchange
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.131&r2=1.132
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.314&r2=1.315
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99

--- LVM2/lib/metadata/metadata-exported.h	2010/02/14 03:21:37	1.131
+++ LVM2/lib/metadata/metadata-exported.h	2010/02/24 18:15:05	1.132
@@ -463,6 +463,7 @@
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names,
 	      struct pvcreate_params *pp);
 int vg_reduce(struct volume_group *vg, char *pv_name);
+int vg_change_tag(struct volume_group *vg, const char *tag, int add_tag);
 int vg_set_extent_size(struct volume_group *vg, uint32_t new_extent_size);
 int vg_set_max_lv(struct volume_group *vg, uint32_t max_lv);
 int vg_set_max_pv(struct volume_group *vg, uint32_t max_pv);
--- LVM2/lib/metadata/metadata.c	2010/02/14 03:21:37	1.314
+++ LVM2/lib/metadata/metadata.c	2010/02/24 18:15:05	1.315
@@ -665,6 +665,29 @@
 	return 0;
 }
 
+int vg_change_tag(struct volume_group *vg, const char *tag, int add_tag)
+{
+	if (!(vg->fid->fmt->features & FMT_TAGS)) {
+		log_error("Volume group %s does not support tags", vg->name);
+		return 0;
+	}
+
+	if (add_tag) {
+		if (!str_list_add(vg->vgmem, &vg->tags, tag)) {
+			log_error("Failed to add tag %s to volume group %s",
+				  tag, vg->name);
+			return 0;
+		}
+	} else {
+		if (!str_list_del(&vg->tags, tag)) {
+			log_error("Failed to remove tag %s from volume group "
+				  "%s", tag, vg->name);
+			return 0;
+		}
+	}
+	return 1;
+}
+
 const char *strip_dir(const char *vg_name, const char *dev_dir)
 {
 	size_t len = strlen(dev_dir);
--- LVM2/tools/vgchange.c	2010/01/13 01:56:18	1.98
+++ LVM2/tools/vgchange.c	2010/02/24 18:15:06	1.99
@@ -447,28 +447,14 @@
 		return ECMD_FAILED;
 	}
 
-	if (!(vg->fid->fmt->features & FMT_TAGS)) {
-		log_error("Volume group %s does not support tags", vg->name);
-		return ECMD_FAILED;
-	}
-
 	if (!archive(vg)) {
 		stack;
 		return ECMD_FAILED;
 	}
 
-	if ((arg == addtag_ARG)) {
-		if (!str_list_add(cmd->mem, &vg->tags, tag)) {
-			log_error("Failed to add tag %s to volume group %s",
-				  tag, vg->name);
-			return ECMD_FAILED;
-		}
-	} else {
-		if (!str_list_del(&vg->tags, tag)) {
-			log_error("Failed to remove tag %s from volume group "
-				  "%s", tag, vg->name);
-			return ECMD_FAILED;
-		}
+	if (!vg_change_tag(vg, tag, arg == addtag_ARG)) {
+		stack;
+		return ECMD_FAILED;
 	}
 
 	if (!vg_write(vg) || !vg_commit(vg)) {


