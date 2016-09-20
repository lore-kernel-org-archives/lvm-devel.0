From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Tue, 20 Sep 2016 22:39:37 +0000 (UTC)
Subject: master - lvconvert: fix (automatic) raid repair regression
Message-ID: <20160920223937.74FE360C39@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5d455b28fce16fce20f33279fe3b1b682c57e619
Commit:        5d455b28fce16fce20f33279fe3b1b682c57e619
Parent:        78e0fdb6182e8cae26998510760caf7afe237c39
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Sep 21 00:38:38 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Sep 21 00:39:29 2016 +0200

lvconvert: fix (automatic) raid repair regression

The dm-raid target now rejects device rebuild requests during ongoing
resynchronization thus causing 'lvconvert --repair ...' to fail with
a kernel error message. This regresses with respect to failing automatic
repair via the dmeventd RAID plugin in case raid_fault_policy="allocate"
is configured in lvm.conf as well.

Previously allowing such repair request required cancelling the
resynchronization of any still accessible DataLVs, hence reasoning
potential data loss.

Patch allows the resynchronization of still accessible DataLVs to
finish up by rejecting any 'lvconvert --repair ...'.

It enhances the dmeventd RAID plugin to be able to automatically repair
by postponing the repair after synchronization ended.

More tests are added to lvconvert-rebuild-raid.sh to cover single
and multiple DataLV failure cases for the different RAID levels.

- resolves: rhbz1371717
---
 WHATS_NEW                                     |    1 +
 daemons/dmeventd/plugins/raid/dmeventd_raid.c |   42 ++++++++--
 lib/metadata/lv.c                             |    6 --
 lib/metadata/raid_manip.c                     |    2 +-
 test/shell/lvconvert-repair-raid.sh           |  104 +++++++++++++++++++++++-
 tools/lvconvert.c                             |   18 ----
 6 files changed, 134 insertions(+), 39 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index faddb9f..f7b39b9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.166 - 
 =====================================
+  Fix lvconvert --repair regression
   Fix reported origin lv field for cache volumes. (2.02.133)
   Always specify snapshot cow LV for monitoring not internal LV. (2.02.165)
   Fix lvchange --discard|--zero for active thin-pool.
diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index 770fbc6..bec594a 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005-2015 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2016 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -13,14 +13,20 @@
  */
 
 #include "lib.h"
+#include "defaults.h"
 #include "dmeventd_lvm.h"
 #include "libdevmapper-event.h"
 
+/* Hold enough elements for the mximum number of RAID images */
+#define	RAID_DEVS_ELEMS	((DEFAULT_RAID_MAX_IMAGES + 63) / 64)
+
 struct dso_state {
 	struct dm_pool *mem;
 	char cmd_lvscan[512];
 	char cmd_lvconvert[512];
+	uint64_t raid_devs[RAID_DEVS_ELEMS];
 	int failed;
+	int warned;
 };
 
 DM_EVENT_LOG_FN("raid")
