From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 3 Aug 2010 13:39:29 -0000
Subject: LVM2 ./WHATS_NEW_DM lib/device/dev-cache.c
Message-ID: <20100803133929.22669.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-08-03 13:39:27

Modified files:
	.              : WHATS_NEW_DM 
	lib/device     : dev-cache.c 

Log message:
	Use built-in rules for device aliases: block/ < dm- < disk/ < mapper/ < other.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.403&r2=1.404
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/WHATS_NEW_DM	2010/08/03 13:04:32	1.403
+++ LVM2/WHATS_NEW_DM	2010/08/03 13:39:27	1.404
@@ -1,5 +1,6 @@
 Version 1.02.54 - 
 ================================
+  Use built-in rule for device aliases: block/ < dm- < disk/ < mapper/ < other.
   Wait for node creation before displaying debug info in dmsetup.
   Fix return status 0 for "dmsetup info -c -o help".
   Add check for kernel semaphore support and disable udev_sync if not available.
--- LVM2/lib/device/dev-cache.c	2010/05/24 22:53:49	1.57
+++ LVM2/lib/device/dev-cache.c	2010/08/03 13:39:27	1.58
@@ -147,6 +147,71 @@
 	dm_list_add_h(&dev->aliases, &sl->list);
 }
 
+/*
+ * Check whether path0 or path1 contains the subpath. The path that
+ * *does not* contain the subpath wins (return 0 or 1). If both paths
+ * contain the subpath, return -1. If none of them contains the subpath,
+ * return -2.
+ */
+static int _builtin_preference(const char *path0, const char *path1,
+			       size_t skip_prefix_count, const char *subpath)
+{
+	size_t subpath_len;
+	int r0, r1;
+
+	subpath_len = strlen(subpath);
+
+	r0 = !strncmp(path0 + skip_prefix_count, subpath, subpath_len);
+	r1 = !strncmp(path1 + skip_prefix_count, subpath, subpath_len);
+
+	if (!r0 && r1)
+		/* path0 does not have the subpath - it wins */
+		return 0;
+	else if (r0 && !r1)
+		/* path1 does not have the subpath - it wins */
+		return 1;
+	else if (r0 && r1)
+		/* both of them have the subpath */
+		return -1;
+
+	/* no path has the subpath */
+	return -2;
+}
+
+static int _apply_builtin_path_preference_rules(const char *path0, const char *path1)
+{
+	size_t devdir_len;
+	int r;
+
+	devdir_len = strlen(_cache.dev_dir);
+
+	if (!strncmp(path0, _cache.dev_dir, devdir_len) &&
+	    !strncmp(path1, _cache.dev_dir, devdir_len)) {
+		/*
+		 * We're trying to achieve the ordering:
+		 *	/dev/block/ < /dev/dm-* < /dev/disk/ < /dev/mapper/ < anything else
+		 */
+
+		/* Prefer any other path over /dev/block/ path. */
+		if ((r = _builtin_preference(path0, path1, devdir_len, "block/")) >= -1)
+			return r;
+
+		/* Prefer any other path over /dev/dm-* path. */
+		if ((r = _builtin_preference(path0, path1, devdir_len, "dm-")) >= -1)
+			return r;
+
+		/* Prefer any other path over /dev/disk/ path. */
+		if ((r = _builtin_preference(path0, path1, devdir_len, "disk/")) >= -1)
+			return r;
+
+		/* Prefer any other path over /dev/mapper/ path. */
+		if ((r = _builtin_preference(path0, path1, 0, dm_dir())) >= -1)
+			return r;
+	}
+
+	return -1;
+}
+
 /* Return 1 if we prefer path1 else return 0 */
 static int _compare_paths(const char *path0, const char *path1)
 {
@@ -156,7 +221,7 @@
 	char p0[PATH_MAX], p1[PATH_MAX];
 	char *s0, *s1;
 	struct stat stat0, stat1;
-	size_t devdir_len;
+	int r;
 
 	/*
 	 * FIXME Better to compare patterns one-at-a-time against all names.
@@ -177,22 +242,9 @@
 		}
 	}
 
-	/*
-	 * Built-in rules.
-	 */
-
-	/*
-	 * Anything beats /dev/block.
-	 */
-	devdir_len = strlen(_cache.dev_dir);
-	if (!strncmp(path0, _cache.dev_dir, devdir_len) &&
-	    !strncmp(path1, _cache.dev_dir, devdir_len)) {
-		if (!strncmp(path0 + devdir_len, "block/", 6)) {
-			if (strncmp(path1 + devdir_len, "block/", 6))
-				return 1;
-		} else if (!strncmp(path1 + devdir_len, "block/", 6))
-			return 0;
-	}
+	/* Apply built-in preference rules first. */
+	if ((r = _apply_builtin_path_preference_rules(path0, path1)) >= 0)
+		return r;
 
 	/* Return the path with fewer slashes */
 	for (p = path0; p++; p = (const char *) strchr(p, '/'))


