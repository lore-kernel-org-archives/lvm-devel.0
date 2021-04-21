From: David Teigland <teigland@sourceware.org>
Date: Wed, 21 Apr 2021 13:46:53 +0000 (GMT)
Subject: main - commands: use AUTOTYPE in definitions
Message-ID: <20210421134653.F0E2D3892446@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d651b340e68d97ada25e558eb50aa40062bba936
Commit:        d651b340e68d97ada25e558eb50aa40062bba936
Parent:        7b77226df2ee7f4d1baa11d42752f600e408bf65
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 20 17:03:09 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 21 08:41:37 2021 -0500

commands: use AUTOTYPE in definitions

If a cmd def implies an LV type without --type
in the required options, then include the implied
type in the cmd def as AUTOTYPE: <type>
instead of including the redundant --type foo
in the OO list of options.

Including an implied --type in the OO list would
often cause multiple cmd defs to potentially be
identical when options were used, and a user
command could match more than one cmd def.

The AUTOTYPE values are listed in man page and
help output as
 [ --type foo (implied) ]

If a user command includes --type, it will usually
match a cmd def with --type in the required options.
But, if the user command matches a cmd def with
AUTOTYPE, then the specifed --type and AUTOTYPE must
match.

The man-generator program has a new --check
option that compares cmd defs to find any cmd defs
that are equivalent with the use of options,
and should have their options adjusted.
---
 tools/command-lines.in | 147 ++++++++++++++++++++++++++++++++-----------------
 tools/command.c        |  42 ++++++++++++++
 tools/command.h        |   4 ++
 tools/lvmcmdline.c     |   9 +++
 4 files changed, 150 insertions(+), 52 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 459e2afb6..164516a2e 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -163,6 +163,22 @@
 # RULE: LV_type1 and lv_is_prop1
 #
 #
+# AUTOTYPE: <segtype>
+# The cmd def implies the type.  Optionally using --type foo
+# is not wrong, but it's redundant.  If --type is specified
+# it is not used in matching a user command to the cmd def,
+# but once a user cmd is matched to the cmd def, a specified
+# type is compared to the AUTOTYPE to ensure they match.
+# We avoid including --type foo in the OO list because doing
+# so often makes the cmd def redundant with another cmd def
+# that has --type foo in its required_options.  We want a user
+# command to only match a single cmd def.
+# Usually, a user command with --type foo will match a cmd def
+# that includes --type foo in its required_options.
+#
+# For lvcreate cmd defs, each should either include --type foo
+# in required_options, or it should include AUTOTYPE foo
+# (and not include --type in OO).
 
 #
 # For efficiency, sets of options can be defined and reused
@@ -445,11 +461,11 @@ RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 # alternate form of lvconvert --type thin
 lvconvert --thin --thinpool LV LV_linear_striped_raid_cache_thin_error_zero
-OO: --type thin, --originname LV_new, OO_LVCONVERT_POOL, OO_LVCONVERT
+OO: --originname LV_new, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_thin_with_external
-DESC: Convert LV to a thin LV, using the original LV as an external origin
-DESC: (infers --type thin).
+DESC: Convert LV to a thin LV, using the original LV as an external origin.
 FLAGS: SECONDARY_SYNTAX
+AUTOTYPE: thin
 RULE: all and lv_is_visible
 RULE: all not lv_is_locked lv_is_raid_with_integrity
 RULE: --poolmetadata not --readahead --stripesize --stripes_long
@@ -466,13 +482,14 @@ RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 # alternate form of lvconvert --type cache
 lvconvert --cache --cachepool LV LV_linear_striped_raid_thinpool_vdo_vdopool_vdopooldata
-OO: --type cache, OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
+OO: OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_cache_with_cachepool
-DESC: Attach a cache pool to an LV (infers --type cache).
+DESC: Attach a cache pool to an LV.
 RULE: all and lv_is_visible
 RULE: all not lv_is_raid_with_integrity
 RULE: --poolmetadata not --readahead --stripesize --stripes_long
 FLAGS: SECONDARY_SYNTAX
