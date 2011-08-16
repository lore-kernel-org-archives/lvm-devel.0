From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 16 Aug 2011 09:13:34 -0500
Subject: [PATCH 1 of 5] LVM RAID: down-convert activation clean-up
In-Reply-To: <1313503895.11617.10.camel@f14.redhat.com>
References: <1313503895.11617.10.camel@f14.redhat.com>
Message-ID: <1313504014.11617.12.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Down-convert should not activate sub-lv's between suspend/resume of top LV.

The sub-lv's being removed should not be activated between the suspend/resume
cycle of the top-level LV.  Removing this action however, causes "device
in-use" errors when attempting to deactivate/remove the sub-lv's.  The
solution then, is to call 'sync_local_dev_names' before deactivating the
sub-lv's.


Index: LVM2/lib/metadata/raid_manip.c
===================================================================
--- LVM2.orig/lib/metadata/raid_manip.c
+++ LVM2/lib/metadata/raid_manip.c
@@ -488,22 +488,9 @@ int lv_raid_change_image_count(struct lo
 	}
 
 	/*
-	 * Bring extracted LVs into existance, so there are no
-	 * conflicts for the main RAID device's resume
+	 * Resume original LV
+	 * This also resumes all other sub-lvs (including the extracted)
 	 */
-	if (!dm_list_empty(&removal_list)) {
-		dm_list_iterate_items(lvl, &removal_list) {
-			/* If top RAID was EX, use EX */
-			if (lv_is_active_exclusive_locally(lv)) {
-				if (!activate_lv_excl(lv->vg->cmd, lvl->lv))
-					return_0;
-			} else {
-				if (!activate_lv(lv->vg->cmd, lvl->lv))
-					return_0;
-			}
-		}
-	}
-
 	if (!resume_lv(lv->vg->cmd, lv)) {
 		log_error("Failed to resume %s/%s after committing changes",
 			  lv->vg->name, lv->name);
@@ -513,6 +500,7 @@ int lv_raid_change_image_count(struct lo
 	/*
 	 * Eliminate the extracted LVs
 	 */
+	sync_local_dev_names(lv->vg->cmd);
 	if (!dm_list_empty(&removal_list)) {
 		dm_list_iterate_items(lvl, &removal_list) {
 			if (!deactivate_lv(lv->vg->cmd, lvl->lv))



