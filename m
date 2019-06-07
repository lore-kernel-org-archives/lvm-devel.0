From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jun 2019 17:08:08 -0400
Subject: master - keep track of which mdas have old metadata in lvmcache
Message-ID: <201906072108.x57L88Fw005229@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b2447e3538db370d1e12d328c25ca1f078ddabf6
Commit:        b2447e3538db370d1e12d328c25ca1f078ddabf6
Parent:        0b18c25d934564015402de33e15a267045ed1b8c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 5 13:09:56 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 7 15:54:04 2019 -0500

keep track of which mdas have old metadata in lvmcache

This will be used for more advanced repair in a
subsequent commit.
---
 lib/cache/lvmcache.c |  173 ++++++++++++++++++++++++++++++++++++++++----------
 lib/cache/lvmcache.h |   10 ++-
 2 files changed, 145 insertions(+), 38 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index a860660..f54eff0 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -42,6 +42,10 @@ struct lvmcache_info {
 	uint32_t status;
 	bool mda1_bad;		/* label scan found bad metadata in mda1 */
 	bool mda2_bad;		/* label scan found bad metadata in mda2 */
+	bool summary_seqno_mismatch; /* two mdas on this dev has mismatching metadata */
+	int summary_seqno;      /* vg seqno found on this dev during scan */
+	int mda1_seqno;
+	int mda2_seqno;
 };
 
 /* One per VG */
@@ -61,7 +65,7 @@ struct lvmcache_vginfo {
 	uint32_t mda_checksum;
 	size_t mda_size;
 	int seqno;
-	int scan_summary_mismatch; /* vgsummary from devs had mismatching seqno or checksum */
+	bool scan_summary_mismatch; /* vgsummary from devs had mismatching seqno or checksum */
 };
 
 static struct dm_hash_table *_pvid_hash = NULL;
@@ -1515,12 +1519,9 @@ int lvmcache_add_orphan_vginfo(const char *vgname, struct format_type *fmt)
 }
 
 /*
- * FIXME: get rid of other callers of this function which call it
- * in odd cases to "fix up" some bit of lvmcache state.  Make those
- * callers fix up what they need to directly, and leave this function
- * with one purpose and caller.
+ * Returning 0 causes the caller to remove the info struct for this
+ * device from lvmcache, which will make it look like a missing device.
  */
