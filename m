From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  2 Nov 2022 13:00:19 +0000 (GMT)
Subject: main - device_mapper: add parser for vdo metadata
Message-ID: <20221102130019.1CB06385AE4F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=829ab017082eaad253ebd28ad7d7ae7f3936dbcb
Commit:        829ab017082eaad253ebd28ad7d7ae7f3936dbcb
Parent:        17baeb65a913fb1793d0142b20087b10a7f88e37
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 26 14:33:09 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 2 13:59:34 2022 +0100

device_mapper: add parser for vdo metadata

Add very simplistic parser of vdo metadata to be able to obtain
logical_blocks stored within vdo metadata - as lvm2 may
submit smaller value due to internal aligment rules.

To avoid creation of mismatching table line - use this number
instead the one provided by lvm2.
---
 device_mapper/Makefile         |   3 +-
 device_mapper/libdm-deptree.c  |  15 +++
 device_mapper/vdo/target.h     |   2 +
 device_mapper/vdo/vdo_reader.c | 279 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 298 insertions(+), 1 deletion(-)

diff --git a/device_mapper/Makefile b/device_mapper/Makefile
index d3b791eb5..a322235cb 100644
--- a/device_mapper/Makefile
+++ b/device_mapper/Makefile
@@ -1,4 +1,4 @@
-# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2018 - 2022 Red Hat, Inc. All rights reserved.
 #
 # This file is part of the device-mapper userspace tools.
 #
@@ -29,6 +29,7 @@ DEVICE_MAPPER_SOURCE=\
 	device_mapper/regex/parse_rx.c \
 	device_mapper/regex/ttree.c \
 	device_mapper/vdo/status.c \
+	device_mapper/vdo/vdo_reader.c \
 	device_mapper/vdo/vdo_target.c
 
 DEVICE_MAPPER_TARGET = device_mapper/libdevice-mapper.a
diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 2d382037c..0445e1b4b 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -2857,6 +2857,7 @@ static int _vdo_emit_segment_line(struct dm_task *dmt,
 	int pos = 0;
 	char data[DM_FORMAT_DEV_BUFSIZE];
 	char data_dev[128]; // for /dev/dm-XXXX
+	uint64_t logical_blocks;
 
 	if (!_build_dev_string(data, sizeof(data), seg->vdo_data))
 		return_0;
@@ -2866,6 +2867,20 @@ static int _vdo_emit_segment_line(struct dm_task *dmt,
 		return 0;
 	}
 
+	if (dm_vdo_parse_logical_size(data_dev, &logical_blocks)) {
+		logical_blocks *= 8;
+		if (seg->size != logical_blocks) {
+			if (seg->size > logical_blocks) {
+				log_error("Virtual size of VDO volume is smaller then expected (" FMTu64  " > " FMTu64 ").",
+					  seg->size, logical_blocks);
+				return 1;
+			}
+			log_debug_activation("Increasing VDO virtual volume size from " FMTu64  " to " FMTu64 ".",
+					     seg->size, logical_blocks);
+			seg->size = logical_blocks;
+		}
+	}
+
 	if (seg->vdo_version < 4) {
 		EMIT_PARAMS(pos, "V2 %s " FMTu64 " %u " FMTu64 " %u %s %s %s ",
 			    data_dev,
diff --git a/device_mapper/vdo/target.h b/device_mapper/vdo/target.h
index 60c5bff56..bd21bb5d7 100644
--- a/device_mapper/vdo/target.h
+++ b/device_mapper/vdo/target.h
@@ -108,6 +108,8 @@ struct dm_vdo_target_params {
 bool dm_vdo_validate_target_params(const struct dm_vdo_target_params *vtp,
 				   uint64_t vdo_size);
 
+bool dm_vdo_parse_logical_size(const char *vdo_path, uint64_t *logical_blocks);
+
 //----------------------------------------------------------------
 
 #endif
diff --git a/device_mapper/vdo/vdo_reader.c b/device_mapper/vdo/vdo_reader.c
new file mode 100644
index 000000000..b765af042
--- /dev/null
+++ b/device_mapper/vdo/vdo_reader.c
@@ -0,0 +1,279 @@
+/*
+ * Copyright (C) 2022 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of the device-mapper userspace tools.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+/*
+ * Based on VDO sources: https://github.com/dm-vdo/vdo
+ *
+ * Simplified parser of VDO superblock to obtain basic VDO parameteers
+ *
+ * TODO: maybe switch to some library in the future
+ */
+
+//#define _GNU_SOURCE 1
+//#define _LARGEFILE64_SOURCE 1
+
+#include "device_mapper/misc/dmlib.h"
+
+#include "target.h"
+
+#include "lib/mm/xlate.h"
+//#include "linux/byteorder/big_endian.h"
+//#include "linux/byteorder/little_endian.h"
+//#define le32_to_cpu __le32_to_cpu
+//#define le64_to_cpu __le64_to_cpu
+
+
+#include <errno.h>
+#include <fcntl.h>
+#include <linux/fs.h>	/* For block ioctl definitions */
+#include <stdint.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/ioctl.h>
+#include <sys/stat.h>
+#include <unistd.h>
+
+typedef unsigned char uuid_t[16];
+
+#define __packed	__attribute__((packed))
+
+static const char _MAGIC_NUMBER[] = "dmvdo001";
+#define MAGIC_NUMBER_SIZE  (sizeof(_MAGIC_NUMBER) - 1)
+
+struct vdo_version_number {
+	uint32_t major_version;
+	uint32_t minor_version;
+} __packed;
+
+/*
+ * The registry of component ids for use in headers
+ */
+enum {
+	SUPER_BLOCK	  = 0,
+	FIXED_LAYOUT	  = 1,
+	RECOVERY_JOURNAL  = 2,
+	SLAB_DEPOT	  = 3,
+	BLOCK_MAP	  = 4,
+	GEOMETRY_BLOCK	  = 5,
+}; /* ComponentID */
+
+struct vdo_header {
+	uint32_t id; /* The component this is a header for */
+	struct vdo_version_number version; /* The version of the data format */
+	size_t size; /* The size of the data following this header */
+} __packed;
+
+struct vdo_geometry_block {
+	char magic_number[MAGIC_NUMBER_SIZE];
+	struct vdo_header header;
+	uint32_t checksum;
+} __packed;
+
+struct vdo_config {
+	uint64_t logical_blocks; /* number of logical blocks */
+	uint64_t physical_blocks; /* number of physical blocks */
+	uint64_t slab_size; /* number of blocks in a slab */
+	uint64_t recovery_journal_size; /* number of recovery journal blocks */
+	uint64_t slab_journal_blocks; /* number of slab journal blocks */
+} __packed;
+
+struct vdo_component_41_0 {
+	uint32_t state;
+	uint64_t complete_recoveries;
+	uint64_t read_only_recoveries;
+	struct vdo_config config; /* packed */
+	uint64_t nonce;
+} __packed;
+
+enum vdo_volume_region_id {
+	VDO_INDEX_REGION = 0,
+	VDO_DATA_REGION = 1,
+	VDO_VOLUME_REGION_COUNT,
+};
+
+struct vdo_volume_region {
+	/* The ID of the region */
+	enum vdo_volume_region_id id;
+	/*
+	 * The absolute starting offset on the device. The region continues
+	 * until the next region begins.
+	 */
+	uint64_t start_block;
+} __packed;
+
+struct vdo_index_config {
+	uint32_t mem;
+	uint32_t unused;
+	uint8_t sparse;
+} __packed;
+
+struct vdo_volume_geometry {
+	uint32_t release_version;
+	uint64_t nonce;
+	uuid_t uuid;
+	uint64_t bio_offset;
+	struct vdo_volume_region regions[VDO_VOLUME_REGION_COUNT];
+	struct vdo_index_config index_config;
+} __packed;
+
+/* Decoding mostly only some used stucture members */
+
+static void _vdo_decode_version(struct vdo_version_number *v)
+{
+	v->major_version = le32_to_cpu(v->major_version);
+	v->minor_version = le32_to_cpu(v->minor_version);
+}
+
+static void _vdo_decode_header(struct vdo_header *h)
+{
+	h->id = le32_to_cpu(h->id);
+	_vdo_decode_version(&h->version);
+	h->size = le64_to_cpu(h->size);
+}
+
+static void _vdo_decode_geometry_region(struct vdo_volume_region *vr)
+{
+	vr->id = le32_to_cpu(vr->id);
+	vr->start_block = le32_to_cpu(vr->start_block);
+}
+
+static void _vdo_decode_volume_geometry(struct vdo_volume_geometry *vg)
+{
+	vg->release_version = le64_to_cpu(vg->release_version);
+	vg->nonce = le64_to_cpu(vg->nonce);
+	_vdo_decode_geometry_region(&vg->regions[VDO_DATA_REGION]);
+}
+
+static void _vdo_decode_config(struct vdo_config *vc)
+{
+	vc->logical_blocks = le64_to_cpu(vc->logical_blocks);
+	vc->physical_blocks = le64_to_cpu(vc->physical_blocks);
+	vc->slab_size = le64_to_cpu(vc->slab_size);
+	vc->recovery_journal_size = le64_to_cpu(vc->recovery_journal_size);
+	vc->slab_journal_blocks = le64_to_cpu(vc->slab_journal_blocks);
+}
+
+static void _vdo_decode_pvc(struct vdo_component_41_0 *pvc)
+{
+	_vdo_decode_config(&pvc->config);
+	pvc->nonce = le64_to_cpu(pvc->nonce);
+}
+
+bool dm_vdo_parse_logical_size(const char *vdo_path, uint64_t *logical_blocks)
+{
+	char buffer[4096];
+	int fh, n;
+	bool r = false;
+	off_t l;
+	struct stat st;
+	uint64_t size;
+	uint64_t regpos;
+
+	struct vdo_header h;
+	struct vdo_version_number vn;
+	struct vdo_volume_geometry vg;
+	struct vdo_component_41_0 pvc;
+
+	*logical_blocks = 0;
+	if ((fh = open(vdo_path, O_RDONLY)) == -1) {
+		log_sys_error("Failed to open VDO backend %s", vdo_path);
+		goto err;
+	}
+
+	if (ioctl(fh, BLKGETSIZE64, &size) == -1) {
+		if (errno != ENOTTY) {
+			log_sys_error("ioctl", vdo_path);
+			goto err;
+		}
+
+		/* lets retry for file sizes */
+		if (fstat(fh, &st) < 0) {
+			log_sys_error("fstat", vdo_path);
+			goto err;
+		}
+
+		size = st.st_size;
+	}
+
+	if ((n = read(fh, buffer, sizeof(buffer))) < 0) {
+		log_sys_error("read", vdo_path);
+		goto err;
+	}
+
+	if (strncmp(buffer, _MAGIC_NUMBER, MAGIC_NUMBER_SIZE)) {
+		log_sys_error("mismatch header", vdo_path);
+		goto err;
+	}
+
+	memcpy(&h, buffer + MAGIC_NUMBER_SIZE, sizeof(h));
+	_vdo_decode_header(&h);
+
+	if  (h.version.major_version != 5) {
+		log_error("Unsupported VDO version %u.%u.", h.version.major_version, h.version.minor_version);
+		goto err;
+	}
+
+	memcpy(&vg, buffer + MAGIC_NUMBER_SIZE + sizeof(h), sizeof(vg));
+	_vdo_decode_volume_geometry(&vg);
+
+	regpos = vg.regions[VDO_DATA_REGION].start_block * 4096;
+
+	if ((regpos + sizeof(buffer)) > size) {
+		log_error("File/Device is shorter and can't provide requested VDO volume region at " FMTu64 " > " FMTu64 ".", regpos, size);
+		goto err;
+	}
+
+	if ((l = lseek(fh, regpos, SEEK_SET)) < 0) {
+		log_sys_error("lseek", vdo_path);
+		goto err;
+	}
+
+	if ((n = read(fh, buffer, sizeof(buffer))) < 0) {
+		log_sys_error("read error", vdo_path);
+		goto err;
+	}
+
+
+	memcpy(&vn, buffer + sizeof(struct vdo_geometry_block), sizeof(vn));
+	_vdo_decode_version(&vn);
+
+	if (vn.major_version > 41) {
+		log_error("Unknown VDO component version %u.", vn.major_version); // should be 41!
+		goto err;
+	}
+
+	memcpy(&pvc, buffer + sizeof(struct vdo_geometry_block) + sizeof(vn), sizeof(pvc));
+	_vdo_decode_pvc(&pvc);
+
+	if (pvc.nonce != vg.nonce) {
+		log_error("Mismatching VDO nonce " FMTu64 " != " FMTu64 ".", pvc.nonce, vg.nonce);
+		goto err;
+	}
+
+#if 0
+	log_debug("LogBlocks    " FMTu64 ".", pvc.config.logical_blocks);
+	log_debug("PhyBlocks    " FMTu64 ".", pvc.config.physical_blocks);
+	log_debug("SlabSize     " FMTu64 ".", pvc.config.slab_size);
+	log_debug("RecJourSize  " FMTu64 ".", pvc.config.recovery_journal_size);
+	log_debug("SlabJouSize  " FMTu64 ".", pvc.config.slab_journal_blocks);
+#endif
+
+	*logical_blocks = pvc.config.logical_blocks;
+	r = true;
+err:
+	(void) close(fh);
+
+	return r;
+}

