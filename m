From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jun 2019 17:08:33 -0400
Subject: master - create separate lvmcache update functions for read and write
Message-ID: <201906072108.x57L8XLn005288@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=45b164f62cae25da3ac4b9f0d4f87ecaee1575fa
Commit:        45b164f62cae25da3ac4b9f0d4f87ecaee1575fa
Parent:        027e0e92e6edcde98fd951286c21a29f22f3ec20
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 6 12:10:13 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 7 15:54:04 2019 -0500

create separate lvmcache update functions for read and write

The vg read and vg write cases need to update lvmcache
differently, so create separate functions for them.

The read case now handles checking for outdated mdas
and moves them aside into a new list to be repaired in
a subsequent commit.
---
 lib/cache/lvmcache.c    |  126 ++++++++++++++++++++++++++++++++++++++++++++++-
 lib/cache/lvmcache.h    |    3 +-
 lib/metadata/metadata.c |    6 +-
 3 files changed, 130 insertions(+), 5 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 3987173..08c0459 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1685,7 +1685,27 @@ int lvmcache_update_vgname_and_id(struct lvmcache_info *info, struct lvmcache_vg
 	return 1;
 }
 
-int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted)
+/*
+ * FIXME: quit trying to mirror changes that a command is making into lvmcache.
+ *
+ * First, it's complicated and hard to ensure it's done correctly in every case
+ * (it would be much easier and safer to just toss out what's in lvmcache and
+ * reread the info to recreate it from scratch instead of trying to make sure
+ * every possible discrete state change is correct.)
+ *
+ * Second, it's unnecessary if commands just use the vg they are modifying
+ * rather than also trying to get info from lvmcache.  The lvmcache state
+ * should be populated by label_scan, used to perform vg_read's, and then
+ * ignored (or dropped so it can't be used).
+ *
+ * lvmcache info is already used very little after a command begins its
+ * operation.  The code that's supposed to keep the lvmcache in sync with
+ * changes being made to disk could be half wrong and we wouldn't know it.
+ * That creates a landmine for someone who might try to use a bit of it that
+ * isn't being updated correctly.
+ */
+
+int lvmcache_update_vg_from_write(struct volume_group *vg)
 {
 	struct pv_list *pvl;
 	struct lvmcache_info *info;
@@ -1710,6 +1730,110 @@ int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted)
 }
 
 /*
+ * The lvmcache representation of a VG after label_scan can be incorrect
+ * because the label_scan does not use the full VG metadata to construct
+ * vginfo/info.  PVs that don't hold VG metadata weren't attached to the vginfo
+ * during label scan, and PVs with outdated metadata (claiming to be in the VG,
+ * but not listed in the latest metadata) were attached to the vginfo, but
+ * shouldn't be.  After vg_read() gets the full metdata in the form of a 'vg',
+ * this function is called to fix up the lvmcache representation of the VG
+ * using the 'vg'.
+ */
+
+int lvmcache_update_vg_from_read(struct volume_group *vg, unsigned precommitted)
+{
+	struct pv_list *pvl;
+	struct lvmcache_vginfo *vginfo;
+	struct lvmcache_info *info, *info2;
+	struct metadata_area *mda;
+	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
+	struct lvmcache_vgsummary vgsummary = {
+		.vgname = vg->name,
+		.vgstatus = vg->status,
+		.vgid = vg->id,
+		.system_id = vg->system_id,
+		.lock_type = vg->lock_type
+	};
+
+	if (!(vginfo = lvmcache_vginfo_from_vgname(vg->name, (const char *)&vg->id))) {
+		log_error(INTERNAL_ERROR "lvmcache_update_vg %s no vginfo", vg->name);
+		return 0;
+	}
+
+	/*
+	 * The label scan doesn't know when a PV with old metadata has been
+	 * removed from the VG.  Now with the vg we can tell, so remove the
+	 * info for a PV that has been removed from the VG with
+	 * vgreduce --removemissing.
+	 */
+	dm_list_iterate_items_safe(info, info2, &vginfo->infos) {
+		int found = 0;
+		dm_list_iterate_items(pvl, &vg->pvs) {
+			if (pvl->pv->dev != info->dev)
+				continue;
+			found = 1;
+			break;
+		}
+
+		if (found)
+			continue;
+
+		log_warn("WARNING: outdated PV %s seqno %u has been removed in current VG %s seqno %u.",
+			 dev_name(info->dev), info->summary_seqno, vg->name, vginfo->seqno);
+
+		_drop_vginfo(info, vginfo); /* remove from vginfo->infos */
+		dm_list_add(&vginfo->outdated_infos, &info->list);
+	}
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		(void) dm_strncpy(pvid_s, (char *) &pvl->pv->id, sizeof(pvid_s));
+
+		if (!(info = lvmcache_info_from_pvid(pvid_s, pvl->pv->dev, 0))) {
+			log_debug_cache("lvmcache_update_vg %s no info for %s %s",
+					vg->name,
+					(char *) &pvl->pv->id,
+					pvl->pv->dev ? dev_name(pvl->pv->dev) : "missing");
+			continue;
+		}
+
+		log_debug_cache("lvmcache_update_vg %s for info %s",
+				vg->name, dev_name(info->dev));
+		
+		/*
+		 * FIXME: use a different function that just attaches info's that
+		 * had no metadata onto the correct vginfo.
+		 *
+		 * info's for PVs without metadata were not connected to the
+		 * vginfo by label_scan, so do it here.
+		 */
+		if (!lvmcache_update_vgname_and_id(info, &vgsummary)) {
+			log_debug_cache("lvmcache_update_vg %s failed to update info for %s",
+					vg->name, dev_name(info->dev));
+		}
+
+		/*
+		 * Ignored mdas were not copied from info->mdas to
+		 * fid->metadata_areas... when create_text_instance (at the
+		 * start of vg_read) called lvmcache_fid_add_mdas_vg because at
+		 * that point the info's were not connected to the vginfo
+		 * (since label_scan didn't know this without metadata.)
+		 */
+		dm_list_iterate_items(mda, &info->mdas) {
+			if (!mda_is_ignored(mda))
+				continue;
+			log_debug("lvmcache_update_vg %s copy ignored mdas for %s", vg->name, dev_name(info->dev));
+			if (!lvmcache_fid_add_mdas_pv(info, vg->fid)) {
+				log_debug_cache("lvmcache_update_vg %s failed to update mdas for %s",
+					        vg->name, dev_name(info->dev));
+			}
+			break;
+		}
+	}
+
+	return 1;
+}
+
+/*
  * We can see multiple different devices with the
  * same pvid, i.e. duplicates.
  *
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index d4c19f9..1921709 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -84,7 +84,8 @@ void lvmcache_del_dev(struct device *dev);
 /* Update things */
 int lvmcache_update_vgname_and_id(struct lvmcache_info *info,
 				  struct lvmcache_vgsummary *vgsummary);
