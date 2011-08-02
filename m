From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 2 Aug 2011 22:07:26 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in do ...
Message-ID: <20110802220726.30641.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-08-02 22:07:23

Modified files:
	.              : WHATS_NEW configure configure.in 
	doc            : example.conf.in 
	lib            : Makefile.in 
	lib/activate   : dev_manager.c 
	lib/commands   : toolcontext.c 
	lib/config     : defaults.h 
	lib/format_text: export.c flags.c import_vsn1.c 
	lib/metadata   : lv_manip.c merge.c metadata-exported.h 
	                 metadata.h segtype.h 
	lib/misc       : configure.h.in lvm-string.c 
	libdm          : libdevmapper.h libdm-deptree.c 
	man            : lvcreate.8.in 
	tools          : lvcreate.c 
Added files:
	lib/raid       : raid.c 

Log message:
	Add basic RAID segment type(s) support.
	
	Implementation described in doc/lvm2-raid.txt.
	
	Basic support includes:
	- ability to create RAID 1/4/5/6 arrays
	- ability to delete RAID arrays
	- ability to display RAID arrays
	Notable missing features (not included in this patch):
	- ability to clean-up/repair failures
	- ability to convert RAID segment types
	- ability to monitor RAID segment types

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2045&r2=1.2046
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.149&r2=1.150
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.163&r2=1.164
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.109&r2=1.110
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.226&r2=1.227
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.126&r2=1.127
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/flags.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.268&r2=1.269
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.194&r2=1.195
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.247&r2=1.248
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/raid/raid.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.139&r2=1.140
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.231&r2=1.232

--- LVM2/WHATS_NEW	2011/08/02 10:49:57	1.2045
+++ LVM2/WHATS_NEW	2011/08/02 22:07:20	1.2046
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Add basic support for RAID 1/4/5/6 (i.e. create, remove, display)
   Change DEFAULT_UDEV_SYNC to 1 so udev_sync is used even without any config.
   Add systemd unit file to provide lvm2 monitoring.
   Compare also file size to detect changed config file.
--- LVM2/configure	2011/07/28 12:59:44	1.149
+++ LVM2/configure	2011/08/02 22:07:20	1.150
@@ -614,11 +614,12 @@
 SNAPSHOTS
 SELINUX_PC
 SELINUX_LIBS
+REPLICATORS
 READLINE_LIBS
+RAID
 PTHREAD_LIBS
 POOL
 PKGCONFIG
-REPLICATORS
 OCFDIR
 OCF
 MIRRORS
@@ -797,6 +798,7 @@
 with_cluster
 with_snapshots
 with_mirrors
+with_raid
 with_replicators
 enable_readline
 enable_realtime
@@ -1543,6 +1545,8 @@
                           [[TYPE=internal]]
   --with-mirrors=TYPE     mirror support: internal/shared/none
                           [[TYPE=internal]]
+  --with-raid=TYPE        mirror support: internal/shared/none
+                          [[TYPE=internal]]
   --with-replicators=TYPE replicator support: internal/shared/none
                           [[TYPE=none]]
   --with-ocfdir=DIR       install OCF files in DIR
@@ -6886,6 +6890,31 @@
 fi
 
 ################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include raid" >&5
+$as_echo_n "checking whether to include raid... " >&6; }
+
+# Check whether --with-raid was given.
+if test "${with_raid+set}" = set; then :
+  withval=$with_raid; RAID=$withval
+else
+  RAID=internal
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $RAID" >&5
+$as_echo "$RAID" >&6; }
+
+if [ "x$RAID" != xnone -a "x$RAID" != xinternal -a "x$RAID" != xshared ];
+ then  as_fn_error $? "--with-raid parameter invalid
+" "$LINENO" 5
+fi;
+
+if test x$RAID = xinternal; then
+
+$as_echo "#define RAID_INTERNAL 1" >>confdefs.h
+
+fi
+
+################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include replicators" >&5
 $as_echo_n "checking whether to include replicators... " >&6; }
 
@@ -9169,6 +9198,7 @@
 ################################################################################
 if [ \( "x$LVM1" = xshared -o "x$POOL" = xshared -o "x$CLUSTER" = xshared \
       -o "x$SNAPSHOTS" = xshared -o "x$MIRRORS" = xshared \
+      -o "x$RAID" = xshared \
       \) -a "x$STATIC_LINK" = xyes ];
  then  as_fn_error $? "Features cannot be 'shared' when building statically
 " "$LINENO" 5
@@ -10382,6 +10412,7 @@
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makef!
 ile unit-tests/mm/Makefile"
 
--- LVM2/configure.in	2011/07/28 12:57:26	1.163
+++ LVM2/configure.in	2011/08/02 22:07:21	1.164
@@ -341,6 +341,26 @@
 fi
 
 ################################################################################
