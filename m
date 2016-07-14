From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 14 Jul 2016 13:21:17 +0000 (UTC)
Subject: master - macros: Add lv_is_not_synced.
Message-ID: <20160714132117.7BA5560C5B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5af311ddd8f5c03839b1c2a8feff5eb8dfde5606
Commit:        5af311ddd8f5c03839b1c2a8feff5eb8dfde5606
Parent:        07be2b864f131f2ec48fe2a22e0a50ea76dd5a70
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jul 14 14:21:01 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jul 14 14:21:01 2016 +0100

macros: Add lv_is_not_synced.

---
 lib/metadata/lv.c                |    4 ++--
 lib/metadata/lv_manip.c          |    2 +-
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/raid_manip.c        |    2 +-
 lib/report/report.c              |    2 +-
 tools/lvchange.c                 |    2 +-
 tools/lvconvert.c                |    2 +-
 7 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index e7a56cf..9ee67b4 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1140,9 +1140,9 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 	else if (lv_is_cache_type(lv))
 		repstr[0] = 'C';
 	else if (lv_is_raid(lv))
-		repstr[0] = (lv->status & LV_NOTSYNCED) ? 'R' : 'r';
+		repstr[0] = (lv_is_not_synced(lv)) ? 'R' : 'r';
 	else if (lv_is_mirror(lv))
-		repstr[0] = (lv->status & LV_NOTSYNCED) ? 'M' : 'm';
+		repstr[0] = (lv_is_not_synced(lv)) ? 'M' : 'm';
 	else if (lv_is_thin_volume(lv))
 		repstr[0] = lv_is_merging_origin(lv) ?
 			'O' : (lv_is_merging_thin_snapshot(lv) ? 'S' : 'V');
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a47bd16..c6b8eb5 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4027,7 +4027,7 @@ int lv_extend(struct logical_volume *lv,
 		 */
 		if (old_extents &&
 		    segtype_is_mirrored(segtype) &&
-		    (lv->status & LV_NOTSYNCED)) {
+		    (lv_is_not_synced(lv))) {
 			dm_percent_t sync_percent = DM_PERCENT_INVALID;
 
 			if (!lv_is_active_locally(lv)) {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 84b510b..37d4bf8 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -218,6 +218,7 @@
 #define lv_is_mirror_log(lv)	(((lv)->status & MIRROR_LOG) ? 1 : 0)
 #define lv_is_mirror(lv)	(((lv)->status & MIRROR) ? 1 : 0)
 #define lv_is_mirror_type(lv)	(((lv)->status & (MIRROR | MIRROR_LOG | MIRROR_IMAGE)) ? 1 : 0)
+#define lv_is_not_synced(lv)	(((lv)->status & LV_NOTSYNCED) ? 1 : 0)
 
 #define lv_is_pending_delete(lv) (((lv)->status & LV_PENDING_DELETE) ? 1 : 0)
 #define lv_is_error_when_full(lv) (((lv)->status & LV_ERROR_WHEN_FULL) ? 1 : 0)
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 2ef47b2..feb8d6e 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -590,7 +590,7 @@ static int _raid_add_images(struct logical_volume *lv,
 	struct lv_list *lvl;
 	struct lv_segment_area *new_areas;
 
-	if (lv->status & LV_NOTSYNCED) {
+	if (lv_is_not_synced(lv)) {
 		log_error("Can't add image to out-of-sync RAID LV:"
 			  " use 'lvchange --resync' first.");
 		return 0;
diff --git a/lib/report/report.c b/lib/report/report.c
index 512986e..fab6379 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3161,7 +3161,7 @@ static int _lvinitialimagesync_disp(struct dm_report *rh, struct dm_pool *mem,
 	int initial_image_sync;
 
 	if (lv_is_raid(lv) || lv_is_mirrored(lv))
-		initial_image_sync = (lv->status & LV_NOTSYNCED) == 0;
+		initial_image_sync = !lv_is_not_synced(lv);
 	else
 		initial_image_sync = 0;
 
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 4b02ba9..9194cd6 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -404,7 +404,7 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 	 * worry about persistent logs.
 	 */
 	if (!seg_is_raid(seg) && !seg->log_lv) {
-		if (lv->status & LV_NOTSYNCED) {
+		if (lv_is_not_synced(lv)) {
 			lv->status &= ~LV_NOTSYNCED;
 			log_very_verbose("Updating logical volume %s on disk(s).",
 					 display_lvname(lv));
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index b8c1959..0368e84 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1418,7 +1418,7 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 	 * Up-convert m-way mirror to n-way mirror
 	 */
 	if (new_mimage_count > old_mimage_count) {
-		if (lv->status & LV_NOTSYNCED) {
+		if (lv_is_not_synced(lv)) {
 			log_error("Can't add mirror to out-of-sync mirrored "
 				  "LV: use lvchange --resync first.");
 			return 0;


