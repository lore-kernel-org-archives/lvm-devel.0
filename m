From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:37:25 -0500
Subject: master - cache: allow to specify cachemetadataformat
Message-ID: <201703101837.v2AIbPc0019932@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7b748b7cb88fc3a197df4453305173b4269c24c0
Commit:        7b748b7cb88fc3a197df4453305173b4269c24c0
Parent:        0a9b52f7a4f6dfbf23295ad694e4ff6b9a420cc3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 3 11:33:10 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:01 2017 +0100

cache: allow to specify  cachemetadataformat

OO_LVCREATE_CACHE accepts --cachemetadataformat.

Support new option --cachemetadataformat auto|1|2 for caching.
Word 'auto' can be also be given as '0'.
---
 tools/args.h           |    3 +++
 tools/command-lines.in |    5 +++--
 tools/command.c        |    1 +
 tools/lvmcmdline.c     |   19 +++++++++++++++++++
 tools/tools.h          |    1 +
 tools/vals.h           |    1 +
 6 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index a9ffe5b..26d7617 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -102,6 +102,9 @@ arg(cache_long_ARG, '\0', "cache", 0, 0, 0,
     "#lvscan\n"
     "Scan the devices used by an LV and send the metadata to lvmetad.\n")
 
+arg(cachemetadataformat_ARG, '\0', "cachemetadataformat", cachemetadataformat_VAL, 0, 0,
+    "Specifies the cache metadata format used by cache target.\n")
+
 arg(cachemode_ARG, '\0', "cachemode", cachemode_VAL, 0, 0,
     "Specifies when writes to a cache LV should be considered complete.\n"
     "\\fBwriteback\\fP considers a write complete as soon as it is\n"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 98d5721..f87bf23 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -311,7 +311,8 @@ OO_LVCONVERT_POOL: --poolmetadata LV, --poolmetadatasize SizeMB,
 --poolmetadataspare Bool, --readahead Readahead, --chunksize SizeKB,
 --zero Bool, --metadataprofile String
 
-OO_LVCONVERT_CACHE: --cachemode CacheMode, --cachepolicy String,
+OO_LVCONVERT_CACHE: --cachemetadataformat CacheMetadataFormat,
+--cachemode CacheMode, --cachepolicy String,
 --cachesettings String, --zero Bool
 
 OO_LVCONVERT: --alloc Alloc, --background, --force, --noudevsync
@@ -702,7 +703,7 @@ OO_LVCREATE: --addtag Tag, --alloc Alloc, --autobackup Bool, --activate Active,
 --zero Bool
 
 OO_LVCREATE_CACHE: --cachemode CacheMode, --cachepolicy String, --cachesettings String,
---chunksize SizeKB
+--chunksize SizeKB, --cachemetadataformat CacheMetadataFormat
 
 OO_LVCREATE_POOL: --poolmetadatasize SizeMB, --poolmetadataspare Bool, --chunksize SizeKB
 
diff --git a/tools/command.c b/tools/command.c
index 9594284..8d3c353 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -70,6 +70,7 @@ struct arg_values;
 /* needed to include args.h */
 static inline int yes_no_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int activation_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+static inline int cachemetadataformat_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int cachemode_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int discards_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int mirrorlog_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 9bc7f60..05b659d 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -421,6 +421,25 @@ int cachemode_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_va
 	return 1;
 }
 
+int cachemetadataformat_arg(struct cmd_context *cmd, struct arg_values *av)
+{
+	if (!strcmp(av->value, "auto")) {
+		av->i_value = CACHE_METADATA_FORMAT_UNSELECTED;
+		av->ui_value = CACHE_METADATA_FORMAT_UNSELECTED;
+	} else if (!int_arg(cmd, av))
+		return_0;
+
+	switch (av->i_value) {
+	case CACHE_METADATA_FORMAT_UNSELECTED:
+	case CACHE_METADATA_FORMAT_1:
+	case CACHE_METADATA_FORMAT_2:
+		return 1;
+	}
+
+	log_error("Selected cache metadata format %d is not supported.", av->i_value);
+	return 0;
+}
+
 int discards_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
 {
 	thin_discards_t discards;
diff --git a/tools/tools.h b/tools/tools.h
index 630349a..3bf20ef 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -144,6 +144,7 @@ void usage(const char *name);
 /* the argument verify/normalise functions */
 int yes_no_arg(struct cmd_context *cmd, struct arg_values *av);
 int activation_arg(struct cmd_context *cmd, struct arg_values *av);
+int cachemetadataformat_arg(struct cmd_context *cmd, struct arg_values *av);
 int cachemode_arg(struct cmd_context *cmd, struct arg_values *av);
 int discards_arg(struct cmd_context *cmd, struct arg_values *av);
 int mirrorlog_arg(struct cmd_context *cmd, struct arg_values *av);
diff --git a/tools/vals.h b/tools/vals.h
index ef97ecb..8fa42ae 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -108,6 +108,7 @@ val(tag_VAL, tag_arg, "Tag", NULL)
 val(select_VAL, NULL, "Select", NULL)       /* used only for command defs */
 val(activationmode_VAL, string_arg, "ActivationMode", "partial|degraded|complete")
 val(activation_VAL, activation_arg, "Active", "y|n|ay")
+val(cachemetadataformat_VAL, cachemetadataformat_arg, "CacheMetadataFormat", "auto|1|2")
 val(cachemode_VAL, cachemode_arg, "CacheMode", "writethrough|writeback|passthrough")
 val(discards_VAL, discards_arg, "Discards", "passdown|nopassdown|ignore")
 val(mirrorlog_VAL, mirrorlog_arg, "MirrorLog", "core|disk")


