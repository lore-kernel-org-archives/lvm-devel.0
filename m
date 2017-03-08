From: David Teigland <teigland@sourceware.org>
Date: Wed, 8 Mar 2017 13:54:58 -0500
Subject: master - commands: clean up and unify signed option value handling
Message-ID: <201703081854.v28IswbN006229@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a6a2788e7cb3a7bce73b03644351f15f26a6ad36
Commit:        a6a2788e7cb3a7bce73b03644351f15f26a6ad36
Parent:        7f25fbe1547f06f4de880fbf6d28b83cebc7e16d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 7 16:55:07 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 8 12:54:43 2017 -0600

commands: clean up and unify signed option value handling

Add new values for different sign variations, resulting in:

size_VAL      no sign accepted
ssize_VAL     accepts + or -
psize_VAL     accepts +
nsize_VAL     accpets -

extents_VAL   no sign accepted
sextents_VAL  accepts + or -
pextents_VAL  accepts +
nextents_VAL  accepts -

Depending on the command being run, change the option
values for --size, --extents, --poolmetadatasize to
use the appropriate value from above.

lvcreate uses no sign (but accepts + and ignores it).
lvresize accepts +|- for a relative change.
lvextend accepts + for a relative change.
lvreduce accepts - for a relative change.
---
 tools/args.h           |   31 ++++----
 tools/command-lines.in |   70 ++++++++--------
 tools/command.c        |  204 +++++++++++++++++++++++++++++++++---------------
 tools/command.h        |    2 +
 tools/lvmcmdline.c     |   86 +++++++++++++++++++-
 tools/tools.h          |    5 +
 tools/vals.h           |   13 ++--
 7 files changed, 287 insertions(+), 124 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 7bb177d..821c56d 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -414,7 +414,7 @@ arg(pooldatasize_ARG, '\0', "pooldatasize", sizemb_VAL, 0, 0, NULL)
 arg(poolmetadata_ARG, '\0', "poolmetadata", lv_VAL, 0, 0,
     "The name of a an LV to use for storing pool metadata.\n")
 
