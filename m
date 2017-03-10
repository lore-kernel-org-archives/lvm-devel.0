From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:37:15 -0500
Subject: master - cache: validation for cache_metadata_format
Message-ID: <201703101837.v2AIbFcw009799@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=64d3f05aa1ee22cb337d5d8e9d650cb02040543a
Commit:        64d3f05aa1ee22cb337d5d8e9d650cb02040543a
Parent:        825c16e57e0e05bbffda9a32ea245c0e6acfb081
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 26 21:22:43 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:01 2017 +0100

cache: validation for cache_metadata_format

Only  cache-pool segtype may store cache_metadata_format.
Only supported values are 0,1,2
Format 2 requires LV status uses LV_METADATA_FORMAT.
Format 0 (unselected) or 1 shall not set this 'incompatible' status.
---
 lib/metadata/merge.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index a5cb9f3..3d82a05 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -328,6 +328,13 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 
 	if (seg_is_cache_pool(seg)) {
 		if (!dm_list_empty(&seg->lv->segs_using_this_lv)) {
+			switch (seg->cache_metadata_format) {
+			case CACHE_METADATA_FORMAT_2:
+			case CACHE_METADATA_FORMAT_1:
+				break;
+			default:
+				seg_error("has invalid cache metadata format");
+			}
 			switch (seg->cache_mode) {
 			case CACHE_MODE_WRITETHROUGH:
 			case CACHE_MODE_WRITEBACK:
@@ -341,13 +348,22 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 		}
 		if (!validate_cache_chunk_size(lv->vg->cmd, seg->chunk_size))
 			seg_error("has invalid chunk size.");
+		if (seg->lv->status & LV_METADATA_FORMAT) {
+			if (seg->cache_metadata_format != CACHE_METADATA_FORMAT_2)
+				seg_error("sets METADATA_FORMAT flag");
+		} else if (seg->cache_metadata_format == CACHE_METADATA_FORMAT_2)
+			seg_error("is missing METADATA_FORMAT flag");
 	} else { /* !cache_pool */
+		if (seg->cache_metadata_format)
+			seg_error("sets cache metadata format");
 		if (seg->cache_mode)
 			seg_error("sets cache mode");
 		if (seg->policy_name)
 			seg_error("sets policy name");
 		if (seg->policy_settings)
 			seg_error("sets policy settings");
+		if (seg->lv->status & LV_METADATA_FORMAT)
+			seg_error("sets METADATA_FORMAT flag");
 	}
 
 	if (!seg_can_error_when_full(seg) && lv_is_error_when_full(lv))


