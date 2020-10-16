From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:32 +0000 (GMT)
Subject: stable-2.02 - devices: detect md ddf and imsm superblocks
Message-ID: <20201016191132.A6DAD396EC83@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=57ddaaa47dc3f730057ed77bc457c820ed51f29f
Commit:        57ddaaa47dc3f730057ed77bc457c820ed51f29f
Parent:        db7aef215afba518024aefea3e412f23cf7b80bd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 19 11:33:59 2019 -0500
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

devices: detect md ddf and imsm superblocks

---
 lib/device/dev-md.c | 105 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 104 insertions(+), 1 deletion(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 972850726..fa9547009 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -16,6 +16,7 @@
 #include "lib.h"
 #include "dev-type.h"
 #include "xlate.h"
+#include "crc.h"
 #ifdef UDEV_SYNC_SUPPORT
 #include <libudev.h> /* for MD detection using udev db records */
 #include "dev-ext-udev-constants.h"
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
@@ -162,8 +250,8 @@ static int _native_dev_is_md(struct device *dev, uint64_t *offset_found, int ful
 		goto out;
 	}
 
-	/* Check if it is an md component device. */
 	/* Version 0.90.0 */
+	/* superblock@64KB from end of device */
 	sb_offset = MD_NEW_SIZE_SECTORS(size) << SECTOR_SHIFT;
 	if (_dev_has_md_magic(dev, sb_offset)) {
 		ret = 1;
@@ -171,8 +259,11 @@ static int _native_dev_is_md(struct device *dev, uint64_t *offset_found, int ful
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
@@ -180,6 +271,18 @@ static int _native_dev_is_md(struct device *dev, uint64_t *offset_found, int ful
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


