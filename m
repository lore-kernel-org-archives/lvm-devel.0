From: mpatocka@sourceware.org <mpatocka@sourceware.org>
Date: Tue, 21 Jul 2009 20:00:28 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c
Message-ID: <20090721200005.10457.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mpatocka at sourceware.org	2009-07-21 20:00:04

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c 

Log message:
	Pass struct cmd_context as a first argument to init_multiple_segtypes.
	
	Remove redundant assignment seglib.cmd = cmd (done already at the beginning
	of the function).
	
	Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1194&r2=1.1195
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83

--- LVM2/WHATS_NEW	2009/07/21 11:10:49	1.1194
+++ LVM2/WHATS_NEW	2009/07/21 20:00:02	1.1195
@@ -1,5 +1,6 @@
 Version 2.02.50 - 
 ================================
+  Pass a pointer to struct cmd_context to init_multiple_segtypes
   Return EINVALID_CMD_LINE not success when invalid VG name format is used.
   Remove unnecessary messages after vgcreate/vgsplit refactor (2.02.49).
   Add log_errno to set a specific errno and replace log_error in due course.
--- LVM2/lib/commands/toolcontext.c	2009/07/16 00:36:59	1.82
+++ LVM2/lib/commands/toolcontext.c	2009/07/21 20:00:04	1.83
@@ -835,7 +835,8 @@
 	return 1;
 }
 
-static int _init_single_segtype(struct segtype_library *seglib)
+static int _init_single_segtype(struct cmd_context *cmd,
+				struct segtype_library *seglib)
 {
 	struct segment_type *(*init_segtype_fn) (struct cmd_context *);
 	struct segment_type *segtype;
@@ -901,9 +902,8 @@
 	    (cn = find_config_tree_node(cmd, "global/segment_libraries"))) {
 
 		struct config_value *cv;
-		int (*init_multiple_segtypes_fn) (struct segtype_library *);
-
-		seglib.cmd = cmd;
+		int (*init_multiple_segtypes_fn) (struct cmd_context *,
+						  struct segtype_library *);
 
 		for (cv = cn->v; cv; cv = cv->next) {
 			if (cv->type != CFG_STRING) {
@@ -928,7 +928,7 @@
 				init_multiple_segtypes_fn =
 				    _init_single_segtype;
  
-			if (!init_multiple_segtypes_fn(&seglib)) {
+			if (!init_multiple_segtypes_fn(cmd, &seglib)) {
 				struct dm_list *sgtl, *tmp;
 				log_error("init_multiple_segtypes() failed: "
 					  "Unloading shared library %s",


