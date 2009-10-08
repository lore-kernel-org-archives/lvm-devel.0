From: Fabio M. Di Nitto <fabbione@fabbione.net>
Date: Thu,  8 Oct 2009 14:49:13 +0200
Subject: [PATCH 06/11] debian/ubuntu: make the device node creation more atomic
In-Reply-To: <1255006158-8053-1-git-send-email-fabbione@fabbione.net>
References: <1255006158-8053-1-git-send-email-fabbione@fabbione.net>
Message-ID: <e9a3bd65858c5f5ba4e839c7402a5cbd22b475df.1255002311.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Fabio M. Di Nitto <fdinitto@redhat.com>

http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=455745

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 248d3ac... 90e0907... M	libdm/libdm-common.c
 libdm/libdm-common.c |   32 ++++++++++++++++++++++++--------
 1 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 248d3ac..90e0907 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -403,12 +403,19 @@ int dm_set_selinux_context(const char *path, mode_t mode)
 static int _add_dev_node(const char *dev_name, uint32_t major, uint32_t minor,
 			 uid_t uid, gid_t gid, mode_t mode)
 {
-	char path[PATH_MAX];
+	char path[PATH_MAX], tmppath[PATH_MAX];
 	struct stat info;
 	dev_t dev = MKDEV(major, minor);
 	mode_t old_mask;
 
 	_build_dev_path(path, sizeof(path), dev_name);
+	_build_dev_path(tmppath, sizeof(tmppath), ".XXXXXX");
+
+	mktemp(tmppath);
+	if (strlen(tmppath) == 0) {
+		log_error("Unable to create name of temporary file");
+		return 0;
+	}
 
 	if (stat(path, &info) >= 0) {
 		if (!S_ISBLK(info.st_mode)) {
@@ -431,24 +438,33 @@ static int _add_dev_node(const char *dev_name, uint32_t major, uint32_t minor,
 			 "node creation.", path);
 
 	old_mask = umask(0);
-	if (mknod(path, S_IFBLK | mode, dev) < 0) {
+	if (mknod(tmppath, S_IFBLK | mode, dev) < 0) {
 		umask(old_mask);
 		log_error("Unable to make device node for '%s'", dev_name);
-		return 0;
+		goto error;
 	}
 	umask(old_mask);
 
-	if (chown(path, uid, gid) < 0) {
+	if (chown(tmppath, uid, gid) < 0) {
 		log_sys_error("chown", path);
-		return 0;
+		goto error;
 	}
 
-	log_debug("Created %s", path);
+	if (!dm_set_selinux_context(tmppath, S_IFBLK))
+		goto error;
 
-	if (!dm_set_selinux_context(path, S_IFBLK))
-		return 0;
+	if (rename(tmppath, path) < 0) {
+		log_error("Unable to replace device node for '%s'", dev_name);
+		goto error;
+	}
+
+	log_debug("Created %s", path);
 
 	return 1;
+
+error:
+	unlink(tmppath);
+	return 0;
 }
 
 static int _rm_dev_node(const char *dev_name)
-- 
1.5.4.3


