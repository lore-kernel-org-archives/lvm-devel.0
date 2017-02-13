From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:24 +0000 (UTC)
Subject: master - args: use uint32 arg for maxphysicalvolumes
Message-ID: <20170213181024.7AEFE6039D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=db26a82f2f464d0f710229c24d67c83818fd8f3c
Commit:        db26a82f2f464d0f710229c24d67c83818fd8f3c
Parent:        041c2fef88ab2e546555625039a17ccbb7b1c9c5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 3 15:52:27 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

args: use uint32 arg for maxphysicalvolumes

---
 tools/args.h            |    2 +-
 tools/command-lines.in  |    6 +++---
 tools/create-commands.c |    1 +
 tools/vals.h            |    1 +
 4 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 559bf16..690b4ee 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -204,7 +204,7 @@ arg(novolumegroup_ARG, 'n', "novolumegroup", 0, 0, 0)
 arg(oldpath_ARG, 'n', "oldpath", 0, 0, 0)
 arg(options_ARG, 'o', "options", string_VAL, ARG_GROUPABLE, 0)
 arg(sort_ARG, 'O', "sort", string_VAL, ARG_GROUPABLE, 0)
-arg(maxphysicalvolumes_ARG, 'p', "maxphysicalvolumes", number_VAL, 0, 0)
+arg(maxphysicalvolumes_ARG, 'p', "maxphysicalvolumes", uint32_VAL, 0, 0)
 arg(permission_ARG, 'p', "permission", permission_VAL, 0, 0)
 arg(partial_ARG, 'P', "partial", 0, 0, 0)
 arg(physicalvolume_ARG, 'P', "physicalvolume", 0, 0, 0)
diff --git a/tools/command-lines.in b/tools/command-lines.in
index ebe7006..f99cb8c 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1335,7 +1335,7 @@ OO_VGCHANGE: --autobackup Bool, --ignoremonitoring, --ignoreskippedcluster,
 # because it can function as a required opt.
 
 OO_VGCHANGE_META: --addtag Tag, --deltag Tag,
---logicalvolume Number, --maxphysicalvolumes Number, --alloc Alloc, --uuid,
+--logicalvolume Number, --maxphysicalvolumes Uint32, --alloc Alloc, --uuid,
 --clustered Bool, --pvmetadatacopies MetadataCopiesPV, --vgmetadatacopies MetadataCopiesVG,
 --physicalextentsize SizeMB, --resizeable Bool, --systemid String, --locktype LockType,
 --profile String, --detachprofile, --metadataprofile String
@@ -1402,7 +1402,7 @@ ID: vgconvert_general
 
 vgcreate VG_new PV ...
 OO: --addtag Tag, --alloc Alloc, --autobackup Bool, --clustered Bool, --maxlogicalvolumes Number,
---maxphysicalvolumes Number, --metadataprofile String, --metadatatype MetadataType,
+--maxphysicalvolumes Uint32, --metadataprofile String, --metadatatype MetadataType,
 --physicalextentsize SizeMB, --force, --zero Bool, --labelsector Number,
 --metadatasize SizeMB, --pvmetadatacopies MetadataCopiesPV, --vgmetadatacopies MetadataCopiesVG,
 --reportformat ReportFmt, --dataalignment SizeKB, --dataalignmentoffset SizeKB,
@@ -1535,7 +1535,7 @@ OO_VGSPLIT: --autobackup Bool
 
 # used only when the destination VG is new
 OO_VGSPLIT_NEW: --alloc Alloc, --clustered Bool,
---maxlogicalvolumes Number, --maxphysicalvolumes Number,
+--maxlogicalvolumes Number, --maxphysicalvolumes Uint32,
 --metadatatype MetadataType, --vgmetadatacopies MetadataCopiesVG
 
 vgsplit VG VG PV ...
diff --git a/tools/create-commands.c b/tools/create-commands.c
index 704ec47..d9f8218 100644
--- a/tools/create-commands.c
+++ b/tools/create-commands.c
@@ -34,6 +34,7 @@ int size_kb_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 int size_mb_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 int size_mb_arg_with_percent(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 int int_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+int uint32_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 int int_arg_with_sign(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 int int_arg_with_sign_and_percent(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 int major_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
diff --git a/tools/vals.h b/tools/vals.h
index c8c998f..12d315f 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -99,6 +99,7 @@ val(conststr_VAL, NULL, "ConstString", "ERR")  /* used only for command defs */
 val(constnum_VAL, NULL, "ConstNumber", "ERR")  /* used only for command defs */
 val(bool_VAL, yes_no_arg, "Bool", "y|n")
 val(number_VAL, int_arg, "Number", NULL)
+val(uint32_VAL, uint32_arg, "Uint32", "Number")
 val(string_VAL, string_arg, "String", NULL)
 val(vg_VAL, string_arg, "VG", NULL)
 val(lv_VAL, string_arg, "LV", NULL)


