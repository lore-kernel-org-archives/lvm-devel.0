From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 26 Jul 2012 01:27:23 +0000 (UTC)
Subject: master - filters: Add Micron PCIe SSDs (mtip32xx)
Message-ID: <20120726012723.2F0777E@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7803756e9751117c8a2454d55c145f6e759279dd
Commit:        7803756e9751117c8a2454d55c145f6e759279dd
Parent:        599f18db8aadcc0f4818471ec5b47298a5a8ef54
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jul 26 02:26:40 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jul 26 02:26:40 2012 +0100

filters: Add Micron PCIe SSDs (mtip32xx)

Recognise Micron PCIe SSDs in filter and move array out to device-types.h.
---
 WHATS_NEW            |    1 +
 lib/filters/filter.c |   42 ++----------------------------------------
 2 files changed, 3 insertions(+), 40 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bca890e..735bdba 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Recognise Micron PCIe SSDs in filter and move array out to device-types.h.
   Fix segfault when attempting to replace RAID 4/5/6 device (2.02.97).
   Fix dumpconfig <node> to print only <node> without its siblings (2.02.89).
   Do not issue "Failed to handle a client connection" error if lvmetad killed.
diff --git a/lib/filters/filter.c b/lib/filters/filter.c
index 11b94c1..bab20ec 100644
--- a/lib/filters/filter.c
+++ b/lib/filters/filter.c
@@ -40,6 +40,8 @@ typedef struct {
 	const int8_t max_partitions;
 } device_info_t;
 
+#include "device-types.h"
+
 static int _md_major = -1;
 static int _blkext_major = -1;
 static int _drbd_major = -1;
@@ -99,46 +101,6 @@ const char *dev_subsystem_name(const struct device *dev)
 	return "";
 }
 
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
-	{"", 0}
-};
-
 static int _passes_lvm_type_device_filter(struct dev_filter *f __attribute__((unused)),
 					  struct device *dev)
 {


