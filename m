From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 13:32:52 -0000
Subject: LVM2/lib error/errseg.c format1/format1.c form ...
Message-ID: <20101220133252.18090.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 13:32:50

Modified files:
	lib/error      : errseg.c 
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: format-text.c 
	lib/freeseg    : freeseg.c 
	lib/metadata   : metadata.h segtype.h 
	lib/mirror     : mirrored.c 
	lib/replicator : replicator.c 
	lib/snapshot   : snapshot.c 
	lib/striped    : striped.c 
	lib/unknown    : unknown.c 
	lib/zero       : zero.c 

Log message:
	Remove const usage from destroy callbacks
	
	As const segment_type or const format_type are never released
	use their non-const version and remove const downcast from dm_free calls.
	This change fixes many gcc warnings we were getting from them.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/error/errseg.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.125&r2=1.126
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.152&r2=1.153
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/freeseg/freeseg.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.226&r2=1.227
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/replicator/replicator.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/striped/striped.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/unknown/unknown.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/zero/zero.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/lib/error/errseg.c	2010/07/09 15:34:43	1.21
+++ LVM2/lib/error/errseg.c	2010/12/20 13:32:49	1.22
@@ -81,9 +81,9 @@
 	return 1;
 }
 
-static void _errseg_destroy(const struct segment_type *segtype)
+static void _errseg_destroy(struct segment_type *segtype)
 {
-	dm_free((void *)segtype);
+	dm_free(segtype);
 }
 
 static struct segtype_handler _error_ops = {
--- LVM2/lib/format1/format1.c	2010/10/05 17:34:06	1.125
+++ LVM2/lib/format1/format1.c	2010/12/20 13:32:49	1.126
@@ -555,9 +555,9 @@
 {
 }
 
-static void _format1_destroy(const struct format_type *fmt)
+static void _format1_destroy(struct format_type *fmt)
 {
-	dm_free((void *) fmt);
+	dm_free(fmt);
 }
 
 static struct format_handler _format1_ops = {
--- LVM2/lib/format_pool/format_pool.c	2010/12/20 13:19:14	1.34
+++ LVM2/lib/format_pool/format_pool.c	2010/12/20 13:32:49	1.35
@@ -286,9 +286,9 @@
 {
 }
 
-static void _pool_destroy(const struct format_type *fmt)
+static void _pool_destroy(struct format_type *fmt)
 {
-	dm_free((void *) fmt);
+	dm_free(fmt);
 }
 
 /* *INDENT-OFF* */
--- LVM2/lib/format_text/format-text.c	2010/12/20 13:12:56	1.152
+++ LVM2/lib/format_text/format-text.c	2010/12/20 13:32:49	1.153
@@ -1719,7 +1719,7 @@
 	}
 }
 
-static void _text_destroy(const struct format_type *fmt)
+static void _text_destroy(struct format_type *fmt)
 {
 	if (fmt->private) {
 		_free_dirs(&((struct mda_lists *) fmt->private)->dirs);
@@ -1727,7 +1727,7 @@
 		dm_free(fmt->private);
 	}
 
-	dm_free((void *)fmt);
+	dm_free(fmt);
 }
 
 static struct metadata_area_ops _metadata_text_file_ops = {
--- LVM2/lib/freeseg/freeseg.c	2008/06/25 16:52:27	1.1
+++ LVM2/lib/freeseg/freeseg.c	2010/12/20 13:32:49	1.2
@@ -31,9 +31,9 @@
 	return seg->segtype->name;
 }
 
