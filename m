From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 12 Jun 2013 11:16:51 +0000 (UTC)
Subject: master - refactor: move lib/filters/device-types.h -> lib/device/device-types.h
Message-ID: <20130612111651.BB15E60F27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=22b0f3573e222f7471c4e279e5703f2933cf6e9a
Commit:        22b0f3573e222f7471c4e279e5703f2933cf6e9a
Parent:        657abb08e0e509e084d23d8b4dcf6248362cccd4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 12 11:46:07 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 12 11:54:36 2013 +0200

refactor: move lib/filters/device-types.h -> lib/device/device-types.h

---
 lib/device/device-types.h  |   63 ++++++++++++++++++++++++++++++++++++++++++++
 lib/filters/device-types.h |   63 --------------------------------------------
 lib/filters/filter.c       |    2 +-
 3 files changed, 64 insertions(+), 64 deletions(-)

diff --git a/lib/device/device-types.h b/lib/device/device-types.h
new file mode 100644
index 0000000..2e49f7f
--- /dev/null
+++ b/lib/device/device-types.h
@@ -0,0 +1,63 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+typedef struct {
+	const char name[15];
+	const int8_t max_partitions;
+} device_info_t;
+
+/*
+ * Devices are only checked for partition tables if their minor number
+ * is a multiple of the number corresponding to their type below
+ * i.e. this gives the granularity of whole-device minor numbers.
+ * Use 1 if the device is not partitionable.
+ *
+ * The list can be supplemented with devices/types in the config file.
+ */
+static const device_info_t _device_info[] = {
+	{"ide", 64},		/* IDE disk */
+	{"sd", 16},		/* SCSI disk */
+	{"md", 1},		/* Multiple Disk driver (SoftRAID) */
+	{"mdp", 1},		/* Partitionable MD */
+	{"loop", 1},		/* Loop device */
+	{"dasd", 4},		/* DASD disk (IBM S/390, zSeries) */
+	{"dac960", 8},		/* DAC960 */
+	{"nbd", 16},		/* Network Block Device */
+	{"ida", 16},		/* Compaq SMART2 */
+	{"cciss", 16},		/* Compaq CCISS array */
+	{"ubd", 16},		/* User-mode virtual block device */
+	{"ataraid", 16},	/* ATA Raid */
+	{"drbd", 16},		/* Distributed Replicated Block Device */
+	{"emcpower", 16},	/* EMC Powerpath */
+	{"power2", 16},		/* EMC Powerpath */
+	{"i2o_block", 16},	/* i2o Block Disk */
+	{"iseries/vd", 8},	/* iSeries disks */
+	{"gnbd", 1},		/* Network block device */
+	{"ramdisk", 1},		/* RAM disk */
+	{"aoe", 16},		/* ATA over Ethernet */
+	{"device-mapper", 1},	/* Other mapped devices */
+	{"xvd", 16},		/* Xen virtual block device */
+	{"vdisk", 8},		/* SUN's LDOM virtual block device */
+	{"ps3disk", 16},	/* PlayStation 3 internal disk */
+	{"virtblk", 8},		/* VirtIO disk */
+	{"mmc", 16},		/* MMC block device */
+	{"blkext", 1},		/* Extended device partitions */
+	{"fio", 16},		/* Fusion */
+	{"mtip32xx", 16},	/* Micron PCIe SSDs */
+	{"vtms", 16},		/* Violin Memory */
+	{"skd", 16},		/* STEC */
+	{"scm", 8},		/* Storage Class Memory (IBM S/390) */
+	{"", 0}
+};
diff --git a/lib/filters/device-types.h b/lib/filters/device-types.h
deleted file mode 100644
index 2e49f7f..0000000
--- a/lib/filters/device-types.h
+++ /dev/null
@@ -1,63 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
- */
-
-typedef struct {
-	const char name[15];
-	const int8_t max_partitions;
-} device_info_t;
-
-/*
- * Devices are only checked for partition tables if their minor number
- * is a multiple of the number corresponding to their type below
- * i.e. this gives the granularity of whole-device minor numbers.
- * Use 1 if the device is not partitionable.
- *
- * The list can be supplemented with devices/types in the config file.
- */
-static const device_info_t _device_info[] = {
-	{"ide", 64},		/* IDE disk */
-	{"sd", 16},		/* SCSI disk */
-	{"md", 1},		/* Multiple Disk driver (SoftRAID) */
-	{"mdp", 1},		/* Partitionable MD */
-	{"loop", 1},		/* Loop device */
-	{"dasd", 4},		/* DASD disk (IBM S/390, zSeries) */
-	{"dac960", 8},		/* DAC960 */
-	{"nbd", 16},		/* Network Block Device */
-	{"ida", 16},		/* Compaq SMART2 */
-	{"cciss", 16},		/* Compaq CCISS array */
-	{"ubd", 16},		/* User-mode virtual block device */
-	{"ataraid", 16},	/* ATA Raid */
-	{"drbd", 16},		/* Distributed Replicated Block Device */
-	{"emcpower", 16},	/* EMC Powerpath */
-	{"power2", 16},		/* EMC Powerpath */
-	{"i2o_block", 16},	/* i2o Block Disk */
-	{"iseries/vd", 8},	/* iSeries disks */
-	{"gnbd", 1},		/* Network block device */
-	{"ramdisk", 1},		/* RAM disk */
-	{"aoe", 16},		/* ATA over Ethernet */
-	{"device-mapper", 1},	/* Other mapped devices */
-	{"xvd", 16},		/* Xen virtual block device */
-	{"vdisk", 8},		/* SUN's LDOM virtual block device */
-	{"ps3disk", 16},	/* PlayStation 3 internal disk */
-	{"virtblk", 8},		/* VirtIO disk */
-	{"mmc", 16},		/* MMC block device */
-	{"blkext", 1},		/* Extended device partitions */
-	{"fio", 16},		/* Fusion */
-	{"mtip32xx", 16},	/* Micron PCIe SSDs */
-	{"vtms", 16},		/* Violin Memory */
-	{"skd", 16},		/* STEC */
-	{"scm", 8},		/* Storage Class Memory (IBM S/390) */
-	{"", 0}
-};
diff --git a/lib/filters/filter.c b/lib/filters/filter.c
index d3fdd6e..a86b398 100644
--- a/lib/filters/filter.c
+++ b/lib/filters/filter.c
@@ -27,7 +27,7 @@
 #include <fcntl.h>
 #include <limits.h>
 
-#include "device-types.h"
+#include "device/device-types.h"
 
 #define NUMBER_OF_MAJORS 4096
 


