From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 Dec 2013 10:19:34 +0000 (UTC)
Subject: master - dev-cache: return success when ignoring dirs
Message-ID: <20131205101934.1E30C6105B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7baf411c9774d8e51ccc8bff9399562da69906a3
Commit:        7baf411c9774d8e51ccc8bff9399562da69906a3
Parent:        74878bc2bcd66d60a0b53f409a30271496acd348
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 5 11:11:26 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 5 11:17:37 2013 +0100

dev-cache: return success when ignoring dirs

When there is no failure from the insert operation itself,
just dirs and links are skipped - return success.
---
 WHATS_NEW              |    1 +
 lib/device/dev-cache.c |   14 +++++---------
 2 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 60571ff..2e1f59a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Return success when inserting dirs and links into device cache.
   Test for remote exclusive activation after activation fails.
   Support lvconvert --merge for thin snapshots.
   Add support to read thin device id from table line entry.
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 9451314..bbdde92 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -592,7 +592,6 @@ static void _insert_dirs(struct dm_list *dirs)
 static int _insert(const char *path, int rec, int check_with_udev_db)
 {
 	struct stat info;
-	int r = 0;
 
 	if (stat(path, &info) < 0) {
 		log_sys_very_verbose("stat", path);
@@ -613,25 +612,22 @@ static int _insert(const char *path, int rec, int check_with_udev_db)
 
 		if (S_ISLNK(info.st_mode)) {
 			log_debug_devs("%s: Symbolic link to directory", path);
-			return 0;
+			return 1;
 		}
 
-		if (rec)
-			r = _insert_dir(path);
-
+		if (rec && !_insert_dir(path))
+			return_0;
 	} else {		/* add a device */
 		if (!S_ISBLK(info.st_mode)) {
 			log_debug_devs("%s: Not a block device", path);
-			return 0;
+			return 1;
 		}
 
 		if (!_insert_dev(path, info.st_rdev))
 			return_0;
-
-		r = 1;
 	}
 
-	return r;
+	return 1;
 }
 
 static void _full_scan(int dev_scan)


