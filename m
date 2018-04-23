From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:53:27 -0400
Subject: master - scan: skip device rescan in vg_read
Message-ID: <201804231353.w3NDrRPs001109@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aee27dc7bad5734012885fe9f174def0a3f26771
Commit:        aee27dc7bad5734012885fe9f174def0a3f26771
Parent:        7b0a8f47be7df13aab0552599aa2dc2233cc223c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 18 16:29:42 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:23:14 2018 -0500

scan: skip device rescan in vg_read

For reporting commands (pvs,vgs,lvs,pvdisplay,vgdisplay,lvdisplay)
we do not need to repeat the label scan of devices in vg_read if
they all had matching metadata in the initial label scan.  The
data read by label scan can just be reused for the vg_read.
This cuts the amount of device i/o in half, from two reads of
each device to one.  We have to be careful to avoid repairing
the VG if we've skipped rescanning.  (The VG repair code is very
poor, and will be redone soon.)
---
 lib/cache/lvmcache.c          |  207 +++++++++++++++++++++++++++++++---------
 lib/cache/lvmcache.h          |    3 +
 lib/commands/toolcontext.h    |    2 +
 lib/config/config.c           |    6 +
 lib/format_text/format-text.c |   19 ++++
 lib/format_text/import_vsn1.c |    6 +
 lib/format_text/text_label.c  |    7 ++
 lib/metadata/metadata.c       |   88 +++++++++++++++---
 test/shell/mda-rollback.sh    |    3 +
 tools/command.c               |    1 +
 tools/commands.h              |   12 +-
 tools/lvmcmdline.c            |    3 +
 tools/toollib.c               |    2 +-
 tools/tools.h                 |    4 +
 14 files changed, 295 insertions(+), 68 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index c8046f7..f1fd683 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -62,7 +62,9 @@ struct lvmcache_vginfo {
 	char *lock_type;
 	uint32_t mda_checksum;
 	size_t mda_size;
+	int seqno;
 	int independent_metadata_location; /* metadata read from independent areas */
+	int scan_summary_mismatch; /* vgsummary from devs had mismatching seqno or checksum */
 
 	/*
 	 * The following are not related to lvmcache or vginfo,
@@ -1057,25 +1059,34 @@ next:
  * the labels/metadata for each device in the VG now that we hold the
  * lock, and use this for processing the VG.
  *
- * FIXME: In some cases, the data read by label_scan may be fine, and not
- * need to be reread here. e.g. a reporting command, possibly with a
- * special option, could skip this second reread.  Or, we could look
- * at the VG seqno in each copy of the metadata read in the first label
- * scan, and if they all match, consider it good enough to use for
- * reporting without rereading it.  (A command modifying the VG would
- * always want to reread while the lock is held before modifying.)
- *
  * A label scan is ultimately creating associations between devices
  * and VGs so that when vg_read wants to get VG metadata, it knows
- * which devices to read.  In the special case where VG metadata is
- * stored in files on the file system (configured in lvm.conf), the
+ * which devices to read.
+ *
+ * It's possible that a VG is being modified during the first label
+ * scan, causing the scan to see inconsistent metadata on different
+ * devs in the VG.  It's possible that those modifications are
+ * adding/removing devs from the VG, in which case the device/VG
+ * associations in lvmcache after the scan are not correct.
+ * NB. It's even possible the VG was removed completely between
+ * label scan and here, in which case we'd not find the VG in
+ * lvmcache after this rescan.
+ *
+ * A scan will also create in incorrect/incomplete picture of a VG
+ * when devices have no metadata areas.  The scan does not use
+ * VG metadata to figure out that a dev with no metadata belongs
+ * to a particular VG, so a device with no mdas will not be linked
+ * to that VG after a scan.
+ *
+ * (In the special case where VG metadata is stored in files on the
+ * file system (configured in lvm.conf), the
  * vginfo->independent_metadata_location flag is set during label scan.
  * When we get here to rescan, we are revalidating the device to VG
  * mapping from label scan by repeating the label scan on a subset of
  * devices.  If we see independent_metadata_location is set from the
  * initial label scan, we know that there is nothing to do because
  * there is no device to VG mapping to revalidate, since the VG metadata
- * comes directly from files.
+ * comes directly from files.)
  */
 
 int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const char *vgid)
