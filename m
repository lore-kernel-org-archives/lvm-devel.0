From: David Teigland <teigland@sourceware.org>
Date: Thu,  9 Jul 2020 15:50:12 +0000 (GMT)
Subject: master - devices: detect md ddf and imsm superblocks
Message-ID: <20200709155012.838AD386F835@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=23774f997ea077f2cbe8a32bd8bccdd7f4560cca
Commit:        23774f997ea077f2cbe8a32bd8bccdd7f4560cca
Parent:        286a793c12aac1fde17cb9768bacad660e1dfeb3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 19 11:33:59 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jul 9 10:48:21 2020 -0500

devices: detect md ddf and imsm superblocks

---
 lib/device/dev-md.c | 105 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 104 insertions(+), 1 deletion(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 9d0a36363..13a3c168a 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -16,6 +16,7 @@
 #include "lib/misc/lib.h"
 #include "lib/device/dev-type.h"
 #include "lib/mm/xlate.h"
+#include "lib/misc/crc.h"
 #ifdef UDEV_SYNC_SUPPORT
 #include <libudev.h> /* for MD detection using udev db records */
 #include "lib/device/dev-ext-udev-constants.h"
@@ -48,6 +49,93 @@ static int _dev_has_md_magic(struct device *dev, uint64_t sb_offset)
 	return 0;
 }
 
+#define IMSM_SIGNATURE "Intel Raid ISM Cfg Sig. "
+#define IMSM_SIG_LEN (strlen(IMSM_SIGNATURE))
+
+static int _dev_has_imsm_magic(struct device *dev, uint64_t devsize_sectors)
+{
+	char imsm_signature[IMSM_SIG_LEN];
+	uint64_t off = (devsize_sectors * 512) - 1024;
+
+	if (!dev_read_bytes(dev, off, IMSM_SIG_LEN, imsm_signature))
+		return_0;
+
+	if (!memcmp(imsm_signature, IMSM_SIGNATURE, IMSM_SIG_LEN))
+		return 1;
+
+	return 0;
+}
+
+#define DDF_MAGIC 0xDE11DE11
+struct ddf_header {
+	uint32_t magic;
+	uint32_t crc;
+	char guid[24];
+	char revision[8];
+	char padding[472];
+};
+
+static int _dev_has_ddf_magic(struct device *dev, uint64_t devsize_sectors)
+{
+	struct ddf_header hdr;
+	uint32_t crc, our_crc;
+	uint64_t off;
+	uint64_t devsize_bytes = devsize_sectors * 512;
+
+	if (devsize_bytes < 0x30000)
+		return 0;
+
+	/* 512 bytes before the end of device (from libblkid) */
+	off = ((devsize_bytes / 0x200) - 1) * 0x200;
+
+	if (!dev_read_bytes(dev, off, 512, &hdr))
+		return_0;
+
+	if ((hdr.magic == cpu_to_be32(DDF_MAGIC)) ||
+	    (hdr.magic == cpu_to_le32(DDF_MAGIC))) {
+		crc = hdr.crc;
+		hdr.crc = 0xffffffff;
+		our_crc = calc_crc(0, (const uint8_t *)&hdr, 512);
+
+		if ((cpu_to_be32(our_crc) == crc) ||
+		    (cpu_to_le32(our_crc) == crc)) {
+			log_debug_devs("Found md ddf magic at %llu crc %x %s",
+				       (unsigned long long)off, crc, dev_name(dev));
+			return 1;
+		} else {
+			log_debug_devs("Found md ddf magic at %llu wrong crc %x disk %x %s",
+				       (unsigned long long)off, our_crc, crc, dev_name(dev));
+			return 0;
+		}
+	}
+
+	/* 128KB before the end of device (from libblkid) */
+	off = ((devsize_bytes / 0x200) - 257) * 0x200;
+
+	if (!dev_read_bytes(dev, off, 512, &hdr))
+		return_0;
+
+	if ((hdr.magic == cpu_to_be32(DDF_MAGIC)) ||
+	    (hdr.magic == cpu_to_le32(DDF_MAGIC))) {
+		crc = hdr.crc;
+		hdr.crc = 0xffffffff;
+		our_crc = calc_crc(0, (const uint8_t *)&hdr, 512);
+
+		if ((cpu_to_be32(our_crc) == crc) ||
+		    (cpu_to_le32(our_crc) == crc)) {
+			log_debug_devs("Found md ddf magic at %llu crc %x %s",
+				       (unsigned long long)off, crc, dev_name(dev));
+			return 1;
+		} else {
+			log_debug_devs("Found md ddf magic at %llu wrong crc %x disk %x %s",
+				       (unsigned long long)off, our_crc, crc, dev_name(dev));
+			return 0;
+		}
+	}
+
+	return 0;
+}
+
 /*
  * Calculate the position of the superblock.
  * It is always aligned to a 4K boundary and
@@ -178,8 +266,8 @@ static int _native_dev_is_md_component(struct device *dev, uint64_t *offset_foun
 		goto out;
 	}
 
-	/* Check if it is an md component device. */
 	/* Version 0.90.0 */
+	/* superblock@64KB from end of device */
 	sb_offset = MD_NEW_SIZE_SECTORS(size) << SECTOR_SHIFT;
 	if (_dev_has_md_magic(dev, sb_offset)) {
 		ret = 1;
@@ -187,8 +275,11 @@ static int _native_dev_is_md_component(struct device *dev, uint64_t *offset_foun
 	}
 
 	minor = MD_MINOR_VERSION_MIN;
+
 	/* Version 1, try v1.0 -> v1.2 */
+
 	do {
+		/* superblock at start or 4K from start */
 		sb_offset = _v1_sb_offset(size, minor);
 		if (_dev_has_md_magic(dev, sb_offset)) {
 			ret = 1;
@@ -196,6 +287,18 @@ static int _native_dev_is_md_component(struct device *dev, uint64_t *offset_foun
 		}
 	} while (++minor <= MD_MINOR_VERSION_MAX);
 
+	/* superblock 1K from end of device */
+	if (_dev_has_imsm_magic(dev, size)) {
+		ret = 1;
+		goto out;
+	}
+
+	/* superblock 512 bytes from end, or 128KB from end */
+	if (_dev_has_ddf_magic(dev, size)) {
+		ret = 1;
+		goto out;
+	}
+
 	ret = 0;
 out:
 	if (ret && offset_found)