+AUTOTYPE: cache
 
 ---
 
@@ -550,7 +567,7 @@ RULE: --poolmetadata not --readahead --stripesize --stripes_long
 # of creating a pool or swapping metadata should be used.
 
 lvconvert --thinpool LV_linear_striped_raid_cache_thinpool
-OO: --type thin-pool, --stripes_long Number, --stripesize SizeKB,
+OO: --stripes_long Number, --stripesize SizeKB,
 OO_LVCONVERT_THINPOOL, OO_LVCONVERT_POOL, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_to_thinpool_or_swap_metadata
@@ -560,6 +577,7 @@ FLAGS: PREVIOUS_SYNTAX
 RULE: all and lv_is_visible
 RULE: all not lv_is_raid_with_integrity
 RULE: --poolmetadata not --readahead --stripesize --stripes_long
+AUTOTYPE: thin-pool
 
 ---
 
@@ -593,6 +611,17 @@ RULE: all not lv_is_raid_with_integrity
 # This command syntax is deprecated, and the primary forms
 # of creating a pool or swapping metadata should be used.
 
+# FIXME
+# AUTOTYPE: cache-pool doesn't work here.
+# A strange command matches this cmd def:
+# lvconvert --type cache-pool --cachepool LV
+# where the LV is already a cache pool.  That command
+# seems to be used to change properties on an existing cache pool.
+# The command lvconvert --type cache-pool LV will also change
+# properties on an existing cache pool.
+# Neither seems like a logical command to change properties
+# of an LV, wouldn't lvchange do that?
+
 lvconvert --cachepool LV_linear_striped_raid_cachepool_error_zero
 OO: --type cache-pool, OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
 OP: PV ...
@@ -614,12 +643,13 @@ RULE: all and lv_is_visible
 RULE: all not lv_is_locked lv_is_origin lv_is_merging_origin lv_is_external_origin lv_is_virtual lv_is_raid_with_integrity
 
 lvconvert --vdopool LV_linear_striped_raid_cache
-OO: --type vdo-pool, OO_LVCONVERT_VDO, OO_LVCONVERT, --name LV_new, --virtualsize SizeMB,
+OO: OO_LVCONVERT_VDO, OO_LVCONVERT, --name LV_new, --virtualsize SizeMB,
 ID: lvconvert_to_vdopool_param
 DESC: Convert LV to type vdopool.
 RULE: all and lv_is_visible
 RULE: all not lv_is_locked lv_is_origin lv_is_merging_origin lv_is_external_origin lv_is_virtual lv_is_raid_with_integrity
 FLAGS: SECONDARY_SYNTAX
+AUTOTYPE: vdo-pool
 
 ---
 
@@ -712,13 +742,14 @@ RULE: all not lv_is_locked lv_is_pvmove
 RULE: all and lv_is_visible
 
 lvconvert --snapshot LV LV_linear_striped
-OO: --type snapshot, --chunksize SizeKB, --zero Bool, OO_LVCONVERT
+OO: --chunksize SizeKB, --zero Bool, OO_LVCONVERT
 ID: lvconvert_combine_split_snapshot
 DESC: Combine a former COW snapshot (second arg) with a former
 DESC: origin LV (first arg) to reverse a splitsnapshot command.
 RULE: all not lv_is_locked lv_is_pvmove
 RULE: all and lv_is_visible
 FLAGS: SECONDARY_SYNTAX
+AUTOTYPE: snapshot
 
 ---
 
@@ -836,11 +867,12 @@ DESC: Create a linear LV.
 FLAGS: SECONDARY_SYNTAX
 
 lvcreate --size SizeMB VG
-OO: --type linear, OO_LVCREATE
+OO: OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0, --stripes 1
 ID: lvcreate_linear
 DESC: Create a linear LV.
+AUTOTYPE: linear
 
 ---
 
@@ -880,10 +912,11 @@ FLAGS: SECONDARY_SYNTAX
 
 # R13 (just --stripes)
 lvcreate --stripes Number --size SizeMB VG
