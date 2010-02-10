From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 10 Feb 2010 15:57:01 +0100
Subject: [PATCH 15/19] Replicator: add new options for replicator
In-Reply-To: <cover.1265813098.git.zkabelac@redhat.com>
References: <cover.1265813098.git.zkabelac@redhat.com>
Message-ID: <435503dc454774008db8a6589b4d7a7eab1ca4da.1265813098.git.zkabelac@redhat.com>
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
 tools/args.h                     |    5 +++
 tools/commands.h                 |   10 ++++++-
 tools/lvcreate.c                 |   52 +++++++++++++++++++++++++++++++++++++-
 tools/lvmcmdline.c               |    9 ++++++
 tools/tools.h                    |    1 +
 7 files changed, 76 insertions(+), 3 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 94057e4..abf37f3 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -107,6 +107,7 @@
 
 #define DEFAULT_STRIPE_FILLER "error"
 #define DEFAULT_MIRROR_REGION_SIZE 512	/* KB */
+#define DEFAULT_REPLICATOR_REGION_SIZE 512	/* KB */
 #define DEFAULT_INTERVAL 15
 
 #ifdef READLINE_SUPPORT
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0b955b6..1b57787 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -588,6 +588,7 @@ uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 struct lvcreate_params {
 	/* flags */
 	int snapshot; /* snap */
+	int replicator; /* replicator */
 	int zero; /* all */
 	int major; /* all */
 	int minor; /* all */
diff --git a/tools/args.h b/tools/args.h
index 981f45f..3a4cec9 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -66,6 +66,11 @@ arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
 arg(virtualsize_ARG, '\0', "virtualsize", size_mb_arg, 0)
 arg(noudevsync_ARG, '\0', "noudevsync", NULL, 0)
 arg(poll_ARG, '\0', "poll", yes_no_arg, 0)
+arg(replicator_ARG, '\0', "replicator", NULL, 0)
+arg(replicatorlog_ARG, '\0', "replicatorlog", NULL, 0)
+arg(replicatorlogtype_ARG, '\0', "replicatorlogtype", NULL, 0)
+arg(addsite_ARG, '\0', "addsite", site_arg, 0)
+arg(delsite_ARG, '\0', "delsite", site_arg, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index ad0b385..44c5a21 100644
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
@@ -90,7 +92,7 @@ xx(lvchange,
    ignorelockingfailure_ARG, ignoremonitoring_ARG, major_ARG, minor_ARG,
    monitor_ARG, noudevsync_ARG, partial_ARG, permission_ARG, persistent_ARG,
    poll_ARG, readahead_ARG, resync_ARG, refresh_ARG, addtag_ARG, deltag_ARG,
-   test_ARG, yes_ARG)
+   test_ARG, addsite_ARG, delsite_ARG, yes_ARG)
 
 xx(lvconvert,
    "Change logical volume layout",
@@ -160,6 +162,9 @@ xx(lvcreate,
    "\t[-p|--permission {r|rw}]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
+   "\t[--replicator]\n"
+   "\t[--replicatorlog LogicalVolumeName]\n"
+   "\t[--replicatorlogtype ringbuffer]\n"
    "\t[-t|--test]\n"
    "\t[--type VolumeType]\n"
    "\t[-v|--verbose]\n"
@@ -194,7 +199,8 @@ xx(lvcreate,
    addtag_ARG, alloc_ARG, autobackup_ARG, chunksize_ARG, contiguous_ARG,
    corelog_ARG, extents_ARG, major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG,
    name_ARG, nosync_ARG, noudevsync_ARG, permission_ARG, persistent_ARG,
-   readahead_ARG, regionsize_ARG, size_ARG, snapshot_ARG, stripes_ARG,
+   readahead_ARG, regionsize_ARG, replicator_ARG, replicatorlog_ARG,
+   replicatorlogtype_ARG, size_ARG, snapshot_ARG, stripes_ARG,
    stripesize_ARG, test_ARG, type_ARG, virtualoriginsize_ARG, virtualsize_ARG,
    zero_ARG)
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 211cfeb..4f11bba 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -379,6 +379,36 @@ static int _read_mirror_params(struct lvcreate_params *lp,
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
+			log_error("Negative regionsize in configuration "
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
@@ -411,6 +441,9 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	if (seg_is_mirrored(lp))
 		lp->mirrors = 2;
 
+	if (seg_is_replicator(lp) || arg_count(cmd, replicator_ARG))
+		lp->replicator = 1;
+
 	if (arg_count(cmd, mirrors_ARG)) {
 		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0) + 1;
 		if (lp->mirrors == 1)
@@ -475,6 +508,22 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		}
 	}
 
+	if (lp->replicator) {
+		log_error("--replicator for replicators");
+
+	} else {
+		if (arg_count(cmd, replicatorlog_ARG)) {
+			log_error("--replicatorlog is only available "
+				  "with replicators.");
+			return 0;
+		}
+		if (arg_count(cmd, replicatorlogtype_ARG)) {
+			log_error("--replicatorlogtype is only available "
+				  "with replicators.");
+			return 0;
+		}
+	}
+
 	if (activation() && lp->segtype->ops->target_present &&
 	    !lp->segtype->ops->target_present(cmd, NULL, NULL)) {
 		log_error("%s: Required device-mapper target(s) not "
@@ -485,7 +534,8 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
 	    !_read_size_params(lp, lcp, cmd) ||
 	    !_read_stripe_params(lp, cmd) ||
-	    !_read_mirror_params(lp, cmd))
+	    !_read_mirror_params(lp, cmd) ||
+	    !_read_replicator_params(lp, cmd))
 		return_0;
 
 	/*
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 4881d54..bcea8a1 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -483,6 +483,15 @@ int readahead_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
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
1.6.6.1


