From: Lidong Zhong <lidong.zhong@suse.com>
Date: Mon, 25 Nov 2019 03:30:17 +0000
Subject: [PATCH] filter-partitiond: ignore invalid partitions of loop devices
Message-ID: <20191125032957.7302-1-lidong.zhong@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

After detaching the loop device, partitions of the device become
invalid but sometimes they are still visible. And running lvm2
commands will report error messages like:

linux-cno1:~ # pvs
  Error reading device /dev/loop0p1 at 0 length 4096.
  Error reading device /dev/loop0p2 at 0 length 4096.
  PV         VG Fmt  Attr PSize PFree
  /dev/sda1     lvm2 ---  1.00g 1.00g

This patch is written for ignoring the invalid partitions of loop
devices.

Signed-off-by: Lidong Zhong <lidong.zhong@suse.com>
---
 lib/filters/filter-partitioned.c | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/lib/filters/filter-partitioned.c b/lib/filters/filter-partitioned.c
index 1a700543c..1f04601bd 100644
--- a/lib/filters/filter-partitioned.c
+++ b/lib/filters/filter-partitioned.c
@@ -19,10 +19,35 @@
 
 #define MSG_SKIPPING "%s: Skipping: Partition table signature found"
 
+static int _loop_is_with_partscan(dev_t dev)
+{
+	FILE *fp;
+	int partscan = 1;
+	char path[PATH_MAX];
+	char buffer[64];
+
+	if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d/loop/partscan",
+			dm_sysfs_dir(),
+			(int) MAJOR(dev),
+			(int) MINOR(dev)) < 0) {
+		log_warn("Sysfs path for partscan is too long.");
+		return 0;
+	}
+
+	if (!(fp = fopen(path, "r")))
+		return 0; /* not there -> no partscan */
+
+	if (fclose(fp))
+		log_sys_debug("fclose", path);
+
+	return partscan;
+}
+
 static int _passes_partitioned_filter(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
 {
 	struct dev_types *dt = (struct dev_types *) f->private;
 	int ret;
+	dev_t devt;
 
 	ret = dev_is_partitioned(dt, dev);
 
@@ -42,6 +67,14 @@ static int _passes_partitioned_filter(struct cmd_context *cmd, struct dev_filter
 		return 0;
 	}
 
+	/*check if it's a valid loop partition*/
+	if (MAJOR(dev->dev) == dt->blkext_major && (2 == dev_get_primary_dev(dt, dev, &devt))) {
+		if(MAJOR(devt) == dt->loop_major && !_loop_is_with_partscan(devt)) {
+			log_debug_devs("Partitioned filter skip invalide loop partition: %s.", dev_name(dev));
+			return 0;
+		}   
+	}
+
 	return 1;
 }
 
-- 
2.16.4



