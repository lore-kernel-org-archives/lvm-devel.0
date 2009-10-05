From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  5 Oct 2009 16:00:30 +0200
Subject: [PATCH 03/13] Replicator: add lvm support
In-Reply-To: <1254751240-17431-2-git-send-email-zkabelac@redhat.com>
References: <1254751240-17431-1-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-2-git-send-email-zkabelac@redhat.com>
Message-ID: <1254751240-17431-3-git-send-email-zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Adding basic lib lvm elements for Replicator
Validation of Replicator segment

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 configure.in                     |   17 +
 lib/Makefile.in                  |    9 +
 lib/commands/toolcontext.c       |    5 +
 lib/metadata/lv_manip.c          |    1 +
 lib/metadata/merge.c             |   14 +
 lib/metadata/metadata-exported.h |   94 ++++-
 lib/metadata/replicator.c        |  339 ++++++++++++++
 lib/metadata/segtype.h           |    8 +
 lib/replicator/.exported_symbols |    1 +
 lib/replicator/Makefile.in       |   28 ++
 lib/replicator/replicator.c      |  912 ++++++++++++++++++++++++++++++++++++++
 11 files changed, 1427 insertions(+), 1 deletions(-)
 create mode 100644 lib/metadata/replicator.c
 create mode 100644 lib/replicator/.exported_symbols
 create mode 100644 lib/replicator/Makefile.in
 create mode 100644 lib/replicator/replicator.c

diff --git a/configure.in b/configure.in
index bf360ed..197e17a 100644
--- a/configure.in
+++ b/configure.in
@@ -308,6 +308,21 @@ if test x$MIRRORS = xinternal; then
 fi
 
 ################################################################################
+dnl -- Asynchronous Volume Replicator inclusion type
+AC_MSG_CHECKING(whether to include replicator)
+AC_ARG_WITH(replicator, AC_HELP_STRING([--with-replicator=TYPE],
+        [Replicator support: internal/shared/none [[TYPE=none]]]),
+        [ REPLICATOR="$withval" ], [ REPLICATOR="none" ])
+AC_MSG_RESULT($REPLICATOR)
+
+case "$REPLICATOR" in
+ none|shared) ;;
+ internal) AC_DEFINE([REPLICATOR_INTERNAL], 1,
+                     [Define to 1 to include built-in support for replicator.]) ;;
+ *) AC_MSG_ERROR([--with-replicator parameter invalid ($REPLICATOR)]) ;;
+esac
+
+################################################################################
 dnl -- Disable readline
 AC_MSG_CHECKING(whether to enable readline)
 AC_ARG_ENABLE([readline],
@@ -1116,6 +1131,7 @@ AC_SUBST(LVM_PATCHLEVEL)
 AC_SUBST(LVM_RELEASE)
 AC_SUBST(LVM_RELEASE_DATE)
 AC_SUBST(MIRRORS)
+AC_SUBST(REPLICATOR)
 AC_SUBST(MSGFMT)
 AC_SUBST(OWNER)
 AC_SUBST(PKGCONFIG)
@@ -1163,6 +1179,7 @@ lib/format1/Makefile
 lib/format_pool/Makefile
 lib/locking/Makefile
 lib/mirror/Makefile
+lib/replicator/Makefile
 lib/misc/lvm-version.h
 lib/snapshot/Makefile
 libdm/Makefile
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 9396fb2..38a3589 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -33,6 +33,10 @@ ifeq ("@MIRRORS@", "shared")
   SUBDIRS += mirror
 endif
 
+ifeq ("@REPLICATOR@", "shared")
+  SUBDIRS += replicator
+endif
+
 SOURCES =\
 	activate/activate.c \
 	cache/lvmcache.c \
@@ -74,6 +78,7 @@ SOURCES =\
 	metadata/mirror.c \
 	metadata/pv_manip.c \
 	metadata/pv_map.c \
+	metadata/replicator.c \
 	metadata/segtype.c \
 	metadata/snapshot_manip.c \
 	misc/crc.c \
@@ -125,6 +130,10 @@ ifeq ("@MIRRORS@", "internal")
   SOURCES += mirror/mirrored.c
 endif
 
+ifeq ("@REPLICATOR@", "internal")
+  SOURCES += replicator/replicator.c
+endif
+
 ifeq ("@DEVMAPPER@", "yes")
   SOURCES +=\
 	activate/dev_manager.c \
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 2a56100..d1f4724 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -904,6 +904,11 @@ static int _init_segtypes(struct cmd_context *cmd)
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
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 7bcd64f..51e100e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1876,6 +1876,7 @@ struct logical_volume *alloc_lv(struct dm_pool *mem)
 	dm_list_init(&lv->segments);
 	dm_list_init(&lv->tags);
 	dm_list_init(&lv->segs_using_this_lv);
+	dm_list_init(&lv->rsites);
 
 	return lv;
 }
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 66e9ce0..3233d2b 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -66,6 +66,8 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 	int r = 1;
 	uint32_t area_multiplier, s;
 	struct seg_list *sl;
