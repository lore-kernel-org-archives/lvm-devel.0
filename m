From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue, 18 Dec 2012 20:41:06 +0000 (UTC)
Subject: master - RAID: Limit replacement of devices when array is not in-sync.
Message-ID: <20121218204106.F41E52364@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=970dfbcd691addb7b69f4011c067eba3b35270b6
Commit:        970dfbcd691addb7b69f4011c067eba3b35270b6
Parent:        0379c480e09f0d6e8641bd4d8ca49a8bd3c32943
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Dec 18 14:40:42 2012 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Dec 18 14:40:42 2012 -0600

RAID:  Limit replacement of devices when array is not in-sync.

If a RAID array is not in-sync, replacing devices should not be allowed
as a general rule.  This is because the contents used to populate the
incoming device may be undefined because the devices being read where
not in-sync.  The kernel enforces this rule unless overridden by not
allowing the creation of an array that is not in-sync and includes a
devices that needs to be rebuilt.

Since we cannot know the sync state of an LV if it is inactive, we must
also enforce the rule that an array must be active to replace devices.

That leaves us with the following conditions:
1) never allow replacement or repair of devices if the LV is in-active
2) never allow replacement if the LV is not in-sync
3) allow repair if the LV is not in-sync, but warn that contents may
   not be recoverable.

In the case where a user is performing the repair on the command line via
'lvconvert --repair', the warning is printed before the user is prompted
if they would like to replace the device(s).  If the repair is automated
(i.e. via dmeventd and policy is "allocate"), then the device is replaced
if possible and the warning is printed.
---
 WHATS_NEW                 |    2 ++
 lib/metadata/raid_manip.c |   12 ++++++++++++
 tools/lvconvert.c         |   27 +++++++++++++++++++++++++++
 3 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c18f3f4..d114ccc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.99 - 
 ===================================
+  Limit RAID device replacement to repair only if LV is not in-sync.
+  Disallow RAID device replacement or repair on inactive LVs.
   Fix possible race while removing metadata from lvmetad.
   Fix possible deadlock when querying and updating lvmetad at the same time.
   Check lvmcache_info_from_pvid and recall only when needed in _pv_read.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 8be0abe..b902d3d 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1617,6 +1617,18 @@ int lv_raid_replace(struct logical_volume *lv,
 	dm_list_init(&new_meta_lvs);
 	dm_list_init(&new_data_lvs);
 
+	if (!lv_is_active(lv)) {
+		log_error("%s/%s must be active to perform this operation.",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	if (!mirror_in_sync() && !_raid_in_sync(lv)) {
+		log_error("Unable to replace devices in %s/%s while it is"
+			  " not in-sync.", lv->vg->name, lv->name);
+		return 0;
+	}
+
 	/*
 	 * How many sub-LVs are being removed?
 	 */
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index fa3b1ec..5bda00f 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1566,6 +1566,7 @@ static int lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp
 	struct dm_list *failed_pvs;
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *seg = first_seg(lv);
+	percent_t sync_percent;
 
 	if (!arg_count(cmd, type_ARG))
 		lp->segtype = seg->segtype;
@@ -1623,6 +1624,32 @@ static int lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp
 		return lv_raid_replace(lv, lp->replace_pvh, lp->pvh);
 
 	if (arg_count(cmd, repair_ARG)) {
+		if (!lv_is_active(lv)) {
+			log_error("%s/%s must be active to perform"
+				  "this operation.", lv->vg->name, lv->name);
+			return 0;
+		}
+
+		if (!lv_raid_percent(lv, &sync_percent)) {
+			log_error("Unable to determine sync status of %s/%s.",
+				  lv->vg->name, lv->name);
+			return 0;
+		}
+
+		if (sync_percent != PERCENT_100) {
+			log_error("WARNING: %s/%s is not in-sync.",
+				  lv->vg->name, lv->name);
+			log_error("WARNING: Portions of the array may"
+				  " be unrecoverable.");
+
+			/*
+			 * The kernel will not allow a device to be replaced
+			 * in an array that is not in-sync unless we override
+			 * by forcing the array to be considered "in-sync".
+			 */
+			init_mirror_in_sync(1);
+		}
+
 		_lvconvert_raid_repair_ask(cmd, &replace);
 
 		if (replace) {


