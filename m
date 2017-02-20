From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 20 Feb 2017 17:26:59 +0000 (UTC)
Subject: master - lvresize/lvextend: accept type option
Message-ID: <20170220172659.72C9A61081@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4d29d9afb21a4571b45fe18d16cc4b57cd7ec187
Commit:        4d29d9afb21a4571b45fe18d16cc4b57cd7ec187
Parent:        5f2639d01d8e1ac6e95ad7855abb93b5cd260a22
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 20 11:23:46 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 20 11:23:46 2017 -0600

lvresize/lvextend: accept type option

The --type option has previously been accepted for
lvresize/lvextend.  Using it did not affect the operation
of the command.  The value was simply verified as matching
the current seg type of the LV.
---
 tools/command-lines.in |   29 ++++++++++++++++++++++-------
 1 files changed, 22 insertions(+), 7 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index aed38e7..092f941 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1126,12 +1126,17 @@ ID: lvdisplay_general
 
 ---
 
+# --type is an option in lvextend/lvresize only so that the specified type
+# value can be checked to match the existing type; using it doesn't
+# currently enable any different behavior.
+
 # --extents is not specified; it's an automatic alternative for --size
 
 lvextend --size SizeMB LV
 OO: --alloc Alloc, --autobackup Bool, --force, --mirrors SNumber,
 --nofsck, --nosync, --noudevsync, --reportformat ReportFmt, --resizefs,
---stripes Number, --stripesize SizeKB, --poolmetadatasize SizeMB
+--stripes Number, --stripesize SizeKB, --poolmetadatasize SizeMB,
+--type SegType
 OP: PV ...
 ID: lvextend_by_size
 DESC: Extend an LV by a specified size.
@@ -1139,7 +1144,8 @@ DESC: Extend an LV by a specified size.
 lvextend LV PV ...
 OO: --alloc Alloc, --autobackup Bool, --force, --mirrors SNumber,
 --nofsck, --nosync, --noudevsync,
---reportformat ReportFmt, --resizefs, --stripes Number, --stripesize SizeKB
+--reportformat ReportFmt, --resizefs, --stripes Number, --stripesize SizeKB,
+--type SegType
 ID: lvextend_by_pv
 DESC: Extend an LV by specified PV extents.
 FLAGS: SECONDARY_SYNTAX
@@ -1147,7 +1153,8 @@ FLAGS: SECONDARY_SYNTAX
 lvextend --poolmetadatasize SizeMB LV_thinpool
 OO: --alloc Alloc, --autobackup Bool, --force, --mirrors SNumber,
 --nofsck, --nosync, --noudevsync,
---reportformat ReportFmt, --stripes Number, --stripesize SizeKB
+--reportformat ReportFmt, --stripes Number, --stripesize SizeKB,
+--type SegType
 OP: PV ...
 ID: lvextend_pool_metadata_by_size
 DESC: Extend a pool metadata SubLV by a specified size.
@@ -1155,7 +1162,8 @@ DESC: Extend a pool metadata SubLV by a specified size.
 lvextend --usepolicies LV_thinpool_snapshot
 OO: --alloc Alloc, --autobackup Bool, --force, --mirrors SNumber,
 --nofsck, --nosync, --noudevsync,
---reportformat ReportFmt, --resizefs
+--reportformat ReportFmt, --resizefs,
+--type SegType
 OP: PV ...
 ID: lvextend_by_policy
 DESC: Extend an LV according to a predefined policy.
@@ -1193,10 +1201,15 @@ ID: lvrename_lv_lv
 
 ---
 
+# --type is an option in lvextend/lvresize only so that the specified type
+# value can be checked to match the existing type; using it doesn't
+# currently enable any different behavior.
+
 lvresize --size SizeMB LV
 OO: --alloc Alloc, --autobackup Bool, --force,
 --nofsck, --nosync, --noudevsync, --reportformat ReportFmt, --resizefs,
---stripes Number, --stripesize SizeKB, --poolmetadatasize SizeMB
+--stripes Number, --stripesize SizeKB, --poolmetadatasize SizeMB,
+--type SegType
 OP: PV ...
 ID: lvresize_by_size
 DESC: Resize an LV by a specified size.
@@ -1204,7 +1217,8 @@ DESC: Resize an LV by a specified size.
 lvresize LV PV ...
 OO: --alloc Alloc, --autobackup Bool, --force,
 --nofsck, --nosync, --noudevsync,
---reportformat ReportFmt, --resizefs, --stripes Number, --stripesize SizeKB
+--reportformat ReportFmt, --resizefs, --stripes Number, --stripesize SizeKB,
+--type SegType
 ID: lvresize_by_pv
 DESC: Resize an LV by specified PV extents.
 FLAGS: SECONDARY_SYNTAX
@@ -1212,7 +1226,8 @@ FLAGS: SECONDARY_SYNTAX
 lvresize --poolmetadatasize SizeMB LV_thinpool
 OO: --alloc Alloc, --autobackup Bool, --force,
 --nofsck, --nosync, --noudevsync,
---reportformat ReportFmt, --stripes Number, --stripesize SizeKB
+--reportformat ReportFmt, --stripes Number, --stripesize SizeKB,
+--type SegType
 OP: PV ...
 ID: lvresize_pool_metadata_by_size
 DESC: Resize a pool metadata SubLV by a specified size.


