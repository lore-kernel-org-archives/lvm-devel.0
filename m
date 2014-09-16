From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Tue, 16 Sep 2014 15:35:18 +0000 (UTC)
Subject: dev-mcsontos-clvmd-stack-overflow - vgchange: disable cluster convert for active LVs
Message-ID: <20140916153518.9F6E860735@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4a853361b01feda77031901eb2828c6ecabe760f
Commit:        4a853361b01feda77031901eb2828c6ecabe760f
Parent:        1ce21c19d5894b889a6d8da67c8a159709c3dda9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 16 11:41:28 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 16 11:42:41 2014 +0200

vgchange: disable cluster convert for active LVs

While we could probably reacquire some type of lock when
going from non-clustered to clustered vg, we don't have any
single road back to drop the lock and keep LV active.

For now keep it safe and prohibit conversion when LV
is active in the VG.
---
 WHATS_NEW                    |    1 +
 lib/metadata/vg.c            |   42 +++++++++++++++++-------------------------
 test/shell/vgchange-usage.sh |   11 +++++++++++
 3 files changed, 29 insertions(+), 25 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d3f926d..6c12186 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Disable vgchange of clustered attribute with any active LV in VG.
   Use va_copy to properly pass va_list through functions.
   Add function to detect rotational devices.
   Review internal checks for mirror/raid/pvmove volumes.
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 8ebec99..acda5be 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -519,36 +519,24 @@ int vg_set_alloc_policy(struct volume_group *vg, alloc_policy_t alloc)
 	return 1;
 }
 
+/*
+ * We do not currently support switching the cluster attribute
+ * with any active logical volumes.
+ *
+ * FIXME: resolve logic with reacquiring proper top-level LV locks
+ *        and we likely can't giveup DLM locks for active LVs...
+ */
 int vg_set_clustered(struct volume_group *vg, int clustered)
 {
 	struct lv_list *lvl;
+	struct logical_volume *lv;
 
-	/*
-	 * We do not currently support switching the cluster attribute
-	 * on active mirrors, snapshots or RAID logical volumes.
-	 */
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (lv_is_active(lvl->lv) &&
-		    (lv_is_mirrored(lvl->lv) || lv_is_raid_type(lvl->lv))) {
-			log_error("%s logical volumes must be inactive "
-				  "when changing the cluster attribute.",
-				  lv_is_raid_type(lvl->lv) ? "RAID" : "Mirror");
-			return 0;
-		}
-
-		if (clustered) {
-			if (lv_is_origin(lvl->lv) || lv_is_cow(lvl->lv)) {
-				log_error("Volume group %s contains snapshots "
-					  "that are not yet supported.",
-					  vg->name);
-				return 0;
-			}
-		}
-
-		if ((lv_is_origin(lvl->lv) || lv_is_cow(lvl->lv)) &&
-		    lv_is_active(lvl->lv)) {
-			log_error("Snapshot logical volumes must be inactive "
-				  "when changing the cluster attribute.");
+		/* For COW, check lock for origin */
+		lv = lv_is_cow(lvl->lv) ? origin_from_cow(lvl->lv) : lvl->lv;
+		if (lv_is_active(lv)) {
+			log_error("Can't change cluster attribute with active "
+				  "oogical volume %s.", display_lvname(lv));
 			return 0;
 		}
 	}
@@ -557,6 +545,10 @@ int vg_set_clustered(struct volume_group *vg, int clustered)
 		vg->status |= CLUSTERED;
 	else
 		vg->status &= ~CLUSTERED;
+
+	log_debug_metadata("Setting volume group %s as %sclustered.",
+			   vg->name, clustered ? "" : "not " );
+
 	return 1;
 }
 
diff --git a/test/shell/vgchange-usage.sh b/test/shell/vgchange-usage.sh
index 6ba3f69..ff80722 100644
--- a/test/shell/vgchange-usage.sh
+++ b/test/shell/vgchange-usage.sh
@@ -89,16 +89,27 @@ fail vgchange -cy |& tee out
 grep "y/n" out
 check vg_attr_bit cluster $vg "-"
 
+lvcreate -l1 $vg
+
 # check on cluster
 # either skipped as clustered (non-cluster), or already clustered (on cluster)
 if test -e LOCAL_CLVMD ; then
+	# can't switch with active LV
+	not vgchange -cy $vg
+	lvchange -an $vg
 	vgchange -cy $vg
 	fail vgchange -cy $vg
 	check vg_attr_bit cluster $vg "c"
+	lvchange -ay $vg
+	not vgchange -cn $vg
+	lvchange -an $vg
 	vgchange -cn $vg
 else
 	# no clvmd is running
 	fail vgchange -cy $vg
+	# can't switch with active LV
+	not vgchange --yes -cy $vg
+	lvchange -an $vg
 	vgchange --yes -cy $vg
 	fail vgchange --yes -cy $vg
 	fail vgs $vg |& tee out


