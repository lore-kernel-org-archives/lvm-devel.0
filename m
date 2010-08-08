From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:57:32 +0200
Subject: [PATCH 20/25] Replicator: lvcreate implementation
In-Reply-To: <cover.1281256234.git.zkabelac@redhat.com>
References: <cover.1281256234.git.zkabelac@redhat.com>
Message-ID: <5a18a3dc43cd9e3429e0bd246ed51b0a19dfe0e3.1281256235.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/commands.h |   11 ++++-
 tools/lvcreate.c |  138 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 145 insertions(+), 4 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index d9e13f4..595da54 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -165,6 +165,12 @@ xx(lvcreate,
    "\t[-p|--permission {r|rw}]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
+   "\t[--replicator [ReplicatorName] [--replicatorlogtype ringbuffer]\n"
+   "\t[{--replicatorsynclog {disk|core}|--corelog}]\n"
+   "\t[--site LocalSiteName [--sitepolicy {sync|warn|stall|drop|fail}]\n"
+   "\t  [--remotevg RemoteVGName] [{--fallbehindsize Size[bBsSkKmMgG]|\n"
+   "\t    --fallbehindios IOCount|--fallbehindtimeout Secs}]]\n"
+   "\t[--replicatordev]\n"
    "\t[-t|--test]\n"
    "\t[--type VolumeType]\n"
    "\t[-v|--verbose]\n"
@@ -203,6 +209,9 @@ xx(lvcreate,
    mirrorlog_ARG, mirrors_ARG, monitor_ARG, name_ARG, nosync_ARG, noudevsync_ARG,
    permission_ARG, persistent_ARG, readahead_ARG, regionsize_ARG, size_ARG,
    snapshot_ARG, stripes_ARG, stripesize_ARG, test_ARG, type_ARG,
+   fallbehindios_ARG, fallbehindsize_ARG, fallbehindtimeout_ARG,
+   remotevg_ARG, replicated_ARG, replicator_ARG, replicatorlogtype_ARG,
+   site_ARG, sitepolicy_ARG,
    virtualoriginsize_ARG, virtualsize_ARG, zero_ARG)
 
 xx(lvdisplay,
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index de5b59c..d89678f 100644
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
@@ -64,9 +64,33 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 				log_error("Please provide a volume group name");
 				return 0;
 			}
-
 		} else {
 			vg_name = skip_dev_dir(cmd, argv[0], NULL);
+			if (lp->replicator || lp->replicated) {
+				/*
+				 * support with following combinations
+				 *   --replicator -n lv ... vg
+				 *   --replicator ... vg/rep_lv
+				 *   --site site --replicator ... vg/rep_lv
+				 *   --replicated -n lv --replicator ... vg/rep_lv
+				 */
+				if (!(ptr = strrchr(vg_name, '/'))) {
+					if (!lp->lv_name || lp->replicated) {
+						log_error("Replicator logical volume name "
+							  "expected with volume group name.");
+						return 0;
+					}
+				} else {
+					ptr[0] = '\0';
+					lp->replicator = ptr + 1;
+				}
+
+				if (!lp->lv_name &&
+				    !lp->replicated &&
+				    lp->replicator[0])
+					lp->lv_name = lp->replicator;
+			}
+
 			if (strrchr(vg_name, '/')) {
 				log_error("Volume group name expected "
 					  "(no slash)");
@@ -311,7 +335,84 @@ static int _read_mirror_params(struct lvcreate_params *lp,
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
+	if (arg_count(cmd, sitepolicy_ARG)) {
+		log_error("FIXME: Sorry, site policy parameter is not yet supported.");
 		return 0;
+	}
+
+	replicatorsynclog = arg_str_value(cmd, replicatorsynclog_ARG,
+					  corelog ? "core" : DEFAULT_REPLICATOR_SYNCLOG);
+
+	if (strcmp("core", replicatorsynclog) && corelog) {
+		log_error("Please use only one of --replicatorlog or --corelog.");
+		return 0;
+	}
+
+	if (!strcmp("disk", replicatorsynclog))
+		lp->log_count = 1;
+	else if (!strcmp("core", replicatorsynclog))
+		lp->log_count = 0;
+	else {
+		log_error("Unknown replicatorsynclog type: %s.", replicatorsynclog);
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
+		log_error("Unsupported replicator log type %s.", lp->rlog_type);
+		return 0;
+	}
+
+	if (arg_count(cmd, remotevg_ARG))
+		lp->rsite.vg_name = arg_str_value(cmd, remotevg_ARG, NULL);
+
+	if (arg_count(cmd, site_ARG)) {
+		lp->rsite.name = arg_str_value(cmd, site_ARG,
+					       DEFAULT_REPLICATOR_LOCAL_SITE_NAME);
+		lp->lv_name = NULL;  /* cannot create LV when creating site */
+		/* FIXME: improve lv_create_single to handle --site case */
+	}
+
+	lp->rsite.policy = DM_REPLICATOR_SYNC;
+	if (!get_replicator_site_params(cmd, &lp->rsite, &changed))
+		return_0;
 
 	return 1;
 }
@@ -323,6 +424,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 {
 	int contiguous;
 	unsigned pagesize;
+	int i;
 
 	memset(lp, 0, sizeof(*lp));
 	memset(lcp, 0, sizeof(*lcp));
@@ -342,6 +444,12 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	if (seg_is_mirrored(lp))
 		lp->mirrors = 2;
 
+	if (seg_is_replicator(lp) || arg_count(cmd, replicator_ARG))
+		lp->replicator = ""; /* later set replicator name */
+
+	if (seg_is_replicated(lp) || arg_count(cmd, replicated_ARG))
+		lp->replicated = 1;
+
 	if (arg_count(cmd, mirrors_ARG)) {
 		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0) + 1;
 		if (lp->mirrors == 1)
@@ -379,7 +487,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		}
 	}
 
-	if (lp->mirrors > 1) {
+	if (lp->mirrors > 1 || lp->replicator) {
 		if (lp->snapshot) {
 			log_error("mirrors and snapshots are currently "
 				  "incompatible");
@@ -405,6 +513,29 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		}
 	}
 
+	if (!lp->replicator) {
+		static const struct {
+			const char str[20]; // carefull
+			int argname;
+		} repargs[] = {
+			{ "fallbehindsize", fallbehindsize_ARG },
+			{ "fallbehindios", fallbehindios_ARG },
+			{ "fallbehindtimeout", fallbehindtimeout_ARG },
+			{ "remotevg", remotevg_ARG },
+			{ "replicatorlogtype", replicatorlogtype_ARG },
+			{ "replicatorsynclog", replicatorsynclog_ARG },
+			{ "site", site_ARG },
+			{ "sitepolicy", sitepolicy_ARG }
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
@@ -419,6 +550,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
 	    !_read_size_params(lp, lcp, cmd) ||
 	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
+	    !_read_replicator_params(lp, cmd) ||
 	    !_read_mirror_params(lp, cmd))
 		return_0;
 
-- 
1.7.2.1


