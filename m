From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 6 Jul 2009 19:04:26 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf lib/device/d ...
Message-ID: <20090706190426.29812.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-07-06 19:04:25

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf 
	lib/device     : dev-md.c device.h 
	lib/metadata   : metadata.c 
	man            : lvm.conf.5.in 

Log message:
	Use the MD device's stripe-width, instead of chunk_size, to align the
	data blocks of a Physical Volume that is placed directly upon an MD
	device.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1163&r2=1.1164
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-md.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.h.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.230&r2=1.231
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2009/07/03 11:04:06	1.1163
+++ LVM2/WHATS_NEW	2009/07/06 19:04:24	1.1164
@@ -1,5 +1,6 @@
 Version 2.02.49 - 
 ================================
+  Update 'md_chunk_alignment' to use stripe-width to align PV data area.
   Update test/t-inconsistent-metadata.sh to match new vg_read interface.
   Add lvmcache_init() to polldaemon initialization.
   Convert tools to use new vg_read / vg_read_for_update.
--- LVM2/doc/example.conf	2009/06/04 12:01:15	1.40
+++ LVM2/doc/example.conf	2009/07/06 19:04:25	1.41
@@ -94,7 +94,7 @@
     md_component_detection = 1
 
     # By default, if a PV is placed directly upon an md device, LVM2
-    # will align its data blocks with the the chunk_size exposed in sysfs.
+    # will align its data blocks with the md device's stripe-width.
     # 1 enables; 0 disables.
     md_chunk_alignment = 1
 
--- LVM2/lib/device/dev-md.c	2008/10/03 14:22:18	1.13
+++ LVM2/lib/device/dev-md.c	2009/07/06 19:04:25	1.14
@@ -125,39 +125,57 @@
 	return ret;
 }
 
