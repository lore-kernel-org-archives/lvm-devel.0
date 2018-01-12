From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 11 Jan 2018 19:35:04 -0500
Subject: master - man: regenerate
Message-ID: <201801120035.w0C0Z4q3012953@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5bbe68cf15b00987e6644c956cf602251ac91581
Commit:        5bbe68cf15b00987e6644c956cf602251ac91581
Parent:        35cdd9cf48a8ec4e4e02fe62eec90dcce4fc8970
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jan 12 00:30:52 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jan 12 00:30:52 2018 +0000

man: regenerate

---
 man/lvchange.8_pregen       |   15 +++++++++++++++
 man/lvconvert.8_pregen      |   15 +++++++++++++++
 man/lvcreate.8_pregen       |   15 +++++++++++++++
 man/lvdisplay.8_pregen      |   11 +++++++++++
 man/lvextend.8_pregen       |   15 +++++++++++++++
 man/lvm-fullreport.8_pregen |   11 +++++++++++
 man/lvm-lvpoll.8_pregen     |   11 +++++++++++
 man/lvmconfig.8_pregen      |   11 +++++++++++
 man/lvmdiskscan.8_pregen    |   11 +++++++++++
 man/lvreduce.8_pregen       |   11 +++++++++++
 man/lvremove.8_pregen       |   11 +++++++++++
 man/lvrename.8_pregen       |   11 +++++++++++
 man/lvresize.8_pregen       |   15 +++++++++++++++
 man/lvs.8_pregen            |   11 +++++++++++
 man/lvscan.8_pregen         |   11 +++++++++++
 man/pvchange.8_pregen       |   11 +++++++++++
 man/pvck.8_pregen           |   11 +++++++++++
 man/pvcreate.8_pregen       |   11 +++++++++++
 man/pvdisplay.8_pregen      |   11 +++++++++++
 man/pvmove.8_pregen         |   11 +++++++++++
 man/pvremove.8_pregen       |   11 +++++++++++
 man/pvresize.8_pregen       |   11 +++++++++++
 man/pvs.8_pregen            |   11 +++++++++++
 man/pvscan.8_pregen         |   11 +++++++++++
 man/vgcfgbackup.8_pregen    |   11 +++++++++++
 man/vgcfgrestore.8_pregen   |   15 +++++++++++++++
 man/vgchange.8_pregen       |   16 ++++------------
 man/vgck.8_pregen           |   11 +++++++++++
 man/vgconvert.8_pregen      |   11 +++++++++++
 man/vgcreate.8_pregen       |    8 ++++----
 man/vgdisplay.8_pregen      |   11 +++++++++++
 man/vgexport.8_pregen       |   11 +++++++++++
 man/vgextend.8_pregen       |   11 +++++++++++
 man/vgimport.8_pregen       |   11 +++++++++++
 man/vgimportclone.8_pregen  |   11 +++++++++++
 man/vgmerge.8_pregen        |   11 +++++++++++
 man/vgmknodes.8_pregen      |   11 +++++++++++
 man/vgreduce.8_pregen       |   15 +++++++++++++++
 man/vgremove.8_pregen       |   11 +++++++++++
 man/vgrename.8_pregen       |   11 +++++++++++
 man/vgs.8_pregen            |   11 +++++++++++
 man/vgscan.8_pregen         |   11 +++++++++++
 man/vgsplit.8_pregen        |   11 +++++++++++
 43 files changed, 487 insertions(+), 16 deletions(-)

diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index 68c21d8..26a6297 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -101,6 +101,10 @@ lvchange - Change the attributes of logical volume(s)
 .ad b
 .br
 .ad l
+    \fB--lockopt\fP \fIString\fP
+.ad b
+.br
+.ad l
     \fB--longhelp\fP
 .ad b
 .br
@@ -564,6 +568,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -809,6 +817,13 @@ without clustered locking and clustered VGs are skipped.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 243d1c3..5171d6a 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -79,6 +79,10 @@ lvconvert - Change logical volume layout
 .ad b
 .br
 .ad l
+    \fB--lockopt\fP \fIString\fP
+.ad b
+.br
+.ad l
     \fB--longhelp\fP
 .ad b
 .br
@@ -891,6 +895,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -1066,6 +1074,13 @@ Report progress at regular intervals.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index 71bd82b..9dcb33f 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -99,6 +99,10 @@ lvcreate - Create a logical volume
 .ad b
 .br
 .ad l
+    \fB--lockopt\fP \fIString\fP
+.ad b
+.br
+.ad l
     \fB--longhelp\fP
 .ad b
 .br
