From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Oct 2007 11:31:23 -0000
Subject: LVM2 ./WHATS_NEW lib/filters/filter-sysfs.c
Message-ID: <20071010113123.4678.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-10-10 11:31:21

Modified files:
	.              : WHATS_NEW 
	lib/filters    : filter-sysfs.c 

Log message:
	Handle new sysfs subsystem/block/devices directory structure.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.717&r2=1.718
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-sysfs.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/WHATS_NEW	2007/10/09 13:13:05	1.717
+++ LVM2/WHATS_NEW	2007/10/10 11:31:21	1.718
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Handle new sysfs subsystem/block/devices directory structure.
   Tests are run with LVM_SYSTEM_DIR pointing to private root and /dev dirs.
   Fix a bug in lvm_dump.sh checks for lvm/dmsetup binaries.
   Fix underquotations in lvm_dump.sh.
--- LVM2/lib/filters/filter-sysfs.c	2007/08/22 14:38:16	1.17
+++ LVM2/lib/filters/filter-sysfs.c	2007/10/10 11:31:21	1.18
@@ -20,12 +20,14 @@
 
 #include <dirent.h>
 
-static int _locate_sysfs_blocks(const char *proc, char *path, size_t len)
+static int _locate_sysfs_blocks(const char *proc, char *path, size_t len,
+				unsigned *sysfs_depth)
 {
 	char proc_mounts[PATH_MAX];
-	int r = 0;
 	FILE *fp;
 	char *split[4], buffer[PATH_MAX + 16];
+	const char *sys_mnt = NULL;
+	struct stat info;
 
 	if (!*proc) {
 		log_verbose("No proc filesystem found: skipping sysfs filter");
@@ -46,10 +48,7 @@
 	while (fgets(buffer, sizeof(buffer), fp)) {
 		if (dm_split_words(buffer, 4, 0, split) == 4 &&
 		    !strcmp(split[2], "sysfs")) {
-			if (dm_snprintf(path, len, "%s/%s", split[1],
-					 "block") >= 0) {
-				r = 1;
-			}
+			sys_mnt = split[1];
 			break;
 		}
 	}
@@ -57,7 +56,70 @@
 	if (fclose(fp))
 		log_sys_error("fclose", proc_mounts);
 
-	return r;
+	if (!sys_mnt) {
+		log_error("Failed to find sysfs mount point");
+		return 0;
+	}
+
+	/*
+	 * unified classification directory for all kernel subsystems
+	 *
+	 * /sys/subsystem/block/devices
+	 * |-- sda -> ../../../devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda
+	 * |-- sda1 -> ../../../devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda/sda1
+	 *  `-- sr0 -> ../../../devices/pci0000:00/0000:00:1f.2/host1/target1:0:0/1:0:0:0/block/sr0
+	 *
+	 */
+	if (dm_snprintf(path, len, "%s/%s", sys_mnt,
+			"subsystem/block/devices") >= 0) {
+		if (!stat(path, &info)) {
+			*sysfs_depth = 0;
+			return 1;
+		}
+	}
+
+	/*
+	 * block subsystem as a class
+	 *
+	 * /sys/class/block
+	 * |-- sda -> ../../devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda
+	 * |-- sda1 -> ../../devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda/sda1
+	 *  `-- sr0 -> ../../devices/pci0000:00/0000:00:1f.2/host1/target1:0:0/1:0:0:0/block/sr0
+	 *
+	 */
+	if (dm_snprintf(path, len, "%s/%s", sys_mnt, "class/block") >= 0) {
+		if (!stat(path, &info)) {
+			*sysfs_depth = 0;
+			return 1;
+		}
+	}
+
+	/*
+	 * old block subsystem layout with nested directories
+	 *
+	 * /sys/block/
+	 * |-- sda
+	 * |   |-- capability
+	 * |   |-- dev
+	 * ...
+	 * |   |-- sda1
+	 * |   |   |-- dev
+	 * ...
+	 * |
+	 * `-- sr0
+	 *     |-- capability
+	 *     |-- dev
+	 * ...
+	 *
+	 */
+	if (dm_snprintf(path, len, "%s/%s", sys_mnt, "block") >= 0) {
+		if (!stat(path, &info)) {
+			*sysfs_depth = 1;
+			return 1;
+		}
+	}
+
+	return 0;
 }
 
 /*----------------------------------------------------------------
@@ -72,11 +134,14 @@
 struct dev_set {
 	struct dm_pool *mem;
 	const char *sys_block;
+	unsigned sysfs_depth;
 	int initialised;
 	struct entry *slots[SET_BUCKETS];
 };
 
-static struct dev_set *_dev_set_create(struct dm_pool *mem, const char *sys_block)
+static struct dev_set *_dev_set_create(struct dm_pool *mem,
+				       const char *sys_block,
+				       unsigned sysfs_depth)
 {
 	struct dev_set *ds;
 
@@ -85,6 +150,7 @@
 
 	ds->mem = mem;
 	ds->sys_block = dm_pool_strdup(mem, sys_block);
+	ds->sysfs_depth = sysfs_depth;
 	ds->initialised = 0;
 
 	return ds;
@@ -168,13 +234,13 @@
 /*
  * Recurse through sysfs directories, inserting any devs found.
  */
-static int _read_devs(struct dev_set *ds, const char *dir)
+static int _read_devs(struct dev_set *ds, const char *dir, unsigned sysfs_depth)
 {
         struct dirent *d;
         DIR *dr;
-	unsigned char dtype;
 	struct stat info;
 	char path[PATH_MAX];
+	char file[PATH_MAX];
 	dev_t dev = { 0 };
 	int r = 1;
 
@@ -194,31 +260,22 @@
 			continue;
 		}
 
-		dtype = d->d_type;
-
-		if (dtype == DT_UNKNOWN) {
-			if (lstat(path, &info) >= 0) {
-				if (S_ISLNK(info.st_mode))
-					dtype = DT_LNK;
-				else if (S_ISDIR(info.st_mode))
-					dtype = DT_DIR;
-				else if (S_ISREG(info.st_mode))
-					dtype = DT_REG;
-			}
+		/* devices have a "dev" file */
+		if (dm_snprintf(file, sizeof(file), "%s/dev", path) < 0) {
+			log_error("sysfs path name too long: %s in %s",
+				  d->d_name, dir);
+			continue;
 		}
 
-		if (dtype == DT_DIR) {
-			if (!_read_devs(ds, path)) {
-				r = 0;
-				break;
-			}
+		if (!stat(file, &info)) {
+			/* recurse if we found a device and expect subdirs */
+			if (sysfs_depth)
+				_read_devs(ds, path, sysfs_depth - 1);
+
+			/* add the device we have found */
+			if (_read_dev(file, &dev))
+				_set_insert(ds, dev);
 		}
-
-		if ((dtype == DT_REG && !strcmp(d->d_name, "dev")))
-			if (!_read_dev(path, &dev) || !_set_insert(ds, dev)) {
-				r = 0;
-				break;
-			}
 	}
 
         if (closedir(dr))
@@ -229,7 +286,7 @@
 
 static int _init_devs(struct dev_set *ds)
 {
-	if (!_read_devs(ds, ds->sys_block)) {
+	if (!_read_devs(ds, ds->sys_block, ds->sysfs_depth)) {
 		ds->initialised = -1;
 		return 0;
 	}
@@ -267,11 +324,12 @@
 struct dev_filter *sysfs_filter_create(const char *proc)
 {
 	char sys_block[PATH_MAX];
+	unsigned sysfs_depth;
 	struct dm_pool *mem;
 	struct dev_set *ds;
 	struct dev_filter *f;
 
-	if (!_locate_sysfs_blocks(proc, sys_block, sizeof(sys_block)))
+	if (!_locate_sysfs_blocks(proc, sys_block, sizeof(sys_block), &sysfs_depth))
 		return NULL;
 
 	if (!(mem = dm_pool_create("sysfs", 256))) {
@@ -279,7 +337,7 @@
 		return NULL;
 	}
 
-	if (!(ds = _dev_set_create(mem, sys_block))) {
+	if (!(ds = _dev_set_create(mem, sys_block, sysfs_depth))) {
 		log_error("sysfs dev_set creation failed");
 		goto bad;
 	}


