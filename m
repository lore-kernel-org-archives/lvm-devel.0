From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 May 2010 12:36:33 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in li ...
Message-ID: <20100521123633.10573.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-21 12:36:31

Modified files:
	.              : WHATS_NEW configure configure.in 
	lib            : Makefile.in 
	lib/commands   : toolcontext.c 
	lib/format_text: flags.c 
	lib/metadata   : lv_manip.c merge.c metadata-exported.h 
	                 segtype.h 
	lib/misc       : configure.h.in 

Log message:
	Replicator: base lvm2 support
	
	Adding configure.in support for Replicators.
	Adding basic lib lvm support for Replicators.
	Adding flags REPLICATOR and REPLICATOR_LOG.
	Adding segments SEG_REPLICATOR and SEG_REPLICATOR_DEV.
	Adding basic methods for handling replicator metadata.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1579&r2=1.1580
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.129&r2=1.130
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.140&r2=1.141
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/flags.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.229&r2=1.230
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.146&r2=1.147
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/WHATS_NEW	2010/05/21 12:30:35	1.1579
+++ LVM2/WHATS_NEW	2010/05/21 12:36:30	1.1580
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Initial lvm2 support for Replicator metadata handling.
   Checking open_count in all parents of presuspend_node.
   Added dm_tree_node_set_presuspend_node() to presuspend child in deactivate.
   Initial libdm support for Replicator target (API is not stable yet).
--- LVM2/configure	2010/05/20 13:47:21	1.129
+++ LVM2/configure	2010/05/21 12:36:30	1.130
@@ -660,6 +660,7 @@
 PTHREAD_LIBS
 POOL
 PKGCONFIG
+REPLICATORS
 MIRRORS
 LVM_RELEASE_DATE
 LVM_RELEASE
@@ -824,6 +825,7 @@
 with_cluster
 with_snapshots
 with_mirrors
+with_replicators
 enable_readline
 enable_realtime
 with_clvmd
@@ -1563,6 +1565,7 @@
                           TYPE=internal
   --with-mirrors=TYPE     Mirror support: internal/shared/none
                           TYPE=internal
+  --with-replicators=TYPE Replicator support: internal/shared/none TYPE=none
   --with-clvmd=TYPE       Build cluster LVM Daemon.
                           The following cluster manager combinations are valid:
                            * cman,gulm             (RHEL4 or equivalent)
@@ -9345,6 +9348,32 @@
 fi
 
 ################################################################################
+{ $as_echo "$as_me:$LINENO: checking whether to include replicators" >&5
+$as_echo_n "checking whether to include replicators... " >&6; }
+
+# Check whether --with-replicators was given.
+if test "${with_replicators+set}" = set; then
+  withval=$with_replicators; REPLICATORS=$withval
+else
+  REPLICATORS="none"
+fi
+
+{ $as_echo "$as_me:$LINENO: result: $REPLICATORS" >&5
+$as_echo "$REPLICATORS" >&6; }
+
+case "$REPLICATORS" in
+  none|shared) ;;
+  internal)
+cat >>confdefs.h <<\_ACEOF
+#define REPLICATOR_INTERNAL 1
+_ACEOF
+ ;;
+  *) { { $as_echo "$as_me:$LINENO: error: --with-replicators parameter invalid ($REPLICATORS)" >&5
+$as_echo "$as_me: error: --with-replicators parameter invalid ($REPLICATORS)" >&2;}
+   { (exit 1); exit 1; }; } ;;
+esac
+
+################################################################################
 { $as_echo "$as_me:$LINENO: checking whether to enable readline" >&5
 $as_echo_n "checking whether to enable readline... " >&6; }
 # Check whether --enable-readline was given.
@@ -15712,8 +15741,9 @@
 
 
 
+
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -16332,6 +16362,7 @@
     "lib/format_pool/Makefile") CONFIG_FILES="$CONFIG_FILES lib/format_pool/Makefile" ;;
     "lib/locking/Makefile") CONFIG_FILES="$CONFIG_FILES lib/locking/Makefile" ;;
     "lib/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES lib/mirror/Makefile" ;;
+    "lib/replicator/Makefile") CONFIG_FILES="$CONFIG_FILES lib/replicator/Makefile" ;;
     "lib/misc/lvm-version.h") CONFIG_FILES="$CONFIG_FILES lib/misc/lvm-version.h" ;;
     "lib/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES lib/snapshot/Makefile" ;;
     "libdm/Makefile") CONFIG_FILES="$CONFIG_FILES libdm/Makefile" ;;
