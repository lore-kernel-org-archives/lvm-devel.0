From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 00:36:28 +0000 (GMT)
Subject: main - lvm-file: remove duplication of dm_is_empty_dir
Message-ID: <20210310003628.7876C385802B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=88d04e917363a65374582313b3a4686ec51ea25c
Commit:        88d04e917363a65374582313b3a4686ec51ea25c
Parent:        413a114cdbb1fa0c198fb9a3f71d47dcb3d5e28d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 9 11:10:47 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 01:09:14 2021 +0100

lvm-file: remove duplication of dm_is_empty_dir

---
 device_mapper/libdm-file.c |  2 +-
 lib/activate/fs.c          |  2 +-
 lib/misc/lvm-file.c        | 20 --------------------
 lib/misc/lvm-file.h        |  5 -----
 4 files changed, 2 insertions(+), 27 deletions(-)

diff --git a/device_mapper/libdm-file.c b/device_mapper/libdm-file.c
index 37c6ce793..94ca146f1 100644
--- a/device_mapper/libdm-file.c
+++ b/device_mapper/libdm-file.c
@@ -110,7 +110,7 @@ int dm_is_empty_dir(const char *dir)
 	DIR *d;
 
 	if (!(d = opendir(dir))) {
-		log_sys_error("opendir", dir);
+		log_sys_debug("opendir", dir);
 		return 0;
 	}
 
diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index 96f7df678..2e8098ddf 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -76,7 +76,7 @@ static int _rm_dir(const char *dev_dir, const char *vg_name)
 		return 0;
 	}
 
-	if (dir_exists(vg_path) && is_empty_dir(vg_path)) {
+	if (dir_exists(vg_path) && dm_is_empty_dir(vg_path)) {
 		log_very_verbose("Removing directory %s", vg_path);
 		rmdir(vg_path);
 	}
diff --git a/lib/misc/lvm-file.c b/lib/misc/lvm-file.c
index 883b22de6..4a3479a5a 100644
--- a/lib/misc/lvm-file.c
+++ b/lib/misc/lvm-file.c
@@ -141,26 +141,6 @@ int dir_exists(const char *path)
 	return 1;
 }
 
-int is_empty_dir(const char *dir)
-{
-	struct dirent *dirent;
-	DIR *d;
-
-	if (!(d = opendir(dir))) {
-		log_sys_error("opendir", dir);
-		return 0;
-	}
-
-	while ((dirent = readdir(d)))
-		if (strcmp(dirent->d_name, ".") && strcmp(dirent->d_name, ".."))
-			break;
-
-	if (closedir(d))
-		log_sys_error("closedir", dir);
-
-	return dirent ? 0 : 1;
-}
-
 void sync_dir(const char *file)
 {
 	int fd;
diff --git a/lib/misc/lvm-file.h b/lib/misc/lvm-file.h
index 6128abd14..4c405e683 100644
--- a/lib/misc/lvm-file.h
+++ b/lib/misc/lvm-file.h
@@ -41,11 +41,6 @@ int lvm_rename(const char *old, const char *new);
 int path_exists(const char *path);
 int dir_exists(const char *path);
 
-/*
- * Return 1 if dir is empty
- */
-int is_empty_dir(const char *dir);
-
 /* Sync directory changes */
 void sync_dir(const char *file);
 


