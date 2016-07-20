From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Wed, 20 Jul 2016 15:21:01 +0000 (UTC)
Subject: master - lvcreate: raid0 needs default number of stripes
Message-ID: <20160720152101.F36A8605B2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7eb79091937d01eec51fc6a034879a6fe607231d
Commit:        7eb79091937d01eec51fc6a034879a6fe607231d
Parent:        19e652b182099ca06c678394eccd1988967dacf9
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Jul 20 17:20:15 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Jul 20 17:20:15 2016 +0200

lvcreate: raid0 needs default number of stripes

Commit 3928c96a37941d765bf467d82502cd2aec7fd809 introduced
new defaults for raid number of stripes, which may cause
backwards compatibility issues with customer scripts.

Adding configurable option 'raid_stripe_all_devices' defaulting
to '0' (i.e. off = new behaviour) to select the old behaviour
of using all PVs in the VG or those provided on the command line.

In case any scripts rely on the old behaviour, just set
'raid_strip_all_devices = 1'.

- resolves rhbz1354650
---
 conf/example.conf.in         |    7 ++
 lib/config/config_settings.h |    5 ++
 lib/config/defaults.h        |    1 +
 tools/lvcreate.c             |  126 ++++++++++++++++++++++++-----------------
 4 files changed, 87 insertions(+), 52 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index f7cebf9..8b79d7d 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -472,6 +472,13 @@ allocation {
 	# Default physical extent size in KiB to use for new VGs.
 	# This configuration option has an automatic default value.
 	# physical_extent_size = 4096
+
+	# Configuration option striping across all PVs when RAID stripes are not specified.
+	# If enabled, all PVs in the VG or on the command line are used for raid0/4/5/6/10
+	# when the command does not specify the number of stripes to use.
+	#
+	# This configuration option has an automatic default value.
+	# raid_stripe_all_devices = 0
 }
 
 # Configuration section log.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 25914ea..8b9932e 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -461,6 +461,11 @@ cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separa
 	"Mirror logs and images will always use different PVs.\n"
 	"The default setting changed in version 2.02.85.\n")
 
+cfg(allocation_raid_stripe_all_devices_CFG, "raid_stripe_all_devices", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ALLOCATION_STRIPE_ALL_DEVICES, vsn(2, 2, 162), NULL, 0, NULL,
+	"Stripe across all PVs when RAID stripes are not specified.\n"
+	"If enabled, all PVs in the VG or on the command line are used for raid0/4/5/6/10\n"
+	"when the command does not specify the number of stripes to use.\n")
+
 cfg(allocation_cache_pool_metadata_require_separate_pvs_CFG, "cache_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 106), NULL, 0, NULL,
 	"Cache pool metadata and data will always use different PVs.\n")
 
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index addb14f..f1f1700 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -68,6 +68,7 @@
 #define DEFAULT_MIRROR_MAX_IMAGES 8 /* limited by kernel DM_KCOPYD_MAX_REGIONS */
 // FIXME Increase this to 64
 #define DEFAULT_RAID_MAX_IMAGES 8 /* limited by kernel failed devices bitfield in superblock (raid4/5/6 max 253) */