+dnl -- raid inclusion type
+AC_MSG_CHECKING(whether to include raid)
+AC_ARG_WITH(raid,
+	    AC_HELP_STRING([--with-raid=TYPE],
+			   [mirror support: internal/shared/none
+			    [[TYPE=internal]]]),
+	    RAID=$withval, RAID=internal)
+AC_MSG_RESULT($RAID)
+
+if [[ "x$RAID" != xnone -a "x$RAID" != xinternal -a "x$RAID" != xshared ]];
+ then  AC_MSG_ERROR(
+--with-raid parameter invalid
+)
+fi;
+
+if test x$RAID = xinternal; then
+	AC_DEFINE([RAID_INTERNAL], 1, [Define to 1 to include built-in support for raid.])
+fi
+
+################################################################################
 dnl -- asynchronous volume replicator inclusion type
 AC_MSG_CHECKING(whether to include replicators)
 AC_ARG_WITH(replicators,
@@ -961,6 +981,7 @@
 dnl -- Check for shared/static conflicts
 if [[ \( "x$LVM1" = xshared -o "x$POOL" = xshared -o "x$CLUSTER" = xshared \
       -o "x$SNAPSHOTS" = xshared -o "x$MIRRORS" = xshared \
+      -o "x$RAID" = xshared \
       \) -a "x$STATIC_LINK" = xyes ]];
  then  AC_MSG_ERROR(
 Features cannot be 'shared' when building statically
@@ -1346,16 +1367,17 @@
 AC_SUBST(LVM_RELEASE)
 AC_SUBST(LVM_RELEASE_DATE)
 AC_SUBST(MIRRORS)
+AC_SUBST(MSGFMT)
 AC_SUBST(OCF)
 AC_SUBST(OCFDIR)
-AC_SUBST(REPLICATORS)
-AC_SUBST(MSGFMT)
 AC_SUBST(PKGCONFIG)
 AC_SUBST(POOL)
 AC_SUBST(PTHREAD_LIBS)
 AC_SUBST(QUORUM_CFLAGS)
 AC_SUBST(QUORUM_LIBS)
+AC_SUBST(RAID)
 AC_SUBST(READLINE_LIBS)
+AC_SUBST(REPLICATORS)
 AC_SUBST(SACKPT_CFLAGS)
 AC_SUBST(SACKPT_LIBS)
 AC_SUBST(SALCK_CFLAGS)
--- LVM2/doc/example.conf.in	2011/07/01 14:09:19	1.28
+++ LVM2/doc/example.conf.in	2011/08/02 22:07:21	1.29
@@ -474,6 +474,26 @@
     # "auto" - Use default value chosen by kernel.
     readahead = "auto"
 
+    # 'mirror_segtype_default' defines which segtype will be used when the
+    # shorthand '-m' option is used for mirroring.  The possible options are:
+    #
+    # "mirror" - The original RAID1 implementation provided by LVM2/DM.  It is
+    # 	         characterized by a flexible log solution (core, disk, mirrored)
+    #		 and by the necessity to block I/O while reconfiguring in the
+    #		 event of a failure.  Snapshots of this type of RAID1 can be
+    #		 problematic.
+    #
+    # "raid1"  - This implementation leverages MD's RAID1 personality through
+    # 	       	 device-mapper.  It is characterized by a lack of log options.
+    #		 (A log is always allocated for every device and they are placed
+    #		 on the same device as the image - no separate devices are
+    #		 required.)  This mirror implementation does not require I/O
+    #		 to be blocked in the kernel in the event of a failure.
+    #
+    # Specify the '--type <mirror|raid1>' option to override this default
+    # setting.
+    mirror_segtype_default = "mirror"
+
     # 'mirror_image_fault_policy' and 'mirror_log_fault_policy' define
     # how a device failure affecting a mirror is handled.
     # A mirror is composed of mirror images (copies) and a log.
--- LVM2/lib/Makefile.in	2010/11/30 11:53:31	1.109
+++ LVM2/lib/Makefile.in	2011/08/02 22:07:21	1.110
@@ -32,6 +32,10 @@
   SUBDIRS += mirror
 endif
 
+ifeq ("@RAID@", "shared")
+  SUBDIRS += raid
+endif
+
 ifeq ("@REPLICATORS@", "shared")
   SUBDIRS += replicator
 endif
@@ -140,6 +144,10 @@
   SOURCES += mirror/mirrored.c
 endif
 
+ifeq ("@RAID@", "internal")
+  SOURCES += raid/raid.c
+endif
+
 ifeq ("@REPLICATORS@", "internal")
   SOURCES += replicator/replicator.c
 endif
@@ -170,6 +178,7 @@
 	format_pool \
 	snapshot \
 	mirror \
+	raid \
 	replicator \
 	locking
 endif
--- LVM2/lib/activate/dev_manager.c	2011/07/06 00:29:45	1.226
+++ LVM2/lib/activate/dev_manager.c	2011/08/02 22:07:21	1.227
@@ -751,6 +751,7 @@
 {
 	char *name;
 	const char *dlid;
+	const char *target_type = first_seg(lv)->segtype->name;
 	const char *layer = (lv_is_origin(lv)) ? "real" : NULL;
 
 	/*
@@ -766,8 +767,9 @@
 		return 0;
 	}
 
-	log_debug("Getting device mirror status percentage for %s", name);
-	if (!(_percent(dm, name, dlid, "mirror", wait, lv, percent,
+	log_debug("Getting device %s status percentage for %s",
+		  target_type, name);
+	if (!(_percent(dm, name, dlid, target_type, wait, lv, percent,
 		       event_nr, 0)))
 		return_0;
 
@@ -1216,6 +1218,15 @@
 				    (seg_pv(seg, s)->pe_start + (extent_size * seg_pe(seg, s)))))
 				return_0;
 		} else if (seg_type(seg, s) == AREA_LV) {
+			if (seg_is_raid(seg)) {
+				dlid = build_dm_uuid(dm->mem,
+						     seg_metalv(seg, s)->lvid.s,
+						     NULL);
+				if (!dlid)
+					return_0;
+				dm_tree_node_add_target_area(node, NULL, dlid,
+							     extent_size * seg_metale(seg, s));
+			}
 			if (!(dlid = build_dm_uuid(dm->mem, seg_lv(seg, s)->lvid.s, NULL)))
 				return_0;
 			if (!dm_tree_node_add_target_area(node, NULL, dlid, extent_size * seg_le(seg, s)))
@@ -1444,11 +1455,16 @@
 			return_0;
 	} else {
 		/* Add any LVs used by this segment */
-		for (s = 0; s < seg->area_count; s++)
+		for (s = 0; s < seg->area_count; s++) {
 			if ((seg_type(seg, s) == AREA_LV) &&
 			    (!_add_new_lv_to_dtree(dm, dtree, seg_lv(seg, s),
 						   laopts, NULL)))
 				return_0;
+			if (seg_is_raid(seg) &&
+			    !_add_new_lv_to_dtree(dm, dtree, seg_metalv(seg, s),
+						  laopts, NULL))
+				return_0;
+		}
 	}
 
 	/* Now we've added its dependencies, we can add the target itself */
--- LVM2/lib/commands/toolcontext.c	2011/07/08 17:31:06	1.126
+++ LVM2/lib/commands/toolcontext.c	2011/08/02 22:07:22	1.127
@@ -988,32 +988,40 @@
 
 static int _init_segtypes(struct cmd_context *cmd)
 {
+	int i;
 	struct segment_type *segtype;
 	struct segtype_library seglib = { .cmd = cmd };
+	struct segment_type *(*init_segtype_array[])(struct cmd_context *cmd) = {
+		init_striped_segtype,
+		init_zero_segtype,
+		init_error_segtype,
+		init_free_segtype,
+#ifdef RAID_INTERNAL
+		init_raid1_segtype,
+		init_raid4_segtype,
+		init_raid5_segtype,
+		init_raid5_la_segtype,
+		init_raid5_ra_segtype,
+		init_raid5_ls_segtype,
+		init_raid5_rs_segtype,
+		init_raid6_segtype,
+		init_raid6_zr_segtype,
+		init_raid6_nr_segtype,
+		init_raid6_nc_segtype,
+#endif
+		NULL
+	};
 
 #ifdef HAVE_LIBDL
 	const struct config_node *cn;
 #endif
 
-	if (!(segtype = init_striped_segtype(cmd)))
-		return 0;
-	segtype->library = NULL;
-	dm_list_add(&cmd->segtypes, &segtype->list);
-
-	if (!(segtype = init_zero_segtype(cmd)))
-		return 0;
-	segtype->library = NULL;
-	dm_list_add(&cmd->segtypes, &segtype->list);
-
-	if (!(segtype = init_error_segtype(cmd)))
-		return 0;
-	segtype->library = NULL;
-	dm_list_add(&cmd->segtypes, &segtype->list);
-
-	if (!(segtype = init_free_segtype(cmd)))
-		return 0;
-	segtype->library = NULL;
-	dm_list_add(&cmd->segtypes, &segtype->list);
+	for (i = 0; init_segtype_array[i]; i++) {
+		if (!(segtype = init_segtype_array[i](cmd)))
+			return 0;
+		segtype->library = NULL;
+		dm_list_add(&cmd->segtypes, &segtype->list);
+	}
 
 #ifdef SNAPSHOT_INTERNAL
 	if (!(segtype = init_snapshot_segtype(cmd)))
--- LVM2/lib/config/defaults.h	2011/08/02 10:49:57	1.79
+++ LVM2/lib/config/defaults.h	2011/08/02 22:07:22	1.80
@@ -49,6 +49,7 @@
 #define DEFAULT_USE_MLOCKALL 0
 #define DEFAULT_METADATA_READ_ONLY 0
 
+#define DEFAULT_MIRROR_SEGTYPE "mirror"
 #define DEFAULT_MIRRORLOG "disk"
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
 #define DEFAULT_MIRROR_IMAGE_FAULT_POLICY "remove"
--- LVM2/lib/format_text/export.c	2011/04/08 14:21:34	1.81
+++ LVM2/lib/format_text/export.c	2011/08/02 22:07:22	1.82
@@ -544,10 +544,25 @@
 			     (s == seg->area_count - 1) ? "" : ",");
 			break;
 		case AREA_LV:
-			outf(f, "\"%s\", %u%s",
-			     seg_lv(seg, s)->name,
-			     seg_le(seg, s),
+			if (!(seg->status & RAID)) {
+				outf(f, "\"%s\", %u%s",
+				     seg_lv(seg, s)->name,
+				     seg_le(seg, s),
+				     (s == seg->area_count - 1) ? "" : ",");
+				continue;
+			}
+
+			/* RAID devices are laid-out in metadata/data pairs */
+			if (!(seg_lv(seg, s)->status & RAID_IMAGE) ||
+			    !(seg_metalv(seg, s)->status & RAID_META)) {
+				log_error("RAID segment has non-RAID areas");
+				return 0;
+			}
+
+			outf(f, "\"%s\", \"%s\"%s",
+			     seg_metalv(seg, s)->name, seg_lv(seg, s)->name,
 			     (s == seg->area_count - 1) ? "" : ",");
+
 			break;
 		case AREA_UNASSIGNED:
 			return 0;
--- LVM2/lib/format_text/flags.c	2011/06/17 14:30:58	1.45
+++ LVM2/lib/format_text/flags.c	2011/08/02 22:07:22	1.46
@@ -56,6 +56,9 @@
 	{PVMOVE, "PVMOVE", STATUS_FLAG},
 	{LOCKED, "LOCKED", STATUS_FLAG},
 	{LV_NOTSYNCED, "NOTSYNCED", STATUS_FLAG},
+	{RAID, NULL, 0},
+	{RAID_META, NULL, 0},
+	{RAID_IMAGE, NULL, 0},
 	{MIRROR_IMAGE, NULL, 0},
 	{MIRROR_LOG, NULL, 0},
 	{MIRRORED, NULL, 0},
--- LVM2/lib/format_text/import_vsn1.c	2011/06/01 19:29:33	1.88
+++ LVM2/lib/format_text/import_vsn1.c	2011/08/02 22:07:22	1.89
@@ -365,10 +365,13 @@
 	if (seg_is_mirrored(seg))
 		lv->status |= MIRRORED;
 
+	if (seg_is_raid(seg))
+		lv->status |= RAID;
+
 	if (seg_is_virtual(seg))
 		lv->status |= VIRTUAL;
 
-	if (_is_converting(lv))
+	if (!seg_is_raid(seg) && _is_converting(lv))
 		lv->status |= CONVERTING;
 
 	return 1;
--- LVM2/lib/metadata/lv_manip.c	2011/07/19 16:37:42	1.268
+++ LVM2/lib/metadata/lv_manip.c	2011/08/02 22:07:22	1.269
@@ -35,6 +35,9 @@
 	NEXT_AREA
 } area_use_t;
 
+/* FIXME: remove RAID_METADATA_AREA_LEN macro after defining 'raid_log_extents'*/
+#define RAID_METADATA_AREA_LEN 1
+
 /* FIXME These ended up getting used differently from first intended.  Refactor. */
 #define A_CONTIGUOUS		0x01
 #define A_CLING			0x02
@@ -215,6 +218,11 @@
 	struct lv_segment *seg;
 	uint32_t areas_sz = area_count * sizeof(*seg->areas);
 
+	if (!segtype) {
+		log_error(INTERNAL_ERROR "alloc_lv_segment: Missing segtype.");
+		return NULL;
+	}
+
 	if (!(seg = dm_pool_zalloc(mem, sizeof(*seg))))
 		return_NULL;
 
@@ -223,9 +231,10 @@
 		return_NULL;
 	}
 
-	if (!segtype) {
-		log_error("alloc_lv_segment: Missing segtype.");
-		return NULL;
+	if (segtype_is_raid(segtype) &&
+	    !(seg->meta_areas = dm_pool_zalloc(mem, areas_sz))) {
+		dm_pool_free(mem, seg); /* frees everything alloced since seg */
+		return_NULL;
 	}
 
 	seg->segtype = segtype;
@@ -293,6 +302,27 @@
 		return;
 	}
 
+	if (seg_lv(seg, s)->status & RAID_IMAGE) {
+		/*
+		 * FIXME: Use lv_reduce not lv_remove
+		 *  We use lv_remove for now, because I haven't figured out
+		 *  why lv_reduce won't remove the LV.
+		lv_reduce(seg_lv(seg, s), area_reduction);
+		*/
+		if (area_reduction != seg->area_len) {
+			log_error("Unable to reduce RAID LV - operation not implemented.");
+			return;
+		} else
+			lv_remove(seg_lv(seg, s));
+
+		/* Remove metadata area if image has been removed */
+		if (area_reduction == seg->area_len) {
+			lv_reduce(seg_metalv(seg, s),
+				  seg_metalv(seg, s)->le_count);
+		}
+		return;
+	}
+
 	if (area_reduction == seg->area_len) {
 		log_very_verbose("Remove %s:%" PRIu32 "[%" PRIu32 "] from "
 				 "the top of LV %s:%" PRIu32,
@@ -375,9 +405,19 @@
 	log_very_verbose("Stack %s:%" PRIu32 "[%" PRIu32 "] on LV %s:%" PRIu32,
 			 seg->lv->name, seg->le, area_num, lv->name, le);
 
-	seg->areas[area_num].type = AREA_LV;
-	seg_lv(seg, area_num) = lv;
-	seg_le(seg, area_num) = le;
+	if (status & RAID_META) {
+		seg->meta_areas[area_num].type = AREA_LV;
+		seg_metalv(seg, area_num) = lv;
+		if (le) {
+			log_error(INTERNAL_ERROR "Meta le != 0");
+			return 0;
+		}
+		seg_metale(seg, area_num) = 0;
+	} else {
+		seg->areas[area_num].type = AREA_LV;
+		seg_lv(seg, area_num) = lv;
+		seg_le(seg, area_num) = le;
+	}
 	lv->status |= status;
 
 	if (!add_seg_to_segs_using_this_lv(lv, seg))
@@ -559,14 +599,25 @@
 	alloc_policy_t alloc;		/* Overall policy */
 	uint32_t new_extents;		/* Number of new extents required */
 	uint32_t area_count;		/* Number of parallel areas */
+	uint32_t parity_count;   /* Adds to area_count, but not area_multiple */
 	uint32_t area_multiple;		/* seg->len = area_len * area_multiple */
 	uint32_t log_area_count;	/* Number of parallel logs */
-	uint32_t log_len;		/* Length of log */
+	uint32_t metadata_area_count;   /* Number of parallel metadata areas */
+	uint32_t log_len;		/* Length of log/metadata_area */
 	uint32_t region_size;		/* Mirror region size */
 	uint32_t total_area_len;	/* Total number of parallel extents */
 
 	unsigned maximise_cling;
-	unsigned mirror_logs_separate;	/* Must mirror logs be on separate PVs? */
+	unsigned mirror_logs_separate;	/* Force mirror logs on separate PVs? */
+
+	/*
+	 * RAID devices require a metadata area that accompanies each
+	 * device.  During initial creation, it is best to look for space
+	 * that is new_extents + log_len and then split that between two
+	 * allocated areas when found.  'alloc_and_split_meta' indicates
+	 * that this is the desired dynamic.
+	 */
+	unsigned alloc_and_split_meta;
 
 	const struct config_node *cling_tag_list_cn;
 
@@ -631,13 +682,14 @@
 					uint32_t new_extents,
 					uint32_t mirrors,
 					uint32_t stripes,
-					uint32_t log_area_count,
+					uint32_t metadata_area_count,
 					uint32_t extent_size,
 					uint32_t region_size,
 					struct dm_list *parallel_areas)
 {
 	struct alloc_handle *ah;
-	uint32_t s, area_count;
+	uint32_t s, area_count, alloc_count;
+	size_t size = 0;
 
 	/* FIXME Caller should ensure this */
 	if (mirrors && !stripes)
@@ -650,7 +702,18 @@
 	else
 		area_count = stripes;
 
-	if (!(ah = dm_pool_zalloc(mem, sizeof(*ah) + sizeof(ah->alloced_areas[0]) * (area_count + log_area_count)))) {
+	size = sizeof(*ah);
+	alloc_count = area_count + segtype->parity_devs;
+	if (segtype_is_raid(segtype) && metadata_area_count)
+		/* RAID has a meta area for each device */
+		alloc_count *= 2;
+	else
+		/* mirrors specify their exact log count */
+		alloc_count += metadata_area_count;
+
+	size += sizeof(ah->alloced_areas[0]) * alloc_count;
+
+	if (!(ah = dm_pool_zalloc(mem, size))) {
 		log_error("allocation handle allocation failed");
 		return NULL;
 	}
@@ -660,7 +723,7 @@
 	if (segtype_is_virtual(segtype))
 		return ah;
 
-	if (!(area_count + log_area_count)) {
+	if (!(area_count + metadata_area_count)) {
 		log_error(INTERNAL_ERROR "_alloc_init called for non-virtual segment with no disk space.");
 		return NULL;
 	}
@@ -672,14 +735,35 @@
 
 	ah->new_extents = new_extents;
 	ah->area_count = area_count;
-	ah->log_area_count = log_area_count;
+	ah->parity_count = segtype->parity_devs;
 	ah->region_size = region_size;
 	ah->alloc = alloc;
 	ah->area_multiple = _calc_area_multiple(segtype, area_count, stripes);
 
-	ah->log_len = log_area_count ? mirror_log_extents(ah->region_size, extent_size, ah->new_extents / ah->area_multiple) : 0;
+	if (segtype_is_raid(segtype)) {
+		if (metadata_area_count) {
+			if (metadata_area_count != area_count)
+				log_error(INTERNAL_ERROR
+					  "Bad metadata_area_count");
+			ah->metadata_area_count = area_count;
+			ah->alloc_and_split_meta = 1;
+
+			ah->log_len = RAID_METADATA_AREA_LEN;
+
+			/*
+			 * We need 'log_len' extents for each
+			 * RAID device's metadata_area
+			 */
+			ah->new_extents += (ah->log_len * ah->area_multiple);
+		}
+	} else {
+		ah->log_area_count = metadata_area_count;
+		ah->log_len = !metadata_area_count ? 0 :
+			mirror_log_extents(ah->region_size, extent_size,
+					   ah->new_extents / ah->area_multiple);
+	}
 
-	for (s = 0; s < ah->area_count + ah->log_area_count; s++)
+	for (s = 0; s < alloc_count; s++)
 		dm_list_init(&ah->alloced_areas[s]);
 
 	ah->parallel_areas = parallel_areas;
@@ -700,9 +784,13 @@
 }
 
 /* Is there enough total space or should we give up immediately? */
-static int _sufficient_pes_free(struct alloc_handle *ah, struct dm_list *pvms, uint32_t allocated, uint32_t extents_still_needed)
+static int _sufficient_pes_free(struct alloc_handle *ah, struct dm_list *pvms,
+				uint32_t allocated, uint32_t extents_still_needed)
 {
-	uint32_t total_extents_needed = (extents_still_needed - allocated) * ah->area_count / ah->area_multiple;
+	uint32_t area_extents_needed = (extents_still_needed - allocated) * ah->area_count / ah->area_multiple;
+	uint32_t parity_extents_needed = (extents_still_needed - allocated) * ah->parity_count / ah->area_multiple;
+	uint32_t metadata_extents_needed = ah->metadata_area_count * RAID_METADATA_AREA_LEN; /* One each */
+	uint32_t total_extents_needed = area_extents_needed + parity_extents_needed + metadata_extents_needed;
 	uint32_t free_pes = pv_maps_size(pvms);
 
 	if (total_extents_needed > free_pes) {
@@ -874,9 +962,12 @@
 	uint32_t area_len, len;
 	uint32_t s;
 	uint32_t ix_log_skip = 0; /* How many areas to skip in middle of array to reach log areas */
-	uint32_t total_area_count = ah->area_count + alloc_state->log_area_count_still_needed;
+	uint32_t total_area_count;
 	struct alloced_area *aa;
+	struct pv_area *pva;
 
+	total_area_count = ah->area_count + alloc_state->log_area_count_still_needed;
+	total_area_count += ah->parity_count;
 	if (!total_area_count) {
 		log_error(INTERNAL_ERROR "_alloc_parallel_area called without any allocation to do.");
 		return 1;
@@ -885,11 +976,13 @@
 	area_len = max_to_allocate / ah->area_multiple;
 
 	/* Reduce area_len to the smallest of the areas */
-	for (s = 0; s < ah->area_count; s++)
+	for (s = 0; s < ah->area_count + ah->parity_count; s++)
 		if (area_len > alloc_state->areas[s].used)
 			area_len = alloc_state->areas[s].used;
 
-	if (!(aa = dm_pool_alloc(ah->mem, sizeof(*aa) * total_area_count))) {
+	len = (ah->alloc_and_split_meta) ? total_area_count * 2 : total_area_count;
+	len *= sizeof(*aa);
+	if (!(aa = dm_pool_alloc(ah->mem, len))) {
 		log_error("alloced_area allocation failed");
 		return 0;
 	}
@@ -901,24 +994,53 @@
 	 */
 	len = area_len;
 	for (s = 0; s < total_area_count; s++) {
-		if (s == ah->area_count) {
+		if (s == (ah->area_count + ah->parity_count)) {
 			ix_log_skip = ix_log_offset - ah->area_count;
 			len = ah->log_len;
 		}
 
-		aa[s].pv = alloc_state->areas[s + ix_log_skip].pva->map->pv;
-		aa[s].pe = alloc_state->areas[s + ix_log_skip].pva->start;
-		aa[s].len = len;
+		pva = alloc_state->areas[s + ix_log_skip].pva;
+		if (ah->alloc_and_split_meta) {
+			/*
+			 * The metadata area goes at the front of the allocated
+			 * space for now, but could easily go at the end (or
+			 * middle!).
+			 *
+			 * Even though we split these two from the same
+			 * allocation, we store the images at the beginning
+			 * of the areas array and the metadata at the end.
+			 */
+			s += ah->area_count + ah->parity_count;
+			aa[s].pv = pva->map->pv;
+			aa[s].pe = pva->start;
+			aa[s].len = ah->log_len;
+
+			log_debug("Allocating parallel metadata area %" PRIu32
+				  " on %s start PE %" PRIu32
+				  " length %" PRIu32 ".",
+				  s, pv_dev_name(aa[s].pv), aa[s].pe,
+				  ah->log_len);
+
+			consume_pv_area(pva, ah->log_len);
+			dm_list_add(&ah->alloced_areas[s], &aa[s].list);
+			s -= ah->area_count + ah->parity_count;
+		}
+		aa[s].pv = pva->map->pv;
+		aa[s].pe = pva->start;
+		aa[s].len = (ah->alloc_and_split_meta) ? len - ah->log_len : len;
 
 		log_debug("Allocating parallel area %" PRIu32
 			  " on %s start PE %" PRIu32 " length %" PRIu32 ".",
-			  s, dev_name(aa[s].pv->dev), aa[s].pe, len);
+			  s, pv_dev_name(aa[s].pv), aa[s].pe, aa[s].len);
 
-		consume_pv_area(alloc_state->areas[s + ix_log_skip].pva, len);
+		consume_pv_area(pva, aa[s].len);
 
 		dm_list_add(&ah->alloced_areas[s], &aa[s].list);
 	}
 
+	/* Only need to alloc metadata from the first batch */
+	ah->alloc_and_split_meta = 0;
+
 	ah->total_area_len += area_len;
 
 	alloc_state->allocated += area_len * ah->area_multiple;
@@ -1425,6 +1547,7 @@
 	unsigned log_iteration_count = 0; /* extra iteration for logs on data devices */
 	struct alloced_area *aa;
 	uint32_t s;
+	uint32_t devices_needed = ah->area_count + ah->parity_count;
 
 	/* ix_offset holds the number of parallel allocations that must be contiguous/cling */
 	if (alloc_parms->flags & (A_CONTIGUOUS | A_CLING) && alloc_parms->prev_lvseg)
@@ -1442,15 +1565,15 @@
 	log_debug("Still need %" PRIu32 " extents for %" PRIu32 " parallel areas and %" PRIu32 " log areas of %" PRIu32 " extents. "
 		  "(Total %" PRIu32 " extents.)",
 		  (ah->new_extents - alloc_state->allocated) / ah->area_multiple,
-		  ah->area_count, alloc_state->log_area_count_still_needed,
+		  devices_needed, alloc_state->log_area_count_still_needed,
 		  alloc_state->log_area_count_still_needed ? ah->log_len : 0,
-		  (ah->new_extents - alloc_state->allocated) * ah->area_count / ah->area_multiple +
+		  (ah->new_extents - alloc_state->allocated) * devices_needed / ah->area_multiple +
 			alloc_state->log_area_count_still_needed * ah->log_len);
 
 	/* ix holds the number of areas found on other PVs */
 	do {
 		if (log_iteration_count) {
-			log_debug("Found %u areas for %" PRIu32 " parallel areas and %" PRIu32 " log areas so far.", ix, ah->area_count, alloc_state->log_area_count_still_needed);
+			log_debug("Found %u areas for %" PRIu32 " parallel areas and %" PRIu32 " log areas so far.", ix, devices_needed, alloc_state->log_area_count_still_needed);
 		} else if (iteration_count)
 			log_debug("Filled %u out of %u preferred areas so far.", preferred_count, ix_offset);
 
@@ -1493,12 +1616,12 @@
 				 * not enough for the logs.
 				 */
 				if (log_iteration_count) {
-					for (s = ah->area_count; s < ix + ix_offset; s++)
+					for (s = devices_needed; s < ix + ix_offset; s++)
 						if (alloc_state->areas[s].pva && alloc_state->areas[s].pva->map->pv == pvm->pv)
 							goto next_pv;
 				/* On a second pass, avoid PVs already used in an uncommitted area */
  				} else if (iteration_count)
-					for (s = 0; s < ah->area_count; s++)
+					for (s = 0; s < devices_needed; s++)
 						if (alloc_state->areas[s].pva && alloc_state->areas[s].pva->map->pv == pvm->pv)
 							goto next_pv;
 			}
@@ -1548,32 +1671,34 @@
 			/* With cling and contiguous we stop if we found a match for *all* the areas */
 			/* FIXME Rename these variables! */
 			if ((alloc_parms->alloc == ALLOC_ANYWHERE &&
-			    ix + ix_offset >= ah->area_count + alloc_state->log_area_count_still_needed) ||
+			    ix + ix_offset >= devices_needed + alloc_state->log_area_count_still_needed) ||
 			    (preferred_count == ix_offset &&
-			     (ix_offset == ah->area_count + alloc_state->log_area_count_still_needed)))
+			     (ix_offset == devices_needed + alloc_state->log_area_count_still_needed))) {
+				log_error("Breaking: preferred_count = %d, ix_offset = %d, devices_needed = %d", preferred_count, ix_offset, devices_needed);
 				break;
+			}
 		}
-	} while ((alloc_parms->alloc == ALLOC_ANYWHERE && last_ix != ix && ix < ah->area_count + alloc_state->log_area_count_still_needed) ||
+	} while ((alloc_parms->alloc == ALLOC_ANYWHERE && last_ix != ix && ix < devices_needed + alloc_state->log_area_count_still_needed) ||
 		/* With cling_to_alloced, if there were gaps in the preferred areas, have a second iteration */
 		 (alloc_parms->alloc == ALLOC_NORMAL && preferred_count &&
 		  (preferred_count < ix_offset || alloc_state->log_area_count_still_needed) &&
 		  (alloc_parms->flags & A_CLING_TO_ALLOCED) && !iteration_count++) ||
 		/* Extra iteration needed to fill log areas on PVs already used? */
 		 (alloc_parms->alloc == ALLOC_NORMAL && preferred_count == ix_offset && !ah->mirror_logs_separate &&
-		  (ix + preferred_count >= ah->area_count) && 
-		  (ix + preferred_count < ah->area_count + alloc_state->log_area_count_still_needed) && !log_iteration_count++));
+		  (ix + preferred_count >= devices_needed) &&
+		  (ix + preferred_count < devices_needed + alloc_state->log_area_count_still_needed) && !log_iteration_count++));
 
 	if (preferred_count < ix_offset && !(alloc_parms->flags & A_CLING_TO_ALLOCED))
 		return 1;
 
-	if (ix + preferred_count < ah->area_count + alloc_state->log_area_count_still_needed)
+	if (ix + preferred_count < devices_needed + alloc_state->log_area_count_still_needed)
 		return 1;
 
 	/* Sort the areas so we allocate from the biggest */
 	if (log_iteration_count) {
-		if (ix > ah->area_count + 1) {
-			log_debug("Sorting %u log areas", ix - ah->area_count);
-			qsort(alloc_state->areas + ah->area_count, ix - ah->area_count, sizeof(*alloc_state->areas),
+		if (ix > devices_needed + 1) {
+			log_debug("Sorting %u log areas", ix - devices_needed);
+			qsort(alloc_state->areas + devices_needed, ix - devices_needed, sizeof(*alloc_state->areas),
 			      _comp_area);
 		}
 	} else if (ix > 1) {
@@ -1584,7 +1709,7 @@
 
 	/* If there are gaps in our preferred areas, fill then from the sorted part of the array */
 	if (preferred_count && preferred_count != ix_offset) {
-		for (s = 0; s < ah->area_count; s++)
+		for (s = 0; s < devices_needed; s++)
 			if (!alloc_state->areas[s].pva) {
 				alloc_state->areas[s].pva = alloc_state->areas[ix_offset].pva;
 				alloc_state->areas[s].used = alloc_state->areas[ix_offset].used;
@@ -1609,7 +1734,7 @@
 		ix_log_offset = ix_offset + ix - too_small_for_log_count - ah->log_area_count;
 	}
 
-	if (ix + ix_offset < ah->area_count +
+	if (ix + ix_offset < devices_needed +
 	    (alloc_state->log_area_count_still_needed ? alloc_state->log_area_count_still_needed +
 				    too_small_for_log_count : 0))
 		return 1;
@@ -1741,14 +1866,15 @@
 		stack;
 
 	alloc_state.areas_size = dm_list_size(pvms);
-	if (alloc_state.areas_size && alloc_state.areas_size < (ah->area_count + ah->log_area_count)) {
+	if (alloc_state.areas_size &&
+	    alloc_state.areas_size < (ah->area_count + ah->parity_count + ah->log_area_count)) {
 		if (ah->alloc != ALLOC_ANYWHERE && ah->mirror_logs_separate) {
 			log_error("Not enough PVs with free space available "
 				  "for parallel allocation.");
 			log_error("Consider --alloc anywhere if desperate.");
 			return 0;
 		}
-		alloc_state.areas_size = ah->area_count + ah->log_area_count;
+		alloc_state.areas_size = ah->area_count + ah->parity_count + ah->log_area_count;
 	}
 
 	/* Upper bound if none of the PVs in prev_lvseg is in pvms */
@@ -1780,7 +1906,9 @@
 		if (!_sufficient_pes_free(ah, pvms, alloc_state.allocated, ah->new_extents))
 			goto_out;
 
-		_init_alloc_parms(ah, &alloc_parms, alloc, prev_lvseg, can_split, alloc_state.allocated, ah->new_extents);
+		_init_alloc_parms(ah, &alloc_parms, alloc, prev_lvseg,
+				  can_split, alloc_state.allocated,
+				  ah->new_extents);
 
 		if (!_find_max_parallel_space_for_one_policy(ah, &alloc_parms, pvms, &alloc_state))
 			goto_out;
@@ -2119,12 +2247,13 @@
 
 static int _lv_insert_empty_sublvs(struct logical_volume *lv,
 				   const struct segment_type *segtype,
-				   uint32_t region_size,
+				   uint32_t stripe_size, uint32_t region_size,
 				   uint32_t devices)
 {
 	struct logical_volume *sub_lv;
 	uint32_t i;
 	uint64_t status = 0;
+	const char *layer_name;
 	size_t len = strlen(lv->name) + 32;
 	char img_name[len];
 	struct lv_segment *mapseg;
@@ -2135,15 +2264,22 @@
 		return 0;
 	}
 
-	if (!segtype_is_mirrored(segtype))
+	if (segtype_is_raid(segtype)) {
+		lv->status |= RAID;
+		status = RAID_IMAGE;
+		layer_name = "rimage";
+	} else if (segtype_is_mirrored(segtype)) {
+		lv->status |= MIRRORED;
+		status = MIRROR_IMAGE;
+		layer_name = "mimage";
+	} else
 		return_0;
-	lv->status |= MIRRORED;
 
 	/*
 	 * First, create our top-level segment for our top-level LV
 	 */
 	if (!(mapseg = alloc_lv_segment(lv->vg->cmd->mem, segtype,
-					lv, 0, 0, lv->status, 0, NULL,
+					lv, 0, 0, lv->status, stripe_size, NULL,
 					devices, 0, 0, region_size, 0, NULL))) {
 		log_error("Failed to create mapping segment for %s", lv->name);
 		return 0;
@@ -2152,17 +2288,34 @@
 	/*
 	 * Next, create all of our sub_lv's and link them in.
 	 */
-	if (dm_snprintf(img_name, len, "%s%s", lv->name, "_mimage_%d") < 0)
-		return_0;
-
 	for (i = 0; i < devices; i++) {
+		/* Data LVs */
+		if (dm_snprintf(img_name, len, "%s_%s_%u",
+				lv->name, layer_name, i) < 0)
+			return_0;
+
 		sub_lv = lv_create_empty(img_name, NULL,
-					 LVM_READ | LVM_WRITE | MIRROR_IMAGE,
+					 LVM_READ | LVM_WRITE | status,
 					 lv->alloc, lv->vg);
+
 		if (!sub_lv)
 			return_0;
 		if (!set_lv_segment_area_lv(mapseg, i, sub_lv, 0, status))
 			return_0;
+		if (!segtype_is_raid(segtype))
+			continue;
+
+		/* RAID meta LVs */
+		if (dm_snprintf(img_name, len, "%s_rmeta_%u", lv->name, i) < 0)
+			return_0;
+
+		sub_lv = lv_create_empty(img_name, NULL,
+					 LVM_READ | LVM_WRITE | RAID_META,
+					 lv->alloc, lv->vg);
+		if (!sub_lv)
+			return_0;
+		if (!set_lv_segment_area_lv(mapseg, i, sub_lv, 0, RAID_META))
+			return_0;
 	}
 	dm_list_add(&lv->segments, &mapseg->list);
 
@@ -2174,31 +2327,101 @@
 				 uint32_t extents, uint32_t first_area,
 				 uint32_t stripes, uint32_t stripe_size)
 {
-	struct logical_volume *sub_lv;
+	const struct segment_type *segtype;
+	struct logical_volume *sub_lv, *meta_lv;
 	struct lv_segment *seg;
-	uint32_t m, s;
+	uint32_t fa, s;
+	int clear_metadata = 0;
+
+	segtype = get_segtype_from_string(lv->vg->cmd, "striped");
+
+	/*
+	 * The component devices of a "striped" LV all go in the same
+	 * LV.  However, RAID has an LV for each device - making the
+	 * 'stripes' and 'stripe_size' parameters meaningless.
+	 */
+	if (seg_is_raid(first_seg(lv))) {
+		stripes = 1;
+		stripe_size = 0;
+	}
 
 	seg = first_seg(lv);
-	for (m = first_area, s = 0; s < seg->area_count; s++) {
+	for (fa = first_area, s = 0; s < seg->area_count; s++) {
 		if (is_temporary_mirror_layer(seg_lv(seg, s))) {
 			if (!_lv_extend_layered_lv(ah, seg_lv(seg, s), extents,
-						   m, stripes, stripe_size))
+						   fa, stripes, stripe_size))
 				return_0;
-			m += lv_mirror_count(seg_lv(seg, s));
+			fa += lv_mirror_count(seg_lv(seg, s));
 			continue;
 		}
 
 		sub_lv = seg_lv(seg, s);
-		if (!lv_add_segment(ah, m, stripes, sub_lv,
-				    get_segtype_from_string(lv->vg->cmd,
-							    "striped"),
+		if (!lv_add_segment(ah, fa, stripes, sub_lv, segtype,
 				    stripe_size, sub_lv->status, 0)) {
 			log_error("Aborting. Failed to extend %s in %s.",
 				  sub_lv->name, lv->name);
 			return 0;
 		}
-		m += stripes;
+
+		/* Extend metadata LVs only on initial creation */
+		if (seg_is_raid(seg) && !lv->le_count) {
+			if (!seg->meta_areas) {
+				log_error("No meta_areas for RAID type");
+				return 0;
+			}
+
+			meta_lv = seg_metalv(seg, s);
+			if (!lv_add_segment(ah, fa + seg->area_count, 1,
+					    meta_lv, segtype, 0,
+					    meta_lv->status, 0)) {
+				log_error("Failed to extend %s in %s.",
+					  meta_lv->name, lv->name);
+				return 0;
+			}
+			lv_set_visible(meta_lv);
+			clear_metadata = 1;
+		}
+
+		fa += stripes;
 	}
+
+	if (clear_metadata) {
+		/*
+		 * We must clear the metadata areas upon creation.
+		 */
+		if (!vg_write(meta_lv->vg) || !vg_commit(meta_lv->vg))
+			return_0;
+
+		for (s = 0; s < seg->area_count; s++) {
+			meta_lv = seg_metalv(seg, s);
+			if (!activate_lv(meta_lv->vg->cmd, meta_lv)) {
+				log_error("Failed to activate %s/%s for clearing",
+					  meta_lv->vg->name, meta_lv->name);
+				return 0;
+			}
+
+			log_verbose("Clearing metadata area of %s/%s",
+				    meta_lv->vg->name, meta_lv->name);
+			/*
+			 * Rather than wiping meta_lv->size, we can simply
+			 * wipe '1' to remove the superblock of any previous
+			 * RAID devices.  It is much quicker.
+			 */
+			if (!set_lv(meta_lv->vg->cmd, meta_lv, 1, 0)) {
+				log_error("Failed to zero %s/%s",
+					  meta_lv->vg->name, meta_lv->name);
+				return 0;
+			}
+
+			if (!deactivate_lv(meta_lv->vg->cmd, meta_lv)) {
+				log_error("Failed to deactivate %s/%s",
+					  meta_lv->vg->name, meta_lv->name);
+				return 0;
+			}
+			lv_set_hidden(meta_lv);
+		}
+	}
+
 	seg->area_len += extents;
 	seg->len += extents;
 	lv->le_count += extents;
@@ -2218,22 +2441,40 @@
 	      struct dm_list *allocatable_pvs, alloc_policy_t alloc)
 {
 	int r = 1;
+	int raid_logs = 0;
 	struct alloc_handle *ah;
+	uint32_t dev_count = mirrors * stripes + segtype->parity_devs;
+
+	log_very_verbose("Extending segment type, %s", segtype->name);
 
 	if (segtype_is_virtual(segtype))
 		return lv_add_virtual_segment(lv, 0u, extents, segtype);
 
-	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors, 0, 0,
-				    extents, allocatable_pvs, alloc, NULL)))
+	if (segtype_is_raid(segtype) && !lv->le_count)
+		raid_logs = mirrors * stripes;
+
+	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors,
+				    raid_logs, region_size, extents,
+				    allocatable_pvs, alloc, NULL)))
 		return_0;
 
-	if (!segtype_is_mirrored(segtype))
+	if (!segtype_is_mirrored(segtype) && !segtype_is_raid(segtype))
 		r = lv_add_segment(ah, 0, ah->area_count, lv, segtype,
 				   stripe_size, 0u, 0);
 	else {
+		/*
+		 * For RAID, all the devices are AREA_LV.
+		 * However, for 'mirror on stripe' using non-RAID targets,
+		 * the mirror legs are AREA_LV while the stripes underneath
+		 * are AREA_PV.  So if this is not RAID, reset dev_count to
+		 * just 'mirrors' - the necessary sub_lv count.
+		 */
+		if (!segtype_is_raid(segtype))
+			dev_count = mirrors;
+
 		if (!lv->le_count &&
-		    !_lv_insert_empty_sublvs(lv, segtype,
-					     region_size, mirrors)) {
+		    !_lv_insert_empty_sublvs(lv, segtype, stripe_size,
+					     region_size, dev_count)) {
 			log_error("Failed to insert layer for %s", lv->name);
 			alloc_destroy(ah);
 			return 0;
@@ -2707,6 +2948,12 @@
 		return 0;
 	}
 
+	if (lv->status & (RAID_META | RAID_IMAGE)) {
+		log_error("Can't remove logical volume %s used as RAID device",
+			  lv->name);
+		return 0;
+	}
+
 	if (lv->status & LOCKED) {
 		log_error("Can't remove locked LV %s", lv->name);
 		return 0;
@@ -3498,8 +3745,11 @@
 		return 0;
 	}
 
-	if (lp->mirrors > 1 && !(vg->fid->fmt->features & FMT_SEGMENTS)) {
-		log_error("Metadata does not support mirroring.");
+	if ((segtype_is_mirrored(lp->segtype) ||
+	     segtype_is_raid(lp->segtype)) &&
+	    !(vg->fid->fmt->features & FMT_SEGMENTS)) {
+		log_error("Metadata does not support %s.",
+			  segtype_is_raid(lp->segtype) ? "RAID" : "mirroring");
 		return 0;
 	}
 
@@ -3632,9 +3882,12 @@
 		return 0;
 	}
 
-	if (lp->mirrors > 1 && !activation()) {
-		log_error("Can't create mirror without using "
-			  "device-mapper kernel driver.");
+	if ((segtype_is_mirrored(lp->segtype) ||
+	     segtype_is_raid(lp->segtype)) && !activation()) {
+		log_error("Can't create %s without using "
+			  "device-mapper kernel driver.",
+			  segtype_is_raid(lp->segtype) ? lp->segtype->name :
+			  "mirror");
 		return 0;
 	}
 
@@ -3654,18 +3907,15 @@
 		}
 	}
 
-	if (lp->mirrors > 1) {
+	if (segtype_is_mirrored(lp->segtype) || segtype_is_raid(lp->segtype)) {
 		init_mirror_in_sync(lp->nosync);
 
 		if (lp->nosync) {
-			log_warn("WARNING: New mirror won't be synchronised. "
-				  "Don't read what you didn't write!");
+			log_warn("WARNING: New %s won't be synchronised. "
+				 "Don't read what you didn't write!",
+				 lp->segtype->name);
 			status |= LV_NOTSYNCED;
 		}
-
-		lp->segtype = get_segtype_from_string(cmd, "mirror");
-		if (!lp->segtype)
-			return_0;
 	}
 
 	if (!(lv = lv_create_empty(lp->lv_name ? lp->lv_name : "lvol%d", NULL,
@@ -3688,15 +3938,18 @@
 	if (!dm_list_empty(&lp->tags))
 		dm_list_splice(&lv->tags, &lp->tags);
 
-	if (!lv_extend(lv, lp->segtype, lp->stripes, lp->stripe_size,
-		       lp->mirrors,
-		       adjusted_mirror_region_size(vg->extent_size,
-						   lp->extents,
-						   lp->region_size),
+	lp->region_size = adjusted_mirror_region_size(vg->extent_size,
+						      lp->extents,
+						      lp->region_size);
+
+	if (!lv_extend(lv, lp->segtype,
+		       lp->stripes, lp->stripe_size,
+		       lp->mirrors, lp->region_size,
 		       lp->extents, lp->pvh, lp->alloc))
 		return_0;
 
-	if ((lp->mirrors > 1) && lp->log_count) {
+	if (lp->log_count &&
+	    !seg_is_raid(first_seg(lv)) && seg_is_mirrored(first_seg(lv))) {
 		if (!add_mirror_log(cmd, lv, lp->log_count,
 				    first_seg(lv)->region_size,
 				    lp->pvh, lp->alloc)) {
--- LVM2/lib/metadata/merge.c	2011/06/09 19:36:16	1.44
+++ LVM2/lib/metadata/merge.c	2011/08/02 22:07:22	1.45
@@ -94,18 +94,22 @@
 			inc_error_count;
 		}
 
-		if (complete_vg && seg->log_lv) {
-			if (!seg_is_mirrored(seg)) {
-				log_error("LV %s: segment %u has log LV but "
-					  "is not mirrored",
-					  lv->name, seg_count);
-				inc_error_count;
-			}
+		if (complete_vg && seg->log_lv &&
+		    !seg_is_mirrored(seg) && !(seg->status & RAID_IMAGE)) {
+			log_error("LV %s: segment %u log LV %s is not a "
+				  "mirror log or a RAID image",
+				  lv->name, seg_count, seg->log_lv->name);
+			inc_error_count;
+		}
 
+		/*
+		 * Check mirror log - which is attached to the mirrored seg
+		 */
+		if (complete_vg && seg->log_lv && seg_is_mirrored(seg)) {
 			if (!(seg->log_lv->status & MIRROR_LOG)) {
 				log_error("LV %s: segment %u log LV %s is not "
 					  "a mirror log",
-					   lv->name, seg_count, seg->log_lv->name);
+					  lv->name, seg_count, seg->log_lv->name);
 				inc_error_count;
 			}
 
@@ -113,7 +117,7 @@
 			    find_mirror_seg(seg2) != seg) {
 				log_error("LV %s: segment %u log LV does not "
 					  "point back to mirror segment",
-					   lv->name, seg_count);
+					  lv->name, seg_count);
 				inc_error_count;
 			}
 		}
@@ -189,6 +193,7 @@
 				dm_list_iterate_items(sl, &seg_lv(seg, s)->segs_using_this_lv)
 					if (sl->seg == seg)
 						seg_found++;
+
 				if (!seg_found) {
 					log_error("LV %s segment %d uses LV %s,"
 						  " but missing ptr from %s to %s",
@@ -205,7 +210,8 @@
 				}
 			}
 
-			if (complete_vg && seg_is_mirrored(seg) &&
+			if (complete_vg &&
+			    seg_is_mirrored(seg) && !seg_is_raid(seg) &&
 			    seg_type(seg, s) == AREA_LV &&
 			    seg_lv(seg, s)->le_count != seg->area_len) {
 				log_error("LV %s: mirrored LV segment %u has "
@@ -227,6 +233,8 @@
 				continue;
 			if (lv == seg_lv(seg, s))
 				seg_found++;
+			if (seg_is_raid(seg) && (lv == seg_metalv(seg, s)))
+				seg_found++;
 		}
 		if (seg_is_replicator_dev(seg)) {
 			dm_list_iterate_items(rsite, &seg->replicator->rsites) {
--- LVM2/lib/metadata/metadata-exported.h	2011/06/17 14:30:58	1.194
+++ LVM2/lib/metadata/metadata-exported.h	2011/08/02 22:07:22	1.195
@@ -46,6 +46,14 @@
 #define EXPORTED_VG          	0x00000002U	/* VG PV */
 #define RESIZEABLE_VG        	0x00000004U	/* VG */
 
+/*
+ * Since the RAID flags are LV (and seg) only and the above three
+ * are VG/PV only, these flags are reused.
+ */
+#define RAID                    0x00000001U	/* LV */
+#define RAID_META               0x00000002U	/* LV */
+#define RAID_IMAGE              0x00000004U	/* LV */
+
 /* May any free extents on this PV be used or must they be left free? */
 #define ALLOCATABLE_PV         	0x00000008U	/* PV */
 
@@ -293,7 +301,7 @@
 	uint64_t status;
 
 	/* FIXME Fields depend on segment type */
-	uint32_t stripe_size;
+	uint32_t stripe_size;   /* For stripe and RAID - in sectors */
 	uint32_t area_count;
 	uint32_t area_len;
 	uint32_t chunk_size;	/* For snapshots - in sectors */
@@ -309,6 +317,7 @@
 	struct dm_list tags;
 
 	struct lv_segment_area *areas;
+	struct lv_segment_area *meta_areas; /* For RAID */
 
 	struct logical_volume *replicator;/* For replicator-devs - link to replicator LV */
 	struct logical_volume *rlog_lv;	/* For replicators */
@@ -320,6 +329,7 @@
 #define seg_type(seg, s)	(seg)->areas[(s)].type
 #define seg_pv(seg, s)		(seg)->areas[(s)].u.pv.pvseg->pv
 #define seg_lv(seg, s)		(seg)->areas[(s)].u.lv.lv
+#define seg_metalv(seg, s)	(seg)->meta_areas[(s)].u.lv.lv
 
 struct pe_range {
 	struct dm_list list;
--- LVM2/lib/metadata/metadata.h	2011/06/30 18:25:18	1.247
+++ LVM2/lib/metadata/metadata.h	2011/08/02 22:07:22	1.248
@@ -233,6 +233,7 @@
 #define seg_dev(seg, s)		(seg)->areas[(s)].u.pv.pvseg->pv->dev
 #define seg_pe(seg, s)		(seg)->areas[(s)].u.pv.pvseg->pe
 #define seg_le(seg, s)		(seg)->areas[(s)].u.lv.le
+#define seg_metale(seg, s)	(seg)->meta_areas[(s)].u.lv.le
 
 struct name_list {
 	struct dm_list list;
--- LVM2/lib/metadata/segtype.h	2011/06/17 14:14:20	1.35
+++ LVM2/lib/metadata/segtype.h	2011/08/02 22:07:22	1.36
@@ -38,6 +38,7 @@
 #define SEG_MONITORED		0x00000080U
 #define SEG_REPLICATOR		0x00000100U
 #define SEG_REPLICATOR_DEV	0x00000200U
+#define SEG_RAID		0x00000400U
 #define SEG_UNKNOWN		0x80000000U
 
 #define seg_is_mirrored(seg)	((seg)->segtype->flags & SEG_AREAS_MIRRORED ? 1 : 0)
@@ -46,6 +47,7 @@
 #define seg_is_striped(seg)	((seg)->segtype->flags & SEG_AREAS_STRIPED ? 1 : 0)
 #define seg_is_snapshot(seg)	((seg)->segtype->flags & SEG_SNAPSHOT ? 1 : 0)
 #define seg_is_virtual(seg)	((seg)->segtype->flags & SEG_VIRTUAL ? 1 : 0)
+#define seg_is_raid(seg)	((seg)->segtype->flags & SEG_RAID ? 1 : 0)
 #define seg_can_split(seg)	((seg)->segtype->flags & SEG_CAN_SPLIT ? 1 : 0)
 #define seg_cannot_be_zeroed(seg) ((seg)->segtype->flags & SEG_CANNOT_BE_ZEROED ? 1 : 0)
 #define seg_monitored(seg)	((seg)->segtype->flags & SEG_MONITORED ? 1 : 0)
@@ -53,14 +55,19 @@
 
 #define segtype_is_striped(segtype)	((segtype)->flags & SEG_AREAS_STRIPED ? 1 : 0)
 #define segtype_is_mirrored(segtype)	((segtype)->flags & SEG_AREAS_MIRRORED ? 1 : 0)
+#define segtype_is_raid(segtype)	((segtype)->flags & SEG_RAID ? 1 : 0)
 #define segtype_is_virtual(segtype)	((segtype)->flags & SEG_VIRTUAL ? 1 : 0)
 
 struct segment_type {
 	struct dm_list list;		/* Internal */
 	struct cmd_context *cmd;	/* lvm_register_segtype() sets this. */
+
 	uint32_t flags;
+	uint32_t parity_devs;           /* Parity drives required by segtype */
+
 	struct segtype_handler *ops;
 	const char *name;
+
 	void *library;			/* lvm_register_segtype() sets this. */
 	void *private;			/* For the segtype handler to use. */
 };
@@ -117,7 +124,21 @@
 struct segment_type *init_zero_segtype(struct cmd_context *cmd);
 struct segment_type *init_error_segtype(struct cmd_context *cmd);
 struct segment_type *init_free_segtype(struct cmd_context *cmd);
-struct segment_type *init_unknown_segtype(struct cmd_context *cmd, const char *name);
+struct segment_type *init_unknown_segtype(struct cmd_context *cmd,
+					  const char *name);
+#ifdef RAID_INTERNAL
+struct segment_type *init_raid1_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid4_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid5_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid5_la_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid5_ra_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid5_ls_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid5_rs_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid6_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid6_zr_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid6_nr_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid6_nc_segtype(struct cmd_context *cmd);
+#endif
 
 #ifdef REPLICATOR_INTERNAL
 int init_replicator_segtype(struct segtype_library *seglib);
--- LVM2/lib/misc/configure.h.in	2011/02/04 22:17:55	1.32
+++ LVM2/lib/misc/configure.h.in	2011/08/02 22:07:22	1.33
@@ -493,6 +493,9 @@
 /* Define to 1 to include built-in support for GFS pool metadata. */
 #undef POOL_INTERNAL
 
+/* Define to 1 to include built-in support for raid. */
+#undef RAID_INTERNAL
+
 /* Define to 1 to include the LVM readline shell. */
 #undef READLINE_SUPPORT
 
--- LVM2/lib/misc/lvm-string.c	2011/04/08 14:40:20	1.27
+++ LVM2/lib/misc/lvm-string.c	2011/08/02 22:07:22	1.28
@@ -361,6 +361,18 @@
 		return 0;
 	}
 
+	if (strstr(name, "_rimage")) {
+		log_error("Names including \"_rimage\" are reserved. "
+			  "Please choose a different LV name.");
+		return 0;
+	}
+
+	if (strstr(name, "_rmeta")) {
+		log_error("Names including \"_rmeta\" are reserved. "
+			  "Please choose a different LV name.");
+		return 0;
+	}
+
 	if (strstr(name, "_vorigin")) {
 		log_error("Names including \"_vorigin\" are reserved. "
 			  "Please choose a different LV name.");
/cvs/lvm2/LVM2/lib/raid/raid.c,v  -->  standard output
revision 1.1
--- LVM2/lib/raid/raid.c
+++ -	2011-08-02 22:07:26.054169000 +0000
@@ -0,0 +1,352 @@
+/*
+ * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lib.h"
+#include "toolcontext.h"
+#include "segtype.h"
+#include "display.h"
+#include "text_export.h"
+#include "text_import.h"
+#include "config.h"
+#include "str_list.h"
+#include "targets.h"
+#include "lvm-string.h"
+#include "activate.h"
+#include "metadata.h"
+#include "lv_alloc.h"
+
+static const char *_raid_name(const struct lv_segment *seg)
+{
+	return seg->segtype->name;
+}
+
+static int _raid_text_import_area_count(const struct config_node *sn,
+					uint32_t *area_count)
+{
+	if (!get_config_uint32(sn, "device_count", area_count)) {
+		log_error("Couldn't read 'device_count' for "
+			  "segment '%s'.", config_parent_name(sn));
+		return 0;
+	}
+	return 1;
+}
+
+static int
+_raid_text_import_areas(struct lv_segment *seg, const struct config_node *sn,
+			const struct config_node *cn)
+{
+	unsigned int s;
+	const struct config_value *cv;
+	struct logical_volume *lv1;
+	const char *seg_name = config_parent_name(sn);
+
+	if (!seg->area_count) {
+		log_error("No areas found for segment %s", seg_name);
+		return 0;
+	}
+
+	for (cv = cn->v, s = 0; cv && s < seg->area_count; s++, cv = cv->next) {
+		if (cv->type != CFG_STRING) {
+			log_error("Bad volume name in areas array for segment %s.", seg_name);
+			return 0;
+		}
+
+		if (!cv->next) {
+			log_error("Missing data device in areas array for segment %s.", seg_name);
+			return 0;
+		}
+
+		/* Metadata device comes first */
+		if (!(lv1 = find_lv(seg->lv->vg, cv->v.str))) {
+			log_error("Couldn't find volume '%s' for segment '%s'.",
+				  cv->v.str ? : "NULL", seg_name);
+			return 0;
+		}
+		if (!set_lv_segment_area_lv(seg, s, lv1, 0, RAID_META))
+				return_0;
+
+		/* Data device comes second */
+		cv = cv->next;
+		if (!(lv1 = find_lv(seg->lv->vg, cv->v.str))) {
+			log_error("Couldn't find volume '%s' for segment '%s'.",
+				  cv->v.str ? : "NULL", seg_name);
+			return 0;
+		}
+		if (!set_lv_segment_area_lv(seg, s, lv1, 0, RAID_IMAGE))
+				return_0;
+	}
+
+	/*
+	 * Check we read the correct number of RAID data/meta pairs.
+	 */
+	if (cv || (s < seg->area_count)) {
+		log_error("Incorrect number of areas in area array "
+			  "for segment '%s'.", seg_name);
+		return 0;
+	}
+
+	return 1;
+}
+
+static int
+_raid_text_import(struct lv_segment *seg, const struct config_node *sn,
+		  struct dm_hash_table *pv_hash)
+{
+	const struct config_node *cn;
+
+	if (find_config_node(sn, "region_size")) {
+		if (!get_config_uint32(sn, "region_size", &seg->region_size)) {
+			log_error("Couldn't read 'region_size' for "
+				  "segment %s of logical volume %s.",
+				  config_parent_name(sn), seg->lv->name);
+			return 0;
+		}
+	}
+	if (find_config_node(sn, "stripe_size")) {
+		if (!get_config_uint32(sn, "stripe_size", &seg->stripe_size)) {
+			log_error("Couldn't read 'stripe_size' for "
+				  "segment %s of logical volume %s.",
+				  config_parent_name(sn), seg->lv->name);
+			return 0;
+		}
+	}
+	if (!(cn = find_config_node(sn, "raids"))) {
+		log_error("Couldn't find RAID array for "
+			  "segment %s of logical volume %s.",
+			  config_parent_name(sn), seg->lv->name);
+		return 0;
+	}
+
+	if (!_raid_text_import_areas(seg, sn, cn)) {
+		log_error("Failed to import RAID images");
+		return 0;
+	}
+
+	seg->status |= RAID;
+
+	return 1;
+}
+
+static int
+_raid_text_export(const struct lv_segment *seg, struct formatter *f)
+{
+	outf(f, "device_count = %u", seg->area_count);
+	if (seg->region_size)
+		outf(f, "region_size = %" PRIu32, seg->region_size);
+	if (seg->stripe_size)
+		outf(f, "stripe_size = %" PRIu32, seg->stripe_size);
+
+	return out_areas(f, seg, "raid");
+}
+
+static int
+_raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
+		      struct dm_pool *mem __attribute__((unused)),
+		      struct cmd_context *cmd __attribute__((unused)),
+		      void **target_state __attribute__((unused)),
+		      struct lv_segment *seg,
+		      const struct lv_activate_opts *laopts __attribute__((unused)),
+		      struct dm_tree_node *node, uint64_t len,
+		      uint32_t *pvmove_mirror_count __attribute__((unused)))
+{
+	if (!seg->area_count) {
+		log_error(INTERNAL_ERROR "_raid_add_target_line called "
+			  "with no areas for %s.", seg->lv->name);
+		return 0;
+	}
+
+	if (!seg->region_size) {
+		log_error("Missing region size for mirror segment.");
+		return 0;
+	}
+
+	if (!dm_tree_node_add_raid_target(node, len, _raid_name(seg),
+					  seg->region_size, seg->stripe_size,
+					  0, 0))
+		return_0;
+
+	return add_areas_line(dm, seg, node, 0u, seg->area_count);
+}
+
+static int _raid_target_status_compatible(const char *type)
+{
+	return (strstr(type, "raid") != NULL);
+}
+
+static int _raid_target_percent(void **target_state,
+				percent_t *percent,
+				struct dm_pool *mem,
+				struct cmd_context *cmd,
+				struct lv_segment *seg, char *params,
+				uint64_t *total_numerator,
+				uint64_t *total_denominator)
+{
+	int i;
+	uint64_t numerator, denominator;
+	char *pos = params;
+	/*
+	 * Status line:
+	 *    <raid_type> <#devs> <status_chars> <synced>/<total>
+	 * Example:
+	 *    raid1 2 AA 1024000/1024000
+	 */
+	for (i = 0; i < 3; i++) {
+		pos = strstr(pos, " ");
+		if (pos)
+			pos++;
+		else
+			break;
+	}
+	if (!pos || (sscanf(pos, "%" PRIu64 "/%" PRIu64 "%n",
+			    &numerator, &denominator, &i) != 2)) {
+		log_error("Failed to parse %s status fraction: %s",
+			  seg->segtype->name, params);
+		return 0;
+	}
+
+	*total_numerator += numerator;
+	*total_denominator += denominator;
+
+	if (seg)
+		seg->extents_copied = seg->area_len * numerator / denominator;
+
+	*percent = make_percent(numerator, denominator);
+
+	return 1;
+}
+
+
+static int
+_raid_target_present(struct cmd_context *cmd,
+		     const struct lv_segment *seg __attribute__((unused)),
+		     unsigned *attributes __attribute__((unused)))
+{
+	static int _raid_checked = 0;
+	static int _raid_present = 0;
+
+	if (!_raid_checked)
+		_raid_present = target_present(cmd, "raid", 1);
+
+	_raid_checked = 1;
+
+	return _raid_present;
+}
+
+static int
+_raid_modules_needed(struct dm_pool *mem,
+		     const struct lv_segment *seg __attribute__((unused)),
+		     struct dm_list *modules)
+{
+	if (!str_list_add(mem, modules, "raid")) {
+		log_error("raid module string list allocation failed");
+		return 0;
+	}
+
+	return 1;
+}
+
+static void _raid_destroy(struct segment_type *segtype)
+{
+	dm_free((void *) segtype);
+}
+
+static struct segtype_handler _raid_ops = {
+	.name = _raid_name,
+	.text_import_area_count = _raid_text_import_area_count,
+	.text_import = _raid_text_import,
+	.text_export = _raid_text_export,
+	.add_target_line = _raid_add_target_line,
+	.target_status_compatible = _raid_target_status_compatible,
+	.target_percent = _raid_target_percent,
+	.target_present = _raid_target_present,
+	.modules_needed = _raid_modules_needed,
+	.destroy = _raid_destroy,
+};
+
+static struct segment_type *init_raid_segtype(struct cmd_context *cmd,
+					      const char *raid_type)
+{
+	struct segment_type *segtype = dm_malloc(sizeof(*segtype));
+
+	if (!segtype)
+		return_NULL;
+
+	segtype->cmd = cmd;
+
+	segtype->flags = SEG_RAID;
+	segtype->parity_devs = strstr(raid_type, "raid6") ? 2 : 1;
+
+	segtype->ops = &_raid_ops;
+	segtype->name = raid_type;
+
+	segtype->private = NULL;
+
+	log_very_verbose("Initialised segtype: %s", segtype->name);
+
+	return segtype;
+}
+
+struct segment_type *init_raid1_segtype(struct cmd_context *cmd)
+{
+	struct segment_type *segtype;
+
+	segtype = init_raid_segtype(cmd, "raid1");
+	if (!segtype)
+		return NULL;
+
+	segtype->flags |= SEG_AREAS_MIRRORED;
+	segtype->parity_devs = 0;
+
+	return segtype;
+}
+struct segment_type *init_raid4_segtype(struct cmd_context *cmd)
+{
+	return init_raid_segtype(cmd, "raid4");
+}
+struct segment_type *init_raid5_segtype(struct cmd_context *cmd)
+{
+	return init_raid_segtype(cmd, "raid5");
+}
+struct segment_type *init_raid5_la_segtype(struct cmd_context *cmd)
+{
+	return init_raid_segtype(cmd, "raid5_la");
+}
+struct segment_type *init_raid5_ra_segtype(struct cmd_context *cmd)
+{
+	return init_raid_segtype(cmd, "raid5_ra");
+}
+struct segment_type *init_raid5_ls_segtype(struct cmd_context *cmd)
+{
+	return init_raid_segtype(cmd, "raid5_ls");
+}
+struct segment_type *init_raid5_rs_segtype(struct cmd_context *cmd)
+{
+	return init_raid_segtype(cmd, "raid5_rs");
+}
+struct segment_type *init_raid6_segtype(struct cmd_context *cmd)
+{
+	return init_raid_segtype(cmd, "raid6");
+}
+struct segment_type *init_raid6_zr_segtype(struct cmd_context *cmd)
+{
+	return init_raid_segtype(cmd, "raid6_zr");
+}
+struct segment_type *init_raid6_nr_segtype(struct cmd_context *cmd)
+{
+	return init_raid_segtype(cmd, "raid6_nr");
+}
+struct segment_type *init_raid6_nc_segtype(struct cmd_context *cmd)
+{
+	return init_raid_segtype(cmd, "raid6_nc");
+}
--- LVM2/libdm/libdevmapper.h	2011/07/01 14:09:20	1.139
+++ LVM2/libdm/libdevmapper.h	2011/08/02 22:07:23	1.140
@@ -467,6 +467,14 @@
 					  unsigned area_count,
 					  uint32_t flags);
 
+int dm_tree_node_add_raid_target(struct dm_tree_node *node,
+				 uint64_t size,
+				 const char *raid_type,
+				 uint32_t region_size,
+				 uint32_t stripe_size,
+				 uint64_t reserved1,
+				 uint64_t reserved2);
+
 /*
  * Replicator operation mode
  * Note: API for Replicator is not yet stable
--- LVM2/libdm/libdm-deptree.c	2011/07/08 19:13:05	1.102
+++ LVM2/libdm/libdm-deptree.c	2011/08/02 22:07:23	1.103
@@ -42,6 +42,16 @@
 	SEG_SNAPSHOT_MERGE,
 	SEG_STRIPED,
 	SEG_ZERO,
+	SEG_RAID1,
+	SEG_RAID4,
+	SEG_RAID5_LA,
+	SEG_RAID5_RA,
+	SEG_RAID5_LS,
+	SEG_RAID5_RS,
+	SEG_RAID6_ZR,
+	SEG_RAID6_NR,
+	SEG_RAID6_NC,
+	SEG_LAST,
 };
 
 /* FIXME Add crypt and multipath support */
@@ -61,6 +71,18 @@
 	{ SEG_SNAPSHOT_MERGE, "snapshot-merge" },
 	{ SEG_STRIPED, "striped" },
 	{ SEG_ZERO, "zero"},
+	{ SEG_RAID1, "raid1"},
+	{ SEG_RAID4, "raid4"},
+	{ SEG_RAID5_LA, "raid5_la"},
+	{ SEG_RAID5_RA, "raid5_ra"},
+	{ SEG_RAID5_LS, "raid5_ls"},
+	{ SEG_RAID5_RS, "raid5_rs"},
+	{ SEG_RAID6_ZR, "raid6_zr"},
+	{ SEG_RAID6_NR, "raid6_nr"},
+	{ SEG_RAID6_NC, "raid6_nc"},
+	{ SEG_RAID5_LS, "raid5"}, /* same as "raid5_ls" (default for MD also) */
+	{ SEG_RAID6_ZR, "raid6"}, /* same as "raid6_zr" */
+	{ SEG_LAST, NULL },
 };
 
 /* Some segment types have a list of areas of other devices attached */
@@ -100,7 +122,7 @@
 	unsigned area_count;		/* Linear + Striped + Mirrored + Crypt + Replicator */
 	struct dm_list areas;		/* Linear + Striped + Mirrored + Crypt + Replicator */
 
-	uint32_t stripe_size;		/* Striped */
+	uint32_t stripe_size;		/* Striped + raid */
 
 	int persistent;			/* Snapshot */
 	uint32_t chunk_size;		/* Snapshot */
@@ -109,7 +131,7 @@
 	struct dm_tree_node *merge;	/* Snapshot */
 
 	struct dm_tree_node *log;	/* Mirror + Replicator */
-	uint32_t region_size;		/* Mirror */
+	uint32_t region_size;		/* Mirror + raid */
 	unsigned clustered;		/* Mirror */
 	unsigned mirror_area_count;	/* Mirror */
 	uint32_t flags;			/* Mirror log */
@@ -1499,6 +1521,17 @@
 					EMIT_PARAMS(*pos, "%s", synctype);
 			}
 			break;
+		case SEG_RAID1:
+		case SEG_RAID4:
+		case SEG_RAID5_LA:
+		case SEG_RAID5_RA:
+		case SEG_RAID5_LS:
+		case SEG_RAID5_RS:
+		case SEG_RAID6_ZR:
+		case SEG_RAID6_NR:
+		case SEG_RAID6_NC:
+			EMIT_PARAMS(*pos, " %s", devbuf);
+			break;
 		default:
 			EMIT_PARAMS(*pos, "%s%s %" PRIu64, first_time ? "" : " ",
 				    devbuf, area->offset);
@@ -1676,6 +1709,43 @@
 	return 1;
 }
 
+static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
+				   uint32_t minor, struct load_segment *seg,
+				   uint64_t *seg_start, char *params,
+				   size_t paramsize)
+{
+	int param_count = 1; /* mandatory 'chunk size'/'stripe size' arg */
+	int pos = 0;
+
+	if ((seg->flags & DM_NOSYNC) || (seg->flags & DM_FORCESYNC))
+		param_count++;
+
+	if (seg->region_size)
+		param_count += 2;
+
+	if ((seg->type == SEG_RAID1) && seg->stripe_size)
+		log_error("WARNING: Ignoring RAID1 stripe size");
+
+	EMIT_PARAMS(pos, "%s %d %u", dm_segtypes[seg->type].target,
+		    param_count, seg->stripe_size);
+
+	if (seg->flags & DM_NOSYNC)
+		EMIT_PARAMS(pos, " nosync");
+	else if (seg->flags & DM_FORCESYNC)
+		EMIT_PARAMS(pos, " sync");
+
+	if (seg->region_size)
+		EMIT_PARAMS(pos, " region_size %u", seg->region_size);
+
+	/* Print number of metadata/data device pairs */
+	EMIT_PARAMS(pos, " %u", seg->area_count/2);
+
+	if (_emit_areas_line(dmt, seg, params, paramsize, &pos) <= 0)
+		return_0;
+
+	return 1;
+}
+
 static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 			      uint32_t minor, struct load_segment *seg,
 			      uint64_t *seg_start, char *params,
@@ -1683,6 +1753,7 @@
 {
 	int pos = 0;
 	int r;
+	int target_type_is_raid = 0;
 	char originbuf[DM_FORMAT_DEV_BUFSIZE], cowbuf[DM_FORMAT_DEV_BUFSIZE];
 
 	switch(seg->type) {
@@ -1736,6 +1807,22 @@
 			    seg->iv_offset != DM_CRYPT_IV_DEFAULT ?
 			    seg->iv_offset : *seg_start);
 		break;
+	case SEG_RAID1:
+	case SEG_RAID4:
+	case SEG_RAID5_LA:
+	case SEG_RAID5_RA:
+	case SEG_RAID5_LS:
+	case SEG_RAID5_RS:
+	case SEG_RAID6_ZR:
+	case SEG_RAID6_NR:
+	case SEG_RAID6_NC:
+		target_type_is_raid = 1;
+		r = _raid_emit_segment_line(dmt, major, minor, seg, seg_start,
+					    params, paramsize);
+		if (!r)
+			return_0;
+
+		break;
 	}
 
 	switch(seg->type) {
@@ -1767,7 +1854,9 @@
 		  " %" PRIu64 " %s %s", major, minor,
 		  *seg_start, seg->size, dm_segtypes[seg->type].target, params);
 
-	if (!dm_task_add_target(dmt, *seg_start, seg->size, dm_segtypes[seg->type].target, params))
+	if (!dm_task_add_target(dmt, *seg_start, seg->size,
+				target_type_is_raid ? "raid" :
+				dm_segtypes[seg->type].target, params))
 		return_0;
 
 	*seg_start += seg->size;
@@ -2250,6 +2339,30 @@
 	return 1;
 }
 
+int dm_tree_node_add_raid_target(struct dm_tree_node *node,
+				 uint64_t size,
+				 const char *raid_type,
+				 uint32_t region_size,
+				 uint32_t stripe_size,
+				 uint64_t reserved1,
+				 uint64_t reserved2)
+{
+	int i;
+	struct load_segment *seg = NULL;
+
+	for (i = 0; dm_segtypes[i].target && !seg; i++)
+		if (!strcmp(raid_type, dm_segtypes[i].target))
+			if (!(seg = _add_segment(node,
+						 dm_segtypes[i].type, size)))
+				return_0;
+
+	seg->region_size = region_size;
+	seg->stripe_size = stripe_size;
+	seg->area_count = 0;
+
+	return 1;
+}
+
 int dm_tree_node_add_replicator_target(struct dm_tree_node *node,
 				       uint64_t size,
 				       const char *rlog_uuid,
--- LVM2/man/lvcreate.8.in	2011/06/01 19:21:04	1.19
+++ LVM2/man/lvcreate.8.in	2011/08/02 22:07:23	1.20
@@ -199,11 +199,11 @@
 .TP
 .I \-\-type SegmentType
 Create a logical volume that uses the specified segment type
-(e.g. "mirror", "snapshot", "striped").  Especially useful when no
-existing commandline switch alias enables the use of the desired type
-(e.g. "error" or "zero" types).  Many segment types already have a
+(e.g. "raid5", "mirror", "snapshot").  Many segment types have a
 commandline switch alias that will enable their use (-s is an alias for
---type snapshot).
+--type snapshot).  However, this argument must be used when no existing
+commandline switch alias is available for the desired type, as is the case
+with "error", "zero", "raid4", "raid5", or "raid6".
 .TP
 .I \-\-virtualsize VirtualSize
 Create a sparse device of the given size (in MB by default) using a snapshot.  
@@ -258,7 +258,12 @@
 .br
 creates a linear logical volume "vg00/lvol1" using physical extents
 /dev/sda:0-7 and /dev/sdb:0-7 for allocation of extents.
+.br
 
+"lvcreate --type raid5 -L 5G -i 3 -I 64 -n my_lv vg00"
+.br
+creates a 5GiB RAID5 logical volume "vg00/my_lv", with 3 stripes (plus
+a parity drive for a total of 4 devices) and a stripesize of 64kiB.
 
 .SH SEE ALSO
 .BR lvm (8), 
--- LVM2/tools/lvcreate.c	2011/06/01 19:21:03	1.231
+++ LVM2/tools/lvcreate.c	2011/08/02 22:07:23	1.232
@@ -320,6 +320,50 @@
 	return 1;
 }
 
+static int _read_raid_params(struct lvcreate_params *lp,
+			     struct cmd_context *cmd)
+{
+	if (!segtype_is_raid(lp->segtype))
+		return 1;
+
+	if (arg_count(cmd, corelog_ARG) ||
+	    arg_count(cmd, mirrorlog_ARG)) {
+		log_error("Log options not applicable to %s segtype",
+			  lp->segtype->name);
+		return 0;
+	}
+
+	/*
+	 * get_stripe_params is called before _read_raid_params
+	 * and already sets:
+	 *   lp->stripes
+	 *   lp->stripe_size
+	 *
+	 * For RAID 4/5/6, these values must be set.
+	 */
+	if (!segtype_is_mirrored(lp->segtype) && (lp->stripes < 2)) {
+		log_error("Number of stripes to %s not specified",
+			  lp->segtype->name);
+		return 0;
+	}
+
+	/*
+	 * _read_mirror_params is called before _read_raid_params
+	 * and already sets:
+	 *   lp->nosync
+	 *   lp->region_size
+	 *
+	 * But let's ensure that programmers don't reorder
+	 * that by checking and warning if they aren't set.
+	 */
+	if (!lp->region_size) {
+		log_error("Programmer error: lp->region_size not set.");
+		return 0;
+	}
+
+	return 1;
+}
+
 static int _lvcreate_params(struct lvcreate_params *lp,
 			    struct lvcreate_cmdline_params *lcp,
 			    struct cmd_context *cmd,
@@ -328,6 +372,7 @@
 	int contiguous;
 	unsigned pagesize;
 	struct arg_value_group_list *current_group;
+	const char *segtype_str;
 	const char *tag;
 
 	memset(lp, 0, sizeof(*lp));
@@ -337,7 +382,11 @@
 	/*
 	 * Check selected options are compatible and determine segtype
 	 */
-	lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, "striped"));
+	segtype_str = "striped";
+	if (arg_count(cmd, mirrors_ARG))
+		segtype_str = find_config_tree_str(cmd, "activation/mirror_segtype_default", DEFAULT_MIRROR_SEGTYPE);
+
+	lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, segtype_str));
 
 	if (arg_count(cmd, snapshot_ARG) || seg_is_snapshot(lp) ||
 	    arg_count(cmd, virtualsize_ARG))
@@ -345,7 +394,7 @@
 
 	lp->mirrors = 1;
 
-	/* Default to 2 mirrored areas if --type mirror */
+	/* Default to 2 mirrored areas if '--type mirror|raid1' */
 	if (segtype_is_mirrored(lp->segtype))
 		lp->mirrors = 2;
 
@@ -386,15 +435,12 @@
 		}
 	}
 
-	if (lp->mirrors > 1) {
+	if (segtype_is_mirrored(lp->segtype) || segtype_is_raid(lp->segtype)) {
 		if (lp->snapshot) {
 			log_error("mirrors and snapshots are currently "
 				  "incompatible");
 			return 0;
 		}
-
-		if (!(lp->segtype = get_segtype_from_string(cmd, "striped")))
-			return_0;
 	} else {
 		if (arg_count(cmd, corelog_ARG)) {
 			log_error("--corelog is only available with mirrors");
@@ -426,7 +472,8 @@
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
 	    !_read_size_params(lp, lcp, cmd) ||
 	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
-	    !_read_mirror_params(lp, cmd))
+	    !_read_mirror_params(lp, cmd) ||
+	    !_read_raid_params(lp, cmd))
 		return_0;
 
 	lp->activate = arg_uint_value(cmd, available_ARG, CHANGE_AY);


