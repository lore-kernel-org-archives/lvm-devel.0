From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 22 Jan 2021 15:10:06 +0000 (GMT)
Subject: main - pvscan: ensure read buffer ends with 0
Message-ID: <20210122151006.024AD398E43C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fa2fa9f36da74d228db22a7765aa4df28107f71a
Commit:        fa2fa9f36da74d228db22a7765aa4df28107f71a
Parent:        ce6e74f485cb1fb36a4c1c35d1bd3262b77954de
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 21 21:15:33 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 22 15:30:37 2021 +0100

pvscan: ensure read buffer ends with 0

Read buffersize - 1 so the last byte is always 0.
Simplify init of 0 buffers.
Check snprintf result for error and report internal error as it could
happen only via bad compile parameters.
---
 tools/pvscan.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 0ad901c13..021ec691e 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -206,7 +206,7 @@ static char *_vgname_in_pvid_file_buf(char *buf)
 
 static int _online_pvid_file_read(char *path, int *major, int *minor, char *vgname)
 {
-	char buf[MAX_PVID_FILE_SIZE];
+	char buf[MAX_PVID_FILE_SIZE] = { 0 };
 	char *name;
 	int fd, rv;
 
@@ -216,9 +216,7 @@ static int _online_pvid_file_read(char *path, int *major, int *minor, char *vgna
 		return 0;
 	}
 
-	memset(buf, 0, sizeof(buf));
-
-	rv = read(fd, buf, sizeof(buf));
+	rv = read(fd, buf, sizeof(buf) - 1);
 	if (close(fd))
 		log_sys_debug("close", path);
 	if (!rv || rv < 0) {
@@ -350,7 +348,7 @@ static void _online_files_remove(const char *dirpath)
 static int _online_pvid_file_create(struct device *dev, const char *vgname)
 {
 	char path[PATH_MAX];
-	char buf[MAX_PVID_FILE_SIZE];
+	char buf[MAX_PVID_FILE_SIZE] = { 0 };
 	char file_vgname[NAME_LEN];
 	int file_major = 0, file_minor = 0;
 	int major, minor;
@@ -360,8 +358,6 @@ static int _online_pvid_file_create(struct device *dev, const char *vgname)
 	int len1 = 0;
 	int len2 = 0;
 
-	memset(buf, 0, sizeof(buf));
-
 	major = (int)MAJOR(dev->dev);
 	minor = (int)MINOR(dev->dev);
 
@@ -451,13 +447,14 @@ check_duplicate:
 
 static int _online_pvid_file_exists(const char *pvid)
 {
-	char path[PATH_MAX];
+	char path[PATH_MAX] = { 0 };
 	struct stat buf;
 	int rv;
 
-	memset(path, 0, sizeof(path));
-
-	snprintf(path, sizeof(path), "%s/%s", _pvs_online_dir, pvid);
+	if (dm_snprintf(path, sizeof(path), "%s/%s", _pvs_online_dir, pvid) < 0) {
+		log_debug(INTERNAL_ERROR "Path %s/%s is too long.", _pvs_online_dir, pvid);
+		return 0;
+	}
 
 	log_debug("Check pv online: %s", path);
 


