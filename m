From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:11:00 +0000 (UTC)
Subject: master - args: use arg parsing function for region size
Message-ID: <20170213181100.87E9F60CD7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=13a6368522894e9d32544d8fb3d6360bbe9018d1
Commit:        13a6368522894e9d32544d8fb3d6360bbe9018d1
Parent:        a1386dcca024b51019c1f3be6b153249df06dbac
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 7 15:12:24 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:21:58 2017 -0600

args: use arg parsing function for region size

Consolidate the validation of the region size arg
in a new arg parsing function.
---
 lib/config/config_settings.h |    9 ++++---
 lib/metadata/lv_manip.c      |    7 ++++++
 tools/args.h                 |    6 +---
 tools/command-lines.in       |    8 +++---
 tools/command.c              |    1 +
 tools/lvconvert.c            |   43 ++---------------------------------------
 tools/lvcreate.c             |   14 -------------
 tools/lvmcmdline.c           |   39 ++++++++++++++++++++++++++++++++++++++
 tools/tools.h                |    1 +
 tools/vals.h                 |    5 ++++
 10 files changed, 67 insertions(+), 66 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 1d9603f..2b76526 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1221,14 +1221,15 @@ cfg_array(activation_read_only_volume_list_CFG, "read_only_volume_list", activat
 	"read_only_volume_list = [ \"vg1\", \"vg2/lvol1\", \"@tag1\", \"@*\" ]\n"
 	"#\n")
 
-cfg(activation_mirror_region_size_CFG, "mirror_region_size", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RAID_REGION_SIZE, vsn(1, 0, 0), NULL, vsn(2, 2, 99),
+ cfg(activation_mirror_region_size_CFG, "mirror_region_size", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RAID_REGION_SIZE, vsn(1, 0, 0), NULL, vsn(2, 2, 99),
 	"This has been replaced by the activation/raid_region_size setting.\n",
-        "Size in KiB of each copy operation when mirroring.\n")
+	"Size in KiB of each raid or mirror synchronization region.\n")
 
 cfg(activation_raid_region_size_CFG, "raid_region_size", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RAID_REGION_SIZE, vsn(2, 2, 99), NULL, 0, NULL,
 	"Size in KiB of each raid or mirror synchronization region.\n"
-	"For raid or mirror segment types, this is the amount of data that is\n"
-	"copied at once when initializing, or moved at once by pvmove.\n")
+	"The clean/dirty state of data is tracked for each region.\n"
+	"The value is rounded down to a power of two if necessary, and\n"
+	"is ignored if it is not a multiple of the machine memory page size.\n")
 
 cfg(activation_error_when_full_CFG, "error_when_full", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_ERROR_WHEN_FULL, vsn(2, 2, 115), NULL, 0, NULL,
 	"Return errors if a thin pool runs out of space.\n"
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index bc599de..d8f869d 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -712,6 +712,7 @@ static int _round_down_pow2(int r)
 
 int get_default_region_size(struct cmd_context *cmd)
 {
+	int pagesize = lvm_getpagesize();
 	int region_size = _get_default_region_size(cmd);
 
 	if (!is_power_of_2(region_size)) {
@@ -720,6 +721,12 @@ int get_default_region_size(struct cmd_context *cmd)
 			    region_size / 2);
 	}
 
+	if (region_size % (pagesize >> SECTOR_SHIFT)) {
+		region_size = DEFAULT_RAID_REGION_SIZE * 2;
+		log_verbose("Using default region size %u kiB (multiple of page size).",
+			    region_size / 2);
+	}
+
 	return region_size;
 }
 
