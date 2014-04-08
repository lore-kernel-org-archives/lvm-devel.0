From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Apr 2014 09:02:36 +0000 (UTC)
Subject: master - libdm: check for _build_dev_path failure
Message-ID: <20140408090236.75BE0612E1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d3d2d5e3da3e870e2df07c32cea4dfbbeab572c
Commit:        6d3d2d5e3da3e870e2df07c32cea4dfbbeab572c
Parent:        2c2819763083d3c2e6b011117d8fa27c77a4d4e8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 4 21:47:54 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 8 11:00:13 2014 +0200

libdm: check for _build_dev_path failure

Enhance internal function _build_dev_path for failure
if buffer would be too small.
Use memcpy instead printf for a single string.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-common.c |   28 +++++++++++++++++++---------
 2 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 1c0843e..4004d98 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.85 - 
 ===================================
+  Check for sprintf error when building internal device path.
   Check for sprintf error when creating path for dm control node.
   When buffer for dm_get_library_version() is too small, return error code.
   Always reinitialize _name_mangling_mode in dm_lib_init().
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 93f3dd1..5c8b49c 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -192,13 +192,20 @@ void dm_log_init_verbose(int level)
 	_verbose = level;
 }
 
-static void _build_dev_path(char *buffer, size_t len, const char *dev_name)
+static int _build_dev_path(char *buffer, size_t len, const char *dev_name)
 {
+	int r;
+
 	/* If there's a /, assume caller knows what they're doing */
 	if (strchr(dev_name, '/'))
-		snprintf(buffer, len, "%s", dev_name);
+		r = dm_strncpy(buffer, dev_name, len);
 	else
-		snprintf(buffer, len, "%s/%s", _dm_dir, dev_name);
+		r = (dm_snprintf(buffer, len, "%s/%s",
+				 _dm_dir, dev_name) < 0) ? 0 : 1;
+	if (!r)
+		log_error("Failed to build dev path for \"%s\".", dev_name);
+
+	return r;
 }
 
 int dm_get_library_version(char *version, size_t size)
@@ -955,7 +962,8 @@ static int _add_dev_node(const char *dev_name, uint32_t major, uint32_t minor,
 	dev_t dev = MKDEV((dev_t)major, minor);
 	mode_t old_mask;
 
-	_build_dev_path(path, sizeof(path), dev_name);
+	if (!_build_dev_path(path, sizeof(path), dev_name))
+		return_0;
 
 	if (stat(path, &info) >= 0) {
 		if (!S_ISBLK(info.st_mode)) {
@@ -1005,8 +1013,8 @@ static int _rm_dev_node(const char *dev_name, int warn_if_udev_failed)
 	char path[PATH_MAX];
 	struct stat info;
 
-	_build_dev_path(path, sizeof(path), dev_name);
-
+	if (!_build_dev_path(path, sizeof(path), dev_name))
+		return_0;
 	if (stat(path, &info) < 0)
 		return 1;
 	else if (_warn_if_op_needed(warn_if_udev_failed))
@@ -1031,8 +1039,9 @@ static int _rename_dev_node(const char *old_name, const char *new_name,
 	char newpath[PATH_MAX];
 	struct stat info;
 
-	_build_dev_path(oldpath, sizeof(oldpath), old_name);
-	_build_dev_path(newpath, sizeof(newpath), new_name);
+	if (!_build_dev_path(oldpath, sizeof(oldpath), old_name) ||
+	    !_build_dev_path(newpath, sizeof(newpath), new_name))
+		return_0;
 
 	if (stat(newpath, &info) == 0) {
 		if (!S_ISBLK(info.st_mode)) {
@@ -1106,7 +1115,8 @@ static int _open_dev_node(const char *dev_name)
 	int fd = -1;
 	char path[PATH_MAX];
 
-	_build_dev_path(path, sizeof(path), dev_name);
+	if (!_build_dev_path(path, sizeof(path), dev_name))
+		return fd;
 
 	if ((fd = open(path, O_RDONLY, 0)) < 0)
 		log_sys_error("open", path);


