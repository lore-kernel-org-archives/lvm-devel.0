From: David Teigland <teigland@sourceware.org>
Date: Thu,  9 Jul 2020 15:50:13 +0000 (GMT)
Subject: master - devices: simplify md superblock checking code
Message-ID: <20200709155013.A58C9387084E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=00c9a788cc617e5e40746dee2e17287d61ee5c81
Commit:        00c9a788cc617e5e40746dee2e17287d61ee5c81
Parent:        23774f997ea077f2cbe8a32bd8bccdd7f4560cca
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 19 12:17:36 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jul 9 10:48:34 2020 -0500

devices: simplify md superblock checking code

---
 lib/device/dev-md.c | 135 ++++++++++++++++++++++------------------------------
 1 file changed, 58 insertions(+), 77 deletions(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 13a3c168a..23ce41af1 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -75,7 +75,7 @@ struct ddf_header {
 	char padding[472];
 };
 
-static int _dev_has_ddf_magic(struct device *dev, uint64_t devsize_sectors)
+static int _dev_has_ddf_magic(struct device *dev, uint64_t devsize_sectors, uint64_t *sb_offset)
 {
 	struct ddf_header hdr;
 	uint32_t crc, our_crc;
@@ -99,8 +99,7 @@ static int _dev_has_ddf_magic(struct device *dev, uint64_t devsize_sectors)
 
 		if ((cpu_to_be32(our_crc) == crc) ||
 		    (cpu_to_le32(our_crc) == crc)) {
-			log_debug_devs("Found md ddf magic at %llu crc %x %s",
-				       (unsigned long long)off, crc, dev_name(dev));
+			*sb_offset = off;
 			return 1;
 		} else {
 			log_debug_devs("Found md ddf magic at %llu wrong crc %x disk %x %s",
@@ -123,8 +122,7 @@ static int _dev_has_ddf_magic(struct device *dev, uint64_t devsize_sectors)
 
 		if ((cpu_to_be32(our_crc) == crc) ||
 		    (cpu_to_le32(our_crc) == crc)) {
-			log_debug_devs("Found md ddf magic at %llu crc %x %s",
-				       (unsigned long long)off, crc, dev_name(dev));
+			*sb_offset = off;
 			return 1;
 		} else {
 			log_debug_devs("Found md ddf magic at %llu wrong crc %x disk %x %s",
@@ -136,46 +134,6 @@ static int _dev_has_ddf_magic(struct device *dev, uint64_t devsize_sectors)
 	return 0;
 }
 
-/*
- * Calculate the position of the superblock.
- * It is always aligned to a 4K boundary and
- * depending on minor_version, it can be:
- * 0: At least 8K, but less than 12K, from end of device
- * 1: At start of device
- * 2: 4K from start of device.
- */
-typedef enum {
-	MD_MINOR_VERSION_MIN,
-	MD_MINOR_V0 = MD_MINOR_VERSION_MIN,
-	MD_MINOR_V1,
-	MD_MINOR_V2,
-	MD_MINOR_VERSION_MAX = MD_MINOR_V2
-} md_minor_version_t;
-
-static uint64_t _v1_sb_offset(uint64_t size, md_minor_version_t minor_version)
-{
-	uint64_t sb_offset;
-
-	switch(minor_version) {
-	case MD_MINOR_V0:
-		sb_offset = (size - 8 * 2) & ~(4 * 2 - 1ULL);
-		break;
-	case MD_MINOR_V1:
-		sb_offset = 0;
-		break;
-	case MD_MINOR_V2:
-		sb_offset = 4 * 2;
-		break;
-	default:
-		log_warn(INTERNAL_ERROR "WARNING: Unknown minor version %d.",
-			 minor_version);
-		return 0;
-	}
-	sb_offset <<= SECTOR_SHIFT;
-
-	return sb_offset;
-}
-
 /*
  * _udev_dev_is_md_component() only works if
  *   external_device_info_source="udev"
@@ -218,7 +176,6 @@ static int _udev_dev_is_md_component(struct device *dev)
  */
 static int _native_dev_is_md_component(struct device *dev, uint64_t *offset_found, int full)
 {
-	md_minor_version_t minor;
 	uint64_t size, sb_offset;
 	int ret;
 
@@ -234,9 +191,9 @@ static int _native_dev_is_md_component(struct device *dev, uint64_t *offset_foun
 		return 0;
 
 	/*
-	 * Old md versions locate the magic number at the end of the device.
-	 * Those checks can't be satisfied with the initial bcache data, and
-	 * would require an extra read i/o at the end of every device.  Issuing
+	 * Some md versions locate the magic number at the end of the device.
+	 * Those checks can't be satisfied with the initial scan data, and
+	 * require an extra read i/o at the end of every device.  Issuing
 	 * an extra read to every device in every command, just to check for
 	 * the old md format is a bad tradeoff.
 	 *
@@ -247,54 +204,78 @@ static int _native_dev_is_md_component(struct device *dev, uint64_t *offset_foun
 	 * and set it for commands that could possibly write to an md dev
 	 * (pvcreate/vgcreate/vgextend).
 	 */
-	if (!full) {
-		sb_offset = 0;
-		if (_dev_has_md_magic(dev, sb_offset)) {
-			log_debug_devs("Found md magic number at offset 0 of %s.", dev_name(dev));
-			ret = 1;
-			goto out;
-		}
 
-		sb_offset = 8 << SECTOR_SHIFT;
-		if (_dev_has_md_magic(dev, sb_offset)) {
-			log_debug_devs("Found md magic number at offset %d of %s.", (int)sb_offset, dev_name(dev));
-			ret = 1;
-			goto out;
-		}
+	/*
+	 * md superblock version 1.1 at offset 0 from start
+	 */
+
+	if (_dev_has_md_magic(dev, 0)) {
+		log_debug_devs("Found md magic number at offset 0 of %s.", dev_name(dev));
+		ret = 1;
+		goto out;
+	}
+
+	/*
+	 * md superblock version 1.2 at offset 4KB from start
+	 */
 
+	if (_dev_has_md_magic(dev, 4096)) {
+		log_debug_devs("Found md magic number at offset 4096 of %s.", dev_name(dev));
+		ret = 1;
+		goto out;
+	}
+
+	if (!full) {
 		ret = 0;
 		goto out;
 	}
 
-	/* Version 0.90.0 */
-	/* superblock at 64KB from end of device */
+	/*
+	 * Handle superblocks at the end of the device.
+	 */
+
+	/*
+	 * md superblock version 0 at 64KB from end of device
+	 * (after end is aligned to 64KB)
+	 */
+
 	sb_offset = MD_NEW_SIZE_SECTORS(size) << SECTOR_SHIFT;
+
 	if (_dev_has_md_magic(dev, sb_offset)) {
+		log_debug_devs("Found md magic number at offset %llu of %s.", (unsigned long long)sb_offset, dev_name(dev));
 		ret = 1;
 		goto out;
 	}
 
-	minor = MD_MINOR_VERSION_MIN;
+	/*
+	 * md superblock version 1.0@8KB from end of device
+	 */
 
-	/* Version 1, try v1.0 -> v1.2 */
+	sb_offset = ((size - 8 * 2) & ~(4 * 2 - 1ULL)) << SECTOR_SHIFT;
 
-	do {
-		/* superblock at start or 4K from start */
-		sb_offset = _v1_sb_offset(size, minor);
-		if (_dev_has_md_magic(dev, sb_offset)) {
-			ret = 1;
-			goto out;
-		}
-	} while (++minor <= MD_MINOR_VERSION_MAX);
+	if (_dev_has_md_magic(dev, sb_offset)) {
+		log_debug_devs("Found md magic number at offset %llu of %s.", (unsigned long long)sb_offset, dev_name(dev));
+		ret = 1;
+		goto out;
+	}
+
+	/*
+	 * md imsm superblock 1K from end of device
+	 */
 
-	/* superblock 1K from end of device */
 	if (_dev_has_imsm_magic(dev, size)) {
+		log_debug_devs("Found md imsm magic number at offset %llu of %s.", (unsigned long long)sb_offset, dev_name(dev));
+		sb_offset = 1024;
 		ret = 1;
 		goto out;
 	}
 
-	/* superblock 512 bytes from end, or 128KB from end */
-	if (_dev_has_ddf_magic(dev, size)) {
+	/*
+	 * md ddf superblock 512 bytes from end, or 128KB from end
+	 */
+
+	if (_dev_has_ddf_magic(dev, size, &sb_offset)) {
+		log_debug_devs("Found md ddf magic number@offset %llu of %s.", (unsigned long long)sb_offset, dev_name(dev));
 		ret = 1;
 		goto out;
 	}