@@ -904,6 +908,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -1147,6 +1155,13 @@ Do not use this if dmeventd is already monitoring a device.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/lvdisplay.8_pregen b/man/lvdisplay.8_pregen
index 6df90a0..33e4f5d 100644
--- a/man/lvdisplay.8_pregen
+++ b/man/lvdisplay.8_pregen
@@ -162,6 +162,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -283,6 +287,13 @@ without clustered locking and clustered VGs are skipped.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--logonly\fP
 .br
 Suppress command report and display only log report.
diff --git a/man/lvextend.8_pregen b/man/lvextend.8_pregen
index 9f4f097..130672e 100644
--- a/man/lvextend.8_pregen
+++ b/man/lvextend.8_pregen
@@ -47,6 +47,10 @@ lvextend - Add space to a logical volume
 .ad b
 .br
 .ad l
+    \fB--lockopt\fP \fIString\fP
+.ad b
+.br
+.ad l
     \fB--longhelp\fP
 .ad b
 .br
@@ -312,6 +316,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -420,6 +428,13 @@ Display help text.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/lvm-fullreport.8_pregen b/man/lvm-fullreport.8_pregen
index ff0cba7..3fb00b1 100644
--- a/man/lvm-fullreport.8_pregen
+++ b/man/lvm-fullreport.8_pregen
@@ -162,6 +162,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -258,6 +262,13 @@ without clustered locking and clustered VGs are skipped.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--logonly\fP
 .br
 Suppress command report and display only log report.
diff --git a/man/lvm-lvpoll.8_pregen b/man/lvm-lvpoll.8_pregen
index 2154b79..4591a28 100644
--- a/man/lvm-lvpoll.8_pregen
+++ b/man/lvm-lvpoll.8_pregen
@@ -76,6 +76,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -152,6 +156,13 @@ Report progress at regular intervals.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/lvmconfig.8_pregen b/man/lvmconfig.8_pregen
index 0b7fea6..b47d589 100644
--- a/man/lvmconfig.8_pregen
+++ b/man/lvmconfig.8_pregen
@@ -145,6 +145,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -245,6 +249,13 @@ options --typeconfig list --withsummary.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/lvmdiskscan.8_pregen b/man/lvmdiskscan.8_pregen
index fe379bb..8b26d95 100644
--- a/man/lvmdiskscan.8_pregen
+++ b/man/lvmdiskscan.8_pregen
@@ -71,6 +71,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -121,6 +125,13 @@ Display help text.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/lvreduce.8_pregen b/man/lvreduce.8_pregen
index 865aef4..3aa4b5a 100644
--- a/man/lvreduce.8_pregen
+++ b/man/lvreduce.8_pregen
@@ -102,6 +102,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -189,6 +193,13 @@ Display help text.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/lvremove.8_pregen b/man/lvremove.8_pregen
index 2c9aad1..88d0501 100644
--- a/man/lvremove.8_pregen
+++ b/man/lvremove.8_pregen
@@ -106,6 +106,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -170,6 +174,13 @@ Display help text.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/lvrename.8_pregen b/man/lvrename.8_pregen
index af39eed..69711e0 100644
--- a/man/lvrename.8_pregen
+++ b/man/lvrename.8_pregen
@@ -81,6 +81,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -138,6 +142,13 @@ Display help text.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/lvresize.8_pregen b/man/lvresize.8_pregen
index 2432495..8df157a 100644
--- a/man/lvresize.8_pregen
+++ b/man/lvresize.8_pregen
@@ -47,6 +47,10 @@ lvresize - Resize a logical volume
 .ad b
 .br
 .ad l
+    \fB--lockopt\fP \fIString\fP
+.ad b
+.br
+.ad l
     \fB--longhelp\fP
 .ad b
 .br
@@ -260,6 +264,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -368,6 +376,13 @@ Display help text.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index f773750..c6303bb 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -166,6 +166,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -273,6 +277,13 @@ without clustered locking and clustered VGs are skipped.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--logonly\fP
 .br
 Suppress command report and display only log report.
diff --git a/man/lvscan.8_pregen b/man/lvscan.8_pregen
index 7713e53..e9d90ee 100644
--- a/man/lvscan.8_pregen
+++ b/man/lvscan.8_pregen
@@ -97,6 +97,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -174,6 +178,13 @@ operations after locking failures.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/pvchange.8_pregen b/man/pvchange.8_pregen
index 33c49e9..6a80e72 100644
--- a/man/pvchange.8_pregen
+++ b/man/pvchange.8_pregen
@@ -146,6 +146,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -243,6 +247,13 @@ without clustered locking and clustered VGs are skipped.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/pvck.8_pregen b/man/pvck.8_pregen
index 51b761d..1140d69 100644
--- a/man/pvck.8_pregen
+++ b/man/pvck.8_pregen
@@ -61,6 +61,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -120,6 +124,13 @@ in the source). Use with care.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/pvcreate.8_pregen b/man/pvcreate.8_pregen
index 6345b28..abceb82 100644
--- a/man/pvcreate.8_pregen
+++ b/man/pvcreate.8_pregen
@@ -137,6 +137,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -233,6 +237,13 @@ in the source). Use with care.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/pvdisplay.8_pregen b/man/pvdisplay.8_pregen
index 1e7ed4b..bbf09d8 100644
--- a/man/pvdisplay.8_pregen
+++ b/man/pvdisplay.8_pregen
@@ -158,6 +158,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -270,6 +274,13 @@ without clustered locking and clustered VGs are skipped.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--logonly\fP
 .br
 Suppress command report and display only log report.
