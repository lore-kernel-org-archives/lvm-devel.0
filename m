From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 23 Sep 2009 09:50:03 -0500
Subject: [PATCH 1 of 1] lvm2 fix emit_segment_line functions
Message-ID: <200909231450.n8NEo3NF025811@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm2-fix-emit_segment_line-functions.patch

It turns out that the EMIT_PARAMS macro can force your function
to return -1 if there is no space to fit the string.  This means
that _emit_areas_line returns 0, 1, -1 (which is even more
confusing).  So, I need to correct the comments I made earlier
and have mirror_emit_segment_line return similar values.  I've
also changed the function name 'mirror_emit_segment_line' to have
a leading '_', which is convention for static functions in LVM.

Index: LVM2/libdm/libdm-deptree.c
===================================================================
--- LVM2.orig/libdm/libdm-deptree.c
+++ LVM2/libdm/libdm-deptree.c
@@ -1261,7 +1261,7 @@ do {\
 /*
  * _emit_areas_line
  *
- * Returns: 1 on success, 0 on failure
+ * Returns: 1 on success, 0 on failure, -1 if out of space
  */
 static int _emit_areas_line(struct dm_task *dmt __attribute((unused)),
 			    struct load_segment *seg, char *params,
@@ -1287,12 +1287,12 @@ static int _emit_areas_line(struct dm_ta
 /*
  * mirror_emit_segment_line
  *
- * Returns: 1 on success, 0 on failure
+ * Returns: 1 on success, 0 on failure, -1 if out of space
  */
-static int mirror_emit_segment_line(struct dm_task *dmt, uint32_t major,
-				    uint32_t minor, struct load_segment *seg,
-				    uint64_t *seg_start, char *params,
-				    size_t paramsize)
+static int _mirror_emit_segment_line(struct dm_task *dmt, uint32_t major,
+				     uint32_t minor, struct load_segment *seg,
+				     uint64_t *seg_start, char *params,
+				     size_t paramsize)
 {
 	int r;
 	int block_on_error = 0;
@@ -1396,8 +1396,10 @@ static int mirror_emit_segment_line(stru
 
 	EMIT_PARAMS(pos, " %u ", seg->mirror_area_count);
 
-	if ((r = _emit_areas_line(dmt, seg, params, paramsize, &pos)) <= 0)
-		return_0;
+	if ((r = _emit_areas_line(dmt, seg, params, paramsize, &pos)) <= 0) {
+		stack;
+		return r;
+	}
 
 	if (handle_errors)
 		EMIT_PARAMS(pos, " 1 handle_errors");
@@ -1421,10 +1423,10 @@ static int _emit_segment_line(struct dm_
 		break;
 	case SEG_MIRRORED:
 		/* Mirrors are pretty complicated - now in separate function */
-		r = mirror_emit_segment_line(dmt, major, minor, seg, seg_start,
-					     params, paramsize);
-		if (!r)
-			return_0;
+		r = _mirror_emit_segment_line(dmt, major, minor, seg, seg_start,
+					      params, paramsize);
+		if (r <= 0)
+			return r;
 		break;
 	case SEG_SNAPSHOT:
 		if (!_build_dev_string(originbuf, sizeof(originbuf), seg->origin))


