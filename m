From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 6 Nov 2018 09:08:37 -0500
Subject: master - pvscan: add error checking for write of online files
Message-ID: <201811061408.wA6E8b4t031900@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a1b1b3dbb620dd51123387828b4b936a47814853
Commit:        a1b1b3dbb620dd51123387828b4b936a47814853
Parent:        9a6f0e64f92bfb9f8c7fd4e5692a8107eba50034
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 6 15:04:35 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 6 15:05:44 2018 +0100

pvscan: add error checking for write of online files

When there is any write failure during writting file,
report this upward as error and fail command instead
of continuing futher.
---
 tools/pvscan.c |   37 +++++++++++++++++++++++++------------
 1 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 85b0e04..0f7603e 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -256,40 +256,52 @@ static void _online_pvid_files_remove(void)
 		log_sys_debug("closedir", _pvs_online_dir);
 }
 
-static void _online_pvid_file_create(struct device *dev)
+static int _online_pvid_file_create(struct device *dev)
 {
 	char path[PATH_MAX];
 	char buf[32];
 	int major, minor;
 	int fd;
 	int rv;
-
-	memset(path, 0, sizeof(path));
+	int len;
 
 	major = (int)MAJOR(dev->dev);
 	minor = (int)MINOR(dev->dev);
 
-	snprintf(path, sizeof(path), "%s/%s", _pvs_online_dir, dev->pvid);
+	if (dm_snprintf(path, sizeof(path), "%s/%s", _pvs_online_dir, dev->pvid) < 0) {
+		log_error("Path %s/%s is too long.", _pvs_online_dir, dev->pvid);
+		return 0;
+	}
 
-	snprintf(buf, sizeof(buf), "%d:%d\n", major, minor);
+	if ((len = dm_snprintf(buf, sizeof(buf), "%d:%d\n", major, minor)) < 0) {
+		log_error("Device %d:%d is too long.", major, minor);
+		return 0;
+	}
 
 	log_debug("Create pv online: %s %d:%d %s", path, major, minor, dev_name(dev));
 
 	fd = open(path, O_CREAT | O_TRUNC | O_RDWR, S_IRUSR | S_IWUSR);
 	if (fd < 0) {
-		log_warn("Failed to open %s: %d", path, errno);
-		return;
+		log_error("Failed to open %s: %d", path, errno);
+		return 0;
 	}
 
-	rv = write(fd, buf, strlen(buf));
-	if (!rv || rv < 0)
-		log_warn("Failed to write fd %d buf %s dev %s to %s: %d",
-			 fd, buf, dev_name(dev), path, errno);
+	while (len > 0) {
+		rv = write(fd, buf, len);
+		if (rv < 0) {
+			log_error("Failed to write fd %d buf %s dev %s to %s: %d",
+				  fd, buf, dev_name(dev), path, errno);
+			return 0;
+		}
+		len -= rv;
+	}
 
 	/* We don't care about syncing, these files are not even persistent. */
 
 	if (close(fd))
 		log_sys_debug("close", path);
+
+	return 1;
 }
 
 static int _online_pvid_file_exists(const char *pvid)
@@ -364,7 +376,8 @@ static int _online_pv_found(struct cmd_context *cmd,
 	 * Create file named for pvid to record this PV is online.
 	 */
 
-	_online_pvid_file_create(dev);
+	if (!_online_pvid_file_create(dev))
+		return_0;
 
 	if (!vg || !found_vgnames)
 		return 1;


