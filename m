From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  3 Oct 2012 13:14:43 +0000 (UTC)
Subject: master - liblvm: add lv_rename_update
Message-ID: <20121003131443.251602319@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=21c401006c3c12b75354736db9a2f75e7993f489
Commit:        21c401006c3c12b75354736db9a2f75e7993f489
Parent:        739092e64ac2776a0b0b0796349041b659d816b0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 27 09:48:25 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 3 15:03:49 2012 +0200

liblvm: add lv_rename_update

Support lv_rename without directly updating metatata.
It can save some metadata commits in some cases,
i.e. when LVs are offline.
---
 WHATS_NEW                        |    1 +
 lib/metadata/lv_manip.c          |   19 ++++++++++++++++---
 lib/metadata/metadata-exported.h |    2 ++
 3 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 45ce574..bc0c778 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Add internal lv_rename_update() to rename LV without updating mda.
   Ensure descriptors 0,1,2 are always available.
   Use /proc/self/fd for closing openned descriptors.
   Add missing pkg init with --enable-testing in configure.in (2.02.71).
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f2d99b8..eb5794c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2938,8 +2938,8 @@ int for_each_sub_lv(struct cmd_context *cmd, struct logical_volume *lv,
  * Core of LV renaming routine.
  * VG must be locked by caller.
  */
-int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
-	      const char *new_name)
+int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
+		     const char *new_name, int update_mda)
 {
 	struct volume_group *vg = lv->vg;
 	struct lv_names lv_names;
@@ -2964,7 +2964,7 @@ int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!archive(vg))
+	if (update_mda && !archive(vg))
 		return 0;
 
 	/* rename sub LVs */
@@ -2986,6 +2986,9 @@ int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 	if (lv_is_cow(lv) && lv_is_virtual_origin(lvl2.lv = origin_from_cow(lv)))
 		dm_list_add_h(&lvs_changed, &lvl2.list);
 
+	if (!update_mda)
+		return 1;
+
 	log_verbose("Writing out updated volume group");
 	if (!vg_write(vg))
 		return 0;
@@ -3009,6 +3012,16 @@ out:
 	return r;
 }
 
+/*
+ * Core of LV renaming routine.
+ * VG must be locked by caller.
+ */
+int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
+	      const char *new_name)
+{
+	return lv_rename_update(cmd, lv, new_name, 1);
+}
+
 char *generate_lv_name(struct volume_group *vg, const char *format,
 		       char *buffer, size_t len)
 {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0658fad..d149f95 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -560,6 +560,8 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 
 int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 	      const char *new_name);
+int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
+		     const char *new_name, int update_mda);
 
 uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 			   uint32_t extent_size);