-int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted);
+int lvmcache_update_vg_from_read(struct volume_group *vg, unsigned precommitted);
+int lvmcache_update_vg_from_write(struct volume_group *vg);
 
 void lvmcache_lock_vgname(const char *vgname, int read_only);
 void lvmcache_unlock_vgname(const char *vgname);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 49c1e74..bd6ec4d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3098,7 +3098,7 @@ static int _vg_commit_mdas(struct volume_group *vg)
 
 		/* Update cache first time we succeed */
 		if (!failed && !cache_updated) {
-			lvmcache_update_vg(vg, 0);
+			lvmcache_update_vg_from_write(vg);
 			cache_updated = 1;
 		}
 	}
@@ -3993,7 +3993,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				 * If there is no precommitted metadata, committed metadata
 				 * is read and stored in the cache even if use_precommitted is set
 				 */
-				lvmcache_update_vg(correct_vg, correct_vg->status & PRECOMMITTED);
+				lvmcache_update_vg_from_read(correct_vg, correct_vg->status & PRECOMMITTED);
 
 				if (!(pvids = lvmcache_get_pvids(cmd, vgname, vgid))) {
 					release_vg(correct_vg);
@@ -4149,7 +4149,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	 * If there is no precommitted metadata, committed metadata
 	 * is read and stored in the cache even if use_precommitted is set
 	 */
-	lvmcache_update_vg(correct_vg, (correct_vg->status & PRECOMMITTED));
+	lvmcache_update_vg_from_read(correct_vg, (correct_vg->status & PRECOMMITTED));
 
 	if (inconsistent) {
 		/* FIXME Test should be if we're *using* precommitted metadata not if we were searching for it */


