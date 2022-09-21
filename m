From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 21 Sep 2022 12:59:07 +0000 (GMT)
Subject: main - make: generate
Message-ID: <20220921125907.EE165385514C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e97cf8552c7e47ab0a85e9dbec2d3581e34e2cc3
Commit:        e97cf8552c7e47ab0a85e9dbec2d3581e34e2cc3
Parent:        3a7aeebf7d7c58e53158321d73542c239896a3d7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 16 12:52:28 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 21 14:58:34 2022 +0200

make: generate

---
 man/lvextend.8_pregen | 59 +++++++++++++++++++++++++++++++++++++++++++++------
 man/lvreduce.8_pregen | 43 +++++++++++++++++++++++++++++++++----
 man/lvresize.8_pregen | 51 ++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 139 insertions(+), 14 deletions(-)

diff --git a/man/lvextend.8_pregen b/man/lvextend.8_pregen
index 3c2bfa6bf..2e0ed3068 100644
--- a/man/lvextend.8_pregen
+++ b/man/lvextend.8_pregen
@@ -36,6 +36,10 @@ lvextend \(em Add space to a logical volume
  \fB-l\fP|\fB--extents\fP [\fB+\fP]\fINumber\fP[PERCENT]
 .br
  \fB-f\fP|\fB--force\fP
+.br
+    \fB--fs\fP \fIString\fP
+.br
+    \fB--fsmode\fP \fIString\fP
 .br
  \fB-h\fP|\fB--help\fP
 .br
@@ -123,6 +127,10 @@ Extend an LV by a specified size.
 .br
 [    \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT] ]
 .br