--- LVM2/configure.in	2010/05/20 22:32:44	1.140
+++ LVM2/configure.in	2010/05/21 12:36:30	1.141
@@ -303,6 +303,21 @@
 fi
 
 ################################################################################
+dnl -- asynchronous volume replicator inclusion type
+AC_MSG_CHECKING(whether to include replicators)
+AC_ARG_WITH(replicators, AC_HELP_STRING([--with-replicators=TYPE],
+	[Replicator support: internal/shared/none [TYPE=none] ]),
+	[REPLICATORS=$withval], [REPLICATORS="none"])
+AC_MSG_RESULT($REPLICATORS)
+
+case "$REPLICATORS" in
+  none|shared) ;;
+  internal) AC_DEFINE([REPLICATOR_INTERNAL], 1,
+		[Define to 1 to include built-in support for replicators.]) ;;
+  *) AC_MSG_ERROR([--with-replicators parameter invalid ($REPLICATORS)]) ;;
+esac
+
+################################################################################
 dnl -- Disable readline
 AC_MSG_CHECKING(whether to enable readline)
 AC_ARG_ENABLE([readline],
@@ -1151,6 +1166,7 @@
 AC_SUBST(LVM_RELEASE)
 AC_SUBST(LVM_RELEASE_DATE)
 AC_SUBST(MIRRORS)
+AC_SUBST(REPLICATORS)
 AC_SUBST(MSGFMT)
 AC_SUBST(PKGCONFIG)
 AC_SUBST(POOL)
@@ -1206,6 +1222,7 @@
 lib/format_pool/Makefile
 lib/locking/Makefile
 lib/mirror/Makefile
+lib/replicator/Makefile
 lib/misc/lvm-version.h
 lib/snapshot/Makefile
 libdm/Makefile
--- LVM2/lib/Makefile.in	2010/04/09 21:42:50	1.102
+++ LVM2/lib/Makefile.in	2010/05/21 12:36:30	1.103
@@ -32,6 +32,10 @@
   SUBDIRS += mirror
 endif
 
+ifeq ("@REPLICATORS@", "shared")
+  SUBDIRS += replicator
+endif
+
 SOURCES =\
 	activate/activate.c \
 	cache/lvmcache.c \
@@ -74,6 +78,7 @@
 	metadata/mirror.c \
 	metadata/pv_manip.c \
 	metadata/pv_map.c \
+	metadata/replicator_manip.c \
 	metadata/segtype.c \
 	metadata/snapshot_manip.c \
 	misc/crc.c \
@@ -129,6 +134,10 @@
   SOURCES += mirror/mirrored.c
 endif
 
+ifeq ("@REPLICATORS@", "internal")
+  SOURCES += replicator/replicator.c
+endif
+
 ifeq ("@DEVMAPPER@", "yes")
   SOURCES +=\
 	activate/dev_manager.c \
@@ -155,6 +164,7 @@
 	format_pool \
 	snapshot \
 	mirror \
+	replicator \
 	locking
 endif
 
--- LVM2/lib/commands/toolcontext.c	2010/05/13 13:04:05	1.97
+++ LVM2/lib/commands/toolcontext.c	2010/05/21 12:36:31	1.98
@@ -936,6 +936,11 @@
 	dm_list_add(&cmd->segtypes, &segtype->list);
 #endif
 
+#ifdef REPLICATOR_INTERNAL
+	if (!init_replicator_segtype(&seglib))
+		return 0;
+#endif
+
 #ifdef HAVE_LIBDL
 	/* Load any formats in shared libs unless static */
 	if (!is_static() &&
--- LVM2/lib/format_text/flags.c	2010/01/13 01:56:18	1.41
+++ LVM2/lib/format_text/flags.c	2010/05/21 12:36:31	1.42
@@ -67,6 +67,8 @@
 	{PARTIAL_LV, NULL, 0},
 	{POSTORDER_FLAG, NULL, 0},
 	{VIRTUAL_ORIGIN, NULL, 0},
+	{REPLICATOR, NULL, 0},
+	{REPLICATOR_LOG, NULL, 0},
 	{0, NULL, 0}
 };
 
--- LVM2/lib/metadata/lv_manip.c	2010/04/23 19:27:10	1.229
+++ LVM2/lib/metadata/lv_manip.c	2010/05/21 12:36:31	1.230
@@ -2008,6 +2008,7 @@
 	dm_list_init(&lv->segments);
 	dm_list_init(&lv->tags);
 	dm_list_init(&lv->segs_using_this_lv);
+	dm_list_init(&lv->rsites);
 
 	return lv;
 }
