From: David Teigland <teigland@sourceware.org>
Date: Fri, 10 Mar 2017 16:41:41 -0500
Subject: master - commands: use correct relative signs with mirror option
Message-ID: <201703102141.v2ALff0Z006546@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c8671f6f798ec2516887a0d4abdebefcad0ce0ee
Commit:        c8671f6f798ec2516887a0d4abdebefcad0ce0ee
Parent:        164d4a309ca62eb6e7810b76e5616074656258e3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 10 15:22:13 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Mar 10 15:41:29 2017 -0600

commands: use correct relative signs with mirror option

As was recently done with relative signes for sizes/extents,
limit the signs used with the mirrors option, e.g.
lvcreate --mirrors now does not accept or advertise an
optional minus sign with the value.  lvconvert --mirrors
accepts +|-.
---
 tools/args.h           |    2 +-
 tools/command-lines.in |   14 +++++++-------
 tools/command.c        |   28 +++++++++++++++++++++++++---
 tools/lvmcmdline.c     |   15 +++++++++++++++
 tools/tools.h          |    1 +
 tools/vals.h           |    3 ++-
 6 files changed, 51 insertions(+), 12 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 26d7617..fd0ad0c 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -1121,7 +1121,7 @@ arg(maps_ARG, 'm', "maps", 0, 0, 0,
 
 /* FIXME: should the unused mirrors option be removed from lvextend? */
 
-arg(mirrors_ARG, 'm', "mirrors", snumber_VAL, 0, 0,
+arg(mirrors_ARG, 'm', "mirrors", number_VAL, 0, 0,
     "#lvcreate\n"
     "Specifies the number of mirror images in addition to the original LV\n"
     "image, e.g. --mirrors 1 means there are two images of the data, the\n"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 9651053..e4e956c 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -706,7 +706,7 @@ OO_LVCREATE_POOL: --poolmetadatasize SizeMB, --poolmetadataspare Bool, --chunksi
 
 OO_LVCREATE_THIN: --discards Discards, --errorwhenfull Bool
 
-OO_LVCREATE_RAID: --mirrors SNumber, --stripes Number, --stripesize SizeKB,
+OO_LVCREATE_RAID: --mirrors PNumber, --stripes Number, --stripesize SizeKB,
 --regionsize RegionSize, --minrecoveryrate SizeKB, --maxrecoveryrate SizeKB
 
 ---
@@ -760,14 +760,14 @@ DESC: Create a striped LV (infers --type striped).
 ---
 
 lvcreate --type mirror --size SizeMB VG
-OO: --mirrors SNumber, --mirrorlog MirrorLog, --regionsize RegionSize, --stripes Number, OO_LVCREATE
+OO: --mirrors PNumber, --mirrorlog MirrorLog, --regionsize RegionSize, --stripes Number, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_mirror
 DESC: Create a mirror LV (also see --type raid1).
 FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type raid1|mirror
-lvcreate --mirrors SNumber --size SizeMB VG
+lvcreate --mirrors PNumber --size SizeMB VG
 OO: --type raid1, --type mirror, --mirrorlog MirrorLog, --stripes Number, OO_LVCREATE_RAID, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_mirror_or_raid1
@@ -1146,7 +1146,7 @@ ID: lvdisplay_general
 # --extents is not specified; it's an automatic alternative for --size
 
 lvextend --size PSizeMB LV
-OO: --alloc Alloc, --autobackup Bool, --force, --mirrors SNumber,
+OO: --alloc Alloc, --autobackup Bool, --force, --mirrors Number,
 --nofsck, --nosync, --noudevsync, --reportformat ReportFmt, --resizefs,
 --stripes Number, --stripesize SizeKB, --poolmetadatasize PSizeMB,
 --type SegType
@@ -1155,7 +1155,7 @@ ID: lvextend_by_size
 DESC: Extend an LV by a specified size.
 
 lvextend LV PV ...
-OO: --alloc Alloc, --autobackup Bool, --force, --mirrors SNumber,
+OO: --alloc Alloc, --autobackup Bool, --force, --mirrors Number,
 --nofsck, --nosync, --noudevsync,
 --reportformat ReportFmt, --resizefs, --stripes Number, --stripesize SizeKB,
 --type SegType
@@ -1163,7 +1163,7 @@ ID: lvextend_by_pv
 DESC: Extend an LV by specified PV extents.
 
 lvextend --poolmetadatasize PSizeMB LV_thinpool
-OO: --alloc Alloc, --autobackup Bool, --force, --mirrors SNumber,
+OO: --alloc Alloc, --autobackup Bool, --force, --mirrors Number,
 --nofsck, --nosync, --noudevsync,
 --reportformat ReportFmt, --stripes Number, --stripesize SizeKB,
 --type SegType
@@ -1172,7 +1172,7 @@ ID: lvextend_pool_metadata_by_size
 DESC: Extend a pool metadata SubLV by a specified size.
 
 lvextend --usepolicies LV_thinpool_snapshot
-OO: --alloc Alloc, --autobackup Bool, --force, --mirrors SNumber,
+OO: --alloc Alloc, --autobackup Bool, --force, --mirrors Number,
 --nofsck, --nosync, --noudevsync,
 --reportformat ReportFmt, --resizefs,
 --type SegType
diff --git a/tools/command.c b/tools/command.c
index 8d3c353..9f6b078 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -83,6 +83,7 @@ static inline int nsize_mb_arg(struct cmd_context *cmd, struct arg_values *av) {
 static inline int int_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int uint32_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int int_arg_with_sign(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+static inline int int_arg_with_plus(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int extents_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int sextents_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int pextents_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
@@ -1559,6 +1560,11 @@ void configure_command_option_values(const char *name)
 		return;
 	}
 
+	if (!strcmp(name, "lvconvert")) {
+		opt_names[mirrors_ARG].val_enum = snumber_VAL;
+		return;
+	}
+
 	if (!strcmp(name, "lvcreate")) {
 		/*
 		 * lvcreate is a bit of a mess because it has previously
@@ -1572,6 +1578,7 @@ void configure_command_option_values(const char *name)
 		opt_names[size_ARG].val_enum = psizemb_VAL;
 		opt_names[extents_ARG].val_enum = pextents_VAL;
 		opt_names[poolmetadatasize_ARG].val_enum = psizemb_VAL;
+		opt_names[mirrors_ARG].val_enum = pnumber_VAL;
 		return;
 	}
 }
@@ -1622,7 +1629,8 @@ static void print_val_usage(struct command *cmd, int opt_enum, int val_enum)
 {
 	int is_relative_opt = (opt_enum == size_ARG) ||
 			      (opt_enum == extents_ARG) ||
-			      (opt_enum == poolmetadatasize_ARG);
+			      (opt_enum == poolmetadatasize_ARG) ||
+			      (opt_enum == mirrors_ARG);
 
 	/*
 	 * Suppress the [+] prefix for lvcreate which we have to
@@ -1633,6 +1641,8 @@ static void print_val_usage(struct command *cmd, int opt_enum, int val_enum)
 			val_enum = sizemb_VAL;
 		else if (val_enum == pextents_VAL)
 			val_enum = extents_VAL;
+		else if ((val_enum == pnumber_VAL) && (opt_enum == mirrors_ARG))
+			val_enum = number_VAL;
 	}
 
 	if (!val_names[val_enum].usage)
@@ -2056,14 +2066,15 @@ void print_usage_notes(struct command_name *cname)
  */
 static void print_val_man(struct command_name *cname, int opt_enum, int val_enum)
 {
-	const char *str = val_names[val_enum].usage;
+	const char *str;
 	char *line;
 	char *line_argv[MAX_LINE_ARGC];
 	int line_argc;
 	int i;
 	int is_relative_opt = (opt_enum == size_ARG) ||
 			      (opt_enum == extents_ARG) ||
-			      (opt_enum == poolmetadatasize_ARG);
+			      (opt_enum == poolmetadatasize_ARG) ||
+			      (opt_enum == mirrors_ARG);
 
 	/*
 	 * Suppress the [+] prefix for lvcreate which we have to
@@ -2074,6 +2085,8 @@ static void print_val_man(struct command_name *cname, int opt_enum, int val_enum
 			val_enum = sizemb_VAL;
 		else if (val_enum == pextents_VAL)
 			val_enum = extents_VAL;
+		else if ((val_enum == pnumber_VAL) && (opt_enum == mirrors_ARG))
+			val_enum = number_VAL;
 	}
 
 	if (val_enum == sizemb_VAL) {
@@ -2136,6 +2149,15 @@ static void print_val_man(struct command_name *cname, int opt_enum, int val_enum
 		return;
 	}
 
+	if (val_enum == pnumber_VAL) {
+		printf("[\\fB+\\fP]\\fINumber\\fP");
+		return;
+	}
+
+	str = val_names[val_enum].usage;
+	if (!str)
+		str = val_names[val_enum].name;
+
 	if (!strcmp(str, "PV[:t|n|y]")) {
 		printf("\\fIPV\\fP[\\fB:t\\fP|\\fBn\\fP|\\fBy\\fP]");
 		return;
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 05b659d..d1399c9 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -719,6 +719,21 @@ int int_arg_with_sign(struct cmd_context *cmd __attribute__((unused)), struct ar
 	return 1;
 }
 
+int int_arg_with_plus(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
+{
+	char *ptr;
+
+	if (!_get_int_arg(av, &ptr) || (*ptr))
+		return 0;
+
+	if (av->sign == SIGN_MINUS) {
+		log_error("Number may not be negative.");
+		return 0;
+	}
+
+	return 1;
+}
+
 static int _extents_arg(struct cmd_context *cmd __attribute__((unused)),
 		        struct arg_values *av)
 {
diff --git a/tools/tools.h b/tools/tools.h
index 3bf20ef..10d7450 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -157,6 +157,7 @@ int nsize_mb_arg(struct cmd_context *cmd, struct arg_values *av);
 int int_arg(struct cmd_context *cmd, struct arg_values *av);
 int uint32_arg(struct cmd_context *cmd, struct arg_values *av);
 int int_arg_with_sign(struct cmd_context *cmd, struct arg_values *av);
+int int_arg_with_plus(struct cmd_context *cmd, struct arg_values *av);
 int extents_arg(struct cmd_context *cmd, struct arg_values *av);
 int sextents_arg(struct cmd_context *cmd, struct arg_values *av);
 int pextents_arg(struct cmd_context *cmd, struct arg_values *av);
diff --git a/tools/vals.h b/tools/vals.h
index 8fa42ae..614a909 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -99,6 +99,8 @@ val(conststr_VAL, NULL, "ConstString", "ERR")  /* used only for command defs */
 val(constnum_VAL, NULL, "ConstNumber", "ERR")  /* used only for command defs */
 val(bool_VAL, yes_no_arg, "Bool", "y|n")
 val(number_VAL, int_arg, "Number", NULL)
+val(snumber_VAL, int_arg_with_sign, "SNumber", "[+|-]Number")
+val(pnumber_VAL, int_arg_with_plus, "PNumber", "[+]Number")
 val(uint32_VAL, uint32_arg, "Uint32", "Number")
 val(string_VAL, string_arg, "String", NULL)
 val(vg_VAL, string_arg, "VG", NULL)
@@ -119,7 +121,6 @@ val(ssizemb_VAL, ssize_mb_arg, "SSizeMB", "[+|-]Size[m|UNIT]")
 val(psizemb_VAL, psize_mb_arg, "PSizeMB", "[+]Size[m|UNIT]")
 val(nsizemb_VAL, nsize_mb_arg, "NSizeMB", "[-]Size[m|UNIT]")
 val(regionsize_VAL, regionsize_arg, "RegionSize", "Size[m|UNIT]")
-val(snumber_VAL, int_arg_with_sign, "SNumber", "[+|-]Number")
 val(extents_VAL, extents_arg, "Extents", "Number[PERCENT]")
 val(sextents_VAL, sextents_arg, "SExtents", "[+|-]Number[PERCENT]")
 val(pextents_VAL, pextents_arg, "PExtents", "[+]Number[PERCENT]")


