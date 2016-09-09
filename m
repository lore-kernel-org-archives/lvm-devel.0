From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  9 Sep 2016 13:04:10 +0000 (UTC)
Subject: master - cache: report metadata percentage
Message-ID: <20160909130410.7E7D760DD8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4b22cd81e6b3b60f08976df4104b7411d1af4fc5
Commit:        4b22cd81e6b3b60f08976df4104b7411d1af4fc5
Parent:        a13440d7ca4268eeede9986223d31e33122e753a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 9 14:24:49 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 9 15:01:35 2016 +0200

cache: report metadata percentage

Reinstantiate reporting of metadata percent usage for cache volumes.
Also show the same percentage with hidden cache-pool LV.
This regression was caused by optimization for a single-ioctl in
2.02.155.
---
 WHATS_NEW                    |    1 +
 lib/metadata/segtype.h       |    1 +
 lib/report/report.c          |    1 +
 test/shell/lvcreate-cache.sh |   16 ++++++++++++++++
 tools/reporter.c             |   14 +++++++++++++-
 5 files changed, 32 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c594723..9584872 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.166 - 
 =====================================
+  Restore reporting of metadata usage for cache volumes (2.02.155).
   Support raid scrubbing on cache origin LV.
 
 Version 2.02.165 - 7th September 2016
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 2fafa19..9ca740d 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -153,6 +153,7 @@ struct dev_manager;
 #define seg_is_striped_target(seg)	segtype_is_striped_target((seg)->segtype)
 #define seg_is_cache(seg)	segtype_is_cache((seg)->segtype)
 #define seg_is_cache_pool(seg)	segtype_is_cache_pool((seg)->segtype)
+#define seg_is_used_cache_pool(seg) (seg_is_cache_pool(seg) && (!dm_list_empty(&(seg->lv)->segs_using_this_lv)))
 #define seg_is_linear(seg)	(seg_is_striped(seg) && ((seg)->area_count == 1))
 #define seg_is_mirror(seg)	segtype_is_mirror((seg)->segtype)
 #define seg_is_mirrored(seg)	segtype_is_mirrored((seg)->segtype)
diff --git a/lib/report/report.c b/lib/report/report.c
index ea36795..1ca4dfb 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2939,6 +2939,7 @@ static int _metadatapercent_disp(struct dm_report *rh,
 	dm_percent_t percent = DM_PERCENT_INVALID;
 
 	if (lv_is_thin_pool(lvdm->lv) ||
+	    lv_is_cache(lvdm->lv) ||
 	    lv_is_used_cache_pool(lvdm->lv))
 		percent = lvseg_percent_with_info_and_seg_status(lvdm, PERCENT_GET_METADATA);
 
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index fbea5b8..52d36a1 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -81,6 +81,22 @@ check lv_field $vg/pool7 segtype "cache-pool"
 lvremove -f $vg
 
 
+# Check the percentage values are reported for both cache and cache-pool
+lvcreate --type cache-pool  -L1 $vg/cpool
+lvcreate -H -L4 -n $lv1 $vg/cpool
+
+check lv_field $vg/$lv1 copy_percent "100.00"
+check lv_field $vg/$lv1 data_percent "0.00"
+check lv_field $vg/$lv1 metadata_percent "0.78"
+check lv_field $vg/cpool copy_percent "100.00"
+check lv_field $vg/cpool data_percent "0.00"
+check lv_field $vg/cpool metadata_percent "0.78"
+# check we also display percent value for segmented output (-o+devices)
+lvs -a -o+devices $vg/cpool | tee out
+grep "100.00" out
+lvremove -f $vg
+
+
 # Validate ambiguous pool name is detected
 invalid lvcreate -l 1 --type cache-pool --cachepool pool1 $vg/pool2
 invalid lvcreate -l 1 --type cache-pool --name pool3 --cachepool pool4 $vg
diff --git a/tools/reporter.c b/tools/reporter.c
index 0df22ff..b7a2f39 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -89,6 +89,12 @@ static int _vgs_single(struct cmd_context *cmd __attribute__((unused)),
 
 static void _choose_lv_segment_for_status_report(const struct logical_volume *lv, const struct lv_segment **lv_seg)
 {
+	if (lv_is_used_cache_pool(lv)) {
+		/* For a used cache pool, choose cache volume segment */
+		*lv_seg = get_only_segment_using_this_lv(lv);
+		return;
+	}
+
 	/*
 	 * By default, take the first LV segment to report status for.
 	 * If there's any other specific segment that needs to be
@@ -115,8 +121,9 @@ static int _do_info_and_status(struct cmd_context *cmd,
 	if (do_status) {
 		if (!(status->seg_status.mem = dm_pool_create("reporter_pool", 1024)))
 			return_0;
-		if (!lv_seg)
+		if (!lv_seg || seg_is_used_cache_pool(lv_seg))
 			_choose_lv_segment_for_status_report(lv, &lv_seg);
+
 		if (do_info) {
 			/* both info and status */
 			status->info_ok = lv_info_with_seg_status(cmd, lv, lv_seg, use_layer, status, 1, 1);
@@ -124,6 +131,11 @@ static int _do_info_and_status(struct cmd_context *cmd,
 			if (use_layer && status->info_ok &&
 			    !lv_info(cmd, lv, 0, NULL, 0, 0))
 				memset(&status->info,  0, sizeof(status->info));
+			/* for inactive cache reset lvinfo for its struct for cache-pool */
+			if (lv_is_used_cache_pool(lv) && !status->info_ok) {
+				memset(&status->info,  0, sizeof(status->info));
+				status->info_ok = 1;
+			}
 		} else
 			/* status only */
 			status->info_ok = lv_status(cmd, lv_seg, use_layer, &status->seg_status);


