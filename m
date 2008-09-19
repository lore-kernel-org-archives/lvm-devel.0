From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Sep 2008 05:19:10 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c lib/d ...
Message-ID: <20080919051910.23167.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-19 05:19:09

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 
	lib/device     : dev-md.c device.h 

Log message:
	adjust pe_align for md chunk size

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.957&r2=1.958
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.188&r2=1.189
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-md.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.h.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/WHATS_NEW	2008/09/19 04:27:27	1.957
+++ LVM2/WHATS_NEW	2008/09/19 05:19:08	1.958
@@ -1,6 +1,6 @@
 Version 2.02.40 - 
 ================================
-  Pass struct physical_volume to pe_align.
+  Pass struct physical_volume to pe_align and adjust for md chunk size.
   Store sysfs location in struct cmd_context.
   Avoid shuffling remaining mirror images when removing one, retaining primary.
   Add missing LV error target activation in _remove_mirror_images.
--- LVM2/lib/metadata/metadata.c	2008/09/19 04:27:27	1.188
+++ LVM2/lib/metadata/metadata.c	2008/09/19 05:19:09	1.189
@@ -66,9 +66,20 @@
 
 unsigned long pe_align(struct physical_volume *pv)
 {
-	if (!pv->pe_align)
-		pv->pe_align = MAX(65536UL, lvm_getpagesize()) >> SECTOR_SHIFT;
+	if (pv->pe_align)
+		goto out;
 
+	pv->pe_align = MAX(65536UL, lvm_getpagesize()) >> SECTOR_SHIFT;
+
+	/*
+	 * Align to chunk size of underlying md device if present
+	 */
+	if (pv->dev)
+		pv->pe_align = MAX(pv->pe_align,
+				   dev_md_chunk_size(pv->fmt->cmd->sysfs_dir,
+						     pv->dev));
+
+out:
 	return pv->pe_align;
 }
 
--- LVM2/lib/device/dev-md.c	2008/06/23 19:26:21	1.10
+++ LVM2/lib/device/dev-md.c	2008/09/19 05:19:09	1.11
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2004 Luca Berra
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -16,6 +16,7 @@
 #include "lib.h"
 #include "metadata.h"
 #include "xlate.h"
+#include "filter.h"
 
 #ifdef linux
 
@@ -124,6 +125,62 @@
 	return ret;
 }
 
+/*
+ * Retrieve chunk size from md device using sysfs.
+ */
+unsigned long dev_md_chunk_size(const char *sysfs_dir, struct device *dev)
+{
+	char path[PATH_MAX+1], buffer[64];
+	FILE *fp;
+	struct stat info;
+	unsigned long chunk_size = 0UL;
+
+	if (MAJOR(dev->dev) != md_major())
+		return 0;
+
+	if (!sysfs_dir || !*sysfs_dir)
+		return_0;
+
+	if (dm_snprintf(path, PATH_MAX, "%s/dev/block/%d:%d/md/chunk_size",
+	    sysfs_dir, MAJOR(dev->dev), MINOR(dev->dev)) < 0) {
+		log_error("dm_snprintf md chunk_size failed");
+		return 0;
+	}
+
+	/* old sysfs structure */
+	if (stat(path, &info) &&
+	    dm_snprintf(path, PATH_MAX, "%s/block/md%d/md/chunk_size",
+			sysfs_dir, MINOR(dev->dev)) < 0) {
+		log_error("dm_snprintf old md chunk size failed");
+		return 0;
+	}
+
+	if (!(fp = fopen(path, "r"))) {
+		log_sys_error("fopen", path);
+		return 0;
+	}
+
+	if (!fgets(buffer, sizeof(buffer), fp)) {
+		log_sys_error("fgets", path);
+		goto out;
+	}
+
+	if (sscanf(buffer, "%lu", &chunk_size) != 1) {
+		log_error("sysfs file %s not in expected format: %s", path,
+			  buffer);
+		goto out;
+	}
+
+	log_very_verbose("Found chunksize %u for md device %s.", chunk_size,
+			 dev_name(dev));
+
+out:
+	if (fclose(fp))
+		log_sys_error("fclose", path);
+
+	return chunk_size;
+}
+
 #else
 
 int dev_is_md(struct device *dev __attribute((unused)),
@@ -132,4 +189,10 @@
 	return 0;
 }
 
+unsigned long dev_md_chunk_size(const char *sysfs_dir __attribute((unused)),
+				struct device *dev  __attribute((unused)))
+{
+	return 0UL;
+}
+
 #endif
--- LVM2/lib/device/device.h	2008/07/23 19:46:33	1.35
+++ LVM2/lib/device/device.h	2008/09/19 05:19:09	1.36
@@ -93,6 +93,7 @@
 
 /* Does device contain md superblock?  If so, where? */
 int dev_is_md(struct device *dev, uint64_t *sb);
+unsigned long dev_md_chunk_size(const char *sysfs_dir, struct device *dev);
 
 int is_partitioned_dev(struct device *dev);
 


