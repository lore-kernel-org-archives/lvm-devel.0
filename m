From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Jul 2013 16:26:29 +0000 (UTC)
Subject: master - cleanup: use dm_list_empty
Message-ID: <20130718162629.1B5716073F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=20187fc190c248c556fdc44f5651eaa99219d2fb
Commit:        20187fc190c248c556fdc44f5651eaa99219d2fb
Parent:        8bd67f9e5a3d53d78c83d7c554db300d6f82b97c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 17 14:49:21 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 18 18:22:42 2013 +0200

cleanup: use dm_list_empty

Check for empty list directly.
---
 lib/format_text/archiver.c |    2 +-
 lib/metadata/lv_manip.c    |    2 +-
 lib/metadata/metadata.c    |    6 +++---
 lib/metadata/pv_manip.c    |    4 ++--
 tools/toollib.c            |    2 +-
 5 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 1e6dbac..b6b9fb3 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -430,7 +430,7 @@ int backup_to_file(const char *file, const char *desc, struct volume_group *vg)
 		return 0;
 	}
 
-	if (!dm_list_size(&tf->metadata_areas_in_use)) {
+	if (dm_list_empty(&tf->metadata_areas_in_use)) {
 		log_error(INTERNAL_ERROR "No in use metadata areas to write.");
 		tf->fmt->ops->destroy_instance(tf);
 		return 0;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e95deca..0999bd0 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2411,7 +2411,7 @@ int lv_add_segment(struct alloc_handle *ah,
 		return 0;
 	}
 
-	if ((status & MIRROR_LOG) && dm_list_size(&lv->segments)) {
+	if ((status & MIRROR_LOG) && !dm_list_empty(&lv->segments)) {
 		log_error("Log segments can only be added to an empty LV");
 		return 0;
 	}
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 96e1355..c8d35c9 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1339,7 +1339,7 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	 * this means checking every VG by scanning every PV on the
 	 * system.
 	 */
-	if (pv && is_orphan(pv) && !dm_list_size(&pv->fid->metadata_areas_in_use)) {
+	if (pv && is_orphan(pv) && dm_list_empty(&pv->fid->metadata_areas_in_use)) {
 		free_pv_fid(pv);
 		if (!scan_vgs_for_pvs(cmd, 0))
 			return_0;
@@ -1831,7 +1831,7 @@ struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
 		goto bad;
 	}
 
-	if (is_orphan_vg(pv->vg_name) && !dm_list_size(&pv->fid->metadata_areas_in_use)) {
+	if (is_orphan_vg(pv->vg_name) && dm_list_empty(&pv->fid->metadata_areas_in_use)) {
 		/* If a PV has no MDAs - need to search all VGs for it */
 		if (!scan_vgs_for_pvs(cmd, 1))
 			goto_bad;
@@ -4527,7 +4527,7 @@ int mdas_empty_or_ignored(struct dm_list *mdas)
 {
 	struct metadata_area *mda;
 
-	if (!dm_list_size(mdas))
+	if (dm_list_empty(mdas))
 		return 1;
 	dm_list_iterate_items(mda, mdas) {
 		if (mda_is_ignored(mda))
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 2b16206..fb29ef4 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -687,8 +687,8 @@ static int pvremove_check(struct cmd_context *cmd, const char *name,
 	 * means checking every VG by scanning every
 	 * PV on the system.
 	 */
-	if (is_orphan(pv) && !dm_list_size(&pv->fid->metadata_areas_in_use) &&
-	    !dm_list_size(&pv->fid->metadata_areas_ignored)) {
+	if (is_orphan(pv) && dm_list_empty(&pv->fid->metadata_areas_in_use) &&
+	    dm_list_empty(&pv->fid->metadata_areas_ignored)) {
 		if (!scan_vgs_for_pvs(cmd, 0)) {
 			log_error("Rescan for PVs without metadata areas "
 				  "failed.");
diff --git a/tools/toollib.c b/tools/toollib.c
index 5db537f..ce449e7 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -770,7 +770,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 				 * PV on the system.
 				 */
 				if (!scanned && is_orphan(pv) &&
-				    !dm_list_size(&pv->fid->metadata_areas_in_use)) {
+				    dm_list_empty(&pv->fid->metadata_areas_in_use)) {
 					if (!scan_label_only &&
 					    !scan_vgs_for_pvs(cmd, 1)) {
 						stack;


