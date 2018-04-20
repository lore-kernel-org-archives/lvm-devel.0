From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:02:34 -0400
Subject: master - cleanup: add _mb_ to regiosize option
Message-ID: <201804201102.w3KB2Ysn031368@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7323557379d9dc40e68203a467e8ec541e512789
Commit:        7323557379d9dc40e68203a467e8ec541e512789
Parent:        e878c3fc32161048e76c2b8e6a33d84f6852cdd4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 18 12:56:32 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:17:01 2018 +0200

cleanup: add _mb_ to regiosize option

Just like with others mentions default unit in function name.
---
 lib/metadata/metadata-exported.h |    2 +-
 tools/args.h                     |    2 +-
 tools/command.c                  |    4 ++--
 tools/lvmcmdline.c               |    2 +-
 tools/tools.h                    |    2 +-
 tools/vals.h                     |    2 +-
 6 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index cd7ff8a..2bc7927 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -449,7 +449,7 @@ struct lv_segment {
 	struct logical_volume *merge_lv; /* thin, merge descendent lv into this ancestor */
 	struct logical_volume *cow;
 	struct dm_list origin_list;
-	uint32_t region_size;	/* For mirrors, replicators - in sectors */
+	uint32_t region_size;	/* For raids/mirrors - in sectors */
 	uint32_t data_copies;	/* For RAID: number of data copies (e.g. 3 for RAID 6 */
 	uint32_t extents_copied;/* Number of extents synced for raids/mirrors */
 	struct logical_volume *log_lv;
diff --git a/tools/args.h b/tools/args.h
index 89d84b4..b80b8da 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -1295,7 +1295,7 @@ arg(resizefs_ARG, 'r', "resizefs", 0, 0, 0,
 /* Not used */
 arg(reset_ARG, 'R', "reset", 0, 0, 0, NULL)
 
-arg(regionsize_ARG, 'R', "regionsize", regionsize_VAL, 0, 0,
+arg(regionsize_ARG, 'R', "regionsize", regionsizemb_VAL, 0, 0,
     "Size of each raid or mirror synchronization region.\n"
     "lvm.conf activation/raid_region_size can be used to\n"
     "configure a default.\n")
diff --git a/tools/command.c b/tools/command.c
index fafbaa9..a40b327 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -115,7 +115,7 @@ static inline int segtype_arg(struct cmd_context *cmd, struct arg_values *av) {
 static inline int alloc_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int locktype_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int readahead_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
-static inline int regionsize_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+static inline int regionsize_mb_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int vgmetadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
 static inline int pvmetadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
 static inline int metadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
@@ -2264,7 +2264,7 @@ static void _print_val_man(struct command_name *cname, int opt_enum, int val_enu
 		return;
 	}
 
-	if (val_enum == regionsize_VAL) {
+	if (val_enum == regionsizemb_VAL) {
 		printf("\\fISize\\fP[m|UNIT]");
 		return;
 	}
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 6be4bcd..26510bc 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -929,7 +929,7 @@ int readahead_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_va
 	return 1;
 }
 
-int regionsize_arg(struct cmd_context *cmd, struct arg_values *av)
+int regionsize_mb_arg(struct cmd_context *cmd, struct arg_values *av)
 {
 	int pagesize = lvm_getpagesize();
 	uint32_t num;
diff --git a/tools/tools.h b/tools/tools.h
index dc29e4b..33cbf10 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -174,7 +174,7 @@ int segtype_arg(struct cmd_context *cmd, struct arg_values *av);
 int alloc_arg(struct cmd_context *cmd, struct arg_values *av);
 int locktype_arg(struct cmd_context *cmd, struct arg_values *av);
 int readahead_arg(struct cmd_context *cmd, struct arg_values *av);
-int regionsize_arg(struct cmd_context *cmd, struct arg_values *av);
+int regionsize_mb_arg(struct cmd_context *cmd, struct arg_values *av);
 int vgmetadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
 int pvmetadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
 int metadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
diff --git a/tools/vals.h b/tools/vals.h
index 614a909..95dc8b2 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -120,7 +120,7 @@ val(sizemb_VAL, size_mb_arg, "SizeMB", "Size[m|UNIT]")
 val(ssizemb_VAL, ssize_mb_arg, "SSizeMB", "[+|-]Size[m|UNIT]")
 val(psizemb_VAL, psize_mb_arg, "PSizeMB", "[+]Size[m|UNIT]")
 val(nsizemb_VAL, nsize_mb_arg, "NSizeMB", "[-]Size[m|UNIT]")
-val(regionsize_VAL, regionsize_arg, "RegionSize", "Size[m|UNIT]")
+val(regionsizemb_VAL, regionsize_mb_arg, "RegionSize", "Size[m|UNIT]")
 val(extents_VAL, extents_arg, "Extents", "Number[PERCENT]")
 val(sextents_VAL, sextents_arg, "SExtents", "[+|-]Number[PERCENT]")
 val(pextents_VAL, pextents_arg, "PExtents", "[+]Number[PERCENT]")


