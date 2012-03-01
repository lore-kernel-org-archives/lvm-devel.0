From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 10:30:49 -0000
Subject: LVM2 ./WHATS_NEW lib/filters/filter-mpath.c
Message-ID: <20120301103049.22896.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 10:30:48

Modified files:
	.              : WHATS_NEW 
	lib/filters    : filter-mpath.c 

Log message:
	Improve error logging
	
	Log errors instead of plain return 0.
	Check for f->private strdup result.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2328&r2=1.2329
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-mpath.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/WHATS_NEW	2012/03/01 09:54:23	1.2328
+++ LVM2/WHATS_NEW	2012/03/01 10:30:48	1.2329
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================
+  Improve error logging from mpath filter.
   Check for allocation failure in hold_lock() in clvmd.
   Use set_lv() (wipe initial 4KiB) for non zeroed thin volume.
   Allow cluster mirrors to handle the absence of the checkpoint lib (libSaCkpt).
--- LVM2/lib/filters/filter-mpath.c	2012/02/08 11:40:02	1.3
+++ LVM2/lib/filters/filter-mpath.c	2012/03/01 10:30:48	1.4
@@ -26,13 +26,16 @@
 {
 	const char *name;
 
-	name = strrchr(dev_name(dev), '/');
-	if (!name)
+	if (!(name = strrchr(dev_name(dev), '/'))) {
+		log_error("Cannot find '/' in device name.");
 		return NULL;
+	}
 	name++;
 
-	if (!*name)
+	if (!*name) {
+		log_error("Device name is not valid.");
 		return NULL;
+	}
 
 	return name;
 }
@@ -42,16 +45,18 @@
 	FILE *fp;
 	int r = 0;
 
-	if (!(fp = fopen(path, "r")))
-		return_0;
+	if (!(fp = fopen(path, "r"))) {
+		log_sys_error("fopen", path);
+		return 0;
+	}
 
 	if (!fgets(buffer, max_size, fp))
-		stack;
+		log_sys_error("fgets", path);
 	else
 		r = 1;
 
 	if (fclose(fp))
-		stack;
+		log_sys_error("fclose", path);
 
 	return r;
 }
@@ -60,14 +65,18 @@
 {
 	char path[PATH_MAX], buffer[64];
 
-	if (dm_snprintf(path, sizeof(path), "%s/block/%s/dev", sysfs_dir, kname) < 0)
-		return_0;
+	if (dm_snprintf(path, sizeof(path), "%s/block/%s/dev", sysfs_dir, kname) < 0) {
+		log_error("Sysfs path string is too long.");
+		return 0;
+	}
 
 	if (!get_sysfs_string(path, buffer, sizeof(buffer)))
-		return 0;
+		return_0;
 
-	if (sscanf(buffer, "%d:%d", major, minor) != 2)
+	if (sscanf(buffer, "%d:%d", major, minor) != 2) {
+		log_error("Failed to parse major minor from %s", buffer);
 		return 0;
+	}
 
 	return 1;
 }
@@ -78,8 +87,10 @@
 	DIR *dr;
 	int r = 0;
 
-	if (!(dr = opendir(dir)))
-		return_0;
+	if (!(dr = opendir(dir))) {
+		log_sys_error("opendir", dir);
+		return 0;
+	}
 
 	*name = '\0';
 	while ((d = readdir(dr))) {
@@ -97,7 +108,7 @@
 	}
 
 	if (closedir(dr))
-		stack;
+		log_sys_error("closedir", dir);
 
 	return r;
 }
@@ -109,32 +120,39 @@
 	char parent_name[PATH_MAX+1];
 	struct stat info;
 	const char *sysfs_dir = f->private;
-	int major, minor, r;
+	int major, minor;
 
 	/* Limit this filter only to SCSI devices */
 	if (!major_is_scsi_device(MAJOR(dev->dev)))
 		return 0;
 
-	name = get_sysfs_name(dev);
-	if (!name)
+	if (!(name = get_sysfs_name(dev)))
 		return_0;
 
-	r = dm_snprintf(path, PATH_MAX, "%s/block/%s/holders", sysfs_dir, name);
-	if (r < 0)
-		return_0;
+	if (dm_snprintf(path, PATH_MAX, "%s/block/%s/holders", sysfs_dir, name) < 0) {
+		log_error("Sysfs path to check mpath is too long.");
+		return 0;
+	}
 
 	/* also will filter out partitions */
-	if (stat(path, &info) == -1 || !S_ISDIR(info.st_mode))
+	if (stat(path, &info))
 		return 0;
 
+	if (!S_ISDIR(info.st_mode)) {
+		log_error("Path %s is not a directory.", path);
+		return 0;
+	}
+
 	if (!get_parent_mpath(path, parent_name, PATH_MAX))
 		return 0;
 
 	if (!get_sysfs_get_major_minor(sysfs_dir, parent_name, &major, &minor))
-		return 0;
+		return_0;
 
-	if (major != dm_major())
+	if (major != dm_major()) {
+		log_error("mpath major %d is not dm major %d.", major, dm_major());
 		return 0;
+	}
 
 	return lvm_dm_prefix_check(major, minor, MPATH_PREFIX);
 }
@@ -175,7 +193,12 @@
 	f->passes_filter = _ignore_mpath;
 	f->destroy = _destroy;
 	f->use_count = 0;
-	f->private = dm_strdup(sysfs_dir);
+
+	if (!(f->private = dm_strdup(sysfs_dir))) {
+		log_error("Cannot duplicate sysfs dir.");
+		dm_free(f);
+		return NULL;
+	}
 
 	return f;
 }


