From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 26 Jul 2012 01:31:56 +0000 (UTC)
Subject: master - filters: Add Micron PCIe SSDs (mtip32xx) [part2]
Message-ID: <20120726013156.BA1DE7E@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e0bc3cf1a0102aff6c047a3293ef45ca5f221c10
Commit:        e0bc3cf1a0102aff6c047a3293ef45ca5f221c10
Parent:        7803756e9751117c8a2454d55c145f6e759279dd
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jul 26 02:31:06 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jul 26 02:31:06 2012 +0100

filters: Add Micron PCIe SSDs (mtip32xx) [part2]

Recognise Micron PCIe SSDs in filter and move array out to device-types.h.
---
 lib/filters/device-types.h |   55 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 55 insertions(+), 0 deletions(-)

diff --git a/lib/filters/device-types.h b/lib/filters/device-types.h
new file mode 100644
index 0000000..1208160
--- /dev/null
+++ b/lib/filters/device-types.h
@@ -0,0 +1,55 @@
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
+	{"", 0}
+};


