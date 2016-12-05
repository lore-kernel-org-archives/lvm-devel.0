From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  5 Dec 2016 16:15:05 +0000 (UTC)
Subject: master - lv: always check status type
Message-ID: <20161205161505.D0B9D60243@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=325c2c5687e42afd2c8611e4cefd73f4fb7fb6ed
Commit:        325c2c5687e42afd2c8611e4cefd73f4fb7fb6ed
Parent:        6a450952add6bc389537aec23fc727ef6e156671
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 1 10:43:55 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 5 17:03:38 2016 +0100

lv: always check status type

Always validate status type has an expected value,
before accessing status struct members.
---
 WHATS_NEW           |    1 +
 lib/metadata/lv.c   |   33 ++++++++++++++++-----------------
 lib/report/report.c |   12 ++++++++----
 3 files changed, 25 insertions(+), 21 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 541e3ec..fbf4f61 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Test segment type before accessing segment members when checking status.
   Implement compatible target function for stripe segment.
   Use status info to report merge failed and snapshot invalid lvs fields.
 
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 14370bb..eb5066a 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1184,7 +1184,8 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 	if (lv_is_historical(lv)) {
 		repstr[4] = 'h';
 		repstr[5] = '-';
-	} else if (!activation() || !lvdm->info_ok) {
+	} else if (!activation() || !lvdm->info_ok ||
+		   (lvdm->seg_status.type == SEG_STATUS_UNKNOWN)) {
 		repstr[4] = 'X';		/* Unknown */
 		repstr[5] = 'X';		/* Unknown */
 	} else if (lvdm->info.exists) {
@@ -1216,8 +1217,10 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 		/* 'c' when cache/thin-pool is active with needs_check flag
 		 * 'C' for suspend */
 		if ((lv_is_thin_pool(lv) &&
+		     (lvdm->seg_status.type == SEG_STATUS_THIN_POOL) &&
 		     lvdm->seg_status.thin_pool->needs_check) ||
 		    (lv_is_cache(lv) &&
+		     (lvdm->seg_status.type == SEG_STATUS_CACHE) &&
 		     lvdm->seg_status.cache->needs_check))
 			repstr[4] = lvdm->info.suspended ? 'C' : 'c';
 
@@ -1259,6 +1262,10 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 		repstr[7] = '-';
 
 	repstr[8] = '-';
+	/* TODO: also convert raid health
+	 * lv_is_raid_type() is to wide
+	 * NOTE: snapshot origin is 'mostly' showing it's layered status
+	 */
 	if (lv_is_partial(lv))
 		repstr[8] = 'p';
 	else if (lv_is_raid_type(lv)) {
@@ -1272,31 +1279,23 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 				repstr[8] = 'm';  /* RAID has 'm'ismatches */
 		} else if (lv->status & LV_WRITEMOSTLY)
 			repstr[8] = 'w';  /* sub-LV has 'w'ritemostly */
-	} else if (lv_is_cache(lv) &&
-		   (lvdm->seg_status.type != SEG_STATUS_NONE)) {
-		if (lvdm->seg_status.type == SEG_STATUS_UNKNOWN)
-			repstr[8] = 'X'; /* Unknown */
-		else if (lvdm->seg_status.cache->fail)
+	} else if (lvdm->seg_status.type == SEG_STATUS_CACHE) {
+		if (lvdm->seg_status.cache->fail)
 			repstr[8] = 'F';
 		else if (lvdm->seg_status.cache->read_only)
 			repstr[8] = 'M';
-	} else if (lv_is_thin_pool(lv) &&
-		   (lvdm->seg_status.type != SEG_STATUS_NONE)) {
-		if (lvdm->seg_status.type == SEG_STATUS_UNKNOWN)
-			repstr[8] = 'X'; /* Unknown */
-		else if (lvdm->seg_status.thin_pool->fail)
+	} else if (lvdm->seg_status.type == SEG_STATUS_THIN_POOL) {
+		if (lvdm->seg_status.thin_pool->fail)
 			repstr[8] = 'F';
 		else if (lvdm->seg_status.thin_pool->out_of_data_space)
 			repstr[8] = 'D';
 		else if (lvdm->seg_status.thin_pool->read_only)
 			repstr[8] = 'M';
-	} else if (lv_is_thin_volume(lv) &&
-		   (lvdm->seg_status.type != SEG_STATUS_NONE)) {
-		if (lvdm->seg_status.type == SEG_STATUS_UNKNOWN)
-			repstr[8] = 'X'; /* Unknown */
-		else if (lvdm->seg_status.thin->fail)
+	} else if (lvdm->seg_status.type == SEG_STATUS_THIN) {
+		if (lvdm->seg_status.thin->fail)
 			repstr[8] = 'F';
-	}
+	} else if (lvdm->seg_status.type == SEG_STATUS_UNKNOWN)
+		repstr[8] = 'X'; /* Unknown */
 
 	if (lv->status & LV_ACTIVATION_SKIP)
 		repstr[9] = 'k';
diff --git a/lib/report/report.c b/lib/report/report.c
index 358ae94..702befb 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2936,12 +2936,16 @@ static int _metadatapercent_disp(struct dm_report *rh,
 				 const void *data, void *private)
 {
 	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
-	dm_percent_t percent = DM_PERCENT_INVALID;
+	dm_percent_t percent;
 
-	if (lv_is_thin_pool(lvdm->lv) ||
-	    lv_is_cache(lvdm->lv) ||
-	    lv_is_used_cache_pool(lvdm->lv))
+	switch (lvdm->seg_status.type) {
+	case SEG_STATUS_CACHE:
+	case SEG_STATUS_THIN_POOL:
 		percent = lvseg_percent_with_info_and_seg_status(lvdm, PERCENT_GET_METADATA);
+		break;
+	default:
+                percent = DM_PERCENT_INVALID;
+	}
 
 	return dm_report_field_percent(rh, field, &percent);
 }


