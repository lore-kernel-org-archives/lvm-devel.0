From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 29 Jun 2010 18:26:07 +0200
Subject: [PATCH 07/12] Replicator: add new options for replicator
In-Reply-To: <cover.1277828149.git.zkabelac@redhat.com>
References: <cover.1277828149.git.zkabelac@redhat.com>
Message-ID: <ee6e38c10d7bf375bdad0f7b74af0bf8e9438cb6.1277828149.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

New options for lvcreate:
replicator, replicatordev, replicatorlogtype, replicatorsynclog,
remotevg, site, sitemode

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/config/defaults.h            |    8 ++
 lib/metadata/metadata-exported.h |   46 +++++++++++--
 tools/args.h                     |   10 +++
 tools/commands.h                 |   15 ++++
 tools/lvcreate.c                 |  134 +++++++++++++++++++++++++++++++++++++-
 tools/lvmcmdline.c               |   10 +++
 tools/tools.h                    |    1 +
 7 files changed, 213 insertions(+), 11 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 0d8cb9c..644809d 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -48,6 +48,13 @@
 #define DEFAULT_DMEVENTD_MONITOR 1
 #define DEFAULT_BACKGROUND_POLLING 1
 
+#define DEFAULT_REPLICATOR_SYNCLOG "disk"
+#define DEFAULT_REPLICATOR_LOG_TYPE "ringbuffer"
+#define DEFAULT_REPLICATOR_LOCAL_SITE_NAME "local"
+#define DEFAULT_REPLICATOR_FALL_BEHIND_DATA 0
+#define DEFAULT_REPLICATOR_FALL_BEHIND_IOS 0
+#define DEFAULT_REPLICATOR_FALL_BEHIND_TIMEOUT 0
+
 #define DEFAULT_UMASK 0077
 
 #ifdef LVM1_FALLBACK
@@ -104,6 +111,7 @@
 
 #define DEFAULT_STRIPE_FILLER "error"
 #define DEFAULT_MIRROR_REGION_SIZE 512	/* KB */
+#define DEFAULT_REPLICATOR_REGION_SIZE 512	/* KB */
 #define DEFAULT_INTERVAL 15
 
 #ifdef READLINE_SUPPORT
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 26ba545..8b2dd66 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -74,6 +74,7 @@
 
 #define REPLICATOR		0x20000000U	/* LV -internal use only for replicator */
 #define REPLICATOR_LOG		0x40000000U	/* LV -internal use only for replicator-dev */
+#define REPLICATOR_NOTSYNCED   	0x80000000U	/* LV -internal use only for replicator */
 
 #define LVM_READ              	0x00000100U	/* LV VG */
 #define LVM_WRITE             	0x00000200U	/* LV VG */
@@ -349,7 +350,7 @@ struct replicator_device {
 	const char *name;		/* Device LV name */
 	struct logical_volume *lv;	/* LV from replicator site's VG */
 	struct logical_volume *slog;	/* Synclog lv from VG  */
-	const char *slog_name;		/* Debug - specify size of core synclog */
+	uint32_t slog_core;		/* Corelog size */
 };
 /* -- Replicator datatypes */
 
