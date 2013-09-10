From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue, 10 Sep 2013 21:34:04 +0000 (UTC)
Subject: master - RAID: Make RAID single-machine-exclusive capable in a cluster
Message-ID: <20130910213404.7EAD36104E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2691f1d764182722195cda80be1f511e968480aa
Commit:        2691f1d764182722195cda80be1f511e968480aa
Parent:        8d1d83504dcf9c86ad42d34d3bd0b201d7bab8f6
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Sep 10 16:33:22 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Sep 10 16:33:22 2013 -0500

RAID: Make RAID single-machine-exclusive capable in a cluster

Creation, deletion, [de]activation, repair, conversion, scrubbing
and changing operations are all now available for RAID LVs in a
cluster - provided that they are activated exclusively.

The code has been changed to ensure that no LV or sub-LV activation
is attempted cluster-wide.  This includes the often overlooked
operations of activating metadata areas for the brief time it takes
to clear them.  Additionally, some 'resume_lv' operations were
replaced with 'activate_lv_excl_local' when sub-LVs were promoted
to top-level LVs for removal, clearing or extraction.  This was
necessary because it forces the appropriate renaming actions the
occur via resume in the single-machine case, but won't happen in
a cluster due to the necessity of acquiring a lock first.

The *raid* tests have been updated to allow testing in a cluster.
For the most part, this meant creating devices with '-aey' if they
were to be converted to RAID.  (RAID requires the converting LV to
be EX because it is a condition of activation for the RAID LV in
a cluster.)
---
 WHATS_NEW                           |    1 +
 lib/metadata/lv.c                   |   12 +++++--
 lib/metadata/lv_manip.c             |   29 +++++++----------
 lib/metadata/raid_manip.c           |   58 +++++++++++++++++++++++-----------
 lib/metadata/vg.c                   |   11 ------
 test/lib/aux.sh                     |    3 --
 test/shell/lvchange-raid.sh         |    6 ++--
 test/shell/lvconvert-raid.sh        |   29 ++++++++++++-----
 test/shell/lvconvert-raid10.sh      |    4 +-
 test/shell/lvcreate-large-raid.sh   |    3 +-
 test/shell/lvcreate-large-raid10.sh |    1 -
 tools/lvchange.c                    |   41 ++++++++++++++++++++-----
 tools/lvconvert.c                   |    9 +++--
 13 files changed, 124 insertions(+), 83 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b1060af..b14daf5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Make RAID capable of single-machine exclusive operations in a cluster.
   Drop calculation of read ahead for deactivated volume.
   Check for exactly one lv segment in validation of thin pools and volumes.
   Fix dmeventd unmonitoring of thin pools.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index db71cf0..e3fda18 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -737,24 +737,28 @@ int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
 		if (!deactivate_lv(cmd, lv))
 			return_0;
 	} else if ((activate == CHANGE_AE) ||
+		   seg_is_raid(first_seg(lv)) ||
 		   lv_is_origin(lv) ||
 		   lv_is_thin_type(lv)) {
 		if (activate == CHANGE_ALN) {
-			/* origin or thin, all others have _AE */
+			/* origin, thin or RAID - all others have _AE */
 			/* other types of activation are implicitly exclusive */
 			/* Note: the order of tests is mandatory */
 			log_error("Cannot deactivate \"%s\" locally.", lv->name);
 			return 0;
 		}
-		log_verbose("Activating logical volume \"%s\" exclusively.", lv->name);
+		log_verbose("Activating logical volume \"%s\" exclusively.",
+			    lv->name);
 		if (!activate_lv_excl(cmd, lv))
 			return_0;
 	} else if (activate == CHANGE_ALN) {
-		log_verbose("Deactivating logical volume \"%s\" locally.", lv->name);
+		log_verbose("Deactivating logical volume \"%s\" locally.",
+			    lv->name);
 		if (!deactivate_lv_local(cmd, lv))
 			return_0;
 	} else if ((activate == CHANGE_ALY) || (activate == CHANGE_AAY)) {
-		log_verbose("Activating logical volume \"%s\" locally.", lv->name);
+		log_verbose("Activating logical volume \"%s\" locally.",
+			    lv->name);
 		if (!activate_lv_local(cmd, lv))
 			return_0;
 	} else { /* CHANGE_AY */
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1cccd8c..d12b34e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2881,7 +2881,8 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 				continue;
 			}
 
