From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 31 Oct 2009 17:30:52 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20091031173052.10444.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-10-31 17:30:52

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : vgchange.c 

Log message:
	Add vg_set_clustered() - move logic from vgchange.
	
	Similar to other vg_set_* functions, we create a vg_set_clustered() function
	which does a few checks and sets a flag.  This is where we check for
	any limitations of clusters.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.118&r2=1.119
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.292&r2=1.293
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89

--- LVM2/lib/metadata/metadata-exported.h	2009/10/31 17:26:13	1.118
+++ LVM2/lib/metadata/metadata-exported.h	2009/10/31 17:30:52	1.119
@@ -462,6 +462,7 @@
 int vg_set_max_lv(struct volume_group *vg, uint32_t max_lv);
 int vg_set_max_pv(struct volume_group *vg, uint32_t max_pv);
 int vg_set_alloc_policy(struct volume_group *vg, alloc_policy_t alloc);
+int vg_set_clustered(struct volume_group *vg, int clustered);
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 		  struct volume_group *vg_to);
 
--- LVM2/lib/metadata/metadata.c	2009/10/31 17:26:13	1.292
+++ LVM2/lib/metadata/metadata.c	2009/10/31 17:30:52	1.293
@@ -1127,6 +1127,26 @@
 	return 1;
 }
 
+int vg_set_clustered(struct volume_group *vg, int clustered)
+{
+	struct lv_list *lvl;
+	if (clustered) {
+		dm_list_iterate_items(lvl, &vg->lvs) {
+			if (lv_is_origin(lvl->lv) || lv_is_cow(lvl->lv)) {
+				log_error("Volume group %s contains snapshots "
+					  "that are not yet supported.",
+					  vg->name);
+				return 0;
+			}
+		}
+	}
+
+	if (clustered)
+		vg->status |= CLUSTERED;
+	else
+		vg->status &= ~CLUSTERED;
+	return 1;
+}
 
 /*
  * Separate metadata areas after splitting a VG.
--- LVM2/tools/vgchange.c	2009/09/30 12:05:25	1.88
+++ LVM2/tools/vgchange.c	2009/10/31 17:30:52	1.89
@@ -245,7 +245,6 @@
 			       struct volume_group *vg)
 {
 	int clustered = !strcmp(arg_str_value(cmd, clustered_ARG, "n"), "y");
-	struct lv_list *lvl;
 
 	if (clustered && (vg_is_clustered(vg))) {
 		log_error("Volume group \"%s\" is already clustered",
@@ -259,26 +258,13 @@
 		return ECMD_FAILED;
 	}
 
-	if (clustered) {
-		dm_list_iterate_items(lvl, &vg->lvs) {
-			if (lv_is_origin(lvl->lv) || lv_is_cow(lvl->lv)) {
-				log_error("Volume group %s contains snapshots "
-					  "that are not yet supported.",
-					  vg->name);
-				return ECMD_FAILED;
-			}
-		}
-	}
-
 	if (!archive(vg)) {
 		stack;
 		return ECMD_FAILED;
 	}
 
-	if (clustered)
-		vg->status |= CLUSTERED;
-	else
-		vg->status &= ~CLUSTERED;
+	if (!vg_set_clustered(vg, clustered))
+		return ECMD_FAILED;
 
 	if (!vg_write(vg) || !vg_commit(vg)) {
 		stack;