-OO: --stripesize SizeKB, --type striped, OO_LVCREATE
+OO: --stripesize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_striped
-DESC: Create a striped LV (infers --type striped).
+DESC: Create a striped LV.
+AUTOTYPE: striped
 
 # R5,R7 (--type mirror with or without --mirrors)
 lvcreate --type mirror --size SizeMB VG
@@ -897,11 +930,13 @@ FLAGS: SECONDARY_SYNTAX
 # R14 (just --mirrors)
 # alternate form of lvcreate --type raid1|mirror
 lvcreate --mirrors PNumber --size SizeMB VG
-OO: --stripes Number, --stripesize SizeKB,
---mirrorlog MirrorLog, --regionsize RegionSize, --minrecoveryrate SizeKB, --maxrecoveryrate SizeKB, OO_LVCREATE
+OO: --stripesize SizeKB, --mirrorlog MirrorLog, --regionsize RegionSize, --minrecoveryrate SizeKB, --maxrecoveryrate SizeKB, OO_LVCREATE
 OP: PV ...
+IO: --stripes 1
 ID: lvcreate_mirror_or_raid1
-DESC: Create a raid1 or mirror LV (infers --type raid1|mirror).
+DESC: Create a raid1 or mirror LV.
+AUTOTYPE: raid1
+AUTOTYPE: mirror
 
 # R9,R10,R11,R12 (--type raid with any use of --stripes/--mirrors)
 lvcreate --type raid --size SizeMB VG
@@ -913,11 +948,14 @@ ID: lvcreate_raid_any
 DESC: Create a raid LV (a specific raid level must be used, e.g. raid1).
 
 # R15 (--stripes and --mirrors which implies raid10)
+# FIXME: --mirrors N --stripes 1 is raid1|mirror and should only
+# match the cmd def above for raid1|mirror with IO: --stripes 1
 lvcreate --mirrors PNumber --stripes Number --size SizeMB VG
 OO: --stripesize SizeKB, --regionsize RegionSize, --minrecoveryrate SizeKB, --maxrecoveryrate SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_raid_any
 DESC: Create a raid10 LV.
+AUTOTYPE: raid10
 
 ---
 
@@ -937,11 +975,12 @@ DESC: (also see --snapshot).
 FLAGS: SECONDARY_SYNTAX
 
 lvcreate --snapshot --size SizeMB LV
-OO: --type snapshot, --stripes Number, --stripesize SizeKB,
+OO: --stripes Number, --stripesize SizeKB,
 --chunksize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_cow_snapshot
 DESC: Create a COW snapshot LV of an origin LV.
+AUTOTYPE: snapshot
 
 ---
 
@@ -966,24 +1005,24 @@ DESC: Create a thin pool.
 
 # alternate form of lvcreate --type thin-pool
 lvcreate --thin --size SizeMB VG
-OO: --stripes Number, --stripesize SizeKB,
---type thin-pool, OO_LVCREATE_THINPOOL, OO_LVCREATE_POOL, OO_LVCREATE
+OO: --stripes Number, --stripesize SizeKB, OO_LVCREATE_THINPOOL, OO_LVCREATE_POOL, OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thinpool
-DESC: Create a thin pool (infers --type thin-pool).
+DESC: Create a thin pool.
 FLAGS: SECONDARY_SYNTAX
+AUTOTYPE: thin-pool
 
 # alternate form of lvcreate --type thin-pool
 lvcreate --size SizeMB --thinpool LV_new VG
 OO: --stripes Number, --stripesize SizeKB,
---thin, --type thin-pool, OO_LVCREATE_THINPOOL, OO_LVCREATE_POOL, OO_LVCREATE
+--thin, OO_LVCREATE_THINPOOL, OO_LVCREATE_POOL, OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thinpool
-DESC: Create a thin pool named by the --thinpool arg
-DESC: (infers --type thin-pool).
+DESC: Create a thin pool named in --thinpool.
 FLAGS: SECONDARY_SYNTAX
+AUTOTYPE: thin-pool
 
 ---
 
