From: David Teigland <teigland@sourceware.org>
Date: Fri, 3 Mar 2017 17:12:16 -0500
Subject: master - man/help: poolmetadatasize option can take relative value
Message-ID: <201703032212.v23MCG7F023025@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b6c4b7cfb07504229cb7ff1f02f4cce4ebdead6d
Commit:        b6c4b7cfb07504229cb7ff1f02f4cce4ebdead6d
Parent:        c5b6c9ad44a3057cd3d8e81e29b65149151ff1e7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 3 15:57:51 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Mar 3 16:12:02 2017 -0600

man/help: poolmetadatasize option can take relative value

In lvcreate/lvconvert, --poolmetdatasize can only be an
absolute value, but in lvresize/lvextend, --poolmetadatasize
can be given a + relative value.

The val types only currently support relative values that
go in both directions +|-.  Further work is needed to add
val types that can be relative in only one direction, and
switching various option values to one those depending on
the command name.  Then poolmetdatasize will not appear
with a +|- option in lvcreate/lvconvert, and will
appear with only the + option in lvresize/lvextend.
---
 tools/args.h           |   11 +++++++++--
 tools/command-lines.in |   12 ++++++------
 tools/command.c        |    8 ++++++++
 3 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 5512bed..448f6aa 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -414,8 +414,15 @@ arg(pooldatasize_ARG, '\0', "pooldatasize", sizemb_VAL, 0, 0, NULL)
 arg(poolmetadata_ARG, '\0', "poolmetadata", lv_VAL, 0, 0,
     "The name of a an LV to use for storing pool metadata.\n")
 
-arg(poolmetadatasize_ARG, '\0', "poolmetadatasize", sizemb_VAL, 0, 0,
-    "The size of the pool metadata LV created by the command.\n")
+arg(poolmetadatasize_ARG, '\0', "poolmetadatasize", ssizemb_VAL, 0, 0,
+    "#lvcreate\n"
+    "#lvconvert\n"
+    "Specifies the size of the new pool metadata LV.\n"
+    "#lvresize\n"
+    "#lvextend\n"
+    "Specifies the new size of the pool metadata LV.\n"
+    "The plus prefix \\fB+\\fP can be used, in which case\n"
+    "the value is added to the current size.\n")
 
 arg(poolmetadataspare_ARG, '\0', "poolmetadataspare", bool_VAL, 0, 0,
     "Enable or disable the automatic creation and management of a\n"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index f6a4414..b1405b6 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -307,7 +307,7 @@ RULE: all not LV_thinpool LV_cachepool
 OO_LVCONVERT_RAID: --mirrors SNumber, --stripes_long Number,
 --stripesize SizeKB, --regionsize RegionSize, --interval Number
 
-OO_LVCONVERT_POOL: --poolmetadata LV, --poolmetadatasize SizeMB,
+OO_LVCONVERT_POOL: --poolmetadata LV, --poolmetadatasize SSizeMB,
 --poolmetadataspare Bool, --readahead Readahead, --chunksize SizeKB
 
 OO_LVCONVERT_CACHE: --cachemode CacheMode, --cachepolicy String,
@@ -702,7 +702,7 @@ OO_LVCREATE: --addtag Tag, --alloc Alloc, --autobackup Bool, --activate Active,
 OO_LVCREATE_CACHE: --cachemode CacheMode, --cachepolicy String, --cachesettings String,
 --chunksize SizeKB
 
-OO_LVCREATE_POOL: --poolmetadatasize SizeMB, --poolmetadataspare Bool, --chunksize SizeKB
+OO_LVCREATE_POOL: --poolmetadatasize SSizeMB, --poolmetadataspare Bool, --chunksize SizeKB
 
 OO_LVCREATE_THIN: --discards Discards, --errorwhenfull Bool
 
@@ -1148,7 +1148,7 @@ ID: lvdisplay_general
 lvextend --size SSizeMB LV
 OO: --alloc Alloc, --autobackup Bool, --force, --mirrors SNumber,
 --nofsck, --nosync, --noudevsync, --reportformat ReportFmt, --resizefs,
---stripes Number, --stripesize SizeKB, --poolmetadatasize SizeMB,
+--stripes Number, --stripesize SizeKB, --poolmetadatasize SSizeMB,
 --type SegType
 OP: PV ...
 ID: lvextend_by_size
@@ -1162,7 +1162,7 @@ OO: --alloc Alloc, --autobackup Bool, --force, --mirrors SNumber,
 ID: lvextend_by_pv
 DESC: Extend an LV by specified PV extents.
 
-lvextend --poolmetadatasize SizeMB LV_thinpool
+lvextend --poolmetadatasize SSizeMB LV_thinpool
 OO: --alloc Alloc, --autobackup Bool, --force, --mirrors SNumber,
 --nofsck, --nosync, --noudevsync,
 --reportformat ReportFmt, --stripes Number, --stripesize SizeKB,
@@ -1220,7 +1220,7 @@ ID: lvrename_lv_lv
 lvresize --size SSizeMB LV
 OO: --alloc Alloc, --autobackup Bool, --force,
 --nofsck, --nosync, --noudevsync, --reportformat ReportFmt, --resizefs,
---stripes Number, --stripesize SizeKB, --poolmetadatasize SizeMB,
+--stripes Number, --stripesize SizeKB, --poolmetadatasize SSizeMB,
 --type SegType
 OP: PV ...
 ID: lvresize_by_size
@@ -1234,7 +1234,7 @@ OO: --alloc Alloc, --autobackup Bool, --force,
 ID: lvresize_by_pv
 DESC: Resize an LV by specified PV extents.
 
-lvresize --poolmetadatasize SizeMB LV_thinpool
+lvresize --poolmetadatasize SSizeMB LV_thinpool
 OO: --alloc Alloc, --autobackup Bool, --force,
 --nofsck, --nosync, --noudevsync,
 --reportformat ReportFmt, --stripes Number, --stripesize SizeKB,
diff --git a/tools/command.c b/tools/command.c
index 436e759..70f9bee 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1596,6 +1596,10 @@ static void print_val_usage(struct command *cmd, int val_enum)
 	 * lvcreate does not take a relative [+|-] value
 	 * for --size or --extents.
 	 * Should we also squash - for lvextend and + for lvreduce?
+	 *
+	 * Should also squash +|- in front of poolmetadatasize value
+	 * in lvcreate and lvconvert, and squash - in front of
+	 * poolmetadatasize value in lvresize/lvextend.
 	 */
 	squash_sign_prefix = !strcmp(cmd->name, "lvcreate");
 
@@ -2070,6 +2074,10 @@ static void print_val_man(struct command_name *cname, int val_enum)
 	 * lvcreate does not take a relative [+|-] value
 	 * for --size or --extents.
 	 * Should we also squash - for lvextend and + for lvreduce?
+	 *
+	 * Should also squash +|- in front of poolmetadatasize value
+	 * in lvcreate and lvconvert, and squash - in front of
+	 * poolmetadatasize value in lvresize/lvextend.
 	 */
 	squash_sign_prefix = !strcmp(cname->name, "lvcreate");
 