@@ -1083,7 +1094,7 @@ int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const
 	struct dm_list devs;
 	struct device_list *devl;
 	struct lvmcache_vginfo *vginfo;
-	struct lvmcache_info *info;
+	struct lvmcache_info *info, *info2;
 
 	if (lvmetad_used())
 		return 1;
@@ -1112,14 +1123,17 @@ int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const
 		dm_list_add(&devs, &devl->list);
 	}
 
-	label_scan_devs(cmd, &devs);
+	dm_list_iterate_items_safe(info, info2, &vginfo->infos)
+		lvmcache_del(info);
 
-	/*
-	 * TODO: grab vginfo again, and compare vginfo->infos
-	 * to what was found above before rereading labels.
-	 * If there are any info->devs now that were not in the
-	 * first devs list, then do label_read on those also.
-	 */
+	/* Dropping the last info struct is supposed to drop vginfo. */
+	if ((vginfo = lvmcache_vginfo_from_vgname(vgname, vgid)))
+		log_warn("VG info not dropped before rescan of %s", vgname);
+
+	/* FIXME: should we also rescan unused_duplicate_devs for devs
+	   being rescanned here and then repeat resolving the duplicates? */
+
+	label_scan_devs(cmd, &devs);
 
 	return 1;
 }
@@ -1803,28 +1817,6 @@ out:
 	return 1;
 }
 
