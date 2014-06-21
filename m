From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 20 Jun 2014 23:27:59 -0500
Subject: [PATCH] Add persistent log for 'pvmove --atomic'
Message-ID: <1403324879.5118.3.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Please be aware that in order to get around udev rules that prevent LVs
beginning with "pvmove*" from creating FS accessible links, I
temporarily rename the log device in order to wipe it of signatures and
initialize the log.  The name is currently "visible_pvmove_log".

 brassow

pvmove: Add persistent log to atomic pvmove

A persistent log allows atomic pvmoves to track their progress.  If a
deactivation happens for any reason, the move will pick-up where it
left off the last time.  The log is added after the pvmove mirror is
constructed but before the move begins.  If the creation of the log
fails for any reason (no space, metadata write failure, activation
failure, etc) the log is removed if necessary, a warning is printed,
and the pvmove proceeds.  The pvmove is fine to proceed without a
persistent log and the warning reminds the user that progress is not
tracked and that deactivation would result in starting over.  A
'pvmove --abort' at any point (whether the log was created or not)
cleans up the pvmove and restores the LVs to their former state.

Index: lvm2/lib/metadata/lv_manip.c
===================================================================
--- lvm2.orig/lib/metadata/lv_manip.c
+++ lvm2/lib/metadata/lv_manip.c
@@ -2806,8 +2806,6 @@ int lv_add_segmented_mirror_image(struct
 	}
 	lv->status |= MIRRORED;
 
-	/* FIXME: add log */
-
 	if (lv->vg->fid->fmt->ops->lv_setup &&
 	    !lv->vg->fid->fmt->ops->lv_setup(lv->vg->fid, lv))
 		return_0;
Index: lvm2/lib/metadata/mirror.c
===================================================================
--- lvm2.orig/lib/metadata/mirror.c
+++ lvm2/lib/metadata/mirror.c
@@ -284,6 +284,7 @@ static int _init_mirror_log(struct cmd_c
 	struct dm_str_list *sl;
 	uint64_t orig_status = log_lv->status;
 	int was_active = 0;
+	const char *log_name = log_lv->name;
 
 	if (test_mode()) {
 		log_verbose("Test mode: Skipping mirror log initialisation.");
@@ -314,6 +315,14 @@ static int _init_mirror_log(struct cmd_c
 	/* Temporary make it visible for set_lv() */
 	lv_set_visible(log_lv);
 
+	/*
+	 * If this is a pvmove log, there are udev rules that prevent it
+	 * from becoming visible by name.  Therefore, we change the name
+	 * for the short duration we need in order to wipe the log.
+	 */
+	if (!strncmp(log_lv->name, "pvmove", 6))
+		log_lv->name = "visible_pvmove_log";
+
 	/* Temporary tag mirror log for activation */
 	dm_list_iterate_items(sl, tagsl)
 		if (!str_list_add(cmd->mem, &log_lv->tags, sl->str)) {
@@ -360,6 +369,7 @@ static int _init_mirror_log(struct cmd_c
 	}
 
 	lv_set_hidden(log_lv);
+	log_lv->name = log_name;
 
 	if (was_active && !activate_lv(cmd, log_lv))
 		return_0;
@@ -1693,6 +1703,9 @@ static int _add_mirrors_that_preserve_se
 	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
 		return_0;
 
+	if (!region_size)
+		region_size = get_default_region_size(lv->vg->cmd);
+
 	adjusted_region_size = adjusted_mirror_region_size(lv->vg->extent_size,
 							   lv->le_count,
 							   region_size);
@@ -1720,6 +1733,13 @@ static int _add_mirrors_that_preserve_se
 		r = 0;
 	}
 	alloc_destroy(ah);
+
+	if ((flags & MIRROR_BY_SEGMENTED_LV) &&
+	    !add_mirror_log(cmd, lv, 1, first_seg(lv)->region_size,
+			    allocatable_pvs, alloc)) {
+		log_error("Failed to create persistent log\n");
+		log_error("Progress of pvmove will not be saved if deactivated.");
+	}
 	return r;
 }
 