diff --git a/man/pvmove.8_pregen b/man/pvmove.8_pregen
index cfc4549..cb121f2 100644
--- a/man/pvmove.8_pregen
+++ b/man/pvmove.8_pregen
@@ -129,6 +129,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -237,6 +241,13 @@ Report progress at regular intervals.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/pvremove.8_pregen b/man/pvremove.8_pregen
index 325654a..16a82ad 100644
--- a/man/pvremove.8_pregen
+++ b/man/pvremove.8_pregen
@@ -71,6 +71,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -128,6 +132,13 @@ Display help text.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/pvresize.8_pregen b/man/pvresize.8_pregen
index 09c81e4..7b61f81 100644
--- a/man/pvresize.8_pregen
+++ b/man/pvresize.8_pregen
@@ -66,6 +66,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -116,6 +120,13 @@ Display help text.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/pvs.8_pregen b/man/pvs.8_pregen
index 970c1f9..a2a62a6 100644
--- a/man/pvs.8_pregen
+++ b/man/pvs.8_pregen
@@ -162,6 +162,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -260,6 +264,13 @@ without clustered locking and clustered VGs are skipped.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--logonly\fP
 .br
 Suppress command report and display only log report.
diff --git a/man/pvscan.8_pregen b/man/pvscan.8_pregen
index ebd155f..230492b 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -210,6 +210,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -294,6 +298,13 @@ operations after locking failures.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/vgcfgbackup.8_pregen b/man/vgcfgbackup.8_pregen
index 6a56481..e9c42fe 100644
--- a/man/vgcfgbackup.8_pregen
+++ b/man/vgcfgbackup.8_pregen
@@ -97,6 +97,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -169,6 +173,13 @@ operations after locking failures.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/vgcfgrestore.8_pregen b/man/vgcfgrestore.8_pregen
index f4fe2e4..e028103 100644
--- a/man/vgcfgrestore.8_pregen
+++ b/man/vgcfgrestore.8_pregen
@@ -43,6 +43,10 @@ vgcfgrestore - Restore volume group configuration
 .ad b
 .br
 .ad l
+    \fB--lockopt\fP \fIString\fP
+.ad b
+.br
+.ad l
     \fB--longhelp\fP
 .ad b
 .br
@@ -185,6 +189,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -259,6 +267,13 @@ May be used with --file. Does not restore the VG.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index c1628a7..00cfc2b 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -547,10 +547,6 @@ Start the lockspace of a shared VG in lvmlockd.
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
 .ad b
 .br
