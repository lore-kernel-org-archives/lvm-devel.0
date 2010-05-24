From: agk@sourceware.org <agk@sourceware.org>
Date: 24 May 2010 22:53:49 -0000
Subject: LVM2 ./WHATS_NEW lib/device/dev-cache.c
Message-ID: <20100524225349.5670.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-05-24 22:53:49

Modified files:
	.              : WHATS_NEW 
	lib/device     : dev-cache.c 

Log message:
	Avoid selecting names under /dev/block if there is an alternative.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1596&r2=1.1597
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/WHATS_NEW	2010/05/24 17:46:47	1.1596
+++ LVM2/WHATS_NEW	2010/05/24 22:53:48	1.1597
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Avoid selecting names under /dev/block if there is an alternative.
   Update clustered log kernel module name to log-userspace for 2.6.31 onwards.
   Activate only first head of Replicator for vgchange -ay.
   Add Replicators' LVs to dtree for activation.
--- LVM2/lib/device/dev-cache.c	2009/07/15 20:02:46	1.56
+++ LVM2/lib/device/dev-cache.c	2010/05/24 22:53:49	1.57
@@ -40,6 +40,7 @@
 	struct dm_hash_table *names;
 	struct btree *devices;
 	struct dm_regex *preferred_names_matcher;
+	const char *dev_dir;
 
 	int has_scanned;
 	struct dm_list dirs;
@@ -155,6 +156,7 @@
 	char p0[PATH_MAX], p1[PATH_MAX];
 	char *s0, *s1;
 	struct stat stat0, stat1;
+	size_t devdir_len;
 
 	/*
 	 * FIXME Better to compare patterns one-at-a-time against all names.
@@ -179,6 +181,19 @@
 	 * Built-in rules.
 	 */
 
+	/*
+	 * Anything beats /dev/block.
+	 */
+	devdir_len = strlen(_cache.dev_dir);
+	if (!strncmp(path0, _cache.dev_dir, devdir_len) &&
+	    !strncmp(path1, _cache.dev_dir, devdir_len)) {
+		if (!strncmp(path0 + devdir_len, "block/", 6)) {
+			if (strncmp(path1 + devdir_len, "block/", 6))
+				return 1;
+		} else if (!strncmp(path1 + devdir_len, "block/", 6))
+			return 0;
+	}
+
 	/* Return the path with fewer slashes */
 	for (p = path0; p++; p = (const char *) strchr(p, '/'))
 		slash0++;
@@ -545,6 +560,11 @@
 		goto bad;
 	}
 
+	if (!(_cache.dev_dir = _strdup(cmd->dev_dir))) {
+		log_error("strdup dev_dir failed.");
+		goto bad;
+	}
+
 	dm_list_init(&_cache.dirs);
 	dm_list_init(&_cache.files);
 


