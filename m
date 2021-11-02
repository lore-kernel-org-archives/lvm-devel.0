From: David Teigland <teigland@sourceware.org>
Date: Tue,  2 Nov 2021 21:58:08 +0000 (GMT)
Subject: main - filter-sysfs: skip when device id is set
Message-ID: <20211102215808.034AD385840D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b5b0369e4decbd7e2b4a160ba8ebad4e8f8a4094
Commit:        b5b0369e4decbd7e2b4a160ba8ebad4e8f8a4094
Parent:        5d0964d127ea62da480cafc91fefe403dda86870
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 2 15:42:26 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 2 16:54:53 2021 -0500

filter-sysfs: skip when device id is set

When a device id is set for a device, using an idtype other
than devname, it means that sysfs has been used with the device
to match the device id.  So, checking for a sysfs entry for the
device in filter-sysfs is redundant.  For any other cases not
covered by this (e.g. devname ids), have filter-sysfs simply
stat /sys/dev/block/major:minor to test if the device exists
in sysfs.

The extensive processing done by filter-sysfs init is removed.
It was taking an immense amount of time with many devices, e.g.
. 1024 PVs in 520 VGs
. 520 concurrent vgchange -ay <vgname> commands
. vgchange scans only PVs in the named VG (based on pvs_online
  files from a pending patch)

A large number of the vgchange commands were taking over 1 min,
and nearly half of that time was used by filter-sysfs init.
With this patch, the vgchange commands take about half the time.
---
 lib/commands/toolcontext.c |  24 ++--
 lib/filters/filter-sysfs.c | 296 ++++-----------------------------------------
 2 files changed, 32 insertions(+), 288 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 1b7170de1..a0c78ddd6 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1143,19 +1143,6 @@ static struct dev_filter *_init_filter_chain(struct cmd_context *cmd)
 	 * Update MAX_FILTERS definition above when adding new filters.
 	 */
 
-	/*
-	 * sysfs filter. Only available on 2.6 kernels.  Non-critical.
-	 * Listed first because it's very efficient at eliminating
-	 * unavailable devices.
-	 *
-	 * TODO: I suspect that using the lvm_type and device_id
-	 * filters before this one may be more efficient.
-	 */
-	if (find_config_tree_bool(cmd, devices_sysfs_scan_CFG, NULL)) {
-		if ((filters[nr_filt] = sysfs_filter_create()))
-			nr_filt++;
-	}
-
 	/* internal filter used by command processing. */
 	if (!(filters[nr_filt] = internal_filter_create())) {
 		log_error("Failed to create internal device filter");
@@ -1195,6 +1182,17 @@ static struct dev_filter *_init_filter_chain(struct cmd_context *cmd)
 	}
 	nr_filt++;
 
