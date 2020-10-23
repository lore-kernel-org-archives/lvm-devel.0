From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Oct 2020 23:43:29 +0000 (GMT)
Subject: master - man: regenerate
Message-ID: <20201023234329.BFEB33858003@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=edb55b767a45d6c7eb5194dea23c11b5ae5f71d3
Commit:        edb55b767a45d6c7eb5194dea23c11b5ae5f71d3
Parent:        413c88116dd1a2a922216fd640598812b93ae3c9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 19 12:34:36 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 24 01:42:16 2020 +0200

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
index 51172f243..e133387af 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -1176,9 +1176,8 @@ Input units are always treated as base two values, regardless of
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
index 9e22c85ff..a47ccac08 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -1788,9 +1788,8 @@ Input units are always treated as base two values, regardless of
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
index ee6903431..716db5053 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -1944,9 +1944,8 @@ Input units are always treated as base two values, regardless of
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
index 4ba8dff18..9751b7656 100644
--- a/man/lvdisplay.8_pregen
+++ b/man/lvdisplay.8_pregen
@@ -497,9 +497,8 @@ Input units are always treated as base two values, regardless of
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
index b7e4bca4b..3dd4d0f3f 100644
--- a/man/lvextend.8_pregen
+++ b/man/lvextend.8_pregen
@@ -652,9 +652,8 @@ Input units are always treated as base two values, regardless of
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
index 07e618a82..b6212a6f0 100644
--- a/man/lvm-fullreport.8_pregen
+++ b/man/lvm-fullreport.8_pregen
@@ -462,9 +462,8 @@ Input units are always treated as base two values, regardless of
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
index d491e77ea..bbfa1216d 100644
--- a/man/lvm-lvpoll.8_pregen
+++ b/man/lvm-lvpoll.8_pregen
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
diff --git a/man/lvmconfig.8_pregen b/man/lvmconfig.8_pregen
index 7f8e6c6e5..b2ab265ca 100644
--- a/man/lvmconfig.8_pregen
+++ b/man/lvmconfig.8_pregen
@@ -469,9 +469,8 @@ Input units are always treated as base two values, regardless of
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
index 91a456712..62dc2afdd 100644
--- a/man/lvmdiskscan.8_pregen
+++ b/man/lvmdiskscan.8_pregen
@@ -221,9 +221,8 @@ Input units are always treated as base two values, regardless of
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
index 450ae80c7..9e3dbfe87 100644
--- a/man/lvreduce.8_pregen
+++ b/man/lvreduce.8_pregen
@@ -323,9 +323,8 @@ Input units are always treated as base two values, regardless of
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
index 7798e132d..4635ec77c 100644
--- a/man/lvremove.8_pregen
+++ b/man/lvremove.8_pregen
@@ -314,9 +314,8 @@ Input units are always treated as base two values, regardless of
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
index 811f5a09b..1cfc887a8 100644
--- a/man/lvrename.8_pregen
+++ b/man/lvrename.8_pregen
@@ -250,9 +250,8 @@ Input units are always treated as base two values, regardless of
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
index f1a67c4d1..83b060d86 100644
--- a/man/lvresize.8_pregen
+++ b/man/lvresize.8_pregen
@@ -587,9 +587,8 @@ Input units are always treated as base two values, regardless of
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
index 8aea3566a..57b3736f9 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -493,9 +493,8 @@ Input units are always treated as base two values, regardless of
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
index af1142785..0b782fedf 100644
--- a/man/lvscan.8_pregen
+++ b/man/lvscan.8_pregen
@@ -257,9 +257,8 @@ Input units are always treated as base two values, regardless of
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
index 33c63dc32..234a114a9 100644
--- a/man/pvchange.8_pregen
+++ b/man/pvchange.8_pregen
@@ -366,9 +366,8 @@ Input units are always treated as base two values, regardless of
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
index 1800714a9..eac6634ce 100644
--- a/man/pvck.8_pregen
+++ b/man/pvck.8_pregen
@@ -548,9 +548,8 @@ Input units are always treated as base two values, regardless of
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
index aa893f4f1..781762521 100644
--- a/man/pvcreate.8_pregen
+++ b/man/pvcreate.8_pregen
@@ -479,9 +479,8 @@ Input units are always treated as base two values, regardless of
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
index ef225cfb6..7c4500131 100644
--- a/man/pvdisplay.8_pregen
+++ b/man/pvdisplay.8_pregen
@@ -484,9 +484,8 @@ Input units are always treated as base two values, regardless of
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
index e8413cb99..a34271ff8 100644
--- a/man/pvmove.8_pregen
+++ b/man/pvmove.8_pregen
@@ -356,9 +356,8 @@ Input units are always treated as base two values, regardless of
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
index 89f8c0d15..784fcbe12 100644
--- a/man/pvremove.8_pregen
+++ b/man/pvremove.8_pregen
@@ -232,9 +232,8 @@ Input units are always treated as base two values, regardless of
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
index 53ed2fda8..fc79a3a5f 100644
--- a/man/pvresize.8_pregen
+++ b/man/pvresize.8_pregen
@@ -227,9 +227,8 @@ Input units are always treated as base two values, regardless of
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
index 596f593af..d85ae6cda 100644
--- a/man/pvs.8_pregen
+++ b/man/pvs.8_pregen
@@ -483,9 +483,8 @@ Input units are always treated as base two values, regardless of
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
index 94c42684f..27e1a773e 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -397,9 +397,8 @@ Input units are always treated as base two values, regardless of
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
index 73a086863..6401ee4fb 100644
--- a/man/vgcfgbackup.8_pregen
+++ b/man/vgcfgbackup.8_pregen
@@ -278,9 +278,8 @@ Input units are always treated as base two values, regardless of
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
index 71d2adab6..a174d7642 100644
--- a/man/vgcfgrestore.8_pregen
+++ b/man/vgcfgrestore.8_pregen
@@ -362,9 +362,8 @@ Input units are always treated as base two values, regardless of
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
index 10cf8a7ae..9016e76dd 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -1079,9 +1079,8 @@ Input units are always treated as base two values, regardless of
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
index 2a1ec2364..9226dc4a6 100644
--- a/man/vgck.8_pregen
+++ b/man/vgck.8_pregen
@@ -252,9 +252,8 @@ Input units are always treated as base two values, regardless of
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
index 48cf5e55d..09b6f1d31 100644
--- a/man/vgconvert.8_pregen
+++ b/man/vgconvert.8_pregen
@@ -294,9 +294,8 @@ Input units are always treated as base two values, regardless of
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
index d8ebc2ae3..adef80999 100644
--- a/man/vgcreate.8_pregen
+++ b/man/vgcreate.8_pregen
@@ -497,9 +497,8 @@ Input units are always treated as base two values, regardless of
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
index e65a53a62..f7db557b7 100644
--- a/man/vgdisplay.8_pregen
+++ b/man/vgdisplay.8_pregen
@@ -467,9 +467,8 @@ Input units are always treated as base two values, regardless of
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
index 5018efd0e..a9a9dc6fb 100644
--- a/man/vgexport.8_pregen
+++ b/man/vgexport.8_pregen
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
diff --git a/man/vgextend.8_pregen b/man/vgextend.8_pregen
index d2b4f7e56..40a34d9e0 100644
--- a/man/vgextend.8_pregen
+++ b/man/vgextend.8_pregen
@@ -363,9 +363,8 @@ Input units are always treated as base two values, regardless of
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
index 03b7bdcb2..b82a1847e 100644
--- a/man/vgimport.8_pregen
+++ b/man/vgimport.8_pregen
@@ -275,9 +275,8 @@ Input units are always treated as base two values, regardless of
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
index 11b8e7c0a..8cb048ffa 100644
--- a/man/vgimportclone.8_pregen
+++ b/man/vgimportclone.8_pregen
@@ -230,9 +230,8 @@ Input units are always treated as base two values, regardless of
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
index b964e3a7b..03aa096eb 100644
--- a/man/vgmerge.8_pregen
+++ b/man/vgmerge.8_pregen
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
diff --git a/man/vgmknodes.8_pregen b/man/vgmknodes.8_pregen
index 199e7eb3e..4243b0923 100644
--- a/man/vgmknodes.8_pregen
+++ b/man/vgmknodes.8_pregen
@@ -252,9 +252,8 @@ Input units are always treated as base two values, regardless of
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
index 7aed4d8b9..1f1d8d94e 100644
--- a/man/vgreduce.8_pregen
+++ b/man/vgreduce.8_pregen
@@ -382,9 +382,8 @@ Input units are always treated as base two values, regardless of
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
index 703f3ba76..c715742ad 100644
--- a/man/vgremove.8_pregen
+++ b/man/vgremove.8_pregen
@@ -269,9 +269,8 @@ Input units are always treated as base two values, regardless of
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
index 8085e0619..b9ac143e5 100644
--- a/man/vgrename.8_pregen
+++ b/man/vgrename.8_pregen
@@ -256,9 +256,8 @@ Input units are always treated as base two values, regardless of
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
index 8726909f7..f50e43fbd 100644
--- a/man/vgs.8_pregen
+++ b/man/vgs.8_pregen
@@ -464,9 +464,8 @@ Input units are always treated as base two values, regardless of
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
index 68050c916..5d329f921 100644
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
index f76a4db88..3adb0510f 100644
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