@@ -1032,20 +1071,21 @@ FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin
 lvcreate --virtualsize SizeMB --thinpool LV_thinpool VG
-OO: --type thin, --thin, OO_LVCREATE
+OO: --thin, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_vol
-DESC: Create a thin LV in a thin pool (infers --type thin).
+DESC: Create a thin LV in a thin pool.
+AUTOTYPE: thin
 
 # alternate form of lvcreate --type thin
 lvcreate --virtualsize SizeMB LV_thinpool
-OO: --type thin, --thin, OO_LVCREATE
+OO: --thin, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_vol
 DESC: Create a thin LV in the thin pool named in the first arg
-DESC: (variant, infers --type thin, also see --thinpool for
-DESC: naming pool.)
+DESC: (also see --thinpool for naming pool.)
 FLAGS: SECONDARY_SYNTAX
+AUTOTYPE: thin
 
 ---
 
@@ -1058,20 +1098,20 @@ FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin
 lvcreate --thin LV_thin
-OO: --type thin, OO_LVCREATE
+OO: OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_snapshot
-DESC: Create a thin LV that is a snapshot of an existing thin LV
-DESC: (infers --type thin).
+DESC: Create a thin LV that is a snapshot of an existing thin LV.
 FLAGS: SECONDARY_SYNTAX
+AUTOTYPE: thin
 
 # alternate form of lvcreate --type thin
 lvcreate --snapshot LV_thin
-OO: --type thin, OO_LVCREATE
+OO: OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_snapshot
-DESC: Create a thin LV that is a snapshot of an existing thin LV
-DESC: (infers --type thin).
+DESC: Create a thin LV that is a snapshot of an existing thin LV.
+AUTOTYPE: thin
 
 lvcreate --type thin --thinpool LV_thinpool LV
 OO: --thin, OO_LVCREATE
@@ -1081,12 +1121,12 @@ DESC: Create a thin LV that is a snapshot of an external origin LV.
 
 # alternate form of lvcreate --type thin --thinpool LV_thinpool LV
 lvcreate --snapshot --thinpool LV_thinpool LV
-OO: --type thin, OO_LVCREATE
+OO: OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_snapshot_of_external
-DESC: Create a thin LV that is a snapshot of an external origin LV
-DESC: (infers --type thin).
+DESC: Create a thin LV that is a snapshot of an external origin LV.
 FLAGS: SECONDARY_SYNTAX
+AUTOTYPE: thin
 
 ---
 
@@ -1100,21 +1140,23 @@ DESC: Create a LV that returns VDO when used.
 
 lvcreate --vdo --size SizeMB VG
 OO: --stripes Number, --stripesize SizeKB,
---type vdo, --virtualsize SizeMB, --vdopool LV_new, OO_LVCREATE_VDO, OO_LVCREATE
+--virtualsize SizeMB, --vdopool LV_new, OO_LVCREATE_VDO, OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_vdo_vol
 DESC: Create a VDO LV with VDO pool.
 FLAGS: SECONDARY_SYNTAX
+AUTOTYPE: vdo
 
 lvcreate --vdopool LV_new --size SizeMB VG
 OO: --stripes Number, --stripesize SizeKB,
---vdo, --type vdo, --virtualsize SizeMB, OO_LVCREATE_VDO, OO_LVCREATE
+--virtualsize SizeMB, OO_LVCREATE_VDO, OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_vdo_vol
 DESC: Create a VDO LV with VDO pool.
 FLAGS: SECONDARY_SYNTAX
+AUTOTYPE: vdo
 
 ---
 
@@ -1147,14 +1189,14 @@ FLAGS: SECONDARY_SYNTAX
 # alternate form of lvcreate --type thin
 lvcreate --virtualsize SizeMB --size SizeMB --thinpool LV_new VG
 OO: --stripes Number, --stripesize SizeKB,
---type thin, --thin, OO_LVCREATE_THINPOOL, OO_LVCREATE_POOL, OO_LVCREATE
+--thin, OO_LVCREATE_THINPOOL, OO_LVCREATE_POOL, OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thin_vol_and_thinpool
 DESC: Create a thin LV, first creating a thin pool for it,