-.ad l
-[    \fB--lockopt\fP \fIString\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -569,10 +565,6 @@ Stop the lockspace of a shared VG in lvmlockd.
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
 .ad b
 .br
-.ad l
-[    \fB--lockopt\fP \fIString\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -587,10 +579,6 @@ Change the lock type for a shared VG.
 \fBvgchange\fP \fB--locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP \fIVG\fP
 .br
 .RS 4
-.ad l
-[    \fB--lockopt\fP \fIString\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -641,6 +629,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
diff --git a/man/vgck.8_pregen b/man/vgck.8_pregen
index 9e3c2ef..83e4a19 100644
--- a/man/vgck.8_pregen
+++ b/man/vgck.8_pregen
@@ -66,6 +66,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -116,6 +120,13 @@ Display help text.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/vgconvert.8_pregen b/man/vgconvert.8_pregen
index c63bd50..6228087 100644
--- a/man/vgconvert.8_pregen
+++ b/man/vgconvert.8_pregen
@@ -90,6 +90,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -170,6 +174,13 @@ in the source). Use with care.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/vgcreate.8_pregen b/man/vgcreate.8_pregen
index 82d341c..ddad391 100644
--- a/man/vgcreate.8_pregen
+++ b/man/vgcreate.8_pregen
@@ -100,10 +100,6 @@ devices are also available with vgcreate.
 [    \fB--locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP ]
 .ad b
 .br
-.ad l
-[    \fB--lockopt\fP \fIString\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -148,6 +144,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
diff --git a/man/vgdisplay.8_pregen b/man/vgdisplay.8_pregen
index 2fffacb..dcf9934 100644
--- a/man/vgdisplay.8_pregen
+++ b/man/vgdisplay.8_pregen
@@ -153,6 +153,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -265,6 +269,13 @@ without clustered locking and clustered VGs are skipped.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--logonly\fP
 .br
 Suppress command report and display only log report.
diff --git a/man/vgexport.8_pregen b/man/vgexport.8_pregen
index ed292f8..74aa597 100644
--- a/man/vgexport.8_pregen
+++ b/man/vgexport.8_pregen
@@ -89,6 +89,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -144,6 +148,13 @@ Display help text.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/vgextend.8_pregen b/man/vgextend.8_pregen
index bc6d959..ee805a8 100644
--- a/man/vgextend.8_pregen
+++ b/man/vgextend.8_pregen
@@ -115,6 +115,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -204,6 +208,13 @@ in the source). Use with care.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/vgimport.8_pregen b/man/vgimport.8_pregen
index 7e0c3d6..71f9d56 100644
--- a/man/vgimport.8_pregen
+++ b/man/vgimport.8_pregen
@@ -90,6 +90,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -153,6 +157,13 @@ Display help text.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/vgimportclone.8_pregen b/man/vgimportclone.8_pregen
index 96c95f9..aab34f4 100644
--- a/man/vgimportclone.8_pregen
+++ b/man/vgimportclone.8_pregen
@@ -70,6 +70,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -137,6 +141,13 @@ will not be changed (nor will their associated PVs).
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/vgmerge.8_pregen b/man/vgmerge.8_pregen
index c3a9bc8..ab6873d 100644
--- a/man/vgmerge.8_pregen
+++ b/man/vgmerge.8_pregen
@@ -67,6 +67,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -130,6 +134,13 @@ Display merged destination VG like vgdisplay -v.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/vgmknodes.8_pregen b/man/vgmknodes.8_pregen
index b50b3dc..9588694 100644
--- a/man/vgmknodes.8_pregen
+++ b/man/vgmknodes.8_pregen
@@ -78,6 +78,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -135,6 +139,13 @@ operations after locking failures.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/vgreduce.8_pregen b/man/vgreduce.8_pregen
index 44a6ae0..ecc5aca 100644
--- a/man/vgreduce.8_pregen
+++ b/man/vgreduce.8_pregen
@@ -41,6 +41,10 @@ vgreduce - Remove physical volume(s) from a volume group
 .ad b
 .br
 .ad l
+    \fB--lockopt\fP \fIString\fP
+.ad b
+.br
+.ad l
     \fB--longhelp\fP
 .ad b
 .br
@@ -175,6 +179,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -245,6 +253,13 @@ Display help text.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/vgremove.8_pregen b/man/vgremove.8_pregen
index 5399848..f562991 100644
--- a/man/vgremove.8_pregen
+++ b/man/vgremove.8_pregen
@@ -81,6 +81,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -138,6 +142,13 @@ Display help text.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/vgrename.8_pregen b/man/vgrename.8_pregen
index 3570e87..1f8928e 100644
--- a/man/vgrename.8_pregen
+++ b/man/vgrename.8_pregen
@@ -94,6 +94,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -158,6 +162,13 @@ Display help text.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/vgs.8_pregen b/man/vgs.8_pregen
index 6bef89d..efceb4e 100644
--- a/man/vgs.8_pregen
+++ b/man/vgs.8_pregen
@@ -158,6 +158,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -255,6 +259,13 @@ without clustered locking and clustered VGs are skipped.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--logonly\fP
 .br
 Suppress command report and display only log report.
diff --git a/man/vgscan.8_pregen b/man/vgscan.8_pregen
index bd2f4d9..18b2990 100644
--- a/man/vgscan.8_pregen
+++ b/man/vgscan.8_pregen
@@ -77,6 +77,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -140,6 +144,13 @@ operations after locking failures.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.
diff --git a/man/vgsplit.8_pregen b/man/vgsplit.8_pregen
index d02e68a..210c266 100644
--- a/man/vgsplit.8_pregen
+++ b/man/vgsplit.8_pregen
@@ -114,6 +114,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--lockopt\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--longhelp\fP ]
 .ad b
 .br
@@ -198,6 +202,13 @@ Display help text.
 .ad b
 .HP
 .ad l
+\fB--lockopt\fP \fIString\fP
+.br
+Used to pass options for special cases to lvmlockd.
+See \fBlvmlockd\fP(8) for more information.
+.ad b
+.HP
+.ad l
 \fB--longhelp\fP
 .br
 Display long help text.


