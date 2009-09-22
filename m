From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 22 Sep 2009 16:26:59 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20090922162659.5217.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2009-09-22 16:26:59

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	'_emit_areas_line' returns 1 for success and 0 for failure.  This always
	confuses me, so I've added a comment at the top of the function to
	remind me of this.
	
	I also found that 'mirror_emit_segment_line' was returning 0 (return_0)
	on failure /and/ success.  It now returns 1 for success and 0 for failure -
	just like '_emit_areas_line' and its calling function, '_emit_segment_line'.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/libdm/libdm-deptree.c	2009/08/13 16:31:01	1.56
+++ LVM2/libdm/libdm-deptree.c	2009/09/22 16:26:59	1.57
@@ -1258,6 +1258,11 @@
 	p += w;\
 } while (0)
 
+/*
+ * _emit_areas_line
+ *
+ * Returns: 1 on success, 0 on failure
+ */
 static int _emit_areas_line(struct dm_task *dmt __attribute((unused)),
 			    struct load_segment *seg, char *params,
 			    size_t paramsize, int *pos)
@@ -1279,6 +1284,11 @@
 	return 1;
 }
 
+/*
+ * mirror_emit_segment_line
+ *
+ * Returns: 1 on success, 0 on failure
+ */
 static int mirror_emit_segment_line(struct dm_task *dmt, uint32_t major,
 				    uint32_t minor, struct load_segment *seg,
 				    uint64_t *seg_start, char *params,
@@ -1386,15 +1396,13 @@
 
 	EMIT_PARAMS(pos, " %u ", seg->mirror_area_count);
 
-	if ((r = _emit_areas_line(dmt, seg, params, paramsize, &pos)) <= 0) {
-		stack;
-		return r;
-	}
+	if ((r = _emit_areas_line(dmt, seg, params, paramsize, &pos)) <= 0)
+		return_0;
 
 	if (handle_errors)
 		EMIT_PARAMS(pos, " 1 handle_errors");
 
-	return 0;
+	return 1;
 }
 
 static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
@@ -1415,8 +1423,8 @@
 		/* Mirrors are pretty complicated - now in separate function */
 		r = mirror_emit_segment_line(dmt, major, minor, seg, seg_start,
 					     params, paramsize);
-		if (r)
-			return r;
+		if (!r)
+			return_0;
 		break;
 	case SEG_SNAPSHOT:
 		if (!_build_dev_string(originbuf, sizeof(originbuf), seg->origin))


