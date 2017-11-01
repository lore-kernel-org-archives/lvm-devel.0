From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 31 Oct 2017 20:02:19 -0400
Subject: master - cleanup: use segtype_is_raid_with_meta
Message-ID: <201711010002.vA102Joq010633@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7a394575fbb11aad1ad61f4caa8f16584ae45102
Commit:        7a394575fbb11aad1ad61f4caa8f16584ae45102
Parent:        7a28b243faf4fc57466beb138fe1017608bfa7b2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 31 23:16:13 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 1 00:59:22 2017 +0100

cleanup: use segtype_is_raid_with_meta

Replace with common macro.
---
 lib/metadata/lv_manip.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c4c2fdf..41b52ec 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -941,8 +941,7 @@ struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 		return_NULL;
 	}
 
-	if (segtype_is_raid(segtype) &&
-	    !segtype_is_raid0(segtype) &&
+	if (segtype_is_raid_with_meta(segtype) &&
 	    !(seg->meta_areas = dm_pool_zalloc(mem, areas_sz))) {
 		dm_pool_free(mem, seg); /* frees everything alloced since seg */
 		return_NULL;
@@ -3923,7 +3922,7 @@ static int _lv_insert_empty_sublvs(struct logical_volume *lv,
 			return_0;
 
 		/* Metadata LVs for raid */
-		if (segtype_is_raid(segtype) && !segtype_is_raid0(segtype)) {
+		if (segtype_is_raid_with_meta(segtype)) {
 			if (dm_snprintf(img_name, sizeof(img_name), "%s_rmeta_%u",
 					lv->name, i) < 0)
 				goto_bad;
@@ -4144,7 +4143,7 @@ int lv_extend(struct logical_volume *lv,
 		else if (segtype_is_raid0_meta(segtype))
 			/* Extend raid0 metadata LVs too */
 			log_count = stripes;
-		else if (segtype_is_raid(segtype) && !segtype_is_raid0(segtype))
+		else if (segtype_is_raid_with_meta(segtype))
 			log_count = mirrors * stripes;
 	}
 	/* FIXME log_count should be 1 for mirrors */
@@ -4171,7 +4170,7 @@ int lv_extend(struct logical_volume *lv,
 		return_0;
 
 	new_extents = ah->new_extents;
-	if (segtype_is_raid(segtype) && !segtype_is_raid0(segtype))
+	if (segtype_is_raid_with_meta(segtype))
 		new_extents -= ah->log_len * ah->area_multiple;
 
 	if (segtype_is_pool(segtype)) {