-			if (!activate_lv(meta_lv->vg->cmd, meta_lv)) {
+			/* For clearing, simply activate exclusive locally */
+			if (!activate_lv_excl_local(meta_lv->vg->cmd, meta_lv)) {
 				log_error("Failed to activate %s/%s for clearing",
 					  meta_lv->vg->name, meta_lv->name);
 				return 0;
@@ -5504,7 +5505,8 @@ int lv_activation_skip(struct logical_volume *lv, activation_change_t activate,
  *   If lp->activate is AY*, activate it.
  *   If lp->activate was AN* and the pool was originally inactive, deactivate it.
  */
-static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct lvcreate_params *lp,
+static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
+					       struct lvcreate_params *lp,
 					       const char *new_lv_name)
 {
 	struct cmd_context *cmd = vg->cmd;
@@ -5527,21 +5529,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 		return NULL;
 	}
 
-	if (vg_is_clustered(vg) && segtype_is_raid(lp->segtype)) {
-		/*
-		 * FIXME:
-		 * We could allow a RAID LV to be created as long as it
-		 * is activated exclusively.  Any subsequent activations
-		 * would have to be enforced as exclusive also.
-		 *
-		 * For now, we disallow the existence of RAID LVs in a
-		 * cluster VG
-		 */
-		log_error("Unable to create a %s logical volume in a cluster.",
-			  lp->segtype->name);
-		return NULL;
-	}
-
 	if ((segtype_is_mirrored(lp->segtype) ||
 	     segtype_is_raid(lp->segtype) || segtype_is_thin(lp->segtype)) &&
 	    !(vg->fid->fmt->features & FMT_SEGMENTS)) {
@@ -5843,6 +5830,14 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 	} else if (seg_is_raid(lp)) {
 		first_seg(lv)->min_recovery_rate = lp->min_recovery_rate;
 		first_seg(lv)->max_recovery_rate = lp->max_recovery_rate;
+		if (vg_is_clustered(lv->vg) &&
+		    is_change_activating(lp->activate) &&
+		    (lp->activate != CHANGE_AE)) {
+			log_debug_activation("Creating RAID logical volume in a"
+					     " cluster: setting activation"
+					     " mode to EX");
+			lp->activate = CHANGE_AE;
+		}
 	}
 
 	/* FIXME Log allocation and attachment should have happened inside lv_extend. */
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index d13750d..147b478 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -174,7 +174,7 @@ static int _clear_lv(struct logical_volume *lv)
 	if (test_mode())
 		return 1;
 
-	if (!was_active && !activate_lv(lv->vg->cmd, lv)) {
+	if (!was_active && !activate_lv_excl_local(lv->vg->cmd, lv)) {
 		log_error("Failed to activate %s for clearing",
 			  lv->name);
 		return 0;
@@ -962,12 +962,12 @@ static int _raid_remove_images(struct logical_volume *lv,
 	}
 
 	/*
-	 * We resume the extracted sub-LVs first so they are renamed
+	 * We activate the extracted sub-LVs first so they are renamed
 	 * and won't conflict with the remaining (possibly shifted)
 	 * sub-LVs.
 	 */
 	dm_list_iterate_items(lvl, &removal_list) {
-		if (!resume_lv(lv->vg->cmd, lvl->lv)) {
+		if (!activate_lv_excl_local(lv->vg->cmd, lvl->lv)) {
 			log_error("Failed to resume extracted LVs");
 			return 0;
 		}
@@ -1023,6 +1023,16 @@ int lv_raid_change_image_count(struct logical_volume *lv,
 		return 1;
 	}
 
+	/*
+	 * LV must be either in-active or exclusively active
+	 */
+	if (lv_is_active(lv) && vg_is_clustered(lv->vg) &&
+	    !lv_is_active_exclusive_locally(lv)) {
+		log_error("%s/%s must be active exclusive locally to"
+			  " perform this operation.", lv->vg->name, lv->name);
+		return 0;
+	}
+
 	if (old_count > new_count)
 		return _raid_remove_images(lv, new_count, pvs);
 
@@ -1125,15 +1135,15 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 	}
 
 	/*
-	 * First resume the newly split LV and LVs on the removal list.
+	 * First activate the newly split LV and LVs on the removal list.
 	 * This is necessary so that there are no name collisions due to
 	 * the original RAID LV having possibly had sub-LVs that have been
 	 * shifted and renamed.
 	 */
-	if (!resume_lv(cmd, lvl->lv))
+	if (!activate_lv_excl_local(cmd, lvl->lv))
 		return_0;
 	dm_list_iterate_items(lvl, &removal_list)
-		if (!resume_lv(cmd, lvl->lv))
+		if (!activate_lv_excl_local(cmd, lvl->lv))
 			return_0;
 
 	if (!resume_lv(lv->vg->cmd, lv)) {
@@ -1470,6 +1480,12 @@ int lv_raid_reshape(struct logical_volume *lv,
 		return 0;
 	}
 
+	if (vg_is_clustered(lv->vg) && !lv_is_active_exclusive_locally(lv)) {
+		log_error("%s/%s must be active exclusive locally to"
+			  " perform this operation.", lv->vg->name, lv->name);
+		return 0;
+	}
+
 	if (!strcmp(seg->segtype->name, "mirror") &&
 	    (!strcmp(new_segtype->name, "raid1")))
 	    return _convert_mirror_to_raid1(lv, new_segtype);
@@ -1493,21 +1509,23 @@ int lv_raid_replace(struct logical_volume *lv,
 		    struct dm_list *allocate_pvs)
 {
 	uint32_t s, sd, match_count = 0;
-	struct dm_list old_meta_lvs, old_data_lvs;
+	struct dm_list old_lvs;
 	struct dm_list new_meta_lvs, new_data_lvs;
 	struct lv_segment *raid_seg = first_seg(lv);
 	struct lv_list *lvl;
 	char *tmp_names[raid_seg->area_count * 2];
 
-	dm_list_init(&old_meta_lvs);
-	dm_list_init(&old_data_lvs);
+	dm_list_init(&old_lvs);
 	dm_list_init(&new_meta_lvs);
 	dm_list_init(&new_data_lvs);
 
-	if (!lv_is_active_locally(lv)) {
+	if (lv->status & PARTIAL_LV)
+		lv->vg->cmd->partial_activation = 1;
+
+	if (!lv_is_active_exclusive_locally(lv)) {
 		log_error("%s/%s must be active %sto perform this operation.",
 			  lv->vg->name, lv->name,
-			  vg_is_clustered(lv->vg) ? "locally " : "");
+			  vg_is_clustered(lv->vg) ? "exclusive locally " : "");
 		return 0;
 	}
 
@@ -1612,13 +1630,21 @@ try_again:
 	 */
 	if (!_raid_extract_images(lv, raid_seg->area_count - match_count,
 				  remove_pvs, 0,
-				  &old_meta_lvs, &old_data_lvs)) {
+				  &old_lvs, &old_lvs)) {
 		log_error("Failed to remove the specified images from %s/%s",
 			  lv->vg->name, lv->name);
 		return 0;
 	}
 
 	/*
+	 * Now that they are extracted and visible, make the system aware
+	 * of their new names.
+	 */
+	dm_list_iterate_items(lvl, &old_lvs)
+		if (!activate_lv_excl_local(lv->vg->cmd, lvl->lv))
+			return_0;
+
+	/*
 	 * Skip metadata operation normally done to clear the metadata sub-LVs.
 	 *
 	 * The LV_REBUILD flag is set on the new sub-LVs,
@@ -1696,13 +1722,7 @@ try_again:
 		return 0;
 	}
 
-	dm_list_iterate_items(lvl, &old_meta_lvs) {
-		if (!deactivate_lv(lv->vg->cmd, lvl->lv))
-			return_0;
-		if (!lv_remove(lvl->lv))
-			return_0;
-	}
-	dm_list_iterate_items(lvl, &old_data_lvs) {
+	dm_list_iterate_items(lvl, &old_lvs) {
 		if (!deactivate_lv(lv->vg->cmd, lvl->lv))
 			return_0;
 		if (!lv_remove(lvl->lv))
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 22099e2..476292e 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -524,17 +524,6 @@ int vg_set_clustered(struct volume_group *vg, int clustered)
 	 * on active mirrors, snapshots or RAID logical volumes.
 	 */
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		/*
-		 * FIXME:
-		 * We could allow exclusive activation of RAID LVs, but
-		 * for now we disallow them in a cluster VG at all.
-		 */
-		if (lv_is_raid_type(lvl->lv)) {
-			log_error("RAID logical volumes are not allowed "
-				  "in a cluster volume group.");
-			return 0;
-		}
-
 		if (lv_is_active(lvl->lv) &&
 		    (lv_is_mirrored(lvl->lv) || lv_is_raid_type(lvl->lv))) {
 			log_error("%s logical volumes must be inactive "
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 5ff0b0c..e07397d 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -640,9 +640,6 @@ wait_for_sync() {
 # i.e.   dm_target_at_least  dm-thin-pool  1 0
 target_at_least()
 {
-	# Raid target does not work in cluster
-	test -e LOCAL_CLVMD -a "$1" = "dm-raid" && return 1
-
 	case "$1" in
 	  dm-*) modprobe "$1" || true ;;
 	esac
diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 38b9c4c..babe726 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -289,7 +289,7 @@ run_checks() {
 
 # Hey, specifying devices for thin allocation doesn't work
 #		lvconvert --thinpool $1/$2 "$dev6"
-		lvcreate -L 2M -n ${2}_meta $1 "$dev6"
+		lvcreate -aey -L 2M -n ${2}_meta $1 "$dev6"
 		lvconvert --thinpool $1/$2 --poolmetadata ${2}_meta
 		lvcreate -T $1/$2 -V 1 -n thinlv
 		THIN_POSTFIX="_tdata"
@@ -303,7 +303,7 @@ run_checks() {
 		printf "#\n#\n# run_checks: RAID as thinpool metadata\n#\n#\n"
 
 		lvrename $1/$2 ${2}_meta
-		lvcreate -L 2M -n $2 $1 "$dev6"
+		lvcreate -aey -L 2M -n $2 $1 "$dev6"
 		lvconvert --thinpool $1/$2 --poolmetadata ${2}_meta
 		lvcreate -T $1/$2 -V 1 -n thinlv
 		THIN_POSTFIX="_tmeta"
@@ -314,7 +314,7 @@ run_checks() {
 		run_recovery_rate_check $1 $2
 	elif [ 'snapshot' == $3 ]; then
 		printf "#\n#\n# run_checks: RAID under snapshot\n#\n#\n"
-		lvcreate -s $1/$2 -l 4 -n snap "$dev6"
+		lvcreate -aey -s $1/$2 -l 4 -n snap "$dev6"
 
 		run_writemostly_check $1 $2
 		run_syncaction_check $1 $2
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 8693cf3..4c08386 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -11,8 +11,6 @@
 
 . lib/test
 
-test -e LOCAL_CLVMD && skip
-
 get_image_pvs() {
 	local d
 	local images
@@ -24,7 +22,10 @@ get_image_pvs() {
 ########################################################
 # MAIN
 ########################################################
-aux target_at_least dm-raid 1 2 0 || skip
+if ! aux target_at_least dm-raid 1 2 0; then
+	dmsetup targets | grep raid
+	skip
+fi
 
 # 9 PVs needed for RAID10 testing (3-stripes/2-mirror - replacing 3 devs)
 aux prepare_pvs 9 80
@@ -57,17 +58,17 @@ for i in 1 2 3; do
 			# Shouldn't be able to create with just 1 image
 			not lvcreate --type raid1 -m 0 -l 2 -n $lv1 $vg
 
-			lvcreate -l 2 -n $lv1 $vg
+			lvcreate -aey -l 2 -n $lv1 $vg
 		else
 			lvcreate --type raid1 -m $(($i - 1)) -l 2 -n $lv1 $vg
 			aux wait_for_sync $vg $lv1
 		fi
 
 		if $under_snap; then
-			lvcreate -s $vg/$lv1 -n snap -l 2
+			lvcreate -aey -s $vg/$lv1 -n snap -l 2
 		fi
 
-		lvconvert -m $((j - 1))  $vg/$lv1
+		lvconvert -m $((j - 1)) $vg/$lv1
 
 		# FIXME: ensure no residual devices
 
@@ -138,7 +139,7 @@ lvremove -ff $vg
 ###########################################
 # Linear to RAID1 conversion ("raid1" default segtype)
 ###########################################
-lvcreate -l 2 -n $lv1 $vg
+lvcreate -aey -l 2 -n $lv1 $vg
 lvconvert -m 1 $vg/$lv1 \
 	--config 'global { mirror_segtype_default = "raid1" }'
 lvs --noheadings -o attr $vg/$lv1 | grep '^r*'
@@ -147,17 +148,27 @@ lvremove -ff $vg
 ###########################################
 # Linear to RAID1 conversion (override "mirror" default segtype)
 ###########################################
-lvcreate -l 2 -n $lv1 $vg
+lvcreate -aey -l 2 -n $lv1 $vg
 lvconvert --type raid1 -m 1 $vg/$lv1 \
 	--config 'global { mirror_segtype_default = "mirror" }'
 lvs --noheadings -o attr $vg/$lv1 | grep '^r*'
 lvremove -ff $vg
 
 ###########################################
+# Must not be able to convert non-EX LVs in a cluster
+###########################################
+if [ -e LOCAL_CLVMD ]; then
+	lvcreate -l 2 -n $lv1 $vg
+	not lvconvert --type raid1 -m 1 $vg/$lv1 \
+		--config 'global { mirror_segtype_default = "mirror" }'
+	lvremove -ff $vg
+fi
+
+###########################################
 # Mirror to RAID1 conversion
 ###########################################
 for i in 1 2 3 ; do
-	lvcreate --type mirror -m $i -l 2 -n $lv1 $vg
+	lvcreate -aey --type mirror -m $i -l 2 -n $lv1 $vg
 	aux wait_for_sync $vg $lv1
 	lvconvert --type raid1 $vg/$lv1
 	lvremove -ff $vg
diff --git a/test/shell/lvconvert-raid10.sh b/test/shell/lvconvert-raid10.sh
index b2d4afd..4b3ceb4 100644
--- a/test/shell/lvconvert-raid10.sh
+++ b/test/shell/lvconvert-raid10.sh
@@ -11,8 +11,6 @@
 
 . lib/test
 
-test -e LOCAL_CLVMD && skip
-
 get_image_pvs() {
 	local d
 	local images
@@ -56,3 +54,5 @@ for i in 0 1; do
 		 $vg/$lv1
 	aux wait_for_sync $vg $lv1
 done
+
+lvremove -ff $vg
diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index c0b40db..a91da05 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -13,7 +13,6 @@
 
 . lib/test
 
-test -e LOCAL_CLVMD && skip
 aux target_at_least dm-raid 1 1 0 || skip
 
 aux prepare_vg 5
@@ -51,7 +50,7 @@ done
 #
 # Convert large linear to RAID1 (belong in different test script?)
 #
-lvcreate -L 200T -n $lv1 $vg1
+lvcreate -aey -L 200T -n $lv1 $vg1
 # Need to deactivate or the up-convert will start sync'ing
 lvchange -an $vg1/$lv1
 lvconvert --type raid1 -m 1 $vg1/$lv1
diff --git a/test/shell/lvcreate-large-raid10.sh b/test/shell/lvcreate-large-raid10.sh
index 50dd23a..d971d74 100644
--- a/test/shell/lvcreate-large-raid10.sh
+++ b/test/shell/lvcreate-large-raid10.sh
@@ -13,7 +13,6 @@
 
 . lib/test
 
-test -e LOCAL_CLVMD && skip
 aux target_at_least dm-raid 1 3 0 || skip
 
 aux prepare_vg 5
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 34e230c..1d4f0a5 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -301,6 +301,20 @@ static int lvchange_refresh(struct cmd_context *cmd, struct logical_volume *lv)
 	return lv_refresh(cmd, lv);
 }
 
+static int _reactivate_lv(struct logical_volume *lv,
+			  int active, int exclusive)
+{
+	struct cmd_context *cmd = lv->vg->cmd;
+
+	if (!active)
+		return 1;
+
+	if (exclusive)
+		return activate_lv_excl_local(cmd, lv);
+
+	return activate_lv(cmd, lv);
+}
+
 /*
  * lvchange_resync
  * @cmd
@@ -311,6 +325,7 @@ static int lvchange_refresh(struct cmd_context *cmd, struct logical_volume *lv)
 static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	int active = 0;
+	int exclusive = 0;
 	int monitored;
 	struct lvinfo info;
 	struct lv_segment *seg = first_seg(lv);
@@ -356,9 +371,17 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 				return_0;
 
 			active = 1;
+			if (lv_is_active_exclusive_locally(lv))
+				exclusive = 1;
 		}
 	}
 
+	if (seg_is_raid(seg) && active && !exclusive) {
+		log_error("RAID logical volume %s/%s cannot be active remotely.",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
 	/* Activate exclusively to ensure no nodes still have LV active */
 	monitored = dmeventd_monitor_mode();
 	if (monitored != DMEVENTD_MONITOR_IGNORE)
@@ -403,7 +426,7 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 			}
 		}
 
-		if (active && !activate_lv(cmd, lv)) {
+		if (!_reactivate_lv(lv, active, exclusive)) {
 			log_error("Failed to reactivate %s to resynchronize "
 				  "mirror", lv->name);
 			return 0;
@@ -429,7 +452,7 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 		log_error("Failed to write intermediate VG metadata.");
 		if (!attach_metadata_devices(seg, &device_list))
 			stack;
-		if (active && !activate_lv(cmd, lv))
+		if (!_reactivate_lv(lv, active, exclusive))
 			stack;
 		return 0;
 	}
@@ -438,7 +461,7 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 		log_error("Failed to commit intermediate VG metadata.");
 		if (!attach_metadata_devices(seg, &device_list))
 			stack;
-		if (active && !activate_lv(cmd, lv))
+		if (!_reactivate_lv(lv, active, exclusive))
 			stack;
 		return 0;
 	}
@@ -446,9 +469,10 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 	backup(lv->vg);
 
 	dm_list_iterate_items(lvl, &device_list) {
-		if (!activate_lv(cmd, lvl->lv)) {
-			log_error("Unable to activate %s for mirror log resync",
-				  lvl->lv->name);
+		if (!activate_lv_excl_local(cmd, lvl->lv)) {
+			log_error("Unable to activate %s for %s clearing",
+				  lvl->lv->name, (seg_is_raid(seg)) ?
+				  "metadata area" : "mirror log");
 			return 0;
 		}
 
@@ -486,8 +510,9 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 		return 0;
 	}
 
-	if (active && !activate_lv(cmd, lv)) {
-		log_error("Failed to reactivate %s after resync", lv->name);
+	if (!_reactivate_lv(lv, active, exclusive)) {
+		log_error("Failed to reactivate %s after resync",
+			  lv->name);
 		return 0;
 	}
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 94ba8c8..13002e3 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1754,10 +1754,11 @@ static int lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp
 		return lv_raid_replace(lv, lp->replace_pvh, lp->pvh);
 
 	if (arg_count(cmd, repair_ARG)) {
-		if (!lv_is_active_locally(lv)) {
-			log_error("%s/%s must be active %sto perform"
-				  "this operation.", lv->vg->name, lv->name,
-				  vg_is_clustered(lv->vg) ? "locally " : "");
+		if (!lv_is_active_exclusive_locally(lv)) {
+			log_error("%s/%s must be active %sto perform this"
+				  " operation.", lv->vg->name, lv->name,
+				  vg_is_clustered(lv->vg) ?
+				  "exclusive locally " : "");
 			return 0;
 		}
 


