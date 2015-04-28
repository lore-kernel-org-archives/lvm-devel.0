From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 28 Apr 2015 15:44:22 +0000 (UTC)
Subject: master - devices: improve handling of duplicate PVs
Message-ID: <20150428154422.8B56860CDF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=beb229e1e8e8b95de09920195c2bc4171e89dc19
Commit:        beb229e1e8e8b95de09920195c2bc4171e89dc19
Parent:        6cc37275cebdc590f58bbd4e91110fe4d38801ce
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 24 14:58:58 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 28 10:41:32 2015 -0500

devices: improve handling of duplicate PVs

Example:

/dev/loop0 and /dev/loop1 are duplicates,
created by copying one backing file to the
other.

'identity /dev/loopX' creates an identity
mapping for loopX named idmloopX, which
adds a duplicate for the named device.

The duplicate selection code for lvmetad is
incomplete, and lvmetad is disabled for this
example.

[~]# losetup -f loopfile0
[~]# pvs
  PV         VG           Fmt  Attr PSize   PFree
  /dev/loop0 foo          lvm2 a--  308.00m 296.00m

[~]# losetup -f loopfile1
[~]# pvs
  Found duplicate PV LnSOEqzEYED3RvIOa5PZP2s7uyuBLmAV: using /dev/loop1 not /dev/loop0
  Using duplicate PV /dev/loop1 which is more recent, replacing /dev/loop0
  PV         VG           Fmt  Attr PSize   PFree
  /dev/loop1 foo          lvm2 a--  308.00m 308.00m

[~]# ./identity /dev/loop0
[~]# pvs
  Found duplicate PV LnSOEqzEYED3RvIOa5PZP2s7uyuBLmAV: using /dev/loop1 not /dev/loop0
  Using duplicate PV /dev/loop1 without holders, replacing /dev/loop0
  Found duplicate PV LnSOEqzEYED3RvIOa5PZP2s7uyuBLmAV: using /dev/mapper/idmloop0 not /dev/loop1
  Using duplicate PV /dev/mapper/idmloop0 from subsystem DM, replacing /dev/loop1
  PV                   VG           Fmt  Attr PSize   PFree
  /dev/mapper/idmloop0 foo          lvm2 a--  308.00m 296.00m

[~]# ./identity /dev/loop1
[~]# pvs
  WARNING: duplicate PV LnSOEqzEYED3RvIOa5PZP2s7uyuBLmAV is being used from both devices /dev/loop0 and /dev/loop1
  Found duplicate PV LnSOEqzEYED3RvIOa5PZP2s7uyuBLmAV: using /dev/loop1 not /dev/loop0
  Using duplicate PV /dev/loop1 which is more recent, replacing /dev/loop0
  Found duplicate PV LnSOEqzEYED3RvIOa5PZP2s7uyuBLmAV: using /dev/mapper/idmloop0 not /dev/loop1
  Using duplicate PV /dev/mapper/idmloop0 from subsystem DM, replacing /dev/loop1
  Found duplicate PV LnSOEqzEYED3RvIOa5PZP2s7uyuBLmAV: using /dev/mapper/idmloop1 not /dev/mapper/idmloop0
  Using duplicate PV /dev/mapper/idmloop1 which is more recent, replacing /dev/mapper/idmloop0
  PV                   VG           Fmt  Attr PSize   PFree
  /dev/mapper/idmloop1 foo          lvm2 a--  308.00m 308.00m
---
 lib/cache/lvmcache.c  |  248 ++++++++++++++++++++++++++++++++++++++++---------
 lib/cache/lvmetad.c   |   17 +++-
 lib/device/dev-type.c |    3 +
 3 files changed, 220 insertions(+), 48 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index c5f78c8..90e7b28 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1529,6 +1529,64 @@ void lvmcache_replace_dev(struct cmd_context *cmd, struct physical_volume *pv,
 	pv->dev = dev;
 }
 
