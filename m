From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Aug 2011 13:41:48 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/segtype.h lib/ra ...
Message-ID: <20110824134148.24271.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-24 13:41:47

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : segtype.h 
	lib/raid       : .exported_symbols raid.c 
	lib/commands   : toolcontext.c 
	lib/replicator : replicator.c 

Log message:
	Fix raid shared lib segtype registration (2.02.87).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2083&r2=1.2084
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/raid/.exported_symbols.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/raid/raid.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/replicator/replicator.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/WHATS_NEW	2011/08/19 23:01:20	1.2083
+++ LVM2/WHATS_NEW	2011/08/24 13:41:46	1.2084
@@ -1,9 +1,11 @@
 Version 2.02.89 - 
 ==================================
+  Add configure --with-thin for (unimplemented) segtypes "thin" and "thin_pool".
+  Fix raid shared lib segtype registration (2.02.87).
 
 Version 2.02.88 - 19th August 2011
 ==================================
-  Remove incorrect 'Breaking' error message from allocation code (2.02.87).
+  Remove incorrect 'Breaking' error message from allocation code. (2.02.87)
   Add lvconvert --merge support for raid1 devices split with --trackchanges.
   Support lvconvert of -m1 raid1 devices to a higher number.
   Add --trackchanges support to lvconvert --splitmirrors option for raid1.
--- LVM2/lib/metadata/segtype.h	2011/08/24 08:27:50	1.37
+++ LVM2/lib/metadata/segtype.h	2011/08/24 13:41:46	1.38
@@ -130,21 +130,11 @@
 struct segment_type *init_unknown_segtype(struct cmd_context *cmd,
 					  const char *name);
 #ifdef RAID_INTERNAL
-struct segment_type *init_raid1_segtype(struct cmd_context *cmd);
-struct segment_type *init_raid4_segtype(struct cmd_context *cmd);
-struct segment_type *init_raid5_segtype(struct cmd_context *cmd);
-struct segment_type *init_raid5_la_segtype(struct cmd_context *cmd);
-struct segment_type *init_raid5_ra_segtype(struct cmd_context *cmd);
-struct segment_type *init_raid5_ls_segtype(struct cmd_context *cmd);
-struct segment_type *init_raid5_rs_segtype(struct cmd_context *cmd);
-struct segment_type *init_raid6_segtype(struct cmd_context *cmd);
-struct segment_type *init_raid6_zr_segtype(struct cmd_context *cmd);
-struct segment_type *init_raid6_nr_segtype(struct cmd_context *cmd);
-struct segment_type *init_raid6_nc_segtype(struct cmd_context *cmd);
+int init_raid_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
 #endif
 
 #ifdef REPLICATOR_INTERNAL
-int init_replicator_segtype(struct segtype_library *seglib);
+int init_replicator_segtype(struct cmd_context *cmd, struct segtype_library *seglib);
 #endif
 
 #ifdef SNAPSHOT_INTERNAL
--- LVM2/lib/raid/.exported_symbols	2011/08/11 19:18:18	1.1
+++ LVM2/lib/raid/.exported_symbols	2011/08/24 13:41:47	1.2
@@ -1 +1 @@
-init_segtype
+init_multiple_segtypes
--- LVM2/lib/raid/raid.c	2011/08/19 15:59:15	1.8
+++ LVM2/lib/raid/raid.c	2011/08/24 13:41:47	1.9
@@ -331,8 +331,8 @@
 	.destroy = _raid_destroy,
 };
 
-static struct segment_type *init_raid_segtype(struct cmd_context *cmd,
-					      const char *raid_type)
+static struct segment_type *_init_raid_segtype(struct cmd_context *cmd,
+					       const char *raid_type)
 {
 	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
 
@@ -362,25 +362,11 @@
 	return segtype;
 }
 