+	struct replicator_site *rsite;
+	struct replicator_device *rdev;
 
 	dm_list_iterate_items(seg, &lv->segments) {
 		seg_count++;
@@ -207,6 +209,18 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
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
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index bf830aa..2d08c2d 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -61,6 +61,9 @@
 //#define PRECOMMITTED		0x00200000U	/* VG - internal use only */
 #define CONVERTING		0x00400000U	/* LV */
 
+#define REPLICATOR		0x10000000U	/* LV -internal use only for replicator/replicator-dev */
+#define REPLICATOR_LOG		0x20000000U	/* LV -internal use only for replicator/replicator-dev */
+
 #define MISSING_PV              0x00800000U	/* PV */
 #define PARTIAL_LV              0x01000000U	/* LV - derived flag, not
 						   written out in metadata*/
@@ -277,6 +280,54 @@ struct lv_segment_area {
 };
 
 struct segment_type;
+
+/* ++ replicator datatypes */
+typedef enum {
+	REPLICATOR_ACTION_WARN,
+	REPLICATOR_ACTION_STALL,
+	REPLICATOR_ACTION_DROP,
+	REPLICATOR_ACTION_FAIL,
+	NUM_REPLICATOR_ACTION
+} replicator_action_t;
+
+typedef enum {
+	REPLICATOR_STATE_PASSIVE,
+	REPLICATOR_STATE_ACTIVE,
+	NUM_REPLICATOR_STATE
+} replicator_state_t;
+
+struct replicator_site {
+	struct dm_list list;		/* chained list of sites */
+	struct dm_list rdevices;	/* device list */
+
+	struct logical_volume *replicator; /* reference to replicator */
+
+	const char *name;
+	const char *vg_name;		/* vg name/uuid */
+	struct volume_group *vg;	/* site's volume group */
+	unsigned site_index;
+	replicator_state_t state;	/* active|pasive state of site */
+	replicator_action_t async_action;/* fail|warn|drop|resync|stall */
+	uint64_t fall_behind_data;	/* in bytes */
+	uint32_t fall_behind_ios;	/* io operations */
+	uint32_t fall_behind_timeout;	/* seconds */
+};
+
+struct replicator_device {
+	struct dm_list list;		/* chained list of devices from same site */
+
+	struct lv_segment *replicator_dev; /* reference to replicator-dev segment */
+	struct replicator_site *rsite;	/* reference to site parameters */
+
+	uint64_t device_index;
+	const char *name;		/* any device path/uuid */
+	struct logical_volume *lv;	/* lv from rsite's VG */
+	struct logical_volume *slog;	/* llog lv from VG  */
+	const char *slog_name;		/* ?debug? - specify ram based core log size */
+};
+
+/* -- replicator datatypes */
+
 struct lv_segment {
 	struct dm_list list;
 	struct logical_volume *lv;
@@ -295,13 +346,19 @@ struct lv_segment {
 	struct logical_volume *cow;
 	struct dm_list origin_list;
 	uint32_t chunk_size;	/* For snapshots - in sectors */
-	uint32_t region_size;	/* For mirrors - in sectors */
+	uint32_t region_size;	/* For mirrors, replicators - in sectors */
 	uint32_t extents_copied;
 	struct logical_volume *log_lv;
 
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
@@ -327,6 +384,9 @@ struct logical_volume {
 	struct dm_list snapshot_segs;
 	struct lv_segment *snapshot;
 
+	struct replicator_device *rdevice;/* For replicator-devs, rimages, slogs - reference to rdevice */
+	struct dm_list rsites;	/* For replicators - all sites */
+
 	struct dm_list segments;
 	struct dm_list tags;
 	struct dm_list segs_using_this_lv;
@@ -520,6 +580,7 @@ uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 struct lvcreate_params {
 	/* flags */
 	int snapshot; /* snap */
+	int replicator; /* replicator */
 	int zero; /* all */
 	int major; /* all */
 	int minor; /* all */
@@ -682,6 +743,37 @@ int reconfigure_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirr
 int collapse_mirrored_lv(struct logical_volume *lv);
 int shift_mirror_images(struct lv_segment *mirrored_seg, unsigned mimage);
 
+/* ++  metadata/replicator.c */
+
+int lvm_replicator_add_dev(struct logical_volume *replicator_lv, struct lv_segment *replicator_dev_seg);
+/*
+ * returns rimage ?? lv upon succeful detach of device
+ * entire LV entry should be removed by this crootall ??
+ */
+struct logical_volume *lvm_replicator_remove_dev(struct lv_segment *replicator_dev_seg);//MAYBE: struct replicator_device *rdev??
+int lvm_replicator_add_rlog(struct lv_segment *replicator_seg, struct logical_volume *rlog_lv);
+struct logical_volume *lvm_replicator_remove_rlog(struct lv_segment *replicator_seg);
+
+int lvm_replicator_dev_add_slog(struct replicator_device *rdev, struct logical_volume *llog_lv);
+struct logical_volume *lvm_replicator_dev_remove_slog(struct replicator_device *rdev);
+int lvm_replicator_dev_add_rimage(struct replicator_device *rdev, struct logical_volume *lv);
+struct logical_volume *lvm_replicator_dev_remove_rimage(struct replicator_device *rdev);
+
+/* is this segment part of active replicator */
+int lv_is_active_replicator_dev(const struct logical_volume *lv);
+
+/* is this lv replicator control device */
+int lv_is_replicator(const struct logical_volume *lv);
+/* is this lv replicator device */
+int lv_is_replicator_dev(const struct logical_volume *lv);
+/* is this lv replicated origin lv */
+int lv_is_rimage(const struct logical_volume *lv);
+/* is this lv rlog */
+int lv_is_rlog(const struct logical_volume *lv);
+/* is this lv sync log */
+int lv_is_slog(const struct logical_volume *lv);
+/* --  metadata/replicator.c */
+
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 				      struct device *dev, uint32_t lv_type);
 struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
diff --git a/lib/metadata/replicator.c b/lib/metadata/replicator.c
new file mode 100644
index 0000000..ca87085
--- /dev/null
+++ b/lib/metadata/replicator.c
@@ -0,0 +1,339 @@
+/*
+ * Copyright (C) 2009 Red Hat, Inc. All rights reserved.
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
+#include "metadata.h"
+#include "toolcontext.h"
+#include "segtype.h"
+#include "archiver.h"
+#include "lvm-string.h"
+#include "str_list.h"
+#include "defaults.h"
+#include "lv_alloc.h"
+
+/* Add lv as replicator device */
+int lvm_replicator_dev_add_rimage(struct replicator_device *rdev,
+				  struct logical_volume *lv)
+{
+	if (!lv || !rdev)
+		return_0;
+	log_verbose("try add_rimage");
+
+	if (lv_is_rimage(lv)) {
+		log_error("Logical volume %s is already part of other "
+			  "replicator.", lv->name);
+		return 0;
+	}
+
+	if (rdev->lv) {
+		log_error("Logical volume %s can not be attached to an "
+			  "already defined replicator_device", lv->name);
+		return 0;
+	}
+
+	lv_set_hidden(lv);
+	lv->rdevice = rdev;
+	rdev->lv = lv;
+
+	//{ static int  kill = 4; if (getenv("LVMKILL") && kill-- < 0) abort(); }
+
+	log_verbose("LV rdev rd:%p repseg:%p", rdev, rdev->replicator_dev);
+	return add_seg_to_segs_using_this_lv(lv, rdev->replicator_dev);
+}
+
+/* Remove lv from replicator device */
+struct logical_volume *lvm_replicator_dev_remove_rimage(struct replicator_device *rdev)
+{
+	struct logical_volume *lv;
+
+	if (!rdev || !rdev->lv)
+		return_NULL;
+
+	lv = rdev->lv;
+	if (!remove_seg_from_segs_using_this_lv(lv, rdev->replicator_dev))
+		return NULL;
+
+	// FIXME: - check for site references
+	rdev->lv = NULL;
+	lv->rdevice = NULL;
+	lv_set_visible(lv);
+
+	return lv;
+}
+
+int lvm_replicator_dev_add_slog(struct replicator_device *rdev,
+				struct logical_volume *slog)
+{
+	if (!slog || !rdev)
+		return_0;
+
+	if (rdev->slog) {
+		log_error("Replicator device in site %s already has sync log.",
+			  rdev->rsite->name);
+		return 0;
+	}
+
+	if (slog->rdevice) {
+		log_error("Sync log %s is already part of other replicator.",
+			  slog->name);
+		return 0;
+	}
+
+	lv_set_hidden(slog);
+	slog->rdevice = rdev;
+	rdev->slog = slog;
+
+	return add_seg_to_segs_using_this_lv(slog, rdev->replicator_dev);
+}
+
+struct logical_volume *lvm_replicator_dev_remove_slog(struct replicator_device *rdev)
+{
+	struct logical_volume *lv;
+
+	if (!rdev)
+		return_NULL;
+
+	lv = rdev->slog;
+	if (!lv) {
+		log_error("Replicator device in site %s does not have sync log.",
+			  rdev->rsite->name);
+		return NULL;
+	}
+
+	if (!remove_seg_from_segs_using_this_lv(lv, rdev->replicator_dev))
+		return NULL;
+
+	rdev->slog = NULL;
+	lv->rdevice = NULL;
+	lv_set_visible(lv);
+
+	return lv;
+}
+
+int lvm_replicator_add_dev(struct logical_volume *replicator_lv,
+			   struct lv_segment *replicator_dev_seg)
+{
+	if (!replicator_lv)
+		return_0;
+
+	if (!(replicator_lv->status & REPLICATOR)) {
+		dm_list_init(&replicator_lv->rsites);
+		lv_set_hidden(replicator_lv);
+		replicator_lv->status |= REPLICATOR;
+	}
+
+	if (!replicator_dev_seg)
+                return 1;
+
+	if (replicator_dev_seg->replicator) {
+		log_error("Replicator device %s is already part of replicator.",
+			  replicator_dev_seg->lv->name);
+		return 0;
+	}
+
+	replicator_dev_seg->replicator = replicator_lv;
+
+	return add_seg_to_segs_using_this_lv(replicator_lv, replicator_dev_seg);
+}
+
+struct logical_volume *lvm_replicator_remove_dev(struct lv_segment *replicator_dev_seg)
+{
+	struct logical_volume *lv = NULL;
+
+#if 0
+	// FIXME - this is going to be complex....
+	if (!replicator_dev_seg)
+		return_NULL;
+
+	// if slog -  exit
+	// if rimage - exit
+
+	if (!remove_seg_from_segs_using_this_lv(lv, replicator_seg))
+		return NULL;
+	replicator_seg->rlog_lv = NULL;
+	lv->status &= ~REPLICATOR_LOG;
+	lv_set_visible(lv);
+#endif
+
+	return lv;
+}
+
+int lvm_replicator_add_rlog(struct lv_segment *replicator_seg,
+			    struct logical_volume *rlog_lv)
+{
+	if (!rlog_lv)
+		return_0;
+
+	if (rlog_lv->status & REPLICATOR_LOG) {
+		log_error("Rlog device %s is already used.", rlog_lv->name);
+		return 0;
+	}
+
+	lv_set_hidden(rlog_lv);
+	rlog_lv->status |= REPLICATOR_LOG;
+	replicator_seg->rlog_lv = rlog_lv;
+
+	return add_seg_to_segs_using_this_lv(rlog_lv, replicator_seg);
+}
+
+struct logical_volume *lvm_replicator_remove_rlog(struct lv_segment *replicator_seg)
+{
+	struct logical_volume *lv;
+
+	if (!replicator_seg)
+		return_0;
+
+	if (!(lv = replicator_seg->rlog_lv)) {
+		log_error("Replog segment %s does not have rlog.",
+			  replicator_seg->lv->name);
+		return NULL;
+	}
+
+	if (!remove_seg_from_segs_using_this_lv(lv, replicator_seg))
+		return NULL;
+
+	replicator_seg->rlog_lv = NULL;
+	lv->status &= ~REPLICATOR_LOG;
+	lv_set_visible(lv);
+
+	return lv;
+}
+
+
+#if 0
+/*
+ * Create new LV to pretend the original LV
+ * this target will have a 'replicator' segment
+ */
+int lvm_replicator_lv_add(struct logical_volume *origin, const char *rep_suffix)
+{
+	struct logical_volume *rep_lv;
+	//struct lv_segment *seg;
+	char *name;
+	size_t slen;
+
+	//name = strcpy(alloc(strlen(s) + 1), s), if (!strstr(name, suffix) ? ),
+
+	if (!(name = strstr(origin->name, rep_suffix))) {
+		log_error("Failed to find replicator suffix %s in LV name %s",
+			  rep_suffix, origin->name);
+		return 0;
+	}
+	slen = (size_t)(name - origin->name);
+	name = alloca(slen + 1);
+	memcpy(name, origin->name, slen);
+	name[slen] = 0;
+
+	if ((rep_lv = find_lv(origin->vg, name))) {
+		rep_lv->status |= VIRTUAL;
+		log_very_verbose("Found already created lv  %s	le:%" PRIu32,
+				 rep_lv->name, rep_lv->le_count);
+		return 1;
+	}
+
+	if (!(rep_lv = lv_create_empty(name, &origin->lvid,
+				       LVM_READ | LVM_WRITE | VISIBLE_LV,
+				       ALLOC_INHERIT, origin->vg)))
+		return_0;
+
+	log_very_verbose("Created empty lv  %s	 %s le:%" PRIu32,
+			 rep_lv->name, origin->name, origin->le_count);
+
+	if (!lv_add_virtual_segment(rep_lv, 0, origin->le_count,
+				    get_segtype_from_string(origin->vg->cmd,
+							    "error")))
+		return_0;
+
+	/*
+	if (!(seg = alloc_snapshot_seg(rep, 0, 0)))
+		return_0;
+
+	seg->chunk_size = chunk_size;
+	seg->origin = origin;
+	seg->cow = cow;
+	seg->lv->status |= SNAPSHOT;
+
+	origin->origin_count++;
+	origin->vg->snapshot_count++;
+	origin->vg->lv_count--;
+	cow->snapshot = seg;
+
+	cow->status &= ~VISIBLE_LV;
+
+	dm_list_add(&origin->snapshot_segs, &seg->origin_list);
+	*/
+
+	//rep_lv->status |= REPLICATOR | VIRTUAL;
+	rep_lv->status |= VIRTUAL;
+	return 1;
+}
+
+int lvm_replicator_lv_remove(struct logical_volume *lv)
+{
+	dm_list_del(&cow->snapshot->origin_list);
+	cow->snapshot->origin->origin_count--;
+
+	if (!lv_remove(cow->snapshot->lv)) {
+		log_error("Failed to remove internal snapshot LV %s",
+			  cow->snapshot->lv->name);
+		return 0;
+	}
+
+	cow->snapshot = NULL;
+
+	cow->vg->snapshot_count--;
+	cow->status |= VISIBLE_LV;
+
+	return 1;
+}
+#endif
+
+int lv_is_replicator(const struct logical_volume *lv)
+{
+	return ((lv->status & REPLICATOR) &&
+		!dm_list_empty(&lv->segments) &&
+		seg_is_replicator(first_seg(lv)));
+}
+
+int lv_is_replicator_dev(const struct logical_volume *lv)
+{
+	return ((lv->status & REPLICATOR) &&
+		!dm_list_empty(&lv->segments) &&
+		seg_is_replicator_dev(first_seg(lv)));
+}
+
+int lv_is_rimage(const struct logical_volume *lv)
+{
+        return (lv->rdevice && lv->rdevice->lv == lv);
+}
+
+int lv_is_rlog(const struct logical_volume *lv)
+{
+	return (lv->status & REPLICATOR_LOG) &&
+		!dm_list_empty(&lv->segments) &&
+		seg_is_replicator(first_seg(lv));
+}
+
+int lv_is_slog(const struct logical_volume *lv)
+{
+	return (lv->rdevice && lv->rdevice->slog == lv);
+}
+
+int lv_is_active_replicator_dev(const struct logical_volume *lv)
+{
+	if (!(lv->status & REPLICATOR) ||
+	    !lv->rdevice || !lv->rdevice->rsite)
+		return 0;
+	return (lv->rdevice->rsite->state == REPLICATOR_STATE_ACTIVE);
+}
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index ff6fb08..4454cb2 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -35,8 +35,12 @@ struct dev_manager;
 #define SEG_VIRTUAL		0x00000020U
 #define SEG_CANNOT_BE_ZEROED	0x00000040U
 #define SEG_MONITORED		0x00000080U
+#define SEG_REPLICATOR		0x00000100U
+#define SEG_REPLICATOR_DEV	0x00000200U
 
 #define seg_is_mirrored(seg)	((seg)->segtype->flags & SEG_AREAS_MIRRORED ? 1 : 0)
+#define seg_is_replicator(seg)	((seg)->segtype->flags & SEG_REPLICATOR ? 1 : 0)
+#define seg_is_replicator_dev(seg) ((seg)->segtype->flags & SEG_REPLICATOR_DEV ? 1 : 0)
 #define seg_is_striped(seg)	((seg)->segtype->flags & SEG_AREAS_STRIPED ? 1 : 0)
 #define seg_is_snapshot(seg)	((seg)->segtype->flags & SEG_SNAPSHOT ? 1 : 0)
 #define seg_is_virtual(seg)	((seg)->segtype->flags & SEG_VIRTUAL ? 1 : 0)
@@ -106,6 +110,10 @@ struct segment_type *init_zero_segtype(struct cmd_context *cmd);
 struct segment_type *init_error_segtype(struct cmd_context *cmd);
 struct segment_type *init_free_segtype(struct cmd_context *cmd);
 
+#ifdef REPLICATOR_INTERNAL
+int init_replicator_segtype(struct segtype_library *seglib);
+#endif
+
 #ifdef SNAPSHOT_INTERNAL
 struct segment_type *init_snapshot_segtype(struct cmd_context *cmd);
 #endif
diff --git a/lib/replicator/.exported_symbols b/lib/replicator/.exported_symbols
new file mode 100644
index 0000000..1c92c6a
--- /dev/null
+++ b/lib/replicator/.exported_symbols
@@ -0,0 +1 @@
+init_segtype
diff --git a/lib/replicator/Makefile.in b/lib/replicator/Makefile.in
new file mode 100644
index 0000000..db1f9b7
--- /dev/null
+++ b/lib/replicator/Makefile.in
@@ -0,0 +1,28 @@
+#
+# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+srcdir = @srcdir@
+top_srcdir = @top_srcdir@
+VPATH = @srcdir@
+
+SOURCES = replicator.c
+
+LIB_SHARED = liblvm2replicator.so
+
+include $(top_srcdir)/make.tmpl
+
+install: $(LIB_SHARED)
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
+		$(libdir)/$(LIB_SHARED).$(LIB_VERSION)
+	$(LN_S) -f $(LIB_SHARED).$(LIB_VERSION) \
+		$(libdir)/$(LIB_SHARED)
diff --git a/lib/replicator/replicator.c b/lib/replicator/replicator.c
new file mode 100644
index 0000000..6e0f7a6
--- /dev/null
+++ b/lib/replicator/replicator.c
@@ -0,0 +1,912 @@
+/*
+ * Copyright (C) 2009 Red Hat, Inc. All rights reserved.
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
+#include "metadata.h"
+#include "segtype.h"
+#include "text_export.h"
+#include "text_import.h"
+#include "config.h"
+#include "activate.h"
+#include "str_list.h"
+#include "targets.h"  /* build_dlid */
+#ifdef DMEVENTD
+#  include "sharedlib.h"
+#  include "libdevmapper-event.h"
+#endif
+
+/* dm kernel module name for replicator */
+#define REPLICATOR_MODULE "replicator"
+#define REPLICATOR_DEV_MODULE "replicator-dev"
+
+#define SEG_LOG_ERROR(t, p...) \
+	log_error(t " segment %s of logical volume %s.", ## p, \
+		  config_parent_name(sn), seg->lv->name), 0; \
+
+
+/*
+ *  Replicator  target
+ */
+static const char *_replicator_name(const struct lv_segment *seg)
+{
+	return seg->segtype->name;
+}
+
+/* FIXME: */
+static void _replicator_display(const struct lv_segment *seg)
+{
+	//const char *size;
+	//uint32_t s;
+
+	log_print("  Replicator");
+	if (seg->rlog_lv)
+		log_print("  Replicator volume\t%s", seg->rlog_lv->name);
+}
+
+/* Wrapper for get_config_uint32 with default value */
+static uint32_t _get_config_uint32(const struct config_node *cn,
+				   const char *path,
+				   uint32_t def)
+{
+	uint32_t t;
+
+	return get_config_uint32(cn, path, &t) ? t : def;
+}
+
+/* Wrapper for get_config_uint64 with default value */
+static uint64_t _get_config_uint64(const struct config_node *cn,
+				   const char *path,
+				   uint64_t def)
+{
+	uint64_t t;
+
+	return get_config_uint64(cn, path, &t) ? t : def;
+}
+
+
+/* Strings replicator_state_t enum */
+static const char _state_txt[NUM_REPLICATOR_STATE][8] = {
+	"passive",
+	"active"
+};
+
+/* Parse state string */
+static replicator_state_t _get_state(const struct config_node *sn,
+				     const char *path, replicator_state_t def)
+{
+	char *str;
+	unsigned i;
+
+	if (get_config_str(sn, path, &str)) {
+		for (i = 0; i < sizeof(_state_txt)/sizeof(_state_txt[0]); ++i)
+			if (strcasecmp(str, _state_txt[i]) == 0) {
+				log_very_verbose("Setting %s to %s",
+						 path, _state_txt[i]);
+				return (replicator_state_t) i;
+			}
+
+		log_warn("%s: unknown value '%s', using default '%s' state",
+			 path, str, _state_txt[def]);
+	}
+
+	return def;
+}
+
+/* Strings for replicator_action_t enum */
+static const char _action_txt[NUM_REPLICATOR_ACTION][8] = {
+	"warn",
+	"stall",
+	"drop",
+	"fail"
+};
+
+
+/* Parse action string */
+static replicator_action_t _get_action(const struct config_node *sn,
+				       const char *path, replicator_action_t def)
+{
+	char *str;
+	unsigned i;
+
+	if (get_config_str(sn, path, &str)) {
+		for (i = 0; i < sizeof(_action_txt)/sizeof(_action_txt[0]); ++i)
+			if (strcasecmp(str, _action_txt[i]) == 0) {
+				log_very_verbose("Setting %s to %s",
+						 path, _action_txt[i]);
+				return (replicator_action_t) i;
+			}
+		log_warn("%s: unknown value '%s', using default '%s' action",
+			 path, str, _action_txt[def]);
+	}
+
+	return def;
+}
+
+static struct replicator_site *_get_site(struct logical_volume *replicator,
+					 const char *key)
+{
+	struct dm_pool *mem = replicator->vg->vgmem;
+	struct replicator_site *rsite;
+
+	dm_list_iterate_items(rsite, &replicator->rsites) {
+		if (strcasecmp(rsite->name, key) == 0) {
+			return rsite;
+		}
+	}
+	if (!(rsite = dm_pool_zalloc(mem, sizeof(*rsite))))
+		return_NULL;
+
+	if (!(rsite->name = dm_pool_strdup(mem, key)))
+		return_NULL;
+
+	rsite->replicator = replicator;
+	dm_list_init(&rsite->rdevices);
+	dm_list_add(&replicator->rsites, &rsite->list);
+
+	return rsite;
+}
+
+
+/* Parse replicator site element */
+static int _add_site(struct lv_segment *seg,
+		     const char *key,
+		     const struct config_node *sn)
+{
+	struct dm_pool *mem = seg->lv->vg->vgmem;
+	const struct config_node *cn;
+	struct replicator_site *rsite;
+
+	if (!(rsite = _get_site(seg->lv, key)))
+		return_0;
+
+	if (!find_config_node(sn, "site_index"))
+		return SEG_LOG_ERROR("Mandatory site_index is missing for");
+
+	rsite->state = _get_state(sn, "state", REPLICATOR_STATE_PASSIVE);
+	rsite->site_index = _get_config_uint32(sn, "site_index", 0);
+	if (rsite->site_index > seg->rsite_index_highest)
+		return SEG_LOG_ERROR("site_index=%d > highest_site_index=%d for",
+				     rsite->site_index, seg->rsite_index_highest);
+
+	rsite->fall_behind_data = _get_config_uint64(sn, "fall_behind_data", 0);
+	rsite->fall_behind_ios = _get_config_uint32(sn, "fall_behind_ios", 0);
+	rsite->fall_behind_timeout = _get_config_uint32(sn, "fall_behind_timeout", 0);
+	rsite->async_action = REPLICATOR_ACTION_WARN;
+
+	if (rsite->fall_behind_data ||
+	    rsite->fall_behind_ios ||
+	    rsite->fall_behind_timeout) {
+		if (rsite->fall_behind_data && rsite->fall_behind_ios)
+			return SEG_LOG_ERROR("Defined both fall_behind_data "
+					     "and fall_behind_ios in");
+
+		if (rsite->fall_behind_data && rsite->fall_behind_timeout)
+			return SEG_LOG_ERROR("Defined both fall_behind_data "
+					     "and fall_behind_timeout in");
+
+		if (rsite->fall_behind_ios && rsite->fall_behind_timeout)
+			return SEG_LOG_ERROR("Defined both fall_behind_ios "
+					     "and fall_behind_timeout in");
+
+		rsite->async_action = _get_action(sn, "async_action",
+						  rsite->async_action);
+	}
+
+	if ((cn = find_config_node(sn, "volume_group"))) {
+		if (!cn->v || cn->v->type != CFG_STRING)
+			return SEG_LOG_ERROR("volume_group must be a string in");
+
+		if (!(rsite->vg_name = dm_pool_strdup(mem, cn->v->v.str)))
+			return_0;
+
+	} else if (rsite->site_index != 0)
+		return SEG_LOG_ERROR("volume_group is mandatory for remote site in");
+
+	return 1;
+}
+
+
+/* Import replicator segment */
+static int _replicator_text_import(struct lv_segment *seg,
+				   const struct config_node *sn,
+				   struct dm_hash_table *pv_hash __attribute((unused)))
+{
+	const struct config_node *cn;
+	struct logical_volume *rlog_lv;
+
+	if (!lvm_replicator_add_dev(seg->lv, NULL))
+		return_0;
+
+	if (!(cn = find_config_node(sn, "replicator_log")) ||
+	    !cn->v || cn->v->type != CFG_STRING)
+		return SEG_LOG_ERROR("Replicator log type must be a string in");
+
+	if (!(rlog_lv = find_lv(seg->lv->vg, cn->v->v.str)))
+		return SEG_LOG_ERROR("Unknown replicator log %s in",
+				     cn->v->v.str);
+
+	if (!(cn = find_config_node(sn, "replicator_log_type")) ||
+	    !cn->v || cn->v->type != CFG_STRING)
+		return SEG_LOG_ERROR("Replicator log's type must be a string in");
+	if (strcasecmp(cn->v->v.str, "ringbuffer"))
+		return SEG_LOG_ERROR("Only ringbuffer replicator log type is supported in");
+
+	if (!(seg->rlog_type = dm_pool_strdup(seg->lv->vg->vgmem, cn->v->v.str)))
+		return_0;
+
+
+	log_very_verbose("replicator_log = %s", rlog_lv->name);
+	log_very_verbose("replicator_log_type = %s", seg->rlog_type);
+
+	if (!lvm_replicator_add_rlog(seg, rlog_lv))
+		return_0;
+
+	seg->rdevice_index_highest = _get_config_uint64(sn, "highest_device_index", 0);
+	seg->rsite_index_highest = _get_config_uint64(sn, "highest_site_index", 0);
+
+	seg->region_size = _get_config_uint32(sn, "sync_log_size", 0);
+
+	for (; sn; sn = sn->sib)
+		if (!sn->v && !_add_site(seg, sn->key, sn->child))
+			return 0;
+
+	return 1;
+}
+
+/* Export replicator segment */
+static int _replicator_text_export(const struct lv_segment *seg,
+				   struct formatter *f)
+{
+	const struct replicator_site *rsite;
+
+	if (!seg->rlog_lv)
+                return_0;
+
+	outf(f, "replicator_log = \"%s\"", seg->rlog_lv->name);
+	outf(f, "replicator_log_type = \"%s\"", seg->rlog_type);
+	outf(f, "highest_device_index = %" PRIu64, seg->rdevice_index_highest);
+	outf(f, "highest_site_index = %d", seg->rsite_index_highest);
+
+	if (seg->region_size)
+		outf(f, "sync_log_size = %d", seg->region_size);
+
+	if (!dm_list_empty(&seg->lv->rsites))
+		out_newline(f);
+
+	dm_list_iterate_items(rsite, &seg->lv->rsites) {
+		outf(f, "%s {", rsite->name);
+		out_inc_indent(f);
+
+		outf(f, "state = \"%s\"", _state_txt[rsite->state]);
+		outf(f, "site_index = %d", rsite->site_index);
+
+		/* only non-default parameters are written */
+		if (rsite->async_action != REPLICATOR_ACTION_WARN)
+			outf(f, "async_action = \"%s\"",
+			     _action_txt[rsite->async_action]);
+		if (rsite->fall_behind_timeout)
+			outf(f, "fall_behind_timeout = %u\t# seconds",
+			     rsite->fall_behind_timeout);
+		if (rsite->fall_behind_ios)
+			outf(f, "fall_behind_ios = %u\t# io operations",
+			     rsite->fall_behind_ios);
+		if (rsite->fall_behind_data)
+			outf(f, "fall_behind_data = %" PRIu64  "\t# bytes",
+			     rsite->fall_behind_data);
+		if (rsite->state != REPLICATOR_STATE_ACTIVE && rsite->vg_name)
+			outf(f, "volume_group = \"%s\"", rsite->vg_name);
+
+		out_dec_indent(f);
+		outf(f, "}");
+	}
+
+	return 1;
+}
+
+#ifdef DEVMAPPER_SUPPORT
+static int _replicator_add_target_line(struct dev_manager *dm,
+				       struct dm_pool *mem,
+				       struct cmd_context *cmd,
+				       void **target_state,
+				       struct lv_segment *seg,
+				       struct dm_tree_node *node,
+				       uint64_t len,
+				       uint32_t *pvmove_mirror_count)
+{
+	const char *rlog_dlid;
+	const struct replicator_site *rsite;
+	int action;
+
+	if (!seg->rlog_lv)
+		return_0;
+
+	if (!(rlog_dlid = build_dlid(dm, seg->rlog_lv->lvid.s, NULL)))
+		return_0;
+
+	dm_list_iterate_items(rsite, &seg->lv->rsites) {
+		action = (rsite->async_action == REPLICATOR_ACTION_WARN) ? DM_REPLICATOR_WARN :
+			(rsite->async_action == REPLICATOR_ACTION_STALL) ? DM_REPLICATOR_STALL :
+			(rsite->async_action == REPLICATOR_ACTION_DROP) ? DM_REPLICATOR_DROP : DM_REPLICATOR_FAIL;
+		if (!rsite->fall_behind_timeout && !rsite->fall_behind_data && !rsite->fall_behind_ios)
+			action = DM_REPLICATOR_SYNC;
+		if (!dm_tree_node_add_replicator_target(node,
+							seg->rlog_lv->size,
+							rlog_dlid,
+                                                        seg->rlog_type,
+							rsite->site_index,
+							action,
+							rsite->fall_behind_timeout,
+							rsite->fall_behind_data,
+							rsite->fall_behind_ios)) {
+			if (rsite->site_index == 0) {
+				log_error("Failed to add replicator log '%s' "
+					  "to replicator '%s'.",
+					  rlog_dlid, seg->lv->name);
+				return 0;
+			}
+			// FIXME:
+		}
+	}
+
+	return 1;
+}
+
+/* FIXME write something useful for replicator here */
+static int _replicator_target_percent(void **target_state, struct dm_pool *mem,
+				      struct cmd_context *cmd,
+				      struct lv_segment *seg,
+				      char *params, uint64_t *total_numerator,
+				      uint64_t *total_denominator)
+{
+	struct mirror_state *mirr_state;
+	uint64_t numerator, denominator;
+	unsigned mirror_count, m;
+	int used;
+	char *pos = params;
+
+	//if (!*target_state)
+	//	*target_state = _mirrored_init_target(mem, cmd);
+
+	mirr_state = *target_state;
+
+	/* Status line: <#mirrors> (maj:min)+ <synced>/<total_regions> */
+	log_debug("Replicator status: %s", params);
+
+	if (sscanf(pos, "%u %n", &mirror_count, &used) != 1) {
+		log_error("Failure parsing mirror status mirror count: %s.",
+			  params);
+		return 0;
+	}
+	pos += used;
+
+	for (m = 0; m < mirror_count; ++m) {
+		if (sscanf(pos, "%*x:%*x %n", &used) != 0) {
+			log_error("Failure parsing mirror status devices: %s.",
+				  params);
+			return 0;
+		}
+		pos += used;
+	}
+
+	if (sscanf(pos, "%" PRIu64 "/%" PRIu64 "%n", &numerator, &denominator,
+		   &used) != 2) {
+		log_error("Failure parsing replicator status fraction: %s.",
+			  params);
+		return 0;
+	}
+	pos += used;
+
+	*total_numerator += numerator;
+	*total_denominator += denominator;
+
+	if (seg)
+		seg->extents_copied = (uint32_t)(seg->area_len * numerator / denominator);
+
+	return 1;
+}
+
+/* Check for module presence */
+static int _replicator_target_present(struct cmd_context *cmd,
+				      const struct lv_segment *seg __attribute((unused)),
+				      unsigned *attributes __attribute((unused)))
+{
+	static int _checked = 0;
+	static int _present = 0;
+
+	if (!_checked) {
+		_present = target_present(cmd, REPLICATOR_MODULE, 1);
+		_checked = 1;
+	}
+
+	return _present;
+}
+
+#endif
+
+static int _replicator_modules_needed(struct dm_pool *mem,
+				      const struct lv_segment *seg __attribute((unused)),
+				      struct dm_list *modules)
+{
+	if (!str_list_add(mem, modules, REPLICATOR_MODULE))
+		return_0;
+
+	return 1;
+}
+
+static void _replicator_destroy(const struct segment_type *segtype)
+{
+	dm_free((void *)segtype);
+}
+
+static struct segtype_handler _replicator_ops = {
+	.name = _replicator_name,
+	.display = _replicator_display,
+	.text_import = _replicator_text_import,
+	.text_export = _replicator_text_export,
+#ifdef DEVMAPPER_SUPPORT
+	.add_target_line = _replicator_add_target_line,
+	.target_percent = _replicator_target_percent,
+	.target_present = _replicator_target_present,
+#endif
+	.modules_needed = _replicator_modules_needed,
+	.destroy = _replicator_destroy,
+};
+
+/*
+ *  Replicator-dev  target
+ */
+static void _replicator_dev_display(const struct lv_segment *seg)
+{
+	//const char *size;
+	//uint32_t s;
+
+	log_print("  Replicator\t\t%u", seg->area_count);
+	log_print("  Mirror size\t\t%u", seg->area_len);
+	if (seg->log_lv)
+		log_print("  Replicator log volume\t%s", seg->rlog_lv->name);
+
+}
+
+static int _add_device(struct lv_segment *seg,
+		       const char *site_name,
+		       const struct config_node *sn)
+{
+	struct dm_pool *mem = seg->lv->vg->vgmem;
+	struct logical_volume *lv = NULL;
+	struct logical_volume *slog_lv = NULL;
+	struct replicator_site *rsite = _get_site(seg->replicator, site_name);
+	struct replicator_device *rdev;
+	const char *dev_str = NULL;
+	const char *slog_str = NULL;
+	const struct config_node *cn;
+
+	if ((cn = find_config_node(sn, "sync_log"))) {
+		if (!cn->v || !cn->v->v.str)
+			return SEG_LOG_ERROR("Sync log must be a string in");
+		slog_str = cn->v->v.str;
+	}
+
+	if (!(cn = find_config_node(sn, "logical_volume")) ||
+	    !cn->v || !cn->v->v.str)
+		return SEG_LOG_ERROR("Logical volume must be a string in");
+
+	dev_str = cn->v->v.str;
+
+	if (!seg->lv->rdevice) {
+		if (slog_str)
+			return SEG_LOG_ERROR("Sync log %s defined for local "
+					     "device in", slog_str);
+
+		// check for device in current VG
+		if (!(lv = find_lv(seg->lv->vg, dev_str)))
+			return SEG_LOG_ERROR("Logical volume %s not found in",
+					     dev_str);
+	} else {
+		if (!slog_str)
+			return SEG_LOG_ERROR("Sync log is missing for remote "
+					     "device in");
+		if (!(slog_lv = find_lv(seg->lv->vg, slog_str)))
+			return SEG_LOG_ERROR("Sync log %s not found in",
+					     slog_str);
+	}
+
+	// check for slog device in current VG
+
+	if (!(rdev = dm_pool_zalloc(mem, sizeof(*rdev))))
+		return_0;
+
+	if (!(rdev->name = dm_pool_strdup(mem, dev_str)))
+		return_0;
+
+	rdev->replicator_dev = seg;
+	rdev->rsite = rsite;
+
+	if (!seg->lv->rdevice) {
+		lvm_replicator_dev_add_rimage(rdev, lv);
+		seg->lv->rdevice = rdev;
+	} else {
+		if (!slog_str ||
+		    !(rdev->slog_name = dm_pool_strdup(mem, slog_str)))
+			return_0;
+
+		lvm_replicator_dev_add_slog(rdev, slog_lv);
+	}
+
+	dm_list_add(&rsite->rdevices, &rdev->list);// linked site list
+
+	return 1;
+}
+
+/* Import replicator segment */
+static int _replicator_dev_text_import(struct lv_segment *seg,
+				       const struct config_node *sn,
+				       struct dm_hash_table *pv_hash __attribute((unused)))
+{
+	const struct config_node *cn;
+	struct logical_volume *replicator;
+
+	if (!(cn = find_config_node(sn, "replicator")))
+		return SEG_LOG_ERROR("Replicator is missing for");
+
+	if (!cn->v || !cn->v->v.str)
+		return SEG_LOG_ERROR("Replicator must be a string for");
+
+	if (!(replicator = find_lv(seg->lv->vg, cn->v->v.str)))
+		return SEG_LOG_ERROR("Unknown replicator %s for", cn->v->v.str);
+
+	if (!lvm_replicator_add_dev(replicator, seg))
+		return_0;
+
+	log_very_verbose("replicator=%s", replicator->name);
+
+	// mandatory!!
+	if (!find_config_node(sn, "device_index"))
+		return SEG_LOG_ERROR("Missing device index for");
+
+	// read devices from sites
+	for (; sn; sn = sn->sib)
+		if (!(sn->v) && !_add_device(seg, sn->key, sn->child))
+			return 0;
+
+	if (seg->lv->rdevice)
+		seg->lv->rdevice->device_index = _get_config_uint64(sn, "device_index", 0);
+
+	seg->rlog_lv = NULL;
+	seg->lv->status |= REPLICATOR;
+
+	return 1;
+}
+
+/* Export replicator-dev segment */
+static int _replicator_dev_text_export(const struct lv_segment *seg,
+				       struct formatter *f)
+{
+	const struct replicator_site *rsite;
+	const struct replicator_device *rdev;
+
+	if (!seg->replicator || !seg->lv->rdevice)
+		return_0;
+
+	outf(f, "replicator = \"%s\"", seg->replicator->name);
+	outf(f, "device_index = %" PRId64, seg->lv->rdevice->device_index);
+
+	out_newline(f);
+
+	dm_list_iterate_items(rsite, &seg->replicator->rsites) {
+		dm_list_iterate_items(rdev, &rsite->rdevices) {
+			if (rdev->replicator_dev != seg)
+				continue;
+
+			outf(f, "%s {", rdev->rsite->name);
+
+			out_inc_indent(f);
+
+			outf(f, "logical_volume = \"%s\"",
+			     rdev->name ? rdev->name : rdev->lv->name);
+
+			if (rdev->slog)
+				outf(f, "sync_log = \"%s\"", rdev->slog->name);
+			else if (rdev->slog_name)
+				outf(f, "sync_log = \"%s\"", rdev->slog_name);
+
+			out_dec_indent(f);
+
+			outf(f, "}");
+		}
+	}
+
+	return 1;
+}
+
+#ifdef DEVMAPPER_SUPPORT
+/*
+ * Add target for passive site matching the device index
+ */
+static int _replicator_dev_add_target_line(struct dev_manager *dm,
+					   struct dm_pool *mem,
+					   struct cmd_context *cmd,
+					   void **target_state,
+					   struct lv_segment *seg,
+					   struct dm_tree_node *node,
+					   uint64_t len,
+					   uint32_t *pvmove_mirror_count)
+{
+	const char *replicator_dlid, *rdev_dlid, *slog_dlid;
+	const struct replicator_device *rdev, *rdev_search;
+	const struct replicator_site *rsite;
+	char *rdev_path;	/* needed for write */
+	uint32_t slog_size;
+	uint32_t slog_flags;
+
+	if (!lv_is_active_replicator_dev(seg->lv)) {
+		/* Create passive linear mapping */
+		log_very_verbose("Inactive replicator %s using %s.",
+				 seg->lv->name, seg->lv->rdevice->lv->name);
+		if (!dm_tree_node_add_linear_target(node, seg->lv->size))
+			return_0;
+		if (!(rdev_dlid = build_dlid(dm, seg->lv->rdevice->lv->lvid.s, NULL)))
+			return_0;
+		return dm_tree_node_add_target_area(node, NULL, rdev_dlid, 0);
+	} else if (seg->lv->rdevice->rsite->site_index) {
+		log_error("Active site with site_index != 0 (%s, %d)",
+			  seg->lv->rdevice->rsite->name,
+			  seg->lv->rdevice->rsite->site_index);
+		return 0; /* replicator without any active site */
+	}
+
+	/*
+	 * At this point all devices that have some connection with replicator
+	 * must be present in dm_tree
+	 */
+	if (!seg_is_replicator_dev(seg) ||
+	    !(replicator_dlid = build_dlid(dm, seg->replicator->lvid.s, NULL)))
+		return_0;
+
+	/* Select remote devices with the same device index */
+	dm_list_iterate_items(rsite, &seg->replicator->rsites) {
+		if (rsite->site_index == 0) {
+			/* local slink0 device */
+			rdev = seg->lv->rdevice;
+		} else {
+			rdev = NULL;
+			dm_list_iterate_items(rdev_search, &rsite->rdevices) {
+				if (rdev_search->replicator_dev == seg) {
+					rdev = rdev_search;
+					break;
+				}
+			}
+
+			if (!rdev) {
+                                log_error("Internal rdev list error");
+				return 0;
+			}
+		}
+
+		if (rdev->lv) {
+			if (!(rdev_dlid = build_dlid(dm, rdev->lv->lvid.s, NULL)))
+				return_0;
+		} else {
+			/* (?debug?) support remote device nodes */
+			if (!rdev->rsite->vg_name || !rdev->name)
+				return_0;
+
+			/* FIXME:
+			 * vg_read/_process_one_vg needs to be fixed to locate and lock remote vg
+			 * so we can use
+			 *   lv = find_lv(rdev->rsite->vg, rdev->name);
+			 *   if (!lv || !(rdev_dlid = build_dm_name(mem, rdev->rsite->vg, lv->lvid.s, NULL)))
+			 *       return_0;
+			 *
+                         * meanwhile use solution    vg_name + name
+			 */
+			if (!(rdev_path = dm_pool_alloc(mem, strlen(rdev->rsite->replicator->vg->cmd->dev_dir) +
+							strlen(rdev->rsite->vg_name) +
+							strlen(rdev->name) + 2)))
+				return_0;
+
+			sprintf(rdev_path, "%s%s/%s",
+				rdev->rsite->replicator->vg->cmd->dev_dir,
+				rdev->rsite->vg_name, rdev->name);
+			rdev_dlid = rdev_path;
+		}
+
+		slog_dlid = NULL;
+		/* using either disk or core (in memory) log */
+#if 0
+		/* HACK: avoid using slog device - currently kernel driver is broken */
+		slog_flags = DM_CORELOG | DM_FORCESYNC;
+		slog_size = 2048;
+#else
+		if (rdev->slog) {
+			slog_flags = DM_NOSYNC;
+			slog_size = rdev->slog->size;
+			if (!(slog_dlid = build_dlid(dm, rdev->slog->lvid.s, NULL)))
+				return_0;
+			slog_size = 2048; // FIXME: HACK
+		} else if (rdev->slog_name &&
+			   sscanf(rdev->slog_name, "%" PRIu32, &slog_size) == 1) {
+			slog_flags = DM_CORELOG | DM_FORCESYNC;
+			if (slog_size == 0) {
+				log_error("Failed to use empty corelog size in replicator '%s'.",
+					  rsite->replicator->name);
+				return 0;
+			}
+		} else  {
+			slog_flags = DM_CORELOG | DM_FORCESYNC;
+			slog_size = 0; // NOLOG
+		}
+
+#endif
+		if (!dm_tree_node_add_replicator_dev_target(node,
+							    seg->lv->size,
+							    replicator_dlid,
+							    seg->lv->rdevice->device_index,
+							    rdev_dlid,	/* rdev_uuid/path */
+							    rsite->site_index,
+							    slog_dlid,
+							    slog_flags,
+							    slog_size)) {
+			//if (seg->lv->rdevice->device_index == 0)
+			return_0;
+
+			/*
+			 * FIXME: add  'state = dropped'
+                         */
+
+			// CHECKME: is it fatal or just warning here ?? */
+			log_warn("Failed to add LV '%s' to replicator '%s'.",
+				 rdev->name, rsite->replicator->name);
+			return 1;
+		}
+	}
+
+	return 1;
+}
+
+/* FIXME write something useful for replicator here */
+static int _replicator_dev_target_percent(void **target_state,
+					  struct dm_pool *mem,
+					  struct cmd_context *cmd,
+					  struct lv_segment *seg,
+					  char *params,
+					  uint64_t *total_numerator,
+					  uint64_t *total_denominator)
+{
+	struct mirror_state *mirr_state;
+	uint64_t numerator, denominator;
+	unsigned mirror_count, m;
+	int used;
+	char *pos = params;
+
+	//if (!*target_state)
+	//	*target_state = _mirrored_init_target(mem, cmd);
+
+	mirr_state = *target_state;
+
+	/* Status line: <#mirrors> (maj:min)+ <synced>/<total_regions> */
+	log_debug("Replicator status: %s", params);
+
+	if (sscanf(pos, "%u %n", &mirror_count, &used) != 1) {
+		log_error("Failure parsing mirror status mirror count: %s.",
+			  params);
+		return 0;
+	}
+	pos += used;
+
+	for (m = 0; m < mirror_count; ++m) {
+		if (sscanf(pos, "%*x:%*x %n", &used) != 0) {
+			log_error("Failure parsing mirror status devices: %s.",
+				  params);
+			return 0;
+		}
+		pos += used;
+	}
+
+	if (sscanf(pos, "%" PRIu64 "/%" PRIu64 "%n", &numerator, &denominator,
+		   &used) != 2) {
+		log_error("Failure parsing replicator status fraction: %s.",
+			  params);
+		return 0;
+	}
+	pos += used;
+
+	*total_numerator += numerator;
+	*total_denominator += denominator;
+
+	if (seg)
+		seg->extents_copied = (uint32_t)(seg->area_len * numerator / denominator);
+
+	return 1;
+}
+
+/* Check for module presence */
+static int _replicator_dev_target_present(struct cmd_context *cmd,
+					  const struct lv_segment *seg __attribute((unused)),
+					  unsigned *attributes __attribute((unused)))
+{
+	static int _checked = 0;
+	static int _present = 0;
+
+	if (!_checked) {
+		_present = target_present(cmd, REPLICATOR_DEV_MODULE, 1);
+		_checked = 1;
+	}
+
+	return _present;
+}
+
+#endif
+
+static int _replicator_dev_modules_needed(struct dm_pool *mem,
+					  const struct lv_segment *seg __attribute((unused)),
+					  struct dm_list *modules)
+{
+	if (!str_list_add(mem, modules, REPLICATOR_DEV_MODULE))
+		return_0;
+
+	return 1;
+}
+
+static struct segtype_handler _replicator_dev_ops = {
+	.name = _replicator_name,
+	.display = _replicator_dev_display,
+	.text_import = _replicator_dev_text_import,
+	.text_export = _replicator_dev_text_export,
+#ifdef DEVMAPPER_SUPPORT
+	.add_target_line = _replicator_dev_add_target_line,
+	.target_percent = _replicator_dev_target_percent,
+	.target_present = _replicator_dev_target_present,
+#endif
+	.modules_needed = _replicator_dev_modules_needed,
+	.destroy = _replicator_destroy,
+};
+
+#ifdef REPLICATOR_INTERNAL
+int init_replicator_segtype(struct segtype_library *seglib)
+#else /* Shared */
+int init_multiple_segtype(struct segtype_library *seglib);
+int init_multiple_segtype(struct segtype_library *seglib)
+#endif
+{
+	struct segment_type *segtype;
+
+	if (!(segtype = dm_malloc(sizeof(*segtype))))
+		return_0;
+
+	segtype->ops = &_replicator_ops;
+	segtype->name = REPLICATOR_MODULE;
+	segtype->private = NULL;
+	segtype->flags = SEG_REPLICATOR;
+
+	if (!lvm_register_segtype(seglib, segtype))
+		return 0;
+
+	log_very_verbose("Initialised segtype: " REPLICATOR_MODULE);
+
+	if (!(segtype = dm_malloc(sizeof(*segtype))))
+		return_0;
+
+	segtype->ops = &_replicator_dev_ops;
+	segtype->name = REPLICATOR_DEV_MODULE;
+	segtype->private = NULL;
+	segtype->flags = SEG_REPLICATOR_DEV;
+
+	if (!lvm_register_segtype(seglib, segtype))
+		return 0;
+
+	log_very_verbose("Initialised segtype: " REPLICATOR_DEV_MODULE);
+
+	return 1;
+}
-- 
1.6.5.rc2