-arg(poolmetadatasize_ARG, '\0', "poolmetadatasize", ssizemb_VAL, 0, 0,
+arg(poolmetadatasize_ARG, '\0', "poolmetadatasize", sizemb_VAL, 0, 0,
     "#lvcreate\n"
     "#lvconvert\n"
     "Specifies the size of the new pool metadata LV.\n"
@@ -994,6 +994,11 @@ arg(logicalvolume_ARG, 'l', "logicalvolume", uint32_VAL, 0, 0,
 arg(maxlogicalvolumes_ARG, 'l', "maxlogicalvolumes", uint32_VAL, 0, 0,
     "Sets the maximum number of LVs allowed in a VG.\n")
 
+/*
+ * The extents_VAL is overriden in configure_command_option_values()
+ * according to the command being run.  Different commands accept
+ * different signs with the value.
+ */
 arg(extents_ARG, 'l', "extents", extents_VAL, 0, 0,
     "#lvcreate\n"
     "Specifies the size of the new LV in logical extents.\n"
@@ -1029,9 +1034,9 @@ arg(extents_ARG, 'l', "extents", extents_VAL, 0, 0,
     "When expressed as a percentage, the size defines an upper limit for the\n"
     "number of logical extents in the new LV. The precise number of logical\n"
     "extents in the new LV is not determined until the command has completed.\n"
-    "The plus \\fB+\\fP or minus \\fB-\\fP prefix can be used, in which case\n"
-    "the value is not an absolute size, but is an amount added or subtracted\n"
-    "relative to the current size.\n")
+    "When the plus \\fB+\\fP or minus \\fB-\\fP prefix is used,\n"
+    "the value is not an absolute size, but is relative and added or subtracted\n"
+    "from the current size.\n")
 
 arg(list_ARG, 'l', "list", 0, 0, 0,
     "#lvmconfig\n"
@@ -1049,14 +1054,11 @@ arg(lvmpartition_ARG, 'l', "lvmpartition", 0, 0, 0,
     "Only report PVs.\n")
 
 /*
- * FIXME: for lvcreate, size only accepts absolute values, no +|-,
- * for lvresize, size can relative +|-, for lvreduce, size
- * can be relative -, and for lvextend, size can be relative +.
- * Should we define separate val enums for each of those cases,
- * and at the start of the command, change the val type for
- * size_ARG?  The same for extents_ARG.
+ * The sizemb_VAL is overriden in configure_command_option_values()
+ * according to the command being run.  Different commands accept
+ * different signs with the value.
  */
-arg(size_ARG, 'L', "size", ssizemb_VAL, 0, 0,
+arg(size_ARG, 'L', "size", sizemb_VAL, 0, 0,
     "#lvcreate\n"
     "Specifies the size of the new LV.\n"
     "The --size and --extents options are alternate methods of specifying size.\n"
@@ -1069,10 +1071,9 @@ arg(size_ARG, 'L', "size", ssizemb_VAL, 0, 0,
     "The --size and --extents options are alternate methods of specifying size.\n"
     "The total number of physical extents used will be\n"
     "greater when redundant data is needed for RAID levels.\n"
-    "The plus prefix \\fB+\\fP can be used, in which case\n"
-    "the value is added to the current size,\n"
-    "or the minus prefix \\fB-\\fP can be used, in which case\n"
-    "the value is subtracted from the current size.\n")
+    "When the plus \\fB+\\fP or minus \\fB-\\fP prefix is used,\n"
+    "the value is not an absolute size, but is relative and added or subtracted\n"
+    "from the current size.\n")
 
 arg(persistent_ARG, 'M', "persistent", bool_VAL, 0, 0,
     "When yes, makes the specified minor number persistent.\n")
diff --git a/tools/command-lines.in b/tools/command-lines.in
index b1405b6..4f2ab44 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -307,7 +307,7 @@ RULE: all not LV_thinpool LV_cachepool
 OO_LVCONVERT_RAID: --mirrors SNumber, --stripes_long Number,
 --stripesize SizeKB, --regionsize RegionSize, --interval Number
 
-OO_LVCONVERT_POOL: --poolmetadata LV, --poolmetadatasize SSizeMB,
+OO_LVCONVERT_POOL: --poolmetadata LV, --poolmetadatasize SizeMB,
 --poolmetadataspare Bool, --readahead Readahead, --chunksize SizeKB
 
 OO_LVCONVERT_CACHE: --cachemode CacheMode, --cachepolicy String,
@@ -702,7 +702,7 @@ OO_LVCREATE: --addtag Tag, --alloc Alloc, --autobackup Bool, --activate Active,
 OO_LVCREATE_CACHE: --cachemode CacheMode, --cachepolicy String, --cachesettings String,
 --chunksize SizeKB
 
-OO_LVCREATE_POOL: --poolmetadatasize SSizeMB, --poolmetadataspare Bool, --chunksize SizeKB
+OO_LVCREATE_POOL: --poolmetadatasize SizeMB, --poolmetadataspare Bool, --chunksize SizeKB
 
 OO_LVCREATE_THIN: --discards Discards, --errorwhenfull Bool
 
@@ -711,7 +711,7 @@ OO_LVCREATE_RAID: --mirrors SNumber, --stripes Number, --stripesize SizeKB,
 
 ---
 
-lvcreate --type error --size SSizeMB VG
+lvcreate --type error --size SizeMB VG
 OO: OO_LVCREATE
 ID: lvcreate_error_vol
 DESC: Create an LV that returns errors when used.
@@ -719,7 +719,7 @@ FLAGS: SECONDARY_SYNTAX
 
 ---
 
-lvcreate --type zero --size SSizeMB VG
+lvcreate --type zero --size SizeMB VG
 OO: OO_LVCREATE
 ID: lvcreate_zero_vol
 DESC: Create an LV that returns zeros when read.
@@ -727,7 +727,7 @@ FLAGS: SECONDARY_SYNTAX
 
 ---
 
-lvcreate --type linear --size SSizeMB VG
+lvcreate --type linear --size SizeMB VG
 OO: OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0, --stripes 1
@@ -735,7 +735,7 @@ ID: lvcreate_linear
 DESC: Create a linear LV.
 FLAGS: SECONDARY_SYNTAX
 
-lvcreate --size SSizeMB VG
+lvcreate --size SizeMB VG
 OO: --type linear, OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0, --stripes 1
@@ -744,14 +744,14 @@ DESC: Create a linear LV.
 
 ---
 
-lvcreate --type striped --size SSizeMB VG
+lvcreate --type striped --size SizeMB VG
 OO: --stripes Number, --stripesize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_striped
 DESC: Create a striped LV (also see lvcreate --stripes).
 FLAGS: SECONDARY_SYNTAX
 
-lvcreate --stripes Number --size SSizeMB VG
+lvcreate --stripes Number --size SizeMB VG
 OO: --type striped, --stripesize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_striped
@@ -759,7 +759,7 @@ DESC: Create a striped LV (infers --type striped).
 
 ---
 
-lvcreate --type mirror --size SSizeMB VG
+lvcreate --type mirror --size SizeMB VG
 OO: --mirrors SNumber, --mirrorlog MirrorLog, --regionsize RegionSize, --stripes Number, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_mirror
@@ -767,7 +767,7 @@ DESC: Create a mirror LV (also see --type raid1).
 FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type raid1|mirror
-lvcreate --mirrors SNumber --size SSizeMB VG
+lvcreate --mirrors SNumber --size SizeMB VG
 OO: --type raid1, --type mirror, --mirrorlog MirrorLog, --stripes Number, OO_LVCREATE_RAID, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_mirror_or_raid1
@@ -775,7 +775,7 @@ DESC: Create a raid1 or mirror LV (infers --type raid1|mirror).
 
 ---
 
-lvcreate --type raid --size SSizeMB VG
+lvcreate --type raid --size SizeMB VG
 OO: OO_LVCREATE_RAID, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_raid_any
@@ -789,7 +789,7 @@ DESC: Create a raid LV (a specific raid level must be used, e.g. raid1).
 # another new LV property?
 
 # alternate form of lvcreate --snapshot
-lvcreate --type snapshot --size SSizeMB LV
+lvcreate --type snapshot --size SizeMB LV
 OO: --snapshot, --stripes Number, --stripesize SizeKB,
 --chunksize SizeKB, OO_LVCREATE
 OP: PV ...
@@ -798,7 +798,7 @@ DESC: Create a COW snapshot LV of an origin LV
 DESC: (also see --snapshot).
 FLAGS: SECONDARY_SYNTAX
 
-lvcreate --snapshot --size SSizeMB LV
+lvcreate --snapshot --size SizeMB LV
 OO: --type snapshot, --stripes Number, --stripesize SizeKB,
 --chunksize SizeKB, OO_LVCREATE
 OP: PV ...
@@ -808,7 +808,7 @@ DESC: Create a COW snapshot LV of an origin LV.
 ---
 
 # alternate form of lvcreate --snapshot
-lvcreate --type snapshot --size SSizeMB --virtualsize SizeMB VG
+lvcreate --type snapshot --size SizeMB --virtualsize SizeMB VG
 OO: --snapshot, --chunksize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_cow_snapshot_with_virtual_origin
@@ -816,7 +816,7 @@ DESC: Create a sparse COW snapshot LV of a virtual origin LV
 DESC: (also see --snapshot).
 FLAGS: SECONDARY_SYNTAX
 
-lvcreate --snapshot --size SSizeMB --virtualsize SizeMB VG
+lvcreate --snapshot --size SizeMB --virtualsize SizeMB VG
 OO: --type snapshot, --chunksize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_cow_snapshot_with_virtual_origin
@@ -825,7 +825,7 @@ FLAGS: SECONDARY_SYNTAX
 
 ---
 
-lvcreate --type thin-pool --size SSizeMB VG
+lvcreate --type thin-pool --size SizeMB VG
 OO: --thinpool LV_new, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -834,7 +834,7 @@ ID: lvcreate_thinpool
 DESC: Create a thin pool.
 
 # alternate form of lvcreate --type thin-pool
-lvcreate --thin --size SSizeMB VG
+lvcreate --thin --size SizeMB VG
 OO: --type thin-pool, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -844,7 +844,7 @@ DESC: Create a thin pool (infers --type thin-pool).
 FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin-pool
-lvcreate --size SSizeMB --thinpool LV_new VG
+lvcreate --size SizeMB --thinpool LV_new VG
 OO: --thin, --type thin-pool, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -861,14 +861,14 @@ FLAGS: SECONDARY_SYNTAX
 # still needs to be listed as an optional addition to
 # --type cache-pool.
 
-lvcreate --type cache-pool --size SSizeMB VG
+lvcreate --type cache-pool --size SizeMB VG
 OO: --cache, OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_cachepool
 DESC: Create a cache pool.
 
 # alternate form of lvcreate --type cache-pool
-lvcreate --type cache-pool --size SSizeMB --cachepool LV_new VG
+lvcreate --type cache-pool --size SizeMB --cachepool LV_new VG
 OO: --cache, OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_cachepool
@@ -973,7 +973,7 @@ FLAGS: SECONDARY_SYNTAX
 # definition.  Note that when LV_new is used in arg pos 1,
 # it needs to include a VG name, i.e. VG/LV_new
 
-lvcreate --type thin --virtualsize SizeMB --size SSizeMB --thinpool LV_new
+lvcreate --type thin --virtualsize SizeMB --size SizeMB --thinpool LV_new
 OO: --thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -983,7 +983,7 @@ DESC: Create a thin LV, first creating a thin pool for it,
 DESC: where the new thin pool is named by the --thinpool arg.
 
 # alternate form of lvcreate --type thin
-lvcreate --thin --virtualsize SizeMB --size SSizeMB --thinpool LV_new
+lvcreate --thin --virtualsize SizeMB --size SizeMB --thinpool LV_new
 OO: --type thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -995,7 +995,7 @@ DESC: (variant, infers --type thin).
 FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin
-lvcreate --type thin --virtualsize SizeMB --size SSizeMB LV_new|VG
+lvcreate --type thin --virtualsize SizeMB --size SizeMB LV_new|VG
 OO: --thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -1008,7 +1008,7 @@ DESC: arg is a VG name.
 FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin
-lvcreate --thin --virtualsize SizeMB --size SSizeMB LV_new|VG
+lvcreate --thin --virtualsize SizeMB --size SizeMB LV_new|VG
 OO: --type thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -1022,7 +1022,7 @@ FLAGS: SECONDARY_SYNTAX
 
 ---
 
-lvcreate --size SSizeMB --virtualsize SizeMB VG
+lvcreate --size SizeMB --virtualsize SizeMB VG
 OO: --type thin, --type snapshot, --thin, --snapshot, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -1042,7 +1042,7 @@ FLAGS: SECONDARY_SYNTAX
 # but here it applies to creating the new origin that
 # is used to create the cache LV
 
-lvcreate --type cache --size SSizeMB --cachepool LV_cachepool VG
+lvcreate --type cache --size SizeMB --cachepool LV_cachepool VG
 OO: --cache, OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -1052,7 +1052,7 @@ DESC: then combining it with the existing cache pool named
 DESC: by the --cachepool arg.
 
 # alternate form of lvcreate --type cache
-lvcreate --size SSizeMB --cachepool LV_cachepool VG
+lvcreate --size SizeMB --cachepool LV_cachepool VG
 OO: --type cache, --cache, OO_LVCREATE_CACHE, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -1063,7 +1063,7 @@ DESC: by the --cachepool arg (variant, infers --type cache).
 FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type cache
-lvcreate --type cache --size SSizeMB LV_cachepool
+lvcreate --type cache --size SizeMB LV_cachepool
 OO: --cache, OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -1082,7 +1082,7 @@ FLAGS: SECONDARY_SYNTAX
 #    an already complicated command above.
 #
 # # alternate form for lvcreate_cache_vol_with_new_origin
-# lvcreate --cache --size SSizeMB LV_cachepool
+# lvcreate --cache --size SizeMB LV_cachepool
 # OO: --type cache, --cache, OO_LVCREATE_CACHE, OO_LVCREATE, --stripes Number, --stripesize SizeKB
 # OP: PV ...
 # ID: lvcreate_cache_vol_with_new_origin
@@ -1094,7 +1094,7 @@ FLAGS: SECONDARY_SYNTAX
 # 2. If LV is not a cachepool, then it's a disguised lvconvert.
 #
 # # FIXME: this should be done by lvconvert, and this command removed
-# lvcreate --type cache --size SSizeMB LV
+# lvcreate --type cache --size SizeMB LV
 # OO: OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE
 # OP: PV ...
 # ID: lvcreate_convert_to_cache_vol_with_cachepool
@@ -1111,7 +1111,7 @@ FLAGS: SECONDARY_SYNTAX
 
 # def1: alternate form of lvcreate --type cache, or
 # def2: it should be done by lvconvert.
-lvcreate --cache --size SSizeMB LV
+lvcreate --cache --size SizeMB LV
 OO: OO_LVCREATE_CACHE, OO_LVCREATE_POOL, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
@@ -1145,10 +1145,10 @@ ID: lvdisplay_general
 
 # --extents is not specified; it's an automatic alternative for --size
 
-lvextend --size SSizeMB LV
+lvextend --size PSizeMB LV
 OO: --alloc Alloc, --autobackup Bool, --force, --mirrors SNumber,
 --nofsck, --nosync, --noudevsync, --reportformat ReportFmt, --resizefs,
---stripes Number, --stripesize SizeKB, --poolmetadatasize SSizeMB,
+--stripes Number, --stripesize SizeKB, --poolmetadatasize PSizeMB,
 --type SegType
 OP: PV ...
 ID: lvextend_by_size
@@ -1162,7 +1162,7 @@ OO: --alloc Alloc, --autobackup Bool, --force, --mirrors SNumber,
 ID: lvextend_by_pv
 DESC: Extend an LV by specified PV extents.
 
-lvextend --poolmetadatasize SSizeMB LV_thinpool
+lvextend --poolmetadatasize PSizeMB LV_thinpool
 OO: --alloc Alloc, --autobackup Bool, --force, --mirrors SNumber,
 --nofsck, --nosync, --noudevsync,
 --reportformat ReportFmt, --stripes Number, --stripesize SizeKB,
@@ -1189,7 +1189,7 @@ ID: lvmconfig_general
 
 ---
 
-lvreduce --size SSizeMB LV
+lvreduce --size NSizeMB LV
 OO: --autobackup Bool, --force, --nofsck, --noudevsync,
 --reportformat ReportFmt, --resizefs
 ID: lvreduce_general
diff --git a/tools/command.c b/tools/command.c
index bfd3d7d..0d56e51 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -77,10 +77,15 @@ static inline int size_kb_arg(struct cmd_context *cmd, struct arg_values *av) {
 static inline int ssize_kb_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int size_mb_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int ssize_mb_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+static inline int psize_mb_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+static inline int nsize_mb_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int int_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int uint32_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int int_arg_with_sign(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int extents_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+static inline int sextents_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+static inline int pextents_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+static inline int nextents_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int major_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int minor_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int string_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
@@ -1513,6 +1518,61 @@ int define_commands(char *run_name)
 	return 1;
 }
 
+/*
+ * This does not change the option vals in the cmd defs in commands[]
+ * which are used when printing help/man output.
+ *
+ * The specific val types for each command are specified in
+ * command-lines.in/commands[], and those are used for printing
+ * man/help.  But the opt_names[] array for each option is global
+ * and has no command name context.  So the opt_names[] array always
+ * specifies a non-signed val, e.g. sizemb_VAL, extents_VAL.  The
+ * opt_names[] array is used by run time processing, and for part
+ * of the help/man output.  This adjusts the opt_names[] val types
+ * according to the command being run.
+ */
+void configure_command_option_values(const char *name)
+{
+	if (!strcmp(name, "lvresize")) {
+		/* relative +|- allowed */
+		opt_names[size_ARG].val_enum = ssizemb_VAL;
+		opt_names[extents_ARG].val_enum = sextents_VAL;
+		opt_names[poolmetadatasize_ARG].val_enum = ssizemb_VAL;
+		return;
+	}
+
+	if (!strcmp(name, "lvextend")) {
+		/* relative + allowed */
+		opt_names[size_ARG].val_enum = psizemb_VAL;
+		opt_names[extents_ARG].val_enum = pextents_VAL;
+		opt_names[poolmetadatasize_ARG].val_enum = psizemb_VAL;
+		return;
+	}
+
+	if (!strcmp(name, "lvreduce")) {
+		/* relative - allowed */
+		opt_names[size_ARG].val_enum = nsizemb_VAL;
+		opt_names[extents_ARG].val_enum = nextents_VAL;
+		return;
+	}
+
+	if (!strcmp(name, "lvcreate")) {
+		/*
+		 * lvcreate is a bit of a mess because it has previously
+		 * accepted + but used it as an absolute value, so we
+		 * have to recognize it.  (We don't want to show the +
+		 * option in man/help, though, since it's confusing,
+		 * so there's a special case when printing man/help
+		 * output to show sizemb_VAL/extents_VAL rather than
+		 * psizemb_VAL/pextents_VAL.)
+		 */
+		opt_names[size_ARG].val_enum = psizemb_VAL;
+		opt_names[extents_ARG].val_enum = pextents_VAL;
+		opt_names[poolmetadatasize_ARG].val_enum = psizemb_VAL;
+		return;
+	}
+}
+
 /* type_LVT to "type" */
 
 static const char *lvt_enum_to_name(int lvt_enum)
@@ -1555,29 +1615,21 @@ static void _print_usage_description(struct command *cmd)
 	}
 }
 
-static void print_val_usage(struct command *cmd, int val_enum)
+static void print_val_usage(struct command *cmd, int opt_enum, int val_enum)
 {
-	int squash_sign_prefix;
+	int is_relative_opt = (opt_enum == size_ARG) ||
+			      (opt_enum == extents_ARG) ||
+			      (opt_enum == poolmetadatasize_ARG);
 
 	/*
-	 * lvcreate does not take a relative [+|-] value
-	 * for --size or --extents.
-	 * Should we also squash - for lvextend and + for lvreduce?
-	 *
-	 * Should also squash +|- in front of poolmetadatasize value
-	 * in lvcreate and lvconvert, and squash - in front of
-	 * poolmetadatasize value in lvresize/lvextend.
+	 * Suppress the [+] prefix for lvcreate which we have to
+	 * accept for backwards compat, but don't want to advertise.
 	 */
-	squash_sign_prefix = !strcmp(cmd->name, "lvcreate");
-
-	if ((val_enum == ssizemb_VAL) && squash_sign_prefix) {
-		printf("Size[m|UNIT]");
-		return;
-	}
-
-	if ((val_enum == extents_VAL) && squash_sign_prefix) {
-		printf("Number[PERCENT]");
-		return;
+	if (!strcmp(cmd->name, "lvcreate") && is_relative_opt) {
+		if (val_enum == psizemb_VAL)
+			val_enum = sizemb_VAL;
+		else if (val_enum == pextents_VAL)
+			val_enum = extents_VAL;
 	}
 
 	if (!val_names[val_enum].usage)
@@ -1603,7 +1655,7 @@ static void print_usage_def(struct command *cmd, int opt_enum, struct arg_def *d
 
 			else {
 				if (sep) printf("|");
-				print_val_usage(cmd, val_enum);
+				print_val_usage(cmd, opt_enum, val_enum);
 				sep = 1;
 			}
 
@@ -1724,7 +1776,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 	if (cmd->oo_count) {
 		if (include_extents) {
 			printf("\n\t[ -l|--extents ");
-			print_val_usage(cmd, extents_VAL);
+			print_val_usage(cmd, extents_ARG, opt_names[extents_ARG].val_enum);
 			printf(" ]");
 		}
 
@@ -2028,59 +2080,75 @@ void print_usage_notes(struct command_name *cname)
  * Otherwise, this function has to be updated in
  * sync with any string changes in vals.h
  */
-static void print_val_man(struct command_name *cname, int val_enum)
+static void print_val_man(struct command_name *cname, int opt_enum, int val_enum)
 {
 	const char *str = val_names[val_enum].usage;
 	char *line;
 	char *line_argv[MAX_LINE_ARGC];
 	int line_argc;
 	int i;
-	int squash_sign_prefix;
+	int is_relative_opt = (opt_enum == size_ARG) ||
+			      (opt_enum == extents_ARG) ||
+			      (opt_enum == poolmetadatasize_ARG);
 
 	/*
-	 * lvcreate does not take a relative [+|-] value
-	 * for --size or --extents.
-	 * Should we also squash - for lvextend and + for lvreduce?
-	 *
-	 * Should also squash +|- in front of poolmetadatasize value
-	 * in lvcreate and lvconvert, and squash - in front of
-	 * poolmetadatasize value in lvresize/lvextend.
+	 * Suppress the [+] prefix for lvcreate which we have to
+	 * accept for backwards compat, but don't want to advertise.
 	 */
-	squash_sign_prefix = !strcmp(cname->name, "lvcreate");
+	if (!strcmp(cname->name, "lvcreate") && is_relative_opt) {
+		if (val_enum == psizemb_VAL)
+			val_enum = sizemb_VAL;
+		else if (val_enum == pextents_VAL)
+			val_enum = extents_VAL;
+	}
+
+	if (val_enum == sizemb_VAL) {
+		printf("\\fISize\\fP[m|UNIT]");
+		return;
+	}
 
 	if (val_enum == ssizemb_VAL) {
-		if (squash_sign_prefix)
-			printf("\\fISize\\fP[m|UNIT]");
-		else
-			printf("[\\fB+\\fP|\\fB-\\fP]\\fISize\\fP[m|UNIT]");
+		printf("[\\fB+\\fP|\\fB-\\fP]\\fISize\\fP[m|UNIT]");
+		return;
+	}
+
+	if (val_enum == psizemb_VAL) {
+		printf("[\\fB+\\fP]\\fISize\\fP[m|UNIT]");
+		return;
+	}
+
+	if (val_enum == nsizemb_VAL) {
+		printf("[\\fB-\\fP]\\fISize\\fP[m|UNIT]");
 		return;
 	}
 
 	if (val_enum == extents_VAL) {
-		if (squash_sign_prefix)
-			printf("\\fINumber\\fP[PERCENT]");
-		else
-			printf("[\\fB+\\fP|\\fB-\\fP]\\fINumber\\fP[PERCENT]");
+		printf("\\fINumber\\fP[PERCENT]");
 		return;
 	}
 
-	if (val_enum == sizekb_VAL) {
-		printf("\\fISize\\fP[k|UNIT]");
+	if (val_enum == sextents_VAL) {
+		printf("[\\fB+\\fP|\\fB-\\fP]\\fINumber\\fP[PERCENT]");
 		return;
 	}
 
-	if (val_enum == sizemb_VAL) {
-		printf("\\fISize\\fP[m|UNIT]");
+	if (val_enum == pextents_VAL) {
+		printf("[\\fB+\\fP]\\fINumber\\fP[PERCENT]");
 		return;
 	}
 
-	if (val_enum == ssizekb_VAL) {
-		printf("[\\fB+\\fP|\\fB-\\fP]\\fISize\\fP[k|UNIT]");
+	if (val_enum == nextents_VAL) {
+		printf("[\\fB-\\fP]\\fINumber\\fP[PERCENT]");
 		return;
 	}
 
-	if (val_enum == ssizemb_VAL) {
-		printf("[\\fB+\\fP|\\fB-\\fP]\\fISize\\fP[m|UNIT]");
+	if (val_enum == sizekb_VAL) {
+		printf("\\fISize\\fP[k|UNIT]");
+		return;
+	}
+
+	if (val_enum == ssizekb_VAL) {
+		printf("[\\fB+\\fP|\\fB-\\fP]\\fISize\\fP[k|UNIT]");
 		return;
 	}
 
@@ -2127,7 +2195,7 @@ static void print_val_man(struct command_name *cname, int val_enum)
 	printf("\\fB%s\\fP", str);
 }
 
-static void print_def_man(struct command_name *cname, struct arg_def *def, int usage)
+static void print_def_man(struct command_name *cname, int opt_enum, struct arg_def *def, int usage)
 {
 	int val_enum;
 	int lvt_enum;
@@ -2156,7 +2224,7 @@ static void print_def_man(struct command_name *cname, struct arg_def *def, int u
 					printf("%s", val_names[val_enum].name);
 					printf("\\fP");
 				} else {
-					print_val_man(cname, val_enum);
+					print_val_man(cname, opt_enum, val_enum);
 				}
 
 				sep = 1;
@@ -2290,7 +2358,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
 
 			if (cmd->required_opt_args[ro].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, &cmd->required_opt_args[ro].def, 1);
+				print_def_man(cname, opt_enum, &cmd->required_opt_args[ro].def, 1);
 			}
 
 			sep++;
@@ -2317,7 +2385,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
 
 			if (cmd->required_opt_args[ro].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, &cmd->required_opt_args[ro].def, 1);
+				print_def_man(cname, opt_enum, &cmd->required_opt_args[ro].def, 1);
 			}
 
 			sep++;
@@ -2333,7 +2401,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
 		for (rp = 0; rp < cmd->rp_count; rp++) {
 			if (cmd->required_pos_args[rp].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, &cmd->required_pos_args[rp].def, 1);
+				print_def_man(cname, 0, &cmd->required_pos_args[rp].def, 1);
 			}
 		}
 
@@ -2379,7 +2447,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
 
 			if (cmd->required_opt_args[ro].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, &cmd->required_opt_args[ro].def, 1);
+				print_def_man(cname, opt_enum, &cmd->required_opt_args[ro].def, 1);
 			}
 
 			sep++;
@@ -2391,7 +2459,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
 		for (rp = 0; rp < cmd->rp_count; rp++) {
 			if (cmd->required_pos_args[rp].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, &cmd->required_pos_args[rp].def, 1);
+				print_def_man(cname, 0, &cmd->required_pos_args[rp].def, 1);
 			}
 		}
 
@@ -2415,9 +2483,14 @@ void print_man_usage(char *lvmname, struct command *cmd)
 		printf(".RS 4\n");
 
 		if (include_extents) {
+			/*
+			 * NB we don't just pass extents_VAL here because the
+			 * actual val type for extents_ARG has been adjusted
+			 * in opt_names[] according to the command name.
+			 */
 			printf(".ad l\n");
 			printf("[ \\fB-l\\fP|\\fB--extents\\fP ");
-			print_val_man(cname, extents_VAL);
+			print_val_man(cname, extents_ARG, opt_names[extents_ARG].val_enum);
 			printf(" ]\n");
 			printf(".ad b\n");
 			sep = 1;
@@ -2447,7 +2520,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, &cmd->optional_opt_args[oo].def, 1);
+				print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
 			}
 			printf(" ]\n");
 			printf(".ad b\n");
@@ -2479,7 +2552,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, &cmd->optional_opt_args[oo].def, 1);
+				print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
 			}
 			printf(" ]\n");
 			printf(".ad b\n");
@@ -2507,7 +2580,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
 		for (op = 0; op < cmd->op_count; op++) {
 			if (cmd->optional_pos_args[op].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, &cmd->optional_pos_args[op].def, 1);
+				print_def_man(cname, 0, &cmd->optional_pos_args[op].def, 1);
 			}
 		}
 	}
@@ -2575,7 +2648,7 @@ void print_man_usage_common_lvm(struct command *cmd)
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, &cmd->optional_opt_args[oo].def, 1);
+				print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
 			}
 			printf(" ]\n");
 			printf(".ad b\n");
@@ -2610,7 +2683,7 @@ void print_man_usage_common_lvm(struct command *cmd)
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, &cmd->optional_opt_args[oo].def, 1);
+				print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
 			}
 			printf(" ]\n");
 			printf(".ad b\n");