@@ -617,6 +618,8 @@ uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 struct lvcreate_params {
 	/* flags */
 	int snapshot; /* snap */
+	const char *replicator; /* replicator */
+	int replicator_dev; /* replicator-dev */
 	int zero; /* all */
 	int major; /* all */
 	int minor; /* all */
@@ -635,6 +638,9 @@ struct lvcreate_params {
 
 	uint32_t mirrors; /* mirror */
 
+	const char *rlog_type; /* replicator */
+	struct replicator_site rsite; /* replicator, use only parameters */
+
 	const struct segment_type *segtype; /* all */
 
 	/* size */
@@ -798,17 +804,22 @@ int collapse_mirrored_lv(struct logical_volume *lv);
 int shift_mirror_images(struct lv_segment *mirrored_seg, unsigned mimage);
 
 /* ++  metadata/replicator_manip.c */
-int replicator_add_replicator_dev(struct logical_volume *replicator_lv,
+int replicator_site_add_device(struct replicator_site *rsite,
+			       struct lv_segment *replicator_dev_seg,
+			       const char *name,
+			       struct logical_volume *rimage_lv,
+			       uint32_t slog_core,
+			       struct logical_volume *slog_lv,
+			       uint64_t device_index);
+int replicator_site_remove_device(struct replicator_device *rdev);
+int replicator_add_replicator_dev(struct logical_volume *replicator,
 				  struct lv_segment *rdev_seg);
 struct logical_volume *replicator_remove_replicator_dev(struct lv_segment *rdev_seg);
 int replicator_add_rlog(struct lv_segment *replicator_seg, struct logical_volume *rlog_lv);
 struct logical_volume *replicator_remove_rlog(struct lv_segment *replicator_seg);
-
-int replicator_dev_add_slog(struct replicator_device *rdev, struct logical_volume *slog_lv);
-struct logical_volume *replicator_dev_remove_slog(struct replicator_device *rdev);
-int replicator_dev_add_rimage(struct replicator_device *rdev, struct logical_volume *lv);
-struct logical_volume *replicator_dev_remove_rimage(struct replicator_device *rdev);
-
+struct replicator_site *replicator_add_site(struct logical_volume *replicator,
+					    const char *site_name);
+int replicator_remove_site(struct replicator_site *rsite);
 int lv_is_active_replicator_dev(const struct logical_volume *lv);
 int lv_is_replicator(const struct logical_volume *lv);
 int lv_is_replicator_dev(const struct logical_volume *lv);
@@ -816,6 +827,25 @@ int lv_is_rimage(const struct logical_volume *lv);
 int lv_is_rlog(const struct logical_volume *lv);
 int lv_is_slog(const struct logical_volume *lv);
 struct logical_volume *first_replicator_dev(const struct logical_volume *lv);
+int vg_prepare_replicator(struct volume_group *vg,
+			  const struct lvcreate_params *lp);
+int vg_add_replicator(struct logical_volume *replicator,
+		      const char *rlog_type,
+		      uint32_t region_size);
+int vg_remove_replicator(struct logical_volume *replicator);
+int lv_add_sync_log(struct logical_volume *replicator,
+		    unsigned site_index,
+		    uint64_t device_index,
+		    struct dm_list *allocatable_pvs,
+		    alloc_policy_t alloc);
+int lv_add_replicator_dev(struct logical_volume *replicator,
+			  struct logical_volume *lv);
+int lv_remove_replicator_dev(struct logical_volume *replicator_dev);
+int lv_add_replicator_site(struct logical_volume *replicator,
+			   const struct replicator_site *rsite);
+int lv_remove_replicator_site(struct logical_volume *replicator, const char *site_name);
+struct replicator_site *find_site_in_replicator(struct logical_volume *replicator,
+						const char *site_name);
 /* --  metadata/replicator_manip.c */
 struct cmd_vg *cmd_vg_add(struct dm_pool *mem, struct dm_list *cmd_vgs,
 			  const char *vg_name, const char *vgid,
diff --git a/tools/args.h b/tools/args.h
index ebce252..eab9b51 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -69,6 +69,16 @@ arg(noudevsync_ARG, '\0', "noudevsync", NULL, 0)
 arg(poll_ARG, '\0', "poll", yes_no_arg, 0)
 arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)
 arg(sysinit_ARG, '\0', "sysinit", NULL, 0)
+arg(replicator_ARG, '\0', "replicator", string_arg, 0)
+arg(replicatordev_ARG, '\0', "replicatordev", NULL, 0)
+arg(replicatorsynclog_ARG, '\0', "replicatorsynclog", string_arg, 0)
+arg(replicatorlogtype_ARG, '\0', "replicatorlogtype", string_arg, 0)
+arg(site_ARG, '\0', "site", site_arg, 0)
+arg(fallbehinddata_ARG, '\0', "fallbehinddata", size_mb_arg, 0)
+arg(fallbehindios_ARG, '\0', "fallbehindios", int_arg, 0)
+arg(fallbehindtimeout_ARG, '\0', "fallbehindtimeout", int_arg, 0)
+arg(sitemode_ARG, '\0', "sitemode", string_arg, 0)
+arg(remotevg_ARG, '\0', "remotevg", string_arg, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index aa012a7..a300774 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -118,6 +118,12 @@ xx(lvconvert,
    "\tLogicalVolume[Path] [SplittablePhysicalVolume[Path]...]\n\n"
 
    "lvconvert "
+   "--replicator\n"
+   "\t[-d|--debug]\n"
+   "\t[-h|-?|--help]\n"
+   "\t[-v|--verbose]\n"
+
+   "lvconvert "
    "[-s|--snapshot]\n"
    "\t[-c|--chunksize]\n"
    "\t[-d|--debug]\n"
@@ -165,6 +171,12 @@ xx(lvcreate,
    "\t[-p|--permission {r|rw}]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
+   "\t[--replicator [ReplicatorName] [--replicatorlogtype ringbuffer]\n"
+   "\t[{--replicatorsynclog {disk|core}|--corelog}]\n"
+   "\t[--site LocalSiteName [--sitemode {sync|warn|stall|drop|fail}]\n"
+   "\t  [--remotevg RemoteVGName] [{--fallbehinddata Size[bBsSkKmMgG]|\n"
+   "\t    --fallbehindios IOCount|--fallbehindtimeout Secs}]]\n"
+   "\t[--replicatordev]\n"
    "\t[-t|--test]\n"
    "\t[--type VolumeType]\n"
    "\t[-v|--verbose]\n"
@@ -203,6 +215,9 @@ xx(lvcreate,
    mirrorlog_ARG, mirrors_ARG, monitor_ARG, name_ARG, nosync_ARG, noudevsync_ARG,
    permission_ARG, persistent_ARG, readahead_ARG, regionsize_ARG, size_ARG,
    snapshot_ARG, stripes_ARG, stripesize_ARG, test_ARG, type_ARG,
+   replicator_ARG, replicatordev_ARG, replicatorlogtype_ARG,
+   remotevg_ARG, site_ARG, sitemode_ARG,
+   fallbehinddata_ARG, fallbehindios_ARG, fallbehindtimeout_ARG,
    virtualoriginsize_ARG, virtualsize_ARG, zero_ARG)
 
 xx(lvdisplay,
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 9e167aa..8cb1e24 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -60,7 +60,10 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 		 * environment.
 		 */
 		if (!argc) {
-			if (!(lp->vg_name = extract_vgname(cmd, lp->lv_name))) {
+			if (!(lp->vg_name = extract_vgname(cmd, lp->lv_name)) &&
+			    /* try to detect vg name from --replicator arg */
+			    (lp->replicator &&
+			     !(lp->vg_name = extract_vgname(cmd, lp->replicator)))) {
 				log_error("Please provide a volume group name");
 				return 0;
 			}
@@ -73,6 +76,11 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 				return 0;
 			}
 
+			if (!lp->lv_name &&
+			    !lp->replicator_dev &&
+			    lp->replicator &&
+			    strlen(lp->replicator))
+				lp->lv_name = lp->replicator;
 			/*
 			 * Ensure lv_name doesn't contain a
 			 * different VG.
@@ -116,6 +124,20 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 		}
 	}
 
+	if (lp->replicator) {
+		if ((ptr = strrchr(lp->replicator, '/')))
+			lp->replicator = ptr + 1;
+
+		if (!apply_lvname_restrictions(lp->replicator))
+			return_0;
+
+		if (!validate_name(lp->replicator)) {
+			log_error("Logical volume name \"%s\" is invalid",
+				  lp->replicator);
+			return 0;
+		}
+	}
+
 	return 1;
 }
 
@@ -315,7 +337,82 @@ static int _read_mirror_params(struct lvcreate_params *lp,
 	}
 
 	if (!_validate_mirror_params(cmd, lp))
+		return_0;
+
+	return 1;
+}
+
+static int _read_replicator_params(struct lvcreate_params *lp,
+				   struct cmd_context *cmd)
+{
+	int region_size;
+	const char *replicatorsynclog;
+	int corelog = arg_count(cmd, corelog_ARG);
+
+	if (arg_count(cmd, sitemode_ARG)) {
+		log_error("FIXME: Sorry, sitemode parameter is not yet supported.");
+		return 0;
+	}
+
+	replicatorsynclog = arg_str_value(cmd, replicatorsynclog_ARG,
+					  corelog ? "core" : DEFAULT_REPLICATOR_SYNCLOG);
+
+	if (strcmp("core", replicatorsynclog) && corelog) {
+		log_error("Please use only one of --replicatorlog or --corelog");
 		return 0;
+	}
+
+	if (!strcmp("disk", replicatorsynclog))
+		lp->log_count = 1;
+	else if (!strcmp("core", replicatorsynclog))
+		lp->log_count = 0;
+	else {
+		log_error("Unknown replicatorsynclog type: %s", replicatorsynclog);
+		return 0;
+	}
+
+	log_verbose("Setting sync logging type to %s", replicatorsynclog);
+	if (arg_count(cmd, regionsize_ARG)) {
+		if (arg_sign_value(cmd, regionsize_ARG, 0) == SIGN_MINUS) {
+			log_error("Negative regionsize is invalid.");
+			return 0;
+		}
+		lp->region_size = arg_uint_value(cmd, regionsize_ARG, 0);
+	} else {
+		region_size = 2 * find_config_tree_int(cmd,
+						       "activation/replicator_region_size",
+						       DEFAULT_REPLICATOR_REGION_SIZE);
+		if (region_size < 0) {
+			log_error("Negative replicator_region_size in configuration "
+				  "file is invalid.");
+			return 0;
+		}
+		lp->region_size = region_size;
+	}
+
+	if (!_validate_mirror_params(cmd, lp)) /* reuse for mirror's region_size */
+		return 0;
+
+	lp->rlog_type = arg_str_value(cmd, replicatorlogtype_ARG,
+				      DEFAULT_REPLICATOR_LOG_TYPE);
+
+	if (strcmp(lp->rlog_type, DEFAULT_REPLICATOR_LOG_TYPE)) {
+		log_error("Unsupported replicator log type %s", lp->rlog_type);
+		return 0;
+	}
+
+	lp->rsite.fall_behind_data = arg_uint64_value(cmd, fallbehinddata_ARG,
+						      DEFAULT_REPLICATOR_FALL_BEHIND_DATA);
+	lp->rsite.fall_behind_ios = arg_uint_value(cmd, fallbehindios_ARG,
+						   DEFAULT_REPLICATOR_FALL_BEHIND_IOS);
+	lp->rsite.fall_behind_timeout = arg_uint_value(cmd, fallbehindtimeout_ARG,
+						       DEFAULT_REPLICATOR_FALL_BEHIND_TIMEOUT);
+
+	if (arg_count(cmd, site_ARG))
+		lp->rsite.name = arg_str_value(cmd, site_ARG,
+					       DEFAULT_REPLICATOR_LOCAL_SITE_NAME);
+	if (arg_count(cmd, remotevg_ARG))
+		lp->rsite.vg_name = arg_str_value(cmd, remotevg_ARG, NULL);
 
 	return 1;
 }
@@ -327,6 +424,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 {
 	int contiguous;
 	unsigned pagesize;
+	int i;
 
 	memset(lp, 0, sizeof(*lp));
 	memset(lcp, 0, sizeof(*lcp));
@@ -346,6 +444,12 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	if (seg_is_mirrored(lp))
 		lp->mirrors = 2;
 
+	if (seg_is_replicator(lp) || arg_count(cmd, replicator_ARG))
+		lp->replicator = arg_str_value(cmd, replicator_ARG, "");
+
+	if (seg_is_replicator_dev(lp) || arg_count(cmd, replicatordev_ARG))
+		lp->replicator_dev = 1;
+
 	if (arg_count(cmd, mirrors_ARG)) {
 		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0) + 1;
 		if (lp->mirrors == 1)
@@ -383,7 +487,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		}
 	}
 
-	if (lp->mirrors > 1) {
+	if (lp->mirrors > 1 || lp->replicator) {
 		if (lp->snapshot) {
 			log_error("mirrors and snapshots are currently "
 				  "incompatible");
@@ -409,6 +513,29 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		}
 	}
 
+	if (!lp->replicator) {
+		static const struct {
+			const char *str;
+			int argname;
+		} repargs[] = {
+			{ "fallbehinddata", fallbehinddata_ARG },
+			{ "fallbehindios", fallbehindios_ARG },
+			{ "fallbehindtimeout", fallbehindtimeout_ARG },
+			{ "remotevg", remotevg_ARG },
+			{ "replicatorlogtype", replicatorlogtype_ARG },
+			{ "replicatorsynclog", replicatorsynclog_ARG },
+			{ "site", site_ARG },
+			{ "sitemode", sitemode_ARG }
+		};
+
+		for (i = 0; i < sizeof(repargs)/sizeof(repargs[0]); ++i)
+			if (arg_count(cmd, repargs[i].argname)) {
+				log_error("--%s is only available "
+					  "with replicators.", repargs[i].str);
+				return 0;
+			}
+	}
+
 	if (activation() && lp->segtype->ops->target_present &&
 	    !lp->segtype->ops->target_present(cmd, NULL, NULL)) {
 		log_error("%s: Required device-mapper target(s) not "
@@ -423,6 +550,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
 	    !_read_size_params(lp, lcp, cmd) ||
 	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
+	    !_read_replicator_params(lp, cmd) ||
 	    !_read_mirror_params(lp, cmd))
 		return_0;
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 4652888..f4f9d86 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -473,6 +473,16 @@ int readahead_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
 	return 1;
 }
 
+int site_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
+{
+	if (!validate_name(a->value)) {
+		log_error("Invalid site name.");
+		return 0;
+	}
+
+	return 1;
+}
+
 /*
  * Non-zero, positive integer, "all", or "unmanaged"
  */
diff --git a/tools/tools.h b/tools/tools.h
index a09fa8e..c615b09 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -152,6 +152,7 @@ int units_arg(struct cmd_context *cmd, struct arg *a);
 int segtype_arg(struct cmd_context *cmd, struct arg *a);
 int alloc_arg(struct cmd_context *cmd, struct arg *a);
 int readahead_arg(struct cmd_context *cmd, struct arg *a);
+int site_arg(struct cmd_context *cmd, struct arg *a);
 int vgmetadatacopies_arg(struct cmd_context *cmd __attribute((unused)),
 			 struct arg *a);
 
-- 
1.7.1


