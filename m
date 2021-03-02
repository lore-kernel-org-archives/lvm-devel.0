From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:31 +0000 (GMT)
Subject: main - dev-cache: optimize dir scanning
Message-ID: <20210302215831.5C07F3834402@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fa64c51428ca20e860bbe21338d916329b8aaf25
Commit:        fa64c51428ca20e860bbe21338d916329b8aaf25
Parent:        9dd759c6b1c0e25e785485f823b09c59ef5b2583
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 27 17:09:38 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:54:40 2021 +0100

dev-cache: optimize dir scanning

Use 'C' for alphasort - there is no need to use localized and slower
sorting for internal directory scanning.

Ensure on all code paths allocated dirent entries are released.

Optimize full path construction.
---
 lib/device/dev-cache.c | 41 ++++++++++++++++++++++-------------------
 1 file changed, 22 insertions(+), 19 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 21c9ef0ea..bbf6ce833 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -28,6 +28,7 @@
 #endif
 #include <unistd.h>
 #include <dirent.h>
+#include <locale.h>
 
 struct dev_iter {
 	struct btree_iter *current;
@@ -809,16 +810,6 @@ static int _insert_dev(const char *path, dev_t d)
 	return 0;
 }
 
-static char *_join(const char *dir, const char *name)
-{
-	size_t len = strlen(dir) + strlen(name) + 2;
-	char *r = malloc(len);
-	if (r)
-		snprintf(r, len, "%s/%s", dir, name);
-
-	return r;
-}
-
 /*
  * Get rid of extra slashes in the path string.
  */
@@ -845,27 +836,39 @@ static int _insert_dir(const char *dir)
 {
 	int n, dirent_count, r = 1;
 	struct dirent **dirent;
-	char *path;
+	char path[PATH_MAX];
+	size_t len;
+
+	if (!dm_strncpy(path, dir, sizeof(path) - 1)) {
+		log_debug_devs("Dir path %s is too long", path);
+		return 0;
+	}
+	_collapse_slashes(path);
+	len = strlen(path);
+	if (len && path[len - 1] != '/')
+		path[len++] = '/';
 
+	setlocale(LC_COLLATE, "C"); /* Avoid sorting by locales */
 	dirent_count = scandir(dir, &dirent, NULL, alphasort);
 	if (dirent_count > 0) {
 		for (n = 0; n < dirent_count; n++) {
-			if (dirent[n]->d_name[0] == '.') {
-				free(dirent[n]);
+			if (dirent[n]->d_name[0] == '.')
 				continue;
-			}
 
-			if (!(path = _join(dir, dirent[n]->d_name)))
-				return_0;
+			if (!dm_strncpy(path + len, dirent[n]->d_name, sizeof(path) - len)) {
+				log_debug_devs("Path %s/%s is too long.", dir, dirent[n]->d_name);
+				r = 0;
+				continue;
+			}
 
-			_collapse_slashes(path);
 			r &= _insert(path, NULL, 1, 0);
-			free(path);
+		}
 
+		for (n = 0; n < dirent_count; n++)
 			free(dirent[n]);
-		}
 		free(dirent);
 	}
+	setlocale(LC_COLLATE, "");
 
 	return r;
 }


