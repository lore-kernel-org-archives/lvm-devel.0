From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 27 Aug 2019 11:11:18 -0400
Subject: stable-2.02 - build: make generate
Message-ID: <201908271511.x7RFBIbS026684@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3954034b1577c21be18acd2f8e1904c3181c6c19
Commit:        3954034b1577c21be18acd2f8e1904c3181c6c19
Parent:        ad86cda4d79704dcce13d98cd9579baab56b7e7b
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Aug 27 17:10:05 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Aug 27 17:10:52 2019 +0200

build: make generate

---
 man/lvconvert.8_pregen |   70 ++++++++++++++++++++++++++----------------------
 1 files changed, 38 insertions(+), 32 deletions(-)

diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index a47127b..e6de8f0 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -354,6 +354,44 @@ Convert LV to striped.
 .RE
 -
 
+Convert LV to type mirror (also see type raid1),
+.br
+.P
+\fBlvconvert\fP \fB--type\fP \fBmirror\fP \fILV\fP
+.br
+.RS 4
+.ad l
+[ \fB-m\fP|\fB--mirrors\fP [\fB+\fP|\fB-\fP]\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+.ad b
+.br
+.ad l
+[ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
+.ad b
+.br
+.ad l
+[ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--stripes\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP ]
+.ad b
+.br
+[ COMMON_OPTIONS ]
+.RE
+.br
+.RS 4
+[ \fIPV\fP ... ]
+.RE
+-
+
 Convert LV to raid or change raid layout 
 .br
 (a specific raid level must be used, e.g. raid1).
@@ -1472,38 +1510,6 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .SH ADVANCED USAGE
 Alternate command forms, advanced command usage, and listing of all valid syntax for completeness.
 .P
-Convert LV to type mirror (also see type raid1), 
-.br
-(also see lvconvert --mirrors).
-.br
-.P
-\fBlvconvert\fP \fB--type\fP \fBmirror\fP \fILV\fP
-.br
-.RS 4
-.ad l
-[ \fB-m\fP|\fB--mirrors\fP [\fB+\fP|\fB-\fP]\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
-.ad b
-.br
-.ad l
-[ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP ]
-.ad b
-.br
-[ COMMON_OPTIONS ]
-.RE
-.br
-.RS 4
-[ \fIPV\fP ... ]
-.RE
--
-
 Change the region size of an LV.
 .br
 .P


