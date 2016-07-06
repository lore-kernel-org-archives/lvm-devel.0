From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  6 Jul 2016 15:12:04 +0000 (UTC)
Subject: master - coverity: Fixes for recent changes.
Message-ID: <20160706151204.A029561370@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c1a66d4fc6cd2224e3bf1f2cd08f4ee89b4ea920
Commit:        c1a66d4fc6cd2224e3bf1f2cd08f4ee89b4ea920
Parent:        a497b95db15a24c82f29fd8b00de5fbd1e56b1c5
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jul 6 16:09:32 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jul 6 16:09:32 2016 +0100

coverity: Fixes for recent changes.

---
 lib/cache/lvmetad.c       |    5 +++--
 lib/metadata/raid_manip.c |   26 ++++++++++++++++++++------
 2 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 476448d..1fecb5e 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -879,7 +879,8 @@ static int _pv_populate_lvmcache(struct cmd_context *cmd,
 		if (!id_read_format(&vgid, vgid_txt))
 			return_0;
 	} else
-		strcpy((char*)&vgid, fmt->orphan_vg_name);
+		/* NB uuid is short and NUL-terminated. */
+		(void) dm_strncpy((char*)&vgid, fmt->orphan_vg_name, sizeof(vgid));
 
 	if (!vgname)
 		vgname = fmt->orphan_vg_name;
@@ -1245,7 +1246,7 @@ int lvmetad_vg_update_finish(struct volume_group *vg)
 		dm_hash_get_first(vg->fid->metadata_areas_index) : NULL;
 	while (n) {
 		mda = dm_hash_get_data(vg->fid->metadata_areas_index, n);
-		strcpy(mda_id, dm_hash_get_key(vg->fid->metadata_areas_index, n));
+		(void) dm_strncpy(mda_id, dm_hash_get_key(vg->fid->metadata_areas_index, n), sizeof(mda_id));
 		if ((num = strchr(mda_id, '_'))) {
 			*num = 0;
 			++num;
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 26b2645..b67380f 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1578,7 +1578,12 @@ static uint32_t _min_sublv_area_at_le(struct lv_segment *seg, uint32_t area_le)
 
 	/* Find smallest segment of each of the data image LVs at offset area_le */
 	for (s = 0; s < seg->area_count; s++) {
-		seg1 = find_seg_by_le(seg_lv(seg, s), area_le);
+		if (!(seg1 = find_seg_by_le(seg_lv(seg, s), area_le))) {
+			log_error("Failed to find segment for %s extent %" PRIu32,
+				  seg_lv(seg, s)->name, area_le);
+			return 0;
+		}
+
 		area_len = min(area_len, seg1->len);
 	}
 
@@ -1734,7 +1739,8 @@ static int _raid0_to_striped_retrieve_segments_and_lvs(struct logical_volume *lv
 	 */
 	area_le = le = 0;
 	while (le < lv->le_count) {
-		area_len = _min_sublv_area_at_le(seg, area_le);
+		if (!(area_len = _min_sublv_area_at_le(seg, area_le)))
+			return_0;
 		area_le += area_len;
 
 		if (!_split_area_lvs_segments(seg, area_le) ||
@@ -1748,7 +1754,11 @@ static int _raid0_to_striped_retrieve_segments_and_lvs(struct logical_volume *lv
 	area_le = 0;
 	dm_list_iterate_items(seg_to, &new_segments) {
 		for (s = 0; s < seg->area_count; s++) {
-			data_seg = find_seg_by_le(seg_lv(seg, s), area_le);
+			if (!(data_seg = find_seg_by_le(seg_lv(seg, s), area_le))) {
+				log_error("Failed to find segment for %s extent %" PRIu32,
+					  seg_lv(seg, s)->name, area_le);
+				return 0;
+			}
 
 			/* Move the respective area across to our new segments area */
 			if (!move_lv_segment_area(seg_to, s, data_seg, 0))
@@ -1816,10 +1826,14 @@ static int _eliminate_extracted_lvs_optional_write_vg(struct volume_group *vg,
 	if (!_deactivate_and_remove_lvs(vg, removal_lvs))
 		return_0;
 
-	dm_list_init(removal_lvs);
-
 	/* Wait for events following any deactivation. */
-	sync_local_dev_names(vg->cmd);
+	if (!sync_local_dev_names(vg->cmd)) {
+		log_error("Failed to sync local devices after removing %u LVs in VG %s.",
+			  dm_list_size(removal_lvs), vg->name);
+		return 0;
+	}
+
+	dm_list_init(removal_lvs);
 
 	if (vg_write_requested && !_vg_write_commit_backup(vg))
 		return_0;


