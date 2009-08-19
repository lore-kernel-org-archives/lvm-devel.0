From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 19 Aug 2009 15:34:48 -0000
Subject: LVM2 ./WHATS_NEW lib/device/dev-md.c lib/filte ...
Message-ID: <20090819153448.2034.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-08-19 15:34:46

Modified files:
	.              : WHATS_NEW 
	lib/device     : dev-md.c 
	lib/filters    : filter.c filter.h 

Log message:
	Fix pvcreate on a partition (regressed in 2.02.51).
	
	Eliminate busy loop during pvcreate of a "normal" partition.
	_md_sysfs_attribute_snprintf() would busy loop if the device it was
	given was not a blkext-based MD partition.
	
	Rather than being cute with a busy-loop prone 'goto check_md_major' in
	_md_sysfs_attribute_snprintf(): explicitly check if the provided device
	is a blkext-based partition (blkext_major()); and then check that the
	get_primary_dev() determined parent is an MD device (md_major()).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1241&r2=1.1242
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-md.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.h.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/WHATS_NEW	2009/08/13 17:16:38	1.1241
+++ LVM2/WHATS_NEW	2009/08/19 15:34:33	1.1242
@@ -1,5 +1,6 @@
 Version 2.02.52 -
 =================================
+  Fix pvcreate on a partition (2.02.51).
   Fix vgcfgrestore error paths when locking fails (2.02.49).
   Added configure --enable-clogd to conditionally build the cluster log daemon.
   Make lvchange --refresh only take a read lock on volume group.
--- LVM2/lib/device/dev-md.c	2009/08/01 17:14:52	1.18
+++ LVM2/lib/device/dev-md.c	2009/08/19 15:34:43	1.19
@@ -137,13 +137,15 @@
 	if (!sysfs_dir || !*sysfs_dir)
 		return ret;
 
-check_md_major:
-	if (MAJOR(dev) != md_major()) {
-		if (get_primary_dev(sysfs_dir, blkdev, &dev))
-			goto check_md_major;
-		return ret;
+	if (MAJOR(dev) == blkext_major()) {
+		/* lookup parent MD device from blkext partition */
+		if (!get_primary_dev(sysfs_dir, blkdev, &dev))
+			return ret;
 	}
 
+	if (MAJOR(dev) != md_major())
+		return ret;
+
 	ret = dm_snprintf(path, size, "%s/dev/block/%d:%d/md/%s", sysfs_dir,
 			  (int)MAJOR(dev), (int)MINOR(dev), attribute);
 	if (ret < 0) {
--- LVM2/lib/filters/filter.c	2009/07/09 22:34:02	1.48
+++ LVM2/lib/filters/filter.c	2009/08/19 15:34:46	1.49
@@ -38,6 +38,7 @@
 } device_info_t;
 
 static int _md_major = -1;
+static int _blkext_major = -1;
 static int _device_mapper_major = -1;
 
 int md_major(void)
@@ -45,6 +46,11 @@
 	return _md_major;
 }
 
+int blkext_major(void)
+{
+	return _blkext_major;
+}
+
 /*
  * Devices are only checked for partition tables if their minor number
  * is a multiple of the number corresponding to their type below
@@ -197,6 +203,10 @@
 		if (!strncmp("md", line + i, 2) && isspace(*(line + i + 2)))
 			_md_major = line_maj;
 
+		/* Look for blkext device */
+		if (!strncmp("blkext", line + i, 6) && isspace(*(line + i + 6)))
+			_blkext_major = line_maj;
+
 		/* Look for device-mapper device */
 		/* FIXME Cope with multiple majors */
 		if (!strncmp("device-mapper", line + i, 13) && isspace(*(line + i + 13)))
--- LVM2/lib/filters/filter.h	2007/08/20 20:55:25	1.15
+++ LVM2/lib/filters/filter.h	2009/08/19 15:34:46	1.16
@@ -36,6 +36,7 @@
 void lvm_type_filter_destroy(struct dev_filter *f);
 
 int md_major(void);
+int blkext_major(void);
 int max_partitions(int major);
 
 #endif


