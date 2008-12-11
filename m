From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Dec 2008 16:25:52 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-deptree.c
Message-ID: <20081211162552.29826.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-12-11 16:25:51

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-deptree.c 

Log message:
	Replace _dm_snprintf with EMIT_PARAMS macro for creating target lines

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.257&r2=1.258
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/WHATS_NEW_DM	2008/11/19 14:14:52	1.257
+++ LVM2/WHATS_NEW_DM	2008/12/11 16:25:51	1.258
@@ -1,5 +1,6 @@
 Version 1.02.30 -
 ====================================
+  Replace _dm_snprintf with EMIT_PARAMS macro for creating target lines
 
 Version 1.02.29 - 10th November 2008
 ====================================
--- LVM2/libdm/libdm-deptree.c	2008/11/04 15:07:45	1.47
+++ LVM2/libdm/libdm-deptree.c	2008/12/11 16:25:51	1.48
@@ -135,22 +135,6 @@
 	int no_flush;		/* 1 sets noflush (mirrors/multipath) */
 };
 
-/* FIXME Consider exporting this */
-static int _dm_snprintf(char *buf, size_t bufsize, const char *format, ...)
-{
-        int n;
-        va_list ap;
-
-        va_start(ap, format);
-        n = vsnprintf(buf, bufsize, format, ap);
-        va_end(ap);
-
-        if (n < 0 || (n > (int) bufsize - 1))
-                return -1;
-
-        return n;
-}
-
 struct dm_tree *dm_tree_create(void)
 {
 	struct dm_tree *dtree;
@@ -1238,27 +1222,32 @@
 	return 1;
 }
 
