From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 8 Jul 2011 15:54:00 -0000
Subject: LVM2 ./WHATS_NEW lib/device/dev-md.c
Message-ID: <20110708155400.23702.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-07-08 15:53:59

Modified files:
	.              : WHATS_NEW 
	lib/device     : dev-md.c 

Log message:
	Fix warning for pvcreate over MD linear.
	
	If MD linear device has set rounding (overload chunk size attribute),
	the pvcreate command prints this warning:
	
	/dev/md0 sysfs attr level not in expected format: linear

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2038&r2=1.2039
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-md.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/WHATS_NEW	2011/07/08 12:49:50	1.2038
+++ LVM2/WHATS_NEW	2011/07/08 15:53:59	1.2039
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Fix warning in pvcreate for MD linear devices.
   Move snapshot removal activation logic into lib/activate.
   Cope with a PV only discovered missing when creating deptree.
   Abort operation if dm_tree_node_add_target_area fails.
--- LVM2/lib/device/dev-md.c	2011/05/28 09:48:14	1.21
+++ LVM2/lib/device/dev-md.c	2011/07/08 15:53:59	1.22
@@ -27,6 +27,7 @@
 #define MD_RESERVED_SECTORS (MD_RESERVED_BYTES / 512)
 #define MD_NEW_SIZE_SECTORS(x) ((x & ~(MD_RESERVED_SECTORS - 1)) \
 				- MD_RESERVED_SECTORS)
+#define MD_MAX_SYSFS_SIZE 64
 
 static int _dev_has_md_magic(struct device *dev, uint64_t sb_offset)
 {
@@ -176,7 +177,7 @@
 				     const char *attribute_fmt,
 				     void *attribute_value)
 {
-	char path[PATH_MAX+1], buffer[64];
+	char path[PATH_MAX+1], buffer[MD_MAX_SYSFS_SIZE];
 	FILE *fp;
 	int ret = 0;
 
@@ -231,15 +232,20 @@
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
+	/*  We only care about raid - ignore linear/faulty/multipath etc. */
+	if (sscanf(level_string, "raid%d", &level) != 1)
+		return -1;
 
 	return level;
 }


