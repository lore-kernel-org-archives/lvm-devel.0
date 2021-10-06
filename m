From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  6 Oct 2021 13:47:56 +0000 (GMT)
Subject: main - cleanup: use dm_list_empty
Message-ID: <20211006134756.9934C3857C71@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3cf97a737bb5eb4cd456b894b1e675291f459129
Commit:        3cf97a737bb5eb4cd456b894b1e675291f459129
Parent:        197f6aaad71b6da801ba02b53c65f99b98a15991
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 1 14:30:49 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 6 15:43:31 2021 +0200

cleanup: use dm_list_empty

Instant check for 'dm_list_size() == 0' without any size calc.
---
 lib/metadata/metadata.c   | 2 +-
 lib/metadata/raid_manip.c | 2 +-
 tools/reporter.c          | 2 +-
 tools/toollib.c           | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 8dcdd919c..5fa623ec9 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2739,7 +2739,7 @@ int vg_validate(struct volume_group *vg)
 			continue;
 		}
 
-		if (!hlv->indirect_origin && !dm_list_size(&hlv->indirect_glvs)) {
+		if (!hlv->indirect_origin && dm_list_empty(&hlv->indirect_glvs)) {
 			log_error(INTERNAL_ERROR "Historical LV %s is not part of any LV chain in VG %s", hlv->name, vg->name);
 			r = 0;
 			continue;
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 60a10332e..0e6a77bac 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6963,7 +6963,7 @@ try_again:
 	 */
 	if (!_raid_extract_images(lv, force,
 				  raid_seg->area_count - match_count,
-				  (partial_segment_removed || !dm_list_size(remove_pvs)) ?
+				  (partial_segment_removed || dm_list_empty(remove_pvs)) ?
 				  &lv->vg->pvs : remove_pvs, 0,
 				  &old_lvs, &old_lvs)) {
 		log_error("Failed to remove the specified images from %s.",
diff --git a/tools/reporter.c b/tools/reporter.c
index 54a538d04..eafba4fec 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -1203,7 +1203,7 @@ static int _full_report_single(struct cmd_context *cmd,
 	int orphan = is_orphan_vg(vg->name);
 	int r = ECMD_FAILED;
 
-	if (orphan && !dm_list_size(&vg->pvs))
+	if (orphan && dm_list_empty(&vg->pvs))
 		return ECMD_PROCESSED;
 
 	args->full_report_vg = vg;
diff --git a/tools/toollib.c b/tools/toollib.c
index 7e35f6f22..357c9f8b8 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3172,7 +3172,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	log_set_report_object_name_and_id(NULL, NULL);
 
 	if (handle->include_historical_lvs && !tags_supplied) {
-		if (!dm_list_size(&_historical_lv.segments))
+		if (dm_list_empty(&_historical_lv.segments))
 			dm_list_add(&_historical_lv.segments, &_historical_lv_segment.list);
 		_historical_lv.vg = vg;
 