-static int _lvmcache_update_vg_mda_info(struct lvmcache_info *info, uint32_t mda_checksum,
-					size_t mda_size)
-{
-	if (!info || !info->vginfo || !mda_size)
-		return 1;
-
-	if (info->vginfo->mda_checksum == mda_checksum || info->vginfo->mda_size == mda_size) 
-		return 1;
-
-	info->vginfo->mda_checksum = mda_checksum;
-	info->vginfo->mda_size = mda_size;
-
-	/* FIXME Add checksum index */
-
-	log_debug_cache("lvmcache %s: VG %s: stored metadata checksum 0x%08"
-			PRIx32 " with size %" PRIsize_t ".",
-			dev_name(info->dev), info->vginfo->vgname,
-			mda_checksum, mda_size);
-
-	return 1;
-}
-
 int lvmcache_add_orphan_vginfo(const char *vgname, struct format_type *fmt)
 {
 	if (!_lock_hash && !lvmcache_init()) {
@@ -1835,10 +1827,18 @@ int lvmcache_add_orphan_vginfo(const char *vgname, struct format_type *fmt)
 	return _lvmcache_update_vgname(NULL, vgname, vgname, 0, "", fmt);
 }
 
+/*
+ * FIXME: get rid of other callers of this function which call it
+ * in odd cases to "fix up" some bit of lvmcache state.  Make those
+ * callers fix up what they need to directly, and leave this function
+ * with one purpose and caller.
+ */
+
 int lvmcache_update_vgname_and_id(struct lvmcache_info *info, struct lvmcache_vgsummary *vgsummary)
 {
 	const char *vgname = vgsummary->vgname;
 	const char *vgid = (char *)&vgsummary->vgid;
+	struct lvmcache_vginfo *vginfo;
 
 	if (!vgname && !info->vginfo) {
 		log_error(INTERNAL_ERROR "NULL vgname handed to cache");
@@ -1853,12 +1853,80 @@ int lvmcache_update_vgname_and_id(struct lvmcache_info *info, struct lvmcache_vg
 	    !is_orphan_vg(info->vginfo->vgname) && critical_section())
 		return 1;
 
-	if (!_lvmcache_update_vgname(info, vgname, vgid, vgsummary->vgstatus,
-				     vgsummary->creation_host, info->fmt) ||
-	    !_lvmcache_update_vgid(info, info->vginfo, vgid) ||
-	    !_lvmcache_update_vgstatus(info, vgsummary->vgstatus, vgsummary->creation_host, vgsummary->lock_type, vgsummary->system_id) ||
-	    !_lvmcache_update_vg_mda_info(info, vgsummary->mda_checksum, vgsummary->mda_size))
-		return_0;
+	/*
+	 * Creates a new vginfo struct for this vgname/vgid if none exists,
+	 * and attaches the info struct for the dev to the vginfo.
+	 * Puts the vginfo into the vgname hash table.
+	 */
+	if (!_lvmcache_update_vgname(info, vgname, vgid, vgsummary->vgstatus, vgsummary->creation_host, info->fmt)) {
+		log_error("Failed to update VG %s info in lvmcache.", vgname);
+		return 0;
+	}
+
+	/*
+	 * Puts the vginfo into the vgid hash table.
+	 */
+	if (!_lvmcache_update_vgid(info, info->vginfo, vgid)) {
+		log_error("Failed to update VG %s info in lvmcache.", vgname);
+		return 0;
+	}
+
+	/*
+	 * FIXME: identify which case this is and why this is needed, then
+	 * change that so it doesn't use this function and we can remove
+	 * this special case.
+	 * (I think this distinguishes the scan path, where these things
+	 * are set from the vg_read path where lvmcache_update_vg() is
+	 * called which calls this function without seqno/mda_size/mda_checksum.)
+	 */
+	if (!vgsummary->seqno && !vgsummary->mda_size && !vgsummary->mda_checksum)
+		return 1;
+
+	if (!(vginfo = info->vginfo))
+		return 1;
+
+	if (!vginfo->seqno) {
+		vginfo->seqno = vgsummary->seqno;
+
+		log_debug_cache("lvmcache %s: VG %s: set seqno to %d",
+				dev_name(info->dev), vginfo->vgname, vginfo->seqno);
+
+	} else if (vgsummary->seqno != vginfo->seqno) {
+		log_warn("Scan of VG %s from %s found metadata seqno %d vs previous %d.",
+			 vgname, dev_name(info->dev), vgsummary->seqno, vginfo->seqno);
+		vginfo->scan_summary_mismatch = 1;
+		/* If we don't return success, this dev info will be removed from lvmcache,
+		   and then we won't be able to rescan it or repair it. */
+		return 1;
+	}
+
+	if (!vginfo->mda_size) {
+		vginfo->mda_checksum = vgsummary->mda_checksum;
+		vginfo->mda_size = vgsummary->mda_size;
+
+		log_debug_cache("lvmcache %s: VG %s: set mda_checksum to %x mda_size to %zu",
+				dev_name(info->dev), vginfo->vgname,
+				vginfo->mda_checksum, vginfo->mda_size);
+
+	} else if ((vginfo->mda_size != vgsummary->mda_size) || (vginfo->mda_checksum != vgsummary->mda_checksum)) {
+		log_warn("Scan of VG %s from %s found mda_checksum %x mda_size %zu vs previous %x %zu",
+			 vgname, dev_name(info->dev), vgsummary->mda_checksum, vgsummary->mda_size,
+			 vginfo->mda_checksum, vginfo->mda_size);
+		vginfo->scan_summary_mismatch = 1;
+		/* If we don't return success, this dev info will be removed from lvmcache,
+		   and then we won't be able to rescan it or repair it. */
+		return 1;
+	}
+
+	/*
+	 * If a dev has an unmatching checksum, ignore the other
+	 * info from it, keeping the info we already saved.
+	 */
+	if (!_lvmcache_update_vgstatus(info, vgsummary->vgstatus, vgsummary->creation_host,
+				       vgsummary->lock_type, vgsummary->system_id)) {
+		log_error("Failed to update VG %s info in lvmcache.", vgname);
+		return 0;
+	}
 
 	return 1;
 }
@@ -2532,6 +2600,7 @@ int lvmcache_lookup_mda(struct lvmcache_vgsummary *vgsummary)
 			vgsummary->vgname = vginfo->vgname;
 			vgsummary->creation_host = vginfo->creation_host;
 			vgsummary->vgstatus = vginfo->status;
+			vgsummary->seqno = vginfo->seqno;
 			/* vginfo->vgid has 1 extra byte then vgsummary->vgid */
 			memcpy(&vgsummary->vgid, vginfo->vgid, sizeof(vgsummary->vgid));
 
@@ -2592,3 +2661,47 @@ int lvmcache_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const ch
 	return ret;
 }
 
+/*
+ * Example of reading four devs in sequence from the same VG:
+ *
+ * dev1:
+ *    lvmcache: creates vginfo with initial values
+ *
+ * dev2: all checksums match.
+ *    mda_header checksum matches vginfo from dev1
+ *    metadata checksum matches vginfo from dev1
+ *    metadata is not parsed, and the vgsummary values copied
+ *    from lvmcache from dev1 and passed back to lvmcache for dev2.
+ *    lvmcache: attach info for dev2 to existing vginfo
+ *
+ * dev3: mda_header and metadata have unmatching checksums.
+ *    mda_header checksum matches vginfo from dev1
+ *    metadata checksum doesn't match vginfo from dev1
+ *    produces read error in config.c
+ *    lvmcache: info for dev3 is deleted, FIXME: use a defective state
+ *
+ * dev4: mda_header and metadata have matching checksums, but
+ *       does not match checksum in lvmcache from prev dev.
+ *    mda_header checksum doesn't match vginfo from dev1
+ *    lvmcache_lookup_mda returns 0, no vgname, no checksum_only
+ *    lvmcache: update_vgname_and_id sees checksum from dev4 does not
+ *    match vginfo from dev1, so vginfo->scan_summary_mismatch is set.
+ *    attach info for dev4 to existing vginfo
+ *
+ * dev5: config parsing error.
+ *    lvmcache: info for dev5 is deleted, FIXME: use a defective state
+ */
+
+int lvmcache_scan_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid)
+{
+	struct lvmcache_vginfo *vginfo;
+
+	if (!vgname || !vgid)
+		return 1;
+
+	if ((vginfo = lvmcache_vginfo_from_vgid(vgid)))
+		return vginfo->scan_summary_mismatch;
+
+	return 1;
+}
+
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 107c993..ad478bd 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -60,6 +60,7 @@ struct lvmcache_vgsummary {
 	uint32_t mda_checksum;
 	size_t mda_size;
 	int zero_offset;
+	int seqno;
 };
 
 int lvmcache_init(void);
