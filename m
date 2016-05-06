From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  6 May 2016 14:00:46 +0000 (UTC)
Subject: master - lvmetad: remove client side altdev code
Message-ID: <20160506140046.30E8860722@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=67da017fd2502138d0cc469f3aea320440353156
Commit:        67da017fd2502138d0cc469f3aea320440353156
Parent:        3d2fbfe243550b7801165f393d27e35044c1a56d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jan 29 15:36:55 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 6 09:00:00 2016 -0500

lvmetad: remove client side altdev code

This is no longer used since lvmetad no longer
keeps track of alternate devices for duplicate PVs,
but is simply disabled when duplicates appear.
---
 lib/cache/lvmcache.c |   42 ------------------------------------------
 lib/cache/lvmcache.h |    2 --
 lib/cache/lvmetad.c  |   43 ++-----------------------------------------
 3 files changed, 2 insertions(+), 85 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 8ac113f..4e89371 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -72,7 +72,6 @@ struct lvmcache_vginfo {
 	unsigned vg_use_count;	/* Counter of vg reusage */
 	unsigned precommitted;	/* Is vgmetadata live or precommitted? */
 	unsigned cached_vg_invalidated;	/* Signal to regenerate cached_vg */
-	unsigned preferred_duplicates; /* preferred duplicate pvs have been set */
 };
 
 static struct dm_hash_table *_pvid_hash = NULL;
@@ -122,47 +121,6 @@ int lvmcache_init(void)
 	return 1;
 }
 
-/*
- * Once PV info has been populated in lvmcache and
- * lvmcache has chosen preferred duplicate devices,
- * set this flag so that lvmcache will not try to
- * compare and choose preferred duplicate devices
- * again (which may result in different preferred
- * devices.)  PV info can be populated in lvmcache
- * multiple times, each time causing lvmcache to
- * compare the duplicate devices, so we need to
- * record that the comparison/preferences have
- * already been done, so the preferrences from the
- * first time through are not changed.
- *
- * This is something of a hack to work around the
- * fact that the code isn't really designed to
- * handle duplicate PVs, and the fact that lvmetad
- * has its own way of picking a preferred duplicate
- * and lvmcache has another way based on having
- * more information than lvmetad does.
- *
- * If we come up with a better overall method to
- * handle duplicate PVs, then this can probably be
- * removed.
- *
- * FIXME: if we want to make lvmetad work with clvmd,
- * then this may need to be changed to set
- * preferred_duplicates back to 0.
- */
-
-void lvmcache_set_preferred_duplicates(const char *vgid)
-{
-	struct lvmcache_vginfo *vginfo;
-
-	if (!(vginfo = lvmcache_vginfo_from_vgid(vgid))) {
-		stack;
-		return;
-	}
-
-	vginfo->preferred_duplicates = 1;
-}
-
 void lvmcache_seed_infos_from_lvmetad(struct cmd_context *cmd)
 {
 	if (!lvmetad_used() || _has_scanned)
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 0ebbe07..f62607f 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -198,8 +198,6 @@ void lvmcache_replace_dev(struct cmd_context *cmd, struct physical_volume *pv,
 
 int lvmcache_found_duplicate_pvs(void);
 
-void lvmcache_set_preferred_duplicates(const char *vgid);
-
 int lvmcache_contains_lock_type_sanlock(struct cmd_context *cmd);
 
 void lvmcache_get_max_name_lengths(struct cmd_context *cmd,
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 6c7bddd..86ccd59 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -665,17 +665,14 @@ static int _pv_populate_lvmcache(struct cmd_context *cmd,
 				 struct dm_config_node *cn,
 				 struct format_type *fmt, dev_t fallback)
 {
-	struct device *dev, *dev_alternate, *dev_alternate_cache = NULL;
-	struct label *label;
+	struct device *dev;
 	struct id pvid, vgid;
 	char mda_id[32];
 	char da_id[32];
 	int i = 0;
 	struct dm_config_node *mda, *da;
-	struct dm_config_node *alt_devices = dm_config_find_node(cn->child, "devices_alternate");
-	struct dm_config_value *alt_device = NULL;
 	uint64_t offset, size;
-	struct lvmcache_info *info, *info_alternate;
+	struct lvmcache_info *info;
 	const char *pvid_txt = dm_config_find_str(cn->child, "id", NULL),
 		   *vgid_txt = dm_config_find_str(cn->child, "vgid", NULL),
 		   *vgname = dm_config_find_str(cn->child, "vgname", NULL),
@@ -760,42 +757,6 @@ static int _pv_populate_lvmcache(struct cmd_context *cmd,
 		++i;
 	} while (da);
 
-	if (alt_devices)
-		alt_device = alt_devices->v;
-
-	while (alt_device) {
-		dev_alternate = dev_cache_get_by_devt(alt_device->v.i, cmd->filter);
-
-		log_verbose("PV on device %s (%d:%d %d) is also on device %s (%d:%d %d) %s",
-			    dev_name(dev),
-			    (int)MAJOR(devt), (int)MINOR(devt), (int)devt,
-			    dev_alternate ? dev_name(dev_alternate) : "unknown",
-			    (int)MAJOR(alt_device->v.i), (int)MINOR(alt_device->v.i), (int)alt_device->v.i,
-			    pvid_txt);
-
-		if (dev_alternate) {
-			if ((info_alternate = lvmcache_add(fmt->labeller, (const char *)&pvid, dev_alternate,
-							   vgname, (const char *)&vgid, 0))) {
-				dev_alternate_cache = dev_alternate;
-				info = info_alternate;
-				lvmcache_get_label(info)->dev = dev_alternate;
-			}
-		}
-		alt_device = alt_device->next;
-	}
-
-	/*
-	 * Update lvmcache with the info about the alternate device by
-	 * reading its label, which should update lvmcache.
-	 */
-	if (dev_alternate_cache) {
-		if (!label_read(dev_alternate_cache, &label, 0)) {
-			log_warn("No PV label found on duplicate device %s.", dev_name(dev_alternate_cache));
-		}
-	}
-
-	lvmcache_set_preferred_duplicates((const char *)&vgid);
-
 	lvmcache_set_ext_flags(info, ext_flags);
 	lvmcache_set_ext_version(info, ext_version);
 


