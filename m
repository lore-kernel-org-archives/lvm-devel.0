From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 13 Jul 2009 16:11:20 -0400
Subject: [PATCH 4/6] Improve ability to lookup primary device associated with partition
In-Reply-To: <1247515882-13736-1-git-send-email-snitzer@redhat.com>
References: <1247515882-13736-1-git-send-email-snitzer@redhat.com>
Message-ID: <1247515882-13736-5-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Improve lib/device/device.c:_primary_dev()'s ability to look up the
primary device associated with all partitions; including blkext
(e.g. partitions directly on MD).  The same will also work for obscure
sysfs paths; e.g.: paths with mangled names like the HP cciss driver
uses: /sys/block/cciss!c0d0/cciss!c0d0p1/

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 lib/device/device.c |   56 +++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 49 insertions(+), 7 deletions(-)

Index: LVM2/lib/device/device.c
===================================================================
--- LVM2.orig/lib/device/device.c
+++ LVM2/lib/device/device.c
@@ -13,6 +13,7 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#include <libgen.h> /* dirname, basename */
 #include "lib.h"
 #include "lvm-types.h"
 #include "device.h"
@@ -288,22 +289,63 @@ int _get_partition_type(struct dev_mgr *
 static int _primary_dev(const char *sysfs_dir,
 			struct device *dev, dev_t *result)
 {
-	char path[PATH_MAX+1];
+	char path[PATH_MAX+1], temp_path[PATH_MAX+1], buffer[64];
 	struct stat info;
+	FILE *fp;
+	int pri_maj, pri_min, ret = 0;
 
 	/* check if dev is a partition */
 	if (dm_snprintf(path, PATH_MAX, "%s/dev/block/%d:%d/partition",
 			sysfs_dir, MAJOR(dev->dev), MINOR(dev->dev)) < 0) {
 		log_error("dm_snprintf partition failed");
-		return 0;
+		return ret;
 	}
-
 	if (stat(path, &info) < 0)
-		return 0;
+		return ret;
 
-	*result = dev->dev -
-		(MINOR(dev->dev) % max_partitions(MAJOR(dev->dev)));
-	return 1;
+	/*
+	 * extract parent's path from the partition's symlink, e.g.:
+	 * - readlink /sys/dev/block/259:0 = ../../block/md0/md0p1
+	 * - dirname ../../block/md0/md0p1 = ../../block/md0
+	 * - basename ../../block/md0/md0  = md0
+	 * Parent's 'dev' sysfs attribute  = /sys/block/md0/dev
+	 */
+	if (readlink(dirname(path), temp_path, PATH_MAX) < 0) {
+		log_sys_error("readlink", path);
+		return ret;
+	}
+	if (dm_snprintf(path, PATH_MAX, "%s/block/%s/dev",
+			sysfs_dir, basename(dirname(temp_path))) < 0) {
+		log_error("dm_snprintf dev failed");
+		return ret;
+	}
+
+	/* finally, parse 'dev' attribute and create corresponding dev_t */
+	if (stat(path, &info) < 0) {
+		log_error("sysfs file %s does not exist", path);
+		return ret;
+	}
+	if (!(fp = fopen(path, "r"))) {
+		log_sys_error("fopen", path);
+		return ret;
+	}
+	if (!fgets(buffer, sizeof(buffer), fp)) {
+		log_sys_error("fgets", path);
+		goto out;
+	}
+	if (sscanf(buffer, "%d:%d", &pri_maj, &pri_min) != 2) {
+		log_error("sysfs file %s not in expected MAJ:MIN format: %s",
+			  path, buffer);
+		goto out;
+	}
+	*result = makedev(pri_maj, pri_min);
+	ret = 1;
+
+out:
+	if (fclose(fp))
+		log_sys_error("fclose", path);
+
+	return ret;
 }
 
 static unsigned long _dev_topology_attribute(const char *attribute,


