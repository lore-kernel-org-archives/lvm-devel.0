From: Milan Broz <mbroz@redhat.com>
Date: Tue, 27 Oct 2009 16:31:53 +0100
Subject: [PATCH] Recoginse DRBD device part and handle it similar to MD devices.
Message-ID: <1256657513-13660-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The DRBD uses underlying device so code should prefer top
device if duplicate is found.

Patch also introduce
	dev_subsystem_part_major and dev_subsytem_name
functions to easily handle all these replication susbystems
and not hardcode md_major call.

See https://bugzilla.redhat.com/show_bug.cgi?id=530881
for full problem description.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/cache/lvmcache.c       |   14 ++++++++------
 lib/filters/filter.c       |   30 ++++++++++++++++++++++++++++++
 lib/filters/filter.h       |    3 +++
 lib/format1/disk-rep.c     |    7 ++++---
 lib/format_pool/disk_rep.c |    7 ++++---
 5 files changed, 49 insertions(+), 12 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 7a3fb4c..dc391c8 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1173,11 +1173,12 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 	} else {
 		if (existing->dev != dev) {
 			/* Is the existing entry a duplicate pvid e.g. md ? */
-			if (MAJOR(existing->dev->dev) == md_major() &&
-			    MAJOR(dev->dev) != md_major()) {
+			if (dev_subsystem_part_major(existing->dev) &&
+			    !dev_subsystem_part_major(dev)) {
 				log_very_verbose("Ignoring duplicate PV %s on "
-						 "%s - using md %s",
+						 "%s - using %s %s",
 						 pvid, dev_name(dev),
+						 dev_subsystem_name(existing->dev),
 						 dev_name(existing->dev));
 				return NULL;
 			} else if (dm_is_dm_major(MAJOR(existing->dev->dev)) &&
@@ -1187,11 +1188,12 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 						 pvid, dev_name(dev),
 						 dev_name(existing->dev));
 				return NULL;
-			} else if (MAJOR(existing->dev->dev) != md_major() &&
-				   MAJOR(dev->dev) == md_major())
+			} else if (!dev_subsystem_part_major(existing->dev) &&
+				   dev_subsystem_part_major(dev))
 				log_very_verbose("Duplicate PV %s on %s - "
-						 "using md %s", pvid,
+						 "using %s %s", pvid,
 						 dev_name(existing->dev),
+						 dev_subsystem_name(existing->dev),
 						 dev_name(dev));
 			else if (!dm_is_dm_major(MAJOR(existing->dev->dev)) &&
 				 dm_is_dm_major(MAJOR(dev->dev)))
diff --git a/lib/filters/filter.c b/lib/filters/filter.c
index d8ce366..889b416 100644
--- a/lib/filters/filter.c
+++ b/lib/filters/filter.c
@@ -39,6 +39,7 @@ typedef struct {
 
 static int _md_major = -1;
 static int _blkext_major = -1;
+static int _drbd_major = -1;
 static int _device_mapper_major = -1;
 
 int md_major(void)
@@ -51,6 +52,31 @@ int blkext_major(void)
 	return _blkext_major;
 }
 
+int dev_subsystem_part_major(const struct device *dev)
+{
+	if (MAJOR(dev->dev) == -1)
+		return 0;
+
+	if (MAJOR(dev->dev) == _md_major)
+		return 1;
+
+	if (MAJOR(dev->dev) == _drbd_major)
+		return 1;
+
+	return 0;
+}
+
+const char *dev_subsystem_name(const struct device *dev)
+{
+	if (MAJOR(dev->dev) == _md_major)
+		return "MD";
+
+	if (MAJOR(dev->dev) == _drbd_major)
+		return "DRBD";
+
+	return "";
+}
+
 /*
  * Devices are only checked for partition tables if their minor number
  * is a multiple of the number corresponding to their type below
@@ -207,6 +233,10 @@ static int _scan_proc_dev(const char *proc, const struct config_node *cn)
 		if (!strncmp("blkext", line + i, 6) && isspace(*(line + i + 6)))
 			_blkext_major = line_maj;
 
+		/* Look for drbd device */
+		if (!strncmp("drbd", line + i, 4) && isspace(*(line + i + 4)))
+			_drbd_major = line_maj;
+
 		/* Look for device-mapper device */
 		/* FIXME Cope with multiple majors */
 		if (!strncmp("device-mapper", line + i, 13) && isspace(*(line + i + 13)))
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index 948d074..4da3325 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -39,4 +39,7 @@ int md_major(void);
 int blkext_major(void);
 int max_partitions(int major);
 
+int dev_subsystem_part_major(const struct device *dev);
+const char *dev_subsystem_name(const struct device *dev);
+
 #endif
diff --git a/lib/format1/disk-rep.c b/lib/format1/disk-rep.c
index c5faf5b..c6439d4 100644
--- a/lib/format1/disk-rep.c
+++ b/lib/format1/disk-rep.c
@@ -435,14 +435,15 @@ static void _add_pv_to_list(struct dm_list *head, struct disk_list *data)
 		pvd = &diskl->pvd;
 		if (!strncmp((char *)data->pvd.pv_uuid, (char *)pvd->pv_uuid,
 			     sizeof(pvd->pv_uuid))) {
-			if (MAJOR(data->dev->dev) != md_major()) {
+			if (!dev_subsystem_part_major(data->dev)) {
 				log_very_verbose("Ignoring duplicate PV %s on "
 						 "%s", pvd->pv_uuid,
 						 dev_name(data->dev));
 				return;
 			}
-			log_very_verbose("Duplicate PV %s - using md %s",
-					 pvd->pv_uuid, dev_name(data->dev));
+			log_very_verbose("Duplicate PV %s - using %s %s",
+					 pvd->pv_uuid, dev_subsystem_name(data->dev),
+					 dev_name(data->dev));
 			dm_list_del(&diskl->list);
 			break;
 		}
diff --git a/lib/format_pool/disk_rep.c b/lib/format_pool/disk_rep.c
index 802bf52..adbae6d 100644
--- a/lib/format_pool/disk_rep.c
+++ b/lib/format_pool/disk_rep.c
@@ -62,14 +62,15 @@ static void _add_pl_to_list(struct dm_list *head, struct pool_list *data)
 
 			id_write_format(&pl->pv_uuid, uuid, ID_LEN + 7);
 
-			if (MAJOR(data->dev->dev) != md_major()) {
+			if (!dev_subsystem_part_major(data->dev)) {
 				log_very_verbose("Ignoring duplicate PV %s on "
 						 "%s", uuid,
 						 dev_name(data->dev));
 				return;
 			}
-			log_very_verbose("Duplicate PV %s - using md %s",
-					 uuid, dev_name(data->dev));
+			log_very_verbose("Duplicate PV %s - using %s %s",
+					 uuid, dev_subsystem_name(data->dev),
+					 dev_name(data->dev));
 			dm_list_del(&pl->list);
 			break;
 		}
-- 
1.6.5