--- LVM2/lib/metadata/merge.c	2010/04/09 01:00:11	1.41
+++ LVM2/lib/metadata/merge.c	2010/05/21 12:36:31	1.42
@@ -72,6 +72,8 @@
 	uint32_t area_multiplier, s;
 	struct seg_list *sl;
 	int error_count = 0;
+	struct replicator_site *rsite;
+	struct replicator_device *rdev;
 
 	dm_list_iterate_items(seg, &lv->segments) {
 		seg_count++;
@@ -213,6 +215,18 @@
 			if (lv == seg_lv(seg, s))
 				seg_found++;
 		}
+		if (seg_is_replicator_dev(seg)) {
+			dm_list_iterate_items(rsite, &seg->replicator->rsites) {
+				dm_list_iterate_items(rdev, &rsite->rdevices) {
+					if (lv == rdev->lv || lv == rdev->slog)
+						seg_found++;
+				}
+			}
+			if (lv == seg->replicator)
+				seg_found++;
+		}
+		if (seg_is_replicator(seg) && lv == seg->rlog_lv)
+				seg_found++;
 		if (seg->log_lv == lv)
 			seg_found++;
 		if (!seg_found) {
--- LVM2/lib/metadata/metadata-exported.h	2010/05/19 11:52:37	1.146
+++ LVM2/lib/metadata/metadata-exported.h	2010/05/21 12:36:31	1.147
@@ -72,6 +72,9 @@
 
 #define MERGING			0x10000000U	/* LV SEG */
 
+#define REPLICATOR		0x20000000U	/* LV -internal use only for replicator */
+#define REPLICATOR_LOG		0x40000000U	/* LV -internal use only for replicator-dev */
+
 #define LVM_READ              	0x00000100U	/* LV VG */
 #define LVM_WRITE             	0x00000200U	/* LV VG */
 #define CLUSTERED         	0x00000400U	/* VG */
@@ -292,6 +295,45 @@
 };
 
 struct segment_type;
+
+/* ++ Replicator datatypes */
+typedef enum {
+	REPLICATOR_STATE_PASSIVE,
+	REPLICATOR_STATE_ACTIVE,
+	NUM_REPLICATOR_STATE
+} replicator_state_t;
+
+struct replicator_site {
+	struct dm_list list;		/* Chained list of sites */
+	struct dm_list rdevices;	/* Device list */
+
+	struct logical_volume *replicator; /* Reference to replicator */
+
+	const char *name;               /* Site name */
+	const char *vg_name;		/* VG name */
+	struct volume_group *vg;        /* resolved vg  (activate/deactive) */
+	unsigned site_index;
+	replicator_state_t state;	/* Active or pasive state of site */
+	dm_replicator_mode_t op_mode;	/* Operation mode sync or async fail|warn|drop|stall */
+	uint64_t fall_behind_data;	/* Bytes */
+	uint32_t fall_behind_ios;	/* IO operations */
+	uint32_t fall_behind_timeout;	/* Seconds */
+};
+
+struct replicator_device {
+	struct dm_list list;		/* Chained list of devices from same site */
+
+	struct lv_segment *replicator_dev; /* Reference to replicator-dev segment */
+	struct replicator_site *rsite;	/* Reference to site parameters */
+
+	uint64_t device_index;
+	const char *name;		/* Device LV name */
+	struct logical_volume *lv;	/* LV from replicator site's VG */
+	struct logical_volume *slog;	/* Synclog lv from VG  */
+	const char *slog_name;		/* Debug - specify size of core synclog */
+};
+/* -- Replicator datatypes */
+
 struct lv_segment {
 	struct dm_list list;
 	struct logical_volume *lv;
@@ -310,7 +352,7 @@
 	struct logical_volume *origin;
 	struct logical_volume *cow;
 	struct dm_list origin_list;
-	uint32_t region_size;	/* For mirrors - in sectors */
+	uint32_t region_size;	/* For mirrors, replicators - in sectors */
 	uint32_t extents_copied;
 	struct logical_volume *log_lv;
 	struct lv_segment *pvmove_source_seg;
@@ -319,6 +361,12 @@
 	struct dm_list tags;
 
 	struct lv_segment_area *areas;
+
+	struct logical_volume *replicator;/* For replicator-devs - link to replicator LV */
+	struct logical_volume *rlog_lv;	/* For replicators */
+	const char *rlog_type;		/* For replicators */
+	uint64_t rdevice_index_highest;	/* For replicators */
+	unsigned rsite_index_highest;	/* For replicators */
 };
 
 #define seg_type(seg, s)	(seg)->areas[(s)].type
