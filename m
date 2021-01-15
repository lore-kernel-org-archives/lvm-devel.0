From: David Teigland <teigland@sourceware.org>
Date: Fri, 15 Jan 2021 22:32:27 +0000 (GMT)
Subject: main - devs: remove invalid path name aliases
Message-ID: <20210115223227.4ECF63854807@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=37227b8ad6ba67804f98cdadd0ed6f2b369ae656
Commit:        37227b8ad6ba67804f98cdadd0ed6f2b369ae656
Parent:        0534723a2de62da913dfd88d40ee6f8b8b93ac56
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 14 13:26:42 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jan 15 16:31:50 2021 -0600

devs: remove invalid path name aliases

Make dev_cache_get() verify aliases and drop any
that are invalid before returning a dev for a given
name.
---
 lib/device/dev-cache.c    | 161 ++++++++++++++++++++++++++++++++++++----------
 test/shell/dev-aliases.sh |  53 +++++++++++++++
 2 files changed, 179 insertions(+), 35 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index d5f18ff45..8082efac4 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1428,60 +1428,151 @@ struct device *dev_hash_get(const char *name)
 	return (struct device *) dm_hash_lookup(_cache.names, name);
 }
 
+static void _remove_alias(struct device *dev, const char *name)
+{
+	struct dm_str_list *strl;
+
+	dm_list_iterate_items(strl, &dev->aliases) {
+		if (!strcmp(strl->str, name)) {
+			dm_list_del(&strl->list);
+			return;
+		}
+	}
+}
+
+/*
+ * Check that paths for this dev still refer to the same dev_t.  This is known
+ * to drop invalid paths in the case where lvm deactivates an LV, which causes
+ * that LV path to go away, but that LV path is not removed from dev-cache (it
+ * probably should be).  Later a new path to a different LV is added to
+ * dev-cache, where the new LV has the same major:minor as the previously
+ * deactivated LV.  The new LV will find the existing struct dev, and that
+ * struct dev will have dev->aliases entries that refer to the name of the old
+ * deactivated LV.  Those old paths are all invalid and are dropped here.
+ */
+
+static void _verify_aliases(struct device *dev, const char *newname)
+{
+	struct dm_str_list *strl, *strl2;
+	struct stat st;
+
+	dm_list_iterate_items_safe(strl, strl2, &dev->aliases) {
+		/* newname was just stat'd and added by caller */
+		if (newname && !strcmp(strl->str, newname))
+			continue;
+
+		if (stat(strl->str, &st) || (st.st_rdev != dev->dev)) {
+			log_debug("Drop invalid path %s for %d:%d (new path %s).",
+				  strl->str, (int)MAJOR(dev->dev), (int)MINOR(dev->dev), newname ?: "");
+			dm_hash_remove(_cache.names, strl->str);
+			dm_list_del(&strl->list);
+		}
+	}
+}
+
 struct device *dev_cache_get(struct cmd_context *cmd, const char *name, struct dev_filter *f)
 {
-	struct stat buf;
-	struct device *d = (struct device *) dm_hash_lookup(_cache.names, name);
-	int info_available = 0;
-	int ret = 1;
+	struct device *dev = (struct device *) dm_hash_lookup(_cache.names, name);
+	struct stat st;
+	int ret;
 
-	if (d && (d->flags & DEV_REGULAR))
-		return d;
+	/*
+	 * DEV_REGULAR means that is "dev" is actually a file, not a device.
+	 * FIXME: I don't think dev-cache is used for files any more and this
+	 * can be dropped?
+	 */
+	if (dev && (dev->flags & DEV_REGULAR))
+		return dev;
+
+	/*
+	 * The requested path is invalid, remove any dev-cache
+	 * info for it.
+	 */
+	if (stat(name, &st)) {
+		if (dev) {
+			log_print("Device path %s is invalid for %d:%d %s.",
+				  name, (int)MAJOR(dev->dev), (int)MINOR(dev->dev), dev_name(dev));
 
-	/* If the entry's wrong, remove it */
-	if (stat(name, &buf) < 0) {
-		if (d)
 			dm_hash_remove(_cache.names, name);
-		log_sys_very_verbose("stat", name);
-		d = NULL;
-	} else
-		info_available = 1;
 
-	if (d && (buf.st_rdev != d->dev)) {
-		dm_hash_remove(_cache.names, name);
-		d = NULL;
-	}
+			_remove_alias(dev, name);
 
-	if (!d) {
-		_insert(name, info_available ? &buf : NULL, 0, obtain_device_list_from_udev());
-		d = (struct device *) dm_hash_lookup(_cache.names, name);
-		if (!d) {
-			log_debug_devs("Device name not found in dev_cache repeat dev_cache_scan for %s", name);
-			dev_cache_scan();
-			d = (struct device *) dm_hash_lookup(_cache.names, name);
+			/* Remove any other names in dev->aliases that are incorrect. */
+			_verify_aliases(dev, NULL);
 		}
+		return NULL;
 	}
 
-	if (!d)
+	if (!S_ISBLK(st.st_mode)) {
+		log_debug("Not a block device %s.", name);
 		return NULL;
+	}
 
-	if (d && (d->flags & DEV_REGULAR))
-		return d;
+	/*
+	 * dev-cache has incorrect info for the requested path.
+	 * Remove incorrect info and then add new dev-cache entry.
+	 */
+	if (dev && (st.st_rdev != dev->dev)) {
+		log_print("Device path %s does not match %d:%d %s.",
+			  name, (int)MAJOR(dev->dev), (int)MINOR(dev->dev), dev_name(dev));
+
+		dm_hash_remove(_cache.names, name);
+
+		_remove_alias(dev, name);
+
+		/* Remove any other names in dev->aliases that are incorrect. */
+		_verify_aliases(dev, NULL);
+
+		/* Add new dev-cache entry next. */
+		dev = NULL;
+	}
+
+	/*
+	 * Either add a new struct dev for st_rdev and name,
+	 * or add name as a new alias for an existing struct dev
+	 * for st_rdev.
+	 */
+	if (!dev) {
+		_insert_dev(name, st.st_rdev);
 
-	if (f && !(d->flags & DEV_REGULAR)) {
-		ret = f->passes_filter(cmd, f, d, NULL);
+		/* Get the struct dev that was just added. */
+		dev = (struct device *) dm_hash_lookup(_cache.names, name);
 
-		if (ret == -EAGAIN) {
-			log_debug_devs("get device by name defer filter %s", dev_name(d));
-			d->flags |= DEV_FILTER_AFTER_SCAN;
-			ret = 1;
+		if (!dev) {
+			log_error("Failed to get device %s", name);
+			return NULL;
 		}
+
+		_verify_aliases(dev, name);
 	}
 
-	if (f && !(d->flags & DEV_REGULAR) && !ret)
+	/*
+	 * The caller passed a filter if they only want the dev if it
+	 * passes filters.
+	 */
+
+	if (!f)
+		return dev;
+
+	ret = f->passes_filter(cmd, f, dev, NULL);
+
+	/*
+	 * This might happen if this function is called before
+	 * filters can do i/o.  I don't think this will happen
+	 * any longer and this EAGAIN case can be removed.
+	 */
+	if (ret == -EAGAIN) {
+		log_debug_devs("dev_cache_get filter deferred %s", dev_name(dev));
+		dev->flags |= DEV_FILTER_AFTER_SCAN;
+		ret = 1;
+	}
+
+	if (!ret) {
+		log_debug_devs("dev_cache_get filter excludes %s", dev_name(dev));
 		return NULL;
+	}
 
-	return d;
+	return dev;
 }
 
 static struct device *_dev_cache_seek_devt(dev_t dev)
diff --git a/test/shell/dev-aliases.sh b/test/shell/dev-aliases.sh
new file mode 100644
index 000000000..c97cd5da2
--- /dev/null
+++ b/test/shell/dev-aliases.sh
@@ -0,0 +1,53 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_devs 3
+
+vgcreate $vg $dev1 $dev2 $dev3
+
+#
+# This lvconvert command will deactivate LV1, then internally create a new
+# lv, lvol0, as a poolmetadataspare, then activate lvol0 to zero it.
+# lvol0 will get the same major:minor that LV1 had.  When the code gets
+# the struct dev for lvol0, the new path to lvol0 is added to the
+# dev-cache with it's major:minor.  That major:minor already exists in
+# dev-cache and has the stale LV1 as an alias.  So the path to lvol0 is
+# added as an alias to the existing struct dev (with the correct
+# major:minor), but that struct dev has the stale LV1 path on its aliases
+# list.  The code will now validate all the aliases before returning the
+# dev for lvol0, and will find that the LV1 path is stale and remove it
+# from the aliases.  That will prevent the stale path from being used for
+# the dev in place of the new path.
+#
+# The preferred_name is set to /dev/mapper so that if the stale path still
+# exists, that stale path would be used as the name for the dev, and the
+# wiping code would fail to open that stale name.
+#
+
+lvcreate -n $lv1 -L32M $vg $dev1
+lvcreate -n $lv2 -L16M $vg $dev2
+lvconvert -y --type cache-pool --poolmetadata $lv2 --cachemode writeback $vg/$lv1 --config='devices { preferred_names=["/dev/mapper/"] }' 
+lvremove -y $vg/$lv1
+
+lvcreate -n $lv1 -L32M $vg $dev1
+lvcreate -n $lv2 -L16M $vg $dev2
+lvconvert -y --type cache-pool --poolmetadata $lv2 $vg/$lv1
+lvremove -y $vg/$lv1
+
+# TODO: add more validation of dev aliases being specified as command
+# args in combination with various preferred_names settings.
+
+vgremove -ff  $vg