-DESC: where the new thin pool is named by the --thinpool arg
-DESC: (variant, infers --type thin).
+DESC: where the new thin pool is named by --thinpool.
 FLAGS: SECONDARY_SYNTAX
+AUTOTYPE: thin
 
 # alternate form of lvcreate --type thin
 lvcreate --type thin --virtualsize SizeMB --size SizeMB LV_new|VG
@@ -1172,32 +1214,32 @@ FLAGS: SECONDARY_SYNTAX
 # alternate form of lvcreate --type thin
 lvcreate --thin --virtualsize SizeMB --size SizeMB LV_new|VG
 OO: --stripes Number, --stripesize SizeKB,
---type thin, OO_LVCREATE_THINPOOL, OO_LVCREATE_POOL, OO_LVCREATE
+OO_LVCREATE_THINPOOL, OO_LVCREATE_POOL, OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thin_vol_and_thinpool
 DESC: Create a thin LV, first creating a thin pool for it,
 DESC: where the new thin pool is named in the first arg,
 DESC: or the new thin pool name is generated when the first
-DESC: arg is a VG name (variant, infers --type thin).
+DESC: arg is a VG name.
 FLAGS: SECONDARY_SYNTAX
+AUTOTYPE: thin
 
 ---
 
 lvcreate --size SizeMB --virtualsize SizeMB VG
-OO: --stripes Number, --stripesize SizeKB,
---type String, --snapshot, --thin,
+OO: --stripes Number, --stripesize SizeKB, --snapshot, --thin,
 OO_LVCREATE_THINPOOL, OO_LVCREATE_POOL, OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thin_vol_with_thinpool_or_sparse_snapshot
-DESC: Create a thin LV, first creating a thin pool for it
-DESC: (infers --type thin).
+DESC: Create a thin LV, first creating a thin pool for it.
 DESC: Create a sparse snapshot of a virtual origin LV
-DESC: (infers --type snapshot).
-DESC: Chooses --type thin or --type snapshot according to
+DESC: Chooses type thin or snapshot according to
 DESC: config setting sparse_segtype_default.
 FLAGS: SECONDARY_SYNTAX
+AUTOTYPE: thin
+AUTOTYPE: snapshot
 
 ---
 
@@ -1217,13 +1259,13 @@ DESC: which converts the new LV to type cache.
 # (omits the --type cache option which is inferred)
 lvcreate --size SizeMB --cachepool LV_cachepool VG
 OO: --stripes Number, --stripesize SizeKB,
---cache, --type cache, OO_LVCREATE_CACHE, OO_LVCREATE
+--cache, OO_LVCREATE_CACHE, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_and_attach_cachepool_v2
 DESC: Create a new LV, then attach the specified cachepool
-DESC: which converts the new LV to type cache
-DESC: (variant, infers --type cache.)
+DESC: which converts the new LV to type cache.
 FLAGS: SECONDARY_SYNTAX
+AUTOTYPE: cache
 
 # alternate form of lvcreate --type cache
 # (moves cachepool from option arg to position arg,
@@ -1260,7 +1302,7 @@ FLAGS: SECONDARY_SYNTAX
 # the LV type is known.
 
 lvcreate --cache --size SizeMB LV
-OO: --type cache, OO_LVCREATE_CACHE, OO_LVCREATE_POOL, OO_LVCREATE,
+OO: OO_LVCREATE_CACHE, OO_LVCREATE_POOL, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
 ID: lvcreate_new_plus_old_cachepool_or_lvconvert_old_plus_new_cachepool
@@ -1270,6 +1312,7 @@ DESC: (variant, use --type cache and --cachepool.)
 DESC: When the LV arg is not a cachepool, then create a new cachepool
 DESC: and attach it to the LV arg (alternative, use lvconvert.)
 FLAGS: SECONDARY_SYNTAX
+AUTOTYPE: cache
 
 ---
 