-/*
- * Retrieve chunk size from md device using sysfs.
- */
-unsigned long dev_md_chunk_size(const char *sysfs_dir, struct device *dev)
+static int _md_sysfs_attribute_snprintf(char *path, size_t size,
+					const char *sysfs_dir,
+					struct device *dev,
+					const char *attribute)
 {
-	char path[PATH_MAX+1], buffer[64];
-	FILE *fp;
 	struct stat info;
-	unsigned long chunk_size_bytes = 0UL;
+	int ret = -1;
 
 	if (MAJOR(dev->dev) != md_major())
-		return 0;
+		return ret;
 
 	if (!sysfs_dir || !*sysfs_dir)
-		return_0;
+		return ret;
 
-	if (dm_snprintf(path, PATH_MAX, "%s/dev/block/%d:%d/md/chunk_size",
-	    sysfs_dir, MAJOR(dev->dev), MINOR(dev->dev)) < 0) {
-		log_error("dm_snprintf md chunk_size failed");
-		return 0;
+	ret = dm_snprintf(path, size, "%s/dev/block/%d:%d/md/%s",
+	      sysfs_dir, MAJOR(dev->dev), MINOR(dev->dev), attribute);
+	if (ret < 0) {
+		log_error("dm_snprintf md %s failed", attribute);
+		return ret;
 	}
 
-	/* old sysfs structure */
-	if (stat(path, &info) &&
-	    dm_snprintf(path, PATH_MAX, "%s/block/md%d/md/chunk_size",
-			sysfs_dir, MINOR(dev->dev)) < 0) {
-		log_error("dm_snprintf old md chunk size failed");
-		return 0;
+	if (stat(path, &info) < 0) {
+		/* old sysfs structure */
+		ret = dm_snprintf(path, size, "%s/block/md%d/md/%s",
+				  sysfs_dir, MINOR(dev->dev), attribute);
+		if (ret < 0) {
+			log_error("dm_snprintf old md %s failed", attribute);
+			return ret;
+		}
 	}
 
+	return ret;
+}
+
+static int _md_sysfs_attribute_scanf(const char *sysfs_dir,
+				     struct device *dev,
+				     const char *attribute_name,
+				     const char *attribute_fmt,
+				     void *attribute_value)
+{
+	char path[PATH_MAX+1], buffer[64];
+	FILE *fp;
+	int ret = 0;
+
+	if (_md_sysfs_attribute_snprintf(path, PATH_MAX, sysfs_dir,
+					 dev, attribute_name) < 0)
+		return ret;
+
 	if (!(fp = fopen(path, "r"))) {
 		log_sys_error("fopen", path);
-		return 0;
+		return ret;
 	}
 
 	if (!fgets(buffer, sizeof(buffer), fp)) {
@@ -165,22 +183,130 @@
 		goto out;
 	}
 
-	if (sscanf(buffer, "%lu", &chunk_size_bytes) != 1) {
-		log_error("sysfs file %s not in expected format: %s", path,
-			  buffer);
+	if ((ret = sscanf(buffer, attribute_fmt, attribute_value)) != 1) {
+		log_error("%s sysfs attr %s not in expected format: %s",
+			  dev_name(dev), attribute_name, buffer);
 		goto out;
 	}
 
-	log_very_verbose("Device %s md chunk size is %lu bytes.",
-			 dev_name(dev), chunk_size_bytes);
-
 out:
 	if (fclose(fp))
 		log_sys_error("fclose", path);
 
+	return ret;
+}
+
+/*
+ * Retrieve chunk size from md device using sysfs.
+ */
+static unsigned long dev_md_chunk_size(const char *sysfs_dir,
+				       struct device *dev)
+{
+	const char *attribute = "chunk_size";
+	unsigned long chunk_size_bytes = 0UL;
+
+	if (_md_sysfs_attribute_scanf(sysfs_dir, dev, attribute,
+				      "%lu", &chunk_size_bytes) != 1)
+		return 0;
+
+	log_very_verbose("Device %s %s is %lu bytes.",
+			 dev_name(dev), attribute, chunk_size_bytes);
+
 	return chunk_size_bytes >> SECTOR_SHIFT;
 }
 
+/*
+ * Retrieve level from md device using sysfs.
+ */
+static int dev_md_level(const char *sysfs_dir, struct device *dev)
+{
+	const char *attribute = "level";
+	int level = -1;
+
+	if (_md_sysfs_attribute_scanf(sysfs_dir, dev, attribute,
+				      "raid%d", &level) != 1)
+		return -1;
+
+	log_very_verbose("Device %s %s is raid%d.",
+			 dev_name(dev), attribute, level);
+
+	return level;
+}
+
+/*
+ * Retrieve raid_disks from md device using sysfs.
+ */
+static int dev_md_raid_disks(const char *sysfs_dir, struct device *dev)
+{
+	const char *attribute = "raid_disks";
+	int raid_disks = 0;
+
+	if (_md_sysfs_attribute_scanf(sysfs_dir, dev, attribute,
+				      "%d", &raid_disks) != 1)
+		return 0;
+
+	log_very_verbose("Device %s %s is %d.",
+			 dev_name(dev), attribute, raid_disks);
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
+	/* The raid level governs the number of data disks. */
+	switch (level) {
+	case 0:
+		/* striped md does not have any parity disks */
+		data_disks = raid_disks;
+		break;
+	case 1:
+	case 10:
+		/* mirrored md effectively has 1 data disk */
+		data_disks = 1;
+		break;
+	case 4:
+	case 5:
+		/* both raid 4 and 5 have a single parity disk */
+		data_disks = raid_disks - 1;
+		break;
+	case 6:
+		/* raid 6 has 2 parity disks */
+		data_disks = raid_disks - 2;
+		break;
+	default:
+		log_error("Device %s has an unknown md raid level: %d",
+			  dev_name(dev), level);
+		return 0;
+	}
+
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
@@ -189,8 +315,8 @@
 	return 0;
 }
 
-unsigned long dev_md_chunk_size(const char *sysfs_dir __attribute((unused)),
-				struct device *dev  __attribute((unused)))
+unsigned long dev_md_stripe_width(const char *sysfs_dir __attribute((unused)),
+				  struct device *dev  __attribute((unused)))
 {
 	return 0UL;
 }
--- LVM2/lib/device/device.h	2009/05/20 11:09:49	1.39
+++ LVM2/lib/device/device.h	2009/07/06 19:04:25	1.40
@@ -96,7 +96,7 @@
 /* Does device contain md superblock?  If so, where? */
 int dev_is_md(struct device *dev, uint64_t *sb);
 int dev_is_swap(struct device *dev, uint64_t *signature);
-unsigned long dev_md_chunk_size(const char *sysfs_dir, struct device *dev);
+unsigned long dev_md_stripe_width(const char *sysfs_dir, struct device *dev);
 
 int is_partitioned_dev(struct device *dev);
 
--- LVM2/lib/metadata/metadata.c	2009/07/01 17:03:38	1.230
+++ LVM2/lib/metadata/metadata.c	2009/07/06 19:04:25	1.231
@@ -81,13 +81,13 @@
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
--- LVM2/man/lvm.conf.5.in	2009/02/22 19:00:28	1.2
+++ LVM2/man/lvm.conf.5.in	2009/07/06 19:04:25	1.3
@@ -134,8 +134,8 @@
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