@@ -216,4 +217,6 @@ void lvmcache_save_suspended_vg(struct volume_group *vg, int precommitted);
 struct volume_group *lvmcache_get_suspended_vg(const char *vgid);
 void lvmcache_drop_suspended_vg(struct volume_group *vg);
 
+int lvmcache_scan_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid);
+
 #endif
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index d20cef1..2474264 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -169,6 +169,8 @@ struct cmd_context {
 	unsigned process_component_lvs:1;	/* command processes also component LVs */
 	unsigned mirror_warn_printed:1;		/* command already printed warning about non-monitored mirrors */
 	unsigned pvscan_cache_single:1;
+	unsigned can_use_one_scan:1;
+
 	/*
 	 * Filtering.
 	 */
diff --git a/lib/config/config.c b/lib/config/config.c
index d07c173..ad816c2 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -545,6 +545,12 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 		fb = buf;
 	}
 
+	/*
+	 * The checksum passed in is the checksum from the mda_header
+	 * preceding this metadata.  They should always match.
+	 * FIXME: handle case where mda_header checksum is bad,
+	 * but the checksum calculated here is correct.
+	 */
 	if (checksum_fn && checksum !=
 	    (checksum_fn(checksum_fn(INITIAL_CRC, (const uint8_t *)fb, size),
 			 (const uint8_t *)(fb + size), size2))) {
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 4146e7c..792d75a 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1261,8 +1261,27 @@ int read_metadata_location_summary(const struct format_type *fmt,
 	 * which also matches the checksum saved in vginfo from
 	 * another device, then it skips parsing the metadata into
 	 * a config tree, which saves considerable cpu time.
+	 *
+	 * (NB. there can be different VGs with different metadata
+	 * and checksums, but with the same name.)
+	 *
+	 * FIXME: handle the case where mda_header checksum is bad
+	 * but metadata checksum is good.
 	 */
 
+	/*
+	 * If the checksum we compute of the metadata differs from
+	 * the checksum from mda_header that we save here, then we
+	 * ignore the device.  FIXME: we need to classify a device
+	 * with errors like this as defective.
+	 *
+	 * If the checksum from mda_header and computed from metadata
+	 * does not match the checksum saved in lvmcache from a prev
+	 * device, then we do not skip parsing/saving metadata from
+	 * this dev.  It's parsed, fields saved in vgsummary, which
+	 * is passed into lvmcache (update_vgname_and_id), and
+	 * there we'll see a checksum mismatch.
+	 */
 	vgsummary->mda_checksum = rlocn->checksum;
 	vgsummary->mda_size = rlocn->size;
 	lvmcache_lookup_mda(vgsummary);
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index dee5379..e038a27 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -1292,6 +1292,12 @@ static int _read_vgsummary(const struct format_type *fmt, const struct dm_config
 	    (!(vgsummary->lock_type = dm_pool_strdup(mem, str))))
 		return_0;
 
+	if (!_read_int32(vgn, "seqno", &vgsummary->seqno)) {
+		log_error("Couldn't read seqno for volume group %s.",
+			  vgsummary->vgname);
+		return 0;
+	}
+
 	return 1;
 }
 
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index c47a35a..7d10e06 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -438,6 +438,13 @@ out:
 	baton.info = info;
 	baton.label = *label;
 
+	/*
+	 * In the vg_read phase, we compare all mdas and decide which to use
+	 * which are bad and need repair.
+	 *
+	 * FIXME: this quits if the first mda is bad, but we need something
+	 * smarter to be able to use the second mda if it's good.
+	 */
 	if (!lvmcache_foreach_mda(info, _read_mda_header_and_metadata, &baton)) {
 		log_error("Failed to scan VG from %s", dev_name(dev));
 		return 0;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 8c8ce25..685c589 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3761,6 +3761,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	struct pv_list *pvl;
 	struct dm_list all_pvs;
 	char uuid[64] __attribute__((aligned(8)));
+	int skipped_rescan = 0;
 
 	int reappeared = 0;
 	struct cached_vg_fmtdata *vg_fmtdata = NULL;	/* Additional format-specific data about the vg */
@@ -3834,10 +3835,42 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	 * lock is held, so we rescan all the info from the devs in case
 	 * something changed between the initial scan and now that the lock
 	 * is held.
+	 *
+	 * Some commands (e.g. reporting) are fine reporting data read by
+	 * the label scan.  It doesn't matter if the devs changed between
+	 * the label scan and here, we can report what was seen in the
+	 * scan, even though it is the old state, since we will not be
+	 * making any modifications.  If the VG was being modified during
+	 * the scan, and caused us to see inconsistent metadata on the
+	 * different PVs in the VG, then we do want to rescan the devs
+	 * here to get a consistent view of the VG.  Note that we don't
+	 * know if the scan found all the PVs in the VG at this point.
+	 * We don't know that until vg_read looks at the list of PVs in
+	 * the metadata and compares that to the devices found by the scan.
+	 *
+	 * It's possible that a change made to the VG during scan was
+	 * adding or removing a PV from the VG.  In this case, the list
+	 * of devices associated with the VG in lvmcache would change
+	 * due to the rescan.
+	 *
+	 * The devs in the VG may be persistently inconsistent due to some
+	 * previous problem.  In this case, rescanning the labels here will
+	 * find the same inconsistency.  The VG repair (mistakenly done by
+	 * vg_read below) is supposed to fix that.
+	 *
+	 * FIXME: sort out the usage of the global lock (which is mixed up
+	 * with the orphan lock), and when we can tell that the global
+	 * lock is taken prior to the label scan, and still held here,
+	 * we can also skip the rescan in that case.
 	 */
-	log_debug_metadata("Reading VG rereading labels for %s", vgname);
-
-	lvmcache_label_rescan_vg(cmd, vgname, vgid);
+	if (!cmd->can_use_one_scan || lvmcache_scan_mismatch(cmd, vgname, vgid)) {
+		skipped_rescan = 0;
+		log_debug_metadata("Rescanning devices for for %s", vgname);
+		lvmcache_label_rescan_vg(cmd, vgname, vgid);
+	} else {
+		log_debug_metadata("Skipped rescanning devices for %s", vgname);
+		skipped_rescan = 1;
+	}
 
 	if (!(fmt = lvmcache_fmt_from_vgname(cmd, vgname, vgid, 0))) {
 		log_debug_metadata("Cache did not find fmt for vgname %s", vgname);
@@ -3940,10 +3973,8 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
 		/* FIXME Also ensure contents same - checksum compare? */
 		if (correct_vg->seqno != vg->seqno) {
-			if (cmd->metadata_read_only)
-				log_very_verbose("Not repairing VG %s metadata seqno (%d != %d) "
-						  "as global/metadata_read_only is set.",
-						  vgname, vg->seqno, correct_vg->seqno);
+			if (cmd->metadata_read_only || skipped_rescan)
+				log_warn("Not repairing metadata for VG %s.", vgname);
 			else
 				inconsistent = 1;
 
@@ -4004,7 +4035,29 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 						return_NULL;
 					}
 
-					log_debug_metadata("Empty mda found for VG %s.", vgname);
+					log_debug_metadata("Empty mda found for VG %s on %s.",
+							   vgname, dev_name(pvl->pv->dev));
+
+#if 0
+					/*
+					 * If we are going to do any repair we have to be using 
+					 * the latest metadata on disk, so we have to rescan devs
+					 * if we skipped that at the start of the vg_read.  We'll
+					 * likely come back through here, but without having
+					 * skipped_rescan.
+					 *
+					 * FIXME: in some cases we don't want to do this.
+					 */
+					if (skipped_rescan && cmd->can_use_one_scan) {
+						log_debug_metadata("Restarting read to rescan devs.");
+						cmd->can_use_one_scan = 0;
+						release_vg(correct_vg);
+						correct_vg = NULL;
+						lvmcache_del(info);
+						label_read(pvl->pv->dev, NULL, 0);
+						goto restart_scan;
+					}
+#endif
 
 					if (inconsistent_mdas)
 						continue;
@@ -4142,10 +4195,8 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			/* FIXME Also ensure contents same - checksums same? */
 			if (correct_vg->seqno != vg->seqno) {
 				/* Ignore inconsistent seqno if told to skip repair logic */
-				if (cmd->metadata_read_only)
-					log_very_verbose("Not repairing VG %s metadata seqno (%d != %d) "
-							  "as global/metadata_read_only is set.",
-							  vgname, vg->seqno, correct_vg->seqno);
+				if (cmd->metadata_read_only || skipped_rescan)
+					log_warn("Not repairing metadata for VG %s.", vgname);
 				else
 					inconsistent = 1;
 
@@ -4225,6 +4276,13 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			return correct_vg;
 		}
 
+		if (skipped_rescan) {
+			log_warn("Not repairing metadata for VG %s.", vgname);
+			_free_pv_list(&all_pvs);
+			release_vg(correct_vg);
+			return_NULL;
+		}
+
 		/* Don't touch if vgids didn't match */
 		if (inconsistent_vgid) {
 			log_warn("WARNING: Inconsistent metadata UUIDs found for "
@@ -4271,14 +4329,16 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	}
 
 	/* We have the VG now finally, check if PV ext info is in sync with VG metadata. */
-	if (!_check_or_repair_pv_ext(cmd, correct_vg, *consistent, &inconsistent_pvs)) {
+	if (!_check_or_repair_pv_ext(cmd, correct_vg,
+				     skipped_rescan ? 0 : *consistent,
+				     &inconsistent_pvs)) {
 		release_vg(correct_vg);
 		return_NULL;
 	}
 
 	*consistent = !inconsistent_pvs;
 
-	if (correct_vg && *consistent) {
+	if (correct_vg && *consistent && !skipped_rescan) {
 		if (update_old_pv_ext && !_vg_update_old_pv_ext_if_needed(correct_vg)) {
 			release_vg(correct_vg);
 			return_NULL;
diff --git a/test/shell/mda-rollback.sh b/test/shell/mda-rollback.sh
index dbfdc7d..34080fa 100644
--- a/test/shell/mda-rollback.sh
+++ b/test/shell/mda-rollback.sh
@@ -25,6 +25,9 @@ vgextend $vg1 "$dev1"
 
 dd if=badmda of="$dev1" bs=256K count=1
 
+# the vg_read in vgck (and other commands) will repair the metadata
+vgck $vg1
+
 # dev1 is part of vg1 (as witnessed by metadata on dev2 and dev3), but its mda
 # was corrupt (written over by a backup from time dev1 was an orphan)
 check pv_field "$dev1" vg_name $vg1
diff --git a/tools/command.c b/tools/command.c
index f3b5d82..377d03f 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -140,6 +140,7 @@ static inline int configtype_arg(struct cmd_context *cmd __attribute__((unused))
 #define ENABLE_DUPLICATE_DEVS    0x00000400
 #define DISALLOW_TAG_ARGS        0x00000800
 #define GET_VGNAME_FROM_OPTIONS  0x00001000
+#define CAN_USE_ONE_SCAN	 0x00002000
 
 /* create foo_CMD enums for command def ID's in command-lines.in */
 
diff --git a/tools/commands.h b/tools/commands.h
index 3d142c3..4af92c8 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -55,7 +55,7 @@ xx(lvcreate,
 
 xx(lvdisplay,
    "Display information about a logical volume",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN)
 
 xx(lvextend,
    "Add space to a logical volume",
@@ -99,7 +99,7 @@ xx(lvresize,
 
 xx(lvs,
    "Display information about logical volumes",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN)
 
 xx(lvscan,
    "List all logical volumes in all volume groups",
@@ -127,7 +127,7 @@ xx(pvdata,
 
 xx(pvdisplay,
    "Display various attributes of physical volume(s)",
-   PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH)
+   PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH | CAN_USE_ONE_SCAN)
 
 /* ALL_VGS_IS_DEFAULT is for polldaemon to find pvmoves in-progress using process_each_vg. */
 
@@ -145,7 +145,7 @@ xx(pvremove,
 
 xx(pvs,
    "Display information about physical volumes",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH | CAN_USE_ONE_SCAN)
 
 xx(pvscan,
    "List all physical volumes",
@@ -189,7 +189,7 @@ xx(vgcreate,
 
 xx(vgdisplay,
    "Display volume group information",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN)
 
 xx(vgexport,
    "Unregister volume group(s) from the system",
@@ -229,7 +229,7 @@ xx(vgrename,
 
 xx(vgs,
    "Display information about volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN)
 
 xx(vgscan,
    "Search for all volume groups",
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index c7ac4b6..0600b1c 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2291,6 +2291,9 @@ static int _get_current_settings(struct cmd_context *cmd)
 	if (cmd->cname->flags & LOCKD_VG_SH)
 		cmd->lockd_vg_default_sh = 1;
 
+	if (cmd->cname->flags & CAN_USE_ONE_SCAN)
+		cmd->can_use_one_scan = 1;
+
 	cmd->partial_activation = 0;
 	cmd->degraded_activation = 0;
 	activation_mode = find_config_tree_str(cmd, activation_mode_CFG, NULL);
diff --git a/tools/toollib.c b/tools/toollib.c
index e887f65..6b71f2d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2032,7 +2032,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 		    (!dm_list_empty(arg_tags) && str_list_match_list(arg_tags, &vg->tags, NULL))) &&
 		    select_match_vg(cmd, handle, vg) && _select_matches(handle)) {
 
-			log_very_verbose("Processing VG %s %s", vg_name, vg_uuid ? uuid : "");
+			log_very_verbose("Running command for VG %s %s", vg_name, vg_uuid ? uuid : "");
 
 			ret = process_single_vg(cmd, vg_name, vg, handle);
 			_update_selection_result(handle, &whole_selected);
diff --git a/tools/tools.h b/tools/tools.h
index d4d2fb2..5fe3ba8 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -136,6 +136,10 @@ struct arg_value_group_list {
 #define DISALLOW_TAG_ARGS        0x00000800
 /* Command may need to find VG name in an option value. */
 #define GET_VGNAME_FROM_OPTIONS  0x00001000
+/* The data read from disk by label scan can be used for vg_read. */
+#define CAN_USE_ONE_SCAN	 0x00002000
+
+
 void usage(const char *name);
 
 /* the argument verify/normalise functions */


