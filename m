From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  7 Sep 2016 14:44:13 +0000 (UTC)
Subject: master - cache: scrubbing for cache origin LV - Bug 1169495
Message-ID: <20160907144413.34DAF60734@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5838c41a356eec05218395e734b90d21487f271c
Commit:        5838c41a356eec05218395e734b90d21487f271c
Parent:        01cc0dfae9ec5486fe313c0be4d3bb31e82a0456
Author:        Brassow Jonathan <jbrassow@redhat.com>
AuthorDate:    Tue Sep 6 09:29:14 2016 -0500
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 7 16:42:32 2016 +0200

cache: scrubbing for cache origin LV - Bug 1169495

Allow RAID scrubbing on cache origin sub-LV

This patch adds the ability to perform RAID scrubbing on the cache
origin sub-LV (https://bugzilla.redhat.com/1169495).  Cache origin
operations are restricted to non-clustered RAID LVs until there can
be further testing in a cluster (even for exclusive activation).

User can either specify directly _corig LV
or he can specify cache LV and operation  --syncation is
passed ONLY to   _corig LV.

If users wants to manipulation with cache-pool devices - he
needs to specify this object name.

Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>
---
 WHATS_NEW                              |    1 +
 test/shell/lvchange-syncaction-raid.sh |   11 +++++++++++
 tools/lvchange.c                       |   29 ++++++++++++++++++++++++++++-
 3 files changed, 40 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 22f6cee..c594723 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.166 - 
 =====================================
+  Support raid scrubbing on cache origin LV.
 
 Version 2.02.165 - 7th September 2016
 =====================================
diff --git a/test/shell/lvchange-syncaction-raid.sh b/test/shell/lvchange-syncaction-raid.sh
index 1997bc6..2baaaf6 100644
--- a/test/shell/lvchange-syncaction-raid.sh
+++ b/test/shell/lvchange-syncaction-raid.sh
@@ -82,4 +82,15 @@ aux wait_for_sync $vg $lv1
 # Retest mistmatch exists
 check lv_field $vg/$lv1 raid_mismatch_count "128"
 
+lvremove -ff $vg
+
+# Bug 1169495 - RFE: allow raid scrubbing on cache origin raid volumes
+# lvcreate RAID1 origin, lvcreate cache-pool, and lvconvert to cache
+#  then test that the origin can be scrubbed.
+lvcreate --type raid1 -m 1 --nosync -l 2 -n $lv1 $vg
+lvcreate --type cache-pool -l 1 -n ${lv1}_cachepool $vg
+lvconvert --cache -Zy --cachepool $vg/${lv1}_cachepool $vg/$lv1
+lvchange --syncaction check $vg/${lv1}_corig
+# Check may go too quickly to verify with check of syncaction
+
 vgremove -ff $vg
diff --git a/tools/lvchange.c b/tools/lvchange.c
index e0d91fc..4810392 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1049,6 +1049,18 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	    lv_is_virtual_origin(origin = origin_from_cow(lv)))
 		lv = origin;
 
+	/* Use cache origin LV for 'raid' actions */
+	if (lv_is_cache(lv) &&
+	    arg_from_list_is_set(cmd, NULL,
+				 /* FIXME: we want to support more ops here */
+				 //resync_ARG,
+				 syncaction_ARG,
+				 -1)) {
+		lv = seg_lv(first_seg(lv), 0);
+		log_debug("Using cache origin volume %s for lvchange instead.",
+			  display_lvname(lv));
+	}
+
 	if ((lv_is_thin_pool_data(lv) || lv_is_thin_pool_metadata(lv) ||
 	     lv_is_cache_pool_data(lv) || lv_is_cache_pool_metadata(lv)) &&
 	    !arg_is_set(cmd, activate_ARG) &&
@@ -1056,7 +1068,22 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	    !arg_is_set(cmd, setactivationskip_ARG))
 	    /* Rest can be changed for stacked thin pool meta/data volumes */
 	    ;
-	else if (!lv_is_visible(lv) && !lv_is_virtual_origin(lv)) {
+	else if (lv_is_cache_origin(lv) && lv_is_raid(lv)) {
+		if (vg_is_clustered(lv->vg)) {
+			log_error("Unable to change internal LV %s directly in a cluster.",
+				  display_lvname(lv));
+			return ECMD_FAILED;
+		}
+		/*
+		 * FIXME:  For now, we don't want to allow all kinds of
+		 * operations on this cache origin sub-LV.  We are going
+		 * to restrict it to non-clustered, RAID.  This way, we
+		 * can change the syncaction as needed (e.g. initiate
+		 * scrubbing).
+		 *
+		 * Later pass all 'cache' actions on cache origin.
+		 */
+	} else if (!lv_is_visible(lv) && !lv_is_virtual_origin(lv)) {
 		log_error("Unable to change internal LV %s directly.",
 			  display_lvname(lv));
 		return ECMD_FAILED;


