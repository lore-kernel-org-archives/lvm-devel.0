From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 22 Mar 2023 12:44:18 +0000 (GMT)
Subject: main - make: generate
Message-ID: <20230322124418.BD5F83857C48@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6204fda003804e2bad022347baab510cb845f315
Commit:        6204fda003804e2bad022347baab510cb845f315
Parent:        49dbeb9b4566df684164f40ca6ebdab3d6696836
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Mar 21 13:33:14 2023 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Mar 21 13:33:14 2023 +0100

make: generate

---
 man/vgchange.8_pregen | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index 5ab59204d..4665e98c8 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -68,6 +68,8 @@ vgchange \(em Change volume group attributes
  \fB-l\fP|\fB--logicalvolume\fP \fINumber\fP
 .br
     \fB--longhelp\fP
+.br
+    \fB--majoritypvs\fP
 .br
  \fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP
 .br
@@ -348,6 +350,8 @@ Change the system ID of a VG.
 .ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
 .br
+[    \fB--majoritypvs\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
@@ -666,6 +670,12 @@ Sets the maximum number of LVs allowed in a VG.
 Display long help text.
 .
 .HP
+\fB--majoritypvs\fP
+.br
+Change the VG system ID if the majority of PVs in the VG
+are present (one more than half).
+.
+.HP
 \fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP
 .br
 Sets the maximum number of PVs that can belong to the VG.