-
 int lvmcache_update_vgname_and_id(struct lvmcache_info *info, struct lvmcache_vgsummary *vgsummary)
 {
 	const char *vgname = vgsummary->vgname;
@@ -1546,6 +1547,7 @@ int lvmcache_update_vgname_and_id(struct lvmcache_info *info, struct lvmcache_vg
 	 * Puts the vginfo into the vgname hash table.
 	 */
 	if (!_lvmcache_update_vgname(info, vgname, vgid, vgsummary->vgstatus, vgsummary->creation_host, info->fmt)) {
+		/* shouldn't happen, internal error */
 		log_error("Failed to update VG %s info in lvmcache.", vgname);
 		return 0;
 	}
@@ -1554,6 +1556,7 @@ int lvmcache_update_vgname_and_id(struct lvmcache_info *info, struct lvmcache_vg
 	 * Puts the vginfo into the vgid hash table.
 	 */
 	if (!_lvmcache_update_vgid(info, info->vginfo, vgid)) {
+		/* shouldn't happen, internal error */
 		log_error("Failed to update VG %s info in lvmcache.", vgname);
 		return 0;
 	}
@@ -1569,50 +1572,114 @@ int lvmcache_update_vgname_and_id(struct lvmcache_info *info, struct lvmcache_vg
 	if (!vgsummary->seqno && !vgsummary->mda_size && !vgsummary->mda_checksum)
 		return 1;
 
+	/*
+	 * Keep track of which devs/mdas have old versions of the metadata.
+	 * The values we keep in vginfo are from the metadata with the largest
+	 * seqno.  One dev may have more recent metadata than another dev, and
+	 * one mda may have more recent metadata than the other mda on the same
+	 * device.
+	 *
+	 * When a device holds old metadata, the info struct for the device
+	 * remains in lvmcache, so the device is not treated as missing.
+	 * Also the mda struct containing the old metadata is kept on
+	 * info->mdas.  This means that vg_read will read metadata from
+	 * the mda again (and probably see the same old metadata).  It
+	 * also means that vg_write will use the mda to write new metadata
+	 * into the mda that currently has the old metadata.
+	 */
+	if (vgsummary->mda_num == 1)
+		info->mda1_seqno = vgsummary->seqno;
+	else if (vgsummary->mda_num == 2)
+		info->mda2_seqno = vgsummary->seqno;
+
+	if (!info->summary_seqno)
+		info->summary_seqno = vgsummary->seqno;
+	else {
+		if (info->summary_seqno == vgsummary->seqno) {
+			/* This mda has the same metadata as the prev mda on this dev. */
+			return 1;
+
+		} else if (info->summary_seqno > vgsummary->seqno) {
+			/* This mda has older metadata than the prev mda on this dev. */
+			info->summary_seqno_mismatch = true;
+
+		} else if (info->summary_seqno < vgsummary->seqno) {
+			/* This mda has newer metadata than the prev mda on this dev. */
+			info->summary_seqno_mismatch = true;
+			info->summary_seqno = vgsummary->seqno;
+		}
+	}
+
+	/* this shouldn't happen */
 	if (!(vginfo = info->vginfo))
 		return 1;
 
 	if (!vginfo->seqno) {
 		vginfo->seqno = vgsummary->seqno;
+		vginfo->mda_checksum = vgsummary->mda_checksum;
+		vginfo->mda_size = vgsummary->mda_size;
 
-		log_debug_cache("lvmcache %s: VG %s: set seqno to %d",
-				dev_name(info->dev), vginfo->vgname, vginfo->seqno);
+		log_debug_cache("lvmcache %s mda%d VG %s set seqno %u checksum %x mda_size %zu",
+				dev_name(info->dev), vgsummary->mda_num, vgname,
+				vgsummary->seqno, vgsummary->mda_checksum, vgsummary->mda_size);
+		goto update_vginfo;
+
+	} else if (vgsummary->seqno < vginfo->seqno) {
+		vginfo->scan_summary_mismatch = true;
 
-	} else if (vgsummary->seqno != vginfo->seqno) {
-		log_warn("Scan of VG %s from %s found metadata seqno %d vs previous %d.",
-			 vgname, dev_name(info->dev), vgsummary->seqno, vginfo->seqno);
-		vginfo->scan_summary_mismatch = 1;
-		/* If we don't return success, this dev info will be removed from lvmcache,
-		   and then we won't be able to rescan it or repair it. */
+		log_debug_cache("lvmcache %s mda%d VG %s older seqno %u checksum %x mda_size %zu",
+				dev_name(info->dev), vgsummary->mda_num, vgname,
+				vgsummary->seqno, vgsummary->mda_checksum, vgsummary->mda_size);
 		return 1;
-	}
 
-	if (!vginfo->mda_size) {
+	} else if (vgsummary->seqno > vginfo->seqno) {
+		vginfo->scan_summary_mismatch = true;
+
+		/* Replace vginfo values with values from newer metadata. */
+		vginfo->seqno = vgsummary->seqno;
 		vginfo->mda_checksum = vgsummary->mda_checksum;
 		vginfo->mda_size = vgsummary->mda_size;
 
-		log_debug_cache("lvmcache %s: VG %s: set mda_checksum to %x mda_size to %zu",
-				dev_name(info->dev), vginfo->vgname,
-				vginfo->mda_checksum, vginfo->mda_size);
-
-	} else if ((vginfo->mda_size != vgsummary->mda_size) || (vginfo->mda_checksum != vgsummary->mda_checksum)) {
-		log_warn("Scan of VG %s from %s found mda_checksum %x mda_size %zu vs previous %x %zu",
-			 vgname, dev_name(info->dev), vgsummary->mda_checksum, vgsummary->mda_size,
-			 vginfo->mda_checksum, vginfo->mda_size);
-		vginfo->scan_summary_mismatch = 1;
-		/* If we don't return success, this dev info will be removed from lvmcache,
-		   and then we won't be able to rescan it or repair it. */
+		log_debug_cache("lvmcache %s mda%d VG %s newer seqno %u checksum %x mda_size %zu",
+				dev_name(info->dev), vgsummary->mda_num, vgname,
+				vgsummary->seqno, vgsummary->mda_checksum, vgsummary->mda_size);
+
+		goto update_vginfo;
+	} else {
+		/*
+		 * Same seqno as previous metadata we saw for this VG.
+		 * If the metadata somehow has a different checksum or size,
+		 * even though it has the same seqno, something has gone wrong.
+		 * FIXME: test this case: VG has two PVs, first goes missing,
+		 * second updated to seqno 4, first comes back and second goes
+		 * missing, first updated to seqno 4, second comes back, now
+		 * both are present with same seqno but different checksums.
+		 */
+
+		if ((vginfo->mda_size != vgsummary->mda_size) || (vginfo->mda_checksum != vgsummary->mda_checksum)) {
+			log_warn("WARNING: scan of VG %s from %s mda%d found mda_checksum %x mda_size %zu vs %x %zu",
+				 vgname, dev_name(info->dev), vgsummary->mda_num,
+				 vgsummary->mda_checksum, vgsummary->mda_size,
+				 vginfo->mda_checksum, vginfo->mda_size);
+			vginfo->scan_summary_mismatch = true;
+			return 0;
+		}
+
+		/*
+		 * The seqno and checksum matches what was previously seen;
+		 * the summary values have already been saved in vginfo.
+		 */
 		return 1;
 	}
 
-	/*
-	 * If a dev has an unmatching checksum, ignore the other
-	 * info from it, keeping the info we already saved.
-	 */
+ update_vginfo:
 	if (!_lvmcache_update_vgstatus(info, vgsummary->vgstatus, vgsummary->creation_host,
 				       vgsummary->lock_type, vgsummary->system_id)) {
+		/*
+		 * This shouldn't happen, it's an internal errror, and we can leave
+		 * the info in place without saving the summary values in vginfo.
+		 */
 		log_error("Failed to update VG %s info in lvmcache.", vgname);
-		return 0;
 	}
 
 	return 1;
@@ -2325,17 +2392,17 @@ int lvmcache_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const ch
  *    lvmcache: info for dev5 is deleted, FIXME: use a defective state
  */
 
-int lvmcache_scan_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid)
+bool lvmcache_scan_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid)
 {
 	struct lvmcache_vginfo *vginfo;
 
 	if (!vgname || !vgid)
-		return 1;
+		return true;
 
 	if ((vginfo = lvmcache_vginfo_from_vgid(vgid)))
 		return vginfo->scan_summary_mismatch;
 
-	return 1;
+	return true;
 }
 
 static uint64_t _max_metadata_size;
@@ -2394,6 +2461,42 @@ struct metadata_area *lvmcache_get_mda(struct cmd_context *cmd,
 	return NULL;
 }
 
+/*
+ * This is used by the metadata repair command to check if
+ * the metadata on a dev needs repair because it's old.
+ */
+bool lvmcache_has_old_metadata(struct cmd_context *cmd, const char *vgname, const char *vgid, struct device *dev)
+{
+	struct lvmcache_vginfo *vginfo;
+	struct lvmcache_info *info;
+
+	/* shouldn't happen */
+	if (!vgname || !vgid)
+		return false;
+
+	/* shouldn't happen */
+	if (!(vginfo = lvmcache_vginfo_from_vgid(vgid)))
+		return false;
+
+	/* shouldn't happen */
+	if (!(info = lvmcache_info_from_pvid(dev->pvid, NULL, 0)))
+		return false;
+
+	/* writing to a new PV */
+	if (!info->summary_seqno)
+		return false;
+
+	/* on same dev, one mda has newer metadata than the other */
+	if (info->summary_seqno_mismatch)
+		return true;
+
+	/* one or both mdas on this dev has older metadata than another dev */
+	if (vginfo->seqno > info->summary_seqno)
+		return true;
+
+	return false;
+}
+
 void lvmcache_get_outdated_devs(struct cmd_context *cmd,
 				const char *vgname, const char *vgid,
 				struct dm_list *devs)
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 0f83c80..16cbb48 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -57,10 +57,12 @@ struct lvmcache_vgsummary {
 	char *creation_host;
 	const char *system_id;
 	const char *lock_type;
+	uint32_t seqno;
 	uint32_t mda_checksum;
 	size_t mda_size;
-	int zero_offset;
-	int seqno;
+	int mda_num; /* 1 = summary from mda1, 2 = summary from mda2 */
+	unsigned mda_ignored:1;
+	unsigned zero_offset:1;
 };
 
 int lvmcache_init(struct cmd_context *cmd);
@@ -202,7 +204,7 @@ int lvmcache_get_vg_devs(struct cmd_context *cmd,
 			 struct dm_list *devs);
 void lvmcache_set_independent_location(const char *vgname);
 
-int lvmcache_scan_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid);
+bool lvmcache_scan_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid);
 
 int lvmcache_vginfo_has_pvid(struct lvmcache_vginfo *vginfo, char *pvid);
 
@@ -222,6 +224,8 @@ int dev_in_device_list(struct device *dev, struct dm_list *head);
 
 bool lvmcache_has_bad_metadata(struct device *dev);
 
+bool lvmcache_has_old_metadata(struct cmd_context *cmd, const char *vgname, const char *vgid, struct device *dev);
+
 void lvmcache_get_outdated_devs(struct cmd_context *cmd,
                                 const char *vgname, const char *vgid,
                                 struct dm_list *devs);


