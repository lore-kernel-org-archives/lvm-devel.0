From: Mike Snitzer <snitzer@redhat.com>
Date: Fri,  3 Jul 2009 00:42:48 -0400
Subject: [PATCH] update 'md_chunk_alignment' support to use stripe-width
Message-ID: <1246596168-17218-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use the MD device's stripe-width, instead of chunk_size, to align the
data blocks of a Physical Volume that is placed directly upon an MD
device.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 lib/device/dev-md.c     |  161 ++++++++++++++++++++++++++++++++++++++++--------
 lib/device/device.h     |    2 
 lib/metadata/metadata.c |    6 -
 man/lvm.conf.5.in       |    4 -
 4 files changed, 143 insertions(+), 30 deletions(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 190bc88..7cb58e2 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -125,62 +125,175 @@ out:
 	return ret;
 }
 
-/*
- * Retrieve chunk size from md device using sysfs.
- */
-unsigned long dev_md_chunk_size(const char *sysfs_dir, struct device *dev)
+static FILE *md_sysfs_fopen(const char *sysfs_dir, struct device *dev,
+			    const char *attribute)
 {
-	char path[PATH_MAX+1], buffer[64];
+	char path[PATH_MAX+1];
 	FILE *fp;
 	struct stat info;
-	unsigned long chunk_size_bytes = 0UL;
 
 	if (MAJOR(dev->dev) != md_major())
-		return 0;
+		return NULL;
 
 	if (!sysfs_dir || !*sysfs_dir)
-		return_0;
+		return NULL;
 
-	if (dm_snprintf(path, PATH_MAX, "%s/dev/block/%d:%d/md/chunk_size",
-	    sysfs_dir, MAJOR(dev->dev), MINOR(dev->dev)) < 0) {
-		log_error("dm_snprintf md chunk_size failed");
-		return 0;
+	if (dm_snprintf(path, PATH_MAX, "%s/dev/block/%d:%d/md/%s",
+	    sysfs_dir, MAJOR(dev->dev), MINOR(dev->dev), attribute) < 0) {
+		log_error("dm_snprintf md %s failed", attribute);
+		return NULL;
 	}
 
 	/* old sysfs structure */
 	if (stat(path, &info) &&
-	    dm_snprintf(path, PATH_MAX, "%s/block/md%d/md/chunk_size",
-			sysfs_dir, MINOR(dev->dev)) < 0) {
-		log_error("dm_snprintf old md chunk size failed");
-		return 0;
+	    dm_snprintf(path, PATH_MAX, "%s/block/md%d/md/%s",
+			sysfs_dir, MINOR(dev->dev), attribute) < 0) {
+		log_error("dm_snprintf old md %s failed", attribute);
+		return NULL;
 	}
 
 	if (!(fp = fopen(path, "r"))) {
 		log_sys_error("fopen", path);
-		return 0;
+		return NULL;
 	}
 
+	return fp;
+}
+
+/*
+ * Retrieve chunk size from md device using sysfs.
+ */
+static unsigned long dev_md_chunk_size(const char *sysfs_dir,
+				       struct device *dev)
+{
+	char buffer[64];
+	FILE *fp;
+	const char *attribute = "chunk_size";
+	unsigned long chunk_size_bytes = 0UL;
+
+	if (!(fp = md_sysfs_fopen(sysfs_dir, dev, attribute)))
+		return 0;
+
 	if (!fgets(buffer, sizeof(buffer), fp)) {
-		log_sys_error("fgets", path);
+		log_sys_error("fgets", attribute);
 		goto out;
 	}
 
 	if (sscanf(buffer, "%lu", &chunk_size_bytes) != 1) {
-		log_error("sysfs file %s not in expected format: %s", path,
-			  buffer);
+		log_error("%s sysfs attr %s not in expected format: %s",
+			  dev_name(dev), attribute, buffer);
 		goto out;
 	}
 
-	log_very_verbose("Device %s md chunk size is %lu bytes.",
+	log_very_verbose("Device %s chunk size is %lu bytes.",
 			 dev_name(dev), chunk_size_bytes);
 
 out:
 	if (fclose(fp))
-		log_sys_error("fclose", path);
+		log_sys_error("fclose", attribute);
 
 	return chunk_size_bytes >> SECTOR_SHIFT;
 }
 
+/*
+ * Retrieve level from md device using sysfs.
+ */
+static int dev_md_level(const char *sysfs_dir, struct device *dev)
+{
+	char buffer[64];
+	FILE *fp;
+	const char *attribute = "level";
+	int level = -1;
+
+	if (!(fp = md_sysfs_fopen(sysfs_dir, dev, attribute)))
+		return -1;
+
+	if (!fgets(buffer, sizeof(buffer), fp)) {
+		log_sys_error("fgets", attribute);
+		goto out;
+	}
+
+	if (sscanf(buffer, "raid%d", &level) != 1) {
+		log_error("%s sysfs attr %s not in expected format: %s",
+			  dev_name(dev), attribute, buffer);
+		goto out;
+	}
+
+	log_very_verbose("Device %s raid level is %d.",
+			 dev_name(dev), level);
+
+out:
+	if (fclose(fp))
+		log_sys_error("fclose", attribute);
+
+	return level;
+}
+
+/*
+ * Retrieve raid_disks from md device using sysfs.
+ */
+static int dev_md_raid_disks(const char *sysfs_dir, struct device *dev)
+{
+	char buffer[64];
+	FILE *fp;
+	const char *attribute = "raid_disks";
+	int raid_disks = 0;
+
+	if (!(fp = md_sysfs_fopen(sysfs_dir, dev, attribute)))
+		return 0;
+
+	if (!fgets(buffer, sizeof(buffer), fp)) {
+		log_sys_error("fgets", attribute);
+		goto out;
+	}
+
+	if (sscanf(buffer, "%d", &raid_disks) != 1) {
+		log_error("%s sysfs attr %s not in expected format: %s",
+			  dev_name(dev), attribute, buffer);
+		goto out;
+	}
+
+	log_very_verbose("Device %s raid_disks is %d.",
+			 dev_name(dev), raid_disks);
+
+out:
+	if (fclose(fp))
+		log_sys_error("fclose", attribute);
+
+	return raid_disks;
+}
+
+/*
+ * Calculate stripe width of md device using its sysfs files.
+ */
+unsigned long dev_md_stripe_width(const char *sysfs_dir, struct device *dev)
+{
+	unsigned long chunk_size_sectors = 0UL;
+	unsigned long stripe_width_sectors = 0UL;
+	int level, raid_disks, data_disks;
+
+	chunk_size_sectors = dev_md_chunk_size(sysfs_dir, dev);
+	if (!chunk_size_sectors)
+		return 0;
+
+	level = dev_md_level(sysfs_dir, dev);
+	if (level < 0)
+		return 0;
+
+	raid_disks = dev_md_raid_disks(sysfs_dir, dev);
+	if (!raid_disks)
+		return 0;
+
+	data_disks = raid_disks - (level == 0 ? 0 : (level <= 5 ? 1 : 2));
+	stripe_width_sectors = chunk_size_sectors * data_disks;
+
+	log_very_verbose("Device %s stripe-width is %lu bytes.",
+			 dev_name(dev),
+			 stripe_width_sectors << SECTOR_SHIFT);
+
+	return stripe_width_sectors;
+}
+
 #else
 
 int dev_is_md(struct device *dev __attribute((unused)),
@@ -189,8 +302,8 @@ int dev_is_md(struct device *dev __attribute((unused)),
 	return 0;
 }
 
-unsigned long dev_md_chunk_size(const char *sysfs_dir __attribute((unused)),
-				struct device *dev  __attribute((unused)))
+unsigned long dev_md_stripe_width(const char *sysfs_dir __attribute((unused)),
+				  struct device *dev  __attribute((unused)))
 {
 	return 0UL;
 }
diff --git a/lib/device/device.h b/lib/device/device.h
index 94f17b4..b016823 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -96,7 +96,7 @@ const char *dev_name_confirmed(struct device *dev, int quiet);
 /* Does device contain md superblock?  If so, where? */
 int dev_is_md(struct device *dev, uint64_t *sb);
 int dev_is_swap(struct device *dev, uint64_t *signature);
-unsigned long dev_md_chunk_size(const char *sysfs_dir, struct device *dev);
+unsigned long dev_md_stripe_width(const char *sysfs_dir, struct device *dev);
 
 int is_partitioned_dev(struct device *dev);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index dc7e759..fda07be 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -81,13 +81,13 @@ unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignm
 		goto out;
 
 	/*
-	 * Align to chunk size of underlying md device if present
+	 * Align to stripe-width of underlying md device if present
 	 */
 	if (find_config_tree_bool(pv->fmt->cmd, "devices/md_chunk_alignment",
 				  DEFAULT_MD_CHUNK_ALIGNMENT))
 		pv->pe_align = MAX(pv->pe_align,
-				   dev_md_chunk_size(pv->fmt->cmd->sysfs_dir,
-						     pv->dev));
+				   dev_md_stripe_width(pv->fmt->cmd->sysfs_dir,
+						       pv->dev));
 
 	log_very_verbose("%s: Setting PE alignment to %lu sectors.",
 			 dev_name(pv->dev), pv->pe_align);
diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index 68024b6..0e3a949 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -134,8 +134,8 @@ superblocks. This doesn't always work satisfactorily e.g. if a device
 has been reused without wiping the md superblocks first.
 .IP
 \fBmd_chunk_alignment\fP \(em If set to 1, and a Physical Volume is placed
-directly upon an md device, LVM2 will align its data blocks with the the
-chunk_size exposed in sysfs.
+directly upon an md device, LVM2 will align its data blocks with the
+md device's stripe-width.
 .IP
 \fBdata_alignment\fP \(em Default alignment (in KB) of start of data area
 when creating a new Physical Volume using the \fBlvm2\fP format.


