From: dongsu.park@profitbricks.com <dongsu.park@profitbricks.com>
Date: Mon, 16 Jul 2012 23:18:38 +0200
Subject: [RFC PATCH 2/3] dev-md: optimize detection of MD devices
In-Reply-To: <1342473519-2853-1-git-send-email-dongsu.park@profitbricks.com>
References: <1342473519-2853-1-git-send-email-dongsu.park@profitbricks.com>
Message-ID: <1342473519-2853-3-git-send-email-dongsu.park@profitbricks.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Dongsu Park <dongsu.park@profitbricks.com>

This patch optimizes the detection algorithm of MD devices. In order
to detect MD device, LVM has been trying to find MD magic string from
every underlying device. For that purpose, LVM2 must seek to a specific
offset for each MD metadata version, i.e. 0.9, 1.0, 1.1, 1.2, meaning
4 operations per device. Being quite inefficient, that causes
performance problems when creating a certain amount of logical volumes.

The solution to that is reading block area only 2 times for each MD
device. First, try to read several bytes from the beginning of device.
(This is the case of MD metadata version 1.2 or 1.1)
If MD magic is found there, return immediately.
If not found, then try again to read from the end of device.
(That's the case of MD metadata version 1.0 or 0.9)

This mechanism allows LVM tools to determine more quickly whether a
device is MD device or not, avoiding multiple seek operations to the
end of each device. For each device, the maximum number of seeks to the
end of device will decrease from 2 to 1. Under circumstances, no seek
will be needed at all, when a MD magic is found already from the
beginning of device.

It's also necessary to start reading MD magic v1.2, followed by reading
lower versions of MD magic afterwards, because MD devices with newer
versions of MD metadata (e.g. 1.2) will be more common in these days.

Signed-off-by: Dongsu Park <dongsu.park@profitbricks.com>
---
 lib/device/dev-md.c |  155 ++++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 141 insertions(+), 14 deletions(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 247a8ac..4cd0a7b 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -20,6 +20,12 @@
 
 #ifdef linux
 
+/* MD metadata versions from 0.9 to 1.2 */
+typedef struct md_vers_offset {
+	uint64_t sb_offset;
+	uint32_t md_magic;
+} md_vers_offset_t;
+
 /* Lifted from <linux/raid/md_p.h> because of difficulty including it */
 
 #define MD_SB_MAGIC 0xa92b4efc
@@ -79,19 +85,124 @@ static uint64_t _v1_sb_offset(uint64_t size, md_minor_version_t minor_version)
 }
 
 /*
- * Returns -1 on error
+ * get_md_magic:
+ *  @dev:         [in ] device to be read
+ *  @md_offs:     [in ] array including the md magic pairs (offset, md_magic)
+ *  @len_md_offs: [in ] length of array md_offs[]
+ *  @sb_offset:   [out] offset to superblock obtained
+ *
+ *  Read a specific block area defined in md_offs[], in order to find
+ *  a uint32 integer representing MD magic from a block device.
+ *
+ *  First of all, a memory area from (min_sboff, max_sboff+4) will be read
+ *  out from the block device. The output buffer will then include two integer
+ *  values, one from the beginning (offset min_sboff), and another from the
+ *  end (offset max_sboff).
+ *
+ * Returns 1 if any md_magic is found. 0 if not found,
+ *        -1 on error
+ */
+static int get_md_magic(struct device *dev, md_vers_offset_t *md_offs,
+			unsigned int len_md_offs, uint64_t *sb_offset)
+{
+	int i, ret = 0;
+	uint64_t max_sboff = 0U, min_sboff = 0U;
+	char *magic_buf;
+
+	if (!md_offs)
+		goto err;
+
+	if (len_md_offs < 1)
+		goto err;
+
+	/* Obtain a pair of sb offsets (min_sboff, max_sboff),
+	 * i.e. the min/max values of md_offs[].
+	 */
+	min_sboff = max_sboff = md_offs[0].sb_offset;
+
+	for (i=1; i < len_md_offs; i++) {
+		min_sboff = get_min_val_u64(min_sboff, md_offs[i].sb_offset);
+		max_sboff = get_max_val_u64(max_sboff, md_offs[i].sb_offset);
+	}
+
+	log_debug("min_sboff[%lu], max_sboff[%lu].", min_sboff, max_sboff);
+
+	/* Move the max offset by 4 bytes forwards,
+	 * as we need to read until the end of md magic */
+	max_sboff += sizeof(uint32_t);
+	magic_buf = (char *)alloca(max_sboff - min_sboff);
+
+	log_debug("reading %lu bytes of device area from offset %lu.",
+		max_sboff - min_sboff, min_sboff);
+
+	/* read md magic by once */
+	if (!dev_read(dev, min_sboff, max_sboff - min_sboff, magic_buf)) {
+		log_verbose("cannot read sb_offset.");
+		ret = -1;
+		goto err;
+	}
+
+	/* Get md_magic value for each md version */
+	for (i=0; i < len_md_offs; i++) {
+		md_offs[i].md_magic = *(uint32_t *)(magic_buf
+			+ (md_offs[i].sb_offset - min_sboff));
+
+		if (md_offs[i].md_magic == xlate32(MD_SB_MAGIC) ||
+		    md_offs[i].md_magic == MD_SB_MAGIC) {
+			*sb_offset = md_offs[i].sb_offset;
+			ret = 1;	/* found */
+			goto out;
+		}
+	}
+
+	/* md magic is not found */
+out:
+	log_debug("sb_offset[%lu].", *sb_offset);
+
+	return ret;
+err:
+	return ret;
+}
+
+/*
+ * dev_is_md:
+ *
+ *  Determine if a device is md device.
+ *  First, try to read several bytes from the beginning of device.
+ *  (This is the case of MD metadata version 1.2 or 1.1)
+ *  If any MD magic is found there, return immediately.
+ *  If not found, then try again to read from the end of device.
+ *  (That's the case of MD metadata version 1.0 or 0.9)
+ *
+ *  This mechanism allows LVM tools to read more fast from MD devices,
+ *  avoiding multiple seek operations to the end of each device. For each
+ *  device, the maximum number of seeks to the end of device will decrease
+ *  from 2 to 1. Under circumstances, no seek will be needed@all,
+ *  when a MD magic is found already from the beginning of device.
+ *
+ *  It's also necessary to start reading the MD magic v1.2, followed by
+ *  reading lower versions of MD magic afterwards, because MD devices
+ *  with newer versions of MD metadata (e.g. 1.2) will be more common in
+ *  these days.
+ *
+ * Returns 1 if md_magic is found. 0 if not found,
+ *        -1 on error
  */
 int dev_is_md(struct device *dev, uint64_t *sb)
 {
 	int ret = 1;
-	md_minor_version_t minor;
-	uint64_t size, sb_offset;
+	uint64_t size, sb_offset = 0;
+	md_vers_offset_t md_offs_begin[2];
+	md_vers_offset_t md_offs_end[2];
+	unsigned int len_md_offs;
 
 	if (!dev_get_size(dev, &size)) {
 		stack;
 		return -1;
 	}
 
+	log_debug("block device size = %lu", size);
+
 	if (size < MD_RESERVED_SECTORS * 2)
 		return 0;
 
@@ -100,20 +211,34 @@ int dev_is_md(struct device *dev, uint64_t *sb)
 		return -1;
 	}
 
-	/* Check if it is an md component device. */
-	/* Version 0.90.0 */
-	sb_offset = MD_NEW_SIZE_SECTORS(size) << SECTOR_SHIFT;
-	if (_dev_has_md_magic(dev, sb_offset))
+	/* First of all, try to read md_magic from the beginning of device */
+
+	md_offs_begin[0].sb_offset = _v1_sb_offset(size, MD_MINOR_V2);	/* 1.2 */
+	md_offs_begin[1].sb_offset = _v1_sb_offset(size, MD_MINOR_V1);	/* 1.1 */
+	len_md_offs = sizeof(md_offs_begin) / sizeof(md_offs_begin[0]);
+
+	if ((ret = get_md_magic(dev, md_offs_begin, len_md_offs, &sb_offset)) < 0 ||
+		ret > 0) {
+		/* if md_magic is found, or any error occurred. */
+		stack;
 		goto out;
+	}
 
-	minor = MD_MINOR_VERSION_MIN;
-	/* Version 1, try v1.0 -> v1.2 */
-	do {
-		sb_offset = _v1_sb_offset(size, minor);
-		if (_dev_has_md_magic(dev, sb_offset))
-			goto out;
-	} while (++minor <= MD_MINOR_VERSION_MAX);
+	/* So you haven't found any MD magic from the beginning.
+	 * Then try again to find MD magic from the end of device.
+	 */
+	md_offs_end[0].sb_offset = _v1_sb_offset(size, MD_MINOR_V0);	/* 1.0 */
+	md_offs_end[1].sb_offset = MD_NEW_SIZE_SECTORS(size) << SECTOR_SHIFT;	/* 0.9 */
+	len_md_offs = sizeof(md_offs_end) / sizeof(md_offs_end[0]);
 
+	if ((ret = get_md_magic(dev, md_offs_end, len_md_offs, &sb_offset)) < 0 ||
+		ret > 0) {
+		/* if md_magic is found, or any error occurred. */
+		stack;
+		goto out;
+	}
+
+	/* not found */
 	ret = 0;
 
 out:
@@ -123,6 +248,8 @@ out:
 	if (ret && sb)
 		*sb = sb_offset;
 
+	log_debug("return sb_offset[%lu].", sb_offset);
+
 	return ret;
 }
 
-- 
1.7.10


