From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Feb 2021 14:43:58 +0000 (GMT)
Subject: main - device_mapper: simplify line emitter checking
Message-ID: <20210210144358.309013857C7B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4b371246f52d2b3296ec27467a15a35a18b40542
Commit:        4b371246f52d2b3296ec27467a15a35a18b40542
Parent:        a3835861774f4758e0de2a4b462eb51b91a3f09b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 10 15:22:39 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 10 15:39:03 2021 +0100

device_mapper: simplify line emitter checking

---
 device_mapper/libdm-deptree.c | 22 +++++++++-------------
 device_mapper/libdm-report.c  |  2 +-
 2 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 5b60dc91a..ec345ac55 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -2382,7 +2382,7 @@ static int _mirror_emit_segment_line(struct dm_task *dmt, struct load_segment *s
 
 	EMIT_PARAMS(pos, " %u ", seg->mirror_area_count);
 
-	if (_emit_areas_line(dmt, seg, params, paramsize, &pos) <= 0)
+	if (!_emit_areas_line(dmt, seg, params, paramsize, &pos))
 		return_0;
 
 	if (handle_errors)
@@ -2584,7 +2584,7 @@ static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 	/* Print number of metadata/data device pairs */
 	EMIT_PARAMS(pos, " %u", area_count);
 
-	if (_emit_areas_line(dmt, seg, params, paramsize, &pos) <= 0)
+	if (!_emit_areas_line(dmt, seg, params, paramsize, &pos))
 		return_0;
 
 	return 1;
@@ -2927,7 +2927,6 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 			      size_t paramsize)
 {
 	int pos = 0;
-	int r;
 	int target_type_is_raid = 0;
 	char originbuf[DM_FORMAT_DEV_BUFSIZE], cowbuf[DM_FORMAT_DEV_BUFSIZE];
 
@@ -2938,8 +2937,7 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 		break;
 	case SEG_MIRRORED:
 		/* Mirrors are pretty complicated - now in separate function */
-		r = _mirror_emit_segment_line(dmt, seg, params, paramsize);
-		if (!r)
+		if (!_mirror_emit_segment_line(dmt, seg, params, paramsize))
 			return_0;
 		break;
 	case SEG_SNAPSHOT:
@@ -2960,7 +2958,7 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 		EMIT_PARAMS(pos, "%u %u ", seg->area_count, seg->stripe_size);
 		break;
 	case SEG_VDO:
-		if (!(r = _vdo_emit_segment_line(dmt, seg, params, paramsize)))
+		if (!_vdo_emit_segment_line(dmt, seg, params, paramsize))
 		      return_0;
 		break;
 	case SEG_CRYPT:
@@ -2989,9 +2987,8 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 	case SEG_RAID6_LA_6:
 	case SEG_RAID6_RA_6:
 		target_type_is_raid = 1;
-		r = _raid_emit_segment_line(dmt, major, minor, seg, seg_start,
-					    params, paramsize);
-		if (!r)
+		if (!_raid_emit_segment_line(dmt, major, minor, seg, seg_start,
+					     params, paramsize))
 			return_0;
 
 		break;
@@ -3032,10 +3029,9 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 	case SEG_CRYPT:
 	case SEG_LINEAR:
 	case SEG_STRIPED:
-		if ((r = _emit_areas_line(dmt, seg, params, paramsize, &pos)) <= 0) {
-			stack;
-			return r;
-		}
+		if (!_emit_areas_line(dmt, seg, params, paramsize, &pos))
+			return_0;
+
 		if (!params[0]) {
 			log_error("No parameters supplied for %s target "
 				  "%u:%u.", _dm_segtypes[seg->type].target,
diff --git a/device_mapper/libdm-report.c b/device_mapper/libdm-report.c
index 9279e3370..1928354d3 100644
--- a/device_mapper/libdm-report.c
+++ b/device_mapper/libdm-report.c
@@ -492,7 +492,7 @@ static int _report_field_string_list(struct dm_report *rh,
 		delimiter = ",";
 	delimiter_len = strlen(delimiter);
 
-	i = pos = len = 0;
+	i = pos = 0;
 	dm_list_iterate_items(sl, data) {
 		arr[i].str = sl->str;
 		if (!sort) {