@@ -2672,7 +2745,7 @@ void print_man_usage_common_cmd(struct command *cmd)
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, &cmd->optional_opt_args[oo].def, 1);
+				print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
 			}
 			printf(" ]\n");
 			printf(".ad b\n");
@@ -2714,7 +2787,7 @@ void print_man_usage_common_cmd(struct command *cmd)
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, &cmd->optional_opt_args[oo].def, 1);
+				print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
 			}
 			printf(" ]\n");
 			printf(".ad b\n");
@@ -2849,7 +2922,7 @@ void print_man_all_options_list(struct command_name *cname)
 			printf("\\fP");
 		} else {
 			printf(" ");
-			print_val_man(cname, val_enum);
+			print_val_man(cname, opt_enum, val_enum);
 		}
 
 		printf("\n.ad b\n");
@@ -2897,7 +2970,7 @@ void print_man_all_options_desc(struct command_name *cname)
 			printf("\\fP");
 		} else {
 			printf(" ");
-			print_val_man(cname, val_enum);
+			print_val_man(cname, opt_enum, val_enum);
 		}
 
 		if (opt_names[opt_enum].flags & ARG_COUNTABLE)
@@ -3382,6 +3455,9 @@ int main(int argc, char *argv[])
 
 	define_commands(NULL);
 
