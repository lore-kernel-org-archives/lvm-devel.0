From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Feb 2021 14:43:59 +0000 (GMT)
Subject: main - libdm: simplify line emitter checking
Message-ID: <20210210144359.52404385DC33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=82bffa99ada0173704739b6fff856a3d6cb5455d
Commit:        82bffa99ada0173704739b6fff856a3d6cb5455d
Parent:        4b371246f52d2b3296ec27467a15a35a18b40542
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 10 15:10:28 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 10 15:39:03 2021 +0100

libdm: simplify line emitter checking

---
 libdm/libdm-deptree.c | 20 ++++++++------------
 libdm/libdm-report.c  |  2 +-
 2 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 336cbb696..bf027ee81 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2231,7 +2231,7 @@ static int _mirror_emit_segment_line(struct dm_task *dmt, struct load_segment *s
 
 	EMIT_PARAMS(pos, " %u ", seg->mirror_area_count);
 
-	if (_emit_areas_line(dmt, seg, params, paramsize, &pos) <= 0)
+	if (!_emit_areas_line(dmt, seg, params, paramsize, &pos))
 		return_0;
 
 	if (handle_errors)
@@ -2433,7 +2433,7 @@ static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 	/* Print number of metadata/data device pairs */
 	EMIT_PARAMS(pos, " %u", area_count);
 
-	if (_emit_areas_line(dmt, seg, params, paramsize, &pos) <= 0)
+	if (!_emit_areas_line(dmt, seg, params, paramsize, &pos))
 		return_0;
 
 	return 1;
@@ -2561,7 +2561,6 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 			      size_t paramsize)
 {
 	int pos = 0;
-	int r;
 	int target_type_is_raid = 0;
 	char originbuf[DM_FORMAT_DEV_BUFSIZE], cowbuf[DM_FORMAT_DEV_BUFSIZE];
 
@@ -2572,8 +2571,7 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 		break;
 	case SEG_MIRRORED:
 		/* Mirrors are pretty complicated - now in separate function */
-		r = _mirror_emit_segment_line(dmt, seg, params, paramsize);
-		if (!r)
+		if (!_mirror_emit_segment_line(dmt, seg, params, paramsize))
 			return_0;
 		break;
 	case SEG_SNAPSHOT:
@@ -2619,9 +2617,8 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
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
@@ -2652,10 +2649,9 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
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
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index b0c89ab61..a1c07badd 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -491,7 +491,7 @@ static int _report_field_string_list(struct dm_report *rh,
 		delimiter = ",";
 	delimiter_len = strlen(delimiter);
 
-	i = pos = len = 0;
+	i = pos = 0;
 	dm_list_iterate_items(sl, data) {
 		arr[i].str = sl->str;
 		if (!sort) {


