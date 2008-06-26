From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 26 Jun 2008 16:52:56 -0500
Subject: [PATCH - take 2] Allow mirror log conversion while inactive
Message-ID: <1214517177.21232.2.camel@hydrogen>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 brassow

Fix for bug 192865.

Allow mirror log conversion (disk -> core) of a non-clustered
mirror while it is inactive.

It should be mentioned that core -> disk was already working.

I also had to turn off support for this for cluster mirrors,
due to the fact that a mirror could be active on another
machine, but processing would continue as though inactive if
that was the state on the executing machine.  (core -> disk
conversions of cluster mirrors was being allowed... but
should not have been.)

So, in summary:
Single Machine mirroring
OPERATION	BEFORE PATCH	AFTER PATCH
inactive c->d	allowed		allowed
inactive d->c	disallowed	allowed (y/n prompt)
active c->d	allowed		allowed
active d->c	allowed		allowed

Cluster mirroring
OPERATION	BEFORE PATCH	AFTER PATCH
inactive c->d	allowed		disallowed (better msg)
inactive d->c	disallowed	disallowed (better msg)
active c->d	allowed		allowed
active d->c	allowed		allowed


Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -1140,6 +1140,8 @@ int remove_mirror_log(struct cmd_context
 		      struct list *removable_pvs)
 {
 	float sync_percent;
+	struct lvinfo info;
+	struct volume_group *vg = lv->vg;
 
 	/* Unimplemented features */
 	if (list_size(&lv->segments) != 1) {
@@ -1148,10 +1150,21 @@ int remove_mirror_log(struct cmd_context
 	}
 
 	/* Had disk log, switch to core. */
-	if (!lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL)) {
-		log_error("Unable to determine mirror sync status.");
+	if (lv_info(cmd, lv, &info, 0, 0) && info.exists) {
+		if (!lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL)) {
+			log_error("Unable to determine mirror sync status.");
+			return 0;
+		}
+	} else if (vg_is_clustered(vg)) {
+		log_error("Unable to convert the log of an inactive "
+			  "cluster mirrors, %s", lv->name);
+		return 0;
+	} else if (yes_no_prompt("Converting %s to core log while inactive "
+			       " requires a complete resync of the mirror.\n"
+			       "Proceed? [y/n]: "))
+		sync_percent = 0;
+	else
 		return 0;
-	}
 
 	if (sync_percent >= 100.0)
 		init_mirror_in_sync(1);
@@ -1269,12 +1282,9 @@ int attach_mirror_log(struct lv_segment 
 	return add_seg_to_segs_using_this_lv(log_lv, seg);
 }
 
-int add_mirror_log(struct cmd_context *cmd,
-		   struct logical_volume *lv,
-		   uint32_t log_count,
-		   uint32_t region_size,
-		   struct list *allocatable_pvs,
-		   alloc_policy_t alloc)
+int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
+		   uint32_t log_count, uint32_t region_size,
+		   struct list *allocatable_pvs, alloc_policy_t alloc)
 {
 	struct alloc_handle *ah;
 	const struct segment_type *segtype;
@@ -1282,17 +1292,31 @@ int add_mirror_log(struct cmd_context *c
 	float sync_percent;
 	int in_sync;
 	struct logical_volume *log_lv;
+	struct lvinfo info;
 
 	/* Unimplemented features */
 	if (log_count > 1) {
 		log_error("log_count > 1 is not supported");
 		return 0;
 	}
+
 	if (list_size(&lv->segments) != 1) {
 		log_error("Multiple-segment mirror is not supported");
 		return 0;
 	}
 
+	/*
+	 * We are unable to convert the log of inactive cluster mirrors
+	 * due to the inability to detect whether the mirror is active
+	 * on remote nodes (even though it is inactive on this node)
+	 */
+	if (vg_is_clustered(lv->vg) &&
+	    !(lv_info(cmd, lv, &info, 0, 0) && info.exists)) {
+		log_error("Unable to convert the log of an inactive "
+			  "cluster mirror, %s", lv->name);
+		return 0;
+	}
+
 	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv)))
 		return_0;
 
Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -508,6 +508,9 @@ static int lvconvert_mirrors(struct cmd_
 	}
 
 	if (lp->mirrors == existing_mirrors) {
+		/*
+		 * Convert Mirror log type
+		 */
 		original_lv = _original_lv(lv);
 		if (!first_seg(original_lv)->log_lv && !corelog) {
 			if (!add_mirror_log(cmd, original_lv, 1,