-#ifndef RAID_INTERNAL /* Shared */
-struct segment_type *init_raid1_segtype(struct cmd_context *cmd);
-struct segment_type *init_raid4_segtype(struct cmd_context *cmd);
-struct segment_type *init_raid5_segtype(struct cmd_context *cmd);
-struct segment_type *init_raid5_la_segtype(struct cmd_context *cmd);
-struct segment_type *init_raid5_ra_segtype(struct cmd_context *cmd);
-struct segment_type *init_raid5_ls_segtype(struct cmd_context *cmd);
-struct segment_type *init_raid5_rs_segtype(struct cmd_context *cmd);
-struct segment_type *init_raid6_segtype(struct cmd_context *cmd);
-struct segment_type *init_raid6_zr_segtype(struct cmd_context *cmd);
-struct segment_type *init_raid6_nr_segtype(struct cmd_context *cmd);
-struct segment_type *init_raid6_nc_segtype(struct cmd_context *cmd);
-#endif
-
-struct segment_type *init_raid1_segtype(struct cmd_context *cmd)
+static struct segment_type *_init_raid1_segtype(struct cmd_context *cmd)
 {
 	struct segment_type *segtype;
 
-	segtype = init_raid_segtype(cmd, "raid1");
+	segtype = _init_raid_segtype(cmd, "raid1");
 	if (!segtype)
 		return NULL;
 
@@ -389,43 +375,87 @@
 
 	return segtype;
 }
-struct segment_type *init_raid4_segtype(struct cmd_context *cmd)
+
+static struct segment_type *_init_raid4_segtype(struct cmd_context *cmd)
 {
-	return init_raid_segtype(cmd, "raid4");
+	return _init_raid_segtype(cmd, "raid4");
 }
-struct segment_type *init_raid5_segtype(struct cmd_context *cmd)
+
+static struct segment_type *_init_raid5_segtype(struct cmd_context *cmd)
 {
-	return init_raid_segtype(cmd, "raid5");
+	return _init_raid_segtype(cmd, "raid5");
 }
-struct segment_type *init_raid5_la_segtype(struct cmd_context *cmd)
+
+static struct segment_type *_init_raid5_la_segtype(struct cmd_context *cmd)
 {
-	return init_raid_segtype(cmd, "raid5_la");
+	return _init_raid_segtype(cmd, "raid5_la");
 }
-struct segment_type *init_raid5_ra_segtype(struct cmd_context *cmd)
+
+static struct segment_type *_init_raid5_ra_segtype(struct cmd_context *cmd)
 {
-	return init_raid_segtype(cmd, "raid5_ra");
+	return _init_raid_segtype(cmd, "raid5_ra");
 }
-struct segment_type *init_raid5_ls_segtype(struct cmd_context *cmd)
+
+static struct segment_type *_init_raid5_ls_segtype(struct cmd_context *cmd)
 {
-	return init_raid_segtype(cmd, "raid5_ls");
+	return _init_raid_segtype(cmd, "raid5_ls");
 }
-struct segment_type *init_raid5_rs_segtype(struct cmd_context *cmd)
+
+static struct segment_type *_init_raid5_rs_segtype(struct cmd_context *cmd)
 {
-	return init_raid_segtype(cmd, "raid5_rs");
+	return _init_raid_segtype(cmd, "raid5_rs");
 }
-struct segment_type *init_raid6_segtype(struct cmd_context *cmd)
+
+static struct segment_type *_init_raid6_segtype(struct cmd_context *cmd)
 {
-	return init_raid_segtype(cmd, "raid6");
+	return _init_raid_segtype(cmd, "raid6");
 }
-struct segment_type *init_raid6_zr_segtype(struct cmd_context *cmd)
+
+static struct segment_type *_init_raid6_zr_segtype(struct cmd_context *cmd)
 {
-	return init_raid_segtype(cmd, "raid6_zr");
+	return _init_raid_segtype(cmd, "raid6_zr");
 }
-struct segment_type *init_raid6_nr_segtype(struct cmd_context *cmd)
+
+static struct segment_type *_init_raid6_nr_segtype(struct cmd_context *cmd)
 {
-	return init_raid_segtype(cmd, "raid6_nr");
+	return _init_raid_segtype(cmd, "raid6_nr");
 }
