From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  7 Jul 2010 14:34:52 +0200
Subject: [PATCH 18/22] Replicator: lvcreate implementation
In-Reply-To: <cover.1278505885.git.zkabelac@redhat.com>
References: <cover.1278505885.git.zkabelac@redhat.com>
Message-ID: <c45e975a1934b39f593740ddde5d37ac2fb2ea72.1278505885.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/commands.h |    9 ++++
 tools/lvcreate.c |  133 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 139 insertions(+), 3 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 2b34933..7966cff 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -165,6 +165,12 @@ xx(lvcreate,
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
@@ -203,6 +209,9 @@ xx(lvcreate,
    mirrorlog_ARG, mirrors_ARG, monitor_ARG, name_ARG, nosync_ARG, noudevsync_ARG,
    permission_ARG, persistent_ARG, readahead_ARG, regionsize_ARG, size_ARG,
    snapshot_ARG, stripes_ARG, stripesize_ARG, test_ARG, type_ARG,
+   replicator_ARG, replicatordev_ARG, replicatorlogtype_ARG,
+   remotevg_ARG, site_ARG, sitemode_ARG,
+   fallbehinddata_ARG, fallbehindios_ARG, fallbehindtimeout_ARG,
    virtualoriginsize_ARG, virtualsize_ARG, zero_ARG)
 
 xx(lvdisplay,
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 9e167aa..0a605ef 100644
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
 
@@ -315,7 +337,81 @@ static int _read_mirror_params(struct lvcreate_params *lp,
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
+	int changed;
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
+		return 0;
+	}
+
+	if (!strcmp("disk", replicatorsynclog))
+		lp->log_count = 1;
+	else if (!strcmp("core", replicatorsynclog))
+		lp->log_count = 0;
+	else {
+		log_error("Unknown replicatorsynclog type: %s", replicatorsynclog);
 		return 0;
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
+	if (arg_count(cmd, remotevg_ARG))
+		lp->rsite.vg_name = arg_str_value(cmd, remotevg_ARG, NULL);
+
+	if (arg_count(cmd, site_ARG))
+		lp->rsite.name = arg_str_value(cmd, site_ARG,
+					       DEFAULT_REPLICATOR_LOCAL_SITE_NAME);
+
+	lp->rsite.op_mode = DM_REPLICATOR_SYNC;
+	if (!get_replicator_site_params(cmd, &lp->rsite, &changed))
+		return_0;
 
 	return 1;
 }
@@ -327,6 +423,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 {
 	int contiguous;
 	unsigned pagesize;
+	int i;
 
 	memset(lp, 0, sizeof(*lp));
 	memset(lcp, 0, sizeof(*lcp));
@@ -346,6 +443,12 @@ static int _lvcreate_params(struct lvcreate_params *lp,
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
@@ -383,7 +486,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		}
 	}
 
-	if (lp->mirrors > 1) {
+	if (lp->mirrors > 1 || lp->replicator) {
 		if (lp->snapshot) {
 			log_error("mirrors and snapshots are currently "
 				  "incompatible");
@@ -409,6 +512,29 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		}
 	}
 
+	if (!lp->replicator) {
+		static const struct {
+			const char str[20]; // carefull
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
@@ -423,6 +549,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
 	    !_read_size_params(lp, lcp, cmd) ||
 	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
+	    !_read_replicator_params(lp, cmd) ||
 	    !_read_mirror_params(lp, cmd))
 		return_0;
 
-- 
1.7.1.1