+	if (cmdname)
+		configure_command_option_values(cmdname);
+
 	factor_common_options();
 
 	if (primary)
diff --git a/tools/command.h b/tools/command.h
index 891349a..668428f 100644
--- a/tools/command.h
+++ b/tools/command.h
@@ -17,6 +17,7 @@
 #define _LVM_COMMAND_H
 
 struct cmd_context;
+struct logical_volume;
 
 /* old per-command-name function */
 typedef int (*command_fn) (struct cmd_context *cmd, int argc, char **argv);
@@ -262,5 +263,6 @@ void print_usage_common_lvm(struct command_name *cname, struct command *cmd);
 void print_usage_notes(struct command_name *cname);
 void factor_common_options(void);
 int command_has_alternate_extents(const char *name);
+void configure_command_option_values(const char *name);
 
 #endif
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index f46e283..9bc7f60 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -633,8 +633,8 @@ int size_mb_arg(struct cmd_context *cmd, struct arg_values *av)
 	if (!_size_arg(cmd, av, 2048, 0))
 		return 0;
 
-	if (av->sign == SIGN_MINUS) {
-		log_error("Size may not be negative.");
+	if ((av->sign == SIGN_MINUS) || (av->sign == SIGN_PLUS)) {
+		log_error("Size may not be relative/signed.");
 		return 0;
 	}
 
@@ -646,6 +646,32 @@ int ssize_mb_arg(struct cmd_context *cmd, struct arg_values *av)
 	return _size_arg(cmd, av, 2048, 0);
 }
 
