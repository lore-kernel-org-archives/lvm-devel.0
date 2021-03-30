From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 30 Mar 2021 11:10:12 +0000 (GMT)
Subject: main - man: writecache missed for --type
Message-ID: <20210330111012.01DAD3860C39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2aaea13aaa2935905a6d1cb32db4e2cd477c22f4
Commit:        2aaea13aaa2935905a6d1cb32db4e2cd477c22f4
Parent:        648188df2a9ba7528f60a9362860d7615227061b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 30 11:22:27 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 30 13:08:14 2021 +0200

man: writecache missed for --type

Add missing writecache type into man pages.
---
 man/lvconvert.8_pregen | 4 ++--
 man/lvcreate.8_pregen  | 4 ++--
 man/lvextend.8_pregen  | 6 +++---
 man/lvresize.8_pregen  | 6 +++---
 tools/vals.h           | 2 +-
 5 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 63fbc093c..5be4321c6 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -259,7 +259,7 @@ lvconvert - Change logical volume layout
 .ad b
 .br
 .ad l
-    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBvdo\fP|\fBthin-pool\fP|\fBcache-pool\fP|\fBvdo-pool\fP
+    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBraid\fP|\fBmirror\fP|\fBthin\fP|\fBthin-pool\fP|\fBvdo\fP|\fBvdo-pool\fP|\fBcache\fP|\fBcache-pool\fP|\fBwritecache\fP
 .ad b
 .br
 .ad l
@@ -1738,7 +1738,7 @@ the image (see --splitmirrors with --name.
 .ad b
 .HP
 .ad l
-\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBvdo\fP|\fBthin-pool\fP|\fBcache-pool\fP|\fBvdo-pool\fP
+\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBraid\fP|\fBmirror\fP|\fBthin\fP|\fBthin-pool\fP|\fBvdo\fP|\fBvdo-pool\fP|\fBcache\fP|\fBcache-pool\fP|\fBwritecache\fP
 .br
 The LV type, also known as "segment type" or "segtype".
 See usage descriptions for the specific ways to use these types.
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index 8f548811e..79441c128 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -263,7 +263,7 @@ lvcreate - Create a logical volume
 .ad b
 .br
 .ad l
-    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBvdo\fP|\fBthin-pool\fP|\fBcache-pool\fP|\fBvdo-pool\fP
+    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBraid\fP|\fBmirror\fP|\fBthin\fP|\fBthin-pool\fP|\fBvdo\fP|\fBvdo-pool\fP|\fBcache\fP|\fBcache-pool\fP|\fBwritecache\fP
 .ad b
 .br
 .ad l
@@ -1845,7 +1845,7 @@ The name of a thin pool LV.
 .ad b
 .HP
 .ad l
-\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBvdo\fP|\fBthin-pool\fP|\fBcache-pool\fP|\fBvdo-pool\fP
+\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBraid\fP|\fBmirror\fP|\fBthin\fP|\fBthin-pool\fP|\fBvdo\fP|\fBvdo-pool\fP|\fBcache\fP|\fBcache-pool\fP|\fBwritecache\fP
 .br
 The LV type, also known as "segment type" or "segtype".
 See usage descriptions for the specific ways to use these types.
diff --git a/man/lvextend.8_pregen b/man/lvextend.8_pregen
index 4ccfa809b..5e0a89ffd 100644
--- a/man/lvextend.8_pregen
+++ b/man/lvextend.8_pregen
@@ -119,7 +119,7 @@ lvextend - Add space to a logical volume
 .ad b
 .br
 .ad l
-    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBvdo\fP|\fBthin-pool\fP|\fBcache-pool\fP|\fBvdo-pool\fP
+    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBraid\fP|\fBmirror\fP|\fBthin\fP|\fBthin-pool\fP|\fBvdo\fP|\fBvdo-pool\fP|\fBcache\fP|\fBcache-pool\fP|\fBwritecache\fP
 .ad b
 .br
 .ad l
@@ -284,7 +284,7 @@ Common options for command:
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBvdo\fP|\fBthin-pool\fP|\fBcache-pool\fP|\fBvdo-pool\fP ]
+[    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBraid\fP|\fBmirror\fP|\fBthin\fP|\fBthin-pool\fP|\fBvdo\fP|\fBvdo-pool\fP|\fBcache\fP|\fBcache-pool\fP|\fBwritecache\fP ]
 .ad b
 .RE
 
