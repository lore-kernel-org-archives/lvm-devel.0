From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 16 Jul 2010 14:56:00 +0200
Subject: [PATCH] Give preference to /dev/mapper/* aliases in device cache
Message-ID: <4C4056E0.6010507@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is a little patch that tries to give preference to aliases in dev cache (/dev/mapper
content instead of /dev/dm-X or /dev/disk or anything else).

First, I thought it would be a good idea to have a possibility to give preference to
/dev/<vgname>/<lvname> if used and detected somehow. The thing is that the detection
is not so straightforward :)

Anyway, I think that having a preference for /dev/mapper content is general enough and
does its job as well, it's probably not worth to fiddle with the code more.

So, for example, now we should see /dev/mapper/<dm-name> in pvs output instead of
undescriptive /dev/dm-X (or any other funny location elsewhere in /dev).

Peter
---
 lib/device/dev-cache.c |   37 +++++++++++++++++++++++++++----------
 1 files changed, 27 insertions(+), 10 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index f6c8a46..153a5bf 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -147,8 +147,24 @@ void dev_set_preferred_name(struct str_list *sl, struct device *dev)
 	dm_list_add_h(&dev->aliases, &sl->list);
 }
 
+static int _builtin_preference(const char *path0, const char *path1,
+			  size_t skip_prefix_count, const char *subpath)
+{
+	size_t subpath_len;
+
+	subpath_len = strlen(subpath);
+
+	if (!strncmp(path0 + skip_prefix_count, subpath, subpath_len)) {
+		if (strncmp(path1 + skip_prefix_count, subpath, subpath_len))
+			return 0;
+	} else if (!strncmp(path1 + skip_prefix_count, subpath, subpath_len))
+		return 1;
+
+	return -1;
+}
+
 /* Return 1 if we prefer path1 else return 0 */
-static int _compare_paths(const char *path0, const char *path1)
+static int _compare_paths(struct device *dev, const char *path0, const char *path1)
 {
 	int slash0 = 0, slash1 = 0;
 	int m0, m1;
@@ -157,6 +173,7 @@ static int _compare_paths(const char *path0, const char *path1)
 	char *s0, *s1;
 	struct stat stat0, stat1;
 	size_t devdir_len;
+	int r;
 
 	/*
 	 * FIXME Better to compare patterns one-at-a-time against all names.
@@ -181,17 +198,17 @@ static int _compare_paths(const char *path0, const char *path1)
 	 * Built-in rules.
 	 */
 
-	/*
-	 * Anything beats /dev/block.
-	 */
 	devdir_len = strlen(_cache.dev_dir);
 	if (!strncmp(path0, _cache.dev_dir, devdir_len) &&
 	    !strncmp(path1, _cache.dev_dir, devdir_len)) {
-		if (!strncmp(path0 + devdir_len, "block/", 6)) {
-			if (strncmp(path1 + devdir_len, "block/", 6))
-				return 1;
-		} else if (!strncmp(path1 + devdir_len, "block/", 6))
-			return 0;
+		/* Try to defer paths with block/ generally. */
+		if ((r = _builtin_preference(path0, path1, devdir_len, "block/")) >= 0)
+			return !r;
+
+		/* Try to prefer paths with dm_dir() for device-mapper devices. */
+		if (dm_is_dm_major(MAJOR(dev->dev)) &&
+		    ((r = _builtin_preference(path0, path1, 0, dm_dir())) >= 0))
+				return r;
 	}
 
 	/* Return the path with fewer slashes */
@@ -269,7 +286,7 @@ static int _add_alias(struct device *dev, const char *path)
 
 	if (!dm_list_empty(&dev->aliases)) {
 		oldpath = dm_list_item(dev->aliases.n, struct str_list)->str;
-		prefer_old = _compare_paths(path, oldpath);
+		prefer_old = _compare_paths(dev, path, oldpath);
 		log_debug("%s: Aliased to %s in device cache%s",
 			  path, oldpath, prefer_old ? "" : " (preferred name)");
 


