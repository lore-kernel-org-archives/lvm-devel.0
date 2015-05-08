From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  8 May 2015 16:49:53 +0000 (UTC)
Subject: master - lvmcache: choose preferred device once
Message-ID: <20150508164953.D2F4560F07@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f25132b354b110994b9da8dc3edf39cf4db37657
Commit:        f25132b354b110994b9da8dc3edf39cf4db37657
Parent:        1dfedcc179b6f7caee1069974ab34ddd111ef01d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 6 14:49:44 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 8 11:44:49 2015 -0500

lvmcache: choose preferred device once

Once the preferred duplicate devices have been set in
lvmcache, don't attempt to pick preferred duplicates
again.
---
 lib/cache/lvmcache.c |   58 ++++++++++++++++++++++++++++++++++++++++++++++++-
 lib/cache/lvmcache.h |    2 +
 lib/cache/lvmetad.c  |   19 ++++++++-------
 3 files changed, 68 insertions(+), 11 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 0d13c16..1586f30 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -67,6 +67,7 @@ struct lvmcache_vginfo {
 	unsigned vg_use_count;	/* Counter of vg reusage */
 	unsigned precommitted;	/* Is vgmetadata live or precommitted? */
 	unsigned cached_vg_invalidated;	/* Signal to regenerate cached_vg */
+	unsigned preferred_duplicates; /* preferred duplicate pvs have been set */
 };
 
 static struct dm_hash_table *_pvid_hash = NULL;
@@ -115,6 +116,47 @@ int lvmcache_init(void)
 	return 1;
 }
 
+/*
+ * Once PV info has been populated in lvmcache and
+ * lvmcache has chosen preferred duplicate devices,
+ * set this flag so that lvmcache will not try to
+ * compare and choose preferred duplicate devices
+ * again (which may result in different preferred
+ * devices.)  PV info can be populated in lvmcache
+ * multiple times, each time causing lvmcache to
+ * compare the duplicate devices, so we need to
+ * record that the comparison/preferences have
+ * already been done, so the preferrences from the
+ * first time through are not changed.
+ *
+ * This is something of a hack to work around the
+ * fact that the code isn't really designed to
+ * handle duplicate PVs, and the fact that lvmetad
+ * has its own way of picking a preferred duplicate
+ * and lvmcache has another way based on having
+ * more information than lvmetad does.
+ *
+ * If we come up with a better overall method to
+ * handle duplicate PVs, then this can probably be
+ * removed.
+ *
+ * FIXME: if we want to make lvmetad work with clvmd,
+ * then this may need to be changed to set
+ * preferred_duplicates back to 0.
+ */
+
+void lvmcache_set_preferred_duplicates(const char *vgid)
+{
+	struct lvmcache_vginfo *vginfo;
+
+	if (!(vginfo = lvmcache_vginfo_from_vgid(vgid))) {
+		stack;
+		return;
+	}
+
+	vginfo->preferred_duplicates = 1;
+}
+
 void lvmcache_seed_infos_from_lvmetad(struct cmd_context *cmd)
 {
 	if (!lvmetad_active() || _has_scanned)
@@ -1689,6 +1731,18 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 					 dev_name(dev));
 			}
 
+			if (existing->vginfo->preferred_duplicates) {
+				/*
+				 * The preferred duplicate devs have already
+				 * been chosen during a previous populating of
+				 * lvmcache, so just use the existing preferences.
+				 */
+				log_verbose("Found duplicate PV %s: using existing dev %s",
+					    pvid_s,
+					    dev_name(existing->dev));
+				return NULL;
+			}
+
 			if (old_in_subsystem && !new_in_subsystem) {
 				/* Use old, ignore new. */
 				log_warn("Found duplicate PV %s: using %s not %s",
@@ -1741,7 +1795,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 					 pvid_s,
 					 dev_name(dev),
 					 dev_name(existing->dev));
-				log_warn("Using duplicate PV %s which is more recent, replacing %s",
+				log_warn("Using duplicate PV %s which is last seen, replacing %s",
 					 dev_name(dev),
 					 dev_name(existing->dev));
 
@@ -1754,7 +1808,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 					 pvid_s,
 					 dev_name(dev),
 					 dev_name(existing->dev));
-				log_warn("Using duplicate PV %s which is more recent, replacing %s",
+				log_warn("Using duplicate PV %s which is last seen, replacing %s",
 					 dev_name(dev),
 					 dev_name(existing->dev));
 			}
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 6c4c927..6a43204 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -171,4 +171,6 @@ void lvmcache_replace_dev(struct cmd_context *cmd, struct physical_volume *pv,
 
 int lvmcache_found_duplicate_pvs(void);
 
+void lvmcache_set_preferred_duplicates(const char *vgid);
+
 #endif
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 00a84b5..fd0630f 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -265,9 +265,9 @@ static int _read_mda(struct lvmcache_info *info,
 	return 0;
 }
 
-static struct lvmcache_info *_pv_populate_lvmcache(struct cmd_context *cmd,
-						   struct dm_config_node *cn,
-						   struct format_type *fmt, dev_t fallback)
+static int _pv_populate_lvmcache(struct cmd_context *cmd,
+				 struct dm_config_node *cn,
+				 struct format_type *fmt, dev_t fallback)
 {
 	struct device *dev, *dev_alternate, *dev_alternate_cache = NULL;
 	struct label *label;
@@ -293,7 +293,7 @@ static struct lvmcache_info *_pv_populate_lvmcache(struct cmd_context *cmd,
 
 	if (!fmt) {
 		log_error("PV %s not recognised. Is the device missing?", pvid_txt);
-		return NULL;
+		return 0;
 	}
 
 	dev = dev_cache_get_by_devt(devt, cmd->filter);
@@ -302,17 +302,17 @@ static struct lvmcache_info *_pv_populate_lvmcache(struct cmd_context *cmd,
 
 	if (!dev) {
 		log_warn("WARNING: Device for PV %s not found or rejected by a filter.", pvid_txt);
-		return NULL;
+		return 0;
 	}
 
 	if (!pvid_txt || !id_read_format(&pvid, pvid_txt)) {
 		log_error("Missing or ill-formatted PVID for PV: %s.", pvid_txt);
-		return NULL;
+		return 0;
 	}
 
 	if (vgid_txt) {
 		if (!id_read_format(&vgid, vgid_txt))
-			return_NULL;
+			return_0;
 	} else
 		strcpy((char*)&vgid, fmt->orphan_vg_name);
 
@@ -321,7 +321,7 @@ static struct lvmcache_info *_pv_populate_lvmcache(struct cmd_context *cmd,
 
 	if (!(info = lvmcache_add(fmt->labeller, (const char *)&pvid, dev,
 				  vgname, (const char *)&vgid, 0)))
-		return_NULL;
+		return_0;
 
 	lvmcache_get_label(info)->sector = label_sector;
 	lvmcache_get_label(info)->dev = dev;
@@ -390,7 +390,8 @@ static struct lvmcache_info *_pv_populate_lvmcache(struct cmd_context *cmd,
 		}
 	}
 
-	return info;
+	lvmcache_set_preferred_duplicates((const char *)&vgid);
+	return 1;
 }
 
 struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgname, const char *vgid)