@@ -31,20 +37,39 @@ static int _process_raid_event(struct dso_state *state, char *params, const char
 {
 	struct dm_status_raid *status;
 	const char *d;
+	int dead = 0, r = 1;
 
 	if (!dm_get_status_raid(state->mem, params, &status)) {
 		log_error("Failed to process status line for %s.", device);
 		return 0;
 	}
 
-	if ((d = strchr(status->dev_health, 'D'))) {
+	d = status->dev_health;
+	while ((d = strchr(d, 'D'))) {
+		uint32_t dev = (uint32_t)(d - status->dev_health);
+
+		if (!(state->raid_devs[dev / 64] & (1 << (dev % 64))))
+			log_error("Device #%u of %s array, %s, has failed.",
+				  dev, status->raid_type, device);
+
+		state->raid_devs[dev / 64] |= (1 << (dev % 64));
+		d++;
+		dead = 1;
+	}
+
+	if (dead) {
+		if (status->insync_regions < status->total_regions) {
+			if (!state->warned)
+				log_warn("WARNING: waiting for resynchronization to finish "
+					 "before initiating repair on RAID device %s", device);
+
+			state->warned = 1;
+			goto out; /* Not yet done syncing with accessible devices */
+		}
+
 		if (state->failed)
 			goto out; /* already reported */
 
-		log_error("Device #%d of %s array, %s, has failed.",
-			  (int)(d - status->dev_health),
-			  status->raid_type, device);
-
 		state->failed = 1;
 		if (!dmeventd_lvm2_run_with_lock(state->cmd_lvscan))
 			log_warn("WARNING: Re-scan of RAID device %s failed.", device);
@@ -52,8 +77,7 @@ static int _process_raid_event(struct dso_state *state, char *params, const char
 		/* if repair goes OK, report success even if lvscan has failed */
 		if (!dmeventd_lvm2_run_with_lock(state->cmd_lvconvert)) {
 			log_info("Repair of RAID device %s failed.", device);
-			dm_pool_free(state->mem, status);
-			return 0;
+			r = 0;
 		}
 	} else {
 		state->failed = 0;
@@ -64,7 +88,7 @@ static int _process_raid_event(struct dso_state *state, char *params, const char
 out:
 	dm_pool_free(state->mem, status);
 
-	return 1;
+	return r;
 }
 
 void process_event(struct dm_task *dmt,
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 53a1044..60374dd 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1018,12 +1018,6 @@ int lv_raid_image_in_sync(const struct logical_volume *lv)
 		return 0;
 	}
 
-	if (!lv_raid_percent(raid_seg->lv, &percent))
-		return_0;
-
-	if (percent == DM_PERCENT_100)
-		return 1;
-
 	/* Find out which sub-LV this is. */
 	for (s = 0; s < raid_seg->area_count; s++)
 		if (seg_lv(raid_seg, s) == lv)
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index e5fdf4f..deb88a2 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3658,7 +3658,7 @@ static int _lv_raid_rebuild_or_replace(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!mirror_in_sync() && !_raid_in_sync(lv)) {
+	if (!_raid_in_sync(lv)) {
 		log_error("Unable to replace devices in %s/%s while it is"
 			  " not in-sync.", lv->vg->name, lv->name);
 		return 0;
diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index 1ef91c4..b51d8fe 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -22,11 +22,52 @@ aux lvmconf 'allocation/maximise_cling = 0' \
 
 aux prepare_vg 8
 
+function delay
+{
+	for d in $(< DEVICES)
+	do
+		aux delay_dev "$d" 0 $1 $(get first_extent_sector "$d")
+	done
+}
+
 # It's possible small raid arrays do have problems with reporting in-sync.
 # So try bigger size
+RAID_SIZE=32
+
+# Fast sync and repair afterwards
+delay 0
+
+# RAID1 dual-leg single replace after initial sync
+lvcreate --type raid1 -m 1 -L $RAID_SIZE -n $lv1 $vg "$dev1" "$dev2"
+aux wait_for_sync $vg $lv1
+aux disable_dev "$dev2"
+lvconvert -y --repair $vg/$lv1
+vgreduce --removemissing $vg
+aux enable_dev "$dev2"
+vgextend $vg "$dev2"
+lvremove -ff $vg/$lv1
+
+# Delayed sync to allow for repair during rebuild
+delay 50
+
+# RAID1 triple-leg single replace during initial sync
+lvcreate --type raid1 -m 2 -L $RAID_SIZE -n $lv1 $vg "$dev1" "$dev2" "$dev3"
+aux disable_dev "$dev2" "$dev3"
+not lvconvert -y --repair $vg/$lv1
+aux wait_for_sync $vg $lv1
+lvconvert -y --repair $vg/$lv1
+vgreduce --removemissing $vg
+aux enable_dev "$dev2" "$dev3"
+vgextend $vg "$dev2" "$dev3"
+lvremove -ff $vg/$lv1
+
+
+# Larger RAID size possible for striped RAID
 RAID_SIZE=64
 
-# RAID5 single replace
+# Fast sync and repair afterwards
+delay 0
+# RAID5 single replace after initial sync
 lvcreate --type raid5 -i 2 -L $RAID_SIZE -n $lv1 $vg "$dev1" "$dev2" "$dev3"
 aux wait_for_sync $vg $lv1
 aux disable_dev "$dev3"
@@ -34,16 +75,69 @@ lvconvert -y --repair $vg/$lv1
 vgreduce --removemissing $vg
 aux enable_dev "$dev3"
 vgextend $vg "$dev3"
-lvremove -ff $vg
+lvremove -ff $vg/$lv1
 
-# RAID6 double replace
+# Delayed sync to allow for repair during rebuild
+delay 50
+
+# RAID5 single replace during initial sync
+lvcreate --type raid5 -i 2 -L $RAID_SIZE -n $lv1 $vg "$dev1" "$dev2" "$dev3"
+aux disable_dev "$dev3"
+not lvconvert -y --repair $vg/$lv1
+aux wait_for_sync $vg $lv1
+lvconvert -y --repair $vg/$lv1
+vgreduce --removemissing $vg
+aux enable_dev "$dev3"
+vgextend $vg "$dev3"
+lvremove -ff $vg/$lv1
+
+# Fast sync and repair afterwards
+delay 0
+
+# RAID6 double replace after initial sync
 lvcreate --type raid6 -i 3 -L $RAID_SIZE -n $lv1 $vg \
     "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 aux wait_for_sync $vg $lv1
 aux disable_dev "$dev4" "$dev5"
 lvconvert -y --repair $vg/$lv1
 vgreduce --removemissing $vg
-aux enable_dev "$dev4"
-aux enable_dev "$dev5"
+aux enable_dev "$dev4" "$dev5"
 vgextend $vg "$dev4" "$dev5"
+lvremove -ff $vg/$lv1
+
+# Delayed sync to allow for repair during rebuild
+delay 50
+
+# RAID6 single replace after initial sync
+lvcreate --type raid6 -i 3 -L $RAID_SIZE -n $lv1 $vg \
+    "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+aux disable_dev "$dev4"
+not lvconvert -y --repair $vg/$lv1
+delay 0 # Fast sync and repair afterwards
+aux disable_dev "$dev4" # Need to disable again after changing delay
+aux wait_for_sync $vg $lv1
+lvconvert -y --repair $vg/$lv1
+vgreduce --removemissing $vg
+aux enable_dev "$dev4"
+vgextend $vg "$dev4"
+lvremove -ff $vg/$lv1
+
+# Delayed sync to allow for repair during rebuild
+delay 50
+
+# RAID10 single replace after initial sync
+lvcreate --type raid10 -m 1 -i 2 -L $RAID_SIZE -n $lv1 $vg \
+    "$dev1" "$dev2" "$dev3" "$dev4"
+aux disable_dev "$dev4"
+not lvconvert -y --repair $vg/$lv1
+delay 0 # Fast sync and repair afterwards
+aux disable_dev "$dev4" # Need to disable again after changing delay
+aux disable_dev "$dev1"
+aux wait_for_sync $vg $lv1
+lvconvert -y --repair $vg/$lv1
+vgreduce --removemissing $vg
+aux enable_dev "$dev4"
+vgextend $vg "$dev4"
+lvremove -ff $vg/$lv1
+
 vgremove -ff $vg
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d1d21b6..4095101 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1974,24 +1974,6 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			return 0;
 		}
 
-		if (!lv_raid_percent(lv, &sync_percent)) {
-			log_error("Unable to determine sync status of %s.",
-				  display_lvname(lv));
-			return 0;
-		}
-
-		if (sync_percent != DM_PERCENT_100) {
-			log_warn("WARNING: %s is not in-sync.", display_lvname(lv));
-			log_warn("WARNING: Portions of the array may be unrecoverable.");
-
-			/*
-			 * The kernel will not allow a device to be replaced
-			 * in an array that is not in-sync unless we override
-			 * by forcing the array to be considered "in-sync".
-			 */
-			init_mirror_in_sync(1);
-		}
-
 		_lvconvert_raid_repair_ask(cmd, lp, &replace);
 
 		if (replace) {


