From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 11 Nov 2011 16:41:38 -0000
Subject: LVM2/lib activate/activate.c activate/activate ...
Message-ID: <20111111164138.8749.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-11-11 16:41:37

Modified files:
	lib/activate   : activate.c activate.h 
	lib/filters    : filter-mpath.c 

Log message:
	Remove unneeded parameter.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.222&r2=1.223
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-mpath.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/lib/activate/activate.c	2011/11/11 15:14:05	1.222
+++ LVM2/lib/activate/activate.c	2011/11/11 16:41:37	1.223
@@ -443,7 +443,7 @@
 	return r;
 }
 
-int lvm_dm_prefix_check(const char *sysfs_dir, int major, int minor, const char *prefix)
+int lvm_dm_prefix_check(int major, int minor, const char *prefix)
 {
 	struct dm_task *dmt;
 	const char *uuid;
--- LVM2/lib/activate/activate.h	2011/11/11 15:14:05	1.87
+++ LVM2/lib/activate/activate.h	2011/11/11 16:41:37	1.88
@@ -53,7 +53,7 @@
 		   int use_modprobe);
 int target_version(const char *target_name, uint32_t *maj,
 		   uint32_t *min, uint32_t *patchlevel);
-int lvm_dm_prefix_check(const char *sysfs_dir, int major, int minor, const char *prefix);
+int lvm_dm_prefix_check(int major, int minor, const char *prefix);
 int list_segment_modules(struct dm_pool *mem, const struct lv_segment *seg,
 			 struct dm_list *modules);
 int list_lv_modules(struct dm_pool *mem, const struct logical_volume *lv,
--- LVM2/lib/filters/filter-mpath.c	2011/11/11 15:24:48	1.1
+++ LVM2/lib/filters/filter-mpath.c	2011/11/11 16:41:37	1.2
@@ -136,7 +136,7 @@
 	if (major != dm_major())
 		return 0;
 
-	return lvm_dm_prefix_check(sysfs_dir, major, minor, MPATH_PREFIX);
+	return lvm_dm_prefix_check(major, minor, MPATH_PREFIX);
 }
 
 static int _ignore_mpath(struct dev_filter *f, struct device *dev)


