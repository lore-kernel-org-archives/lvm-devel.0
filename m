From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Apr 2010 14:37:44 +0200
Subject: [PATCH 22/23] Replicator: add new options for replicator
In-Reply-To: <cover.1272457502.git.zkabelac@redhat.com>
References: <cover.1272457502.git.zkabelac@redhat.com>
Message-ID: <2c5e4c9f8b70ddf3239d70e5857bcd50f17aeb23.1272457502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

New options: addsite, delsite, replicator,
replicatorlog, replicatorlogtype.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/config/defaults.h            |    1 +
 lib/metadata/metadata-exported.h |    1 +
 tools/args.h                     |   13 ++++++++
 tools/commands.h                 |    7 ++++
 tools/lvcreate.c                 |   58 +++++++++++++++++++++++++++++++++++++-
 tools/lvmcmdline.c               |    9 ++++++
 tools/tools.h                    |    1 +
 7 files changed, 89 insertions(+), 1 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 22a085d..4ef94ff 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -108,6 +108,7 @@
 
 #define DEFAULT_STRIPE_FILLER "error"
 #define DEFAULT_MIRROR_REGION_SIZE 512	/* KB */
+#define DEFAULT_REPLICATOR_REGION_SIZE 512	/* KB */
 #define DEFAULT_INTERVAL 15
 
 #ifdef READLINE_SUPPORT
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 09c83a4..4198a87 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -608,6 +608,7 @@ uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 struct lvcreate_params {
 	/* flags */
 	int snapshot; /* snap */
+	int replicator; /* replicator */
 	int zero; /* all */
 	int major; /* all */
 	int minor; /* all */
diff --git a/tools/args.h b/tools/args.h
index 88d0d05..7907082 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -66,6 +66,19 @@ arg(virtualsize_ARG, '\0', "virtualsize", size_mb_arg, 0)
 arg(noudevsync_ARG, '\0', "noudevsync", NULL, 0)
 arg(poll_ARG, '\0', "poll", yes_no_arg, 0)
 arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)