+/*
+ * We can see multiple different devices with the
+ * same pvid, i.e. duplicates.
+ *
+ * There may be different reasons for seeing two
+ * devices with the same pvid:
+ * - multipath showing two paths to the same thing
+ * - one device copied to another, e.g. with dd,
+ *   also referred to as cloned devices.
+ * - a "subsystem" taking a device and creating
+ *   another device of its own that represents the
+ *   underlying device it is using, e.g. using dm
+ *   to create an identity mapping of a PV.
+ *
+ * Given duplicate devices, we have to choose one
+ * of them to be the "preferred" dev, i.e. the one
+ * that will be referenced in lvmcache, by pv->dev.
+ * We can keep the existing dev, that's currently
+ * used in lvmcache, or we can replace the existing
+ * dev with the new duplicate.
+ *
+ * Regardless of which device is preferred, we need
+ * to print messages explaining which devices were
+ * found so that a user can sort out for themselves
+ * what has happened if the preferred device is not
+ * the one they are interested in.
+ *
+ * If a user wants to use the non-preferred device,
+ * they will need to filter out the device that
+ * lvm is preferring.
+ *
+ * The dev_subsystem calls check if the major number
+ * of the dev is part of a subsystem like DM/MD/DRBD.
+ * A dev that's part of a subsystem is preferred over a
+ * duplicate of that dev that is not part of a
+ * subsystem.
+ *
+ * The has_holders calls check if the device is being
+ * used by another, and prefers one that's being used.
+ *
+ * FIXME: why do we prefer a device without holders
+ * over a device with holders?  We should understand
+ * the reason for that choice.
+ *
+ * FIXME: there may be other reasons to prefer one
+ * device over another:
+ *
+ * . are there other use/open counts we could check
+ *   beyond the holders?
+ *
+ * . check if either is bad/usable and prefer
+ *   the good one?
+ *
+ * . prefer the one with smaller minor number?
+ *   Might avoid disturbing things due to a new
+ *   transient duplicate?
+ */
+
 struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 				   struct device *dev,
 				   const char *vgname, const char *vgid,