diff --git a/tools/args.h b/tools/args.h
index a481bc5..b33df9a 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -1212,10 +1212,8 @@ arg(resizefs_ARG, 'r', "resizefs", 0, 0, 0,
 /* Not used */
 arg(reset_ARG, 'R', "reset", 0, 0, 0, NULL)
 
-arg(regionsize_ARG, 'R', "regionsize", sizemb_VAL, 0, 0,
-    "A mirror is divided into regions of this size, and the mirror log\n"
-    "uses this granularity to track which regions are in sync.\n"
-    "(This can be used with the \"mirror\" type, not the \"raid1\" type.)\n")
+arg(regionsize_ARG, 'R', "regionsize", regionsize_VAL, 0, 0,
+    "Size of each raid or mirror synchronization region.\n")
 
 arg(physicalextentsize_ARG, 's', "physicalextentsize", sizemb_VAL, 0, 0,
     "#vgcreate\n"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 6743b79..1a9a796 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -317,7 +317,7 @@ RULE: all not LV_thinpool LV_cachepool
 ---
 
 OO_LVCONVERT_RAID: --mirrors SNumber, --stripes_long Number,
---stripesize SizeKB, --regionsize SizeMB, --interval Number
+--stripesize SizeKB, --regionsize RegionSize, --interval Number
 
 OO_LVCONVERT_POOL: --poolmetadata LV, --poolmetadatasize SizeMB,
 --poolmetadataspare Bool, --readahead Readahead, --chunksize SizeKB
@@ -364,7 +364,7 @@ ID: lvconvert_raid_types
 DESC: Convert LV to raid1 or mirror, or change number of mirror images.
 RULE: all not lv_is_locked lv_is_pvmove
 
-lvconvert --regionsize SizeMB LV_raid
+lvconvert --regionsize RegionSize LV_raid
 OO: OO_LVCONVERT
 ID: lvconvert_change_region_size
 DESC: Change the region size of an LV.
@@ -655,7 +655,7 @@ OO_LVCREATE_POOL: --poolmetadatasize SizeMB, --poolmetadataspare Bool, --chunksi
 OO_LVCREATE_THIN: --discards Discards, --errorwhenfull Bool
 
 OO_LVCREATE_RAID: --mirrors SNumber, --stripes Number, --stripesize SizeKB,
---regionsize SizeMB, --minrecoveryrate SizeKB, --maxrecoveryrate SizeKB
+--regionsize RegionSize, --minrecoveryrate SizeKB, --maxrecoveryrate SizeKB
 
 ---
 
@@ -712,7 +712,7 @@ DESC: Create a striped LV (infers --type striped).
 ---
 
 lvcreate --type mirror --size SizeMB VG
-OO: --mirrors SNumber, --mirrorlog MirrorLog, --regionsize SizeMB, --stripes Number, OO_LVCREATE
+OO: --mirrors SNumber, --mirrorlog MirrorLog, --regionsize RegionSize, --stripes Number, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_mirror
 DESC: Create a mirror LV (also see --type raid1).
diff --git a/tools/command.c b/tools/command.c
index 59c9ea0..68566fa 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -75,6 +75,7 @@ static inline int segtype_arg(struct cmd_context *cmd, struct arg_values *av) {
 static inline int alloc_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int locktype_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int readahead_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+static inline int regionsize_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int vgmetadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
 static inline int pvmetadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
 static inline int metadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4d6b1c9..502d614 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -146,8 +146,6 @@ static int _read_conversion_type(struct cmd_context *cmd,
 static int _read_params(struct cmd_context *cmd, struct lvconvert_params *lp)
 {
 	const char *vg_name = NULL;
-	int region_size;
-	int pagesize = lvm_getpagesize();
 
 	if (!_read_conversion_type(cmd, lp))
 		return_0;
@@ -249,45 +247,10 @@ static int _read_params(struct cmd_context *cmd, struct lvconvert_params *lp)
 				return 0;
 			}
 
-			/*
-			 * --regionsize is only valid if converting an LV into a mirror.
-			 * Checked when we know the state of the LV being converted.
-			 */
-			if (arg_is_set(cmd, regionsize_ARG)) {
-				if (arg_sign_value(cmd, regionsize_ARG, SIGN_NONE) ==
-					    SIGN_MINUS) {
-					log_error("Negative regionsize is invalid.");
-					return 0;
-				}
+			if (arg_is_set(cmd, regionsize_ARG))
 				lp->region_size = arg_uint_value(cmd, regionsize_ARG, 0);
-			} else {
-				region_size = get_default_region_size(cmd);
-				if (region_size < 0) {
-					log_error("Negative regionsize in "
-						  "configuration file is invalid.");
-					return 0;
-				}
-				lp->region_size = region_size;
-			}
-
-			if (lp->region_size % (pagesize >> SECTOR_SHIFT)) {
-				log_error("Region size (%" PRIu32 ") must be "
-					  "a multiple of machine memory "
-					  "page size (%d).",
-					  lp->region_size, pagesize >> SECTOR_SHIFT);
-				return 0;
-			}
-
-			if (!is_power_of_2(lp->region_size)) {
-				log_error("Region size (%" PRIu32
-					  ") must be a power of 2.", lp->region_size);
-				return 0;
-			}
-
-			if (!lp->region_size) {
-				log_error("Non-zero region size must be supplied.");
-				return 0;
-			}
+			else
+				lp->region_size = get_default_region_size(cmd);
 
 			/* FIXME man page says in one place that --type and --mirrors can't be mixed */
 			if (lp->mirrors_supplied && !lp->mirrors)
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 0512585..cd31c99 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -545,7 +545,6 @@ static int _read_raid_params(struct cmd_context *cmd,
 static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 					struct lvcreate_params *lp)
 {
-	int pagesize = lvm_getpagesize();
 	unsigned max_images;
 
 	if (seg_is_raid(lp)) {
@@ -616,19 +615,6 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!is_power_of_2(lp->region_size)) {
-		log_error("Region size (%" PRIu32 ") must be a power of 2",
-			  lp->region_size);
-		return 0;
-	}
-
-	if (lp->region_size % (pagesize >> SECTOR_SHIFT)) {
-		log_error("Region size (%" PRIu32 ") must be a multiple of "
-			  "machine memory page size (%d)",
-			  lp->region_size, pagesize >> SECTOR_SHIFT);
-		return 0;
-	}
-
 	if (seg_is_mirror(lp) && !_read_mirror_params(cmd, lp))
                 return_0;
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 4fda356..58d1a44 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -797,6 +797,45 @@ int readahead_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_va
 	return 1;
 }
 
+int regionsize_arg(struct cmd_context *cmd, struct arg_values *av)
+{
+	int pagesize = lvm_getpagesize();
+	uint32_t num;
+
+	if (!_size_arg(cmd, av, 2048, 0))
+		return 0;
+
+	if (av->sign == SIGN_MINUS) {
+		log_error("Region size may not be negative.");
+		return 0;
+	}
+
+	if (av->ui64_value > UINT32_MAX) {
+		log_error("Region size is too big (max %u).", UINT32_MAX);
+		return 0;
+	}
+
+	num = av->ui_value;
+
+	if (!num) {
+		log_error("Region size may not be zero.");
+		return 0;
+	}
+
+	if (num % (pagesize >> SECTOR_SHIFT)) {
+		log_error("Region size must be a multiple of machine memory page size (%d bytes).",
+			  pagesize);
+		return 0;
+	}
+
+	if (!is_power_of_2(num)) {
+		log_error("Region size must be a power of 2.");
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
index 00476d1..b3858a0 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -200,6 +200,7 @@ int segtype_arg(struct cmd_context *cmd, struct arg_values *av);
 int alloc_arg(struct cmd_context *cmd, struct arg_values *av);
 int locktype_arg(struct cmd_context *cmd, struct arg_values *av);
 int readahead_arg(struct cmd_context *cmd, struct arg_values *av);
+int regionsize_arg(struct cmd_context *cmd, struct arg_values *av);
 int vgmetadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
 int pvmetadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
 int metadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
diff --git a/tools/vals.h b/tools/vals.h
index 12d315f..38029aa 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -92,6 +92,10 @@
  * --size and other option args treat upper/lower letters
  * the same, all as 1024 SI base.  For this reason, we
  * should avoid suggesting the upper case letters.
+ *
+ * FIXME: negative numbers should be automatically rejected
+ * for anything but int_arg_with_sign(), e.g.
+ * size_mb_arg() should reject a negative number.
  */
 
 val(none_VAL, NULL, "None", "ERR")             /* unused, for enum value 0 */
@@ -113,6 +117,7 @@ val(discards_VAL, discards_arg, "Discards", "passdown|nopassdown|ignore")
 val(mirrorlog_VAL, mirrorlog_arg, "MirrorLog", "core|disk")
 val(sizekb_VAL, size_kb_arg, "SizeKB", "Number[k|unit]")
 val(sizemb_VAL, size_mb_arg, "SizeMB", "Number[m|unit]")
+val(regionsize_VAL, regionsize_arg, "RegionSize", "Number[m|unit]")
 val(numsigned_VAL, int_arg_with_sign, "SNumber", "[+|-]Number")
 val(numsignedper_VAL, int_arg_with_sign_and_percent, "SNumberP", "[+|-]Number[%VG|%PVS|%FREE]")
 val(permission_VAL, permission_arg, "Permission", "rw|r")


