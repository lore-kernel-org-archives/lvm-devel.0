From: David Teigland <teigland@sourceware.org>
Date: Fri,  7 Apr 2023 19:26:41 +0000 (GMT)
Subject: main - support 16KB page size
Message-ID: <20230407192641.785EF3858D32@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b443eac6efd29a72a4356f54c713cc9a0e0da866
Commit:        b443eac6efd29a72a4356f54c713cc9a0e0da866
Parent:        b1789b84c39a10241f3e09a4bad16e482db784e4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 7 09:05:07 2023 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 7 14:26:09 2023 -0500

support 16KB page size

---
 lib/config/config.c     | 3 +++
 lib/metadata/metadata.c | 3 +++
 tools/pvck.c            | 7 +++++--
 3 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 5986e64b1..2bb55daeb 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -540,6 +540,9 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 				log_sys_error("read", dev_name(dev));
 				goto out;
 			}
+
+			if (!sz)
+				goto out;
 		}
 	} else {
 		if (!dev_read_bytes(dev, offset, size, buf))
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 10af75665..07244bf6a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -119,6 +119,7 @@ int get_default_pvmetadatasize_sectors(void)
 	 * pagesizes:
 	 * 4096 = 8 sectors.
 	 * 8192 = 16 sectors.
+	 * 16384 = 32 sectors.
 	 * 65536 = 128 sectors.
 	 */
 
@@ -127,6 +128,8 @@ int get_default_pvmetadatasize_sectors(void)
 		return 2040;
 	case 8192:
 		return 2032;
+	case 16384:
+		return 2016;
 	case 65536:
 		return 1920;
 	}
diff --git a/tools/pvck.c b/tools/pvck.c
index 5273da63c..879810b76 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -1146,7 +1146,10 @@ static int _dump_label_and_pv_header(struct cmd_context *cmd, uint64_t labelsect
 			 * mda1 offset is page size from machine that created it,
 			 * warn if it's not one of the expected page sizes.
 			 */
-			if ((*mda1_offset != 4096) && (*mda1_offset != 8192) && (*mda1_offset != 65536)) {
+			if ((*mda1_offset != 4096) && 
+			    (*mda1_offset != 8192) &&
+			    (*mda1_offset != 16384) &&
+			    (*mda1_offset != 65536)) {
 				log_print("WARNING: pv_header.disk_locn[%d].offset %llu is unexpected # for first mda",
 					  di, (unsigned long long)*mda1_offset);
 			}
@@ -1273,7 +1276,7 @@ static int _dump_mda_header(struct cmd_context *cmd, struct settings *set,
 	uint64_t meta_offset = 0; /* bytes */
 	uint64_t meta_size = 0;   /* bytes */
 	uint32_t meta_checksum = 0;
-	int mda_num = (mda_offset == 4096) ? 1 : 2;
+	int mda_num = (mda_offset <= 65536) ? 1 : 2;
 	int bad = 0;
 
 	*checksum0_ret = 0; /* checksum from raw_locn[0] */