@@ -1576,54 +1634,156 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 		lvmcache_del_bas(info);
 	} else {
 		if (existing->dev != dev) {
-			/* Is the existing entry a duplicate pvid e.g. md ? */
-			if (dev_subsystem_part_major(dt, existing->dev) &&
-			    !dev_subsystem_part_major(dt, dev)) {
-				log_very_verbose("Ignoring duplicate PV %s on "
-						 "%s - using %s %s",
-						 pvid, dev_name(dev),
-						 dev_subsystem_name(dt, existing->dev),
-						 dev_name(existing->dev));
-				return NULL;
-			} else if (dm_is_dm_major(MAJOR(existing->dev->dev)) &&
-				   !dm_is_dm_major(MAJOR(dev->dev))) {
-				log_very_verbose("Ignoring duplicate PV %s on "
-						 "%s - using dm %s",
-						 pvid, dev_name(dev),
-						 dev_name(existing->dev));
+			int old_in_subsystem = 0;
+			int new_in_subsystem = 0;
+			int old_is_dm = 0;
+			int new_is_dm = 0;
+			int old_has_holders = 0;
+			int new_has_holders = 0;
+
+			/*
+			 * Here are different devices with the same pvid:
+			 * duplicates.  See comment above.
+			 */
+
+			/*
+			 * This flag tells the process_each_pv code to search
+			 * the devices list for duplicates, so that devices
+			 * can be processed together with their duplicates
+			 * (while processing the VG, rather than reporting
+			 * pv->dev under the VG, and its duplicate outside
+			 * the VG context.)
+			 */
+			_found_duplicate_pvs = 1;
+
+			/*
+			 * The new dev may not have pvid set.
+			 * The process_each_pv code needs to have the pvid
+			 * set in each device to detect that the devices
+			 * are duplicates.
+			 */
+			strncpy(dev->pvid, pvid_s, sizeof(dev->pvid));
+
+			/*
+			 * Now decide if we are going to ignore the new
+			 * device, or replace the existing/old device in
+			 * lvmcache with the new one.
+			 */
+			old_in_subsystem = dev_subsystem_part_major(dt, existing->dev);
+			new_in_subsystem = dev_subsystem_part_major(dt, dev);
+
+			old_is_dm = dm_is_dm_major(MAJOR(existing->dev->dev));
+			new_is_dm = dm_is_dm_major(MAJOR(dev->dev));
+
+			old_has_holders = dm_device_has_holders(MAJOR(existing->dev->dev), MINOR(existing->dev->dev));
+			new_has_holders = dm_device_has_holders(MAJOR(dev->dev), MINOR(dev->dev));
+
+			if (old_has_holders && new_has_holders) {
+				/*
+				 * This is not a selection of old or new, but
+				 * just a warning to be aware of.
+				 */
+				log_warn("WARNING: duplicate PV %s is being used from both devices %s and %s",
+					 pvid_s,
+					 dev_name(existing->dev),
+					 dev_name(dev));
+			}
+
+			if (old_in_subsystem && !new_in_subsystem) {
+				/* Use old, ignore new. */
+				log_warn("Found duplicate PV %s: using %s not %s",
+					 pvid_s,
+					 dev_name(existing->dev),
+					 dev_name(dev));
+				log_warn("Using duplicate PV %s from subsystem %s, ignoring %s",
+					 dev_name(existing->dev),
+					 dev_subsystem_name(dt, existing->dev),
+					 dev_name(dev));
 				return NULL;
-			} else if (!dev_subsystem_part_major(dt, existing->dev) &&
-				   dev_subsystem_part_major(dt, dev))
-				log_very_verbose("Duplicate PV %s on %s - "
-						 "using %s %s", pvid,
-						 dev_name(existing->dev),
-						 dev_subsystem_name(dt, existing->dev),
-						 dev_name(dev));
-			else if (!dm_is_dm_major(MAJOR(existing->dev->dev)) &&
-				 dm_is_dm_major(MAJOR(dev->dev)))
-				log_very_verbose("Duplicate PV %s on %s - "
-						 "using dm %s", pvid,
-						 dev_name(existing->dev),
-						 dev_name(dev));
-			/* FIXME If both dm, check dependencies */
-			//else if (dm_is_dm_major(MAJOR(existing->dev->dev)) &&
-				 //dm_is_dm_major(MAJOR(dev->dev)))
-				 //
-			else if (!strcmp(pvid_s, existing->dev->pvid)) {
-				log_error("Found duplicate PV %s: using %s not %s",
-					  pvid_s,
-					  dev_name(existing->dev),
-					  dev_name(dev));
-				strncpy(dev->pvid, pvid_s, sizeof(dev->pvid));
-				_found_duplicate_pvs = 1;
+
+			} else if (!old_in_subsystem && new_in_subsystem) {
+				/* Use new, replace old. */
+				log_warn("Found duplicate PV %s: using %s not %s",
+					 pvid_s,
+					 dev_name(dev),
+					 dev_name(existing->dev));
+				log_warn("Using duplicate PV %s from subsystem %s, replacing %s",
+					 dev_name(dev),
+					 dev_subsystem_name(dt, dev),
+					 dev_name(existing->dev));
+
+			} else if (old_has_holders && !new_has_holders) {
+				/* Use new, replace old. */
+				/* FIXME: why choose the one without olders? */
+				log_warn("Found duplicate PV %s: using %s not %s",
+					 pvid_s,
+					 dev_name(dev),
+					 dev_name(existing->dev));
+				log_warn("Using duplicate PV %s without holders, replacing %s",
+					 dev_name(dev),
+					 dev_name(existing->dev));
+
+			} else if (!old_has_holders && new_has_holders) {
+				/* Use old, ignore new. */
+				log_warn("Found duplicate PV %s: using %s not %s",
+					 pvid_s,
+					 dev_name(existing->dev),
+					 dev_name(dev));
+				log_warn("Using duplicate PV %s without holders, ignoring %s",
+					 dev_name(existing->dev),
+					 dev_name(dev));
 				return NULL;
+
+			} else if (old_is_dm && new_is_dm) {
+				/* Use new, replace old. */
+				/* FIXME: why choose the new instead of the old? */
+				log_warn("Found duplicate PV %s: using %s not %s",
+					 pvid_s,
+					 dev_name(dev),
+					 dev_name(existing->dev));
+				log_warn("Using duplicate PV %s which is more recent, replacing %s",
+					 dev_name(dev),
+					 dev_name(existing->dev));
+
+			} else if (!strcmp(pvid_s, existing->dev->pvid)) {
+				/* No criteria to use for preferring old or new. */
+				/* FIXME: why choose the new instead of the old? */
+				/* FIXME: a transient duplicate would be a reason
+				 * to select the old instead of the new. */
+				log_warn("Found duplicate PV %s: using %s not %s",
+					 pvid_s,
+					 dev_name(dev),
+					 dev_name(existing->dev));
+				log_warn("Using duplicate PV %s which is more recent, replacing %s",
+					 dev_name(dev),
+					 dev_name(existing->dev));
 			}
+		} else {
+			/*
+			 * The new dev is the same as the existing dev.
+			 *
+			 * FIXME: Why can't we just return NULL here if the
+			 * device already exists?  Things don't seem to work
+			 * if we do that for some reason.
+			 */
+			log_verbose("Found same device %s with same pvid %s",
+				    dev_name(existing->dev), pvid_s);
 		}
-		if (strcmp(pvid_s, existing->dev->pvid)) 
-			log_debug_cache("Updating pvid cache to %s (%s) from %s (%s)",
-					pvid_s, dev_name(dev),
-					existing->dev->pvid, dev_name(existing->dev));
-		/* Switch over to new preferred device */
+
+		/*
+		 * FIXME: when could this ever happen?
+		 * If this does happen, identify when/why here, and
+		 * if not, remove this code.
+		 */
+		if (strcmp(pvid_s, existing->dev->pvid))  {
+			log_warn("Replacing dev %s pvid %s with dev %s pvid %s",
+				 dev_name(existing->dev), existing->dev->pvid,
+				 dev_name(dev), pvid_s);
+		}
+
+		/*
+		 * Switch over to new preferred device.
+		 */
 		existing->dev = dev;
 		info = existing;
 		/* Has labeller changed? */
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 600a6cb..470a7b3 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -366,10 +366,19 @@ static struct lvmcache_info *_pv_populate_lvmcache(struct cmd_context *cmd,
 
 	while (alt_device) {
 		dev_alternate = dev_cache_get_by_devt(alt_device->v.i, cmd->filter);
-		if (dev_alternate)
-			lvmcache_add(fmt->labeller, (const char *)&pvid, dev_alternate,
-				     vgname, (const char *)&vgid, 0);
-		else
+		if (dev_alternate) {
+			if ((info = lvmcache_add(fmt->labeller, (const char *)&pvid, dev_alternate,
+						 vgname, (const char *)&vgid, 0))) {
+				/*
+				 * FIXME: when lvmcache_add returns non-NULL,
+				 * it means that it has made dev_alternate
+				 * the preferred device in lvmcache.
+				 * I think that means it should be followed
+				 * by the same steps done above?
+				 */
+				log_warn("lvmcache only partially updated for alternate device %s", dev_name(dev));
+			}
+		} else
 			log_warn("Duplicate of PV %s dev %s exists on unknown device %"PRId64 ":%" PRId64,
 				 pvid_txt, dev_name(dev), MAJOR(alt_device->v.i), MINOR(alt_device->v.i));
 		alt_device = alt_device->next;
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index d3407d1..5a4c658 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -225,6 +225,9 @@ int dev_subsystem_part_major(struct dev_types *dt, struct device *dev)
 
 const char *dev_subsystem_name(struct dev_types *dt, struct device *dev)
 {
+	if (MAJOR(dev->dev) == dt->device_mapper_major)
+		return "DM";
+
 	if (MAJOR(dev->dev) == dt->md_major)
 		return "MD";
 