diff --git a/tools/command.c b/tools/command.c
index d6e0fec57..99661a517 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -645,6 +645,13 @@ static int _is_desc_line(char *str)
 	return 0;
 }
 
+static int _is_autotype_line(char *str)
+{
+	if (!strncmp(str, "AUTOTYPE:", 6))
+		return 1;
+	return 0;
+}
+
 static int _is_flags_line(char *str)
 {
 	if (!strncmp(str, "FLAGS:", 6))
@@ -1209,6 +1216,19 @@ static void _add_flags(struct command *cmd, char *line)
 		cmd->cmd_flags |= CMD_FLAG_PREVIOUS_SYNTAX;
 }
 
+static void _add_autotype(struct cmd_context *cmdtool, struct command *cmd, char *line)
+{
+	int line_argc;
+	char *line_argv[MAX_LINE_ARGC];
+
+	_split_line(line, &line_argc, line_argv, ' ');
+
+	if (cmd->autotype)
+		cmd->autotype2 = dm_pool_strdup(cmdtool->libmem, line_argv[1]);
+	else
+		cmd->autotype = dm_pool_strdup(cmdtool->libmem, line_argv[1]);
+}
+
 #define MAX_RULE_OPTS 64
 
 static void _add_rule(struct cmd_context *cmdtool, struct command *cmd, char *line)
@@ -1535,6 +1555,11 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 			continue;
 		}
 
+		if (_is_autotype_line(line_argv[0]) && !skip && cmd) {
+			_add_autotype(cmdtool, cmd, line_orig);
+			continue;
+		}
+
 		if (_is_flags_line(line_argv[0]) && !skip && cmd) {
 			_add_flags(cmd, line_orig);
 			continue;
@@ -1951,6 +1976,14 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 		goto op_count;
 
 	if (cmd->oo_count) {
+		if (cmd->autotype) {
+			printf("\n\t");
+			if (!cmd->autotype2)
+				printf("[ --type %s (implied) ]", cmd->autotype);
+			else
+				printf("[ --type %s|%s (implied) ]", cmd->autotype, cmd->autotype2);
+		}
+
 		if (include_extents) {
 			printf("\n\t[ -l|--extents ");
 			_print_val_usage(cmd, extents_ARG, opt_names[extents_ARG].val_enum);
@@ -2727,6 +2760,15 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 		printf(".RS 4\n");
 		printf(".ad l\n");
 
+		if (cmd->autotype) {
+			if (!cmd->autotype2)
+				printf("[ \\fB--type %s\\fP (implied) ]\n", cmd->autotype);
+			else
+				printf("[ \\fB--type %s\\fP|\\fB%s\\fP (implied) ]\n", cmd->autotype, cmd->autotype2);
+			printf(".br\n");
+			sep = 1;
+		}
+
 		if (include_extents) {
 			/*
 			 * NB we don't just pass extents_VAL here because the
diff --git a/tools/command.h b/tools/command.h
index 325ad1dd0..df994e1ae 100644
--- a/tools/command.h
+++ b/tools/command.h
@@ -208,6 +208,10 @@ struct command {
 
 	struct cmd_rule rules[CMD_MAX_RULES];
 
+	/* usually only one autotype, in one case there are two */
+	char *autotype;
+	char *autotype2;
+
 	int any_ro_count;
 
 	int ro_count;
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 23ab6fa37..d97ff5720 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1708,6 +1708,15 @@ static struct command *_find_command(struct cmd_context *cmd, const char *path,
 				continue;
 		}
 
+		/*
+		 * If the cmd def has an implied type, specified in AUTOTYPE,
+		 * then if the user command has --type, it must match.
+		 */
+		if (type_arg && commands[i].autotype && strcmp(type_arg, commands[i].autotype))
+			continue;
+		if (type_arg && commands[i].autotype2 && strcmp(type_arg, commands[i].autotype2))
+			continue;
+
 		/*
 		 * '--type foo' is special.  If the user has set --type foo, then
 		 * we will only look at command defs that include the same --type foo


