From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 17 Sep 2015 12:32:08 +0000 (UTC)
Subject: master - libdm: file: add proper checks for directory components in dm_create_dir
Message-ID: <20150917123208.071B360236@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6c0b4a2769067048fa144814e298a3272564c475
Commit:        6c0b4a2769067048fa144814e298a3272564c475
Parent:        afdae26c71d2539a9f0dfb06b65541dedf28b5f5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Sep 17 14:29:51 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Sep 17 14:29:51 2015 +0200

libdm: file: add proper checks for directory components in dm_create_dir

Also make error messages more consistent:

Before this patch:

(/run/lock exists and is not a directory)
$ pvs
  /run/lock/lvm: mkdir failed: Not a directory
  File-based locking initialisation failed.

(/run/lock/lvm exists and is not a directory)
$ pvs
  Directory "/run/lock/lvm" not found
  File-based locking initialisation failed.

With this patch applied:

(/run/lock exists and is not a directory)
$ pvs
  Existing path /run/lock is not a directory.
  Failed to create directory /run/lock/lvm.
  File-based locking initialisation failed

(/run/lock/lvm exists and is not a directory)
$ pvs
  Existing path /run/lock/lvm is not a directory.
  Failed to create directory /run/lock/lvm.
  File-based locking initialisation failed.
---
 libdm/libdm-file.c |   57 +++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 43 insertions(+), 14 deletions(-)

diff --git a/libdm/libdm-file.c b/libdm/libdm-file.c
index e4beddd..0de2d61 100644
--- a/libdm/libdm-file.c
+++ b/libdm/libdm-file.c
@@ -19,6 +19,24 @@
 #include <fcntl.h>
 #include <dirent.h>
 
+static int _is_dir(const char *path)
+{
+	struct stat st;
+
+	if (stat(path, &st) < 0) {
+		log_sys_error("stat", path);
+		return 0;
+	}
+
+	if (!S_ISDIR(st.st_mode)) {
+		log_error("Existing path %s is not "
+			  "a directory.", path);
+		return 0;
+	}
+
+	return 1;
+}
+
 static int _create_dir_recursive(const char *dir)
 {
 	char *orig, *s;
@@ -36,10 +54,15 @@ static int _create_dir_recursive(const char *dir)
 		*s = '\0';
 		if (*orig) {
 			rc = mkdir(orig, 0777);
-			if (rc < 0 && errno != EEXIST) {
-				if (errno != EROFS)
-					log_sys_error("mkdir", orig);
-				goto out;
+			if (rc < 0) {
+				if (errno == EEXIST) {
+					if (!_is_dir(orig))
+						goto_out;
+				} else {
+					if (errno != EROFS)
+						log_sys_error("mkdir", orig);
+					goto out;
+				}
 			}
 		}
 		*s++ = '/';
@@ -47,10 +70,15 @@ static int _create_dir_recursive(const char *dir)
 
 	/* Create final directory */
 	rc = mkdir(dir, 0777);
-	if (rc < 0 && errno != EEXIST) {
-		if (errno != EROFS)
-			log_sys_error("mkdir", orig);
-		goto out;
+	if (rc < 0) {
+		if (errno == EEXIST) {
+			if (!_is_dir(dir))
+				goto_out;
+		} else {
+			if (errno != EROFS)
+				log_sys_error("mkdir", orig);
+			goto out;
+		}
 	}
 
 	r = 1;
@@ -66,14 +94,15 @@ int dm_create_dir(const char *dir)
 	if (!*dir)
 		return 1;
 
-	if (stat(dir, &info) < 0)
-		return _create_dir_recursive(dir);
-
-	if (S_ISDIR(info.st_mode))
+	if (stat(dir, &info) == 0 && S_ISDIR(info.st_mode))
 		return 1;
 
-	log_error("Directory \"%s\" not found", dir);
-	return 0;
+	if (!_create_dir_recursive(dir)) {
+		log_error("Failed to create directory %s.", dir);
+		return 0;
+	}
+
+	return 1;
 }
 
 int dm_is_empty_dir(const char *dir)


