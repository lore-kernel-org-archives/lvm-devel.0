From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  8 Nov 2022 10:10:39 +0000 (GMT)
Subject: main - vdo: enhance detection of virtual size
Message-ID: <20221108101039.0615D385840A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8e9410594b3113386a667df400b2c229c745cb6a
Commit:        8e9410594b3113386a667df400b2c229c745cb6a
Parent:        218c7d44b5ac64b6c38dfd40885a22008b5cec81
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 5 23:10:36 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 8 11:10:21 2022 +0100

vdo: enhance detection of virtual size

Improve detection of VDO virtual size - so it's not reading VDO
metadata when VDO device is already active and instead we reuse
existing table line for knowing existing metadata size.

NOTE: if there is ever going to be added support for reduction
of VDO virtual size - this method will need to be reworked to
allow size difference only within 'extent_size' alignment.
---
 device_mapper/libdm-deptree.c | 44 ++++++++++++++++++++++++++++++-------------
 1 file changed, 31 insertions(+), 13 deletions(-)

diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 02a56c8e3..39af7b1d4 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -2850,7 +2850,7 @@ static int _thin_pool_emit_segment_line(struct dm_task *dmt,
 	return 1;
 }
 
-static int _vdo_emit_segment_line(struct dm_task *dmt,
+static int _vdo_emit_segment_line(struct dm_task *dmt, uint32_t major, uint32_t minor,
 				  struct load_segment *seg,
 				  char *params, size_t paramsize)
 {
@@ -2858,6 +2858,10 @@ static int _vdo_emit_segment_line(struct dm_task *dmt,
 	char data[DM_FORMAT_DEV_BUFSIZE];
 	char data_dev[128]; // for /dev/dm-XXXX
 	uint64_t logical_blocks;
+	struct dm_task *vdo_dmt;
+	uint64_t start, length = 0;
+	char *type = NULL;
+	char *vdo_params = NULL;
 
 	if (!_build_dev_string(data, sizeof(data), seg->vdo_data))
 		return_0;
@@ -2867,18 +2871,32 @@ static int _vdo_emit_segment_line(struct dm_task *dmt,
 		return 0;
 	}
 
-	if (dm_vdo_parse_logical_size(data_dev, &logical_blocks)) {
-		logical_blocks *= 8;
-		if (seg->size != logical_blocks) {
-			if (seg->size > logical_blocks) {
-				log_error("Virtual size of VDO volume is smaller then expected (" FMTu64  " > " FMTu64 ").",
-					  seg->size, logical_blocks);
-				return 1;
-			}
-			log_debug_activation("Increasing VDO virtual volume size from " FMTu64  " to " FMTu64 ".",
-					     seg->size, logical_blocks);
-			seg->size = logical_blocks;
+	/*
+	 * If there is already running VDO target, read 'existing' virtual size out of table line
+	 * and avoid reading it them from VDO metadata device
+	 *
+	 * NOTE: ATM VDO virtual size can be ONLY extended thus it's simple to recongnize 'right' size.
+	 * However if there would be supported also reduction, this check would need to check range.
+	 */
+	if ((vdo_dmt = dm_task_create(DM_DEVICE_TABLE))) {
+		if (dm_task_set_major(vdo_dmt, major) &&
+		    dm_task_set_minor(vdo_dmt, minor) &&
+		    dm_task_run(vdo_dmt)) {
+			(void) dm_get_next_target(vdo_dmt, NULL, &start, &length, &type, &vdo_params);
+			if (!type || strcmp(type, "vdo"))
+				length = 0;
 		}
+
+		dm_task_destroy(vdo_dmt);
+	}
+
+	if (!length && dm_vdo_parse_logical_size(data_dev, &logical_blocks))
+		length = logical_blocks * 8;
+
+	if (seg->size < length) {
+		log_debug_activation("Correcting VDO virtual volume size from " FMTu64  " to " FMTu64 ".",
+				     seg->size, length);
+		seg->size = length;
 	}
 
 	if (seg->vdo_version < 4) {
@@ -2980,7 +2998,7 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 		EMIT_PARAMS(pos, "%u %u ", seg->area_count, seg->stripe_size);
 		break;
 	case SEG_VDO:
-		if (!_vdo_emit_segment_line(dmt, seg, params, paramsize))
+		if (!_vdo_emit_segment_line(dmt, major, minor, seg, params, paramsize))
 		      return_0;
 		break;
 	case SEG_CRYPT:

