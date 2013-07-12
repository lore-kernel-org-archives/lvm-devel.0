From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 12 Jul 2013 19:39:02 +0000 (UTC)
Subject: master - activation: add support for skipping activation of selected LVs
Message-ID: <20130712193902.A334460DEE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7dc8c84b18cbd71f01ce6350759adbca28df5f9b
Commit:        7dc8c84b18cbd71f01ce6350759adbca28df5f9b
Parent:        4d19fa9582a44a71a53647d6a7c6026955e805c7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 10 14:06:50 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 12 20:39:07 2013 +0200

activation: add support for skipping activation of selected LVs

Also add -k/--setactivationskip y/n and -K/--ignoreactivationskip
options to lvcreate.

The --setactivationskip y sets the flag in metadata for an LV to
skip the LV during activation. Also, the newly created LV is not
activated.

Thin snapsots have this flag set automatically if not specified
directly by the --setactivationskip y/n option.

The --ignoreactivationskip overrides the activation skip flag set
in metadata for an LV (just for the run of the command - the flag
is not changed in metadata!)

A few examples for the lvcreate with the new options:

  (non-thin snap LV => skip flag not set in MDA + LV activated)
  raw/~ $ lvcreate -l1 vg
    Logical volume "lvol0" created
  raw/~ $ lvs -o lv_name,attr vg/lvol0
    LV    Attr
    lvol0 -wi-a----

  (non-thin snap LV + -ky => skip flag set in MDA + LV not activated)
  raw/~ $ lvcreate -l1 -ky vg
    Logical volume "lvol1" created
  raw/~ $ lvs -o lv_name,attr vg/lvol1
    LV    Attr
    lvol1 -wi------

  (non-thin snap LV + -ky + -K => skip flag set in MDA + LV activated)
  raw/~ $ lvcreate -l1 -ky -K vg
    Logical volume "lvol2" created
  raw/~ $ lvs -o lv_name,attr vg/lvol2
    LV    Attr
    lvol2 -wi-a----

  (thin snap LV => skip flag set in MDA (default behaviour) + LV not activated)
  raw/~ $ lvcreate -L100M -T vg/pool -V 1T -n thin_lv
    Logical volume "thin_lv" created
  raw/~ $ lvcreate -s vg/thin_lv -n thin_snap
    Logical volume "thin_snap" created
  raw/~ $ lvs -o name,attr vg
    LV        Attr
    pool      twi-a-tz-
    thin_lv   Vwi-a-tz-
    thin_snap Vwi---tz-

  (thin snap LV + -K => skip flag set in MDA (default behaviour) + LV activated)
  raw/~ $ lvcreate -s vg/thin_lv -n thin_snap -K
    Logical volume "thin_snap" created
  raw/~ $ lvs -o name,attr vg/thin_lv
    LV      Attr
    thin_lv Vwi-a-tz-

  (thins snap LV + -kn => no skip flag in MDA (default behaviour overridden) + LV activated)
  [0] raw/~ # lvcreate -s vg/thin_lv -n thin_snap -kn
    Logical volume "thin_snap" created
  [0] raw/~ # lvs -o name,attr vg/thin_snap
    LV        Attr
    thin_snap Vwi-a-tz-
---
 lib/format_text/flags.c          |    1 +
 lib/metadata/lv_manip.c          |   54 ++++++++++++++++++++++++++++++++++++++
 lib/metadata/metadata-exported.h |   17 ++++++++++++
 man/lvcreate.8.in                |   16 +++++++++++
 tools/args.h                     |    2 +
 tools/commands.h                 |   13 ++++++---
 tools/lvcreate.c                 |   17 ++++++++++++
 7 files changed, 116 insertions(+), 4 deletions(-)

diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index cbccdfd..66dd86b 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -60,6 +60,7 @@ static const struct flag _lv_flags[] = {
 	{LV_NOTSYNCED, "NOTSYNCED", STATUS_FLAG},
 	{LV_REBUILD, "REBUILD", STATUS_FLAG},
 	{LV_WRITEMOSTLY, "WRITEMOSTLY", STATUS_FLAG},
+	{LV_ACTIVATION_SKIP, "ACTIVATION_SKIP", COMPATIBLE_FLAG},
 	{RAID, NULL, 0},
 	{RAID_META, NULL, 0},
 	{RAID_IMAGE, NULL, 0},
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 0941964..1dc1529 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5277,6 +5277,51 @@ static struct logical_volume *_create_virtual_origin(struct cmd_context *cmd,
 	return lv;
 }
 
+/*
+ * Automatically set ACTIVATION_SKIP flag for the LV supplied - this
+ * is default behaviour. If override_default is set, then override
+ * the default behaviour and add/clear the flag based on 'add_skip' arg
+ * supplied instead.
+ */
+void lv_set_activation_skip(struct logical_volume *lv, int override_default,
+			    int add_skip)
+{
+	int skip;
+
+	/* override default behaviour */
+	if (override_default)
+		skip = add_skip;
+	/* default behaviour */
+	else if (lv_is_thin_volume(lv) && first_seg(lv)->origin)
+		skip = 1; /* skip activation for thin snapshots by default */
+	else
+		skip = 0;
+
+	if (skip)
+		lv->status |= LV_ACTIVATION_SKIP;
+	else
+		lv->status &= ~LV_ACTIVATION_SKIP;
+}
+
+/*
+ * Get indication whether the LV should be skipped during activation
+ * based on the ACTIVATION_SKIP flag (deactivation is never skipped!).
+ * If 'override_lv_skip_flag' is set, then override it based on the value
+ * of the 'skip' arg supplied instead.
+ */
+int lv_activation_skip(struct logical_volume *lv, activation_change_t activate,
+		      int override_lv_skip_flag, int skip)
+{
+	/* Do not skip deactivation! */
+	if ((activate == CHANGE_AN) || (activate == CHANGE_ALN))
+		return 0;
+
+	if (override_lv_skip_flag)
+		return skip;
+
+	return (lv->status & LV_ACTIVATION_SKIP) ? 1 : 0;
+}
+
 /* Thin notes:
  * If lp->thin OR lp->activate is AY*, activate the pool if not already active.
  * If lp->thin, create thin LV within the pool - as a snapshot if lp->snapshot.
@@ -5638,6 +5683,9 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 		}
 	}
 
+	lv_set_activation_skip(lv, lp->activation_skip & ACTIVATION_SKIP_SET,
+			       lp->activation_skip & ACTIVATION_SKIP_SET_ENABLED);
+
 	/* store vg on disk(s) */
 	if (!vg_write(vg) || !vg_commit(vg))
 		return_NULL;
@@ -5658,6 +5706,12 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 		goto out;
 	}
 
+	if (lv_activation_skip(lv, lp->activate, lp->activation_skip & ACTIVATION_SKIP_IGNORE, 0)) {
+		log_verbose("ACTIVATION_SKIP flag set for LV %s/%s, skipping activation.",
+			    lv->vg->name, lv->name);
+		lp->activate = CHANGE_AN;
+	}
+
 	if (seg_is_thin(lp)) {
 		/* For snapshot, suspend active thin origin first */
 		if (org && lv_is_active(org) && lv_is_thin_volume(org)) {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index a8e1a29..b571847 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -100,6 +100,8 @@
 
 #define LV_WRITEMOSTLY		UINT64_C(0x0000010000000000)	/* LV (RAID1) */
 
+#define LV_ACTIVATION_SKIP	UINT64_C(0x0000020000000000)	/* LV */
+
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
 #define FMT_MDAS		0x00000002U	/* Proper metadata areas? */
@@ -698,6 +700,10 @@ struct lvcreate_params {
 	int minor; /* all */
 	int log_count; /* mirror */
 	int nosync; /* mirror */
+#define ACTIVATION_SKIP_SET		0x01 /* request to set LV activation skip flag state */
+#define ACTIVATION_SKIP_SET_ENABLED	0x02 /* set the LV activation skip flag state to 'enabled' */
+#define ACTIVATION_SKIP_IGNORE		0x04 /* request to ignore LV activation skip flag (if any) */
+	int activation_skip; /* activation skip flags */
 	activation_change_t activate; /* non-snapshot, non-mirror */
 	thin_discards_t discards;     /* thin */
 
@@ -746,6 +752,17 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
 					struct lvcreate_params *lp);
 
 /*
+ * The activation can be skipped for selected LVs. Some LVs are skipped
+ * by default (e.g. thin snapshots), others can be skipped on demand by
+ * overriding the default behaviour. The flag that causes the activation
+ * skip on next activations is stored directly in metadata for each LV
+ * as ACTIVATION_SKIP flag.
+ */
+void lv_set_activation_skip(struct logical_volume *lv, int override_default, int add_skip_flag);
+int lv_activation_skip(struct logical_volume *lv, activation_change_t activate,
+		       int override_lv_skip_flag, int skip);
+
+/*
  * Functions for layer manipulation
  */
 int insert_layer_for_segments_on_pv(struct cmd_context *cmd,
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index ac5cf65..fd36e90 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -9,6 +9,9 @@ lvcreate \- create a logical volume in an existing volume group
 .IR AllocationPolicy ]
 .RB [ \-a | \-\-activate
 .RI [ a | e | l ]{ y | n }]
+.RB [ \-k | \-\-setactivationskip
+.RI { y | n }]
+.RB [ \-K | \-\-ignoreactivationskip ]
 .RB [ \-A | \-\-autobackup
 .RI { y | n }]
 .RB [ \-C | \-\-contiguous
@@ -136,6 +139,19 @@ and it can't be overridden. If the clustered locking is enabled,
 .IR \fB\-a { a | l } y
 will activate only on the local node.
 .TP
+.IR \fB\-k ", " \fB\-\-setactivationskip " " { y | n }
+Controls whether Logical Volumes are persistently flagged to be skipped during
+activation. By default, thin snapshot volumes are flagged for activation skip.
+To activate such volumes, an extra \fB\-K/\-\-ignoreactivationskip\fP option must
+be used. The flag is not applied during deactivation.
+Use \fBlvchange \-k/\-\-setactivationskip {y | n}\fP command to attach or
+detach the flag for existing volumes. To see whether the flag is attached,
+use \fBlvs\fP command where the state of the flag is reported within
+\fBlv_attr\fP bits.
+.TP
+.IR \fB\-K ", " \fB\-\-ignoreactivationskip
+Ignore the flag to skip Logical Volumes during activation.
+.TP
 .BR \-c ", " \-\-chunksize " " \fIChunkSize [ \fIbBsSkKmMgG ]
 Gives the size of chunk for snapshot and thin pool logical volumes.
 Default unit is in kilobytes.
diff --git a/tools/args.h b/tools/args.h
index ee95ad8..cde0f91 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -136,6 +136,8 @@ arg(logicalextent_ARG, 'L', "logicalextent", int_arg_with_sign, 0)
 arg(persistent_ARG, 'M', "persistent", yes_no_arg, 0)
 arg(merge_ARG, '\0', "merge", NULL, 0)
 arg(major_ARG, 'j', "major", int_arg, ARG_GROUPABLE)
+arg(setactivationskip_ARG, 'k', "setactivationskip", yes_no_arg, 0)
+arg(ignoreactivationskip_ARG, 'K', "ignoreactivationskip", NULL, 0)
 arg(mirrors_ARG, 'm', "mirrors", int_arg_with_sign, 0)
 arg(metadatatype_ARG, 'M', "metadatatype", metadatatype_arg, 0)
 arg(maps_ARG, 'm', "maps", NULL, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 98746b0..3d076c9 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -195,6 +195,8 @@ xx(lvcreate,
    "\t[--ignoremonitoring]\n"
    "\t[--monitor {y|n}]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
+   "\t[-k|--setactivationskip {y|n}]\n"
+   "\t[-K|--ignoreactivationskip] \n"
    "\t{-l|--extents LogicalExtentsNumber[%{VG|PVS|FREE}] |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
@@ -233,6 +235,8 @@ xx(lvcreate,
    "\t[--ignoremonitoring]\n"
    "\t[--monitor {y|n}]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
+   "\t[-k|--activationskip {y|n}]\n"
+   "\t[-K|--ignoreactivationskip] \n"
    "\t{-l|--extents LogicalExtentsNumber[%{VG|FREE|ORIGIN}] |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[--poolmetadatasize MetadataVolumeSize[bBsSkKmMgG]]\n"
@@ -252,10 +256,11 @@ xx(lvcreate,
    chunksize_ARG, contiguous_ARG, corelog_ARG, discards_ARG, extents_ARG,
    ignoremonitoring_ARG, major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG,
    monitor_ARG, minrecoveryrate_ARG, maxrecoveryrate_ARG, name_ARG, nosync_ARG,
-   noudevsync_ARG, permission_ARG,
-   persistent_ARG, readahead_ARG, regionsize_ARG, size_ARG, snapshot_ARG,
-   stripes_ARG, stripesize_ARG, test_ARG, thin_ARG, thinpool_ARG, type_ARG,
-   virtualoriginsize_ARG, poolmetadatasize_ARG, virtualsize_ARG, zero_ARG)
+   noudevsync_ARG, ignoreactivationskip_ARG, setactivationskip_ARG,
+   permission_ARG, persistent_ARG, readahead_ARG, regionsize_ARG, size_ARG,
+   snapshot_ARG, stripes_ARG, stripesize_ARG, test_ARG, thin_ARG, thinpool_ARG,
+   type_ARG, virtualoriginsize_ARG, poolmetadatasize_ARG, virtualsize_ARG,
+   zero_ARG)
 
 xx(lvdisplay,
    "Display information about a logical volume",
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 698d72f..f69c084 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -691,6 +691,23 @@ static int _read_activation_params(struct lvcreate_params *lp, struct cmd_contex
 		return 0;
 	}
 
+	if (arg_count(cmd, setactivationskip_ARG)) {
+		lp->activation_skip |= ACTIVATION_SKIP_SET;
+		if (arg_int_value(cmd, setactivationskip_ARG, 0))
+			lp->activation_skip |= ACTIVATION_SKIP_SET_ENABLED;
+	}
+
+	if (arg_count(cmd, ignoreactivationskip_ARG))
+		lp->activation_skip |= ACTIVATION_SKIP_IGNORE;
+
+	if (lp->zero && (lp->activation_skip & ACTIVATION_SKIP_SET_ENABLED)
+	    && !(lp->activation_skip & ACTIVATION_SKIP_IGNORE)) {
+		log_error("--setactivationskip y requires either --zero n "
+			  "or --ignoreactivationskip");
+		return 0;
+	}
+
+
 	return 1;
 }
 


