From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  4 Jul 2014 10:32:04 +0000 (UTC)
Subject: master - dev-type: print log_sys_debug
Message-ID: <20140704103204.1476260C22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a94abc0fdd33b31cd292d9b9a61ddceb7b72208f
Commit:        a94abc0fdd33b31cd292d9b9a61ddceb7b72208f
Parent:        ac60c876c43d0ebc7e642dcc92528b974bd7b9f5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 3 12:03:16 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 4 12:31:17 2014 +0200

dev-type: print log_sys_debug

For non-fatal error use log_sys_debug as the tool
is not stopping on these errors.
---
 lib/device/dev-type.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index e0cae45..0d91017 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -676,7 +676,7 @@ static unsigned long _dev_topology_attribute(struct dev_types *dt,
 	 */
 	if (stat(path, &info) == -1) {
 		if (errno != ENOENT) {
-			log_sys_error("stat", path);
+			log_sys_debug("stat", path);
 			return 0;
 		}
 		if (!dev_get_primary_dev(dt, dev, &primary))
@@ -688,24 +688,23 @@ static unsigned long _dev_topology_attribute(struct dev_types *dt,
 
 		if (stat(path, &info) == -1) {
 			if (errno != ENOENT)
-				log_sys_error("stat", path);
+				log_sys_debug("stat", path);
 			return 0;
 		}
 	}
 
 	if (!(fp = fopen(path, "r"))) {
-		log_sys_error("fopen", path);
+		log_sys_debug("fopen", path);
 		return 0;
 	}
 
 	if (!fgets(buffer, sizeof(buffer), fp)) {
-		log_sys_error("fgets", path);
+		log_sys_debug("fgets", path);
 		goto out;
 	}
 
 	if (sscanf(buffer, "%lu", &result) != 1) {
-		log_error("sysfs file %s not in expected format: %s", path,
-			  buffer);
+		log_warn("sysfs file %s not in expected format: %s", path, buffer);
 		goto out;
 	}
 
@@ -714,7 +713,7 @@ static unsigned long _dev_topology_attribute(struct dev_types *dt,
 
 out:
 	if (fclose(fp))
-		log_sys_error("fclose", path);
+		log_sys_debug("fclose", path);
 
 	return result >> SECTOR_SHIFT;
 }