+	/*
+	 * sysfs filter. Only available on 2.6 kernels.  Non-critical.
+	 * Eliminates unavailable devices.
+	 * TODO: this may be unnecessary now with device ids
+	 * (currently not used for devs match to device id using syfs)
+	 */
+	if (find_config_tree_bool(cmd, devices_sysfs_scan_CFG, NULL)) {
+		if ((filters[nr_filt] = sysfs_filter_create()))
+			nr_filt++;
+	}
+
 	/* usable device filter. Required. */
 	if (!(filters[nr_filt] = usable_filter_create(cmd, cmd->dev_types, FILTER_MODE_NO_LVMETAD))) {
 		log_error("Failed to create usabled device filter");
diff --git a/lib/filters/filter-sysfs.c b/lib/filters/filter-sysfs.c
index 32ac324dd..672211057 100644
--- a/lib/filters/filter-sysfs.c
+++ b/lib/filters/filter-sysfs.c
@@ -17,288 +17,49 @@
 
 #ifdef __linux__
 
-#include <sys/sysmacros.h>
-#include <dirent.h>
-
-static int _locate_sysfs_blocks(const char *sysfs_dir, char *path, size_t len,
-				unsigned *sysfs_depth)
+static int _accept_p(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
 {
+	char path[PATH_MAX];
+	const char *sysfs_dir;
 	struct stat info;
-	unsigned i;
-	static const struct dir_class {
-		const char path[32];
-		int depth;
-	} classes[] = {
-		/*
-		 * unified classification directory for all kernel subsystems
-		 *
-		 * /sys/subsystem/block/devices
-		 * |-- sda -> ../../../devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda
-		 * |-- sda1 -> ../../../devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda/sda1
-		 *  `-- sr0 -> ../../../devices/pci0000:00/0000:00:1f.2/host1/target1:0:0/1:0:0:0/block/sr0
-		 *
-		 */
-		{ "subsystem/block/devices", 0 },
-
-		/*
-		 * block subsystem as a class
-		 *
-		 * /sys/class/block
-		 * |-- sda -> ../../devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda
-		 * |-- sda1 -> ../../devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda/sda1
-		 *  `-- sr0 -> ../../devices/pci0000:00/0000:00:1f.2/host1/target1:0:0/1:0:0:0/block/sr0
-		 *
-		 */
-		{ "class/block", 0 },
-
-		/*
-		 * old block subsystem layout with nested directories
-		 *
-		 * /sys/block/
-		 * |-- sda
-		 * |   |-- capability
-		 * |   |-- dev
-		 * ...
-		 * |   |-- sda1
-		 * |   |   |-- dev
-		 * ...
-		 * |
-		 * `-- sr0
-		 *     |-- capability
-		 *     |-- dev
-		 * ...
-		 *
-		 */
-
-		{ "block", 1 }
-	};
-
-	for (i = 0; i < DM_ARRAY_SIZE(classes); ++i)
-		if ((dm_snprintf(path, len, "%s%s", sysfs_dir, classes[i].path) >= 0) &&
-		    (stat(path, &info) == 0)) {
-			*sysfs_depth = classes[i].depth;
-			return 1;
-		}
-
-	return 0;
-}
-
-/*----------------------------------------------------------------
- * We need to store a set of dev_t.
- *--------------------------------------------------------------*/
-struct entry {
-	struct entry *next;
-	dev_t dev;
-};
-
-#define SET_BUCKETS 64
-struct dev_set {
-	struct dm_pool *mem;
-	const char *sys_block;
-	unsigned sysfs_depth;
-	int initialised;
-	struct entry *slots[SET_BUCKETS];
-};
-
-static struct dev_set *_dev_set_create(struct dm_pool *mem,
-				       const char *sys_block,
-				       unsigned sysfs_depth)
-{
-	struct dev_set *ds;
-
-	if (!(ds = dm_pool_zalloc(mem, sizeof(*ds))))
-		return NULL;
-
-	ds->mem = mem;
-	if (!(ds->sys_block = dm_pool_strdup(mem, sys_block)))
-		return NULL;
-
-	ds->sysfs_depth = sysfs_depth;
-	ds->initialised = 0;
-
-	return ds;
-}
-
-static unsigned _hash_dev(dev_t dev)
-{
-	return (major(dev) ^ minor(dev)) & (SET_BUCKETS - 1);
-}
 
-/*
- * Doesn't check that the set already contains dev.
- */
-static int _set_insert(struct dev_set *ds, dev_t dev)
-{
-	struct entry *e;
-	unsigned h = _hash_dev(dev);
-
-	if (!(e = dm_pool_alloc(ds->mem, sizeof(*e))))
-		return 0;
-
-	e->next = ds->slots[h];
-	e->dev = dev;
-	ds->slots[h] = e;
-
-	return 1;
-}
+	dev->filtered_flags &= ~DEV_FILTERED_SYSFS;
 
-static int _set_lookup(struct dev_set *ds, dev_t dev)
-{
-	unsigned h = _hash_dev(dev);
-	struct entry *e;
+	/*
+	 * Any kind of device id other than devname has been set
+	 * using sysfs so we know that sysfs info exists for dev.
+	 */
+	if (dev->id && dev->id->idtype && (dev->id->idtype != DEV_ID_TYPE_DEVNAME))
+		return 1;
 
-	for (e = ds->slots[h]; e; e = e->next)
-		if (e->dev == dev)
+	sysfs_dir = dm_sysfs_dir();
+	if (sysfs_dir && *sysfs_dir) {
+		if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d",
+				sysfs_dir, (int)MAJOR(dev->dev), (int)MINOR(dev->dev)) < 0) {
+			log_debug("failed to create sysfs path");
 			return 1;
-
-	return 0;
-}
-
-/*----------------------------------------------------------------
- * filter methods
- *--------------------------------------------------------------*/
-static int _parse_dev(const char *file, FILE *fp, dev_t *result)
-{
-	unsigned major, minor;
-	char buffer[64];
-
-	if (!fgets(buffer, sizeof(buffer), fp)) {
-		log_error("Empty sysfs device file: %s", file);
-		return 0;
-	}
-
-	if (sscanf(buffer, "%u:%u", &major, &minor) != 2) {
-		log_error("Incorrect format for sysfs device file: %s.", file);
-		return 0;
-	}
-
-	*result = makedev(major, minor);
-	return 1;
-}
-
-static int _read_dev(const char *file, dev_t *result)
-{
-	int r;
-	FILE *fp;
-
-	if (!(fp = fopen(file, "r"))) {
-		log_sys_error("fopen", file);
-		return 0;
-	}
-
-	r = _parse_dev(file, fp, result);
-
-	if (fclose(fp))
-		log_sys_error("fclose", file);
-
-	return r;
-}
-
-/*
- * Recurse through sysfs directories, inserting any devs found.
- */
-static int _read_devs(struct dev_set *ds, const char *dir, unsigned sysfs_depth)
-{
-	struct dirent *d;
-	DIR *dr;
-	struct stat info;
-	char path[PATH_MAX];
-	char file[PATH_MAX];
-	dev_t dev = { 0 };
-	int r = 1;
-
-	if (!(dr = opendir(dir))) {
-		log_sys_error("opendir", dir);
-		return 0;
-	}
-
-	while ((d = readdir(dr))) {
-		if (!strcmp(d->d_name, ".") || !strcmp(d->d_name, ".."))
-			continue;
-
-		if (dm_snprintf(path, sizeof(path), "%s/%s", dir,
-				 d->d_name) < 0) {
-			log_warn("WARNING: sysfs path name too long: %s in %s.",
-				 d->d_name, dir);
-			continue;
 		}
 
-		/* devices have a "dev" file */
-		if (dm_snprintf(file, sizeof(file), "%s/dev", path) < 0) {
-			log_warn("WARNING: sysfs path name too long: %s in %s.",
-				 d->d_name, dir);
-			continue;
-		}
-
-		if (!stat(file, &info)) {
-			/* recurse if we found a device and expect subdirs */
-			if (sysfs_depth)
-				_read_devs(ds, path, sysfs_depth - 1);
-
-			/* add the device we have found */
-			if (_read_dev(file, &dev))
-				_set_insert(ds, dev);
+		if (lstat(path, &info)) {
+			log_debug_devs("%s: Skipping (sysfs)", dev_name(dev));
+			dev->filtered_flags |= DEV_FILTERED_SYSFS;
+			return 0;
 		}
 	}
 
-	if (closedir(dr))
-		log_sys_debug("closedir", dir);
-
-	return r;
-}
-
-static int _init_devs(struct dev_set *ds)
-{
-	if (!_read_devs(ds, ds->sys_block, ds->sysfs_depth)) {
-		ds->initialised = -1;
-		return 0;
-	}
-
-	ds->initialised = 1;
-
-	return 1;
-}
-
-
-static int _accept_p(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
-{
-	struct dev_set *ds = (struct dev_set *) f->private;
-
-	dev->filtered_flags &= ~DEV_FILTERED_SYSFS;
-
-	if (!ds->initialised)
-		_init_devs(ds);
-
-	/* Pass through if initialisation failed */
-	if (ds->initialised != 1)
-		return 1;
-
-	if (!_set_lookup(ds, dev->dev)) {
-		log_debug_devs("%s: Skipping (sysfs)", dev_name(dev));
-		dev->filtered_flags |= DEV_FILTERED_SYSFS;
-		return 0;
-	}
-
 	return 1;
 }
 
 static void _destroy(struct dev_filter *f)
 {
-	struct dev_set *ds = (struct dev_set *) f->private;
-
 	if (f->use_count)
 		log_error(INTERNAL_ERROR "Destroying sysfs filter while in use %u times.", f->use_count);
-
-	dm_pool_destroy(ds->mem);
+	free(f);
 }
 
 struct dev_filter *sysfs_filter_create(void)
 {
 	const char *sysfs_dir = dm_sysfs_dir();
-	char sys_block[PATH_MAX];
-	unsigned sysfs_depth;
-	struct dm_pool *mem;
-	struct dev_set *ds;
 	struct dev_filter *f;
 
 	if (!*sysfs_dir) {
@@ -306,26 +67,12 @@ struct dev_filter *sysfs_filter_create(void)
 		return NULL;
 	}
 
-	if (!_locate_sysfs_blocks(sysfs_dir, sys_block, sizeof(sys_block), &sysfs_depth))
-		return NULL;
-
-	if (!(mem = dm_pool_create("sysfs", 256))) {
-		log_error("sysfs pool creation failed");
-		return NULL;
-	}
-
-	if (!(ds = _dev_set_create(mem, sys_block, sysfs_depth))) {
-		log_error("sysfs dev_set creation failed");
-		goto bad;
-	}
-
-	if (!(f = dm_pool_zalloc(mem, sizeof(*f))))
+	if (!(f = zalloc(sizeof(*f))))
 		goto_bad;
 
 	f->passes_filter = _accept_p;
 	f->destroy = _destroy;
 	f->use_count = 0;
-	f->private = ds;
 	f->name = "sysfs";
 
 	log_debug_devs("Sysfs filter initialised.");
@@ -333,7 +80,6 @@ struct dev_filter *sysfs_filter_create(void)
 	return f;
 
  bad:
-	dm_pool_destroy(mem);
 	return NULL;
 }
 


