From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  6 Oct 2021 13:47:55 +0000 (GMT)
Subject: main - cleanup: skip zeroing buffer overwritten by memcpy
Message-ID: <20211006134755.79ABE385BF9D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=197f6aaad71b6da801ba02b53c65f99b98a15991
Commit:        197f6aaad71b6da801ba02b53c65f99b98a15991
Parent:        79e65a3596dc4fef1d7ac74fe727e9c24a539afb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 1 14:25:59 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 6 15:43:31 2021 +0200

cleanup: skip zeroing buffer overwritten by memcpy

Since the buffer is going to be overwritten by memcpy, reset only last
char to 0.

Also more use of DM_LIST_INIT list.h macro.
---
 lib/format_text/format-text.c |  7 ++++---
 lib/metadata/metadata.c       | 33 ++++++++++++++++-----------------
 2 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 6a4cc98d8..654c387bf 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1988,7 +1988,7 @@ static int _text_pv_setup(const struct format_type *fmt,
 			  struct physical_volume *pv,
 			  struct volume_group *vg)
 {
-	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
+	char pvid[ID_LEN + 1] __attribute__((aligned(8)));
 	struct format_instance *fid = pv->fid;
 	struct lvmcache_info *info;
 	unsigned mda_index;
@@ -1997,6 +1997,7 @@ static int _text_pv_setup(const struct format_type *fmt,
 	uint64_t pe_count;
 	uint64_t size_reduction = 0;
 
+	pvid[ID_LEN] = 0;
 	if (*pv->old_id.uuid)
 		memcpy(pvid, &pv->old_id.uuid, ID_LEN);
 	else
@@ -2167,7 +2168,7 @@ static int _add_metadata_area_to_pv(struct physical_volume *pv,
 				    uint64_t mda_size,
 				    unsigned mda_ignored)
 {
-	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
+	char pvid[ID_LEN + 1] __attribute__((aligned(8)));
 	struct metadata_area *mda;
 	struct mda_context *mdac;
 	struct mda_lists *mda_lists = (struct mda_lists *) pv->fmt->private;
@@ -2202,6 +2203,7 @@ static int _add_metadata_area_to_pv(struct physical_volume *pv,
 	memset(&mdac->rlocn, 0, sizeof(mdac->rlocn));
 	mda_set_ignored(mda, mda_ignored);
 
+	pvid[ID_LEN] = 0;
 	memcpy(pvid, &pv->id.uuid, ID_LEN);
 
 	fid_add_mda(pv->fid, mda, pvid, ID_LEN, mda_index);
@@ -2675,4 +2677,3 @@ int text_wipe_outdated_pv_mda(struct cmd_context *cmd, struct device *dev,
 
 	return 1;
 }
-
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ad908634a..8dcdd919c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -275,12 +275,13 @@ void add_pvl_to_vgs(struct volume_group *vg, struct pv_list *pvl)
 
 void del_pvl_from_vgs(struct volume_group *vg, struct pv_list *pvl)
 {
-	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
+	char pvid[ID_LEN + 1] __attribute__((aligned(8)));
 	struct lvmcache_info *info;
 
 	vg->pv_count--;
 	dm_list_del(&pvl->list);
 
+	pvid[ID_LEN] = 0;
 	memcpy(pvid, &pvl->pv->id.uuid, ID_LEN);
 
 	pvl->pv->vg = vg->fid->fmt->orphan_vg; /* orphan */
@@ -2840,8 +2841,8 @@ static int _handle_historical_lvs(struct volume_group *vg)
 
 static void _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg)
 {
-	char vgid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
-	struct dm_list devs;
+	char vgid[ID_LEN + 1] __attribute__((aligned(8)));
+	DM_LIST_INIT(devs);
 	struct dm_list *mdas = NULL;
 	struct device_list *devl;
 	struct device *dev;
@@ -2850,8 +2851,6 @@ static void _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg)
 	struct lvmcache_info *info;
 	uint32_t ext_flags;
 
-	dm_list_init(&devs);
-
 	/*
 	 * When vg_read selected a good copy of the metadata, it used it to
 	 * update the lvmcache representation of the VG (lvmcache_update_vg).
@@ -2859,6 +2858,7 @@ static void _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg)
 	 * vginfo->outdated_infos list.  Here we clear the PVs on that list.
 	 */
 
+	vgid[ID_LEN] = 0;
 	memcpy(vgid, &vg->id.uuid, ID_LEN);
 
 	lvmcache_get_outdated_devs(cmd, vg->name, vgid, &devs);
@@ -2910,7 +2910,7 @@ static void _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg)
  */
 int vg_write(struct volume_group *vg)
 {
-	char vgid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
+	char vgid[ID_LEN + 1] __attribute__((aligned(8)));
 	struct dm_list *mdah;
 	struct pv_list *pvl, *pvl_safe, *new_pvl;
 	struct metadata_area *mda;
@@ -2918,6 +2918,7 @@ int vg_write(struct volume_group *vg)
 	struct device *mda_dev;
 	int revert = 0, wrote = 0;
 
+	vgid[ID_LEN] = 0;
 	memcpy(vgid, &vg->id.uuid, ID_LEN);
 
 	if (vg_is_shared(vg)) {
@@ -3098,13 +3099,12 @@ int vg_write(struct volume_group *vg)
 static int _vg_commit_mdas(struct volume_group *vg)
 {
 	struct metadata_area *mda, *tmda;
-	struct dm_list ignored;
+	DM_LIST_INIT(ignored);
 	int failed = 0;
 	int good = 0;
 	int cache_updated = 0;
 
 	/* Rearrange the metadata_areas_in_use so ignored mdas come first. */
-	dm_list_init(&ignored);
 	dm_list_iterate_items_safe(mda, tmda, &vg->fid->metadata_areas_in_use)
 		if (mda_is_ignored(mda))
 			dm_list_move(&ignored, &mda->list);
@@ -3437,13 +3437,14 @@ static int _check_devs_used_correspond_with_lv(struct dm_pool *mem, struct dm_li
 static int _check_devs_used_correspond_with_vg(struct volume_group *vg)
 {
 	struct dm_pool *mem;
-	char vgid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
+	char vgid[ID_LEN + 1] __attribute__((aligned(8)));
 	struct pv_list *pvl;
 	struct lv_list *lvl;
 	struct dm_list *list;
 	struct device_list *dl;
 	int found_inconsistent = 0;
 
+	vgid[ID_LEN] = 0;
 	memcpy(vgid, &vg->id.uuid, ID_LEN);
 
 	/* Mark all PVs in VG as used. */
@@ -3503,7 +3504,7 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 					struct volume_group *vg,
 					struct lvmcache_info *info)
 {
-	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
+	char pvid[ID_LEN + 1] __attribute__((aligned(8)));
 	struct physical_volume *pv;
 	struct device *dev = lvmcache_device(info);
 
@@ -3527,6 +3528,7 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 	if (!alloc_pv_segment_whole_pv(vg->vgmem, pv))
 		goto_bad;
 
+	pvid[ID_LEN] = 0;
 	memcpy(pvid, &pv->id.uuid, ID_LEN);
 
 	lvmcache_fid_add_mdas(info, vg->fid, pvid, ID_LEN);
@@ -4448,14 +4450,13 @@ int vg_is_foreign(struct volume_group *vg)
 
 void vg_write_commit_bad_mdas(struct cmd_context *cmd, struct volume_group *vg)
 {
-	char vgid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
-	struct dm_list bad_mda_list;
+	char vgid[ID_LEN + 1] __attribute__((aligned(8)));
+	DM_LIST_INIT(bad_mda_list);
 	struct mda_list *mdal;
 	struct metadata_area *mda;
 	struct device *dev;
 
-	dm_list_init(&bad_mda_list);
-
+	vgid[ID_LEN] = 0;
 	memcpy(vgid, &vg->id.uuid, ID_LEN);
 
 	lvmcache_get_bad_mdas(cmd, vg->name, vgid, &bad_mda_list);
@@ -4544,7 +4545,7 @@ void vg_write_commit_bad_mdas(struct cmd_context *cmd, struct volume_group *vg)
 
 static bool _scan_text_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid)
 {
-	struct dm_list mda_list;
+	DM_LIST_INIT(mda_list);
 	struct mda_list *mdal, *safe;
 	struct metadata_area *mda;
 	struct mda_context *mdac;
@@ -4560,8 +4561,6 @@ static bool _scan_text_mismatch(struct cmd_context *cmd, const char *vgname, con
 	 * else check that all mda_headers are unchanged.
 	 */
 
-	dm_list_init(&mda_list);
-
 	lvmcache_get_mdas(cmd, vgname, vgid, &mda_list);
 
 	dm_list_iterate_items(mdal, &mda_list) {


