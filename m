From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Feb 2021 22:45:11 +0000 (GMT)
Subject: main - dev-type: use fopen for sysfs file
Message-ID: <20210208224511.DC4EB3938398@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3bf2ca11d9ce4ce205a98828ec4bfe8169c33403
Commit:        3bf2ca11d9ce4ce205a98828ec4bfe8169c33403
Parent:        e429e69b6593fa688727fb632d7050f05cd27317
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 7 14:07:17 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 8 23:43:38 2021 +0100

dev-type: use fopen for sysfs file

Directly open sysfs files and save extra stat() call which
is not adding any extra safety in sysfs dir.
---
 lib/device/dev-type.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index dca81d8d1..c9f12d793 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -944,8 +944,7 @@ static unsigned long _dev_topology_attribute(struct dev_types *dt,
 	const char *sysfs_dir = dm_sysfs_dir();
 	char path[PATH_MAX], buffer[64];
 	FILE *fp;
-	struct stat info;
-	dev_t uninitialized_var(primary);
+	dev_t primary = 0;
 	unsigned long result = default_value;
 	unsigned long value = 0UL;
 
@@ -963,9 +962,9 @@ static unsigned long _dev_topology_attribute(struct dev_types *dt,
 	 * - if not: either the kernel doesn't have topology support
 	 *   or the device could be a partition
 	 */
-	if (stat(path, &info) == -1) {
+	if (!(fp = fopen(path, "r"))) {
 		if (errno != ENOENT) {
-			log_sys_debug("stat", path);
+			log_sys_debug("fopen", path);
 			goto out;
 		}
 		if (!dev_get_primary_dev(dt, dev, &primary))
@@ -975,25 +974,20 @@ static unsigned long _dev_topology_attribute(struct dev_types *dt,
 		if (!_snprintf_attr(path, sizeof(path), sysfs_dir, attribute, primary))
 			goto_out;
 
-		if (stat(path, &info) == -1) {
+		if (!(fp = fopen(path, "r"))) {
 			if (errno != ENOENT)
-				log_sys_debug("stat", path);
+				log_sys_debug("fopen", path);
 			goto out;
 		}
 	}
 
-	if (!(fp = fopen(path, "r"))) {
-		log_sys_debug("fopen", path);
-		goto out;
-	}
-
 	if (!fgets(buffer, sizeof(buffer), fp)) {
 		log_sys_debug("fgets", path);
 		goto out_close;
 	}
 
 	if (sscanf(buffer, "%lu", &value) != 1) {
-		log_warn("sysfs file %s not in expected format: %s", path, buffer);
+		log_warn("WARNING: sysfs file %s not in expected format: %s", path, buffer);
 		goto out_close;
 	}
 


