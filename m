From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Nov 2019 12:07:15 -0500
Subject: master - devtype: simplify code
Message-ID: <88255.119111412071000847@us-mta-38.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=43f149526d5074dbc6deeaca38e30d02611eadf8
Commit:        43f149526d5074dbc6deeaca38e30d02611eadf8
Parent:        33c8e4de33b2b2fced148e04f725af9d350a989a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 14 16:57:02 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 14 18:06:14 2019 +0100

devtype: simplify code

Update code with simpler form and check for fclose().
---
 lib/device/dev-type.c |   39 +++++++++++++--------------------------
 1 files changed, 13 insertions(+), 26 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index ebe0f99..fba4dc9 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -42,7 +42,6 @@ int dev_is_pmem(struct device *dev)
 {
 	FILE *fp;
 	char path[PATH_MAX];
-	char buffer[64];
 	int is_pmem = 0;
 
 	if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d/queue/dax",
@@ -56,27 +55,16 @@ int dev_is_pmem(struct device *dev)
 	if (!(fp = fopen(path, "r")))
 		return 0;
 
-	if (!fgets(buffer, sizeof(buffer), fp)) {
-		log_warn("Failed to read %s.", path);
-		if (fclose(fp))
-			log_sys_debug("fclose", path);
-		return 0;
-	} else if (sscanf(buffer, "%d", &is_pmem) != 1) {
-		log_warn("Failed to parse %s '%s'.", path, buffer);
-		if (fclose(fp))
-			log_sys_debug("fclose", path);
-		return 0;
-	}
+	if (fscanf(fp, "%d", &is_pmem) != 1)
+		log_warn("Failed to parse DAX %s.", path);
+
+	if (is_pmem)
+		log_debug("%s is pmem", dev_name(dev));
 
 	if (fclose(fp))
 		log_sys_debug("fclose", path);
 
-	if (is_pmem) {
-		log_debug("%s is pmem", dev_name(dev));
-		return 1;
-	}
-
-	return 0;
+	return is_pmem ? 1 : 0;
 }
 
 int dev_is_lv(struct device *dev)
@@ -84,6 +72,7 @@ int dev_is_lv(struct device *dev)
 	FILE *fp;
 	char path[PATH_MAX];
 	char buffer[64];
+	int ret = 0;
 
 	if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d/dm/uuid",
 			dm_sysfs_dir(),
@@ -96,17 +85,15 @@ int dev_is_lv(struct device *dev)
 	if (!(fp = fopen(path, "r")))
 		return 0;
 
-	if (!fgets(buffer, sizeof(buffer), fp)) {
+	if (!fgets(buffer, sizeof(buffer), fp))
 		log_warn("Failed to read %s.", path);
-		fclose(fp);
-		return 0;
-	}
+	else if (!strncmp(buffer, "LVM-", 4))
+		ret = 1;
 
-	fclose(fp);
+	if (fclose(fp))
+		log_sys_debug("fclose", path);
 
-	if (!strncmp(buffer, "LVM-", 4))
-		return 1;
-	return 0;
+	return ret;
 }
 
 struct dev_types *create_dev_types(const char *proc_dir,



