From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 12 Aug 2011 23:33:42 -0500
Subject: [PATCH] LVM RAID: a couple more fixes
In-Reply-To: <1313169003.27367.6.camel@f14.redhat.com>
References: <1313169003.27367.6.camel@f14.redhat.com>
Message-ID: <1313210022.3258.2.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 2011-08-12 at 12:10 -0500, Jonathan Brassow wrote:
> Patch includes:
> 1) add new function 'raid_remove_top_layer' which will be useful
>  to other conversion functions later (also cleans up code)
> 2) Add error messages if raid_[extract|add]_images fails
> 3) DO NOT activate sub_lv's between a suspend/resume
> 4) Add function prototypes to prevent compiler warnings when
>  compiling with '--with-raid=shared'

I've checked in all but #3, which I've attached as a smaller patch with
kabi's suggested change.  I've tested the suggestion and it works (much
better than the sleep :).

 brassow

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



