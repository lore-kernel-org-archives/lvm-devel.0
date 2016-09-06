From: Brassow Jonathan <jbrassow@redhat.com>
Date: Tue, 6 Sep 2016 09:29:14 -0500
Subject: [PATCH] Allow scrubbing on cache origin sub-LVs - Bug 1169495
Message-ID: <EA0C3E08-883E-40CB-939D-CA8E389A7DE7@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Allow RAID scrubbing on cache origin sub-LV

This patch adds the ability to perform RAID scrubbing on the cache
origin sub-LV (https://bugzilla.redhat.com/1169495).  Cache origin
operations are restricted to non-clustered RAID LVs until there can
be further testing in a cluster (even for exclusive activation).

Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Index: Work/lvm2/tools/lvchange.c
===================================================================
--- Work.orig/lvm2/tools/lvchange.c
+++ Work/lvm2/tools/lvchange.c
@@ -1056,7 +1056,20 @@ static int _lvchange_single(struct cmd_c
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
+		 */
+	} else if (!lv_is_visible(lv) && !lv_is_virtual_origin(lv)) {
 		log_error("Unable to change internal LV %s directly.",
 			  display_lvname(lv));
 		return ECMD_FAILED;
Index: Work/lvm2/test/shell/lvchange-syncaction-raid.sh
===================================================================
--- Work.orig/lvm2/test/shell/lvchange-syncaction-raid.sh
+++ Work/lvm2/test/shell/lvchange-syncaction-raid.sh
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


