From: Milan Broz <mbroz@redhat.com>
Date: Fri,  8 Jul 2011 16:30:38 +0200
Subject: [PATCH] Fix warning for pvcreate over MD linear.
Message-ID: <1310135438-23604-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If MD linear device has set rounding (overload chunk size attribute),
the pvcreate command prints this warning:

  /dev/md0 sysfs attr level not in expected format: linear

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/device/dev-md.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 0d522f4..e572392 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -27,6 +27,7 @@
 #define MD_RESERVED_SECTORS (MD_RESERVED_BYTES / 512)
 #define MD_NEW_SIZE_SECTORS(x) ((x & ~(MD_RESERVED_SECTORS - 1)) \
 				- MD_RESERVED_SECTORS)
+#define MD_MAX_SYSFS_SIZE 64
 
 static int _dev_has_md_magic(struct device *dev, uint64_t sb_offset)
 {
@@ -176,7 +177,7 @@ static int _md_sysfs_attribute_scanf(const char *sysfs_dir,
 				     const char *attribute_fmt,
 				     void *attribute_value)
 {
-	char path[PATH_MAX+1], buffer[64];
+	char path[PATH_MAX+1], buffer[MD_MAX_SYSFS_SIZE];
 	FILE *fp;
 	int ret = 0;
 
@@ -231,15 +232,19 @@ static unsigned long dev_md_chunk_size(const char *sysfs_dir,
  */
 static int dev_md_level(const char *sysfs_dir, struct device *dev)
 {
+	char level_string[MD_MAX_SYSFS_SIZE];
 	const char *attribute = "level";
 	int level = -1;
 
 	if (_md_sysfs_attribute_scanf(sysfs_dir, dev, attribute,
-				      "raid%d", &level) != 1)
+				      "%s", &level_string) != 1)
 		return -1;
 
-	log_very_verbose("Device %s %s is raid%d.",
-			 dev_name(dev), attribute, level);
+	log_very_verbose("Device %s %s is %s.",
+			 dev_name(dev), attribute, level_string);
+
+	if (sscanf(level_string, "raid%d", &level) != 1)
+		return -1;
 
 	return level;
 }
-- 
1.7.5.4


