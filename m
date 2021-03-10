From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 23:19:32 +0000 (GMT)
Subject: main - cleanup: eliminate unused assign
Message-ID: <20210310231932.CEE2A3857C5E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c4f5d9312283b5a096c99d4ccd28b89cbf89b1e7
Commit:        c4f5d9312283b5a096c99d4ccd28b89cbf89b1e7
Parent:        d86e943b80a94427bc2cd9deed151dd84c74ffbe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 10 14:12:17 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 11 00:18:01 2021 +0100

cleanup: eliminate unused assign

---
 lib/datastruct/str_list.c |  2 +-
 lib/metadata/raid_manip.c | 10 +++++-----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/datastruct/str_list.c b/lib/datastruct/str_list.c
index efbdeda64..b8b340307 100644
--- a/lib/datastruct/str_list.c
+++ b/lib/datastruct/str_list.c
@@ -218,7 +218,7 @@ struct dm_list *str_to_str_list(struct dm_pool *mem, const char *str,
 		return NULL;
 	}
 
-	p1 = p2 = str;
+	p1 = str;
 	while (*p1) {
 		if (!(p2 = strstr(p1, delim)))
 			next = p2 = str + strlen(str);
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 9c57e8b88..a43e36141 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -584,18 +584,18 @@ static int _lv_update_reload_fns_reset_eliminate_lvs(struct logical_volume *lv,
 		 * Returning 2 from pre function -> lv is suspended and
 		 * metadata got updated, don't need to do it again
 		 */
-		if (!(r = (origin_only ? resume_lv_origin(lv->vg->cmd, lock_lv) :
-					 resume_lv(lv->vg->cmd, lock_lv)))) {
+		if (!(origin_only ? resume_lv_origin(lv->vg->cmd, lock_lv) :
+					 resume_lv(lv->vg->cmd, lock_lv))) {
 			log_error("Failed to resume %s.", display_lvname(lv));
 			return 0;
 		}
 
 	/* Update metadata and reload mappings including flags (e.g. LV_REBUILD, LV_RESHAPE_DELTA_DISKS_PLUS) */
-	} else if (!(r = (origin_only ? lv_update_and_reload_origin(lv) : lv_update_and_reload(lv))))
+	} else if (!(origin_only ? lv_update_and_reload_origin(lv) : lv_update_and_reload(lv)))
 		return_0;
 
 	/* Eliminate any residual LV and don't commit the metadata */
-	if (!(r = _eliminate_extracted_lvs_optional_write_vg(lv->vg, removal_lvs, 0)))
+	if (!_eliminate_extracted_lvs_optional_write_vg(lv->vg, removal_lvs, 0))
 		return_0;
 
 	/*
@@ -620,7 +620,7 @@ static int _lv_update_reload_fns_reset_eliminate_lvs(struct logical_volume *lv,
 	/* Update and reload to clear out reset flags in the metadata and in the kernel */
 	log_debug_metadata("Updating metadata mappings for %s.", display_lvname(lv));
 	if ((r != 2 || flags_reset) &&
-	    !(r = (origin_only ? lv_update_and_reload_origin(lv) : lv_update_and_reload(lv))))
+	    !(origin_only ? lv_update_and_reload_origin(lv) : lv_update_and_reload(lv)))
 		return_0;
 
 	return 1;


