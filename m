From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 28 Jan 2019 16:40:57 -0500
Subject: master - vdo: document types vdo and vdo-pool
Message-ID: <201901282140.x0SLevps002472@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=59b87cf7d67613d82e8dff7eb10f3c6ceaea0124
Commit:        59b87cf7d67613d82e8dff7eb10f3c6ceaea0124
Parent:        87864f09f6a394b408329ce695e6c93cbee15bbd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 28 21:42:30 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 28 22:39:10 2019 +0100

vdo: document types vdo and vdo-pool

---
 man/lvextend.8_pregen |    9 +++++----
 tools/args.h          |    3 ++-
 tools/vals.h          |    2 +-
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/man/lvextend.8_pregen b/man/lvextend.8_pregen
index 6466172..b7e4bca 100644
--- a/man/lvextend.8_pregen
+++ b/man/lvextend.8_pregen
@@ -111,7 +111,7 @@ lvextend - Add space to a logical volume
 .ad b
 .br
 .ad l
-    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
+    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBvdo\fP|\fBthin-pool\fP|\fBcache-pool\fP|\fBvdo-pool\fP
 .ad b
 .br
 .ad l
@@ -276,7 +276,7 @@ Common options for command:
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP ]
+[    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBvdo\fP|\fBthin-pool\fP|\fBcache-pool\fP|\fBvdo-pool\fP ]
 .ad b
 .RE
 
@@ -580,7 +580,7 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
+\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBvdo\fP|\fBthin-pool\fP|\fBcache-pool\fP|\fBvdo-pool\fP
 .br
 The LV type, also known as "segment type" or "segtype".
 See usage descriptions for the specific ways to use these types.
@@ -588,9 +588,10 @@ For more information about redundancy and performance (\fBraid\fP<N>, \fBmirror\
 For thin provisioning (\fBthin\fP, \fBthin-pool\fP) see \fBlvmthin\fP(7).
 For performance caching (\fBcache\fP, \fBcache-pool\fP) see \fBlvmcache\fP(7).
 For copy-on-write snapshots (\fBsnapshot\fP) see usage definitions.
+For VDO (\fBvdo\fP) see \fBlvmvdo\fP(7).
 Several commands omit an explicit type option because the type
 is inferred from other options or shortcuts
-(e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache).
+(e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache, --vdo).
 Use inferred types with care because it can lead to unexpected results.
 .ad b
 .HP
diff --git a/tools/args.h b/tools/args.h
index 898e756..b3ba99e 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -714,9 +714,10 @@ arg(type_ARG, '\0', "type", segtype_VAL, 0, 0,
     "For thin provisioning (\\fBthin\\fP, \\fBthin-pool\\fP) see \\fBlvmthin\\fP(7).\n"
     "For performance caching (\\fBcache\\fP, \\fBcache-pool\\fP) see \\fBlvmcache\\fP(7).\n"
     "For copy-on-write snapshots (\\fBsnapshot\\fP) see usage definitions.\n"
+    "For VDO (\\fBvdo\\fP) see \\fBlvmvdo\\fP(7).\n"
     "Several commands omit an explicit type option because the type\n"
     "is inferred from other options or shortcuts\n"
-    "(e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache).\n"
+    "(e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache, --vdo).\n"
     "Use inferred types with care because it can lead to unexpected results.\n")
 
 arg(unbuffered_ARG, '\0', "unbuffered", 0, 0, 0,
diff --git a/tools/vals.h b/tools/vals.h
index 79c48b5..db8bae9 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -128,7 +128,7 @@ val(nextents_VAL, nextents_arg, "NExtents", "[-]Number[PERCENT]")
 val(permission_VAL, permission_arg, "Permission", "rw|r")
 val(metadatatype_VAL, metadatatype_arg, "MetadataType", "lvm2")
 val(units_VAL, string_arg, "Units", "r|R|h|H|b|B|s|S|k|K|m|M|g|G|t|T|p|P|e|E")
-val(segtype_VAL, segtype_arg, "SegType", "linear|striped|snapshot|mirror|raid|thin|cache|thin-pool|cache-pool")
+val(segtype_VAL, segtype_arg, "SegType", "linear|striped|snapshot|mirror|raid|thin|cache|vdo|thin-pool|cache-pool|vdo-pool")
 val(alloc_VAL, alloc_arg, "Alloc", "contiguous|cling|cling_by_tags|normal|anywhere|inherit")
 val(locktype_VAL, locktype_arg, "LockType", "sanlock|dlm|none")
 val(readahead_VAL, readahead_arg, "Readahead", "auto|none|Number")