@@ -344,6 +392,9 @@
 	struct dm_list snapshot_segs;
 	struct lv_segment *snapshot;
 
+	struct replicator_device *rdevice;/* For replicator-devs, rimages, slogs - reference to rdevice */
+	struct dm_list rsites;	/* For replicators - all sites */
+
 	struct dm_list segments;
 	struct dm_list tags;
 	struct dm_list segs_using_this_lv;
@@ -725,6 +776,27 @@
 int collapse_mirrored_lv(struct logical_volume *lv);
 int shift_mirror_images(struct lv_segment *mirrored_seg, unsigned mimage);
 
+/* ++  metadata/replicator_manip.c */
+int replicator_add_replicator_dev(struct logical_volume *replicator_lv,
+				  struct lv_segment *rdev_seg);
+struct logical_volume *replicator_remove_replicator_dev(struct lv_segment *rdev_seg);
+int replicator_add_rlog(struct lv_segment *replicator_seg, struct logical_volume *rlog_lv);
+struct logical_volume *replicator_remove_rlog(struct lv_segment *replicator_seg);
+
+int replicator_dev_add_slog(struct replicator_device *rdev, struct logical_volume *slog_lv);
+struct logical_volume *replicator_dev_remove_slog(struct replicator_device *rdev);
+int replicator_dev_add_rimage(struct replicator_device *rdev, struct logical_volume *lv);
+struct logical_volume *replicator_dev_remove_rimage(struct replicator_device *rdev);
+
+int lv_is_active_replicator_dev(const struct logical_volume *lv);
+int lv_is_replicator(const struct logical_volume *lv);
+int lv_is_replicator_dev(const struct logical_volume *lv);
+int lv_is_rimage(const struct logical_volume *lv);
+int lv_is_rlog(const struct logical_volume *lv);
+int lv_is_slog(const struct logical_volume *lv);
+struct logical_volume *first_replicator_dev(const struct logical_volume *lv);
+/* --  metadata/replicator_manip.c */
+
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 				      struct device *dev, uint32_t lv_type);
 struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
--- LVM2/lib/metadata/segtype.h	2010/01/15 16:35:26	1.27
+++ LVM2/lib/metadata/segtype.h	2010/05/21 12:36:31	1.28
@@ -35,9 +35,13 @@
 #define SEG_VIRTUAL		0x00000020U
 #define SEG_CANNOT_BE_ZEROED	0x00000040U
 #define SEG_MONITORED		0x00000080U
+#define SEG_REPLICATOR		0x00000100U
+#define SEG_REPLICATOR_DEV	0x00000200U
 #define SEG_UNKNOWN		0x80000000U
 
 #define seg_is_mirrored(seg)	((seg)->segtype->flags & SEG_AREAS_MIRRORED ? 1 : 0)
+#define seg_is_replicator(seg)	((seg)->segtype->flags & SEG_REPLICATOR ? 1 : 0)
+#define seg_is_replicator_dev(seg) ((seg)->segtype->flags & SEG_REPLICATOR_DEV ? 1 : 0)
 #define seg_is_striped(seg)	((seg)->segtype->flags & SEG_AREAS_STRIPED ? 1 : 0)
 #define seg_is_snapshot(seg)	((seg)->segtype->flags & SEG_SNAPSHOT ? 1 : 0)
 #define seg_is_virtual(seg)	((seg)->segtype->flags & SEG_VIRTUAL ? 1 : 0)
@@ -110,6 +114,10 @@
 struct segment_type *init_free_segtype(struct cmd_context *cmd);
 struct segment_type *init_unknown_segtype(struct cmd_context *cmd, const char *name);
 
+#ifdef REPLICATOR_INTERNAL
+int init_replicator_segtype(struct segtype_library *seglib);
+#endif
+
 #ifdef SNAPSHOT_INTERNAL
 struct segment_type *init_snapshot_segtype(struct cmd_context *cmd);
 #endif
--- LVM2/lib/misc/configure.h.in	2010/05/20 22:32:44	1.21
+++ LVM2/lib/misc/configure.h.in	2010/05/21 12:36:31	1.22
@@ -427,6 +427,9 @@
 /* Define to 1 to include the LVM readline shell. */
 #undef READLINE_SUPPORT
 
+/* Define to 1 to include built-in support for replicators. */
+#undef REPLICATOR_INTERNAL
+
 /* Define as the return type of signal handlers (`int' or `void'). */
 #undef RETSIGTYPE
 


