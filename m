From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 10:54:49 +0000 (GMT)
Subject: main - make: generate
Message-ID: <20210217105449.468A23857C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2c5e034cd3cb480d79ac4cc23a6d5079bb053f28
Commit:        2c5e034cd3cb480d79ac4cc23a6d5079bb053f28
Parent:        b9846bdc3e420348646d26259ad57c60b6f2ebf9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 16 21:30:06 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 11:53:19 2021 +0100

make: generate

---
 man/lvconvert.8_pregen | 45 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)

diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 170eec815..01fbc7154 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -86,6 +86,10 @@ lvconvert - Change logical volume layout
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
@@ -819,6 +823,10 @@ Convert LV to type thin-pool.
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
@@ -915,6 +923,18 @@ Convert LV to type vdopool.
 .ad b
 .br
 .ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--compression\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -1326,6 +1346,19 @@ For testing and debugging.
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
@@ -1981,6 +2014,14 @@ Convert LV to type vdopool.
 .br
 .RS 4
 .ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [ \fB-n\fP|\fB--name\fP \fILV\fP\fI_new\fP ]
 .ad b
 .br
@@ -1993,6 +2034,10 @@ Convert LV to type vdopool.
 .ad b
 .br
 .ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--compression\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br


