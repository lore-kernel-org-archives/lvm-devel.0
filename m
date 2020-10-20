From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Oct 2020 21:25:07 +0000 (GMT)
Subject: stable-2.02 - man: regenerate
Message-ID: <20201020212507.A0C0539490A1@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b9d2aa9488931203f851d93324485b26375b9742
Commit:        b9d2aa9488931203f851d93324485b26375b9742
Parent:        50621533ddb143a41d2dd5f1bd85f8d45c6581fe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 19 12:34:36 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 20 22:41:34 2020 +0200

man: regenerate

---
 man/lvchange.8_pregen       | 5 ++---
 man/lvconvert.8_pregen      | 5 ++---
 man/lvcreate.8_pregen       | 5 ++---
 man/lvdisplay.8_pregen      | 5 ++---
 man/lvextend.8_pregen       | 5 ++---
 man/lvm-fullreport.8_pregen | 5 ++---
 man/lvm-lvpoll.8_pregen     | 5 ++---
 man/lvmconfig.8_pregen      | 5 ++---
 man/lvmdiskscan.8_pregen    | 5 ++---
 man/lvreduce.8_pregen       | 5 ++---
 man/lvremove.8_pregen       | 5 ++---
 man/lvrename.8_pregen       | 5 ++---
 man/lvresize.8_pregen       | 5 ++---
 man/lvs.8_pregen            | 5 ++---
 man/lvscan.8_pregen         | 5 ++---
 man/pvchange.8_pregen       | 5 ++---
 man/pvck.8_pregen           | 5 ++---
 man/pvcreate.8_pregen       | 5 ++---
 man/pvdisplay.8_pregen      | 5 ++---
 man/pvmove.8_pregen         | 5 ++---
 man/pvremove.8_pregen       | 5 ++---
 man/pvresize.8_pregen       | 5 ++---
 man/pvs.8_pregen            | 5 ++---
 man/pvscan.8_pregen         | 5 ++---
 man/vgcfgbackup.8_pregen    | 5 ++---
 man/vgcfgrestore.8_pregen   | 5 ++---
 man/vgchange.8_pregen       | 5 ++---
 man/vgck.8_pregen           | 5 ++---
 man/vgconvert.8_pregen      | 5 ++---
 man/vgcreate.8_pregen       | 5 ++---
 man/vgdisplay.8_pregen      | 5 ++---
 man/vgexport.8_pregen       | 5 ++---
 man/vgextend.8_pregen       | 5 ++---
 man/vgimport.8_pregen       | 5 ++---
 man/vgimportclone.8_pregen  | 5 ++---
 man/vgmerge.8_pregen        | 5 ++---
 man/vgmknodes.8_pregen      | 5 ++---
 man/vgreduce.8_pregen       | 5 ++---
 man/vgremove.8_pregen       | 5 ++---
 man/vgrename.8_pregen       | 5 ++---
 man/vgs.8_pregen            | 5 ++---
 man/vgscan.8_pregen         | 5 ++---
 man/vgsplit.8_pregen        | 5 ++---
 43 files changed, 86 insertions(+), 129 deletions(-)

diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index 5c3b6e59c..115a2038b 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -1130,9 +1130,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index e6de8f016..94ad90370 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -1499,9 +1499,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index 9dcb33fbc..3f1e21af1 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -1562,9 +1562,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/lvdisplay.8_pregen b/man/lvdisplay.8_pregen
index 33e4f5d25..f3301d3f7 100644
--- a/man/lvdisplay.8_pregen
+++ b/man/lvdisplay.8_pregen
@@ -501,9 +501,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/lvextend.8_pregen b/man/lvextend.8_pregen
index 130672efa..48fb9d940 100644
--- a/man/lvextend.8_pregen
+++ b/man/lvextend.8_pregen
@@ -637,9 +637,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/lvm-fullreport.8_pregen b/man/lvm-fullreport.8_pregen
index 3fb00b185..e0f30b44f 100644
--- a/man/lvm-fullreport.8_pregen
+++ b/man/lvm-fullreport.8_pregen
@@ -486,9 +486,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/lvm-lvpoll.8_pregen b/man/lvm-lvpoll.8_pregen
index 4591a289e..e22d325fd 100644
--- a/man/lvm-lvpoll.8_pregen
+++ b/man/lvm-lvpoll.8_pregen
@@ -236,9 +236,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/lvmconfig.8_pregen b/man/lvmconfig.8_pregen
index b47d589f6..4c040c2dc 100644
--- a/man/lvmconfig.8_pregen
+++ b/man/lvmconfig.8_pregen
@@ -459,9 +459,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/lvmdiskscan.8_pregen b/man/lvmdiskscan.8_pregen
index 8b26d955c..8f4f1a4dd 100644
--- a/man/lvmdiskscan.8_pregen
+++ b/man/lvmdiskscan.8_pregen
@@ -214,9 +214,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/lvreduce.8_pregen b/man/lvreduce.8_pregen
index 3aa4b5af1..b97ef9a85 100644
--- a/man/lvreduce.8_pregen
+++ b/man/lvreduce.8_pregen
@@ -313,9 +313,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/lvremove.8_pregen b/man/lvremove.8_pregen
index 88d0501bb..c5b6f7a70 100644
--- a/man/lvremove.8_pregen
+++ b/man/lvremove.8_pregen
@@ -304,9 +304,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/lvrename.8_pregen b/man/lvrename.8_pregen
index 69711e0c5..b7675bb1c 100644
--- a/man/lvrename.8_pregen
+++ b/man/lvrename.8_pregen
@@ -240,9 +240,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/lvresize.8_pregen b/man/lvresize.8_pregen
index 8df157a56..252171691 100644
--- a/man/lvresize.8_pregen
+++ b/man/lvresize.8_pregen
@@ -572,9 +572,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index c6303bb66..c3f50005e 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -517,9 +517,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/lvscan.8_pregen b/man/lvscan.8_pregen
index e9d90ee72..4f8a81a58 100644
--- a/man/lvscan.8_pregen
+++ b/man/lvscan.8_pregen
@@ -277,9 +277,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/pvchange.8_pregen b/man/pvchange.8_pregen
index 6a80e7252..493729cc2 100644
--- a/man/pvchange.8_pregen
+++ b/man/pvchange.8_pregen
@@ -371,9 +371,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/pvck.8_pregen b/man/pvck.8_pregen
index 1140d69cd..2b39dda80 100644
--- a/man/pvck.8_pregen
+++ b/man/pvck.8_pregen
@@ -203,9 +203,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/pvcreate.8_pregen b/man/pvcreate.8_pregen
index c4b03da71..a71638c6e 100644
--- a/man/pvcreate.8_pregen
+++ b/man/pvcreate.8_pregen
@@ -411,9 +411,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/pvdisplay.8_pregen b/man/pvdisplay.8_pregen
index bbf09d894..86a34a9f7 100644
--- a/man/pvdisplay.8_pregen
+++ b/man/pvdisplay.8_pregen
@@ -488,9 +488,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/pvmove.8_pregen b/man/pvmove.8_pregen
index cb121f24a..af8d18dc3 100644
--- a/man/pvmove.8_pregen
+++ b/man/pvmove.8_pregen
@@ -346,9 +346,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/pvremove.8_pregen b/man/pvremove.8_pregen
index 16a82adcc..ae55512ea 100644
--- a/man/pvremove.8_pregen
+++ b/man/pvremove.8_pregen
@@ -222,9 +222,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/pvresize.8_pregen b/man/pvresize.8_pregen
index 7b61f811f..d43b2df5d 100644
--- a/man/pvresize.8_pregen
+++ b/man/pvresize.8_pregen
@@ -217,9 +217,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/pvs.8_pregen b/man/pvs.8_pregen
index a2a62a67d..9a2ca0e57 100644
--- a/man/pvs.8_pregen
+++ b/man/pvs.8_pregen
@@ -507,9 +507,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/pvscan.8_pregen b/man/pvscan.8_pregen
index 230492b3a..64da94d3c 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -418,9 +418,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/vgcfgbackup.8_pregen b/man/vgcfgbackup.8_pregen
index e9c42feb1..e08b37e9d 100644
--- a/man/vgcfgbackup.8_pregen
+++ b/man/vgcfgbackup.8_pregen
@@ -271,9 +271,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/vgcfgrestore.8_pregen b/man/vgcfgrestore.8_pregen
index cffd44b68..816d2ffa9 100644
--- a/man/vgcfgrestore.8_pregen
+++ b/man/vgcfgrestore.8_pregen
@@ -348,9 +348,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index 00cfc2bd5..b7478cecf 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -1095,9 +1095,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/vgck.8_pregen b/man/vgck.8_pregen
index 83e4a1916..c570afd99 100644
--- a/man/vgck.8_pregen
+++ b/man/vgck.8_pregen
@@ -209,9 +209,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/vgconvert.8_pregen b/man/vgconvert.8_pregen
index 5e7f8a95c..83fa8d10b 100644
--- a/man/vgconvert.8_pregen
+++ b/man/vgconvert.8_pregen
@@ -283,9 +283,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/vgcreate.8_pregen b/man/vgcreate.8_pregen
index 09bf1260a..a9e9b5f1e 100644
--- a/man/vgcreate.8_pregen
+++ b/man/vgcreate.8_pregen
@@ -486,9 +486,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/vgdisplay.8_pregen b/man/vgdisplay.8_pregen
index dcf993420..1cb4fba6d 100644
--- a/man/vgdisplay.8_pregen
+++ b/man/vgdisplay.8_pregen
@@ -471,9 +471,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/vgexport.8_pregen b/man/vgexport.8_pregen
index 1dd715e67..579c227c3 100644
--- a/man/vgexport.8_pregen
+++ b/man/vgexport.8_pregen
@@ -267,9 +267,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/vgextend.8_pregen b/man/vgextend.8_pregen
index a6a30e92d..eb0a96ad4 100644
--- a/man/vgextend.8_pregen
+++ b/man/vgextend.8_pregen
@@ -354,9 +354,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/vgimport.8_pregen b/man/vgimport.8_pregen
index 71f9d56c9..f7b1e9077 100644
--- a/man/vgimport.8_pregen
+++ b/man/vgimport.8_pregen
@@ -265,9 +265,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/vgimportclone.8_pregen b/man/vgimportclone.8_pregen
index aab34f4d8..f52f5a62a 100644
--- a/man/vgimportclone.8_pregen
+++ b/man/vgimportclone.8_pregen
@@ -220,9 +220,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/vgmerge.8_pregen b/man/vgmerge.8_pregen
index ab6873dd3..03d7398df 100644
--- a/man/vgmerge.8_pregen
+++ b/man/vgmerge.8_pregen
@@ -207,9 +207,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/vgmknodes.8_pregen b/man/vgmknodes.8_pregen
index 958869490..9713e0e29 100644
--- a/man/vgmknodes.8_pregen
+++ b/man/vgmknodes.8_pregen
@@ -242,9 +242,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/vgreduce.8_pregen b/man/vgreduce.8_pregen
index ecc5aca50..aff8e8f78 100644
--- a/man/vgreduce.8_pregen
+++ b/man/vgreduce.8_pregen
@@ -368,9 +368,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/vgremove.8_pregen b/man/vgremove.8_pregen
index f56299184..a13109afb 100644
--- a/man/vgremove.8_pregen
+++ b/man/vgremove.8_pregen
@@ -259,9 +259,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/vgrename.8_pregen b/man/vgrename.8_pregen
index 1f8928e91..eb702449d 100644
--- a/man/vgrename.8_pregen
+++ b/man/vgrename.8_pregen
@@ -246,9 +246,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/vgs.8_pregen b/man/vgs.8_pregen
index efceb4ed1..63a7db519 100644
--- a/man/vgs.8_pregen
+++ b/man/vgs.8_pregen
@@ -488,9 +488,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/vgscan.8_pregen b/man/vgscan.8_pregen
index 18b299072..49c0b1c7a 100644
--- a/man/vgscan.8_pregen
+++ b/man/vgscan.8_pregen
@@ -239,9 +239,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
diff --git a/man/vgsplit.8_pregen b/man/vgsplit.8_pregen
index 6c3e6ec16..78a0b346c 100644
--- a/man/vgsplit.8_pregen
+++ b/man/vgsplit.8_pregen
@@ -332,9 +332,8 @@ Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
 UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
+b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
+m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES


