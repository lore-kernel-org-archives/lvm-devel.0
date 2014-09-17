From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 17 Sep 2014 12:42:40 +0000 (UTC)
Subject: master - vgchange: support clustered conversion for active lv
Message-ID: <20140917124240.1E6DA61087@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=98414ca7dd2682b64fec141ae58b4c8ed4367fc7
Commit:        98414ca7dd2682b64fec141ae58b4c8ed4367fc7
Parent:        f90bc22ca532f5852aeaab92e0c40b36d65ef62d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 17 14:27:46 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 17 14:41:42 2014 +0200

vgchange: support clustered conversion for active lv

If we want to support conversion of VG to clustered type,
we currently need to relock active LV to get proper DLM lock.

So add extra loop after change of VG clustered attribute
to exlusively activate all active top level LVs.

When doing change -cy -> -cn  we should validate LVs are not
active on other cluster nodes - we could be sure about this only
when with local exclusive activation - for other types
we require user to deactivate volumes first.

As a workaround for this limitation there is always
locking_type = 0 which amongs other skip the detection
of active LVs.

FIXME:
 clvmd should handle looks for cluster locking type all the time.
---
 WHATS_NEW                    |    2 +-
 lib/metadata/vg.c            |   35 +++++++++++++++++++++++++++--------
 test/shell/vgchange-usage.sh |   15 ++++++++-------
 tools/vgchange.c             |   29 ++++++++++++++++++++++++++++-
 4 files changed, 64 insertions(+), 17 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1015835..1f64d0d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,7 +1,7 @@
 Version 2.02.112 - 
 =====================================
   Fix inablility to specify cachemode when 'lvconvert'ing to cache-pool.
-  Disable vgchange of clustered attribute with any active LV in VG.
+  Grab cluster lock for active LVs when setting clustered attribute.
   Use va_copy to properly pass va_list through functions.
   Add function to detect rotational devices.
   Review internal checks for mirror/raid/pvmove volumes.
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index acda5be..7b6cb85 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -520,7 +520,8 @@ int vg_set_alloc_policy(struct volume_group *vg, alloc_policy_t alloc)
 }
 
 /*
- * We do not currently support switching the cluster attribute
+ * Switching the cluster attribute make the active volume
+ * exclusively activate
  * with any active logical volumes.
  *
  * FIXME: resolve logic with reacquiring proper top-level LV locks
@@ -529,14 +530,32 @@ int vg_set_alloc_policy(struct volume_group *vg, alloc_policy_t alloc)
 int vg_set_clustered(struct volume_group *vg, int clustered)
 {
 	struct lv_list *lvl;
-	struct logical_volume *lv;
+	int fail = 0;
+
+	if (vg_is_clustered(vg) &&
+	    locking_is_clustered() &&
+	    locking_supports_remote_queries() &&
+	    !clustered) {
+		/*
+		 * If the volume is locally active but not exclusively
+		 * we cannot determine when other nodes also use
+		 * locally active (CR lock), so refuse conversion.
+		 */
+		dm_list_iterate_items(lvl, &vg->lvs)
+			if ((lv_lock_holder(lvl->lv) == lvl->lv) &&
+			    lv_is_active(lvl->lv) &&
+			    !lv_is_active_exclusive_locally(lvl->lv)) {
+				/* Show all non-local-exclusively active LVs
+				 * this includes i.e. clustered mirrors */
+				log_error("Can't change cluster attribute with "
+					  "active logical volume %s.",
+					  display_lvname(lvl->lv));
+				fail = 1;
+			}
 
-	dm_list_iterate_items(lvl, &vg->lvs) {
-		/* For COW, check lock for origin */
-		lv = lv_is_cow(lvl->lv) ? origin_from_cow(lvl->lv) : lvl->lv;
-		if (lv_is_active(lv)) {
-			log_error("Can't change cluster attribute with active "
-				  "oogical volume %s.", display_lvname(lv));
+		if (fail) {
+			log_print_unless_silent("Conversion is supported only for "
+						"locally exclusive volumes.");
 			return 0;
 		}
 	}
diff --git a/test/shell/vgchange-usage.sh b/test/shell/vgchange-usage.sh
index ff80722..e564337 100644
--- a/test/shell/vgchange-usage.sh
+++ b/test/shell/vgchange-usage.sh
@@ -89,27 +89,28 @@ fail vgchange -cy |& tee out
 grep "y/n" out
 check vg_attr_bit cluster $vg "-"
 
-lvcreate -l1 $vg
+lvcreate -l1 -n $lv1 $vg
 
 # check on cluster
 # either skipped as clustered (non-cluster), or already clustered (on cluster)
 if test -e LOCAL_CLVMD ; then
-	# can't switch with active LV
-	not vgchange -cy $vg
-	lvchange -an $vg
+	# can switch with active LV
 	vgchange -cy $vg
 	fail vgchange -cy $vg
+	# check volume is active locally exclusively
+	check lv_field $vg/$lv1 lv_active "local exclusive"
 	check vg_attr_bit cluster $vg "c"
+	# check we do not support conversion of just locally active LVs
+	lvchange -an $vg
 	lvchange -ay $vg
 	not vgchange -cn $vg
 	lvchange -an $vg
+	lvchange -aey $vg
 	vgchange -cn $vg
 else
 	# no clvmd is running
 	fail vgchange -cy $vg
 	# can't switch with active LV
-	not vgchange --yes -cy $vg
-	lvchange -an $vg
 	vgchange --yes -cy $vg
 	fail vgchange --yes -cy $vg
 	fail vgs $vg |& tee out
@@ -117,7 +118,7 @@ else
 	vgs --ignoreskippedcluster $vg |& tee out
 	not grep "Skipping clustered volume group" out
 	# reset back to non-clustered VG with disabled locking
-	vgchange -cn --config 'global{locking_type=0}' $vg
+	vgchange -cn $vg --config 'global{locking_type=0}' $vg
 fi
 check vg_attr_bit cluster $vg "-"
 
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 29e2d8a..da0a05d 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -479,7 +479,9 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg,
 			   void *handle __attribute__((unused)))
 {
+	int ret = ECMD_PROCESSED;
 	unsigned i;
+	struct lv_list *lvl;
 
 	static const struct {
 		int arg;
@@ -534,6 +536,31 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 		backup(vg);
 
 		log_print_unless_silent("Volume group \"%s\" successfully changed", vg->name);
+
+		/* FIXME: fix clvmd bug and take DLM lock for non clustered VGs. */
+		if (arg_is_set(cmd, clustered_ARG) &&
+		    vg_is_clustered(vg) && /* just switched to clustered */
+		    locking_is_clustered() &&
+		    locking_supports_remote_queries())
+			dm_list_iterate_items(lvl, &vg->lvs) {
+				if ((lv_lock_holder(lvl->lv) != lvl->lv) ||
+				    !lv_is_active(lvl->lv))
+					continue;
+
+				if (!activate_lv_excl_local(cmd, lvl->lv) ||
+				    !lv_is_active_exclusive_locally(lvl->lv)) {
+					log_error("Can't reactive logical volume %s, "
+						  "please fix manually.",
+						  display_lvname(lvl->lv));
+					ret = ECMD_FAILED;
+				}
+
+				if (lv_is_mirror(lvl->lv))
+					/* Give hint for clustered mirroring */
+					log_print_unless_silent("For clustered mirroring of %s "
+								"deactivation and activation is needed.",
+								display_lvname(lvl->lv));
+			}
 	}
 
 	if (arg_count(cmd, activate_ARG)) {
@@ -561,7 +588,7 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 		if (!_vgchange_background_polling(cmd, vg))
 			return_ECMD_FAILED;
 
-        return ECMD_PROCESSED;
+        return ret;
 }
 
 int vgchange(struct cmd_context *cmd, int argc, char **argv)


