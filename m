From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 24 Apr 2014 13:40:38 -0500
Subject: [POC PATCH] All or nothing pvmove.
Message-ID: <1398364838.26048.2.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

pvmove: Add ability to move LVs in all-or-none fashion

LVM's pvmove uses what might be called a migrating mirror.  That is, it
sets up the entire move but moves through each LV segment on a PV one at
a time.  At any point in time, the LV segments are either considered
DISABLED (haven't been addressed yet), RUNNING (currently performing the
copy), or COMPLETE (the copy is finished).  DISABLED segments are loaded
as linear targets on the source PV.  COMPLETE segments are loaded as
linear targets on the destination PV.  RUNNING segments are loaded as
mirror targets to perform the copy from source to destination.  If a
'pvmove --abort' is issued, DISABLED and RUNNING segments stay on the
source PV, while any COMPLETE segments stay on the destination PV.

The above is not always the desired behavior.  Some users may wish to
have an all-or-nothing approach.  That is, if the move needs to be aborted
or encounters a problem, the desire would be to have things go back to
the way they were - all on the source PV.  To achieve this, we simply
continue to use a mirror on COMPLETE segments.  We can use the 'nosync'
flag when creating the mirror because we know its contents have already
been copied.  This ensures that both the source and the destination
will continue to be updated with any writes that occur during the move
operation - making it safe to choose either one when aborting.

The attached patch is only a proof-of-concept that shows how we might go
about using 'nosync' mirrors for COMPLETE segments.  It does not yet
handle important topics, including:
- machine failure:  If there are outstanding writes to COMPLETE segments,
  we cannot simply use 'nosync' when restarting the pvmove.  This would
  lead to loss of data.  We could either use a log/bitmap with the mirror
  and not use 'nosync', or we could write a flag to the pvmove segment in
  the metadata that tells us whether the VG was shutdown cleanly or not.
  If cleanly, we can safely use 'nosync' on COMPLETE segments; otherwise,
  we cannot.
- abort:  I've not touched the code that would choose which PV to keep
  when aborting.
- CLI:  I've not done any work on a CLI to tell whether to use the old
  or new behavior.
- documentation

Index: lvm2/lib/mirror/mirrored.c
===================================================================
--- lvm2.orig/lib/mirror/mirrored.c
+++ lvm2/lib/mirror/mirrored.c
@@ -370,7 +370,10 @@ static int _add_log(struct dm_pool *mem,
 		log_flags |= DM_CORELOG;
 	}
 
-	if (mirror_in_sync() && !(seg->status & PVMOVE))
+	if (seg->status & PVMOVE) {
+		if (seg->extents_copied == seg->area_len) /* MIRR_COMPLETED */
+			log_flags |= DM_NOSYNC;
+	} else if (mirror_in_sync())
 		log_flags |= DM_NOSYNC;
 
 	if (_block_on_error_available && !(seg->status & PVMOVE))
@@ -391,7 +394,7 @@ static int _mirrored_add_target_line(str
 	unsigned start_area = 0u;
 	int mirror_status = MIRR_RUNNING;
 	uint32_t region_size;
-	int r;
+	int r, old_way = 0;
 
 	if (!*target_state &&
 	    !(*target_state = _mirrored_init_target(mem, cmd)))
@@ -414,7 +417,8 @@ static int _mirrored_add_target_line(str
 	if (seg->status & PVMOVE) {
 		if (seg->extents_copied == seg->area_len) {
 			mirror_status = MIRR_COMPLETED;
-			start_area = 1;
+			if (old_way)
+				start_area = 1;
 		} else if ((*pvmove_mirror_count)++) {
 			mirror_status = MIRR_DISABLED;
 			area_count = 1;
@@ -422,7 +426,8 @@ static int _mirrored_add_target_line(str
 		/* else MIRR_RUNNING */
 	}
 
-	if (mirror_status != MIRR_RUNNING) {
+	if ((mirror_status == MIRR_DISABLED) ||
+	    (old_way && (mirror_status != MIRR_RUNNING))) {
 		if (!add_linear_area_to_dtree(node, len, seg->lv->vg->extent_size,
 					      cmd->use_linear_target,
 					      seg->lv->vg->name, seg->lv->name))



