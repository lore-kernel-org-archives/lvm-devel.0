From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 12:01:28 +0000 (GMT)
Subject: stable-2.02 - make: generate
Message-ID: <20210217120128.C6E9B389850A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=99d8b91422243f227c9324bdee2cd7d3d879ddbc
Commit:        99d8b91422243f227c9324bdee2cd7d3d879ddbc
Parent:        37a97c8995a4f5ffb65ce6f735816835f9533a29
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 17 11:57:52 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 12:59:36 2021 +0100

make: generate

---
 man/lvconvert.8_pregen | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 94ad90370..d11ff04b9 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -66,6 +66,10 @@ lvconvert - Change logical volume layout
     \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .ad b
 .br
+.ad l
+    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP
+.ad b
+.br
 .ad l
  \fB-f\fP|\fB--force\fP
 .ad b
@@ -675,6 +679,10 @@ Convert LV to type thin-pool.
 .ad b
 .br
 .ad l
+[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [    \fB--poolmetadata\fP \fILV\fP ]
 .ad b
 .br
@@ -1093,6 +1101,19 @@ For testing and debugging.
 .ad b
 .HP
 .ad l
+\fB--errorwhenfull\fP \fBy\fP|\fBn\fP
+.br
+Specifies thin pool behavior when data space is exhausted.
+When yes, device-mapper will immediately return an error
+when a thin pool is full and an I/O request requires space.
+When no, device-mapper will queue these I/O requests for a
+period of time to allow the thin pool to be extended.
+Errors are returned if no space is available after the timeout.
+(Also see dm-thin-pool kernel module option no_space_timeout.)
+See \fBlvmthin\fP(7) for more information.
+.ad b
+.HP
+.ad l
 \fB-f\fP|\fB--force\fP ...
 .br
 Override various checks, confirmations and protections.