+[    \fB--fs\fP \fIString\fP ]
+.br
+[    \fB--fsmode\fP \fIString\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
@@ -145,6 +153,10 @@ Extend an LV by specified PV extents.
 .br
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
 .br
+[    \fB--fs\fP \fIString\fP ]
+.br
+[    \fB--fsmode\fP \fIString\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
@@ -170,7 +182,7 @@ Extend a pool metadata SubLV by a specified size.
 .RE
 .P
 .RS 4
-LV1 types: thinpool
+LV1 types: linear thinpool
 .RE
 .P
 \(em
@@ -184,6 +196,10 @@ Extend an LV according to a predefined policy.
 .ad l
 [ \fB-r\fP|\fB--resizefs\fP ]
 .br
+[    \fB--fs\fP \fIString\fP ]
+.br
+[    \fB--fsmode\fP \fIString\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
@@ -192,7 +208,7 @@ Extend an LV according to a predefined policy.
 .RE
 .P
 .RS 4
-LV1 types: snapshot thinpool
+LV1 types: snapshot thinpool vdopool
 .RE
 .P
 \(em
@@ -377,6 +393,36 @@ Override various checks, confirmations and protections.
 Use with extreme caution.
 .
 .HP
+\fB--fs\fP \fIString\fP
+.br
+Control file system resizing when resizing an LV.
+\fBchecksize\fP: Check the fs size and reduce the LV if the fs is not
+using the reduced space (fs reduce is not needed.) If the reduced space
+is used by the fs, then do not resize the fs or LV, and return an error.
+(checksize only applies when reducing, and does nothing for extend.)
+\fBresize\fP: Resize the fs by calling the fs-specific resize command.
+This may also include mounting, unmounting, or running fsck. See --fsmode to
+control mounting behavior, and --nofsck to disable fsck.
+\fBresize_fsadm\fP: Use the old method of calling fsadm to handle the fs
+(deprecated.) Warning: this option does not prevent lvreduce from destroying
+file systems that are unmounted (or mounted if prompts are skipped.)
+\fBignore\fP: Resize the LV without checking for or handling a file system.
+Warning: using ignore when reducing the LV size may destroy the file system.
+.
+.HP
+\fB--fsmode\fP \fIString\fP
+.br
+Control file system mounting behavior for fs resize.
+\fBmanage\fP: Mount or unmount the fs as needed to resize the fs,
+and attempt to restore the original mount state at the end.
+\fBnochange\fP: Do not mount or unmount the fs. If mounting or unmounting
+is required to resize the fs, then do not resize the fs or the LV and fail
+the command.
+\fBoffline\fP: Unmount the fs if it is mounted, and resize the fs while it
+is unmounted. If mounting is required to resize the fs, then do not resize
+the fs or the LV and fail the command.
+.
+.HP
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
@@ -410,9 +456,7 @@ Not used.
 .HP
 \fB-n\fP|\fB--nofsck\fP
 .br
-Do not perform fsck before resizing filesystem when filesystem
-requires it. You may need to use --force to proceed with
-this option.
+Do not perform fsck when resizing the file system with --resizefs.
 .
 .HP
 \fB--nohints\fP
@@ -485,7 +529,10 @@ See \fBlvmreport\fP(7) for more information.
 .HP
 \fB-r\fP|\fB--resizefs\fP
 .br
-Resize underlying filesystem together with the LV using \fBfsadm\fP(8).
+Resize the fs using the fs-specific resize command.
+May include mounting, unmounting, or running fsck. See --fsmode to control
+mounting behavior, and --nofsck to disable fsck. See --fs for more options
+(--resizefs is equivalent to --fs resize.)
 .
 .HP
 \fB-L\fP|\fB--size\fP [\fB+\fP]\fISize\fP[m|UNIT]
diff --git a/man/lvreduce.8_pregen b/man/lvreduce.8_pregen
index 4f6615449..61b71e4d9 100644
--- a/man/lvreduce.8_pregen
+++ b/man/lvreduce.8_pregen
@@ -52,6 +52,10 @@ the options section.
 .br
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
+[    \fB--fs\fP \fIString\fP ]
+.br
+[    \fB--fsmode\fP \fIString\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
@@ -179,6 +183,36 @@ Override various checks, confirmations and protections.
 Use with extreme caution.
 .
 .HP
+\fB--fs\fP \fIString\fP
+.br
+Control file system resizing when resizing an LV.
+\fBchecksize\fP: Check the fs size and reduce the LV if the fs is not
+using the reduced space (fs reduce is not needed.) If the reduced space
+is used by the fs, then do not resize the fs or LV, and return an error.
+(checksize only applies when reducing, and does nothing for extend.)
+\fBresize\fP: Resize the fs by calling the fs-specific resize command.
+This may also include mounting, unmounting, or running fsck. See --fsmode to
+control mounting behavior, and --nofsck to disable fsck.
+\fBresize_fsadm\fP: Use the old method of calling fsadm to handle the fs
+(deprecated.) Warning: this option does not prevent lvreduce from destroying
+file systems that are unmounted (or mounted if prompts are skipped.)
+\fBignore\fP: Resize the LV without checking for or handling a file system.
+Warning: using ignore when reducing the LV size may destroy the file system.
+.
+.HP
+\fB--fsmode\fP \fIString\fP
+.br
+Control file system mounting behavior for fs resize.
+\fBmanage\fP: Mount or unmount the fs as needed to resize the fs,
+and attempt to restore the original mount state at the end.
+\fBnochange\fP: Do not mount or unmount the fs. If mounting or unmounting
+is required to resize the fs, then do not resize the fs or the LV and fail
+the command.
+\fBoffline\fP: Unmount the fs if it is mounted, and resize the fs while it
+is unmounted. If mounting is required to resize the fs, then do not resize
+the fs or the LV and fail the command.
+.
+.HP
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
@@ -207,9 +241,7 @@ Display long help text.
 .HP
 \fB-n\fP|\fB--nofsck\fP
 .br
-Do not perform fsck before resizing filesystem when filesystem
-requires it. You may need to use --force to proceed with
-this option.
+Do not perform fsck when resizing the file system with --resizefs.
 .
 .HP
 \fB--nohints\fP
@@ -259,7 +291,10 @@ See \fBlvmreport\fP(7) for more information.
 .HP
 \fB-r\fP|\fB--resizefs\fP
 .br
-Resize underlying filesystem together with the LV using \fBfsadm\fP(8).
+Resize the fs using the fs-specific resize command.
+May include mounting, unmounting, or running fsck. See --fsmode to control
+mounting behavior, and --nofsck to disable fsck. See --fs for more options
+(--resizefs is equivalent to --fs resize.)
 .
 .HP
 \fB-L\fP|\fB--size\fP [\fB-\fP]\fISize\fP[m|UNIT]
diff --git a/man/lvresize.8_pregen b/man/lvresize.8_pregen
index 1671741ce..89261f38d 100644
--- a/man/lvresize.8_pregen
+++ b/man/lvresize.8_pregen
@@ -36,6 +36,10 @@ lvresize \(em Resize a logical volume
  \fB-l\fP|\fB--extents\fP [\fB+\fP|\fB-\fP]\fINumber\fP[PERCENT]
 .br
  \fB-f\fP|\fB--force\fP
+.br
+    \fB--fs\fP \fIString\fP
+.br
+    \fB--fsmode\fP \fIString\fP
 .br
  \fB-h\fP|\fB--help\fP
 .br
@@ -109,6 +113,10 @@ Resize an LV by a specified size.
 .br
 [    \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT] ]
 .br
+[    \fB--fs\fP \fIString\fP ]
+.br
+[    \fB--fsmode\fP \fIString\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
@@ -127,6 +135,10 @@ Resize an LV by specified PV extents.
 .ad l
 [ \fB-r\fP|\fB--resizefs\fP ]
 .br
+[    \fB--fs\fP \fIString\fP ]
+.br
+[    \fB--fsmode\fP \fIString\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
@@ -335,6 +347,36 @@ Override various checks, confirmations and protections.
 Use with extreme caution.
 .
 .HP
+\fB--fs\fP \fIString\fP
+.br
+Control file system resizing when resizing an LV.
+\fBchecksize\fP: Check the fs size and reduce the LV if the fs is not
+using the reduced space (fs reduce is not needed.) If the reduced space
+is used by the fs, then do not resize the fs or LV, and return an error.
+(checksize only applies when reducing, and does nothing for extend.)
+\fBresize\fP: Resize the fs by calling the fs-specific resize command.
+This may also include mounting, unmounting, or running fsck. See --fsmode to
+control mounting behavior, and --nofsck to disable fsck.
+\fBresize_fsadm\fP: Use the old method of calling fsadm to handle the fs
+(deprecated.) Warning: this option does not prevent lvreduce from destroying
+file systems that are unmounted (or mounted if prompts are skipped.)
+\fBignore\fP: Resize the LV without checking for or handling a file system.
+Warning: using ignore when reducing the LV size may destroy the file system.
+.
+.HP
+\fB--fsmode\fP \fIString\fP
+.br
+Control file system mounting behavior for fs resize.
+\fBmanage\fP: Mount or unmount the fs as needed to resize the fs,
+and attempt to restore the original mount state at the end.
+\fBnochange\fP: Do not mount or unmount the fs. If mounting or unmounting
+is required to resize the fs, then do not resize the fs or the LV and fail
+the command.
+\fBoffline\fP: Unmount the fs if it is mounted, and resize the fs while it
+is unmounted. If mounting is required to resize the fs, then do not resize
+the fs or the LV and fail the command.
+.
+.HP
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
@@ -363,9 +405,7 @@ Display long help text.
 .HP
 \fB-n\fP|\fB--nofsck\fP
 .br
-Do not perform fsck before resizing filesystem when filesystem
-requires it. You may need to use --force to proceed with
-this option.
+Do not perform fsck when resizing the file system with --resizefs.
 .
 .HP
 \fB--nohints\fP
@@ -438,7 +478,10 @@ See \fBlvmreport\fP(7) for more information.
 .HP
 \fB-r\fP|\fB--resizefs\fP
 .br
-Resize underlying filesystem together with the LV using \fBfsadm\fP(8).
+Resize the fs using the fs-specific resize command.
+May include mounting, unmounting, or running fsck. See --fsmode to control
+mounting behavior, and --nofsck to disable fsck. See --fs for more options
+(--resizefs is equivalent to --fs resize.)
 .
 .HP
 \fB-L\fP|\fB--size\fP [\fB+\fP|\fB-\fP]\fISize\fP[m|UNIT]