+#define DEFAULT_ALLOCATION_STRIPE_ALL_DEVICES 0 /* Don't stripe across all devices if not -i/--stripes given */
 
 #define DEFAULT_RAID_FAULT_POLICY "warn"
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 0dd9b1e..8436365 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -458,26 +458,46 @@ static int _read_mirror_params(struct cmd_context *cmd,
 static int _read_raid_params(struct cmd_context *cmd,
 			     struct lvcreate_params *lp)
 {
-	if ((lp->stripes < 2) && segtype_is_raid10(lp->segtype)) {
-		if (arg_is_set(cmd, stripes_ARG)) {
-			/* User supplied the bad argument */
-			log_error("Segment type 'raid10' requires 2 or more stripes.");
+	if (seg_is_mirrored(lp)) {
+		if (segtype_is_raid10(lp->segtype)) {
+			if (lp->stripes < 2) {
+				/*
+				 * RAID10 needs@least 4 stripes
+				 */
+				log_warn("Adjusting stripes to the minimum of 2 for %s.",
+					 lp->segtype->name);
+				lp->stripes = 2;
+			}
+
+			/*
+			 * FIXME: _check_raid_parameters devides by 2, which
+			 *	  needs to change if we start supporting
+			 *	  odd numbers of stripes with raid10
+			 */
+			lp->stripes *= 2;
+
+		} else if (lp->stripes > 1) {
+			/*
+			 * RAID1 does not take a stripe arg
+			 */
+			log_error("Stripe argument cannot be used with segment type, %s",
+				  lp->segtype->name);
 			return 0;
 		}
-		/* No stripe argument was given - default to 2 */
-		lp->stripes = 2;
-		lp->stripe_size = find_config_tree_int(cmd, metadata_stripesize_CFG, NULL) * 2;
-	}
 
-	/*
-	 * RAID1 does not take a stripe arg
-	 */
-	if ((lp->stripes > 1) && seg_is_mirrored(lp) &&
-	    !segtype_is_raid10(lp->segtype)) {
-		log_error("Stripe argument cannot be used with segment type, %s",
-			  lp->segtype->name);
-		return 0;
-	}
+	} else if (lp->stripes < 2)
+		/* No stripe argument was given */
+		lp->stripes = seg_is_any_raid6(lp) ? 3 : 2;
+
+	if (seg_is_raid1(lp)) {
+		if (lp->stripe_size) {
+			log_error("Stripe size argument cannot be used with segment type, %s",
+				  lp->segtype->name);
+			return 0;
+		}
+
+	} else if (!lp->stripe_size)
+		lp->stripe_size = find_config_tree_int(cmd, metadata_stripesize_CFG, NULL) * 2;
 
 	if (arg_is_set(cmd, mirrors_ARG) && segtype_is_raid(lp->segtype) &&
 	    !segtype_is_raid1(lp->segtype) && !segtype_is_raid10(lp->segtype)) {
@@ -486,13 +506,15 @@ static int _read_raid_params(struct cmd_context *cmd,
 		return 0;
 	}
 
-	/* Rates are recorded in kiB/sec/disk, not sectors/sec/disk */
-	lp->min_recovery_rate = arg_uint_value(cmd, minrecoveryrate_ARG, 0) / 2;
-	lp->max_recovery_rate = arg_uint_value(cmd, maxrecoveryrate_ARG, 0) / 2;
+	if (!seg_is_any_raid0(lp)) {
+		/* Rates are recorded in kiB/sec/disk, not sectors/sec/disk */
+		lp->min_recovery_rate = arg_uint_value(cmd, minrecoveryrate_ARG, 0) / 2;
+		lp->max_recovery_rate = arg_uint_value(cmd, maxrecoveryrate_ARG, 0) / 2;
 
-	if (lp->min_recovery_rate > lp->max_recovery_rate) {
-		log_error("Minimum recovery rate cannot be higher than maximum.");
-		return 0;
+		if (lp->min_recovery_rate > lp->max_recovery_rate) {
+			log_error("Minimum recovery rate cannot be higher than maximum.");
+			return 0;
+		}
 	}
 
 	return 1;
@@ -547,13 +569,6 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 		/* Default to 2 mirrored areas if '--type mirror|raid1|raid10' */
 		lp->mirrors = seg_is_mirrored(lp) ? 2 : 1;
 
-	if (lp->stripes < 2 && segtype_is_any_raid0(lp->segtype))
-		if (arg_count(cmd, stripes_ARG)) {
-			/* User supplied the bad argument */
-			log_error("Segment type %s requires 2 or more stripes.", lp->segtype->name);
-			return 0;
-		}
-
 	lp->nosync = arg_is_set(cmd, nosync_ARG);
 
 	if (!(lp->region_size = arg_uint_value(cmd, regionsize_ARG, 0)) &&
@@ -562,6 +577,8 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 		return 0;
 	}
 
+	lp->stripe_size = arg_uint_value(cmd, stripesize_ARG, 0);
+
 	if (!is_power_of_2(lp->region_size)) {
 		log_error("Region size (%" PRIu32 ") must be a power of 2",
 			  lp->region_size);
@@ -1221,39 +1238,44 @@ static int _check_raid_parameters(struct volume_group *vg,
 {
 	unsigned devs = lcp->pv_count ? : dm_list_size(&vg->pvs);
 	struct cmd_context *cmd = vg->cmd;
+	int old_stripes = !arg_is_set(cmd, stripes_ARG) &&
+			  find_config_tree_bool(cmd, allocation_raid_stripe_all_devices_CFG, NULL);
 
-	if (!seg_is_mirrored(lp) && !lp->stripe_size)
-		lp->stripe_size = find_config_tree_int(cmd, metadata_stripesize_CFG, NULL) * 2;
+	/*
+	 * If we requested the previous behaviour by setting
+	 * "allocation/raid_stripe_all_devices = 1" and the
+	 * number of devices was not supplied, we can infer
+	 * from the PVs given.
+	 */
+	if (old_stripes && seg_is_raid(lp) && !seg_is_raid1(lp))
+		lp->stripes = devs;
+
+	if (seg_is_raid10(lp)) {
+		lp->stripes /= lp->mirrors;
 
-	if (seg_is_any_raid0(lp)) {
 		if (lp->stripes < 2) {
-			log_error("Segment type 'raid0' requires 2 or more stripes.");
+			log_error("Unable to create RAID(1)0 LV: "
+				  "insufficient number of devices.");
 			return 0;
 		}
-	} else if (!seg_is_mirrored(lp)) {
-		/*
-		 * If number of devices was not supplied, we can infer from
-		 * the PVs given.
-		 */
-		if (!arg_is_set(cmd, stripes_ARG) &&
-		    (devs > 2 * lp->segtype->parity_devs))
-			lp->stripes = devs - lp->segtype->parity_devs;
 
-		if (lp->stripes <= lp->segtype->parity_devs) {
+	} else if (!seg_is_mirrored(lp)) {
+		if (old_stripes &&
+		    lp->segtype->parity_devs &&
+		    devs > 2 * lp->segtype->parity_devs)
+			lp->stripes -= lp->segtype->parity_devs;
+
+		if (seg_is_any_raid0(lp)) {
+			if (lp->stripes < 2) {
+				log_error("Segment type 'raid0' requires 2 or more stripes.");
+				return 0;
+			}
+		} else if (lp->stripes <= lp->segtype->parity_devs) {
 			log_error("Number of stripes must be at least %d for %s",
 				  lp->segtype->parity_devs + 1,
 				  lp->segtype->name);
 			return 0;
 		}
-	} else if (segtype_is_any_raid0(lp->segtype) ||
-		   segtype_is_raid10(lp->segtype)) {
-		if (!arg_is_set(cmd, stripes_ARG))
-			lp->stripes = devs / lp->mirrors;
-		if (lp->stripes < 2) {
-			log_error("Unable to create RAID(1)0 LV: "
-				  "insufficient number of devices.");
-			return 0;
-		}
 	}
 	/* 'mirrors' defaults to 2 - not the number of PVs supplied */
 