+/* simplify string emiting code */
+#define EMIT_PARAMS(p, str...)\
+	do {\
+		const size_t bufsize = paramsize - (size_t)p;\
+		int w;\
+		\
+		if ((w = snprintf(params + p, bufsize, str)) < 0\
+		    || ((size_t)w >= bufsize)) {\
+			stack; /* Out of space */\
+			return -1;\
+		}\
+		p += w;\
+	} while (0)
+
 static int _emit_areas_line(struct dm_task *dmt __attribute((unused)),
 			    struct load_segment *seg, char *params,
 			    size_t paramsize, int *pos)
 {
 	struct seg_area *area;
 	char devbuf[DM_FORMAT_DEV_BUFSIZE];
-	int tw;
-	const char *prefix = "";
 
 	dm_list_iterate_items(area, &seg->areas) {
 		if (!_build_dev_string(devbuf, sizeof(devbuf), area->dev_node))
 			return_0;
 
-		if ((tw = _dm_snprintf(params + *pos, paramsize - *pos, "%s%s %" PRIu64,
-					prefix, devbuf, area->offset)) < 0) {
-                        stack;	/* Out of space */
-                        return -1;
-                }
-
-		prefix = " ";
-		*pos += tw;
+		EMIT_PARAMS(*pos, " %s %" PRIu64, devbuf, area->offset);
 	}
 
 	return 1;
@@ -1267,9 +1256,8 @@
 static int _emit_segment_line(struct dm_task *dmt, struct load_segment *seg, uint64_t *seg_start, char *params, size_t paramsize)
 {
 	unsigned log_parm_count;
-        int pos = 0;
-	int tw;
-        int r;
+	int pos = 0;
+	int r;
 	char originbuf[DM_FORMAT_DEV_BUFSIZE], cowbuf[DM_FORMAT_DEV_BUFSIZE];
 	char logbuf[DM_FORMAT_DEV_BUFSIZE];
 	const char *logtype;
@@ -1289,11 +1277,7 @@
 		if (seg->clustered) {
 			if (seg->uuid)
 				log_parm_count++;
-			if ((tw = _dm_snprintf(params + pos, paramsize - pos, "clustered-")) < 0) {
-                        	stack;	/* Out of space */
-                        	return -1;
-                	}
-			pos += tw;
+			EMIT_PARAMS(pos, "clustered-");
 		}
 
 		if (!seg->log)
@@ -1305,61 +1289,25 @@
 				return_0;
 		}
 
-		if ((tw = _dm_snprintf(params + pos, paramsize - pos, "%s %u ", logtype, log_parm_count)) < 0) {
-                        stack;	/* Out of space */
-                        return -1;
-                }
-		pos += tw;
-
-		if (seg->log) {
-			if ((tw = _dm_snprintf(params + pos, paramsize - pos, "%s ", logbuf)) < 0) {
-                        	stack;	/* Out of space */
-                        	return -1;
-                	}
-			pos += tw;
-		}
-
-		if ((tw = _dm_snprintf(params + pos, paramsize - pos, "%u ", seg->region_size)) < 0) {
-                       	stack; /* Out of space */
-                       	return -1;
-               	}
-		pos += tw;
-
-		if (seg->clustered && seg->uuid) {
-			if ((tw = _dm_snprintf(params + pos, paramsize - pos, "%s ", seg->uuid)) < 0) {
-				stack;  /* Out of space */
-				return -1;
-			}
-			pos += tw;
-		}
+		EMIT_PARAMS(pos, "%s %u", logtype, log_parm_count);
+
+		if (seg->log)
+			EMIT_PARAMS(pos, " %s", logbuf);
+
+		EMIT_PARAMS(pos, " %u", seg->region_size);
 
-		if ((seg->flags & DM_NOSYNC)) {
-			if ((tw = _dm_snprintf(params + pos, paramsize - pos, "nosync ")) < 0) {
-                       		stack; /* Out of space */
-                       		return -1;
-               		}
-			pos += tw;
-		} else if ((seg->flags & DM_FORCESYNC)) {
-			if ((tw = _dm_snprintf(params + pos, paramsize - pos, "sync ")) < 0) {
-                       		stack; /* Out of space */
-                       		return -1;
-               		}
-			pos += tw;
-		}
-
-		if ((seg->flags & DM_BLOCK_ON_ERROR)) {
-			if ((tw = _dm_snprintf(params + pos, paramsize - pos, "block_on_error ")) < 0) {
-                       		stack; /* Out of space */
-                       		return -1;
-               		}
-			pos += tw;
-		}
-
-		if ((tw = _dm_snprintf(params + pos, paramsize - pos, "%u ", seg->mirror_area_count)) < 0) {
-                       	stack; /* Out of space */
-                       	return -1;
-               	}
-		pos += tw;
+		if (seg->clustered && seg->uuid)
+			EMIT_PARAMS(pos, " %s", seg->uuid);
+
+		if ((seg->flags & DM_NOSYNC))
+			EMIT_PARAMS(pos, " nosync");
+		else if ((seg->flags & DM_FORCESYNC))
+			EMIT_PARAMS(pos, " sync");
+
+		if ((seg->flags & DM_BLOCK_ON_ERROR))
+			EMIT_PARAMS(pos, " block_on_error");
+
+		EMIT_PARAMS(pos, " %u", seg->mirror_area_count);
 
 		break;
 	case SEG_SNAPSHOT:
@@ -1367,30 +1315,16 @@
 			return_0;
 		if (!_build_dev_string(cowbuf, sizeof(cowbuf), seg->cow))
 			return_0;
-		if ((pos = _dm_snprintf(params, paramsize, "%s %s %c %d",
-                                        originbuf, cowbuf,
-					seg->persistent ? 'P' : 'N',
-                                        seg->chunk_size)) < 0) {
-                        stack;	/* Out of space */
-                        return -1;
-                }
+		EMIT_PARAMS(pos, "%s %s %c %d", originbuf, cowbuf,
+			    seg->persistent ? 'P' : 'N', seg->chunk_size);
 		break;
 	case SEG_SNAPSHOT_ORIGIN:
 		if (!_build_dev_string(originbuf, sizeof(originbuf), seg->origin))
 			return_0;
-		if ((pos = _dm_snprintf(params, paramsize, "%s",
-                                        originbuf)) < 0) {
-                        stack;	/* Out of space */
-                        return -1;
-                }
+		EMIT_PARAMS(pos, "%s", originbuf);
 		break;
 	case SEG_STRIPED:
-		if ((pos = _dm_snprintf(params, paramsize, "%u %u ",
-                                         seg->area_count,
-                                         seg->stripe_size)) < 0) {
-                        stack;	/* Out of space */
-                        return -1;
-                }
+		EMIT_PARAMS(pos, "%u %u", seg->area_count, seg->stripe_size);
 		break;
 	}
 
@@ -1421,6 +1355,8 @@
 	return 1;
 }
 
+#undef EMIT_PARAMS
+
 static int _emit_segment(struct dm_task *dmt, struct load_segment *seg,
 			 uint64_t *seg_start)
 {


