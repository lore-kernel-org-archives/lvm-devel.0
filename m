From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 27 Jul 2010 11:44:59 +0200
Subject: [PATCH] Give preference to /dev/mapper/* aliases in device cache (modified)
In-Reply-To: <4C4056E0.6010507@redhat.com>
References: <4C4056E0.6010507@redhat.com>
Message-ID: <4C4EAA9B.1030203@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

D?a 16.07.2010 14:56, Peter Rajnoha  wrote / nap?sal(a):
> This is a little patch that tries to give preference to aliases in dev cache (/dev/mapper
> content instead of /dev/dm-X or /dev/disk or anything else).
> 
> First, I thought it would be a good idea to have a possibility to give preference to
> /dev/<vgname>/<lvname> if used and detected somehow. The thing is that the detection
> is not so straightforward :)
> 
> Anyway, I think that having a preference for /dev/mapper content is general enough and
> does its job as well, it's probably not worth to fiddle with the code more.

OK, so after a short discussion with Alasdair, we've concluded that giving a priority
to /dev/mapper content is not the right way to go - that would break the original idea
of how the preference to aliases should be given.

This version of the patch tries to achieve the ordering while processing the aliases:

    /dev/block/* < /dev/dm-* < /dev/disk/* < /dev/mapper/* < anything else

For that "anything else", former rules should be applied. It means, giving a priority
to a path with less slashes. If there are aliases@the same level of directory
hierarchy (the same number of slashes), the preference should be given by taking the
alphabetical order rule (this is the very last rule that is applied).

(Maybe we should even document these built-in rules in the man page somewhere so
people know exactly what will be displayed to them, e.g. in pvs output - with udev,
people can create any number of custom symlinks anywhere... People should know
there is a little bit of determinism here :) )

So here's the updated and modified patch. I'll update the man page too if this
patch is accepted...

Peter
---
 lib/device/dev-cache.c |  123 +++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 106 insertions(+), 17 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index f6c8a46..1bfc014 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -147,6 +147,108 @@ void dev_set_preferred_name(struct str_list *sl, struct device *dev)
 	dm_list_add_h(&dev->aliases, &sl->list);
 }
 
+/*
+ * Checks whether path0 is preferred over path1. Path containing
+ * the subpath wins (return 0 or 1). If both (or none) of them
+ * contain the subpath, we're not able to decide which one is
+ * preferred (return -1).
+ */
+static int _builtin_preference(const char *path0, const char *path1,
+			  size_t skip_prefix_count, const char *subpath)
+{
+	size_t subpath_len;
+
+	subpath_len = strlen(subpath);
+
+	if (!strncmp(path0 + skip_prefix_count, subpath, subpath_len)) {
+		if (strncmp(path1 + skip_prefix_count, subpath, subpath_len))
+			/* path0 wins */
+			return 0;
+	} else if (!strncmp(path1 + skip_prefix_count, subpath, subpath_len))
+		/* path1 wins */
+		return 1;
+
+	/* we're not able to decide */
+	return -1;
+}
+
+/*
+ * Checks whether path0 is preferred over path1 while path0 must contain
+ * subpath0 and path1 must contain subpath1. Returns 0 if path0 contains
+ * subpath0 and path1 contains subpath1. Returns 1 if found in reverse.
+ * Returns -1 if not applicable (and so we're not able to decide).
+ */
+static int _builtin_pair_preference(const char *path0, size_t skip_prefix_count0, const char *subpath0,
+				    const char *path1, size_t skip_prefix_count1, const char *subpath1)
+{
+	size_t subpath0_len, subpath1_len;
+
+	subpath0_len = strlen(subpath0);
+	subpath1_len = strlen(subpath1);
+
+	if (!strncmp(path0 + skip_prefix_count0, subpath0, subpath0_len) &&
+	    !strncmp(path1 + skip_prefix_count1, subpath1, subpath1_len))
+		/* path0 wins */
+		return 0;
+
+	if (!strncmp(path1 + skip_prefix_count1, subpath0, subpath0_len) &&
+	    !strncmp(path0 + skip_prefix_count0, subpath1, subpath1_len))
+		/* path1 wins */
+		return 1;
+
+	/* we're not able to decide */
+	return -1;
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
+		if ((r = _builtin_preference(path0, path1, devdir_len, "block/")) >= 0)
+			return !r;
+
+		/* Prefer /dev/mapper/ path over /dev/disk/ path. */
+		if ((r = _builtin_pair_preference(path0, 0, dm_dir(),
+						  path1, devdir_len, "disk/")) >= 0)
+			return r;
+
+		/* Prefer /dev/mapper/ path over /dev/dm-* path. */
+		if ((r = _builtin_pair_preference(path0, 0, dm_dir(),
+						  path1, devdir_len, "dm-")) >= 0)
+			return r;
+
+		/* Prefer /dev/disk/ path over /dev/dm-* path. */
+		if ((r = _builtin_pair_preference(path0, devdir_len, "disk/",
+						  path1, devdir_len, "dm-")) >= 0)
+			return r;
+
+		/* Prefer any other path over /dev/dm-* path. */
+		if ((r = _builtin_preference(path0, path1, devdir_len, "dm-")) >= 0)
+			return !r;
+
+		/* Prefer any other path over /dev/disk/ path. */
+		if ((r = _builtin_preference(path0, path1, devdir_len, "disk/")) >= 0)
+			return !r;
+
+		/* Prefer any other path over /dev/mapper/ path. */
+		if ((r = _builtin_preference(path0, path1, 0, dm_dir())) >= 0)
+			return !r;
+	}
+
+	return -1;
+}
+
 /* Return 1 if we prefer path1 else return 0 */
 static int _compare_paths(const char *path0, const char *path1)
 {
@@ -156,7 +258,7 @@ static int _compare_paths(const char *path0, const char *path1)
 	char p0[PATH_MAX], p1[PATH_MAX];
 	char *s0, *s1;
 	struct stat stat0, stat1;
-	size_t devdir_len;
+	int r;
 
 	/*
 	 * FIXME Better to compare patterns one-at-a-time against all names.
@@ -177,22 +279,9 @@ static int _compare_paths(const char *path0, const char *path1)
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


