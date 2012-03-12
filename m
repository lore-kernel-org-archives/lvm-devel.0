From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 12 Mar 2012 14:40:43 -0000
Subject: LVM2 ./WHATS_NEW lib/device/dev-cache.h lib/fi ...
Message-ID: <20120312144043.27580.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-12 14:40:42

Modified files:
	.              : WHATS_NEW 
	lib/device     : dev-cache.h 
	lib/filters    : filter.c filter.h 

Log message:
	Better structure layout for device_info
	
	Save some relocation entries and use directly char[].
	Since we do not need yes more then 127 partitions per device, use just int8_t.
	Move lvm_type_filter_destroy into local static function.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2351&r2=1.2352
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.h.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.h.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/WHATS_NEW	2012/03/12 14:18:28	1.2351
+++ LVM2/WHATS_NEW	2012/03/12 14:40:41	1.2352
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Better structure layout for device_info in dev_subsystem_name().
   Change message severity for creation of VG over uninitialised devices.
   Fix error path for failing toolcontext creation.
   Fix warn msg for thin pool chunk size and update man for chunksize (2.02.89).
--- LVM2/lib/device/dev-cache.h	2012/02/23 13:11:09	1.15
+++ LVM2/lib/device/dev-cache.h	2012/03/12 14:40:42	1.16
@@ -25,8 +25,8 @@
 struct dev_filter {
 	int (*passes_filter) (struct dev_filter * f, struct device * dev);
 	void (*destroy) (struct dev_filter * f);
-	unsigned use_count;
 	void *private;
+	unsigned use_count;
 };
 
 /*
--- LVM2/lib/filters/filter.c	2012/02/28 10:11:35	1.70
+++ LVM2/lib/filters/filter.c	2012/03/12 14:40:42	1.71
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -36,8 +36,8 @@
 } _partitions[NUMBER_OF_MAJORS];
 
 typedef struct {
-	const char *name;
-	const int max_partitions;
+	const char name[15];
+	const int8_t max_partitions;
 } device_info_t;
 
 static int _md_major = -1;
@@ -107,7 +107,7 @@
  *
  * The list can be supplemented with devices/types in the config file.
  */
-static const device_info_t device_info[] = {
+static const device_info_t _device_info[] = {
 	{"ide", 64},		/* IDE disk */
 	{"sd", 16},		/* SCSI disk */
 	{"md", 1},		/* Multiple Disk driver (SoftRAID) */
@@ -136,7 +136,7 @@
 	{"mmc", 16},		/* MMC block device */
 	{"blkext", 1},		/* Extended device partitions */
 	{"fio", 16},		/* Fusion */
-	{NULL, 0}
+	{"", 0}
 };
 
 static int _passes_lvm_type_device_filter(struct dev_filter *f __attribute__((unused)),
@@ -220,7 +220,7 @@
 		return 0;
 	}
 
-	while (fgets(line, 80, pd) != NULL) {
+	while (fgets(line, sizeof(line), pd) != NULL) {
 		i = 0;
 		while (line[i] == ' ')
 			i++;
@@ -269,13 +269,13 @@
 
 		/* Go through the valid device names and if there is a
 		   match store max number of partitions */
-		for (j = 0; device_info[j].name != NULL; j++) {
-			dev_len = strlen(device_info[j].name);
+		for (j = 0; _device_info[j].name[0]; j++) {
+			dev_len = strlen(_device_info[j].name);
 			if (dev_len <= strlen(line + i) &&
-			    !strncmp(device_info[j].name, line + i, dev_len) &&
+			    !strncmp(_device_info[j].name, line + i, dev_len) &&
 			    (line_maj < NUMBER_OF_MAJORS)) {
 				_partitions[line_maj].max_partitions =
-				    device_info[j].max_partitions;
+				    _device_info[j].max_partitions;
 				break;
 			}
 		}
@@ -342,6 +342,14 @@
 	return (_partitions[major].flags & PARTITION_SCSI_DEVICE) ? 1 : 0;
 }
 
+static void _lvm_type_filter_destroy(struct dev_filter *f)
+{
+	if (f->use_count)
+		log_error(INTERNAL_ERROR "Destroying lvm_type filter while in use %u times.", f->use_count);
+
+	dm_free(f);
+}
+
 struct dev_filter *lvm_type_filter_create(const char *proc,
 					  const struct dm_config_node *cn)
 {
@@ -353,7 +361,7 @@
 	}
 
 	f->passes_filter = _passes_lvm_type_device_filter;
-	f->destroy = lvm_type_filter_destroy;
+	f->destroy = _lvm_type_filter_destroy;
 	f->use_count = 0;
 	f->private = NULL;
 
@@ -364,11 +372,3 @@
 
 	return f;
 }
-
-void lvm_type_filter_destroy(struct dev_filter *f)
-{
-	if (f->use_count)
-		log_error(INTERNAL_ERROR "Destroying lvm_type filter while in use %u times.", f->use_count);
-
-	dm_free(f);
-}
--- LVM2/lib/filters/filter.h	2011/11/11 15:11:12	1.20
+++ LVM2/lib/filters/filter.h	2012/03/12 14:40:42	1.21
@@ -33,8 +33,6 @@
 struct dev_filter *lvm_type_filter_create(const char *proc,
 					  const struct dm_config_node *cn);
 
-void lvm_type_filter_destroy(struct dev_filter *f);
-
 int dm_major(void);
 int md_major(void);
 int blkext_major(void);