-struct segment_type *init_raid6_nc_segtype(struct cmd_context *cmd)
+
+static struct segment_type *_init_raid6_nc_segtype(struct cmd_context *cmd)
 {
-	return init_raid_segtype(cmd, "raid6_nc");
+	return _init_raid_segtype(cmd, "raid6_nc");
+}
+
+#ifdef RAID_INTERNAL /* Shared */
+int init_raid_segtypes(struct cmd_context *cmd, struct segtype_library *seglib)
+#else
+int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
+
+int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *seglib)
+#endif
+{
+	struct segment_type *segtype;
+	unsigned i = 0;
+	struct segment_type *(*raid_segtype_fn[])(struct cmd_context *) =  {
+		_init_raid1_segtype,
+		_init_raid4_segtype,
+		_init_raid5_segtype,
+		_init_raid5_la_segtype,
+		_init_raid5_ra_segtype,
+		_init_raid5_ls_segtype,
+		_init_raid5_rs_segtype,
+		_init_raid6_segtype,
+		_init_raid6_zr_segtype,
+		_init_raid6_nr_segtype,
+		_init_raid6_nc_segtype,
+		NULL,
+	};
+
+	do {
+		if ((segtype = raid_segtype_fn[i](cmd)) &&
+		    !lvm_register_segtype(seglib, segtype))
+			return 0;
+	} while (raid_segtype_fn[++i]);
+
+	return 1;
 }
--- LVM2/lib/commands/toolcontext.c	2011/08/11 17:46:13	1.128
+++ LVM2/lib/commands/toolcontext.c	2011/08/24 13:41:47	1.129
@@ -994,24 +994,17 @@
 {
 	int i;
 	struct segment_type *segtype;
-	struct segtype_library seglib = { .cmd = cmd };
+	struct segtype_library seglib = { .cmd = cmd, .lib = NULL };
 	struct segment_type *(*init_segtype_array[])(struct cmd_context *cmd) = {
 		init_striped_segtype,
 		init_zero_segtype,
 		init_error_segtype,
 		init_free_segtype,
-#ifdef RAID_INTERNAL
-		init_raid1_segtype,
-		init_raid4_segtype,
-		init_raid5_segtype,
-		init_raid5_la_segtype,
-		init_raid5_ra_segtype,
-		init_raid5_ls_segtype,
-		init_raid5_rs_segtype,
-		init_raid6_segtype,
-		init_raid6_zr_segtype,
-		init_raid6_nr_segtype,
-		init_raid6_nc_segtype,
+#ifdef SNAPSHOT_INTERNAL
+		init_snapshot_segtype,
+#endif
+#ifdef MIRRORED_INTERNAL
+		init_mirrored_segtype,
 #endif
 		NULL
 	};
@@ -1027,22 +1020,13 @@
 		dm_list_add(&cmd->segtypes, &segtype->list);
 	}
 
-#ifdef SNAPSHOT_INTERNAL
-	if (!(segtype = init_snapshot_segtype(cmd)))
-		return 0;
-	segtype->library = NULL;
-	dm_list_add(&cmd->segtypes, &segtype->list);
-#endif
-
-#ifdef MIRRORED_INTERNAL
-	if (!(segtype = init_mirrored_segtype(cmd)))
+#ifdef REPLICATOR_INTERNAL
+	if (!init_replicator_segtype(cmd, &seglib))
 		return 0;
-	segtype->library = NULL;
-	dm_list_add(&cmd->segtypes, &segtype->list);
 #endif
 
-#ifdef REPLICATOR_INTERNAL
-	if (!init_replicator_segtype(&seglib))
+#ifdef RAID_INTERNAL
+	if (!init_raid_segtypes(cmd, &seglib))
 		return 0;
 #endif
 
--- LVM2/lib/replicator/replicator.c	2011/06/17 14:14:20	1.7
+++ LVM2/lib/replicator/replicator.c	2011/08/24 13:41:47	1.8
@@ -754,10 +754,10 @@
 };
 
 #ifdef REPLICATOR_INTERNAL
-int init_replicator_segtype(struct segtype_library *seglib)
+int init_replicator_segtype(struct cmd_context *cmd, struct segtype_library *seglib)
 #else /* Shared */
-int init_multiple_segtype(struct segtype_library *seglib);
-int init_multiple_segtype(struct segtype_library *seglib)
+int init_multiple_segtype(struct cmd_context *cmd, struct segtype_library *seglib);
+int init_multiple_segtype(struct cmd_context *cmd, struct segtype_library *seglib)
 #endif
 {
 	struct segment_type *segtype;