+arg(replicator_ARG, '\0', "replicator", NULL, 0)
+arg(replicatordev_ARG, '\0', "replicatordev", NULL, 0)
+arg(replicatorlog_ARG, '\0', "replicatorlog", NULL, 0)
+arg(replicatorlogtype_ARG, '\0', "replicatorlogtype", NULL, 0)
+arg(addsite_ARG, '\0', "addsite", site_arg, 0)
+arg(delsite_ARG, '\0', "delsite", site_arg, 0)
+arg(fallbehinddata_ARG, '\0', "fallbehinddata", size_mb_arg, 0)
+arg(fallbehindios_ARG, '\0', "fallbehindios", int_arg, 0)
+arg(fallbehindtimeout_ARG, '\0', "fallbehindtimeout", int_arg, 0)
+arg(sitemode_ARG, '\0', "sitemode", string_arg, 0)
+arg(activesite_ARG, '\0', "activesite", string_arg, 0)
+arg(passivesite_ARG, '\0', "passivesite", string_arg, 0)
+arg(remotevolumegroup_ARG, '\0', "remotevolumegroup", string_arg, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 7d0185b..39cd5be 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -62,10 +62,12 @@ xx(lvchange,
    "lvchange\n"
    "\t[-A|--autobackup y|n]\n"
    "\t[-a|--available [e|l]y|n]\n"
+   "\t[--addsite Site]\n"
    "\t[--addtag Tag]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-C|--contiguous y|n]\n"
    "\t[-d|--debug]\n"
+   "\t[--delsite Site]\n"
    "\t[--deltag Tag]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
@@ -90,6 +92,7 @@ xx(lvchange,
    ignorelockingfailure_ARG, ignoremonitoring_ARG, major_ARG, minor_ARG,
    monitor_ARG, noudevsync_ARG, partial_ARG, permission_ARG, persistent_ARG,
    poll_ARG, readahead_ARG, resync_ARG, refresh_ARG, addtag_ARG, deltag_ARG,
+   addsite_ARG, delsite_ARG, 
    test_ARG, yes_ARG)
 
 xx(lvconvert,
@@ -164,6 +167,9 @@ xx(lvcreate,
    "\t[-p|--permission {r|rw}]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
+   "\t[--replicator]\n"
+   "\t[--replicatorlog LogicalVolumeName]\n"
+   "\t[--replicatorlogtype ringbuffer]\n"
    "\t[-t|--test]\n"
    "\t[--type VolumeType]\n"
    "\t[-v|--verbose]\n"
@@ -202,6 +208,7 @@ xx(lvcreate,
    mirrorlog_ARG, mirrors_ARG, monitor_ARG, name_ARG, nosync_ARG, noudevsync_ARG,
    permission_ARG, persistent_ARG, readahead_ARG, regionsize_ARG, size_ARG,
    snapshot_ARG, stripes_ARG, stripesize_ARG, test_ARG, type_ARG,
+   replicator_ARG, replicatorlog_ARG, replicatorlogtype_ARG,
    virtualoriginsize_ARG, virtualsize_ARG, zero_ARG)
 
 xx(lvdisplay,
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 8968718..a75867f 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -316,6 +316,36 @@ static int _read_mirror_params(struct lvcreate_params *lp,
 	return 1;
 }
 
+static int _read_replicator_params(struct lvcreate_params *lp,
+				   struct cmd_context *cmd)
+{
+	int region_size;
+	const char *mirrorlog;
+
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
+	if (!_validate_mirror_params(cmd, lp)) /* reuse ? */
+		return 0;
+
+	return 1;
+}
+
 static int _lvcreate_params(struct lvcreate_params *lp,
 			    struct lvcreate_cmdline_params *lcp,
 			    struct cmd_context *cmd,
@@ -323,6 +353,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 {
 	int contiguous;
 	unsigned pagesize;
+	int i;
 
 	memset(lp, 0, sizeof(*lp));
 	memset(lcp, 0, sizeof(*lcp));
@@ -344,6 +375,9 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	if (seg_is_mirrored(lp))
 		lp->mirrors = 2;
 
+	if (seg_is_replicator(lp) || arg_count(cmd, replicator_ARG))
+		lp->replicator = 1;
+
 	if (arg_count(cmd, mirrors_ARG)) {
 		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0) + 1;
 		if (lp->mirrors == 1)
@@ -381,7 +415,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		}
 	}
 
-	if (lp->mirrors > 1) {
+	if (lp->mirrors > 1 || lp->replicator) {
 		if (lp->snapshot) {
 			log_error("mirrors and snapshots are currently "
 				  "incompatible");
@@ -402,6 +436,27 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		}
 	}
 
+	if (lp->replicator) {
+		log_error("--replicator for replicators");
+	} else {
+		static const struct {
+			const char *str;
+			int argname;
+		} repargs[] = {
+			{ "replicatorlogtype", replicatorlogtype_ARG },
+			{ "replicatorlog", replicatorlog_ARG },
+	     //   	{ "replicatorsynclog", replicatorsynclog_ARG },
+			{ "remotevolumegroup", remotevolumegroup_ARG }
+		};
+
+		for (i = 0; i < sizeof(repargs)/sizeof(repargs[0]); ++i)
+			if (arg_count(cmd, repargs[i].argname)) {
+			log_error("--%s is only available "
+				  "with replicators.", repargs[i].str);
+			return 0;
+		}
+	}
+
 	if (activation() && lp->segtype->ops->target_present &&
 	    !lp->segtype->ops->target_present(cmd, NULL, NULL)) {
 		log_error("%s: Required device-mapper target(s) not "
@@ -416,6 +471,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
 	    !_read_size_params(lp, lcp, cmd) ||
 	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
+	    !_read_replicator_params(lp, cmd) ||
 	    !_read_mirror_params(lp, cmd))
 		return_0;
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index d9ea0c7..367e8ee 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -488,6 +488,15 @@ int readahead_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
 	return 1;
 }
 
+int site_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
+{
+	char *pos = a->value;
+	if (!validate_name(pos))
+		return 0;
+
+	return 1;
+}
+
 static void __alloc(int size)
 {
 	if (!(_cmdline.commands = dm_realloc(_cmdline.commands, sizeof(*_cmdline.commands) * size))) {
diff --git a/tools/tools.h b/tools/tools.h
index 75575e7..8dbabbc 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -152,6 +152,7 @@ int units_arg(struct cmd_context *cmd, struct arg *a);
 int segtype_arg(struct cmd_context *cmd, struct arg *a);
 int alloc_arg(struct cmd_context *cmd, struct arg *a);
 int readahead_arg(struct cmd_context *cmd, struct arg *a);
+int site_arg(struct cmd_context *cmd, struct arg *a);
 
 /* we use the enums to access the switches */
 unsigned arg_count(const struct cmd_context *cmd, int a);
-- 
1.7.0.1