-static void _freeseg_destroy(const struct segment_type *segtype)
+static void _freeseg_destroy(struct segment_type *segtype)
 {
-	dm_free((void *)segtype);
+	dm_free(segtype);
 }
 
 static struct segtype_handler _freeseg_ops = {
--- LVM2/lib/metadata/metadata.h	2010/12/20 13:19:14	1.226
+++ LVM2/lib/metadata/metadata.h	2010/12/20 13:32:49	1.227
@@ -291,7 +291,7 @@
 	/*
 	 * Destructor for format type
 	 */
-	void (*destroy) (const struct format_type * fmt);
+	void (*destroy) (struct format_type * fmt);
 };
 
 /*
--- LVM2/lib/metadata/segtype.h	2010/12/20 13:12:57	1.33
+++ LVM2/lib/metadata/segtype.h	2010/12/20 13:32:49	1.34
@@ -97,7 +97,7 @@
 	int (*modules_needed) (struct dm_pool *mem,
 			       const struct lv_segment *seg,
 			       struct dm_list *modules);
-	void (*destroy) (const struct segment_type * segtype);
+	void (*destroy) (struct segment_type * segtype);
 	int (*target_monitored) (struct lv_segment *seg, int *pending);
 	int (*target_monitor_events) (struct lv_segment *seg, int events);
 	int (*target_unmonitor_events) (struct lv_segment *seg, int events);
--- LVM2/lib/mirror/mirrored.c	2010/12/20 13:12:57	1.81
+++ LVM2/lib/mirror/mirrored.c	2010/12/20 13:32:49	1.82
@@ -600,9 +600,9 @@
 	return 1;
 }
 
-static void _mirrored_destroy(const struct segment_type *segtype)
+static void _mirrored_destroy(struct segment_type *segtype)
 {
-	dm_free((void *) segtype);
+	dm_free(segtype);
 }
 
 static struct segtype_handler _mirrored_ops = {
--- LVM2/lib/replicator/replicator.c	2010/12/20 13:12:57	1.4
+++ LVM2/lib/replicator/replicator.c	2010/12/20 13:32:49	1.5
@@ -406,9 +406,9 @@
 	return 1;
 }
 
-static void _replicator_destroy(const struct segment_type *segtype)
+static void _replicator_destroy(struct segment_type *segtype)
 {
-	dm_free((void *)segtype);
+	dm_free(segtype);
 }
 
 static struct segtype_handler _replicator_ops = {
--- LVM2/lib/snapshot/snapshot.c	2010/11/30 11:53:32	1.51
+++ LVM2/lib/snapshot/snapshot.c	2010/12/20 13:32:50	1.52
@@ -218,9 +218,9 @@
 	return 1;
 }
 
-static void _snap_destroy(const struct segment_type *segtype)
+static void _snap_destroy(struct segment_type *segtype)
 {
-	dm_free((void *)segtype);
+	dm_free(segtype);
 }
 
 static struct segtype_handler _snapshot_ops = {
--- LVM2/lib/striped/striped.c	2010/12/20 13:12:57	1.34
+++ LVM2/lib/striped/striped.c	2010/12/20 13:32:50	1.35
@@ -199,9 +199,9 @@
 }
 #endif
 
-static void _striped_destroy(const struct segment_type *segtype)
+static void _striped_destroy(struct segment_type *segtype)
 {
-	dm_free((void *)segtype);
+	dm_free(segtype);
 }
 
 static struct segtype_handler _striped_ops = {
--- LVM2/lib/unknown/unknown.c	2010/07/09 15:34:46	1.3
+++ LVM2/lib/unknown/unknown.c	2010/12/20 13:32:50	1.4
@@ -74,9 +74,9 @@
 }
 #endif
 
-static void _unknown_destroy(const struct segment_type *segtype)
+static void _unknown_destroy(struct segment_type *segtype)
 {
-	dm_free((void *)segtype);
+	dm_free(segtype);
 }
 
 static struct segtype_handler _unknown_ops = {
--- LVM2/lib/zero/zero.c	2010/07/09 15:34:46	1.22
+++ LVM2/lib/zero/zero.c	2010/12/20 13:32:50	1.23
@@ -78,9 +78,9 @@
 	return 1;
 }
 
-static void _zero_destroy(const struct segment_type *segtype)
+static void _zero_destroy(struct segment_type *segtype)
 {
-	dm_free((void *) segtype);
+	dm_free(segtype);
 }
 
 static struct segtype_handler _zero_ops = {