@@ -614,7 +614,7 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBvdo\fP|\fBthin-pool\fP|\fBcache-pool\fP|\fBvdo-pool\fP
+\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBraid\fP|\fBmirror\fP|\fBthin\fP|\fBthin-pool\fP|\fBvdo\fP|\fBvdo-pool\fP|\fBcache\fP|\fBcache-pool\fP|\fBwritecache\fP
 .br
 The LV type, also known as "segment type" or "segtype".
 See usage descriptions for the specific ways to use these types.
diff --git a/man/lvresize.8_pregen b/man/lvresize.8_pregen
index 528066154..bc0b440db 100644
--- a/man/lvresize.8_pregen
+++ b/man/lvresize.8_pregen
@@ -115,7 +115,7 @@ lvresize - Resize a logical volume
 .ad b
 .br
 .ad l
-    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBvdo\fP|\fBthin-pool\fP|\fBcache-pool\fP|\fBvdo-pool\fP
+    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBraid\fP|\fBmirror\fP|\fBthin\fP|\fBthin-pool\fP|\fBvdo\fP|\fBvdo-pool\fP|\fBcache\fP|\fBcache-pool\fP|\fBwritecache\fP
 .ad b
 .br
 .ad l
@@ -232,7 +232,7 @@ Common options for command:
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBvdo\fP|\fBthin-pool\fP|\fBcache-pool\fP|\fBvdo-pool\fP ]
+[    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBraid\fP|\fBmirror\fP|\fBthin\fP|\fBthin-pool\fP|\fBvdo\fP|\fBvdo-pool\fP|\fBcache\fP|\fBcache-pool\fP|\fBwritecache\fP ]
 .ad b
 .RE
 
@@ -556,7 +556,7 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBvdo\fP|\fBthin-pool\fP|\fBcache-pool\fP|\fBvdo-pool\fP
+\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBraid\fP|\fBmirror\fP|\fBthin\fP|\fBthin-pool\fP|\fBvdo\fP|\fBvdo-pool\fP|\fBcache\fP|\fBcache-pool\fP|\fBwritecache\fP
 .br
 The LV type, also known as "segment type" or "segtype".
 See usage descriptions for the specific ways to use these types.
diff --git a/tools/vals.h b/tools/vals.h
index 70404436b..098dc9e4e 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -128,7 +128,7 @@ val(nextents_VAL, nextents_arg, "NExtents", "[-]Number[PERCENT]")
 val(permission_VAL, permission_arg, "Permission", "rw|r")
 val(metadatatype_VAL, metadatatype_arg, "MetadataType", "lvm2")
 val(units_VAL, string_arg, "Units", "r|R|h|H|b|B|s|S|k|K|m|M|g|G|t|T|p|P|e|E")
-val(segtype_VAL, segtype_arg, "SegType", "linear|striped|snapshot|mirror|raid|thin|cache|vdo|thin-pool|cache-pool|vdo-pool")
+val(segtype_VAL, segtype_arg, "SegType", "linear|striped|snapshot|raid|mirror|thin|thin-pool|vdo|vdo-pool|cache|cache-pool|writecache")
 val(alloc_VAL, alloc_arg, "Alloc", "contiguous|cling|cling_by_tags|normal|anywhere|inherit")
 val(locktype_VAL, locktype_arg, "LockType", "sanlock|dlm|none")
 val(readahead_VAL, readahead_arg, "Readahead", "auto|none|Number")


