From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 25 Mar 2011 21:59:45 -0000
Subject: LVM2/lib error/errseg.c freeseg/freeseg.c mirr ...
Message-ID: <20110325215945.10190.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-03-25 21:59:43

Modified files:
	lib/error      : errseg.c 
	lib/freeseg    : freeseg.c 
	lib/mirror     : mirrored.c 
	lib/replicator : replicator.c 
	lib/snapshot   : snapshot.c 
	lib/striped    : striped.c 
	lib/unknown    : unknown.c 
	lib/zero       : zero.c 

Log message:
	Replace malloc with zalloc when creating segment_type's

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/error/errseg.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/freeseg/freeseg.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/replicator/replicator.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/striped/striped.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/unknown/unknown.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/zero/zero.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/lib/error/errseg.c	2010/12/20 13:32:49	1.22
+++ LVM2/lib/error/errseg.c	2011/03/25 21:59:42	1.23
@@ -99,7 +99,7 @@
 
 struct segment_type *init_error_segtype(struct cmd_context *cmd)
 {
-	struct segment_type *segtype = dm_malloc(sizeof(*segtype));
+	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
 
 	if (!segtype)
 		return_NULL;
--- LVM2/lib/freeseg/freeseg.c	2010/12/20 13:32:49	1.2
+++ LVM2/lib/freeseg/freeseg.c	2011/03/25 21:59:42	1.3
@@ -43,7 +43,7 @@
 
 struct segment_type *init_free_segtype(struct cmd_context *cmd)
 {
-	struct segment_type *segtype = dm_malloc(sizeof(*segtype));
+	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
 
 	if (!segtype)
 		return_NULL;
--- LVM2/lib/mirror/mirrored.c	2011/02/18 14:29:40	1.84
+++ LVM2/lib/mirror/mirrored.c	2011/03/25 21:59:42	1.85
@@ -630,7 +630,7 @@
 struct segment_type *init_segtype(struct cmd_context *cmd)
 #endif
 {
-	struct segment_type *segtype = dm_malloc(sizeof(*segtype));
+	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
 
 	if (!segtype)
 		return_NULL;
--- LVM2/lib/replicator/replicator.c	2010/12/20 13:32:49	1.5
+++ LVM2/lib/replicator/replicator.c	2011/03/25 21:59:42	1.6
@@ -760,7 +760,7 @@
 {
 	struct segment_type *segtype;
 
-	if (!(segtype = dm_malloc(sizeof(*segtype))))
+	if (!(segtype = dm_zalloc(sizeof(*segtype))))
 		return_0;
 
 	segtype->ops = &_replicator_ops;
@@ -773,7 +773,7 @@
 
 	log_very_verbose("Initialised segtype: " REPLICATOR_MODULE);
 
-	if (!(segtype = dm_malloc(sizeof(*segtype))))
+	if (!(segtype = dm_zalloc(sizeof(*segtype))))
 		return_0;
 
 	segtype->ops = &_replicator_dev_ops;
--- LVM2/lib/snapshot/snapshot.c	2011/02/18 14:29:41	1.53
+++ LVM2/lib/snapshot/snapshot.c	2011/03/25 21:59:42	1.54
@@ -249,7 +249,7 @@
 struct segment_type *init_segtype(struct cmd_context *cmd)
 #endif
 {
-	struct segment_type *segtype = dm_malloc(sizeof(*segtype));
+	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
 
 	if (!segtype)
 		return_NULL;
--- LVM2/lib/striped/striped.c	2010/12/20 13:32:50	1.35
+++ LVM2/lib/striped/striped.c	2011/03/25 21:59:43	1.36
@@ -220,7 +220,7 @@
 
 struct segment_type *init_striped_segtype(struct cmd_context *cmd)
 {
-	struct segment_type *segtype = dm_malloc(sizeof(*segtype));
+	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
 
 	if (!segtype)
 		return_NULL;
--- LVM2/lib/unknown/unknown.c	2010/12/20 13:32:50	1.4
+++ LVM2/lib/unknown/unknown.c	2011/03/25 21:59:43	1.5
@@ -91,7 +91,7 @@
 
 struct segment_type *init_unknown_segtype(struct cmd_context *cmd, const char *name)
 {
-	struct segment_type *segtype = dm_malloc(sizeof(*segtype));
+	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
 
 	if (!segtype)
 		return_NULL;
--- LVM2/lib/zero/zero.c	2010/12/20 13:32:50	1.23
+++ LVM2/lib/zero/zero.c	2011/03/25 21:59:43	1.24
@@ -96,7 +96,7 @@
 
 struct segment_type *init_zero_segtype(struct cmd_context *cmd)
 {
-	struct segment_type *segtype = dm_malloc(sizeof(*segtype));
+	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
 
 	if (!segtype)
 		return_NULL;