+int psize_mb_arg(struct cmd_context *cmd, struct arg_values *av)
+{
+	if (!_size_arg(cmd, av, 2048, 0))
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
+int nsize_mb_arg(struct cmd_context *cmd, struct arg_values *av)
+{
+	if (!_size_arg(cmd, av, 2048, 0))
+		return 0;
+
+	if (av->sign == SIGN_PLUS) {
+		log_error("Size may not be positive.");
+		return 0;
+	}
+
+	return 1;
+}
+
 int int_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
 {
 	char *ptr;
@@ -674,8 +700,8 @@ int int_arg_with_sign(struct cmd_context *cmd __attribute__((unused)), struct ar
 	return 1;
 }
 
-int extents_arg(struct cmd_context *cmd __attribute__((unused)),
-		struct arg_values *av)
+static int _extents_arg(struct cmd_context *cmd __attribute__((unused)),
+		        struct arg_values *av)
 {
 	char *ptr;
 
@@ -699,6 +725,54 @@ int extents_arg(struct cmd_context *cmd __attribute__((unused)),
 	return 1;
 }
 
+int extents_arg(struct cmd_context *cmd __attribute__((unused)),
+		struct arg_values *av)
+{
+	if (!_extents_arg(cmd, av))
+		return 0;
+
+	if ((av->sign == SIGN_MINUS) || (av->sign == SIGN_PLUS)) {
+		log_error("Extents may not be relative/signed.");
+		return 0;
+	}
+
+	return 1;
+}
+
+int sextents_arg(struct cmd_context *cmd __attribute__((unused)),
+		 struct arg_values *av)
+{
+	return _extents_arg(cmd, av);
+}
+
+int pextents_arg(struct cmd_context *cmd __attribute__((unused)),
+		 struct arg_values *av)
+{
+	if (!_extents_arg(cmd, av))
+		return 0;
+
+	if (av->sign == SIGN_MINUS) {
+		log_error("Extents may not be negative.");
+		return 0;
+	}
+
+	return 1;
+}
+
+int nextents_arg(struct cmd_context *cmd __attribute__((unused)),
+		 struct arg_values *av)
+{
+	if (!_extents_arg(cmd, av))
+		return 0;
+
+	if (av->sign == SIGN_PLUS) {
+		log_error("Extents may not be positive.");
+		return 0;
+	}
+
+	return 1;
+}
+
 int string_arg(struct cmd_context *cmd __attribute__((unused)),
 	       struct arg_values *av __attribute__((unused)))
 {
@@ -1686,6 +1760,8 @@ static int _usage(const char *name, int longhelp, int skip_notes)
 		return 0;
 	}
 
+	configure_command_option_values(name);
+
 	/*
 	 * Looks at all variants of each command name and figures out
 	 * which options are common to all variants (for compact output)
@@ -2516,6 +2592,8 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 
 	cmd->name = dm_pool_strdup(cmd->mem, argv[0]);
 
+	configure_command_option_values(cmd->name);
+
 	/* eliminate '-' from all options starting with -- */
 	for (i = 1; i < argc; i++) {
 
diff --git a/tools/tools.h b/tools/tools.h
index fe3699e..630349a 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -151,10 +151,15 @@ int size_kb_arg(struct cmd_context *cmd, struct arg_values *av);
 int ssize_kb_arg(struct cmd_context *cmd, struct arg_values *av);
 int size_mb_arg(struct cmd_context *cmd, struct arg_values *av);
 int ssize_mb_arg(struct cmd_context *cmd, struct arg_values *av);
+int psize_mb_arg(struct cmd_context *cmd, struct arg_values *av);
+int nsize_mb_arg(struct cmd_context *cmd, struct arg_values *av);
 int int_arg(struct cmd_context *cmd, struct arg_values *av);
 int uint32_arg(struct cmd_context *cmd, struct arg_values *av);
 int int_arg_with_sign(struct cmd_context *cmd, struct arg_values *av);
 int extents_arg(struct cmd_context *cmd, struct arg_values *av);
+int sextents_arg(struct cmd_context *cmd, struct arg_values *av);
+int pextents_arg(struct cmd_context *cmd, struct arg_values *av);
+int nextents_arg(struct cmd_context *cmd, struct arg_values *av);
 int major_arg(struct cmd_context *cmd, struct arg_values *av);
 int minor_arg(struct cmd_context *cmd, struct arg_values *av);
 int string_arg(struct cmd_context *cmd, struct arg_values *av);
diff --git a/tools/vals.h b/tools/vals.h
index 4c70640..ef97ecb 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -92,10 +92,6 @@
  * --size and other option args treat upper/lower letters
  * the same, all as 1024 SI base.  For this reason, we
  * should avoid suggesting the upper case letters.
- *
- * FIXME: negative numbers should be automatically rejected
- * for anything but int_arg_with_sign(), e.g.
- * size_mb_arg() should reject a negative number.
  */
 
 val(none_VAL, NULL, "None", "ERR")             /* unused, for enum value 0 */
@@ -116,12 +112,17 @@ val(cachemode_VAL, cachemode_arg, "CacheMode", "writethrough|writeback|passthrou
 val(discards_VAL, discards_arg, "Discards", "passdown|nopassdown|ignore")
 val(mirrorlog_VAL, mirrorlog_arg, "MirrorLog", "core|disk")
 val(sizekb_VAL, size_kb_arg, "SizeKB", "Size[k|UNIT]")
-val(sizemb_VAL, size_mb_arg, "SizeMB", "Size[m|UNIT]")
 val(ssizekb_VAL, ssize_kb_arg, "SSizeKB", "[+|-]Size[k|UNIT]")
+val(sizemb_VAL, size_mb_arg, "SizeMB", "Size[m|UNIT]")
 val(ssizemb_VAL, ssize_mb_arg, "SSizeMB", "[+|-]Size[m|UNIT]")
+val(psizemb_VAL, psize_mb_arg, "PSizeMB", "[+]Size[m|UNIT]")
+val(nsizemb_VAL, nsize_mb_arg, "NSizeMB", "[-]Size[m|UNIT]")
 val(regionsize_VAL, regionsize_arg, "RegionSize", "Size[m|UNIT]")
 val(snumber_VAL, int_arg_with_sign, "SNumber", "[+|-]Number")
-val(extents_VAL, extents_arg, "Extents", "[+|-]Number[PERCENT]")
+val(extents_VAL, extents_arg, "Extents", "Number[PERCENT]")
+val(sextents_VAL, sextents_arg, "SExtents", "[+|-]Number[PERCENT]")
+val(pextents_VAL, pextents_arg, "PExtents", "[+]Number[PERCENT]")
+val(nextents_VAL, nextents_arg, "NExtents", "[-]Number[PERCENT]")
 val(permission_VAL, permission_arg, "Permission", "rw|r")
 val(metadatatype_VAL, metadatatype_arg, "MetadataType", "lvm2|lvm1")
 val(units_VAL, string_arg, "Units", "r|R|h|H|b|B|s|S|k|K|m|M|g|G|t|T|p|P|e|E")


