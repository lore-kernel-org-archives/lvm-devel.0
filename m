From: David Teigland <teigland@sourceware.org>
Date: Thu, 2 Mar 2017 13:59:57 -0500
Subject: master - lvcreate/lvresize: the --size option accepts signed values
Message-ID: <201703021859.v22Ixv15010220@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b7831fc14ae9a7b35c1d814486f45f4b3cbadc8b
Commit:        b7831fc14ae9a7b35c1d814486f45f4b3cbadc8b
Parent:        70c1fa3764639afd0d2e81968c4495bb3f3c6a73
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 2 12:53:01 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 2 12:53:01 2017 -0600

lvcreate/lvresize: the --size option accepts signed values

There was confusion in the code about whether or not the
--size option accepted a sign.  Make it consistent and clear
that it does.

This exposes a new problem in that an option can only
accept one value type, e.g. --size can only accept a
signed number, it cannot accept a positive or negative
number for some commands and reject negative numbers for
others.

In practice, lvcreate accepts only positive --size
values and lvresize accepts positive or negative --size
values.  There is currently no way to encode this
difference.  Until that is fixed, the man page output
is hacked to avoid printing the [+|-] prefix for sizes
in lvcreate.
---
 tools/args.h           |    4 +-
 tools/command-lines.in |   64 ++++++++++++++++++++++++------------------------
 tools/command.c        |   64 ++++++++++++++++++++++++++++++++++-------------
 tools/lvmcmdline.c     |   28 ++++++++++++++++++--
 tools/tools.h          |    3 +-
 tools/vals.h           |    4 ++-
 6 files changed, 110 insertions(+), 57 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 471a3c2..eb11f38 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -1042,7 +1042,7 @@ arg(list_ARG, 'l', "list", 0, 0, 0,
 arg(lvmpartition_ARG, 'l', "lvmpartition", 0, 0, 0,
     "Only report PVs.\n")
 
-arg(size_ARG, 'L', "size", sizemb_VAL, 0, 0,
+arg(size_ARG, 'L', "size", ssizemb_VAL, 0, 0,
     "#lvcreate\n"
     "Specifies the size of the new LV.\n"
     "The --size and --extents options are alternate methods of specifying size.\n"
@@ -1104,7 +1104,7 @@ arg(maps_ARG, 'm', "maps", 0, 0, 0,
 
 /* FIXME: should the unused mirrors option be removed from lvextend? */
 
-arg(mirrors_ARG, 'm', "mirrors", numsigned_VAL, 0, 0,
+arg(mirrors_ARG, 'm', "mirrors", snumber_VAL, 0, 0,
     "#lvcreate\n"
     "Specifies the number of mirror images in addition to the original LV\n"
     "image, e.g. --mirrors 1 means there are two images of the data, the\n"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 6956c15..295958c 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -710,7 +710,7 @@ OO_LVCREATE_RAID: --mirrors SNumber, --stripes Number, --stripesize SizeKB,
 
 ---
 
-lvcreate --type error --size SizeMB VG
+lvcreate --type error --size SSizeMB VG
 OO: OO_LVCREATE
 ID: lvcreate_error_vol
 DESC: Create an LV that returns errors when used.
@@ -718,7 +718,7 @@ FLAGS: SECONDARY_SYNTAX
 
 ---
 
-lvcreate --type zero --size SizeMB VG
+lvcreate --type zero --size SSizeMB VG
 OO: OO_LVCREATE
 ID: lvcreate_zero_vol
 DESC: Create an LV that returns zeros when read.
@@ -726,7 +726,7 @@ FLAGS: SECONDARY_SYNTAX
 
 ---
 
-lvcreate --type linear --size SizeMB VG
+lvcreate --type linear --size SSizeMB VG
 OO: OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0, --stripes 1
@@ -734,7 +734,7 @@ ID: lvcreate_linear
 DESC: Create a linear LV.
 FLAGS: SECONDARY_SYNTAX
 
-lvcreate --size SizeMB VG
+lvcreate --size SSizeMB VG
 OO: --type linear, OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0, --stripes 1
@@ -743,14 +743,14 @@ DESC: Create a linear LV.
 
 ---
 
-lvcreate --type striped --size SizeMB VG
+lvcreate --type striped --size SSizeMB VG
 OO: --stripes Number, --stripesize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_striped
 DESC: Create a striped LV (also see lvcreate --stripes).
 FLAGS: SECONDARY_SYNTAX
 
-lvcreate --stripes Number --size SizeMB VG
+lvcreate --stripes Number --size SSizeMB VG
 OO: --type striped, --stripesize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_striped
@@ -758,7 +758,7 @@ DESC: Create a striped LV (infers --type striped).
 
 ---
 
-lvcreate --type mirror --size SizeMB VG
+lvcreate --type mirror --size SSizeMB VG
 OO: --mirrors SNumber, --mirrorlog MirrorLog, --regionsize RegionSize, --stripes Number, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_mirror
@@ -766,7 +766,7 @@ DESC: Create a mirror LV (also see --type raid1).
 FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type raid1|mirror
-lvcreate --mirrors SNumber --size SizeMB VG
+lvcreate --mirrors SNumber --size SSizeMB VG
 OO: --type raid1, --type mirror, --mirrorlog MirrorLog, --stripes Number, OO_LVCREATE_RAID, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_mirror_or_raid1
@@ -774,7 +774,7 @@ DESC: Create a raid1 or mirror LV (infers --type raid1|mirror).
 
 ---
 
-lvcreate --type raid --size SizeMB VG
+lvcreate --type raid --size SSizeMB VG
 OO: OO_LVCREATE_RAID, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_raid_any
@@ -788,7 +788,7 @@ DESC: Create a raid LV (a specific raid level must be used, e.g. raid1).
 # another new LV property?
 
 # alternate form of lvcreate --snapshot
-lvcreate --type snapshot --size SizeMB LV
+lvcreate --type snapshot --size SSizeMB LV
 OO: --snapshot, --stripes Number, --stripesize SizeKB,
 --chunksize SizeKB, OO_LVCREATE
 OP: PV ...
@@ -797,7 +797,7 @@ DESC: Create a COW snapshot LV of an origin LV
 DESC: (also see --snapshot).
 FLAGS: SECONDARY_SYNTAX
 
-lvcreate --snapshot --size SizeMB LV
+lvcreate --snapshot --size SSizeMB LV
 OO: --type snapshot, --stripes Number, --stripesize SizeKB,
 --chunksize SizeKB, OO_LVCREATE
 OP: PV ...
@@ -807,7 +807,7 @@ DESC: Create a COW snapshot LV of an origin LV.
 ---
 
 # alternate form of lvcreate --snapshot
-lvcreate --type snapshot --size SizeMB --virtualsize SizeMB VG
+lvcreate --type snapshot --size SSizeMB --virtualsize SizeMB VG
 OO: --snapshot, --chunksize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_cow_snapshot_with_virtual_origin
@@ -815,7 +815,7 @@ DESC: Create a sparse COW snapshot LV of a virtual origin LV
 DESC: (also see --snapshot).
 FLAGS: SECONDARY_SYNTAX
 
-lvcreate --snapshot --size SizeMB --virtualsize SizeMB VG
+lvcreate --snapshot --size SSizeMB --virtualsize SizeMB VG
 OO: --type snapshot, --chunksize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_cow_snapshot_with_virtual_origin
@@ -824,7 +824,7 @@ FLAGS: SECONDARY_SYNTAX
 
 ---
 
-lvcreate --type thin-pool --size SizeMB VG
+lvcreate --type thin-pool --size SSizeMB VG
 OO: --thinpool LV_new, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -833,7 +833,7 @@ ID: lvcreate_thinpool
 DESC: Create a thin pool.
 
 # alternate form of lvcreate --type thin-pool
-lvcreate --thin --size SizeMB VG
+lvcreate --thin --size SSizeMB VG
 OO: --type thin-pool, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -843,7 +843,7 @@ DESC: Create a thin pool (infers --type thin-pool).
 FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin-pool
-lvcreate --size SizeMB --thinpool LV_new VG
+lvcreate --size SSizeMB --thinpool LV_new VG
 OO: --thin, --type thin-pool, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -860,14 +860,14 @@ FLAGS: SECONDARY_SYNTAX
 # still needs to be listed as an optional addition to
 # --type cache-pool.
 
-lvcreate --type cache-pool --size SizeMB VG
+lvcreate --type cache-pool --size SSizeMB VG
 OO: --cache, OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_cachepool
 DESC: Create a cache pool.
 
 # alternate form of lvcreate --type cache-pool
-lvcreate --type cache-pool --size SizeMB --cachepool LV_new VG
+lvcreate --type cache-pool --size SSizeMB --cachepool LV_new VG
 OO: --cache, OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_cachepool
@@ -972,7 +972,7 @@ FLAGS: SECONDARY_SYNTAX
 # definition.  Note that when LV_new is used in arg pos 1,
 # it needs to include a VG name, i.e. VG/LV_new
 
-lvcreate --type thin --virtualsize SizeMB --size SizeMB --thinpool LV_new
+lvcreate --type thin --virtualsize SizeMB --size SSizeMB --thinpool LV_new
 OO: --thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -982,7 +982,7 @@ DESC: Create a thin LV, first creating a thin pool for it,
 DESC: where the new thin pool is named by the --thinpool arg.
 
 # alternate form of lvcreate --type thin
-lvcreate --thin --virtualsize SizeMB --size SizeMB --thinpool LV_new
+lvcreate --thin --virtualsize SizeMB --size SSizeMB --thinpool LV_new
 OO: --type thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -994,7 +994,7 @@ DESC: (variant, infers --type thin).
 FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin
-lvcreate --type thin --virtualsize SizeMB --size SizeMB LV_new|VG
+lvcreate --type thin --virtualsize SizeMB --size SSizeMB LV_new|VG
 OO: --thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -1007,7 +1007,7 @@ DESC: arg is a VG name.
 FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin
-lvcreate --thin --virtualsize SizeMB --size SizeMB LV_new|VG
+lvcreate --thin --virtualsize SizeMB --size SSizeMB LV_new|VG
 OO: --type thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -1021,7 +1021,7 @@ FLAGS: SECONDARY_SYNTAX
 
 ---
 
-lvcreate --size SizeMB --virtualsize SizeMB VG
+lvcreate --size SSizeMB --virtualsize SizeMB VG
 OO: --type thin, --type snapshot, --thin, --snapshot, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -1041,7 +1041,7 @@ FLAGS: SECONDARY_SYNTAX
 # but here it applies to creating the new origin that
 # is used to create the cache LV
 
-lvcreate --type cache --size SizeMB --cachepool LV_cachepool VG
+lvcreate --type cache --size SSizeMB --cachepool LV_cachepool VG
 OO: --cache, OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -1051,7 +1051,7 @@ DESC: then combining it with the existing cache pool named
 DESC: by the --cachepool arg.
 
 # alternate form of lvcreate --type cache
-lvcreate --size SizeMB --cachepool LV_cachepool VG
+lvcreate --size SSizeMB --cachepool LV_cachepool VG
 OO: --type cache, --cache, OO_LVCREATE_CACHE, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -1062,7 +1062,7 @@ DESC: by the --cachepool arg (variant, infers --type cache).
 FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type cache
-lvcreate --type cache --size SizeMB LV_cachepool
+lvcreate --type cache --size SSizeMB LV_cachepool
 OO: --cache, OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -1081,7 +1081,7 @@ FLAGS: SECONDARY_SYNTAX
 #    an already complicated command above.
 #
 # # alternate form for lvcreate_cache_vol_with_new_origin
-# lvcreate --cache --size SizeMB LV_cachepool
+# lvcreate --cache --size SSizeMB LV_cachepool
 # OO: --type cache, --cache, OO_LVCREATE_CACHE, OO_LVCREATE, --stripes Number, --stripesize SizeKB
 # OP: PV ...
 # ID: lvcreate_cache_vol_with_new_origin
@@ -1093,7 +1093,7 @@ FLAGS: SECONDARY_SYNTAX
 # 2. If LV is not a cachepool, then it's a disguised lvconvert.
 #
 # # FIXME: this should be done by lvconvert, and this command removed
-# lvcreate --type cache --size SizeMB LV
+# lvcreate --type cache --size SSizeMB LV
 # OO: OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE
 # OP: PV ...
 # ID: lvcreate_convert_to_cache_vol_with_cachepool
@@ -1110,7 +1110,7 @@ FLAGS: SECONDARY_SYNTAX
 
 # def1: alternate form of lvcreate --type cache, or
 # def2: it should be done by lvconvert.
-lvcreate --cache --size SizeMB LV
+lvcreate --cache --size SSizeMB LV
 OO: OO_LVCREATE_CACHE, OO_LVCREATE_POOL, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -1144,7 +1144,7 @@ ID: lvdisplay_general
 
 # --extents is not specified; it's an automatic alternative for --size
 
-lvextend --size SizeMB LV
+lvextend --size SSizeMB LV
 OO: --alloc Alloc, --autobackup Bool, --force, --mirrors SNumber,
 --nofsck, --nosync, --noudevsync, --reportformat ReportFmt, --resizefs,
 --stripes Number, --stripesize SizeKB, --poolmetadatasize SizeMB,
@@ -1188,7 +1188,7 @@ ID: lvmconfig_general
 
 ---
 
-lvreduce --size SizeMB LV
+lvreduce --size SSizeMB LV
 OO: --autobackup Bool, --force, --nofsck, --noudevsync,
 --reportformat ReportFmt, --resizefs
 ID: lvreduce_general
@@ -1216,7 +1216,7 @@ ID: lvrename_lv_lv
 # value can be checked to match the existing type; using it doesn't
 # currently enable any different behavior.
 
-lvresize --size SizeMB LV
+lvresize --size SSizeMB LV
 OO: --alloc Alloc, --autobackup Bool, --force,
 --nofsck, --nosync, --noudevsync, --reportformat ReportFmt, --resizefs,
 --stripes Number, --stripesize SizeKB, --poolmetadatasize SizeMB,
diff --git a/tools/command.c b/tools/command.c
index e0db503..a532a10 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -74,8 +74,9 @@ static inline int cachemode_arg(struct cmd_context *cmd, struct arg_values *av)
 static inline int discards_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int mirrorlog_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int size_kb_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+static inline int ssize_kb_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int size_mb_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
-static inline int size_mb_arg_with_percent(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+static inline int ssize_mb_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int int_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int uint32_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int int_arg_with_sign(struct cmd_context *cmd, struct arg_values *av) { return 0; }
@@ -1783,7 +1784,7 @@ void print_usage_common_cmd(struct command_name *cname, struct command *cmd)
 
 #ifdef MAN_PAGE_GENERATOR
 
-static void print_val_man(const char *str)
+static void print_val_man(struct command_name *cname, const char *str)
 {
 	char *line;
 	char *line_argv[MAX_LINE_ARGC];
@@ -1791,6 +1792,23 @@ static void print_val_man(const char *str)
 	int i;
 
 	/*
+	 * FIXME: this is a terrible hack that needs to be fixed.
+	 * lvcreate and lvresize both use --size, and --size
+	 * accepts a signed number, and a signed number is
+	 * printed with a [+|-] prefix.  But lvcreate does not
+	 * accept negative numbers.  We need to do something to
+	 * have two (or more) variants of --size, one that can
+	 * accept a sign and one that cannot.  For now, this
+	 * hack just detects when we're going to print
+	 * [+|-]Size for "lvcreate" and overrides it to
+	 * omit the +|-.
+	 */
+	if (!strcmp(cname->name, "lvcreate") && !strcmp(str, "[+|-]Size[m|UNIT]")) {
+		printf("\\fISize\\fP[m|UNIT]");
+		return;
+	}
+
+	/*
 	 * Doing bold k before UNIT creates a lot of
 	 * visual "noise" that makes the text hard to read.
 	 * The extra markup in this case doesn't add anything
@@ -1807,6 +1825,16 @@ static void print_val_man(const char *str)
 		return;
 	}
 
+	if (!strcmp(str, "[+|-]Size[k|UNIT]")) {
+		printf("[\\fB+\\fP|\\fB-\\fP]\\fISize\\fP[k|UNIT]");
+		return;
+	}
+
+	if (!strcmp(str, "[+|-]Size[m|UNIT]")) {
+		printf("[\\fB+\\fP|\\fB-\\fP]\\fISize\\fP[m|UNIT]");
+		return;
+	}
+
 	if (!strcmp(str, "[+|-]Number")) {
 		printf("[\\fB+\\fP|\\fB-\\fP]\\fINumber\\fP");
 		return;
@@ -1868,7 +1896,7 @@ static void print_val_man(const char *str)
 	printf("\\fB%s\\fP", str);
 }
 
-static void print_def_man(struct arg_def *def, int usage)
+static void print_def_man(struct command_name *cname, struct arg_def *def, int usage)
 {
 	int val_enum;
 	int lvt_enum;
@@ -1897,7 +1925,7 @@ static void print_def_man(struct arg_def *def, int usage)
 					printf("%s", val_names[val_enum].name);
 					printf("\\fP");
 				} else {
-					print_val_man(val_names[val_enum].usage);
+					print_val_man(cname, val_names[val_enum].usage);
 				}
 
 				sep = 1;
@@ -2030,7 +2058,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
 
 			if (cmd->required_opt_args[ro].def.val_bits) {
 				printf(" ");
-				print_def_man(&cmd->required_opt_args[ro].def, 1);
+				print_def_man(cname, &cmd->required_opt_args[ro].def, 1);
 			}
 
 			sep++;
@@ -2057,7 +2085,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
 
 			if (cmd->required_opt_args[ro].def.val_bits) {
 				printf(" ");
-				print_def_man(&cmd->required_opt_args[ro].def, 1);
+				print_def_man(cname, &cmd->required_opt_args[ro].def, 1);
 			}
 
 			sep++;
@@ -2073,7 +2101,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
 		for (rp = 0; rp < cmd->rp_count; rp++) {
 			if (cmd->required_pos_args[rp].def.val_bits) {
 				printf(" ");
-				print_def_man(&cmd->required_pos_args[rp].def, 1);
+				print_def_man(cname, &cmd->required_pos_args[rp].def, 1);
 			}
 		}
 
@@ -2116,7 +2144,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
 
 			if (cmd->required_opt_args[ro].def.val_bits) {
 				printf(" ");
-				print_def_man(&cmd->required_opt_args[ro].def, 1);
+				print_def_man(cname, &cmd->required_opt_args[ro].def, 1);
 			}
 
 			sep++;
@@ -2128,7 +2156,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
 		for (rp = 0; rp < cmd->rp_count; rp++) {
 			if (cmd->required_pos_args[rp].def.val_bits) {
 				printf(" ");
-				print_def_man(&cmd->required_pos_args[rp].def, 1);
+				print_def_man(cname, &cmd->required_pos_args[rp].def, 1);
 			}
 		}
 
@@ -2175,7 +2203,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_def_man(&cmd->optional_opt_args[oo].def, 1);
+				print_def_man(cname, &cmd->optional_opt_args[oo].def, 1);
 			}
 			printf(" ]\n");
 			printf(".ad b\n");
@@ -2207,7 +2235,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_def_man(&cmd->optional_opt_args[oo].def, 1);
+				print_def_man(cname, &cmd->optional_opt_args[oo].def, 1);
 			}
 			printf(" ]\n");
 			printf(".ad b\n");
@@ -2235,7 +2263,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
 		for (op = 0; op < cmd->op_count; op++) {
 			if (cmd->optional_pos_args[op].def.val_bits) {
 				printf(" ");
-				print_def_man(&cmd->optional_pos_args[op].def, 1);
+				print_def_man(cname, &cmd->optional_pos_args[op].def, 1);
 			}
 		}
 	}
@@ -2303,7 +2331,7 @@ void print_man_usage_common_lvm(struct command *cmd)
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_def_man(&cmd->optional_opt_args[oo].def, 1);
+				print_def_man(cname, &cmd->optional_opt_args[oo].def, 1);
 			}
 			printf(" ]\n");
 			printf(".ad b\n");
@@ -2338,7 +2366,7 @@ void print_man_usage_common_lvm(struct command *cmd)
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_def_man(&cmd->optional_opt_args[oo].def, 1);
+				print_def_man(cname, &cmd->optional_opt_args[oo].def, 1);
 			}
 			printf(" ]\n");
 			printf(".ad b\n");
@@ -2400,7 +2428,7 @@ void print_man_usage_common_cmd(struct command *cmd)
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_def_man(&cmd->optional_opt_args[oo].def, 1);
+				print_def_man(cname, &cmd->optional_opt_args[oo].def, 1);
 			}
 			printf(" ]\n");
 			printf(".ad b\n");
@@ -2442,7 +2470,7 @@ void print_man_usage_common_cmd(struct command *cmd)
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_def_man(&cmd->optional_opt_args[oo].def, 1);
+				print_def_man(cname, &cmd->optional_opt_args[oo].def, 1);
 			}
 			printf(" ]\n");
 			printf(".ad b\n");
@@ -2577,7 +2605,7 @@ void print_man_all_options_list(struct command_name *cname)
 			printf("\\fP");
 		} else {
 			printf(" ");
-			print_val_man(val_names[val_enum].usage);
+			print_val_man(cname, val_names[val_enum].usage);
 		}
 
 		printf("\n.ad b\n");
@@ -2625,7 +2653,7 @@ void print_man_all_options_desc(struct command_name *cname)
 			printf("\\fP");
 		} else {
 			printf(" ");
-			print_val_man(val_names[val_enum].usage);
+			print_val_man(cname, val_names[val_enum].usage);
 		}
 
 		if (opt_names[opt_enum].flags & ARG_COUNTABLE)
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index d5385a8..5410a1f 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -629,19 +629,41 @@ static int _size_arg(struct cmd_context *cmd __attribute__((unused)),
 	return 1;
 }
 
+/* negative not accepted */
 int size_kb_arg(struct cmd_context *cmd, struct arg_values *av)
 {
+	if (!_size_arg(cmd, av, 2, 0))
+		return 0;
+
+	if (av->sign == SIGN_MINUS) {
+		log_error("Size may not be negative.");
+		return 0;
+	}
+
+	return 1;
+}
+
+int ssize_kb_arg(struct cmd_context *cmd, struct arg_values *av)
+{
 	return _size_arg(cmd, av, 2, 0);
 }
 
 int size_mb_arg(struct cmd_context *cmd, struct arg_values *av)
 {
-	return _size_arg(cmd, av, 2048, 0);
+	if (!_size_arg(cmd, av, 2048, 0))
+		return 0;
+
+	if (av->sign == SIGN_MINUS) {
+		log_error("Size may not be negative.");
+		return 0;
+	}
+
+	return 1;
 }
 
-int size_mb_arg_with_percent(struct cmd_context *cmd, struct arg_values *av)
+int ssize_mb_arg(struct cmd_context *cmd, struct arg_values *av)
 {
-	return _size_arg(cmd, av, 2048, 1);
+	return _size_arg(cmd, av, 2048, 0);
 }
 
 int int_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
diff --git a/tools/tools.h b/tools/tools.h
index 1e1e7f1..f2c926f 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -183,8 +183,9 @@ int cachemode_arg(struct cmd_context *cmd, struct arg_values *av);
 int discards_arg(struct cmd_context *cmd, struct arg_values *av);
 int mirrorlog_arg(struct cmd_context *cmd, struct arg_values *av);
 int size_kb_arg(struct cmd_context *cmd, struct arg_values *av);
+int ssize_kb_arg(struct cmd_context *cmd, struct arg_values *av);
 int size_mb_arg(struct cmd_context *cmd, struct arg_values *av);
-int size_mb_arg_with_percent(struct cmd_context *cmd, struct arg_values *av);
+int ssize_mb_arg(struct cmd_context *cmd, struct arg_values *av);
 int int_arg(struct cmd_context *cmd, struct arg_values *av);
 int uint32_arg(struct cmd_context *cmd, struct arg_values *av);
 int int_arg_with_sign(struct cmd_context *cmd, struct arg_values *av);
diff --git a/tools/vals.h b/tools/vals.h
index d485926..ab1b715 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -117,8 +117,10 @@ val(discards_VAL, discards_arg, "Discards", "passdown|nopassdown|ignore")
 val(mirrorlog_VAL, mirrorlog_arg, "MirrorLog", "core|disk")
 val(sizekb_VAL, size_kb_arg, "SizeKB", "Size[k|UNIT]")
 val(sizemb_VAL, size_mb_arg, "SizeMB", "Size[m|UNIT]")
+val(ssizekb_VAL, ssize_kb_arg, "SSizeKB", "[+|-]Size[k|UNIT]")
+val(ssizemb_VAL, ssize_mb_arg, "SSizeMB", "[+|-]Size[m|UNIT]")
 val(regionsize_VAL, regionsize_arg, "RegionSize", "Size[m|UNIT]")
-val(numsigned_VAL, int_arg_with_sign, "SNumber", "[+|-]Number")
+val(snumber_VAL, int_arg_with_sign, "SNumber", "[+|-]Number")
 val(extents_VAL, extents_arg, "Extents", "[+|-]Number[%VG|%PVS|%FREE]")
 val(permission_VAL, permission_arg, "Permission", "rw|r")
 val(metadatatype_VAL, metadatatype_arg, "MetadataType", "lvm2|lvm1")


