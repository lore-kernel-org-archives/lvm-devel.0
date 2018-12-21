From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Dec 2018 15:47:06 -0500
Subject: master - debug: tracing close errors
Message-ID: <201812212047.wBLKl6gm021454@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2724a09e586acb38a7fd9ce68223213a32aa37fc
Commit:        2724a09e586acb38a7fd9ce68223213a32aa37fc
Parent:        095c9791caa01bbfc14ac5caef45c9c5ba05e721
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 21 20:26:15 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 21 21:45:08 2018 +0100

debug: tracing close errors

---
 lib/device/dev-type.c |    9 ++++++---
 tools/pvscan.c        |    3 ++-
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index d96f00b..638f4b2 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -58,15 +58,18 @@ int dev_is_pmem(struct device *dev)
 
 	if (!fgets(buffer, sizeof(buffer), fp)) {
 		log_warn("Failed to read %s.", path);
-		fclose(fp);
+		if (fclose(fp))
+			log_sys_debug("fclose", path);
 		return 0;
 	} else if (sscanf(buffer, "%d", &is_pmem) != 1) {
 		log_warn("Failed to parse %s '%s'.", path, buffer);
-		fclose(fp);
+		if (fclose(fp))
+			log_sys_debug("fclose", path);
 		return 0;
 	}
 
-	fclose(fp);
+	if (fclose(fp))
+		log_sys_debug("fclose", path);
 
 	if (is_pmem) {
 		log_debug("%s is pmem", dev_name(dev));
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 6841f20..3f3c745 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -291,7 +291,8 @@ static int _online_pvid_file_create(struct device *dev)
 		if (rv < 0) {
 			log_error("Failed to write fd %d buf %s dev %s to %s: %d",
 			          fd, buf, dev_name(dev), path, errno);
-			close(fd);
+			if (close(fd))
+				log_sys_debug("close", path);
 			return 0;
 		}
 		len -= rv;


