From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Mar 2021 14:46:56 +0000 (GMT)
Subject: main - cleanup: simpler checks first
Message-ID: <20210308144656.CABD33953420@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e5456c259f928c6e08ceecbd107796392e66325f
Commit:        e5456c259f928c6e08ceecbd107796392e66325f
Parent:        f4200acac23df573717b32a44e018b30b5a90a70
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 4 17:05:10 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 8 15:43:27 2021 +0100

cleanup: simpler checks first

Minor optimizatoins...
---
 lib/format_text/archiver.c    | 6 +++---
 lib/metadata/merge.c          | 2 +-
 lib/metadata/snapshot_manip.c | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 932f97da3..68117f7dc 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -103,13 +103,13 @@ static int _archive(struct volume_group *vg, int compulsory)
 {
 	char *desc;
 
+	if (vg_is_archived(vg))
+		return 1; /* VG has been already archived */
+
 	/* Don't archive orphan VGs. */
 	if (is_orphan_vg(vg->name))
 		return 1;
 
-	if (vg_is_archived(vg))
-		return 1; /* VG has been already archived */
-
 	if (!vg->cmd->archive_params->enabled || !vg->cmd->archive_params->dir) {
 		vg->status |= ARCHIVED_VG;
 		return 1;
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index eff59ae4b..f29cf64ec 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -371,7 +371,7 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 			seg_error("sets cleaner_policy");
 	}
 
-	if (lv_is_cache(lv) && seg->pool_lv && lv_is_cache_vol(seg->pool_lv)) {
+	if (seg->pool_lv && lv_is_cache(lv) && lv_is_cache_vol(seg->pool_lv)) {
 		cache_setting_seg = seg;
 		no_metadata_format = 1;
 	}
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 0f48e62e8..3ee5f4a86 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -31,7 +31,7 @@ int lv_is_origin(const struct logical_volume *lv)
 int lv_is_cow(const struct logical_volume *lv)
 {
 	/* Make sure a merging thin origin isn't confused as a cow LV */
-	return (!lv_is_thin_volume(lv) && !lv_is_origin(lv) && lv->snapshot) ? 1 : 0;
+	return (lv->snapshot && !lv_is_thin_volume(lv) && !lv_is_origin(lv)) ? 1 : 0;
 }
 
 struct logical_volume *find_cow(const struct logical_volume *snap)


