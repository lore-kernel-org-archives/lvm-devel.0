From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Apr 2021 13:01:01 +0000 (GMT)
Subject: main - make: generate
Message-ID: <20210419130101.849D5396903C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5eac292925ca96bee9a1f50355ca0e8b0ef4a9a6
Commit:        5eac292925ca96bee9a1f50355ca0e8b0ef4a9a6
Parent:        d1f8978ac5adbe7274faa62011dbb30a95719191
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 15 20:11:52 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 19 14:54:37 2021 +0200

make: generate

---
 man/lvchange.8_pregen        |  664 +++++---------
 man/lvconvert.8_pregen       | 1449 +++++++++++--------------------
 man/lvcreate.8_pregen        | 1945 +++++++++++-------------------------------
 man/lvdisplay.8_pregen       |  358 +++-----
 man/lvextend.8_pregen        |  454 +++-------
 man/lvm-fullreport.8_pregen  |  334 +++-----
 man/lvm-lvpoll.8_pregen      |  266 ++----
 man/lvmconfig.8_pregen       |  317 ++-----
 man/lvmdevices.8_pregen      |  351 +++-----
 man/lvmdiskscan.8_pregen     |  220 ++---
 man/lvreduce.8_pregen        |  263 ++----
 man/lvremove.8_pregen        |  277 ++----
 man/lvrename.8_pregen        |  250 ++----
 man/lvresize.8_pregen        |  407 +++------
 man/lvs.8_pregen             |  438 +++-------
 man/lvscan.8_pregen          |  234 ++---
 man/pvchange.8_pregen        |  272 ++----
 man/pvck.8_pregen            |  389 +++------
 man/pvcreate.8_pregen        |  329 ++-----
 man/pvdisplay.8_pregen       |  346 +++-----
 man/pvmove.8_pregen          |  367 ++------
 man/pvremove.8_pregen        |  228 ++---
 man/pvresize.8_pregen        |  236 ++---
 man/pvs.8_pregen             |  353 +++-----
 man/pvscan.8_pregen          |  303 ++-----
 man/vgcfgbackup.8_pregen     |  247 ++----
 man/vgcfgrestore.8_pregen    |  308 ++-----
 man/vgchange.8_pregen        |  610 ++++---------
 man/vgck.8_pregen            |  236 ++---
 man/vgconvert.8_pregen       |  250 ++----
 man/vgcreate.8_pregen        |  349 ++------
 man/vgdisplay.8_pregen       |  341 +++-----
 man/vgexport.8_pregen        |  250 ++----
 man/vgextend.8_pregen        |  288 ++-----
 man/vgimport.8_pregen        |  249 ++----
 man/vgimportclone.8_pregen   |  237 ++---
 man/vgimportdevices.8_pregen |  250 ++----
 man/vgmerge.8_pregen         |  228 ++---
 man/vgmknodes.8_pregen       |  241 ++----
 man/vgreduce.8_pregen        |  306 ++-----
 man/vgremove.8_pregen        |  248 ++----
 man/vgrename.8_pregen        |  247 ++----
 man/vgs.8_pregen             |  355 +++-----
 man/vgscan.8_pregen          |  229 ++---
 man/vgsplit.8_pregen         |  277 ++----
 45 files changed, 4733 insertions(+), 12063 deletions(-)

diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index 93c7311b5..3cfa7330d 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -1,8 +1,11 @@
 .TH LVCHANGE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-lvchange - Change the attributes of logical volume(s)
+.
+lvchange \(em Change the attributes of logical volume(s)
 .
 .SH SYNOPSIS
+.
 \fBlvchange\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
@@ -10,250 +13,136 @@ lvchange - Change the attributes of logical volume(s)
 .P
 .ad l
  \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
-.ad b
 .br
-.ad l
     \fB--activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP
-.ad b
 .br
-.ad l
     \fB--addtag\fP \fITag\fP
-.ad b
 .br
-.ad l
-    \fB--alloc\fP 
+    \fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
-.ad b
 .br
-.ad l
  \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
-.ad b
 .br
-.ad l
     \fB--cachepolicy\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--cachesettings\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--commandprofile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--compression\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--config\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
  \fB-d\fP|\fB--debug\fP
-.ad b
 .br
-.ad l
     \fB--deduplication\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--deltag\fP \fITag\fP
-.ad b
 .br
-.ad l
     \fB--detachprofile\fP
-.ad b
 .br
-.ad l
     \fB--devices\fP \fIPV\fP
-.ad b
 .br
-.ad l
     \fB--devicesfile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
-.ad b
 .br
-.ad l
     \fB--driverloaded\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--errorwhenfull\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
  \fB-f\fP|\fB--force\fP
-.ad b
 .br
-.ad l
  \fB-h\fP|\fB--help\fP
-.ad b
 .br
-.ad l
  \fB-K\fP|\fB--ignoreactivationskip\fP
-.ad b
 .br
-.ad l
     \fB--ignorelockingfailure\fP
-.ad b
 .br
-.ad l
     \fB--ignoremonitoring\fP
-.ad b
 .br
-.ad l
     \fB--lockopt\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--longhelp\fP
-.ad b
 .br
-.ad l
  \fB-j\fP|\fB--major\fP \fINumber\fP
-.ad b
 .br
-.ad l
-    \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT]
-.ad b
+    \fB--\fP[\fBraid\fP]\fBmaxrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
-.ad l
     \fB--metadataprofile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--minor\fP \fINumber\fP
-.ad b
 .br
-.ad l
-    \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT]
-.ad b
+    \fB--\fP[\fBraid\fP]\fBminrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
-.ad l
     \fB--monitor\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--nolocking\fP
-.ad b
 .br
-.ad l
     \fB--noudevsync\fP
-.ad b
 .br
-.ad l
  \fB-P\fP|\fB--partial\fP
-.ad b
 .br
-.ad l
  \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP
-.ad b
 .br
-.ad l
  \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--poll\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--profile\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-q\fP|\fB--quiet\fP
-.ad b
 .br
-.ad l
  \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
-.ad b
 .br
-.ad l
     \fB--readonly\fP
-.ad b
 .br
-.ad l
     \fB--rebuild\fP \fIPV\fP
-.ad b
 .br
-.ad l
     \fB--refresh\fP
-.ad b
 .br
-.ad l
     \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
-.ad b
 .br
-.ad l
     \fB--resync\fP
-.ad b
 .br
-.ad l
  \fB-S\fP|\fB--select\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--setautoactivation\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
-    \fB--[raid]syncaction\fP \fBcheck\fP|\fBrepair\fP
-.ad b
+    \fB--\fP[\fBraid\fP]\fBsyncaction\fP \fBcheck\fP|\fBrepair\fP
 .br
-.ad l
     \fB--sysinit\fP
-.ad b
 .br
-.ad l
  \fB-t\fP|\fB--test\fP
-.ad b
 .br
-.ad l
  \fB-v\fP|\fB--verbose\fP
-.ad b
 .br
-.ad l
     \fB--version\fP
-.ad b
 .br
-.ad l
-    \fB--[raid]writebehind\fP \fINumber\fP
-.ad b
+    \fB--\fP[\fBraid\fP]\fBwritebehind\fP \fINumber\fP
 .br
-.ad l
-    \fB--[raid]writemostly\fP \fIPV\fP[\fB:t\fP|\fBn\fP|\fBy\fP]
-.ad b
+    \fB--\fP[\fBraid\fP]\fBwritemostly\fP \fIPV\fP[\fB:t\fP|\fBn\fP|\fBy\fP]
 .br
-.ad l
  \fB-y\fP|\fB--yes\fP
-.ad b
 .br
-.ad l
  \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .ad b
+.
 .SH DESCRIPTION
+.
 lvchange changes LV attributes in the VG, changes LV activation in the
 kernel, and includes other utilities for LV maintenance.
+.
 .SH USAGE
+.
 Change a general LV attribute. 
 .br
 For options listed in parentheses, any one is 
@@ -279,9 +168,9 @@ required, after which the others are optional.
 .br
      \fB--deltag\fP \fITag\fP
 .br
-     \fB--alloc\fP 
+     \fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
 .br
      \fB--compression\fP \fBy\fP|\fBn\fP
@@ -306,13 +195,13 @@ required, after which the others are optional.
 .br
      \fB--cachesettings\fP \fIString\fP
 .br
-     \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT]
+     \fB--\fP[\fBraid\fP]\fBminrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
-     \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT]
+     \fB--\fP[\fBraid\fP]\fBmaxrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
-     \fB--[raid]writebehind\fP \fINumber\fP
+     \fB--\fP[\fBraid\fP]\fBwritebehind\fP \fINumber\fP
 .br
-     \fB--[raid]writemostly\fP \fIPV\fP[\fB:t\fP|\fBn\fP|\fBy\fP] )
+     \fB--\fP[\fBraid\fP]\fBwritemostly\fP \fIPV\fP[\fB:t\fP|\fBn\fP|\fBy\fP] )
 .RE
 .RS 4
  \fIVG\fP|\fILV\fP|\fITag\fP|\fISelect\fP ...
@@ -321,60 +210,72 @@ required, after which the others are optional.
 .RS 4
 .ad l
 [ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poll\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Resyncronize a mirror or raid LV. 
 .br
 Use to reset 'R' attribute on a not initially synchronized LV.
 .br
 .P
-\fBlvchange\fP \fB--resync\fP \fIVG\fP|\fILV\fP\fI_mirror_raid\fP|\fITag\fP|\fISelect\fP ...
+\fBlvchange\fP \fB--resync\fP \fIVG\fP|\fILV1\fP|\fITag\fP|\fISelect\fP ...
 .br
 .RS 4
 .ad l
 [ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: mirror raid
+.RE
+.P
+\(em
+.P
 Resynchronize or check a raid LV.
 .br
 .P
-\fBlvchange\fP \fB--syncaction\fP \fBcheck\fP|\fBrepair\fP \fIVG\fP|\fILV\fP\fI_raid\fP|\fITag\fP|\fISelect\fP ...
+\fBlvchange\fP \fB--syncaction\fP \fBcheck\fP|\fBrepair\fP \fIVG\fP|\fILV1\fP|\fITag\fP|\fISelect\fP ...
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: raid
+.RE
+.P
+\(em
+.P
 Reconstruct data on specific PVs of a raid LV.
 .br
 .P
-\fBlvchange\fP \fB--rebuild\fP \fIPV\fP \fIVG\fP|\fILV\fP\fI_raid\fP|\fITag\fP|\fISelect\fP ...
+\fBlvchange\fP \fB--rebuild\fP \fIPV\fP \fIVG\fP|\fILV1\fP|\fITag\fP|\fISelect\fP ...
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: raid
+.RE
+.P
+\(em
+.P
 Activate or deactivate an LV.
 .br
 .P
@@ -383,41 +284,27 @@ Activate or deactivate an LV.
 .RS 4
 .ad l
 [ \fB-P\fP|\fB--partial\fP ]
-.ad b
 .br
-.ad l
 [ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
 .br
-.ad l
 [    \fB--activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poll\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--ignorelockingfailure\fP ]
-.ad b
 .br
-.ad l
 [    \fB--sysinit\fP ]
-.ad b
 .br
-.ad l
 [    \fB--readonly\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Reactivate an LV using the latest metadata.
 .br
 .P
@@ -426,36 +313,32 @@ Reactivate an LV using the latest metadata.
 .RS 4
 .ad l
 [ \fB-P\fP|\fB--partial\fP ]
-.ad b
 .br
-.ad l
 [    \fB--activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poll\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Start or stop monitoring an LV from dmeventd.
 .br
 .P
 \fBlvchange\fP \fB--monitor\fP \fBy\fP|\fBn\fP \fIVG\fP|\fILV\fP|\fITag\fP|\fISelect\fP ...
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Start or stop processing an LV conversion.
 .br
 .P
@@ -464,13 +347,13 @@ Start or stop processing an LV conversion.
 .RS 4
 .ad l
 [    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Make the minor device number persistent for an LV.
 .br
 .P
@@ -479,126 +362,81 @@ Make the minor device number persistent for an LV.
 .RS 4
 .ad l
 [ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poll\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Common options for command:
 .
 .RS 4
 .ad l
 [ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-f\fP|\fB--force\fP ]
-.ad b
 .br
-.ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--ignoremonitoring\fP ]
-.ad b
 .br
-.ad l
 [    \fB--noudevsync\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .br
-.ad b
 Change the active state of LVs.
 An active LV can be used through a block device,
 allowing data on the LV to be accessed.
@@ -616,18 +454,17 @@ activation commands.  By default, LVs are autoactivated.
 An autoactivation property can be set on a VG or LV to disable autoactivation,
 see --setautoactivation y|n in vgchange, lvchange, vgcreate, and lvcreate.
 Display the property with vgs or lvs "-o autoactivation".
-The lvm.conf auto_activation_volume_list includes names of VGs or LVs
+The \fBlvm.conf\fP(5) auto_activation_volume_list includes names of VGs or LVs
 that should be autoactivated, and anything not listed is not autoactivated.
 When auto_activation_volume_list is undefined (the default), it has no effect.
 If auto_activation_volume_list is defined and empty, no LVs are autoactivated.
 Items included by auto_activation_volume_list will not be autoactivated if
 the autoactivation property has been disabled.
 See \fBlvmlockd\fP(8) for more information about activation options \fBey\fP and \fBsy\fP for shared VGs.
+.
 .HP
-.ad l
 \fB--activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP
 .br
-.ad b
 Determines if LV activation is allowed when PVs are missing,
 e.g. because of a device failure.
 \fBcomplete\fP only allows LVs with no missing PVs to be activated,
@@ -636,23 +473,23 @@ and is the most restrictive mode.
 (This does not include the "mirror" type, see "raid1" instead.)
 \fBpartial\fP allows any LV with missing PVs to be activated, and
 should only be used for recovery or repair.
-For default, see lvm.conf/activation_mode.
+For default, see \fBlvm.conf\fP(5) activation_mode.
 See \fBlvmraid\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--addtag\fP \fITag\fP
 .br
-.ad b
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
+.
 .HP
 .ad l
-\fB--alloc\fP 
+\fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
-.br
 .ad b
+.br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
 which can be changed with vgchange/lvchange, or overridden on the
@@ -669,18 +506,16 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
+.
 .HP
-.ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
 .br
-.ad b
 Specifies when writes to a cache LV should be considered complete.
 \fBwriteback\fP considers a write complete as soon as it is
 stored in the cache pool.
@@ -692,18 +527,16 @@ cache pool LV. With \fBpassthrough\fP, all reads are served
 from the origin LV (all reads miss the cache) and all writes are
 forwarded to the origin LV; additionally, write hits cause cache
 block invalidates. See \fBlvmcache\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--cachepolicy\fP \fIString\fP
 .br
-.ad b
 Specifies the cache policy for a cache LV.
 See \fBlvmcache\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--cachesettings\fP \fIString\fP
 .br
-.ad b
 Specifies tunable values for a cache LV in "Key = Value" form.
 Repeat this option to specify multiple values.
 (The default values should usually be adequate.)
@@ -711,90 +544,79 @@ The special string value \fBdefault\fP switches
 settings back to their default kernel values and removes
 them from the list of settings stored in LVM metadata.
 See \fBlvmcache\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--compression\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Controls whether compression is enabled or disable for VDO volume.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Sets or resets the contiguous allocation policy for LVs.
 Default is no contiguous allocation based on a next free principle.
 It is only possible to change a non-contiguous allocation policy
 to contiguous if all of the allocated physical extents in the LV
 are already contiguous.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--deduplication\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Controls whether deduplication is enabled or disable for VDO volume.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
+.
 .HP
-.ad l
 \fB--deltag\fP \fITag\fP
 .br
-.ad b
 Deletes a tag from a PV, VG or LV. This option can be repeated to delete
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
+.
 .HP
-.ad l
 \fB--detachprofile\fP
 .br
-.ad b
 Detaches a metadata profile from a VG or LV.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .br
-.ad b
 Specifies how the device-mapper thin pool layer in the kernel should
 handle discards.
 \fBignore\fP causes the thin pool to ignore discards.
@@ -803,18 +625,16 @@ allow reuse of unneeded extents in the thin pool.
 \fBpassdown\fP causes the thin pool to process discards itself
 (like nopassdown) and pass the discards to the underlying device.
 See \fBlvmthin\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB--errorwhenfull\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Specifies thin pool behavior when data space is exhausted.
 When yes, device-mapper will immediately return an error
 when a thin pool is full and an I/O request requires space.
@@ -823,140 +643,121 @@ period of time to allow the thin pool to be extended.
 Errors are returned if no space is available after the timeout.
 (Also see dm-thin-pool kernel module option no_space_timeout.)
 See \fBlvmthin\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-f\fP|\fB--force\fP ...
 .br
-.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB-K\fP|\fB--ignoreactivationskip\fP
 .br
-.ad b
 Ignore the "activation skip" LV flag during activation
 to allow LVs with the flag set to be activated.
+.
 .HP
-.ad l
 \fB--ignorelockingfailure\fP
 .br
-.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
+.
 .HP
-.ad l
 \fB--ignoremonitoring\fP
 .br
-.ad b
 Do not interact with dmeventd unless --monitor is specified.
 Do not use this if dmeventd is already monitoring a device.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB-j\fP|\fB--major\fP \fINumber\fP
 .br
-.ad b
 Sets the major number of an LV block device.
+.
 .HP
-.ad l
-\fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT]
+\fB--\fP[\fBraid\fP]\fBmaxrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
-.ad b
 Sets the maximum recovery rate for a RAID LV.  The rate value
 is an amount of data per second for each device in the array.
 Setting the rate to 0 means it will be unbounded.
 See \fBlvmraid\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--metadataprofile\fP \fIString\fP
 .br
-.ad b
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--minor\fP \fINumber\fP
 .br
-.ad b
 Sets the minor number of an LV block device.
+.
 .HP
-.ad l
-\fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT]
+\fB--\fP[\fBraid\fP]\fBminrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
-.ad b
 Sets the minimum recovery rate for a RAID LV.  The rate value
 is an amount of data per second for each device in the array.
 Setting the rate to 0 means it will be unbounded.
 See \fBlvmraid\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--monitor\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Start (yes) or stop (no) monitoring an LV with dmeventd.
 dmeventd monitors kernel events for an LV, and performs
 automated maintenance for the LV in reponse to specific events.
 See \fBdmeventd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--noudevsync\fP
 .br
-.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
+.
 .HP
-.ad l
 \fB-P\fP|\fB--partial\fP
 .br
-.ad b
 Commands will do their best to activate LVs with missing PV extents.
 Missing extents may be replaced with error or zero segments
-according to the lvm.conf missing_stripe_filler setting.
+according to the  missing_stripe_filler setting.
 Metadata may not be changed with this option.
+.
 .HP
-.ad l
 \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP
 .br
-.ad b
 Set access permission to read only \fBr\fP or read and write \fBrw\fP.
+.
 .HP
-.ad l
 \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 When yes, makes the specified minor number persistent.
+.
 .HP
-.ad l
 \fB--poll\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 When yes, start the background transformation of an LV.
 An incomplete transformation, e.g. pvmove or lvconvert interrupted
 by reboot or crash, can be restarted from the last checkpoint with --poll y.
@@ -964,76 +765,68 @@ When no, background transformation of an LV will not occur, and the
 transformation will not complete. It may not be appropriate to immediately
 poll an LV after activation, in which case --poll n can be used to defer
 polling until a later --poll y command.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
 .br
-.ad b
 Sets read ahead sector count of an LV.
 \fBauto\fP is the default which allows the kernel to choose
 a suitable value automatically.
 \fBnone\fP is equivalent to zero.
+.
 .HP
-.ad l
 \fB--readonly\fP
 .br
-.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
+.
 .HP
-.ad l
 \fB--rebuild\fP \fIPV\fP
 .br
-.ad b
 Selects a PV to rebuild in a raid LV. Multiple PVs can be rebuilt by
 repeating this option.
 Use this option in place of --resync or --syncaction repair when the
 PVs with corrupted data are known, and their data should be reconstructed
 rather than reconstructing default (rotating) data.
 See \fBlvmraid\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--refresh\fP
 .br
-.ad b
 If the LV is active, reload its metadata.
 This is not necessary in normal operation, but may be useful
 if something has gone wrong, or if some form of manual LV
 sharing is being used.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--resync\fP
 .br
-.ad b
 Initiates mirror synchronization. Synchronization generally happens
 automatically, but this option forces it to run.
 Also see --rebuild to synchronize a specific PV.
@@ -1041,11 +834,10 @@ During synchronization, data is read from the primary mirror device
 and copied to the others. This can take considerable time, during
 which the LV is without a complete redundant copy of the data.
 See \fBlvmraid\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
-.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -1054,22 +846,20 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
+.
 .HP
-.ad l
 \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Persistently sets (yes) or clears (no) the "activation skip" flag on an LV.
 An LV with this flag set is not activated unless the
 --ignoreactivationskip option is used by the activation command.
 This flag is set by default on new thin snapshot LVs.
 The flag is not applied to deactivation.
 The current value of the flag is indicated in the lvs lv_attr bits.
+.
 .HP
-.ad l
 \fB--setautoactivation\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Set the autoactivation property on a VG or LV.
 Display the property with vgs or lvs "-o autoactivation".
 When the autoactivation property is disabled, the VG or LV
@@ -1079,23 +869,21 @@ If autoactivation is disabled on a VG, no LVs will be autoactivated
 in that VG, and the LV autoactivation property has no effect.
 If autoactivation is enabled on a VG, autoactivation can be disabled
 for individual LVs.
+.
 .HP
-.ad l
-\fB--[raid]syncaction\fP \fBcheck\fP|\fBrepair\fP
+\fB--\fP[\fBraid\fP]\fBsyncaction\fP \fBcheck\fP|\fBrepair\fP
 .br
-.ad b
 Initiate different types of RAID synchronization.
 This causes the RAID LV to read all data and parity
 blocks in the array and check for discrepancies
 (mismatches between mirrors or incorrect parity values).
 \fBcheck\fP will count but not correct discrepancies.
 \fBrepair\fP will correct discrepancies.
-See lvs for reporting discrepancies found or repaired.
+See \fBlvs\fP(8) for reporting discrepancies found or repaired.
+.
 .HP
-.ad l
 \fB--sysinit\fP
 .br
-.ad b
 Indicates that vgchange/lvchange is being invoked from early system initialisation
 scripts (e.g. rc.sysinit or an initrd), before writable filesystems are
 available. As such, some functionality needs to be disabled and this option
@@ -1103,45 +891,40 @@ acts as a shortcut which selects an appropriate set of options. Currently,
 this is equivalent to using --ignorelockingfailure, --ignoremonitoring,
 --poll n, and setting env var LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES.
 vgchange/lvchange skip autoactivation, and defer to pvscan autoactivation.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
-\fB--[raid]writebehind\fP \fINumber\fP
+\fB--\fP[\fBraid\fP]\fBwritebehind\fP \fINumber\fP
 .br
-.ad b
 The maximum number of outstanding writes that are allowed to
 devices in a RAID1 LV that is marked write-mostly.
 Once this value is exceeded, writes become synchronous (i.e. all writes
 to the constituent devices must complete before the array signals the
 write has completed). Setting the value to zero clears the preference
 and allows the system to choose the value arbitrarily.
+.
 .HP
-.ad l
-\fB--[raid]writemostly\fP \fIPV\fP[\fB:t\fP|\fBn\fP|\fBy\fP]
+\fB--\fP[\fBraid\fP]\fBwritemostly\fP \fIPV\fP[\fB:t\fP|\fBn\fP|\fBy\fP]
 .br
-.ad b
 Mark a device in a RAID1 LV as write-mostly.  All reads
 to these drives will be avoided unless absolutely necessary. This keeps
 the number of I/Os to the drive to a minimum. The default behavior is to
@@ -1150,133 +933,70 @@ It is also possible to remove the write-mostly flag by adding the
 suffix \fB:n\fP at the end of the PV name, or to toggle the value with
 the suffix \fB:t\fP. Repeat this option to change the attribute on
 multiple PVs.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .HP
-.ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Set zeroing mode for thin pool. Note: already provisioned blocks from pool
 in non-zero mode are not cleared in unwritten parts when setting --zero y.
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fILV\fP
-.br
+.TP
+.I LV
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-LV followed by _<type> indicates that an LV of the
-given type is required. (raid represents raid<N> type)
-.HP
-\fITag\fP
-.br
+LV1 indicates the LV must have a specific type, where the
+accepted LV types are listed. (raid represents raid<N> type).
+.TP
+.I Tag
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
-\fISelect\fP
-.br
+.TP
+.I Select
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH EXAMPLES
-Change LV permission to read-only:
-.sp
-.B lvchange -pr vg00/lvol1
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 03e6d62dd..a921438b6 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -1,8 +1,11 @@
 .TH LVCONVERT 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-lvconvert - Change logical volume layout
+.
+lvconvert \(em Change logical volume layout
 .
 .SH SYNOPSIS
+.
 \fBlvconvert\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
@@ -11,334 +14,196 @@ lvconvert - Change logical volume layout
 .br
 .P
 .ad l
-    \fB--alloc\fP 
+    \fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
-.ad b
 .br
-.ad l
  \fB-b\fP|\fB--background\fP
-.ad b
 .br
-.ad l
  \fB-H\fP|\fB--cache\fP
-.ad b
 .br
-.ad l
     \fB--cachedevice\fP \fIPV\fP
-.ad b
 .br
-.ad l
     \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP
-.ad b
 .br
-.ad l
     \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
-.ad b
 .br
-.ad l
     \fB--cachepolicy\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--cachepool\fP \fILV\fP
-.ad b
 .br
-.ad l
     \fB--cachesettings\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--cachesize\fP \fISize\fP[m|UNIT]
-.ad b
 .br
-.ad l
     \fB--cachevol\fP \fILV\fP
-.ad b
 .br
-.ad l
  \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT]
-.ad b
 .br
-.ad l
     \fB--commandprofile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--compression\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--config\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-d\fP|\fB--debug\fP
-.ad b
 .br
-.ad l
     \fB--deduplication\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--devices\fP \fIPV\fP
-.ad b
 .br
-.ad l
     \fB--devicesfile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
-.ad b
 .br
-.ad l
     \fB--driverloaded\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--errorwhenfull\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
  \fB-f\fP|\fB--force\fP
-.ad b
 .br
-.ad l
  \fB-h\fP|\fB--help\fP
-.ad b
 .br
-.ad l
  \fB-i\fP|\fB--interval\fP \fINumber\fP
-.ad b
 .br
-.ad l
     \fB--lockopt\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--longhelp\fP
-.ad b
 .br
-.ad l
     \fB--merge\fP
-.ad b
 .br
-.ad l
     \fB--mergemirrors\fP
-.ad b
 .br
-.ad l
     \fB--mergesnapshot\fP
-.ad b
 .br
-.ad l
     \fB--mergethin\fP
-.ad b
 .br
-.ad l
     \fB--metadataprofile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP
-.ad b
 .br
-.ad l
  \fB-m\fP|\fB--mirrors\fP [\fB+\fP|\fB-\fP]\fINumber\fP
-.ad b
 .br
-.ad l
  \fB-n\fP|\fB--name\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--nolocking\fP
-.ad b
 .br
-.ad l
     \fB--noudevsync\fP
-.ad b
 .br
-.ad l
     \fB--originname\fP \fILV\fP
-.ad b
 .br
-.ad l
     \fB--poolmetadata\fP \fILV\fP
-.ad b
 .br
-.ad l
     \fB--poolmetadatasize\fP \fISize\fP[m|UNIT]
-.ad b
 .br
-.ad l
     \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--profile\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-q\fP|\fB--quiet\fP
-.ad b
 .br
-.ad l
     \fB--raidintegrity\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--raidintegrityblocksize\fP \fINumber\fP
-.ad b
 .br
-.ad l
     \fB--raidintegritymode\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
-.ad b
 .br
-.ad l
  \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT]
-.ad b
 .br
-.ad l
     \fB--repair\fP
-.ad b
 .br
-.ad l
     \fB--replace\fP \fIPV\fP
-.ad b
 .br
-.ad l
  \fB-s\fP|\fB--snapshot\fP
-.ad b
 .br
-.ad l
     \fB--splitcache\fP
-.ad b
 .br
-.ad l
     \fB--splitmirrors\fP \fINumber\fP
-.ad b
 .br
-.ad l
     \fB--splitsnapshot\fP
-.ad b
 .br
-.ad l
     \fB--startpoll\fP
-.ad b
 .br
-.ad l
     \fB--stripes\fP \fINumber\fP
-.ad b
 .br
-.ad l
  \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
-.ad b
 .br
-.ad l
     \fB--swapmetadata\fP
-.ad b
 .br
-.ad l
  \fB-t\fP|\fB--test\fP
-.ad b
 .br
-.ad l
  \fB-T\fP|\fB--thin\fP
-.ad b
 .br
-.ad l
     \fB--thinpool\fP \fILV\fP
-.ad b
 .br
-.ad l
     \fB--trackchanges\fP
-.ad b
 .br
-.ad l
-    \fB--type\fP 
+    \fB--type\fP \c
 .nh
-\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
+\%\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
 .hy
-.ad b
 .br
-.ad l
     \fB--uncache\fP
-.ad b
 .br
-.ad l
     \fB--usepolicies\fP
-.ad b
 .br
-.ad l
     \fB--vdopool\fP \fILV\fP
-.ad b
 .br
-.ad l
  \fB-v\fP|\fB--verbose\fP
-.ad b
 .br
-.ad l
     \fB--version\fP
-.ad b
 .br
-.ad l
  \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
-.ad b
 .br
-.ad l
  \fB-y\fP|\fB--yes\fP
-.ad b
 .br
-.ad l
  \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .ad b
+.
 .SH DESCRIPTION
+.
 lvconvert changes the LV type and includes utilities for LV data
 maintenance. The LV type controls data layout and redundancy.
 The LV type is also called the segment type or segtype.
-
+.P
 To display the current LV type, run the command:
-
+.P
 .B lvs -o name,segtype
 .I LV
-
+.P
 In some cases, an LV is a single device mapper (dm) layer above physical
 devices.  In other cases, hidden LVs (dm devices) are layered between the
 visible LV and physical devices.  LVs in the middle layers are called sub LVs.
 A command run on a visible LV sometimes operates on a sub LV rather than
 the specified LV.  In other cases, a sub LV must be specified directly on
 the command line.
-
+.P
 Sub LVs can be displayed with the command:
-
+.P
 .B lvs -a
-
+.P
 The
 .B linear
 type is equivalent to the
 .B striped
 type when one stripe exists.
 In that case, the types can sometimes be used interchangably.
-
+.P
 In most cases, the
 .B mirror
 type is deprecated and the
 .B raid1
 type should be used.  They are both implementations of mirroring.
-
+.P
 Striped raid types are
 \fBraid0/raid0_meta\fP,
 \fBraid5\fP (an alias for raid5_ls),
 \fBraid6\fP (an alias for raid6_zr) and
 \fBraid10\fP (an alias for raid10_near).
-
+.P
 As opposed to mirroring, raid5 and raid6 stripe data and calculate parity
 blocks. The parity blocks can be used for data block recovery in case
 devices fail. A maximum number of one device in a raid5 LV may fail, and
@@ -347,45 +212,49 @@ data blocks for performance reasons, thus avoiding contention on a single
 device. Specific arrangements of parity and data blocks (layouts) can be
 used to optimize I/O performance, or to convert between raid levels.  See
 \fBlvmraid\fP(7) for more information.
-
+.P
 Layouts of raid5 rotating parity blocks can be: left-asymmetric
 (raid5_la), left-symmetric (raid5_ls with alias raid5), right-asymmetric
 (raid5_ra), right-symmetric (raid5_rs) and raid5_n, which doesn't rotate
 parity blocks. Layouts of raid6 are: zero-restart (raid6_zr with alias
 raid6), next-restart (raid6_nr), and next-continue (raid6_nc).
-
+.P
 Layouts including _n allow for conversion between raid levels (raid5_n to
 raid6 or raid5_n to striped/raid0/raid0_meta). Additionally, special raid6
 layouts for raid level conversions between raid5 and raid6 are:
 raid6_ls_6, raid6_rs_6, raid6_la_6 and raid6_ra_6. Those correspond to
 their raid5 counterparts (e.g. raid5_rs can be directly converted to
 raid6_rs_6 and vice-versa).
-
+.P
 raid10 (an alias for raid10_near) is currently limited to one data copy
 and even number of sub LVs. This is a mirror group layout, thus a single
 sub LV may fail per mirror group without data loss.
-
+.P
 Striped raid types support converting the layout, their stripesize and
 their number of stripes.
-
+.P
 The striped raid types combined with raid1 allow for conversion from
-linear -> striped/raid0/raid0_meta and vice-versa by e.g. linear <-> raid1
-<-> raid5_n (then adding stripes) <-> striped/raid0/raid0_meta.
+linear \[->] striped/raid0/raid0_meta and vice-versa by e.g. linear \[<>] raid1
+\[<>] raid5_n (then adding stripes) \[<>] striped/raid0/raid0_meta.
+.
 .SH USAGE
+.
 Convert LV to linear.
 .br
 .P
 \fBlvconvert\fP \fB--type\fP \fBlinear\fP \fILV\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Convert LV to striped.
 .br
 .P
@@ -394,28 +263,22 @@ Convert LV to striped.
 .RS 4
 .ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [    \fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Convert LV to type mirror (also see type raid1),
 .br
 .P
@@ -424,36 +287,26 @@ Convert LV to type mirror (also see type raid1),
 .RS 4
 .ad l
 [ \fB-m\fP|\fB--mirrors\fP [\fB+\fP|\fB-\fP]\fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [    \fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [    \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Convert LV to raid or change raid layout 
 .br
 (a specific raid level must be used, e.g. raid1).
@@ -464,32 +317,24 @@ Convert LV to raid or change raid layout
 .RS 4
 .ad l
 [ \fB-m\fP|\fB--mirrors\fP [\fB+\fP|\fB-\fP]\fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [    \fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Convert LV to raid1 or mirror, or change number of mirror images.
 .br
 .P
@@ -498,535 +343,491 @@ Convert LV to raid1 or mirror, or change number of mirror images.
 .RS 4
 .ad l
 [ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [    \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Convert raid LV to change number of stripe images.
 .br
 .P
-\fBlvconvert\fP \fB--stripes\fP \fINumber\fP \fILV\fP\fI_raid\fP
+\fBlvconvert\fP \fB--stripes\fP \fINumber\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+.RS 4
+LV1 types: raid
+.RE
+.P
+\(em
+.P
 Convert raid LV to change the stripe size.
 .br
 .P
-\fBlvconvert\fP \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] \fILV\fP\fI_raid\fP
+\fBlvconvert\fP \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] \fILV1\fP
 .br
 .RS 4
 .ad l
 [ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: raid
+.RE
+.P
+\(em
+.P
 Split images from a raid1 or mirror LV and use them to create a new LV.
 .br
 .P
-\fBlvconvert\fP \fB--splitmirrors\fP \fINumber\fP \fB-n\fP|\fB--name\fP \fILV\fP\fI_new\fP \fILV\fP\fI_cache_mirror_raid1\fP
+\fBlvconvert\fP \fB--splitmirrors\fP \fINumber\fP \fB-n\fP|\fB--name\fP \fILV\fP\fI_new\fP \fILV1\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+.RS 4
+LV1 types: cache mirror raid1
+.RE
+.P
+\(em
+.P
 Split images from a raid1 LV and track changes to origin for later merge.
 .br
 .P
-\fBlvconvert\fP \fB--splitmirrors\fP \fINumber\fP \fB--trackchanges\fP \fILV\fP\fI_cache_raid1\fP
+\fBlvconvert\fP \fB--splitmirrors\fP \fINumber\fP \fB--trackchanges\fP \fILV1\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+.RS 4
+LV1 types: cache raid1
+.RE
+.P
+\(em
+.P
 Merge LV images that were split from a raid1 LV.
 .br
 .P
-\fBlvconvert\fP \fB--mergemirrors\fP \fIVG\fP|\fILV\fP\fI_linear_raid\fP|\fITag\fP ...
+\fBlvconvert\fP \fB--mergemirrors\fP \fIVG\fP|\fILV1\fP|\fITag\fP ...
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: linear raid
+.RE
+.P
+\(em
+.P
 Convert LV to a thin LV, using the original LV as an external origin.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBthin\fP \fB--thinpool\fP \fILV\fP \fILV\fP\fI_linear_striped_thin_cache_raid_error_zero\fP
+\fBlvconvert\fP \fB--type\fP \fBthin\fP \fB--thinpool\fP \fILV\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [ \fB-T\fP|\fB--thin\fP ]
-.ad b
 .br
-.ad l
 [ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--originname\fP \fILV\fP\fI_new\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadata\fP \fILV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: linear striped thin cache raid error zero
+.RE
+.P
+\(em
+.P
 Attach a cache pool to an LV, converts the LV to type cache.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBcache\fP \fB--cachepool\fP \fILV\fP \fILV\fP\fI_linear_striped_thinpool_vdo_vdopool_vdopooldata_raid\fP
+\fBlvconvert\fP \fB--type\fP \fBcache\fP \fB--cachepool\fP \fILV\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [ \fB-H\fP|\fB--cache\fP ]
-.ad b
 .br
-.ad l
 [ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachepolicy\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachesettings\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadata\fP \fILV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: linear striped thinpool vdo vdopool vdopooldata raid
+.RE
+.P
+\(em
+.P
 Attach a writecache to an LV, converts the LV to type writecache.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBwritecache\fP \fB--cachevol\fP \fILV\fP \fILV\fP\fI_linear_striped_raid\fP
+\fBlvconvert\fP \fB--type\fP \fBwritecache\fP \fB--cachevol\fP \fILV\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [    \fB--cachesettings\fP \fIString\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: linear striped raid
+.RE
+.P
+\(em
+.P
 Attach a cache to an LV, converts the LV to type cache.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBcache\fP \fB--cachevol\fP \fILV\fP \fILV\fP\fI_linear_striped_thinpool_raid\fP
+\fBlvconvert\fP \fB--type\fP \fBcache\fP \fB--cachevol\fP \fILV\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [ \fB-H\fP|\fB--cache\fP ]
-.ad b
 .br
-.ad l
 [ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachepolicy\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachesettings\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: linear striped thinpool raid
+.RE
+.P
+\(em
+.P
 Add a writecache to an LV, using a specified cache device.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBwritecache\fP \fB--cachedevice\fP \fIPV\fP \fILV\fP\fI_linear_striped_raid\fP
+\fBlvconvert\fP \fB--type\fP \fBwritecache\fP \fB--cachedevice\fP \fIPV\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [    \fB--cachesize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--cachesettings\fP \fIString\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: linear striped raid
+.RE
+.P
+\(em
+.P
 Add a cache to an LV, using a specified cache device.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBcache\fP \fB--cachedevice\fP \fIPV\fP \fILV\fP\fI_linear_striped_thinpool_raid\fP
+\fBlvconvert\fP \fB--type\fP \fBcache\fP \fB--cachedevice\fP \fIPV\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--cachesize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--cachesettings\fP \fIString\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: linear striped thinpool raid
+.RE
+.P
+\(em
+.P
 Convert LV to type thin-pool.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBthin-pool\fP \fILV\fP\fI_linear_striped_cache_raid_error_zero\fP
+\fBlvconvert\fP \fB--type\fP \fBthin-pool\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
-.ad b
 .br
-.ad l
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadata\fP \fILV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+.RS 4
+LV1 types: linear striped cache raid error zero
+.RE
+.P
+\(em
+.P
 Convert LV to type cache-pool.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBcache-pool\fP \fILV\fP\fI_linear_striped_raid\fP
+\fBlvconvert\fP \fB--type\fP \fBcache-pool\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachepolicy\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachesettings\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadata\fP \fILV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+.RS 4
+LV1 types: linear striped raid
+.RE
+.P
+\(em
+.P
 Convert LV to type vdopool.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBvdo-pool\fP \fILV\fP\fI_linear_striped_cache_raid\fP
+\fBlvconvert\fP \fB--type\fP \fBvdo-pool\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [ \fB-n\fP|\fB--name\fP \fILV\fP\fI_new\fP ]
-.ad b
 .br
-.ad l
 [ \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--compression\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
+.RE
+.P
+.RS 4
+LV1 types: linear striped cache raid
 .RE
-.br
--
-
+.P
+\(em
+.P
 Detach a cache from an LV.
 .br
 .P
-\fBlvconvert\fP \fB--splitcache\fP \fILV\fP\fI_thinpool_cache_cachepool_vdopool_writecache\fP
+\fBlvconvert\fP \fB--splitcache\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [    \fB--cachesettings\fP \fIString\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: thinpool cache cachepool vdopool writecache
+.RE
+.P
+\(em
+.P
 Merge thin LV into its origin LV.
 .br
 .P
-\fBlvconvert\fP \fB--mergethin\fP \fILV\fP\fI_thin\fP ...
+\fBlvconvert\fP \fB--mergethin\fP \fILV1\fP ...
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: thin
+.RE
+.P
+\(em
+.P
 Merge COW snapshot LV into its origin.
 .br
 .P
-\fBlvconvert\fP \fB--mergesnapshot\fP \fILV\fP\fI_snapshot\fP ...
+\fBlvconvert\fP \fB--mergesnapshot\fP \fILV1\fP ...
 .br
 .RS 4
 .ad l
 [ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: snapshot
+.RE
+.P
+\(em
+.P
 Combine a former COW snapshot (second arg) with a former 
 .br
 origin LV (first arg) to reverse a splitsnapshot command.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBsnapshot\fP \fILV\fP \fILV\fP\fI_linear_striped\fP
+\fBlvconvert\fP \fB--type\fP \fBsnapshot\fP \fILV\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [ \fB-s\fP|\fB--snapshot\fP ]
-.ad b
 .br
-.ad l
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: linear striped
+.RE
+.P
+\(em
+.P
 Replace failed PVs in a raid or mirror LV. 
 .br
 Repair a thin pool. 
@@ -1034,176 +835,157 @@ Repair a thin pool.
 Repair a cache pool.
 .br
 .P
-\fBlvconvert\fP \fB--repair\fP \fILV\fP\fI_thinpool_cache_cachepool_mirror_raid\fP
+\fBlvconvert\fP \fB--repair\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [    \fB--usepolicies\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+.RS 4
+LV1 types: thinpool cache cachepool mirror raid
+.RE
+.P
+\(em
+.P
 Replace specific PV(s) in a raid LV with another PV.
 .br
 .P
-\fBlvconvert\fP \fB--replace\fP \fIPV\fP \fILV\fP\fI_raid\fP
+\fBlvconvert\fP \fB--replace\fP \fIPV\fP \fILV1\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+.RS 4
+LV1 types: raid
+.RE
+.P
+\(em
+.P
 Poll LV to continue conversion.
 .br
 .P
-\fBlvconvert\fP \fB--startpoll\fP \fILV\fP\fI_mirror_raid\fP
+\fBlvconvert\fP \fB--startpoll\fP \fILV1\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: mirror raid
+.RE
+.P
+\(em
+.P
 Add or remove data integrity checksums to raid images.
 .br
 .P
-\fBlvconvert\fP \fB--raidintegrity\fP \fBy\fP|\fBn\fP \fILV\fP\fI_raid\fP
+\fBlvconvert\fP \fB--raidintegrity\fP \fBy\fP|\fBn\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [    \fB--raidintegritymode\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--raidintegrityblocksize\fP \fINumber\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+.RS 4
+LV1 types: raid
+.RE
+.P
+\(em
+.P
 Common options for command:
 .
 .RS 4
 .ad l
 [ \fB-b\fP|\fB--background\fP ]
-.ad b
 .br
-.ad l
 [ \fB-f\fP|\fB--force\fP ]
-.ad b
 .br
-.ad l
-[    \fB--alloc\fP 
+[    \fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
 ]
-.ad b
 .br
-.ad l
 [    \fB--noudevsync\fP ]
 .ad b
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
 .ad l
-\fB--alloc\fP 
+\fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
-.br
 .ad b
+.br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
 which can be changed with vgchange/lvchange, or overridden on the
@@ -1220,39 +1002,34 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
+.
 .HP
-.ad l
 \fB-b\fP|\fB--background\fP
 .br
-.ad b
 If the operation requires polling, this option causes the command to
 return before the operation is complete, and polling is done in the
 background.
+.
 .HP
-.ad l
 \fB-H\fP|\fB--cache\fP
 .br
-.ad b
 Specifies the command is handling a cache LV or cache pool.
 See --type cache and --type cache-pool.
 See \fBlvmcache\fP(7) for more information about LVM caching.
+.
 .HP
-.ad l
 \fB--cachedevice\fP \fIPV\fP
 .br
-.ad b
 The name of a device to use for a cache.
+.
 .HP
-.ad l
 \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP
 .br
-.ad b
 Specifies the cache metadata format used by cache target.
+.
 .HP
-.ad l
 \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
 .br
-.ad b
 Specifies when writes to a cache LV should be considered complete.
 \fBwriteback\fP considers a write complete as soon as it is
 stored in the cache pool.
@@ -1264,24 +1041,21 @@ cache pool LV. With \fBpassthrough\fP, all reads are served
 from the origin LV (all reads miss the cache) and all writes are
 forwarded to the origin LV; additionally, write hits cause cache
 block invalidates. See \fBlvmcache\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--cachepolicy\fP \fIString\fP
 .br
-.ad b
 Specifies the cache policy for a cache LV.
 See \fBlvmcache\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--cachepool\fP \fILV\fP
 .br
-.ad b
 The name of a cache pool.
+.
 .HP
-.ad l
 \fB--cachesettings\fP \fIString\fP
 .br
-.ad b
 Specifies tunable values for a cache LV in "Key = Value" form.
 Repeat this option to specify multiple values.
 (The default values should usually be adequate.)
@@ -1289,23 +1063,20 @@ The special string value \fBdefault\fP switches
 settings back to their default kernel values and removes
 them from the list of settings stored in LVM metadata.
 See \fBlvmcache\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--cachesize\fP \fISize\fP[m|UNIT]
 .br
-.ad b
 The size of cache to use.
+.
 .HP
-.ad l
 \fB--cachevol\fP \fILV\fP
 .br
-.ad b
 The name of a cache volume.
+.
 .HP
-.ad l
 \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT]
 .br
-.ad b
 The size of chunks in a snapshot, cache pool or thin pool.
 For snapshots, the value must be a power of 2 between 4KiB and 512KiB
 and the default value is 4.
@@ -1316,66 +1087,58 @@ and the default value starts with 64 and scales up to fit the
 pool metadata size within 128MiB, if the pool metadata size is not specified.
 The value must be a multiple of 64KiB.
 See \fBlvmthin\fP(7) and \fBlvmcache\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--compression\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Controls whether compression is enabled or disable for VDO volume.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--deduplication\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Controls whether deduplication is enabled or disable for VDO volume.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .br
-.ad b
 Specifies how the device-mapper thin pool layer in the kernel should
 handle discards.
 \fBignore\fP causes the thin pool to ignore discards.
@@ -1384,18 +1147,16 @@ allow reuse of unneeded extents in the thin pool.
 \fBpassdown\fP causes the thin pool to process discards itself
 (like nopassdown) and pass the discards to the underlying device.
 See \fBlvmthin\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB--errorwhenfull\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Specifies thin pool behavior when data space is exhausted.
 When yes, device-mapper will immediately return an error
 when a thin pool is full and an I/O request requires space.
@@ -1404,57 +1165,49 @@ period of time to allow the thin pool to be extended.
 Errors are returned if no space is available after the timeout.
 (Also see dm-thin-pool kernel module option no_space_timeout.)
 See \fBlvmthin\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-f\fP|\fB--force\fP ...
 .br
-.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB-i\fP|\fB--interval\fP \fINumber\fP
 .br
-.ad b
 Report progress at regular intervals.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--merge\fP
 .br
-.ad b
 An alias for --mergethin, --mergemirrors, or --mergesnapshot,
 depending on the type of LV.
+.
 .HP
-.ad l
 \fB--mergemirrors\fP
 .br
-.ad b
 Merge LV images that were split from a raid1 LV.
 See --splitmirrors with --trackchanges.
+.
 .HP
-.ad l
 \fB--mergesnapshot\fP
 .br
-.ad b
 Merge COW snapshot LV into its origin.
 When merging a snapshot, if both the origin and snapshot LVs are not open,
 the merge will start immediately. Otherwise, the merge will start the
@@ -1467,27 +1220,24 @@ reads or writes to the origin appear as being directed to the snapshot
 being merged. When the merge finishes, the merged snapshot is removed.
 Multiple snapshots may be specified on the command line or a @tag may be
 used to specify multiple snapshots be merged to their respective origin.
+.
 .HP
-.ad l
 \fB--mergethin\fP
 .br
-.ad b
 Merge thin LV into its origin LV.
 The origin thin LV takes the content of the thin snapshot,
 and the thin snapshot LV is removed.
 See \fBlvmthin\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--metadataprofile\fP \fIString\fP
 .br
-.ad b
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP
 .br
-.ad b
 Specifies the type of mirror log for LVs with the "mirror" type
 (does not apply to the "raid1" type.)
 \fBdisk\fP is a persistent log and requires a small amount of
@@ -1497,11 +1247,10 @@ In this case, the mirror must be synchronized (by copying LV data from
 the first device to others) each time the LV is activated, e.g. after reboot.
 \fBmirrored\fP is a persistent log that is itself mirrored, but
 should be avoided. Instead, use the raid1 type for log redundancy.
+.
 .HP
-.ad l
 \fB-m\fP|\fB--mirrors\fP [\fB+\fP|\fB-\fP]\fINumber\fP
 .br
-.ad b
 Specifies the number of mirror images in addition to the original LV
 image, e.g. --mirrors 1 means there are two images of the data, the
 original and one mirror image.
@@ -1511,100 +1260,88 @@ There are two mirroring implementations: "raid1" and "mirror".
 These are the names of the corresponding LV types, or "segment types".
 Use the --type option to specify which to use (raid1 is default,
 and mirror is legacy)
-Use lvm.conf global/mirror_segtype_default and
+Use \fBlvm.conf\fP(5) \fBglobal/mirror_segtype_default\fP and
 global/raid10_segtype_default to configure the default types.
 The plus prefix \fB+\fP can be used, in which case
 the number is added to the current number of images,
 or the minus prefix \fB-\fP can be used, in which case
 the number is subtracted from the current number of images.
 See \fBlvmraid\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-n\fP|\fB--name\fP \fIString\fP
 .br
-.ad b
 Specifies the name of a new LV.
 When unspecified, a default name of "lvol#" is
 generated, where # is a number generated by LVM.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--noudevsync\fP
 .br
-.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
+.
 .HP
-.ad l
 \fB--originname\fP \fILV\fP
 .br
-.ad b
 Specifies the name to use for the external origin LV when converting an LV
 to a thin LV. The LV being converted becomes a read-only external origin
 with this name.
+.
 .HP
-.ad l
 \fB--poolmetadata\fP \fILV\fP
 .br
-.ad b
 The name of a an LV to use for storing pool metadata.
+.
 .HP
-.ad l
 \fB--poolmetadatasize\fP \fISize\fP[m|UNIT]
 .br
-.ad b
 Specifies the size of the new pool metadata LV.
+.
 .HP
-.ad l
 \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Enable or disable the automatic creation and management of a
 spare pool metadata LV in the VG. A spare metadata LV is reserved
 space that can be used when repairing a pool.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--raidintegrity\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Enable or disable data integrity checksums for raid images.
+.
 .HP
-.ad l
 \fB--raidintegrityblocksize\fP \fINumber\fP
 .br
-.ad b
 The block size to use for dm-integrity on raid images.
 The integrity block size should usually match the device
 logical block size, or the file system block size.
 It may be less than the file system block size, but not
 less than the device logical block size.
 Possible values: 512, 1024, 2048, 4096.
+.
 .HP
-.ad l
 \fB--raidintegritymode\fP \fIString\fP
 .br
-.ad b
 Use a journal (default) or bitmap for keeping integrity checksums consistent
 in case of a crash. The bitmap areas are recalculated after a crash, so corruption
 in those areas would not be detected. A journal does not have this problem.
@@ -1612,135 +1349,119 @@ The journal mode doubles writes to storage, but can improve performance for
 scattered writes packed into a single journal write.
 bitmap mode can in theory achieve full write throughput of the device,
 but would not benefit from the potential scattered write optimization.
+.
 .HP
-.ad l
 \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
 .br
-.ad b
 Sets read ahead sector count of an LV.
 \fBauto\fP is the default which allows the kernel to choose
 a suitable value automatically.
 \fBnone\fP is equivalent to zero.
+.
 .HP
-.ad l
 \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT]
 .br
-.ad b
 Size of each raid or mirror synchronization region.
-lvm.conf activation/raid_region_size can be used to
+\fBlvm.conf\fP(5) \fBactivation/raid_region_size\fP can be used to
 configure a default.
+.
 .HP
-.ad l
 \fB--repair\fP
 .br
-.ad b
 Replace failed PVs in a raid or mirror LV, or run a repair
 utility on a thin pool. See \fBlvmraid\fP(7) and \fBlvmthin\fP(7)
 for more information.
+.
 .HP
-.ad l
 \fB--replace\fP \fIPV\fP
 .br
-.ad b
 Replace a specific PV in a raid LV with another PV.
 The new PV to use can be optionally specified after the LV.
 Multiple PVs can be replaced by repeating this option.
 See \fBlvmraid\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-s\fP|\fB--snapshot\fP
 .br
-.ad b
 Combine a former COW snapshot LV with a former origin LV to reverse
 a previous --splitsnapshot command.
+.
 .HP
-.ad l
 \fB--splitcache\fP
 .br
-.ad b
 Separates a cache pool from a cache LV, and keeps the unused cache pool LV.
 Before the separation, the cache is flushed. Also see --uncache.
+.
 .HP
-.ad l
 \fB--splitmirrors\fP \fINumber\fP
 .br
-.ad b
 Splits the specified number of images from a raid1 or mirror LV
 and uses them to create a new LV. If --trackchanges is also specified,
 changes to the raid1 LV are tracked while the split LV remains detached.
 If --name is specified, then the images are permanently split from the
 original LV and changes are not tracked.
+.
 .HP
-.ad l
 \fB--splitsnapshot\fP
 .br
-.ad b
 Separates a COW snapshot from its origin LV. The LV that is split off
 contains the chunks that differ from the origin LV along with metadata
 describing them. This LV can be wiped and then destroyed with lvremove.
+.
 .HP
-.ad l
 \fB--startpoll\fP
 .br
-.ad b
 Start polling an LV to continue processing a conversion.
+.
 .HP
-.ad l
 \fB--stripes\fP \fINumber\fP
 .br
-.ad b
 Specifies the number of stripes in a striped LV. This is the number of
 PVs (devices) that a striped LV is spread across. Data that
 appears sequential in the LV is spread across multiple devices in units of
 the stripe size (see --stripesize). This does not apply to
 existing allocated space, only newly allocated space can be striped.
+.
 .HP
-.ad l
 \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
 .br
-.ad b
 The amount of data that is written to one device before
 moving to the next in a striped LV.
+.
 .HP
-.ad l
 \fB--swapmetadata\fP
 .br
-.ad b
 Extracts the metadata LV from a pool and replaces it with another specified LV.
 The extracted LV is preserved and given the name of the LV that replaced it.
 Use for repair only. When the metadata LV is swapped out of the pool, it can
 be activated directly and used with thin provisioning tools:
 \fBcache_dump\fP(8), \fBcache_repair\fP(8), \fBcache_restore\fP(8),
 \fBthin_dump\fP(8), \fBthin_repair\fP(8), \fBthin_restore\fP(8).
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-T\fP|\fB--thin\fP
 .br
-.ad b
 Specifies the command is handling a thin LV or thin pool.
 See --type thin, --type thin-pool, and --virtualsize.
 See \fBlvmthin\fP(7) for more information about LVM thin provisioning.
+.
 .HP
-.ad l
 \fB--thinpool\fP \fILV\fP
 .br
-.ad b
 The name of a thin pool LV.
+.
 .HP
-.ad l
 \fB--trackchanges\fP
 .br
-.ad b
 Can be used with --splitmirrors on a raid1 LV. This causes
 changes to the original raid1 LV to be tracked while the split images
 remain detached. This is a temporary state that allows the read-only
@@ -1749,14 +1470,15 @@ Only the regions with changed data are resynchronized during merge.
 While a raid1 LV is tracking changes, operations on it are limited to
 merging the split image (see --mergemirrors) or permanently splitting
 the image (see --splitmirrors with --name.
+.
 .HP
 .ad l
-\fB--type\fP 
+\fB--type\fP \c
 .nh
-\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
+\%\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
 .hy
-.br
 .ad b
+.br
 The LV type, also known as "segment type" or "segtype".
 See usage descriptions for the specific ways to use these types.
 For more information about redundancy and performance (\fBraid\fP<N>, \fBmirror\fP, \fBstriped\fP, \fBlinear\fP) see \fBlvmraid\fP(7).
@@ -1768,50 +1490,44 @@ Several commands omit an explicit type option because the type
 is inferred from other options or shortcuts
 (e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache, --vdo).
 Use inferred types with care because it can lead to unexpected results.
+.
 .HP
-.ad l
 \fB--uncache\fP
 .br
-.ad b
 Separates a cache pool from a cache LV, and deletes the unused cache pool LV.
 Before the separation, the cache is flushed. Also see --splitcache.
+.
 .HP
-.ad l
 \fB--usepolicies\fP
 .br
-.ad b
-Perform an operation according to the policy configured in lvm.conf
+Perform an operation according to the policy configured in \fBlvm.conf\fP(5)
 or a profile.
+.
 .HP
-.ad l
 \fB--vdopool\fP \fILV\fP
 .br
-.ad b
 The name of a VDO pool LV.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
 .br
-.ad b
 The virtual size of a new thin LV.
 See \fBlvmthin\fP(7) for more information about LVM thin provisioning.
 Using virtual size (-V) and actual size (-L) together creates
 a sparse LV.
-lvm.conf global/sparse_segtype_default determines the
+\fBlvm.conf\fP(5) \fBglobal/sparse_segtype_default\fP determines the
 default segment type used to create a sparse LV.
 Anything written to a sparse LV will be returned when reading from it.
 Reading from other areas of the LV will return blocks of zeros.
@@ -1819,38 +1535,35 @@ When using a snapshot to create a sparse LV, a hidden virtual device
 is created using the zero target, and the LV has the suffix _vorigin.
 Snapshots are less efficient than thin provisioning when creating
 large sparse LVs (GiB).
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .HP
-.ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 For snapshots, this controls zeroing of the first 4KiB of data in the
 snapshot. If the LV is read-only, the snapshot will not be zeroed.
 For thin pools, this controls zeroing of provisioned blocks.
 Provisioning of large zeroed chunks negatively impacts performance.
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fILV\fP
-.br
+.TP
+.I LV
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-LV followed by _<type> indicates that an LV of the
-given type is required. (raid represents raid<N> type)
-.HP
-\fIPV\fP
-.br
+LV1 indicates the LV must have a specific type, where the
+accepted LV types are listed. (raid represents raid<N> type).
+.TP
+.I PV
 Physical Volume name, a device path under /dev.
 For commands managing physical extents, a PV positional arg
 generally accepts a suffix indicating a range (or multiple ranges)
@@ -1858,278 +1571,261 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
-\fITag\fP
-.br
+.TP
+.I Tag
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
+.
 .SH ADVANCED USAGE
+.
 Alternate command forms, advanced command usage, and listing of all valid syntax for completeness.
 .P
 Change the region size of an LV.
 .br
 .P
-\fBlvconvert\fP \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] \fILV\fP\fI_raid\fP
+\fBlvconvert\fP \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] \fILV1\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: raid
+.RE
+.P
+\(em
+.P
 Change the type of mirror log used by a mirror LV.
 .br
 .P
-\fBlvconvert\fP \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP \fILV\fP\fI_mirror\fP
+\fBlvconvert\fP \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP \fILV1\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+.RS 4
+LV1 types: mirror
+.RE
+.P
+\(em
+.P
 Convert LV to a thin LV, using the original LV as an external origin 
 .br
 (infers --type thin).
 .br
 .P
-\fBlvconvert\fP \fB-T\fP|\fB--thin\fP \fB--thinpool\fP \fILV\fP \fILV\fP\fI_linear_striped_thin_cache_raid_error_zero\fP
+\fBlvconvert\fP \fB-T\fP|\fB--thin\fP \fB--thinpool\fP \fILV\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--type\fP \fBthin\fP ]
-.ad b
 .br
-.ad l
 [    \fB--originname\fP \fILV\fP\fI_new\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadata\fP \fILV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: linear striped thin cache raid error zero
+.RE
+.P
+\(em
+.P
 Attach a cache pool to an LV (infers --type cache).
 .br
 .P
-\fBlvconvert\fP \fB-H\fP|\fB--cache\fP \fB--cachepool\fP \fILV\fP \fILV\fP\fI_linear_striped_thinpool_vdo_vdopool_vdopooldata_raid\fP
+\fBlvconvert\fP \fB-H\fP|\fB--cache\fP \fB--cachepool\fP \fILV\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--type\fP \fBcache\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachepolicy\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachesettings\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadata\fP \fILV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: linear striped thinpool vdo vdopool vdopooldata raid
+.RE
+.P
+\(em
+.P
 Attach a cache to an LV, converts the LV to type cache.
 .br
 .P
-\fBlvconvert\fP \fB-H\fP|\fB--cache\fP \fB--cachevol\fP \fILV\fP \fILV\fP\fI_linear_striped_thinpool_raid\fP
+\fBlvconvert\fP \fB-H\fP|\fB--cache\fP \fB--cachevol\fP \fILV\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachepolicy\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachesettings\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: linear striped thinpool raid
+.RE
+.P
+\(em
+.P
 Convert LV to type vdopool.
 .br
 .P
-\fBlvconvert\fP \fB--vdopool\fP \fILV\fP\fI_linear_striped_cache_raid\fP
+\fBlvconvert\fP \fB--vdopool\fP \fILV\fP
 .br
 .RS 4
 .ad l
 [ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-n\fP|\fB--name\fP \fILV\fP\fI_new\fP ]
-.ad b
 .br
-.ad l
 [ \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--type\fP \fBvdo-pool\fP ]
-.ad b
 .br
-.ad l
 [    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--compression\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Detach and delete a cache from an LV.
 .br
 .P
-\fBlvconvert\fP \fB--uncache\fP \fILV\fP\fI_thinpool_cache_vdopool_writecache\fP
+\fBlvconvert\fP \fB--uncache\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [    \fB--cachesettings\fP \fIString\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: thinpool cache vdopool writecache
+.RE
+.P
+\(em
+.P
 Swap metadata LV in a thin pool or cache pool (for repair only).
 .br
 .P
-\fBlvconvert\fP \fB--swapmetadata\fP \fB--poolmetadata\fP \fILV\fP \fILV\fP\fI_thinpool_cachepool\fP
+\fBlvconvert\fP \fB--swapmetadata\fP \fB--poolmetadata\fP \fILV\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: thinpool cachepool
+.RE
+.P
+\(em
+.P
 Merge LV that was split from a mirror (variant, use --mergemirrors). 
 .br
 Merge thin LV into its origin LV (variant, use --mergethin). 
@@ -2137,245 +1833,80 @@ Merge thin LV into its origin LV (variant, use --mergethin).
 Merge COW snapshot LV into its origin (variant, use --mergesnapshot).
 .br
 .P
-\fBlvconvert\fP \fB--merge\fP \fIVG\fP|\fILV\fP\fI_linear_striped_snapshot_thin_raid\fP|\fITag\fP ...
+\fBlvconvert\fP \fB--merge\fP \fIVG\fP|\fILV1\fP|\fITag\fP ...
 .br
 .RS 4
 .ad l
 [ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: linear striped snapshot thin raid
+.RE
+.P
+\(em
+.P
 Separate a COW snapshot from its origin LV.
 .br
 .P
-\fBlvconvert\fP \fB--splitsnapshot\fP \fILV\fP\fI_snapshot\fP
+\fBlvconvert\fP \fB--splitsnapshot\fP \fILV1\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: snapshot
+.RE
+.P
+\(em
+.P
 Combine a former COW snapshot (second arg) with a former 
 .br
 origin LV (first arg) to reverse a splitsnapshot command.
 .br
 .P
-\fBlvconvert\fP \fB-s\fP|\fB--snapshot\fP \fILV\fP \fILV\fP\fI_linear_striped\fP
+\fBlvconvert\fP \fB-s\fP|\fB--snapshot\fP \fILV\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--type\fP \fBsnapshot\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: linear striped
+.RE
+.P
+\(em
+.P
 Poll LV to continue conversion (also see --startpoll) 
 .br
 or waits till conversion/mirror syncing is finished
 .br
 .P
-\fBlvconvert\fP \fILV\fP\fI_mirror_raid\fP
+\fBlvconvert\fP \fILV1\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
-.SH NOTES
-This previous command syntax would perform two different operations:
-.br
-\fBlvconvert --thinpool\fP \fILV1\fP \fB--poolmetadata\fP \fILV2\fP
-.br
-If LV1 was not a thin pool, the command would convert LV1 to
-a thin pool, optionally using a specified LV for metadata.
-But, if LV1 was already a thin pool, the command would swap
-the current metadata LV with LV2 (for repair purposes.)
-
-In the same way, this previous command syntax would perform two different
-operations:
-.br
-\fBlvconvert --cachepool\fP \fILV1\fP \fB--poolmetadata\fP \fILV2\fP
-.br
-If LV1 was not a cache pool, the command would convert LV1 to
-a cache pool, optionally using a specified LV for metadata.
-But, if LV1 was already a cache pool, the command would swap
-the current metadata LV with LV2 (for repair purposes.)
-.SH EXAMPLES
-Convert a linear LV to a two-way mirror LV.
-.br
-.B lvconvert --type mirror --mirrors 1 vg/lvol1
-
-Convert a linear LV to a two-way RAID1 LV.
-.br
-.B lvconvert --type raid1 --mirrors 1 vg/lvol1
-
-Convert a mirror LV to use an in-memory log.
-.br
-.B lvconvert --mirrorlog core vg/lvol1
-
-Convert a mirror LV to use a disk log.
-.br
-.B lvconvert --mirrorlog disk vg/lvol1
-
-Convert a mirror or raid1 LV to a linear LV.
-.br
-.B lvconvert --type linear vg/lvol1
-
-Convert a mirror LV to a raid1 LV with the same number of images.
-.br
-.B lvconvert --type raid1 vg/lvol1
-
-Convert a linear LV to a two-way mirror LV, allocating new extents from specific
-PV ranges.
-.br
-.B lvconvert --mirrors 1 vg/lvol1 /dev/sda:0-15 /dev/sdb:0-15
-
-Convert a mirror LV to a linear LV, freeing physical extents from a specific PV.
-.br
-.B lvconvert --type linear vg/lvol1 /dev/sda
-
-Split one image from a mirror or raid1 LV, making it a new LV.
-.br
-.B lvconvert --splitmirrors 1 --name lv_split vg/lvol1
-
-Split one image from a raid1 LV, and track changes made to the raid1 LV
-while the split image remains detached.
-.br
-.B lvconvert --splitmirrors 1 --trackchanges vg/lvol1
-
-Merge an image (that was previously created with --splitmirrors and
---trackchanges) back into the original raid1 LV.
-.br
-.B lvconvert --mergemirrors vg/lvol1_rimage_1
-
-Replace PV /dev/sdb1 with PV /dev/sdf1 in a raid1/4/5/6/10 LV.
-.br
-.B lvconvert --replace /dev/sdb1 vg/lvol1 /dev/sdf1
-
-Replace 3 PVs /dev/sd[b-d]1 with PVs /dev/sd[f-h]1 in a raid1 LV.
-.br
-.B lvconvert --replace /dev/sdb1 --replace /dev/sdc1 --replace /dev/sdd1
-.RS
-.B vg/lvol1 /dev/sd[fgh]1
-.RE
-
-Replace the maximum of 2 PVs /dev/sd[bc]1 with PVs /dev/sd[gh]1 in a raid6 LV.
-.br
-.B lvconvert --replace /dev/sdb1 --replace /dev/sdc1 vg/lvol1 /dev/sd[gh]1
-
-Convert an LV into a thin LV in the specified thin pool.  The existing LV
-is used as an external read-only origin for the new thin LV.
-.br
-.B lvconvert --type thin --thinpool vg/tpool1 vg/lvol1
-
-Convert an LV into a thin LV in the specified thin pool.  The existing LV
-is used as an external read-only origin for the new thin LV, and is
-renamed "external".
-.br
-.B lvconvert --type thin --thinpool vg/tpool1
-.RS
-.B --originname external vg/lvol1
-.RE
-
-Convert an LV to a cache pool LV using another specified LV for cache pool
-metadata.
-.br
-.B lvconvert --type cache-pool --poolmetadata vg/poolmeta1 vg/lvol1
-
-Convert an LV to a cache LV using the specified cache pool and chunk size.
-.br
-.B lvconvert --type cache --cachepool vg/cpool1 -c 128 vg/lvol1
-
-Detach and keep the cache pool from a cache LV.
-.br
-.B lvconvert --splitcache vg/lvol1
-
-Detach and remove the cache pool from a cache LV.
-.br
-.B lvconvert --uncache vg/lvol1
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
+.P
+.RS 4
+LV1 types: mirror raid
+.RE
+.P
+\(em
+.P
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index 140344fa8..c73d1bafc 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -1,8 +1,11 @@
 .TH LVCREATE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-lvcreate - Create a logical volume
+.
+lvcreate \(em Create a logical volume
 .
 .SH SYNOPSIS
+.
 \fBlvcreate\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
@@ -12,349 +15,209 @@ lvcreate - Create a logical volume
 .P
 .ad l
  \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
-.ad b
 .br
-.ad l
     \fB--addtag\fP \fITag\fP
-.ad b
 .br
-.ad l
-    \fB--alloc\fP 
+    \fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
-.ad b
 .br
-.ad l
  \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
  \fB-H\fP|\fB--cache\fP
-.ad b
 .br
-.ad l
     \fB--cachedevice\fP \fIPV\fP
-.ad b
 .br
-.ad l
     \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP
-.ad b
 .br
-.ad l
     \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
-.ad b
 .br
-.ad l
     \fB--cachepolicy\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--cachepool\fP \fILV\fP
-.ad b
 .br
-.ad l
     \fB--cachesettings\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--cachesize\fP \fISize\fP[m|UNIT]
-.ad b
 .br
-.ad l
     \fB--cachevol\fP \fILV\fP
-.ad b
 .br
-.ad l
  \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT]
-.ad b
 .br
-.ad l
     \fB--commandprofile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--compression\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--config\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
  \fB-d\fP|\fB--debug\fP
-.ad b
 .br
-.ad l
     \fB--deduplication\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--devices\fP \fIPV\fP
-.ad b
 .br
-.ad l
     \fB--devicesfile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
-.ad b
 .br
-.ad l
     \fB--driverloaded\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--errorwhenfull\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
  \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT]
-.ad b
 .br
-.ad l
  \fB-h\fP|\fB--help\fP
-.ad b
 .br
-.ad l
  \fB-K\fP|\fB--ignoreactivationskip\fP
-.ad b
 .br
-.ad l
     \fB--ignoremonitoring\fP
-.ad b
 .br
-.ad l
     \fB--lockopt\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--longhelp\fP
-.ad b
 .br
-.ad l
  \fB-j\fP|\fB--major\fP \fINumber\fP
-.ad b
 .br
-.ad l
-    \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT]
-.ad b
+    \fB--\fP[\fBraid\fP]\fBmaxrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
-.ad l
     \fB--metadataprofile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--minor\fP \fINumber\fP
-.ad b
 .br
-.ad l
-    \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT]
-.ad b
+    \fB--\fP[\fBraid\fP]\fBminrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
-.ad l
     \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP
-.ad b
 .br
-.ad l
  \fB-m\fP|\fB--mirrors\fP \fINumber\fP
-.ad b
 .br
-.ad l
     \fB--monitor\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
  \fB-n\fP|\fB--name\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--nolocking\fP
-.ad b
 .br
-.ad l
     \fB--nosync\fP
-.ad b
 .br
-.ad l
     \fB--noudevsync\fP
-.ad b
 .br
-.ad l
  \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP
-.ad b
 .br
-.ad l
  \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--poolmetadatasize\fP \fISize\fP[m|UNIT]
-.ad b
 .br
-.ad l
     \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--profile\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-q\fP|\fB--quiet\fP
-.ad b
 .br
-.ad l
     \fB--raidintegrity\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--raidintegrityblocksize\fP \fINumber\fP
-.ad b
 .br
-.ad l
     \fB--raidintegritymode\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
-.ad b
 .br
-.ad l
  \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT]
-.ad b
 .br
-.ad l
     \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
-.ad b
 .br
-.ad l
  \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--setautoactivation\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
  \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
-.ad b
 .br
-.ad l
  \fB-s\fP|\fB--snapshot\fP
-.ad b
 .br
-.ad l
  \fB-i\fP|\fB--stripes\fP \fINumber\fP
-.ad b
 .br
-.ad l
  \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
-.ad b
 .br
-.ad l
  \fB-t\fP|\fB--test\fP
-.ad b
 .br
-.ad l
  \fB-T\fP|\fB--thin\fP
-.ad b
 .br
-.ad l
     \fB--thinpool\fP \fILV\fP
-.ad b
 .br
-.ad l
-    \fB--type\fP 
+    \fB--type\fP \c
 .nh
-\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
+\%\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
 .hy
-.ad b
 .br
-.ad l
     \fB--vdo\fP
-.ad b
 .br
-.ad l
     \fB--vdopool\fP \fILV\fP
-.ad b
 .br
-.ad l
  \fB-v\fP|\fB--verbose\fP
-.ad b
 .br
-.ad l
     \fB--version\fP
-.ad b
 .br
-.ad l
  \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
-.ad b
 .br
-.ad l
  \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
  \fB-y\fP|\fB--yes\fP
-.ad b
 .br
-.ad l
  \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .ad b
+.
 .SH DESCRIPTION
+.
 lvcreate creates a new LV in a VG. For standard LVs, this requires
 allocating logical extents from the VG's free physical extents. If there
 is not enough free space, the VG can be extended with other PVs
 (\fBvgextend\fP(8)), or existing LVs can be reduced or removed
-(\fBlvremove\fP(8), \fBlvreduce\fP(8).)
-
+(\fBlvremove\fP(8), \fBlvreduce\fP(8)).
+.P
 To control which PVs a new LV will use, specify one or more PVs as
 position args at the end of the command line. lvcreate will allocate
 physical extents only from the specified PVs.
-
+.P
 lvcreate can also create snapshots of existing LVs, e.g. for backup
 purposes. The data in a new snapshot LV represents the content of the
 original LV from the time the snapshot was created.
-
+.P
 RAID LVs can be created by specifying an LV type when creating the LV (see
 \fBlvmraid\fP(7)). Different RAID levels require different numbers of
 unique PVs be available in the VG for allocation.
-
+.P
 Thin pools (for thin provisioning) and cache pools (for caching) are
 represented by special LVs with types thin-pool and cache-pool (see
 \fBlvmthin\fP(7) and \fBlvmcache\fP(7)). The pool LVs are not usable as
 standard block devices, but the LV names act as references to the pools.
-
+.P
 Thin LVs are thinly provisioned from a thin pool, and are created with a
 virtual size rather than a physical size. A cache LV is the combination of
 a standard LV with a cache pool, used to cache active portions of the LV
 to improve performance.
-
+.P
 VDO LVs are also provisioned volumes from a VDO pool, and are created with a
 virtual size rather than a physical size (see \fBlvmvdo\fP(7)).
-
+.P
 .SS Usage notes
 In the usage section below, \fB--size\fP \fISize\fP can be replaced
 with \fB--extents\fP \fINumber\fP. See descriptions in the options section.
-
+.P
 In the usage section below, \fB--name\fP is omitted from the required
 options, even though it is typically used. When the name is not
 specified, a new LV name is generated with the "lvol" prefix and a unique
 numeric suffix.
-
+.P
 In the usage section below, when creating a pool and the name is omitted
 the new LV pool name is generated with the
 "vpool" for vdo-pools  for prefix and a unique numeric suffix.
-
+.P
 Pool name can be specified together with \fIVG\fP name i.e.:
 vg00/mythinpool.
+.
 .SH USAGE
+.
 Create a linear LV.
 .br
 .P
@@ -363,20 +226,18 @@ Create a linear LV.
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
 .br
-.ad l
 [    \fB--type\fP \fBlinear\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a striped LV (infers --type striped).
 .br
 .P
@@ -385,20 +246,20 @@ Create a striped LV (infers --type striped).
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
+.br
+[    \fB--type\fP \fBstriped\fP ]
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a raid1 or mirror LV (infers --type raid1|mirror).
 .br
 .P
@@ -407,32 +268,28 @@ Create a raid1 or mirror LV (infers --type raid1|mirror).
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
 .br
-.ad l
+[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+.br
+[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+.br
 [ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP ]
-.ad b
 .br
-.ad l
-[    \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT] ]
-.ad b
+[    \fB--\fP[\fBraid\fP]\fBminrecoveryrate\fP \fISize\fP[k|UNIT] ]
 .br
-.ad l
-[    \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT] ]
-.ad b
+[    \fB--\fP[\fBraid\fP]\fBmaxrecoveryrate\fP \fISize\fP[k|UNIT] ]
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a raid LV (a specific raid level must be used, e.g. raid1).
 .br
 .P
@@ -441,52 +298,34 @@ Create a raid LV (a specific raid level must be used, e.g. raid1).
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
-.br
-.ad l
-[ \fB-m\fP|\fB--mirrors\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
+[ \fB-m\fP|\fB--mirrors\fP \fINumber\fP ]
+.br
 [ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
-[    \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT] ]
-.ad b
+[    \fB--\fP[\fBraid\fP]\fBminrecoveryrate\fP \fISize\fP[k|UNIT] ]
 .br
-.ad l
-[    \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT] ]
-.ad b
+[    \fB--\fP[\fBraid\fP]\fBmaxrecoveryrate\fP \fISize\fP[k|UNIT] ]
 .br
-.ad l
 [    \fB--raidintegrity\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--raidintegritymode\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--raidintegrityblocksize\fP \fINumber\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a raid10 LV.
 .br
 .P
@@ -498,32 +337,24 @@ Create a raid10 LV.
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
-[    \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT] ]
-.ad b
+[    \fB--\fP[\fBraid\fP]\fBminrecoveryrate\fP \fISize\fP[k|UNIT] ]
 .br
-.ad l
-[    \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT] ]
-.ad b
+[    \fB--\fP[\fBraid\fP]\fBmaxrecoveryrate\fP \fISize\fP[k|UNIT] ]
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a COW snapshot LV of an origin LV.
 .br
 .P
@@ -532,32 +363,24 @@ Create a COW snapshot LV of an origin LV.
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--type\fP \fBsnapshot\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a thin pool.
 .br
 .P
@@ -566,48 +389,34 @@ Create a thin pool.
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
-.br
-.ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
-[    \fB--thinpool\fP \fILV\fP\fI_new\fP ]
-.ad b
+[ \fB-T\fP|\fB--thin\fP ]
 .br
-.ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
+[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .br
-.ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
-.ad b
+[    \fB--thinpool\fP \fILV\fP\fI_new\fP ]
 .br
-.ad l
 [    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
-.ad b
 .br
-.ad l
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
-.ad b
+.br
+[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+.br
+[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a cache pool.
 .br
 .P
@@ -616,135 +425,89 @@ Create a cache pool.
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
 .br
-.ad l
-[ \fB-H\fP|\fB--cache\fP ]
-.ad b
+[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .br
-.ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
+[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
 .br
-.ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
+[ \fB-H\fP|\fB--cache\fP ]
 .br
-.ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
-.ad b
+[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .br
-.ad l
 [    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachepolicy\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachesettings\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
-.ad b
+.br
+[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+.br
+[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a thin LV in a thin pool (infers --type thin).
 .br
 .P
-\fBlvcreate\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] \fB--thinpool\fP \fILV\fP\fI_thinpool\fP \fIVG\fP
+\fBlvcreate\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] \fB--thinpool\fP \fILV\fP \fIVG\fP
 .br
 .RS 4
 .ad l
 [ \fB-T\fP|\fB--thin\fP ]
-.ad b
 .br
-.ad l
 [    \fB--type\fP \fBthin\fP ]
-.ad b
-.br
-.ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
-.ad b
-.br
-.ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Create a thin LV that is a snapshot of an existing thin LV 
 .br
 (infers --type thin).
 .br
 .P
-\fBlvcreate\fP \fB-s\fP|\fB--snapshot\fP \fILV\fP\fI_thin\fP
+\fBlvcreate\fP \fB-s\fP|\fB--snapshot\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [    \fB--type\fP \fBthin\fP ]
-.ad b
-.br
-.ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
-.ad b
-.br
-.ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: thin
+.RE
+.P
+\(em
+.P
 Create a thin LV that is a snapshot of an external origin LV.
 .br
 .P
-\fBlvcreate\fP \fB--type\fP \fBthin\fP \fB--thinpool\fP \fILV\fP\fI_thinpool\fP \fILV\fP
+\fBlvcreate\fP \fB--type\fP \fBthin\fP \fB--thinpool\fP \fILV\fP \fILV\fP
 .br
 .RS 4
 .ad l
 [ \fB-T\fP|\fB--thin\fP ]
-.ad b
-.br
-.ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
-.br
-.ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
-.br
-.ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
-.ad b
-.br
-.ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Create a LV that returns VDO when used.
 .br
 .P
@@ -753,99 +516,30 @@ Create a LV that returns VDO when used.
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
 .br
-.ad l
-[ \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] ]
-.ad b
-.br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
+[ \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] ]
+.br
 [    \fB--vdo\fP ]
-.ad b
 .br
-.ad l
 [    \fB--vdopool\fP \fILV\fP\fI_new\fP ]
-.ad b
 .br
-.ad l
 [    \fB--compression\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
-.RE
-.br
-.RS 4
-[ \fIPV\fP ... ]
-.RE
--
-
-Create a thin LV, first creating a thin pool for it, 
-.br
-where the new thin pool is named by the --thinpool arg.
-.br
-.P
-\fBlvcreate\fP \fB--type\fP \fBthin\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
-.RS 5
- \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fB--thinpool\fP \fILV\fP\fI_new\fP
-.RE
-.br
-.RS 4
-.ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
-.br
-.ad l
-[ \fB-T\fP|\fB--thin\fP ]
-.ad b
-.br
-.ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
-.br
-.ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
-.br
-.ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
-.br
-.ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
-.br
-.ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
-.ad b
-.br
-.ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-[ COMMON_OPTIONS ]
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a new LV, then attach the specified cachepool 
 .br
 which converts the new LV to type cache.
@@ -853,62 +547,42 @@ which converts the new LV to type cache.
 .P
 \fBlvcreate\fP \fB--type\fP \fBcache\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
 .RS 5
- \fB--cachepool\fP \fILV\fP\fI_cachepool\fP \fIVG\fP
+ \fB--cachepool\fP \fILV\fP \fIVG\fP
 .RE
 .br
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
 .br
-.ad l
-[ \fB-H\fP|\fB--cache\fP ]
-.ad b
-.br
-.ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
-.br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
+[ \fB-H\fP|\fB--cache\fP ]
 .br
-.ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
-.ad b
+[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .br
-.ad l
 [    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachepolicy\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachesettings\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
-.ad b
+.br
+[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+.br
+[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a new LV, then attach the specified cachevol 
 .br
 which converts the new LV to type cache.
@@ -922,44 +596,30 @@ which converts the new LV to type cache.
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
 .br
-.ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
-.br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
+[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+.br
 [    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachepolicy\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachesettings\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a new LV, then attach a cachevol created from 
 .br
 the specified cache device, which converts the 
@@ -975,48 +635,32 @@ new LV to type cache.
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
 .br
-.ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
-.br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
+[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+.br
+[    \fB--cachesize\fP \fISize\fP[m|UNIT] ]
+.br
 [    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachepolicy\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachesettings\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
-.ad b
-.br
-.ad l
-[    \fB--cachesize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a new LV, then attach the specified cachevol 
 .br
 which converts the new LV to type writecache.
@@ -1030,28 +674,22 @@ which converts the new LV to type writecache.
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--cachesettings\fP \fIString\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a new LV, then attach a cachevol created from 
 .br
 the specified cache device, which converts the 
@@ -1067,201 +705,122 @@ new LV to type writecache.
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--cachesize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--cachesettings\fP \fIString\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Common options for command:
 .
 .RS 4
 .ad l
 [ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
-.ad b
 .br
-.ad l
 [ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
 .br
-.ad l
 [ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-n\fP|\fB--name\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
-.ad b
 .br
-.ad l
 [ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--addtag\fP \fITag\fP ]
-.ad b
 .br
-.ad l
-[    \fB--alloc\fP 
+[    \fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
 ]
-.ad b
 .br
-.ad l
 [    \fB--ignoremonitoring\fP ]
-.ad b
 .br
-.ad l
 [    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--minor\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nosync\fP ]
-.ad b
 .br
-.ad l
 [    \fB--noudevsync\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
-.ad l
 [    \fB--setautoactivation\fP \fBy\fP|\fBn\fP ]
 .ad b
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .br
-.ad b
 Controls the active state of the new LV.
 \fBy\fP makes the LV active, or available.
 New LVs are made active by default.
@@ -1271,24 +830,24 @@ For example, COW snapshots of an active origin LV can only
 be created in the active state (this does not apply to thin snapshots).
 The --zero option normally requires the LV to be active.
 If autoactivation \fBay\fP is used, the LV is only activated
-if it matches an item in lvm.conf activation/auto_activation_volume_list.
+if it matches an item in \fBlvm.conf\fP(5) \fBactivation/auto_activation_volume_list\fP.
 \fBay\fP implies --zero n and --wipesignatures n.
 See \fBlvmlockd\fP(8) for more information about activation options for shared VGs.
+.
 .HP
-.ad l
 \fB--addtag\fP \fITag\fP
 .br
-.ad b
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
+.
 .HP
 .ad l
-\fB--alloc\fP 
+\fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
-.br
 .ad b
+.br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
 which can be changed with vgchange/lvchange, or overridden on the
@@ -1305,38 +864,33 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
+.
 .HP
-.ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
+.
 .HP
-.ad l
 \fB-H\fP|\fB--cache\fP
 .br
-.ad b
 Specifies the command is handling a cache LV or cache pool.
 See --type cache and --type cache-pool.
 See \fBlvmcache\fP(7) for more information about LVM caching.
+.
 .HP
-.ad l
 \fB--cachedevice\fP \fIPV\fP
 .br
-.ad b
 The name of a device to use for a cache.
+.
 .HP
-.ad l
 \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP
 .br
-.ad b
 Specifies the cache metadata format used by cache target.
+.
 .HP
-.ad l
 \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
 .br
-.ad b
 Specifies when writes to a cache LV should be considered complete.
 \fBwriteback\fP considers a write complete as soon as it is
 stored in the cache pool.
@@ -1348,24 +902,21 @@ cache pool LV. With \fBpassthrough\fP, all reads are served
 from the origin LV (all reads miss the cache) and all writes are
 forwarded to the origin LV; additionally, write hits cause cache
 block invalidates. See \fBlvmcache\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--cachepolicy\fP \fIString\fP
 .br
-.ad b
 Specifies the cache policy for a cache LV.
 See \fBlvmcache\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--cachepool\fP \fILV\fP
 .br
-.ad b
 The name of a cache pool.
+.
 .HP
-.ad l
 \fB--cachesettings\fP \fIString\fP
 .br
-.ad b
 Specifies tunable values for a cache LV in "Key = Value" form.
 Repeat this option to specify multiple values.
 (The default values should usually be adequate.)
@@ -1373,23 +924,20 @@ The special string value \fBdefault\fP switches
 settings back to their default kernel values and removes
 them from the list of settings stored in LVM metadata.
 See \fBlvmcache\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--cachesize\fP \fISize\fP[m|UNIT]
 .br
-.ad b
 The size of cache to use.
+.
 .HP
-.ad l
 \fB--cachevol\fP \fILV\fP
 .br
-.ad b
 The name of a cache volume.
+.
 .HP
-.ad l
 \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT]
 .br
-.ad b
 The size of chunks in a snapshot, cache pool or thin pool.
 For snapshots, the value must be a power of 2 between 4KiB and 512KiB
 and the default value is 4.
@@ -1400,76 +948,67 @@ and the default value starts with 64 and scales up to fit the
 pool metadata size within 128MiB, if the pool metadata size is not specified.
 The value must be a multiple of 64KiB.
 See \fBlvmthin\fP(7) and \fBlvmcache\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--compression\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Controls whether compression is enabled or disable for VDO volume.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Sets or resets the contiguous allocation policy for LVs.
 Default is no contiguous allocation based on a next free principle.
 It is only possible to change a non-contiguous allocation policy
 to contiguous if all of the allocated physical extents in the LV
 are already contiguous.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--deduplication\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Controls whether deduplication is enabled or disable for VDO volume.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .br
-.ad b
 Specifies how the device-mapper thin pool layer in the kernel should
 handle discards.
 \fBignore\fP causes the thin pool to ignore discards.
@@ -1478,18 +1017,16 @@ allow reuse of unneeded extents in the thin pool.
 \fBpassdown\fP causes the thin pool to process discards itself
 (like nopassdown) and pass the discards to the underlying device.
 See \fBlvmthin\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB--errorwhenfull\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Specifies thin pool behavior when data space is exhausted.
 When yes, device-mapper will immediately return an error
 when a thin pool is full and an I/O request requires space.
@@ -1498,11 +1035,10 @@ period of time to allow the thin pool to be extended.
 Errors are returned if no space is available after the timeout.
 (Also see dm-thin-pool kernel module option no_space_timeout.)
 See \fBlvmthin\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT]
 .br
-.ad b
 Specifies the size of the new LV in logical extents.
 The --size and --extents options are alternate methods of specifying size.
 The total number of physical extents used will be
@@ -1518,81 +1054,70 @@ the whole origin).
 When expressed as a percentage, the size defines an upper limit for the
 number of logical extents in the new LV. The precise number of logical
 extents in the new LV is not determined until the command has completed.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB-K\fP|\fB--ignoreactivationskip\fP
 .br
-.ad b
 Ignore the "activation skip" LV flag during activation
 to allow LVs with the flag set to be activated.
+.
 .HP
-.ad l
 \fB--ignoremonitoring\fP
 .br
-.ad b
 Do not interact with dmeventd unless --monitor is specified.
 Do not use this if dmeventd is already monitoring a device.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB-j\fP|\fB--major\fP \fINumber\fP
 .br
-.ad b
 Sets the major number of an LV block device.
+.
 .HP
-.ad l
-\fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT]
+\fB--\fP[\fBraid\fP]\fBmaxrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
-.ad b
 Sets the maximum recovery rate for a RAID LV.  The rate value
 is an amount of data per second for each device in the array.
 Setting the rate to 0 means it will be unbounded.
 See \fBlvmraid\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--metadataprofile\fP \fIString\fP
 .br
-.ad b
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--minor\fP \fINumber\fP
 .br
-.ad b
 Sets the minor number of an LV block device.
+.
 .HP
-.ad l
-\fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT]
+\fB--\fP[\fBraid\fP]\fBminrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
-.ad b
 Sets the minimum recovery rate for a RAID LV.  The rate value
 is an amount of data per second for each device in the array.
 Setting the rate to 0 means it will be unbounded.
 See \fBlvmraid\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP
 .br
-.ad b
 Specifies the type of mirror log for LVs with the "mirror" type
 (does not apply to the "raid1" type.)
 \fBdisk\fP is a persistent log and requires a small amount of
@@ -1602,11 +1127,10 @@ In this case, the mirror must be synchronized (by copying LV data from
 the first device to others) each time the LV is activated, e.g. after reboot.
 \fBmirrored\fP is a persistent log that is itself mirrored, but
 should be avoided. Instead, use the raid1 type for log redundancy.
+.
 .HP
-.ad l
 \fB-m\fP|\fB--mirrors\fP \fINumber\fP
 .br
-.ad b
 Specifies the number of mirror images in addition to the original LV
 image, e.g. --mirrors 1 means there are two images of the data, the
 original and one mirror image.
@@ -1616,38 +1140,34 @@ There are two mirroring implementations: "raid1" and "mirror".
 These are the names of the corresponding LV types, or "segment types".
 Use the --type option to specify which to use (raid1 is default,
 and mirror is legacy)
-Use lvm.conf global/mirror_segtype_default and
+Use \fBlvm.conf\fP(5) \fBglobal/mirror_segtype_default\fP and
 global/raid10_segtype_default to configure the default types.
 See the --nosync option for avoiding initial image synchronization.
 See \fBlvmraid\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--monitor\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Start (yes) or stop (no) monitoring an LV with dmeventd.
 dmeventd monitors kernel events for an LV, and performs
 automated maintenance for the LV in reponse to specific events.
 See \fBdmeventd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB-n\fP|\fB--name\fP \fIString\fP
 .br
-.ad b
 Specifies the name of a new LV.
 When unspecified, a default name of "lvol#" is
 generated, where # is a number generated by LVM.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--nosync\fP
 .br
-.ad b
 Causes the creation of mirror, raid1, raid4, raid5 and raid10 to skip the
 initial synchronization. In case of mirror, raid1 and raid10, any data
 written afterwards will be mirrored, but the original contents will not be
@@ -1660,77 +1180,67 @@ This option is not valid for raid6, because raid6 relies on proper parity
 to reconstruct proper user date in case of device failures.
 raid0 and raid0_meta do not provide any data copies or parity support
 and thus do not support initial synchronization.
+.
 .HP
-.ad l
 \fB--noudevsync\fP
 .br
-.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
+.
 .HP
-.ad l
 \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP
 .br
-.ad b
 Set access permission to read only \fBr\fP or read and write \fBrw\fP.
+.
 .HP
-.ad l
 \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 When yes, makes the specified minor number persistent.
+.
 .HP
-.ad l
 \fB--poolmetadatasize\fP \fISize\fP[m|UNIT]
 .br
-.ad b
 Specifies the size of the new pool metadata LV.
+.
 .HP
-.ad l
 \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Enable or disable the automatic creation and management of a
 spare pool metadata LV in the VG. A spare metadata LV is reserved
 space that can be used when repairing a pool.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--raidintegrity\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Enable or disable data integrity checksums for raid images.
+.
 .HP
-.ad l
 \fB--raidintegrityblocksize\fP \fINumber\fP
 .br
-.ad b
 The block size to use for dm-integrity on raid images.
 The integrity block size should usually match the device
 logical block size, or the file system block size.
 It may be less than the file system block size, but not
 less than the device logical block size.
 Possible values: 512, 1024, 2048, 4096.
+.
 .HP
-.ad l
 \fB--raidintegritymode\fP \fIString\fP
 .br
-.ad b
 Use a journal (default) or bitmap for keeping integrity checksums consistent
 in case of a crash. The bitmap areas are recalculated after a crash, so corruption
 in those areas would not be detected. A journal does not have this problem.
@@ -1738,50 +1248,45 @@ The journal mode doubles writes to storage, but can improve performance for
 scattered writes packed into a single journal write.
 bitmap mode can in theory achieve full write throughput of the device,
 but would not benefit from the potential scattered write optimization.
+.
 .HP
-.ad l
 \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
 .br
-.ad b
 Sets read ahead sector count of an LV.
 \fBauto\fP is the default which allows the kernel to choose
 a suitable value automatically.
 \fBnone\fP is equivalent to zero.
+.
 .HP
-.ad l
 \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT]
 .br
-.ad b
 Size of each raid or mirror synchronization region.
-lvm.conf activation/raid_region_size can be used to
+\fBlvm.conf\fP(5) \fBactivation/raid_region_size\fP can be used to
 configure a default.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Persistently sets (yes) or clears (no) the "activation skip" flag on an LV.
 An LV with this flag set is not activated unless the
 --ignoreactivationskip option is used by the activation command.
 This flag is set by default on new thin snapshot LVs.
 The flag is not applied to deactivation.
 The current value of the flag is indicated in the lvs lv_attr bits.
+.
 .HP
-.ad l
 \fB--setautoactivation\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Set the autoactivation property on a VG or LV.
 Display the property with vgs or lvs "-o autoactivation".
 When the autoactivation property is disabled, the VG or LV
@@ -1791,20 +1296,18 @@ If autoactivation is disabled on a VG, no LVs will be autoactivated
 in that VG, and the LV autoactivation property has no effect.
 If autoactivation is enabled on a VG, autoactivation can be disabled
 for individual LVs.
+.
 .HP
-.ad l
 \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
 .br
-.ad b
 Specifies the size of the new LV.
 The --size and --extents options are alternate methods of specifying size.
 The total number of physical extents used will be
 greater when redundant data is needed for RAID levels.
+.
 .HP
-.ad l
 \fB-s\fP|\fB--snapshot\fP
 .br
-.ad b
 Create a snapshot. Snapshots provide a "frozen image" of an origin LV.
 The snapshot LV can be used, e.g. for backups, while the origin LV
 continues to be used.
@@ -1830,11 +1333,10 @@ A small amount of the COW snapshot LV size is used to track COW block
 locations, so the full size is not available for COW data blocks.
 Use lvs to check how much space is used, and see --monitor to
 to automatically extend the size to avoid running out of space.
+.
 .HP
-.ad l
 \fB-i\fP|\fB--stripes\fP \fINumber\fP
 .br
-.ad b
 Specifies the number of stripes in a striped LV. This is the number of
 PVs (devices) that a striped LV is spread across. Data that
 appears sequential in the LV is spread across multiple devices in units of
@@ -1846,46 +1348,43 @@ the RAID type (raid0: 64, raid10: 32, raid4/5: 63, raid6: 62), and
 when unspecified, the default depends on the RAID type
 (raid0: 2, raid10: 2, raid4/5: 3, raid6: 5.)
 To stripe a new raid LV across all PVs by default,
-see lvm.conf allocation/raid_stripe_all_devices.
+see \fBlvm.conf\fP(5) \fBallocation/raid_stripe_all_devices\fP.
+.
 .HP
-.ad l
 \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
 .br
-.ad b
 The amount of data that is written to one device before
 moving to the next in a striped LV.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-T\fP|\fB--thin\fP
 .br
-.ad b
 Specifies the command is handling a thin LV or thin pool.
 See --type thin, --type thin-pool, and --virtualsize.
 See \fBlvmthin\fP(7) for more information about LVM thin provisioning.
+.
 .HP
-.ad l
 \fB--thinpool\fP \fILV\fP
 .br
-.ad b
 The name of a thin pool LV.
+.
 .HP
 .ad l
-\fB--type\fP 
+\fB--type\fP \c
 .nh
-\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
+\%\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
 .hy
-.br
 .ad b
+.br
 The LV type, also known as "segment type" or "segtype".
 See usage descriptions for the specific ways to use these types.
 For more information about redundancy and performance (\fBraid\fP<N>, \fBmirror\fP, \fBstriped\fP, \fBlinear\fP) see \fBlvmraid\fP(7).
@@ -1897,44 +1396,39 @@ Several commands omit an explicit type option because the type
 is inferred from other options or shortcuts
 (e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache, --vdo).
 Use inferred types with care because it can lead to unexpected results.
+.
 .HP
-.ad l
 \fB--vdo\fP
 .br
-.ad b
 Specifies the command is handling VDO LV.
 See --type vdo.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
+.
 .HP
-.ad l
 \fB--vdopool\fP \fILV\fP
 .br
-.ad b
 The name of a VDO pool LV.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
 .br
-.ad b
 The virtual size of a new thin LV.
 See \fBlvmthin\fP(7) for more information about LVM thin provisioning.
 Using virtual size (-V) and actual size (-L) together creates
 a sparse LV.
-lvm.conf global/sparse_segtype_default determines the
+\fBlvm.conf\fP(5) \fBglobal/sparse_segtype_default\fP determines the
 default segment type used to create a sparse LV.
 Anything written to a sparse LV will be returned when reading from it.
 Reading from other areas of the LV will return blocks of zeros.
@@ -1942,61 +1436,57 @@ When using a snapshot to create a sparse LV, a hidden virtual device
 is created using the zero target, and the LV has the suffix _vorigin.
 Snapshots are less efficient than thin provisioning when creating
 large sparse LVs (GiB).
+.
 .HP
-.ad l
 \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Controls detection and subsequent wiping of signatures on new LVs.
 There is a prompt for each signature detected to confirm its wiping
 (unless --yes is used to override confirmations.)
 When not specified, signatures are wiped whenever zeroing is done
 (see --zero). This behaviour can be configured with
-lvm.conf allocation/wipe_signatures_when_zeroing_new_lvs.
-If blkid wiping is used (lvm.conf allocation/use_blkid_wiping)
+\fBlvm.conf\fP(5) \fBallocation/wipe_signatures_when_zeroing_new_lvs\fP.
+If blkid wiping is used (\fBlvm.conf\fP(5) \fBallocation/use_blkid_wiping\fP)
 and LVM is compiled with blkid wiping support, then the blkid(8)
 library is used to detect the signatures (use blkid -k to list the
 signatures that are recognized).
 Otherwise, native LVM code is used to detect signatures
 (only MD RAID, swap and LUKS signatures are detected in this case.)
 The LV is not wiped if the read only flag is set.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .HP
-.ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Controls zeroing of the first 4KiB of data in the new LV.
 Default is \fBy\fP.
 Snapshot COW volumes are always zeroed.
 For thin pools, this controls zeroing of provisioned blocks.
 LV is not zeroed if the read only flag is set.
 Warning: trying to mount an unzeroed LV can cause the system to hang.
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
 For lvcreate, the required VG positional arg may be
 omitted when the VG name is included in another option,
 e.g. --name VG/LV.
-.HP
-\fILV\fP
-.br
+.TP
+.I LV
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-LV followed by _<type> indicates that an LV of the
-given type is required. (raid represents raid<N> type)
-.HP
-\fIPV\fP
-.br
+LV1 indicates the LV must have a specific type, where the
+accepted LV types are listed. (raid represents raid<N> type).
+.TP
+.I PV
 Physical Volume name, a device path under /dev.
 For commands managing physical extents, a PV positional arg
 generally accepts a suffix indicating a range (or multiple ranges)
@@ -2004,26 +1494,42 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
+.
 .SH ADVANCED USAGE
+.
 Alternate command forms, advanced command usage, and listing of all valid syntax for completeness.
 .P
 Create an LV that returns errors when used.
@@ -2034,13 +1540,13 @@ Create an LV that returns errors when used.
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Create an LV that returns zeros when read.
 .br
 .P
@@ -2049,13 +1555,13 @@ Create an LV that returns zeros when read.
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Create a linear LV.
 .br
 .P
@@ -2064,16 +1570,16 @@ Create a linear LV.
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a striped LV (also see lvcreate --stripes).
 .br
 .P
@@ -2082,24 +1588,20 @@ Create a striped LV (also see lvcreate --stripes).
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a mirror LV (also see --type raid1).
 .br
 .P
@@ -2108,36 +1610,26 @@ Create a mirror LV (also see --type raid1).
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
 .br
-.ad l
-[ \fB-m\fP|\fB--mirrors\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
-.ad b
-.br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
+[ \fB-m\fP|\fB--mirrors\fP \fINumber\fP ]
+.br
+[ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
+.br
 [    \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a COW snapshot LV of an origin LV 
 .br
 (also see --snapshot).
@@ -2148,32 +1640,24 @@ Create a COW snapshot LV of an origin LV
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
 .br
-.ad l
 [ \fB-s\fP|\fB--snapshot\fP ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a sparse COW snapshot LV of a virtual origin LV 
 .br
 (also see --snapshot).
@@ -2187,53 +1671,20 @@ Create a sparse COW snapshot LV of a virtual origin LV
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
 .br
-.ad l
 [ \fB-s\fP|\fB--snapshot\fP ]
-.ad b
 .br
-.ad l
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
-.RE
-.br
-.RS 4
-[ \fIPV\fP ... ]
-.RE
--
-
-Create a sparse COW snapshot LV of a virtual origin LV.
-.br
-.P
-\fBlvcreate\fP \fB-s\fP|\fB--snapshot\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
-.RS 5
- \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] \fIVG\fP
-.RE
-.br
-.RS 4
-.ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
-.br
-.ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
-.br
-.ad l
-[    \fB--type\fP \fBsnapshot\fP ]
 .ad b
-.br
-[ COMMON_OPTIONS ]
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a thin pool (infers --type thin-pool).
 .br
 .P
@@ -2242,48 +1693,32 @@ Create a thin pool (infers --type thin-pool).
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
-.br
-.ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
-.br
-.ad l
-[    \fB--type\fP \fBthin-pool\fP ]
-.ad b
 .br
-.ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
+[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .br
-.ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
-.ad b
+[    \fB--type\fP \fBthin-pool\fP ]
 .br
-.ad l
 [    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
-.ad b
 .br
-.ad l
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
-.ad b
+.br
+[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+.br
+[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a thin pool named by the --thinpool arg 
 .br
 (infers --type thin-pool).
@@ -2294,52 +1729,34 @@ Create a thin pool named by the --thinpool arg
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
-.br
-.ad l
-[ \fB-T\fP|\fB--thin\fP ]
-.ad b
-.br
-.ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
-[    \fB--type\fP \fBthin-pool\fP ]
-.ad b
+[ \fB-T\fP|\fB--thin\fP ]
 .br
-.ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
+[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .br
-.ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
-.ad b
+[    \fB--type\fP \fBthin-pool\fP ]
 .br
-.ad l
 [    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
-.ad b
 .br
-.ad l
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
-.ad b
+.br
+[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+.br
+[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a cache pool named by the --cachepool arg 
 .br
 (variant, uses --cachepool in place of --name).
@@ -2353,111 +1770,75 @@ Create a cache pool named by the --cachepool arg
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
 .br
-.ad l
-[ \fB-H\fP|\fB--cache\fP ]
-.ad b
+[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .br
-.ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
+[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
 .br
-.ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
+[ \fB-H\fP|\fB--cache\fP ]
 .br
-.ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
-.ad b
+[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .br
-.ad l
 [    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachepolicy\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachesettings\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
-.ad b
+.br
+[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+.br
+[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a thin LV in a thin pool.
 .br
 .P
 \fBlvcreate\fP \fB--type\fP \fBthin\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
 .RS 5
- \fB--thinpool\fP \fILV\fP\fI_thinpool\fP \fIVG\fP
+ \fB--thinpool\fP \fILV\fP \fIVG\fP
 .RE
 .br
 .RS 4
 .ad l
 [ \fB-T\fP|\fB--thin\fP ]
-.ad b
-.br
-.ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
-.br
-.ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
-.br
-.ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
-.ad b
-.br
-.ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Create a thin LV in a thin pool named in the first arg 
 .br
 (variant, also see --thinpool for naming pool).
 .br
 .P
-\fBlvcreate\fP \fB--type\fP \fBthin\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] \fILV\fP\fI_thinpool\fP
+\fBlvcreate\fP \fB--type\fP \fBthin\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] \fILV1\fP
 .br
 .RS 4
 .ad l
 [ \fB-T\fP|\fB--thin\fP ]
-.ad b
-.br
-.ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
-.ad b
-.br
-.ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: thinpool
+.RE
+.P
+\(em
+.P
 Create a thin LV in the thin pool named in the first arg 
 .br
 (variant, infers --type thin, also see --thinpool for 
@@ -2465,103 +1846,81 @@ Create a thin LV in the thin pool named in the first arg
 naming pool.)
 .br
 .P
-\fBlvcreate\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] \fILV\fP\fI_thinpool\fP
+\fBlvcreate\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] \fILV1\fP
 .br
 .RS 4
 .ad l
 [ \fB-T\fP|\fB--thin\fP ]
-.ad b
 .br
-.ad l
 [    \fB--type\fP \fBthin\fP ]
-.ad b
-.br
-.ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
-.ad b
-.br
-.ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: thinpool
+.RE
+.P
+\(em
+.P
 Create a thin LV that is a snapshot of an existing thin LV.
 .br
 .P
-\fBlvcreate\fP \fB--type\fP \fBthin\fP \fILV\fP\fI_thin\fP
+\fBlvcreate\fP \fB--type\fP \fBthin\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [ \fB-T\fP|\fB--thin\fP ]
-.ad b
-.br
-.ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
-.ad b
-.br
-.ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: thin
+.RE
+.P
+\(em
+.P
 Create a thin LV that is a snapshot of an existing thin LV 
 .br
 (infers --type thin).
 .br
 .P
-\fBlvcreate\fP \fB-T\fP|\fB--thin\fP \fILV\fP\fI_thin\fP
+\fBlvcreate\fP \fB-T\fP|\fB--thin\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [    \fB--type\fP \fBthin\fP ]
-.ad b
-.br
-.ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
-.ad b
-.br
-.ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+.RS 4
+LV1 types: thin
+.RE
+.P
+\(em
+.P
 Create a thin LV that is a snapshot of an external origin LV 
 .br
 (infers --type thin).
 .br
 .P
-\fBlvcreate\fP \fB-s\fP|\fB--snapshot\fP \fB--thinpool\fP \fILV\fP\fI_thinpool\fP \fILV\fP
+\fBlvcreate\fP \fB-s\fP|\fB--snapshot\fP \fB--thinpool\fP \fILV\fP \fILV\fP
 .br
 .RS 4
 .ad l
 [    \fB--type\fP \fBthin\fP ]
-.ad b
-.br
-.ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
-.ad b
-.br
-.ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Create a VDO LV with VDO pool.
 .br
 .P
@@ -2570,40 +1929,30 @@ Create a VDO LV with VDO pool.
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
-.br
-.ad l
-[ \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
+[ \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] ]
+.br
+[    \fB--type\fP \fBvdo\fP ]
+.br
 [    \fB--vdopool\fP \fILV\fP\fI_new\fP ]
-.ad b
 .br
-.ad l
 [    \fB--compression\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a VDO LV with VDO pool.
 .br
 .P
@@ -2612,101 +1961,69 @@ Create a VDO LV with VDO pool.
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
-.br
-.ad l
-[ \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
+[ \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] ]
+.br
 [    \fB--vdo\fP ]
-.ad b
 .br
-.ad l
 [    \fB--type\fP \fBvdo\fP ]
-.ad b
 .br
-.ad l
 [    \fB--compression\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a thin LV, first creating a thin pool for it, 
 .br
-where the new thin pool is named by the --thinpool arg 
-.br
-(variant, infers --type thin).
+where the new thin pool is named by the --thinpool arg.
 .br
 .P
-\fBlvcreate\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
+\fBlvcreate\fP \fB--type\fP \fBthin\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
 .RS 5
- \fB--thinpool\fP \fILV\fP\fI_new\fP
+ \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fB--thinpool\fP \fILV\fP\fI_new\fP \fIVG\fP
 .RE
 .br
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
-.br
-.ad l
-[ \fB-T\fP|\fB--thin\fP ]
-.ad b
-.br
-.ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
+[ \fB-T\fP|\fB--thin\fP ]
 .br
-.ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
-.ad b
+[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .br
-.ad l
 [    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
-.ad b
 .br
-.ad l
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
-.ad b
+.br
+[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+.br
+[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a thin LV, first creating a thin pool for it, 
 .br
 where the new thin pool is named by the --thinpool arg 
@@ -2722,48 +2039,34 @@ where the new thin pool is named by the --thinpool arg
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
-.br
-.ad l
-[ \fB-T\fP|\fB--thin\fP ]
-.ad b
-.br
-.ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
+[ \fB-T\fP|\fB--thin\fP ]
 .br
-.ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
-.ad b
+[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+.br
+[    \fB--type\fP \fBthin\fP ]
 .br
-.ad l
 [    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
-.ad b
 .br
-.ad l
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
-.ad b
+.br
+[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+.br
+[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a thin LV, first creating a thin pool for it, 
 .br
 where the new thin pool is named in the first arg, 
@@ -2781,48 +2084,32 @@ arg is a VG name.
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
-.br
-.ad l
-[ \fB-T\fP|\fB--thin\fP ]
-.ad b
-.br
-.ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
+[ \fB-T\fP|\fB--thin\fP ]
 .br
-.ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
-.ad b
+[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .br
-.ad l
 [    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
-.ad b
 .br
-.ad l
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
-.ad b
+.br
+[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+.br
+[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a thin LV, first creating a thin pool for it, 
 .br
 where the new thin pool is named in the first arg, 
@@ -2840,44 +2127,32 @@ arg is a VG name (variant, infers --type thin).
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
-.br
-.ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
+[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .br
-.ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
-.ad b
+[    \fB--type\fP \fBthin\fP ]
 .br
-.ad l
 [    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
-.ad b
 .br
-.ad l
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
-.ad b
+.br
+[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+.br
+[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a thin LV, first creating a thin pool for it 
 .br
 (infers --type thin). 
@@ -2896,52 +2171,36 @@ config setting sparse_segtype_default.
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
-.br
-.ad l
-[ \fB-s\fP|\fB--snapshot\fP ]
-.ad b
-.br
-.ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
-[    \fB--type\fP \fBsnapshot\fP ]
-.ad b
+[ \fB-s\fP|\fB--snapshot\fP ]
 .br
-.ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
+[ \fB-T\fP|\fB--thin\fP ]
 .br
-.ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
-.ad b
+[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+.br
+[    \fB--type\fP \fIString\fP ]
 .br
-.ad l
 [    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
-.ad b
 .br
-.ad l
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
-.ad b
+.br
+[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+.br
+[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a new LV, then attach the specified cachepool 
 .br
 which converts the new LV to type cache 
@@ -2949,57 +2208,39 @@ which converts the new LV to type cache
 (variant, infers --type cache.)
 .br
 .P
-\fBlvcreate\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fB--cachepool\fP \fILV\fP\fI_cachepool\fP \fIVG\fP
+\fBlvcreate\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fB--cachepool\fP \fILV\fP \fIVG\fP
 .br
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
-.br
-.ad l
-[ \fB-H\fP|\fB--cache\fP ]
-.ad b
-.br
-.ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
+[ \fB-H\fP|\fB--cache\fP ]
+.br
+[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+.br
 [    \fB--type\fP \fBcache\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachepolicy\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachesettings\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Create a new LV, then attach the specified cachepool 
 .br
 which converts the new LV to type cache. 
@@ -3007,61 +2248,45 @@ which converts the new LV to type cache.
 (variant, also use --cachepool).
 .br
 .P
-\fBlvcreate\fP \fB--type\fP \fBcache\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fILV\fP\fI_cachepool\fP
+\fBlvcreate\fP \fB--type\fP \fBcache\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fILV1\fP
 .br
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
-.br
-.ad l
-[ \fB-H\fP|\fB--cache\fP ]
-.ad b
-.br
-.ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
+[ \fB-H\fP|\fB--cache\fP ]
 .br
-.ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
-.ad b
+[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .br
-.ad l
 [    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachepolicy\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachesettings\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
-.ad b
+.br
+[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+.br
+[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+.RS 4
+LV1 types: cachepool
+.RE
+.P
+\(em
+.P
 When the LV arg is a cachepool, then create a new LV and 
 .br
 attach the cachepool arg to it. 
@@ -3078,223 +2303,33 @@ and attach it to the LV arg (alternative, use lvconvert.)
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
-.ad b
 .br
-.ad l
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
+[    \fB--type\fP \fBcache\fP ]
+.br
 [    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachepolicy\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachesettings\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
-.SH EXAMPLES
-
-Create a striped LV with 3 stripes, a stripe size of 8KiB and a size of 100MiB.
-The LV name is chosen by lvcreate.
-.br
-.B lvcreate -i 3 -I 8 -L 100m vg00
-
-Create a raid1 LV with two images, and a useable size of 500 MiB. This
-operation requires two devices, one for each mirror image. RAID metadata
-(superblock and bitmap) is also included on the two devices.
-.br
-.B lvcreate --type raid1 -m1 -L 500m -n mylv vg00
-
-Create a mirror LV with two images, and a useable size of 500 MiB.
-This operation requires three devices: two for mirror images and
-one for a disk log.
-.br
-.B lvcreate --type mirror -m1 -L 500m -n mylv vg00
-
-Create a mirror LV with 2 images, and a useable size of 500 MiB.
-This operation requires 2 devices because the log is in memory.
-.br
-.B lvcreate --type mirror -m1 --mirrorlog core -L 500m -n mylv vg00
-
-Create a copy-on-write snapshot of an LV:
-.br
-.B lvcreate --snapshot --size 100m --name mysnap vg00/mylv
-
-Create a copy-on-write snapshot with a size sufficient
-for overwriting 20% of the size of the original LV.
-.br
-.B lvcreate -s -l 20%ORIGIN -n mysnap vg00/mylv
-
-Create a sparse LV with 1TiB of virtual space, and actual space just under
-100MiB.
-.br
-.B lvcreate --snapshot --virtualsize 1t --size 100m --name mylv vg00
-
-Create a linear LV with a usable size of 64MiB on specific physical extents.
-.br
-.B lvcreate -L 64m -n mylv vg00 /dev/sda:0-7 /dev/sdb:0-7
-
-Create a RAID5 LV with a usable size of 5GiB, 3 stripes, a stripe size of
-64KiB, using a total of 4 devices (including one for parity).
-.br
-.B lvcreate --type raid5 -L 5G -i 3 -I 64 -n mylv vg00
-
-Create a RAID5 LV using all of the free space in the VG and spanning all the
-PVs in the VG (note that the command will fail if there are more than 8 PVs in
-the VG, in which case \fB-i 7\fP must be used to get to the current maximum of
-8 devices including parity for RaidLVs).
-.br
-.B lvcreate --config allocation/raid_stripe_all_devices=1
-.RS
-.B --type raid5 -l 100%FREE -n mylv vg00
-.RE
-
-Create RAID10 LV with a usable size of 5GiB, using 2 stripes, each on
-a two-image mirror. (Note that the \fB-i\fP and \fB-m\fP arguments behave
-differently:
-\fB-i\fP specifies the total number of stripes,
-but \fB-m\fP specifies the number of images in addition
-to the first image).
-.br
-.B lvcreate --type raid10 -L 5G -i 2 -m 1 -n mylv vg00
-
-Create a 1TiB thin LV mythin, with 256GiB thinpool tpool0 in vg00.
-.br
-.B lvcreate --T --size 256G --name mythin vg00/tpool0
-
-Create a 1TiB thin LV, first creating a new thin pool for it, where
-the thin pool has 100MiB of space, uses 2 stripes, has a 64KiB stripe
-size, and 256KiB chunk size.
-.br
-.B lvcreate --type thin --name mylv --thinpool mypool
-.RS
-.B -V 1t -L 100m -i 2 -I 64 -c 256 vg00
-.RE
-
-Create a thin snapshot of a thin LV (the size option must not be
-used, otherwise a copy-on-write snapshot would be created).
-.br
-.B lvcreate --snapshot --name mysnap vg00/thinvol
-
-Create a thin snapshot of the read-only inactive LV named "origin"
-which becomes an external origin for the thin snapshot LV.
-.br
-.B lvcreate --snapshot --name mysnap --thinpool mypool vg00/origin
-
-Create a cache pool from a fast physical device. The cache pool can
-then be used to cache an LV.
-.br
-.B lvcreate --type cache-pool -L 1G -n my_cpool vg00 /dev/fast1
-
-Create a cache LV, first creating a new origin LV on a slow physical device,
-then combining the new origin LV with an existing cache pool.
-.br
-.B lvcreate --type cache --cachepool my_cpool
-.RS
-.B -L 100G -n mylv vg00 /dev/slow1
-.RE
-
-Create a VDO LV vdo0 with VDOPoolLV size of 10GiB and name vpool1.
-.br
-.B lvcreate --vdo --size 10G --name vdo0 vg00/vpool1
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
+.P
+\(em
+.P
diff --git a/man/lvdisplay.8_pregen b/man/lvdisplay.8_pregen
index be1c8b73e..8ff34bc08 100644
--- a/man/lvdisplay.8_pregen
+++ b/man/lvdisplay.8_pregen
@@ -1,363 +1,277 @@
 .TH LVDISPLAY 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-lvdisplay - Display information about a logical volume
+.
+lvdisplay \(em Display information about a logical volume
 .
 .SH SYNOPSIS
+.
 \fBlvdisplay\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 lvdisplay shows the attributes of LVs, like size, read/write status,
 snapshot information, etc.
-
+.P
 \fBlvs\fP(8) is a preferred alternative that shows the same information
 and more, using a more compact and configurable output format.
+.
 .SH USAGE
+.
 \fBlvdisplay\fP
 .br
 .RS 4
 .ad l
 [ \fB-a\fP|\fB--all\fP ]
-.ad b
 .br
-.ad l
 [ \fB-c\fP|\fB--colon\fP ]
-.ad b
 .br
-.ad l
 [ \fB-C\fP|\fB--columns\fP ]
-.ad b
 .br
-.ad l
 [ \fB-H\fP|\fB--history\fP ]
-.ad b
 .br
-.ad l
 [ \fB-m\fP|\fB--maps\fP ]
-.ad b
 .br
-.ad l
 [ \fB-o\fP|\fB--options\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [ \fB-O\fP|\fB--sort\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--aligned\fP ]
-.ad b
 .br
-.ad l
 [    \fB--binary\fP ]
-.ad b
 .br
-.ad l
 [    \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP ]
-.ad b
 .br
-.ad l
 [    \fB--foreign\fP ]
-.ad b
 .br
-.ad l
 [    \fB--ignorelockingfailure\fP ]
-.ad b
 .br
-.ad l
 [    \fB--logonly\fP ]
-.ad b
 .br
-.ad l
 [    \fB--noheadings\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nosuffix\fP ]
-.ad b
 .br
-.ad l
 [    \fB--readonly\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
-.ad l
 [    \fB--segments\fP ]
-.ad b
 .br
-.ad l
 [    \fB--separator\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--shared\fP ]
-.ad b
 .br
-.ad l
 [    \fB--unbuffered\fP ]
-.ad b
 .br
-.ad l
-[    \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP ]
-.ad b
+[    \fB--units\fP \c
+.nh
+\%[\fINumber\fP]\fBr\fP|\:\fBR\fP|\:\fBh\fP|\:\fBH\fP|\:\fBb\fP|\:\fBB\fP|\:\fBs\fP|\:\fBS\fP|\:\fBk\fP|\:\fBK\fP|\:\fBm\fP|\:\fBM\fP|\:\fBg\fP|\:\fBG\fP|\:\fBt\fP|\:\fBT\fP|\:\fBp\fP|\:\fBP\fP|\:\fBe\fP|\:\fBE\fP
+.hy
+]
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIVG\fP|\fILV\fP|\fITag\fP ... ]
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--aligned\fP
 .br
-.ad b
 Use with --separator to align the output columns
+.
 .HP
-.ad l
 \fB-a\fP|\fB--all\fP
 .br
-.ad b
 Show information about internal LVs.
 These are components of normal LVs, such as mirrors,
 which are not independently accessible, e.g. not mountable.
+.
 .HP
-.ad l
 \fB--binary\fP
 .br
-.ad b
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
+.
 .HP
-.ad l
 \fB-c\fP|\fB--colon\fP
 .br
-.ad b
 Generate colon separated output for easier parsing in scripts or programs.
 Also see \fBvgs\fP(8) which provides considerably more control over the output.
+.
 .HP
-.ad l
 \fB-C\fP|\fB--columns\fP
 .br
-.ad b
 Display output in columns, the equivalent of \fBvgs\fP(8).
 Options listed are the same as options given in \fBvgs\fP(8).
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
-.ad b
 See \fBlvmreport\fP(7).
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB--foreign\fP
 .br
-.ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB-H\fP|\fB--history\fP
 .br
-.ad b
 Include historical LVs in the output.
 (This has no effect unless LVs were removed while
-lvm.conf metadata/record_lvs_history was enabled.
+\fBlvm.conf\fP(5) \fBmetadata/record_lvs_history\fP was enabled.
+.
 .HP
-.ad l
 \fB--ignorelockingfailure\fP
 .br
-.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--logonly\fP
 .br
-.ad b
 Suppress command report and display only log report.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB-m\fP|\fB--maps\fP
 .br
-.ad b
 Display the mapping of logical extents to PVs and physical extents.
 To map physical extents to logical extents use:
 pvs --segments -o+lv_name,seg_start_pe,segtype
+.
 .HP
-.ad l
 \fB--noheadings\fP
 .br
-.ad b
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--nosuffix\fP
 .br
-.ad b
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
+.
 .HP
-.ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
 .br
-.ad b
 Comma-separated, ordered list of fields to display in columns.
-String arg syntax is: [+|-|#]Field1[,Field2 ...]
+String arg syntax is: [\fB+\fP|\fB-\fP|\fB#\fP]\fIField1\fP[\fB,\fP\fIField2\fP ...]
 The prefix \fB+\fP will append the specified fields to the default fields,
 \fB-\fP will remove the specified fields from the default fields, and
 \fB#\fP will compact specified fields (removing them when empty for all rows.)
@@ -371,54 +285,48 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBpvseg_all\fP all PV segment fields,
 \fBseg_all\fP all LV segment fields, and
 \fBpvseg_all\fP all PV segment columns.
-See the lvm.conf report section for more config options.
+See the \fBlvm.conf\fP(5) report section for more config options.
 See \fBlvmreport\fP(7) for more information about reporting.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--readonly\fP
 .br
-.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--segments\fP
 .br
-.ad b
+.
 .HP
-.ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
-.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -427,175 +335,115 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
+.
 .HP
-.ad l
 \fB--separator\fP \fIString\fP
 .br
-.ad b
 String to use to separate each column. Useful if grepping the output.
+.
 .HP
-.ad l
 \fB--shared\fP
 .br
-.ad b
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
+.
 .HP
-.ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
 .br
-.ad b
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB--unbuffered\fP
 .br
-.ad b
 Produce output immediately without sorting or aligning the columns properly.
+.
 .HP
 .ad l
-\fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
-.br
+\fB--units\fP \c
+.nh
+\%[\fINumber\fP]\fBr\fP|\:\fBR\fP|\:\fBh\fP|\:\fBH\fP|\:\fBb\fP|\:\fBB\fP|\:\fBs\fP|\:\fBS\fP|\:\fBk\fP|\:\fBK\fP|\:\fBm\fP|\:\fBM\fP|\:\fBg\fP|\:\fBG\fP|\:\fBt\fP|\:\fBT\fP|\:\fBp\fP|\:\fBP\fP|\:\fBe\fP|\:\fBE\fP
+.hy
 .ad b
+.br
 All sizes are output in these units:
 human-(r)eadable with '<' rounding indicator,
 (h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fILV\fP
-.br
+.TP
+.I LV
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-.HP
-\fITag\fP
-.br
+.TP
+.I Tag
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/lvextend.8_pregen b/man/lvextend.8_pregen
index 83216b972..fc4d55233 100644
--- a/man/lvextend.8_pregen
+++ b/man/lvextend.8_pregen
@@ -1,8 +1,11 @@
 .TH LVEXTEND 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-lvextend - Add space to a logical volume
+.
+lvextend \(em Add space to a logical volume
 .
 .SH SYNOPSIS
+.
 \fBlvextend\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
@@ -11,152 +14,94 @@ lvextend - Add space to a logical volume
 .br
 .P
 .ad l
-    \fB--alloc\fP 
+    \fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
-.ad b
 .br
-.ad l
  \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--commandprofile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--config\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-d\fP|\fB--debug\fP
-.ad b
 .br
-.ad l
     \fB--devices\fP \fIPV\fP
-.ad b
 .br
-.ad l
     \fB--devicesfile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--driverloaded\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
  \fB-l\fP|\fB--extents\fP [\fB+\fP]\fINumber\fP[PERCENT]
-.ad b
 .br
-.ad l
  \fB-f\fP|\fB--force\fP
-.ad b
 .br
-.ad l
  \fB-h\fP|\fB--help\fP
-.ad b
 .br
-.ad l
     \fB--lockopt\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--longhelp\fP
-.ad b
 .br
-.ad l
  \fB-m\fP|\fB--mirrors\fP \fINumber\fP
-.ad b
 .br
-.ad l
  \fB-n\fP|\fB--nofsck\fP
-.ad b
 .br
-.ad l
     \fB--nolocking\fP
-.ad b
 .br
-.ad l
     \fB--nosync\fP
-.ad b
 .br
-.ad l
     \fB--noudevsync\fP
-.ad b
 .br
-.ad l
     \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT]
-.ad b
 .br
-.ad l
     \fB--profile\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-q\fP|\fB--quiet\fP
-.ad b
 .br
-.ad l
     \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
-.ad b
 .br
-.ad l
  \fB-r\fP|\fB--resizefs\fP
-.ad b
 .br
-.ad l
  \fB-L\fP|\fB--size\fP [\fB+\fP]\fISize\fP[m|UNIT]
-.ad b
 .br
-.ad l
  \fB-i\fP|\fB--stripes\fP \fINumber\fP
-.ad b
 .br
-.ad l
  \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
-.ad b
 .br
-.ad l
  \fB-t\fP|\fB--test\fP
-.ad b
 .br
-.ad l
-    \fB--type\fP 
+    \fB--type\fP \c
 .nh
-\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
+\%\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
 .hy
-.ad b
 .br
-.ad l
     \fB--usepolicies\fP
-.ad b
 .br
-.ad l
  \fB-v\fP|\fB--verbose\fP
-.ad b
 .br
-.ad l
     \fB--version\fP
-.ad b
 .br
-.ad l
  \fB-y\fP|\fB--yes\fP
 .ad b
+.
 .SH DESCRIPTION
+.
 lvextend extends the size of an LV. This requires allocating logical
 extents from the VG's free physical extents. If the extension adds a new
 LV segment, the new segment will use the existing segment type of the LV.
-
+.P
 Extending a copy-on-write snapshot LV adds space for COW blocks.
-
+.P
 Use \fBlvconvert\fP(8) to change the number of data images in a RAID or
 mirrored LV.
-
+.P
 In the usage section below, \fB--size\fP \fISize\fP can be replaced
 with \fB--extents\fP \fINumber\fP.  See both descriptions
 the options section.
+.
 .SH USAGE
+.
 Extend an LV by a specified size.
 .br
 .P
@@ -165,32 +110,24 @@ Extend an LV by a specified size.
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP [\fB+\fP]\fINumber\fP[PERCENT] ]
-.ad b
 .br
-.ad l
 [ \fB-r\fP|\fB--resizefs\fP ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT] ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Extend an LV by specified PV extents.
 .br
 .P
@@ -199,185 +136,144 @@ Extend an LV by specified PV extents.
 .RS 4
 .ad l
 [ \fB-r\fP|\fB--resizefs\fP ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Extend a pool metadata SubLV by a specified size.
 .br
 .P
-\fBlvextend\fP \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT] \fILV\fP\fI_thinpool\fP
+\fBlvextend\fP \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT] \fILV1\fP
 .br
 .RS 4
 .ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+.RS 4
+LV1 types: thinpool
+.RE
+.P
+\(em
+.P
 Extend an LV according to a predefined policy.
 .br
 .P
-\fBlvextend\fP \fB--usepolicies\fP \fILV\fP\fI_snapshot_thinpool\fP
+\fBlvextend\fP \fB--usepolicies\fP \fILV1\fP
 .br
 .RS 4
 .ad l
 [ \fB-r\fP|\fB--resizefs\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+.RS 4
+LV1 types: snapshot thinpool
+.RE
+.P
+\(em
+.P
 Common options for command:
 .
 .RS 4
 .ad l
 [ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-f\fP|\fB--force\fP ]
-.ad b
 .br
-.ad l
 [ \fB-m\fP|\fB--mirrors\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-n\fP|\fB--nofsck\fP ]
-.ad b
 .br
-.ad l
-[    \fB--alloc\fP 
+[    \fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
 ]
-.ad b
 .br
-.ad l
 [    \fB--nosync\fP ]
-.ad b
 .br
-.ad l
 [    \fB--noudevsync\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
-.ad l
-[    \fB--type\fP 
+[    \fB--type\fP \c
 .nh
-\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
+\%\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
 .hy
 ]
 .ad b
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
 .ad l
-\fB--alloc\fP 
+\fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
-.br
 .ad b
+.br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
 which can be changed with vgchange/lvchange, or overridden on the
@@ -394,66 +290,58 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
+.
 .HP
-.ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-l\fP|\fB--extents\fP [\fB+\fP]\fINumber\fP[PERCENT]
 .br
-.ad b
 Specifies the new size of the LV in logical extents.
 The --size and --extents options are alternate methods of specifying size.
 The total number of physical extents used will be
@@ -472,57 +360,49 @@ extents in the new LV is not determined until the command has completed.
 When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
+.
 .HP
-.ad l
 \fB-f\fP|\fB--force\fP ...
 .br
-.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB-m\fP|\fB--mirrors\fP \fINumber\fP
 .br
-.ad b
 Not used.
+.
 .HP
-.ad l
 \fB-n\fP|\fB--nofsck\fP
 .br
-.ad b
 Do not perform fsck before resizing filesystem when filesystem
 requires it. You may need to use --force to proceed with
 this option.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--nosync\fP
 .br
-.ad b
 Causes the creation of mirror, raid1, raid4, raid5 and raid10 to skip the
 initial synchronization. In case of mirror, raid1 and raid10, any data
 written afterwards will be mirrored, but the original contents will not be
@@ -535,59 +415,52 @@ This option is not valid for raid6, because raid6 relies on proper parity
 to reconstruct proper user date in case of device failures.
 raid0 and raid0_meta do not provide any data copies or parity support
 and thus do not support initial synchronization.
+.
 .HP
-.ad l
 \fB--noudevsync\fP
 .br
-.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
+.
 .HP
-.ad l
 \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT]
 .br
-.ad b
 Specifies the new size of the pool metadata LV.
 The plus prefix \fB+\fP can be used, in which case
 the value is added to the current size.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-r\fP|\fB--resizefs\fP
 .br
-.ad b
 Resize underlying filesystem together with the LV using fsadm(8).
+.
 .HP
-.ad l
 \fB-L\fP|\fB--size\fP [\fB+\fP]\fISize\fP[m|UNIT]
 .br
-.ad b
 Specifies the new size of the LV.
 The --size and --extents options are alternate methods of specifying size.
 The total number of physical extents used will be
@@ -595,11 +468,10 @@ greater when redundant data is needed for RAID levels.
 When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
+.
 .HP
-.ad l
 \fB-i\fP|\fB--stripes\fP \fINumber\fP
 .br
-.ad b
 Specifies the number of stripes in a striped LV. This is the number of
 PVs (devices) that a striped LV is spread across. Data that
 appears sequential in the LV is spread across multiple devices in units of
@@ -611,32 +483,31 @@ the RAID type (raid0: 64, raid10: 32, raid4/5: 63, raid6: 62), and
 when unspecified, the default depends on the RAID type
 (raid0: 2, raid10: 2, raid4/5: 3, raid6: 5.)
 To stripe a new raid LV across all PVs by default,
-see lvm.conf allocation/raid_stripe_all_devices.
+see \fBlvm.conf\fP(5) \fBallocation/raid_stripe_all_devices\fP.
+.
 .HP
-.ad l
 \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
 .br
-.ad b
 The amount of data that is written to one device before
 moving to the next in a striped LV.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
 .ad l
-\fB--type\fP 
+\fB--type\fP \c
 .nh
-\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
+\%\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
 .hy
-.br
 .ad b
+.br
 The LV type, also known as "segment type" or "segtype".
 See usage descriptions for the specific ways to use these types.
 For more information about redundancy and performance (\fBraid\fP<N>, \fBmirror\fP, \fBstriped\fP, \fBlinear\fP) see \fBlvmraid\fP(7).
@@ -648,45 +519,41 @@ Several commands omit an explicit type option because the type
 is inferred from other options or shortcuts
 (e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache, --vdo).
 Use inferred types with care because it can lead to unexpected results.
+.
 .HP
-.ad l
 \fB--usepolicies\fP
 .br
-.ad b
-Perform an operation according to the policy configured in lvm.conf
+Perform an operation according to the policy configured in \fBlvm.conf\fP(5)
 or a profile.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fILV\fP
-.br
+.
+.TP
+.I LV
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-LV followed by _<type> indicates that an LV of the
-given type is required. (raid represents raid<N> type)
-.HP
-\fIPV\fP
-.br
+LV1 indicates the LV must have a specific type, where the
+accepted LV types are listed. (raid represents raid<N> type).
+.TP
+.I PV
 Physical Volume name, a device path under /dev.
 For commands managing physical extents, a PV positional arg
 generally accepts a suffix indicating a range (or multiple ranges)
@@ -694,105 +561,36 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH EXAMPLES
-Extend the size of an LV by 54MiB, using a specific PV.
-.br
-.B lvextend -L +54 vg01/lvol10 /dev/sdk3
-
-Extend the size of an LV by the amount of free
-space on PV /dev/sdk3. This is equivalent to specifying
-"-l +100%PVS" on the command line.
-.br
-.B lvextend vg01/lvol01 /dev/sdk3
-
-Extend an LV by 16MiB using specific physical extents.
-.br
-.B lvextend -L+16m vg01/lvol01 /dev/sda:8-9 /dev/sdb:8-9
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/lvm-fullreport.8_pregen b/man/lvm-fullreport.8_pregen
index 33e2dfaad..399d4ff9a 100644
--- a/man/lvm-fullreport.8_pregen
+++ b/man/lvm-fullreport.8_pregen
@@ -1,330 +1,251 @@
 .TH LVM FULLREPORT 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-lvm fullreport - Display full report
+.
+lvm fullreport \(em Display full report
 .
 .SH SYNOPSIS
+.
 \fBlvm fullreport\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 lvm fullreport produces formatted output about PVs, PV segments, VGs, LVs
 and LV segments. The information is all gathered together for each VG
 (under a per-VG lock) so it is consistent. Information gathered from
 separate calls to \fBvgs\fP, \fBpvs\fP, and \fBlvs\fP can be inconsistent
 if information changes between commands.
+.
 .SH USAGE
+.
 \fBlvm fullreport\fP
 .br
 .RS 4
 .ad l
 [ \fB-a\fP|\fB--all\fP ]
-.ad b
 .br
-.ad l
 [ \fB-o\fP|\fB--options\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [ \fB-O\fP|\fB--sort\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--aligned\fP ]
-.ad b
 .br
-.ad l
 [    \fB--binary\fP ]
-.ad b
 .br
-.ad l
 [    \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP ]
-.ad b
 .br
-.ad l
 [    \fB--foreign\fP ]
-.ad b
 .br
-.ad l
 [    \fB--ignorelockingfailure\fP ]
-.ad b
 .br
-.ad l
 [    \fB--logonly\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nameprefixes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--noheadings\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nosuffix\fP ]
-.ad b
 .br
-.ad l
 [    \fB--readonly\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
-.ad l
 [    \fB--rows\fP ]
-.ad b
 .br
-.ad l
 [    \fB--separator\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--shared\fP ]
-.ad b
 .br
-.ad l
 [    \fB--unbuffered\fP ]
-.ad b
 .br
-.ad l
-[    \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP ]
-.ad b
+[    \fB--units\fP \c
+.nh
+\%[\fINumber\fP]\fBr\fP|\:\fBR\fP|\:\fBh\fP|\:\fBH\fP|\:\fBb\fP|\:\fBB\fP|\:\fBs\fP|\:\fBS\fP|\:\fBk\fP|\:\fBK\fP|\:\fBm\fP|\:\fBM\fP|\:\fBg\fP|\:\fBG\fP|\:\fBt\fP|\:\fBT\fP|\:\fBp\fP|\:\fBP\fP|\:\fBe\fP|\:\fBE\fP
+.hy
+]
 .br
-.ad l
 [    \fB--unquoted\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIVG\fP ... ]
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--aligned\fP
 .br
-.ad b
 Use with --separator to align the output columns
+.
 .HP
-.ad l
 \fB-a\fP|\fB--all\fP
 .br
-.ad b
+.
 .HP
-.ad l
 \fB--binary\fP
 .br
-.ad b
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
-.ad b
 See \fBlvmreport\fP(7).
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB--foreign\fP
 .br
-.ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--ignorelockingfailure\fP
 .br
-.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--logonly\fP
 .br
-.ad b
 Suppress command report and display only log report.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--nameprefixes\fP
 .br
-.ad b
 Add an "LVM2_" prefix plus the field name to the output. Useful
 with --noheadings to produce a list of field=value pairs that can
 be used to set environment variables (for example, in udev rules).
+.
 .HP
-.ad l
 \fB--noheadings\fP
 .br
-.ad b
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--nosuffix\fP
 .br
-.ad b
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
+.
 .HP
-.ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
 .br
-.ad b
 Comma-separated, ordered list of fields to display in columns.
-String arg syntax is: [+|-|#]Field1[,Field2 ...]
+String arg syntax is: [\fB+\fP|\fB-\fP|\fB#\fP]\fIField1\fP[\fB,\fP\fIField2\fP ...]
 The prefix \fB+\fP will append the specified fields to the default fields,
 \fB-\fP will remove the specified fields from the default fields, and
 \fB#\fP will compact specified fields (removing them when empty for all rows.)
@@ -338,55 +259,49 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBpvseg_all\fP all PV segment fields,
 \fBseg_all\fP all LV segment fields, and
 \fBpvseg_all\fP all PV segment columns.
-See the lvm.conf report section for more config options.
+See the \fBlvm.conf\fP(5) report section for more config options.
 See \fBlvmreport\fP(7) for more information about reporting.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--readonly\fP
 .br
-.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--rows\fP
 .br
-.ad b
 Output columns as rows.
+.
 .HP
-.ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
-.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -395,172 +310,113 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
+.
 .HP
-.ad l
 \fB--separator\fP \fIString\fP
 .br
-.ad b
 String to use to separate each column. Useful if grepping the output.
+.
 .HP
-.ad l
 \fB--shared\fP
 .br
-.ad b
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
+.
 .HP
-.ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
 .br
-.ad b
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB--unbuffered\fP
 .br
-.ad b
 Produce output immediately without sorting or aligning the columns properly.
+.
 .HP
 .ad l
-\fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
-.br
+\fB--units\fP \c
+.nh
+\%[\fINumber\fP]\fBr\fP|\:\fBR\fP|\:\fBh\fP|\:\fBH\fP|\:\fBb\fP|\:\fBB\fP|\:\fBs\fP|\:\fBS\fP|\:\fBk\fP|\:\fBK\fP|\:\fBm\fP|\:\fBM\fP|\:\fBg\fP|\:\fBG\fP|\:\fBt\fP|\:\fBT\fP|\:\fBp\fP|\:\fBP\fP|\:\fBe\fP|\:\fBE\fP
+.hy
 .ad b
+.br
 All sizes are output in these units:
 human-(r)eadable with '<' rounding indicator,
 (h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
+.
 .HP
-.ad l
 \fB--unquoted\fP
 .br
-.ad b
 When used with --nameprefixes, output values in the field=value
 pairs are not quoted.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/lvm-lvpoll.8_pregen b/man/lvm-lvpoll.8_pregen
index 3aff67d19..cf18ebeec 100644
--- a/man/lvm-lvpoll.8_pregen
+++ b/man/lvm-lvpoll.8_pregen
@@ -1,381 +1,247 @@
 .TH LVM LVPOLL 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-lvm lvpoll - Continue already initiated poll operation on a logical volume
+.
+lvm lvpoll \(em Continue already initiated poll operation on a logical volume
 .
 .SH SYNOPSIS
+.
 \fBlvm lvpoll\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 lvm lvpoll is an internal command used by \fBlvmpolld\fP(8) to monitor and
 complete \fBlvconvert\fP(8) and \fBpvmove\fP(8) operations. lvpoll itself
 does not initiate these operations and should not normally need to be run
 directly.
+.
 .SH USAGE
+.
 \fBlvm lvpoll\fP \fB--polloperation\fP \fBpvmove\fP|\fBconvert\fP|\fBmerge\fP|\fBmerge_thin\fP \fILV\fP ...
 .br
 .RS 4
 .ad l
 [ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [    \fB--abort\fP ]
-.ad b
 .br
-.ad l
 [    \fB--handlemissingpvs\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--abort\fP
 .br
-.ad b
 Stop processing a poll operation in lvmpolld.
+.
 .HP
-.ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB--handlemissingpvs\fP
 .br
-.ad b
 Allows a polling operation to continue when PVs are missing,
 e.g. for repairs due to faulty devices.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB-i\fP|\fB--interval\fP \fINumber\fP
 .br
-.ad b
 Report progress at regular intervals.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--polloperation\fP \fBpvmove\fP|\fBconvert\fP|\fBmerge\fP|\fBmerge_thin\fP
 .br
-.ad b
 The command to perform from lvmpolld.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fILV\fP
-.br
+.
+.TP
+.I LV
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH NOTES
-
-To find the name of the pvmove LV that was created by an original
-\fBpvmove /dev/name\fP command, use the command:
-.br
-\fBlvs -a -S move_pv=/dev/name\fP.
-.SH EXAMPLES
-
-Continue polling a pvmove operation.
-.br
-.B lvm lvpoll --polloperation pvmove vg00/pvmove0
-
-Abort a pvmove operation.
-.br
-.B lvm lvpoll --polloperation pvmove --abort vg00/pvmove0
-
-Continue polling a mirror conversion.
-.br
-.B lvm lvpoll --polloperation convert vg00/lvmirror
-
-Continue mirror repair.
-.br
-.B lvm lvpoll --polloperation convert vg/damaged_mirror --handlemissingpvs
-
-Continue snapshot merge.
-.br
-.B lvm lvpoll --polloperation merge vg/snapshot_old
-
-Continue thin snapshot merge.
-.br
-.B lvm lvpoll --polloperation merge_thin vg/thin_snapshot
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/lvmconfig.8_pregen b/man/lvmconfig.8_pregen
index 469a6b9e8..6cdb577c1 100644
--- a/man/lvmconfig.8_pregen
+++ b/man/lvmconfig.8_pregen
@@ -1,187 +1,126 @@
 .TH LVMCONFIG 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-lvmconfig - Display and manipulate configuration information
+.
+lvmconfig \(em Display and manipulate configuration information
 .
 .SH SYNOPSIS
+.
 \fBlvmconfig\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 lvmconfig, lvm config, lvm dumpconfig (for compatibility reasons, to be phased out) produce
 formatted output from the LVM configuration tree. The
 sources of the configuration data include \fBlvm.conf\fP(5) and command
 line settings from --config.
+.
 .SH USAGE
+.
 \fBlvmconfig\fP
 .br
 .RS 4
 .ad l
 [ \fB-f\fP|\fB--file\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [ \fB-l\fP|\fB--list\fP ]
-.ad b
 .br
-.ad l
 [    \fB--atversion\fP \fIString\fP ]
-.ad b
 .br
-.ad l
-[    \fB--typeconfig\fP 
+[    \fB--typeconfig\fP \c
 .nh
-\fBcurrent\fP|\:\fBdefault\fP|\:\fBdiff\fP|\:\fBfull\fP|\:\fBlist\fP|\:\fBmissing\fP|\:\fBnew\fP|\:\fBprofilable\fP|\:\fBprofilable-command\fP|\:\fBprofilable-metadata\fP
+\%\fBcurrent\fP|\:\fBdefault\fP|\:\fBdiff\fP|\:\fBfull\fP|\:\fBlist\fP|\:\fBmissing\fP|\:\fBnew\fP|\:\fBprofilable\fP|\:\fBprofilable-command\fP|\:\fBprofilable-metadata\fP
 .hy
 ]
-.ad b
 .br
-.ad l
 [    \fB--ignoreadvanced\fP ]
-.ad b
 .br
-.ad l
 [    \fB--ignoreunsupported\fP ]
-.ad b
 .br
-.ad l
 [    \fB--ignorelocal\fP ]
-.ad b
 .br
-.ad l
 [    \fB--mergedconfig\fP ]
-.ad b
 .br
-.ad l
 [    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--sinceversion\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--showdeprecated\fP ]
-.ad b
 .br
-.ad l
 [    \fB--showunsupported\fP ]
-.ad b
 .br
-.ad l
 [    \fB--validate\fP ]
-.ad b
 .br
-.ad l
 [    \fB--withsummary\fP ]
-.ad b
 .br
-.ad l
 [    \fB--withcomments\fP ]
-.ad b
 .br
-.ad l
 [    \fB--withgeneralpreamble\fP ]
-.ad b
 .br
-.ad l
 [    \fB--withlocalpreamble\fP ]
-.ad b
 .br
-.ad l
 [    \fB--withspaces\fP ]
-.ad b
 .br
-.ad l
 [    \fB--unconfigured\fP ]
-.ad b
 .br
-.ad l
 [    \fB--withversions\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIString\fP ... ]
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--atversion\fP \fIString\fP
 .br
-.ad b
 Specify an LVM version in x.y.z format where x is the major version,
 the y is the minor version and z is the patchlevel (e.g. 2.2.106).
 When configuration is displayed, the configuration settings recognized
@@ -189,116 +128,101 @@ at this LVM version will be considered only. This can be used
 to display a configuration that a certain LVM version understands and
 which does not contain any newer settings for which LVM would
 issue a warning message when checking the configuration.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-f\fP|\fB--file\fP \fIString\fP
 .br
-.ad b
 Write output to the named file.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--ignoreadvanced\fP
 .br
-.ad b
 Exclude advanced configuration settings from the output.
+.
 .HP
-.ad l
 \fB--ignorelocal\fP
 .br
-.ad b
 Ignore the local section. The local section should be defined in
 the lvmlocal.conf file, and should contain config settings
 specific to the local host which should not be copied to
 other hosts.
+.
 .HP
-.ad l
 \fB--ignoreunsupported\fP
 .br
-.ad b
 Exclude unsupported configuration settings from the output. These settings are
 either used for debugging and development purposes only or their support is not
 yet complete and they are not meant to be used in production. The \fBcurrent\fP
 and \fBdiff\fP types include unsupported settings in their output by default,
 all the other types ignore unsupported settings.
+.
 .HP
-.ad l
 \fB-l\fP|\fB--list\fP
 .br
-.ad b
 List config settings with summarizing comment. This is the same as using
 options --typeconfig list --withsummary.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--mergedconfig\fP
 .br
-.ad b
 When the command is run with --config
 and/or --commandprofile (or using LVM_COMMAND_PROFILE
 environment variable), --profile, or --metadataprofile,
@@ -306,81 +230,74 @@ merge all the contents of the "config cascade" before displaying it.
 Without merging, only the configuration at the front of the
 cascade is displayed.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB--metadataprofile\fP \fIString\fP
 .br
-.ad b
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--showdeprecated\fP
 .br
-.ad b
 Include deprecated configuration settings in the output. These settings
 are deprecated after a certain version. If a concrete version is specified
 with --atversion, deprecated settings are automatically included
 if the specified version is lower than the version in which the settings were
 deprecated. The current and diff types include deprecated settings
 in their output by default, all the other types ignore deprecated settings.
+.
 .HP
-.ad l
 \fB--showunsupported\fP
 .br
-.ad b
 Include unsupported configuration settings in the output. These settings
 are either used for debugging or development purposes only, or their support
 is not yet complete and they are not meant to be used in production. The
 current and diff types include unsupported settings in their
 output by default, all the other types ignore unsupported settings.
+.
 .HP
-.ad l
 \fB--sinceversion\fP \fIString\fP
 .br
-.ad b
 Specify an LVM version in x.y.z format where x is the major version,
 the y is the minor version and z is the patchlevel (e.g. 2.2.106).
 This option is currently applicable only with --typeconfig new
 to display all configuration settings introduced since given version.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
 .ad l
-\fB--typeconfig\fP 
+\fB--typeconfig\fP \c
 .nh
-\fBcurrent\fP|\:\fBdefault\fP|\:\fBdiff\fP|\:\fBfull\fP|\:\fBlist\fP|\:\fBmissing\fP|\:\fBnew\fP|\:\fBprofilable\fP|\:\fBprofilable-command\fP|\:\fBprofilable-metadata\fP
+\%\fBcurrent\fP|\:\fBdefault\fP|\:\fBdiff\fP|\:\fBfull\fP|\:\fBlist\fP|\:\fBmissing\fP|\:\fBnew\fP|\:\fBprofilable\fP|\:\fBprofilable-command\fP|\:\fBprofilable-metadata\fP
 .hy
-.br
 .ad b
+.br
 \fBcurrent\fP prints the config settings that would be applied
 to an lvm command (assuming the command does not override them
 on the command line.) This includes:
@@ -413,168 +330,104 @@ with their default values.
 \fBprofilable-command\fP prints settings with their default values that can be set from a command profile.
 \fBprofilable-metadata\fP prints settings with their default values that can be set from a metadata profile.
 Also see \fBlvm.conf\fP(5).
+.
 .HP
-.ad l
 \fB--unconfigured\fP
 .br
-.ad b
 Internal option used for generating config file during build.
+.
 .HP
-.ad l
 \fB--validate\fP
 .br
-.ad b
 Validate current configuration used and exit with appropriate
 return code. The validation is done only for the configuration
 at the front of the "config cascade". To validate the whole
 merged configuration tree, also use --mergedconfig.
-The validation is done even if lvm.conf config/checks is disabled.
+The validation is done even if \fBlvm.conf\fP(5) \fBconfig/checks\fP is disabled.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB--withcomments\fP
 .br
-.ad b
 Display a full comment for each configuration node. For deprecated
 settings, also display comments about deprecation.
+.
 .HP
-.ad l
 \fB--withgeneralpreamble\fP
 .br
-.ad b
 Include general config file preamble.
+.
 .HP
-.ad l
 \fB--withlocalpreamble\fP
 .br
-.ad b
 Include local config file preamble.
+.
 .HP
-.ad l
 \fB--withspaces\fP
 .br
-.ad b
 Where appropriate, add more spaces in output for better readability.
+.
 .HP
-.ad l
 \fB--withsummary\fP
 .br
-.ad b
 Display a one line comment for each configuration node.
+.
 .HP
-.ad l
 \fB--withversions\fP
 .br
-.ad b
 Also display a comment containing the version of introduction for
 each configuration node. If the setting is deprecated, also display
 the version since which it is deprecated.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIString\fP
-.br
+.
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/lvmdevices.8_pregen b/man/lvmdevices.8_pregen
index 6bdb5ff26..267ce965f 100644
--- a/man/lvmdevices.8_pregen
+++ b/man/lvmdevices.8_pregen
@@ -1,8 +1,11 @@
 .TH LVMDEVICES 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-lvmdevices - Manage the devices file
+.
+lvmdevices \(em Manage the devices file
 .
 .SH SYNOPSIS
+.
 \fBlvmdevices\fP \fIoption_args\fP
 .br
     [ \fIoption_args\fP ]
@@ -10,108 +13,68 @@ lvmdevices - Manage the devices file
 .P
 .ad l
     \fB--adddev\fP \fIPV\fP
-.ad b
 .br
-.ad l
     \fB--addpvid\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--check\fP
-.ad b
 .br
-.ad l
     \fB--commandprofile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--config\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-d\fP|\fB--debug\fP
-.ad b
 .br
-.ad l
     \fB--deldev\fP \fIPV\fP
-.ad b
 .br
-.ad l
     \fB--delpvid\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--devices\fP \fIPV\fP
-.ad b
 .br
-.ad l
     \fB--devicesfile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--driverloaded\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
  \fB-h\fP|\fB--help\fP
-.ad b
 .br
-.ad l
     \fB--lockopt\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--longhelp\fP
-.ad b
 .br
-.ad l
     \fB--nolocking\fP
-.ad b
 .br
-.ad l
     \fB--profile\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-q\fP|\fB--quiet\fP
-.ad b
 .br
-.ad l
  \fB-t\fP|\fB--test\fP
-.ad b
 .br
-.ad l
     \fB--update\fP
-.ad b
 .br
-.ad l
  \fB-v\fP|\fB--verbose\fP
-.ad b
 .br
-.ad l
     \fB--version\fP
-.ad b
 .br
-.ad l
  \fB-y\fP|\fB--yes\fP
 .ad b
+.
 .SH DESCRIPTION
+.
 The LVM devices file lists devices that lvm can use.  The default file is
-/etc/lvm/devices/system.devices, and the lvmdevices(8) command is used to
+\fI#DEFAULT_SYS_DIR#/devices/system.devices\fP, and the \fBlvmdevices\fP(8) command is used to
 add or remove device entries.  If the file does not exist, or if lvm.conf
 includes use_devicesfile=0, then lvm will not use a devices file.
-
+.P
 To use a device with lvm, add it to the devices file with the command
 lvmdevices --adddev, and to prevent lvm from seeing or using a device,
 remove it from the devices file with lvmdevices --deldev.  The
 vgimportdevices(8) command adds all PVs from a VG to the devices file,
 and updates the VG metadata to include device IDs of the PVs.
-
+.P
 Commands adding new devices to the devices file necessarily look outside
 the existing devices file to find the devices to add.  pvcreate, vgcreate,
 and vgextend also look outside the devices file to create new PVs and add
 them to the devices file.
-
+.P
 LVM records devices in the devices file using hardware-specific IDs, such
 as the WWID, and attempts to use subsystem-specific IDs for virtual device
 types (which also aim to be as unique and stable as possible.)
@@ -119,436 +82,350 @@ These device IDs are also written in the VG metadata.  When no hardware or
 virtual ID is available, lvm falls back using the unstable device name as
 the device ID.  When devnames are used, lvm performs extra scanning to
 find devices if their devname changes, e.g. after reboot.
-
+.P
 When proper device IDs are used, an lvm command will not look@devices
 outside the devices file, but when devnames are used as a fallback, lvm
 will scan devices outside the devices file to locate PVs on renamed
 devices.  A config setting search_for_devnames can be used to control the
 scanning for renamed devname entries.
-
+.P
 Related to the devices file, the new command option --devices <devnames>
 allows a list of devices to be specified for the command to use,
 overriding the devices file.  The listed devices act as a sort of devices
 file in terms of limiting which devices lvm will see and use.  Devices
 that are not listed will appear to be missing to the lvm command.
-    
-Multiple devices files can be kept in /etc/lvm/devices, which allows lvm
+.P
+Multiple devices files can be kept in \fI#DEFAULT_SYS_DIR#/devices\fP, which allows lvm
 to be used with different sets of devices, e.g. system devices do not need
 to be exposed to a specific application, and the application can use lvm on
 its own devices that are not exposed to the system.  The option
 --devicesfile <filename> is used to select the devices file to use with the
 command.  Without the option set, the default system devices file is used.
-
+.P
 Setting --devicesfile "" causes lvm to not use a devices file.
-
+.P
 With no devices file, lvm will use any device on the system, and applies
 the filter to limit the full set of system devices.  With a devices file,
 the regex filter is not used, and the filter settings in lvm.conf or the
 command line are ignored.  The vgimportdevices command is one exception
 which does apply the regex filter when looking for a VG to import.
-
+.P
 If a devices file exists, lvm will use it, even if it's empty.  An empty
 devices file means lvm will see no devices.
-
+.P
 If the system devices file does not yet exist, the pvcreate or vgcreate
 commands will create it if they see no existing VGs on the system.
 lvmdevices --addev and vgimportdevices will always create a new devices file
 if it does not yet exist.
-
+.P
 It is recommended to use lvm commands to make changes to the devices file to
 ensure proper updates.
-
+.
 .SH USAGE
+.
 Print devices in the devices file.
 .br
 .P
 \fBlvmdevices\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Check the devices file and report incorrect values.
 .br
 .P
 \fBlvmdevices\fP \fB--check\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Update the devices file to fix incorrect values.
 .br
 .P
 \fBlvmdevices\fP \fB--update\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Add a device to the devices file.
 .br
 .P
 \fBlvmdevices\fP \fB--adddev\fP \fIPV\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Remove a device from the devices file.
 .br
 .P
 \fBlvmdevices\fP \fB--deldev\fP \fIPV\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Find the device with the given PVID and add it to the devices file.
 .br
 .P
 \fBlvmdevices\fP \fB--addpvid\fP \fIString\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Remove the devices file entry for the given PVID.
 .br
 .P
 \fBlvmdevices\fP \fB--delpvid\fP \fIString\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Common options for command:
 .
 .RS 4
+.ad l
+.ad b
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--adddev\fP \fIPV\fP
 .br
-.ad b
 Add a device to the devices file.
+.
 .HP
-.ad l
 \fB--addpvid\fP \fIString\fP
 .br
-.ad b
 Find a device with the PVID and add the device to the devices file.
+.
 .HP
-.ad l
 \fB--check\fP
 .br
-.ad b
 Check the content of the devices file.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--deldev\fP \fIPV\fP
 .br
-.ad b
 Remove a device from the devices file.
+.
 .HP
-.ad l
 \fB--delpvid\fP \fIString\fP
 .br
-.ad b
 Remove a device with the PVID from the devices file.
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB--update\fP
 .br
-.ad b
 Update the content of the devices file.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIString\fP
-.br
+.
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/lvmdiskscan.8_pregen b/man/lvmdiskscan.8_pregen
index f6cc0e2e2..5f31e8115 100644
--- a/man/lvmdiskscan.8_pregen
+++ b/man/lvmdiskscan.8_pregen
@@ -1,325 +1,229 @@
 .TH LVMDISKSCAN 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-lvmdiskscan - List devices that may be used as physical volumes
+.
+lvmdiskscan \(em List devices that may be used as physical volumes
 .
 .SH SYNOPSIS
+.
 \fBlvmdiskscan\fP
 .br
     [ \fIoption_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 lvmdiskscan scans all SCSI, (E)IDE disks, multiple devices and a bunch of
 other block devices in the system looking for LVM PVs. The size reported
 is the real device size. Define a filter in \fBlvm.conf\fP(5) to restrict
 the scan to avoid a CD ROM, for example.
-
+.P
 This command is deprecated, use \fBpvs\fP instead.
-
+.
 .SH USAGE
+.
 \fBlvmdiskscan\fP
 .br
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--lvmpartition\fP ]
-.ad b
 .br
-.ad l
 [    \fB--readonly\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB-l\fP|\fB--lvmpartition\fP
 .br
-.ad b
 Only report PVs.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--readonly\fP
 .br
-.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIString\fP
-.br
+.
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/lvreduce.8_pregen b/man/lvreduce.8_pregen
index 49c9465d9..13522bb70 100644
--- a/man/lvreduce.8_pregen
+++ b/man/lvreduce.8_pregen
@@ -1,195 +1,153 @@
 .TH LVREDUCE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-lvreduce - Reduce the size of a logical volume
+.
+lvreduce \(em Reduce the size of a logical volume
 .
 .SH SYNOPSIS
+.
 \fBlvreduce\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 lvreduce reduces the size of an LV. The freed logical extents are returned
 to the VG to be used by other LVs. A copy-on-write snapshot LV can also
 be reduced if less space is needed to hold COW blocks. Use
 \fBlvconvert\fP(8) to change the number of data images in a RAID or
 mirrored LV.
-
+.P
 Be careful when reducing an LV's size, because data in the reduced area is
 lost. Ensure that any file system on the LV is resized \fBbefore\fP
 running lvreduce so that the removed extents are not in use by the file
 system.
-
+.P
 Sizes will be rounded if necessary. For example, the LV size must be an
 exact number of extents, and the size of a striped segment must be a
 multiple of the number of stripes.
-
+.P
 In the usage section below, \fB--size\fP \fISize\fP can be replaced
 with \fB--extents\fP \fINumber\fP.  See both descriptions
 the options section.
+.
 .SH USAGE
+.
 \fBlvreduce\fP \fB-L\fP|\fB--size\fP [\fB-\fP]\fISize\fP[m|UNIT] \fILV\fP
 .br
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP [\fB-\fP]\fINumber\fP[PERCENT] ]
-.ad b
 .br
-.ad l
 [ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-f\fP|\fB--force\fP ]
-.ad b
 .br
-.ad l
 [ \fB-n\fP|\fB--nofsck\fP ]
-.ad b
 .br
-.ad l
 [ \fB-r\fP|\fB--resizefs\fP ]
-.ad b
 .br
-.ad l
 [    \fB--noudevsync\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-l\fP|\fB--extents\fP [\fB-\fP]\fINumber\fP[PERCENT]
 .br
-.ad b
 Specifies the new size of the LV in logical extents.
 The --size and --extents options are alternate methods of specifying size.
 The total number of physical extents used will be
@@ -208,91 +166,79 @@ extents in the new LV is not determined until the command has completed.
 When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
+.
 .HP
-.ad l
 \fB-f\fP|\fB--force\fP ...
 .br
-.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB-n\fP|\fB--nofsck\fP
 .br
-.ad b
 Do not perform fsck before resizing filesystem when filesystem
 requires it. You may need to use --force to proceed with
 this option.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--noudevsync\fP
 .br
-.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-r\fP|\fB--resizefs\fP
 .br
-.ad b
 Resize underlying filesystem together with the LV using fsadm(8).
+.
 .HP
-.ad l
 \fB-L\fP|\fB--size\fP [\fB-\fP]\fISize\fP[m|UNIT]
 .br
-.ad b
 Specifies the new size of the LV.
 The --size and --extents options are alternate methods of specifying size.
 The total number of physical extents used will be
@@ -300,133 +246,70 @@ greater when redundant data is needed for RAID levels.
 When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fILV\fP
-.br
+.
+.TP
+.I LV
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH EXAMPLES
-
-Reduce the size of an LV by 3 logical extents:
-.br
-.B lvreduce -l -3 vg00/lvol1
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/lvremove.8_pregen b/man/lvremove.8_pregen
index 53ba71e0b..a5ed82666 100644
--- a/man/lvremove.8_pregen
+++ b/man/lvremove.8_pregen
@@ -1,28 +1,33 @@
 .TH LVREMOVE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-lvremove - Remove logical volume(s) from the system
+.
+lvremove \(em Remove logical volume(s) from the system
 .
 .SH SYNOPSIS
+.
 \fBlvremove\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 lvremove removes one or more LVs. For standard LVs, this returns the
 logical extents that were used by the LV to the VG for use by other LVs.
-
+.P
 Confirmation will be requested before deactivating any active LV prior to
 removal.  LVs cannot be deactivated or removed while they are open (e.g.
 if they contain a mounted filesystem). Removing an origin LV will also
 remove all dependent snapshots.
-
+.P
 When a single force option is used, LVs are removed without confirmation,
 and the command will try to deactivate unused LVs.
-
+.P
 To remove damaged LVs, two force options may be required (\fB-ff\fP).
-
+.P
 \fBHistorical LVs\fP
-
+.P
 If the configuration setting \fBmetadata/record_lvs_history\fP is enabled
 and the LV being removed forms part of the history of at least one LV that
 is still present, then a simplified representation of the LV will be
@@ -34,240 +39,185 @@ some intermediate LVs have been removed. The names of such historical LVs
 acquire a hyphen as a prefix (e.g. '-lvol1') and cannot be reactivated.
 Use lvremove a second time, with the hyphen, to remove the record of the
 former LV completely.
+.
 .SH USAGE
+.
 \fBlvremove\fP \fIVG\fP|\fILV\fP|\fITag\fP|\fISelect\fP ...
 .br
 .RS 4
 .ad l
 [ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-f\fP|\fB--force\fP ]
-.ad b
 .br
-.ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nohistory\fP ]
-.ad b
 .br
-.ad l
 [    \fB--noudevsync\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-f\fP|\fB--force\fP ...
 .br
-.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--nohistory\fP
 .br
-.ad b
 Do not record history of LVs being removed.
 This has no effect unless the configuration setting
 metadata/record_lvs_history is enabled.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--noudevsync\fP
 .br
-.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
-.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -276,151 +226,82 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fILV\fP
-.br
+.TP
+.I LV
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-.HP
-\fITag\fP
-.br
+.TP
+.I Tag
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
-\fISelect\fP
-.br
+.TP
+.I Select
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH EXAMPLES
-Remove an active LV without asking for confirmation.
-.br
-.B lvremove -f vg00/lvol1
-
-Remove all LVs the specified VG.
-.br
-.B lvremove vg00
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/lvrename.8_pregen b/man/lvrename.8_pregen
index 024da1821..5b5975fa3 100644
--- a/man/lvrename.8_pregen
+++ b/man/lvrename.8_pregen
@@ -1,363 +1,257 @@
 .TH LVRENAME 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-lvrename - Rename a logical volume
+.
+lvrename \(em Rename a logical volume
 .
 .SH SYNOPSIS
+.
 \fBlvrename\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 lvrename renames an existing LV or a historical LV (see \fBlvremove\fP for
 historical LV information.)
+.
 .SH USAGE
+.
 \fBlvrename\fP \fIVG\fP \fILV\fP \fILV\fP\fI_new\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 \fBlvrename\fP \fILV\fP \fILV\fP\fI_new\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Common options for command:
 .
 .RS 4
 .ad l
 [ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--noudevsync\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--noudevsync\fP
 .br
-.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fILV\fP
-.br
+.TP
+.I LV
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH EXAMPLES
-
-Rename "lvold" to "lvnew":
-.br
-.B lvrename /dev/vg02/lvold vg02/lvnew
-
-An alternate syntax to rename "lvold" to "lvnew":
-.br
-.B lvrename vg02 lvold lvnew
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/lvresize.8_pregen b/man/lvresize.8_pregen
index f3535ce7f..4e27cf4ee 100644
--- a/man/lvresize.8_pregen
+++ b/man/lvresize.8_pregen
@@ -1,8 +1,11 @@
 .TH LVRESIZE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-lvresize - Resize a logical volume
+.
+lvresize \(em Resize a logical volume
 .
 .SH SYNOPSIS
+.
 \fBlvresize\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
@@ -11,138 +14,84 @@ lvresize - Resize a logical volume
 .br
 .P
 .ad l
-    \fB--alloc\fP 
+    \fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
-.ad b
 .br
-.ad l
  \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--commandprofile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--config\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-d\fP|\fB--debug\fP
-.ad b
 .br
-.ad l
     \fB--devices\fP \fIPV\fP
-.ad b
 .br
-.ad l
     \fB--devicesfile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--driverloaded\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
  \fB-l\fP|\fB--extents\fP [\fB+\fP|\fB-\fP]\fINumber\fP[PERCENT]
-.ad b
 .br
-.ad l
  \fB-f\fP|\fB--force\fP
-.ad b
 .br
-.ad l
  \fB-h\fP|\fB--help\fP
-.ad b
 .br
-.ad l
     \fB--lockopt\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--longhelp\fP
-.ad b
 .br
-.ad l
  \fB-n\fP|\fB--nofsck\fP
-.ad b
 .br
-.ad l
     \fB--nolocking\fP
-.ad b
 .br
-.ad l
     \fB--nosync\fP
-.ad b
 .br
-.ad l
     \fB--noudevsync\fP
-.ad b
 .br
-.ad l
     \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT]
-.ad b
 .br
-.ad l
     \fB--profile\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-q\fP|\fB--quiet\fP
-.ad b
 .br
-.ad l
     \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
-.ad b
 .br
-.ad l
  \fB-r\fP|\fB--resizefs\fP
-.ad b
 .br
-.ad l
  \fB-L\fP|\fB--size\fP [\fB+\fP|\fB-\fP]\fISize\fP[m|UNIT]
-.ad b
 .br
-.ad l
  \fB-i\fP|\fB--stripes\fP \fINumber\fP
-.ad b
 .br
-.ad l
  \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
-.ad b
 .br
-.ad l
  \fB-t\fP|\fB--test\fP
-.ad b
 .br
-.ad l
-    \fB--type\fP 
+    \fB--type\fP \c
 .nh
-\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
+\%\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
 .hy
-.ad b
 .br
-.ad l
  \fB-v\fP|\fB--verbose\fP
-.ad b
 .br
-.ad l
     \fB--version\fP
-.ad b
 .br
-.ad l
  \fB-y\fP|\fB--yes\fP
 .ad b
+.
 .SH DESCRIPTION
+.
 lvresize resizes an LV in the same way as lvextend and lvreduce. See
 \fBlvextend\fP(8) and \fBlvreduce\fP(8) for more information.
-
+.P
 In the usage section below, \fB--size\fP \fISize\fP can be replaced
 with \fB--extents\fP \fINumber\fP.  See both descriptions
 the options section.
+.
 .SH USAGE
+.
 Resize an LV by a specified size.
 .br
 .P
@@ -151,24 +100,20 @@ Resize an LV by a specified size.
 .RS 4
 .ad l
 [ \fB-l\fP|\fB--extents\fP [\fB+\fP|\fB-\fP]\fINumber\fP[PERCENT] ]
-.ad b
 .br
-.ad l
 [ \fB-r\fP|\fB--resizefs\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT] ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Resize an LV by specified PV extents.
 .br
 .P
@@ -177,155 +122,116 @@ Resize an LV by specified PV extents.
 .RS 4
 .ad l
 [ \fB-r\fP|\fB--resizefs\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Resize a pool metadata SubLV by a specified size.
 .br
 .P
-\fBlvresize\fP \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT] \fILV\fP\fI_thinpool\fP
+\fBlvresize\fP \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT] \fILV1\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
--
-
+.P
+.RS 4
+LV1 types: thinpool
+.RE
+.P
+\(em
+.P
 Common options for command:
 .
 .RS 4
 .ad l
 [ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-f\fP|\fB--force\fP ]
-.ad b
 .br
-.ad l
 [ \fB-n\fP|\fB--nofsck\fP ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
-[    \fB--alloc\fP 
+[    \fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
 ]
-.ad b
 .br
-.ad l
 [    \fB--nosync\fP ]
-.ad b
 .br
-.ad l
 [    \fB--noudevsync\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
-.ad l
-[    \fB--type\fP 
+[    \fB--type\fP \c
 .nh
-\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
+\%\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
 .hy
 ]
 .ad b
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
 .ad l
-\fB--alloc\fP 
+\fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
-.br
 .ad b
+.br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
 which can be changed with vgchange/lvchange, or overridden on the
@@ -342,66 +248,58 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
+.
 .HP
-.ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-l\fP|\fB--extents\fP [\fB+\fP|\fB-\fP]\fINumber\fP[PERCENT]
 .br
-.ad b
 Specifies the new size of the LV in logical extents.
 The --size and --extents options are alternate methods of specifying size.
 The total number of physical extents used will be
@@ -420,51 +318,44 @@ extents in the new LV is not determined until the command has completed.
 When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
+.
 .HP
-.ad l
 \fB-f\fP|\fB--force\fP ...
 .br
-.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB-n\fP|\fB--nofsck\fP
 .br
-.ad b
 Do not perform fsck before resizing filesystem when filesystem
 requires it. You may need to use --force to proceed with
 this option.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--nosync\fP
 .br
-.ad b
 Causes the creation of mirror, raid1, raid4, raid5 and raid10 to skip the
 initial synchronization. In case of mirror, raid1 and raid10, any data
 written afterwards will be mirrored, but the original contents will not be
@@ -477,59 +368,52 @@ This option is not valid for raid6, because raid6 relies on proper parity
 to reconstruct proper user date in case of device failures.
 raid0 and raid0_meta do not provide any data copies or parity support
 and thus do not support initial synchronization.
+.
 .HP
-.ad l
 \fB--noudevsync\fP
 .br
-.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
+.
 .HP
-.ad l
 \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT]
 .br
-.ad b
 Specifies the new size of the pool metadata LV.
 The plus prefix \fB+\fP can be used, in which case
 the value is added to the current size.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-r\fP|\fB--resizefs\fP
 .br
-.ad b
 Resize underlying filesystem together with the LV using fsadm(8).
+.
 .HP
-.ad l
 \fB-L\fP|\fB--size\fP [\fB+\fP|\fB-\fP]\fISize\fP[m|UNIT]
 .br
-.ad b
 Specifies the new size of the LV.
 The --size and --extents options are alternate methods of specifying size.
 The total number of physical extents used will be
@@ -537,11 +421,10 @@ greater when redundant data is needed for RAID levels.
 When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
+.
 .HP
-.ad l
 \fB-i\fP|\fB--stripes\fP \fINumber\fP
 .br
-.ad b
 Specifies the number of stripes in a striped LV. This is the number of
 PVs (devices) that a striped LV is spread across. Data that
 appears sequential in the LV is spread across multiple devices in units of
@@ -553,32 +436,31 @@ the RAID type (raid0: 64, raid10: 32, raid4/5: 63, raid6: 62), and
 when unspecified, the default depends on the RAID type
 (raid0: 2, raid10: 2, raid4/5: 3, raid6: 5.)
 To stripe a new raid LV across all PVs by default,
-see lvm.conf allocation/raid_stripe_all_devices.
+see \fBlvm.conf\fP(5) \fBallocation/raid_stripe_all_devices\fP.
+.
 .HP
-.ad l
 \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
 .br
-.ad b
 The amount of data that is written to one device before
 moving to the next in a striped LV.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
 .ad l
-\fB--type\fP 
+\fB--type\fP \c
 .nh
-\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
+\%\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
 .hy
-.br
 .ad b
+.br
 The LV type, also known as "segment type" or "segtype".
 See usage descriptions for the specific ways to use these types.
 For more information about redundancy and performance (\fBraid\fP<N>, \fBmirror\fP, \fBstriped\fP, \fBlinear\fP) see \fBlvmraid\fP(7).
@@ -590,38 +472,35 @@ Several commands omit an explicit type option because the type
 is inferred from other options or shortcuts
 (e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache, --vdo).
 Use inferred types with care because it can lead to unexpected results.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fILV\fP
-.br
+.
+.TP
+.I LV
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-LV followed by _<type> indicates that an LV of the
-given type is required. (raid represents raid<N> type)
-.HP
-\fIPV\fP
-.br
+LV1 indicates the LV must have a specific type, where the
+accepted LV types are listed. (raid represents raid<N> type).
+.TP
+.I PV
 Physical Volume name, a device path under /dev.
 For commands managing physical extents, a PV positional arg
 generally accepts a suffix indicating a range (or multiple ranges)
@@ -629,96 +508,36 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH EXAMPLES
-
-Extend an LV by 16MB using specific physical extents:
-.br
-.B lvresize -L+16M vg1/lv1 /dev/sda:0-1 /dev/sdb:0-1
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index 76ea404c7..d822347a1 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -1,345 +1,261 @@
 .TH LVS 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-lvs - Display information about logical volumes
+.
+lvs \(em Display information about logical volumes
 .
 .SH SYNOPSIS
+.
 \fBlvs\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 lvs produces formatted output about LVs.
+.
 .SH USAGE
+.
 \fBlvs\fP
 .br
 .RS 4
 .ad l
 [ \fB-H\fP|\fB--history\fP ]
-.ad b
 .br
-.ad l
 [ \fB-a\fP|\fB--all\fP ]
-.ad b
 .br
-.ad l
 [ \fB-o\fP|\fB--options\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [ \fB-O\fP|\fB--sort\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--segments\fP ]
-.ad b
 .br
-.ad l
 [    \fB--aligned\fP ]
-.ad b
 .br
-.ad l
 [    \fB--binary\fP ]
-.ad b
 .br
-.ad l
 [    \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP ]
-.ad b
 .br
-.ad l
 [    \fB--foreign\fP ]
-.ad b
 .br
-.ad l
 [    \fB--ignorelockingfailure\fP ]
-.ad b
 .br
-.ad l
 [    \fB--logonly\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nameprefixes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--noheadings\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nosuffix\fP ]
-.ad b
 .br
-.ad l
 [    \fB--readonly\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
-.ad l
 [    \fB--rows\fP ]
-.ad b
 .br
-.ad l
 [    \fB--separator\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--shared\fP ]
-.ad b
 .br
-.ad l
 [    \fB--unbuffered\fP ]
-.ad b
 .br
-.ad l
-[    \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP ]
-.ad b
+[    \fB--units\fP \c
+.nh
+\%[\fINumber\fP]\fBr\fP|\:\fBR\fP|\:\fBh\fP|\:\fBH\fP|\:\fBb\fP|\:\fBB\fP|\:\fBs\fP|\:\fBS\fP|\:\fBk\fP|\:\fBK\fP|\:\fBm\fP|\:\fBM\fP|\:\fBg\fP|\:\fBG\fP|\:\fBt\fP|\:\fBT\fP|\:\fBp\fP|\:\fBP\fP|\:\fBe\fP|\:\fBE\fP
+.hy
+]
 .br
-.ad l
 [    \fB--unquoted\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIVG\fP|\fILV\fP|\fITag\fP ... ]
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--aligned\fP
 .br
-.ad b
 Use with --separator to align the output columns
+.
 .HP
-.ad l
 \fB-a\fP|\fB--all\fP
 .br
-.ad b
 Show information about internal LVs.
 These are components of normal LVs, such as mirrors,
 which are not independently accessible, e.g. not mountable.
+.
 .HP
-.ad l
 \fB--binary\fP
 .br
-.ad b
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
-.ad b
 See \fBlvmreport\fP(7).
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB--foreign\fP
 .br
-.ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB-H\fP|\fB--history\fP
 .br
-.ad b
 Include historical LVs in the output.
 (This has no effect unless LVs were removed while
-lvm.conf metadata/record_lvs_history was enabled.
+\fBlvm.conf\fP(5) \fBmetadata/record_lvs_history\fP was enabled.
+.
 .HP
-.ad l
 \fB--ignorelockingfailure\fP
 .br
-.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--logonly\fP
 .br
-.ad b
 Suppress command report and display only log report.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--nameprefixes\fP
 .br
-.ad b
 Add an "LVM2_" prefix plus the field name to the output. Useful
 with --noheadings to produce a list of field=value pairs that can
 be used to set environment variables (for example, in udev rules).
+.
 .HP
-.ad l
 \fB--noheadings\fP
 .br
-.ad b
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--nosuffix\fP
 .br
-.ad b
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
+.
 .HP
-.ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
 .br
-.ad b
 Comma-separated, ordered list of fields to display in columns.
-String arg syntax is: [+|-|#]Field1[,Field2 ...]
+String arg syntax is: [\fB+\fP|\fB-\fP|\fB#\fP]\fIField1\fP[\fB,\fP\fIField2\fP ...]
 The prefix \fB+\fP will append the specified fields to the default fields,
 \fB-\fP will remove the specified fields from the default fields, and
 \fB#\fP will compact specified fields (removing them when empty for all rows.)
@@ -353,61 +269,54 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBpvseg_all\fP all PV segment fields,
 \fBseg_all\fP all LV segment fields, and
 \fBpvseg_all\fP all PV segment columns.
-See the lvm.conf report section for more config options.
+See the \fBlvm.conf\fP(5) report section for more config options.
 See \fBlvmreport\fP(7) for more information about reporting.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--readonly\fP
 .br
-.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--rows\fP
 .br
-.ad b
 Output columns as rows.
+.
 .HP
-.ad l
 \fB--segments\fP
 .br
-.ad b
 Use default columns that emphasize segment information.
+.
 .HP
-.ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
-.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -416,264 +325,121 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
+.
 .HP
-.ad l
 \fB--separator\fP \fIString\fP
 .br
-.ad b
 String to use to separate each column. Useful if grepping the output.
+.
 .HP
-.ad l
 \fB--shared\fP
 .br
-.ad b
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
+.
 .HP
-.ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
 .br
-.ad b
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB--unbuffered\fP
 .br
-.ad b
 Produce output immediately without sorting or aligning the columns properly.
+.
 .HP
 .ad l
-\fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
-.br
+\fB--units\fP \c
+.nh
+\%[\fINumber\fP]\fBr\fP|\:\fBR\fP|\:\fBh\fP|\:\fBH\fP|\:\fBb\fP|\:\fBB\fP|\:\fBs\fP|\:\fBS\fP|\:\fBk\fP|\:\fBK\fP|\:\fBm\fP|\:\fBM\fP|\:\fBg\fP|\:\fBG\fP|\:\fBt\fP|\:\fBT\fP|\:\fBp\fP|\:\fBP\fP|\:\fBe\fP|\:\fBE\fP
+.hy
 .ad b
+.br
 All sizes are output in these units:
 human-(r)eadable with '<' rounding indicator,
 (h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
+.
 .HP
-.ad l
 \fB--unquoted\fP
 .br
-.ad b
 When used with --nameprefixes, output values in the field=value
 pairs are not quoted.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fILV\fP
-.br
+.TP
+.I LV
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-.HP
-\fITag\fP
-.br
+.TP
+.I Tag
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH NOTES
-.
-The lv_attr bits are:
-.IP 1 3
-Volume type: (C)ache, (m)irrored, (M)irrored without initial sync, (o)rigin,
-(O)rigin with merging snapshot, (r)aid, (R)aid without initial sync,
-(s)napshot, merging (S)napshot, (p)vmove, (v)irtual,
-mirror or raid (i)mage, mirror or raid (I)mage out-of-sync, mirror (l)og device,
-under (c)onversion, thin (V)olume, (t)hin pool, (T)hin pool data,
-v(d)o pool, v(D)o pool data,
-raid or pool m(e)tadata or pool metadata spare.
-.IP 2 3
-Permissions: (w)riteable, (r)ead-only, (R)ead-only activation of non-read-only
-volume
-.IP 3 3
-Allocation policy:  (a)nywhere, (c)ontiguous, (i)nherited, c(l)ing, (n)ormal
-This is capitalised if the volume is currently locked against allocation
-changes, for example during
-.BR pvmove (8).
-.IP 4 3
-fixed (m)inor
-.IP 5 3
-State: @ctive, (h)istorical, (s)uspended, (I)nvalid snapshot,
-invalid (S)uspended snapshot, snapshot (m)erge failed,
-suspended snapshot (M)erge failed, mapped (d)evice present without tables,
-mapped device present with (i)nactive table, thin-pool (c)heck needed,
-suspended thin-pool (C)heck needed, (X) unknown
-.IP 6 3
-device (o)pen, (X) unknown
-.IP 7 3
-Target type: (C)ache, (m)irror, (r)aid, (s)napshot, (t)hin, (u)nknown, (v)irtual.
-This groups logical volumes related to the same kernel target together.  So,
-for example, mirror images, mirror logs as well as mirrors themselves appear as
-(m) if they use the original device-mapper mirror kernel driver; whereas the raid
-equivalents using the md raid kernel driver all appear as (r).
-Snapshots using the original device-mapper driver appear as (s); whereas
-snapshots of thin volumes using the new thin provisioning driver appear as (t).
-.IP 8 3
-Newly-allocated data blocks are overwritten with blocks of (z)eroes before use.
-.IP 9 3
-Volume Health, where there are currently three groups of attributes identified:
-.IP
-Common ones for all Logical Volumes: (p)artial, (X) unknown.
-.br
-(p)artial signifies that one or more of the Physical Volumes this Logical
-Volume uses is missing from the system. (X) unknown signifies the status
-is unknown.
-.IP
-Related to RAID Logical Volumes: (r)efresh needed, (m)ismatches exist, (w)ritemostly.
-.br
-(r)efresh signifies that one or more of the Physical Volumes this RAID Logical
-Volume uses had suffered a write error. The write error could be due to a
-temporary failure of that Physical Volume or an indication that it is failing.
-The device should be refreshed or replaced. (m)ismatches signifies that the
-RAID logical volume has portions of the array that are not coherent.
-Inconsistencies are detected by initiating a "check" on a RAID logical volume.
-(The scrubbing operations, "check" and "repair", can be performed on a RAID
-logical volume via the 'lvchange' command.)  (w)ritemostly signifies the
-devices in a RAID 1 logical volume that have been marked write-mostly.
-Re(s)haping signifies a RAID Logical Volume is either undergoing a stripe
-addition/removal, a stripe size or RAID algorithm change.
-(R)emove after reshape signifies freed striped raid images to be removed.
-.IP
-Related to Thin pool Logical Volumes: (F)ailed, out of (D)ata space,
-(M)etadata read only.
-.br
-(F)ailed is set if thin pool encounters serious failures and hence no further I/O
-is permitted at all. The out of (D)ata space is set if thin pool has run out of
-data space. (M)etadata read only signifies that thin pool encounters certain
-types of failures but it's still possible to do reads at least,
-but no metadata changes are allowed.
-.IP
-Related to Thin Logical Volumes: (F)ailed.
-.br
-(F)ailed is set when related thin pool enters Failed state and no further I/O
-is permitted at all.
-.IP
-Related to writecache logical volumes: (E)rror.
-.br
-(E)rror is set dm-writecache reports an error.
-.IP 10 3
-s(k)ip activation: this volume is flagged to be skipped during activation.
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/lvscan.8_pregen b/man/lvscan.8_pregen
index 264d9607e..40438a7d2 100644
--- a/man/lvscan.8_pregen
+++ b/man/lvscan.8_pregen
@@ -1,361 +1,257 @@
 .TH LVSCAN 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-lvscan - List all logical volumes in all volume groups
+.
+lvscan \(em List all logical volumes in all volume groups
 .
 .SH SYNOPSIS
+.
 \fBlvscan\fP
 .br
     [ \fIoption_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 lvscan scans all VGs or all supported LVM block devices in the system for
 LVs. The output consists of one line for each LV indicating whether or not
 it is active, a snapshot or origin, the size of the device and its
 allocation policy. Use \fBlvs\fP(8) or \fBlvdisplay\fP(8) to obtain more
 comprehensive information about LVs.
+.
 .SH USAGE
+.
 \fBlvscan\fP
 .br
 .RS 4
 .ad l
 [ \fB-a\fP|\fB--all\fP ]
-.ad b
 .br
-.ad l
 [ \fB-b\fP|\fB--blockdevice\fP ]
-.ad b
 .br
-.ad l
 [    \fB--ignorelockingfailure\fP ]
-.ad b
 .br
-.ad l
 [    \fB--readonly\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB-a\fP|\fB--all\fP
 .br
-.ad b
 Show information about internal LVs.
 These are components of normal LVs, such as mirrors,
 which are not independently accessible, e.g. not mountable.
+.
 .HP
-.ad l
 \fB-b\fP|\fB--blockdevice\fP
 .br
-.ad b
 No longer used.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--ignorelockingfailure\fP
 .br
-.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--readonly\fP
 .br
-.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIString\fP
-.br
+.
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/pvchange.8_pregen b/man/pvchange.8_pregen
index 33778ee6c..577352d2a 100644
--- a/man/pvchange.8_pregen
+++ b/man/pvchange.8_pregen
@@ -1,18 +1,25 @@
 .TH PVCHANGE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-pvchange - Change attributes of physical volume(s)
+.
+pvchange \(em Change attributes of physical volume(s)
 .
 .SH SYNOPSIS
+.
 \fBpvchange\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 pvchange changes PV attributes in the VG.
-
+.P
 For options listed in parentheses, any one is required, after which the
 others are optional.
+.
 .SH USAGE
+.
 Change properties of all PVs.
 .br
 .P
@@ -30,10 +37,11 @@ Change properties of all PVs.
 .RE
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Change properties of specified PVs.
 .br
 .P
@@ -56,252 +64,196 @@ Change properties of specified PVs.
 .RS 4
 .ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Common options for command:
 .
 .RS 4
 .ad l
 [ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-f\fP|\fB--force\fP ]
-.ad b
 .br
-.ad l
 [ \fB-u\fP|\fB--uuid\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--addtag\fP \fITag\fP
 .br
-.ad b
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
+.
 .HP
-.ad l
 \fB-a\fP|\fB--all\fP
 .br
-.ad b
 Change all visible PVs.
+.
 .HP
-.ad l
 \fB-x\fP|\fB--allocatable\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Enable or disable allocation of physical extents on this PV.
+.
 .HP
-.ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--deltag\fP \fITag\fP
 .br
-.ad b
 Deletes a tag from a PV, VG or LV. This option can be repeated to delete
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-f\fP|\fB--force\fP ...
 .br
-.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--metadataignore\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Specifies the metadataignore property of a PV.
 If yes, metadata areas on the PV are ignored, and lvm will
 not store metadata in the metadata areas of the PV.
 If no, lvm will store metadata on the PV.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
-.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -310,47 +262,43 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-u\fP|\fB--uuid\fP
 .br
-.ad b
 Generate new random UUID for specified PVs.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIPV\fP
-.br
+.
+.TP
+.I PV
 Physical Volume name, a device path under /dev.
 For commands managing physical extents, a PV positional arg
 generally accepts a suffix indicating a range (or multiple ranges)
@@ -358,103 +306,41 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
-\fISelect\fP
-.br
+.TP
+.I Select
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH EXAMPLES
-
-Disallow the allocation of physical extents on a PV (e.g. because of
-disk errors, or because it will be removed after freeing it).
-.br
-.B pvchange -x n /dev/sdk1
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/pvck.8_pregen b/man/pvck.8_pregen
index 22e6f6eff..6e55916a3 100644
--- a/man/pvck.8_pregen
+++ b/man/pvck.8_pregen
@@ -1,8 +1,11 @@
 .TH PVCK 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-pvck - Check metadata on physical volumes
+.
+pvck \(em Check metadata on physical volumes
 .
 .SH SYNOPSIS
+.
 \fBpvck\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
@@ -10,103 +13,61 @@ pvck - Check metadata on physical volumes
 .P
 .ad l
     \fB--commandprofile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--config\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-d\fP|\fB--debug\fP
-.ad b
 .br
-.ad l
     \fB--devices\fP \fIPV\fP
-.ad b
 .br
-.ad l
     \fB--devicesfile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--driverloaded\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
-    \fB--dump\fP 
+    \fB--dump\fP \c
 .nh
-\fBheaders\fP|\:\fBmetadata\fP|\:\fBmetadata_all\fP|\:\fBmetadata_search\fP
+\%\fBheaders\fP|\:\fBmetadata\fP|\:\fBmetadata_all\fP|\:\fBmetadata_search\fP
 .hy
-.ad b
 .br
-.ad l
  \fB-f\fP|\fB--file\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-h\fP|\fB--help\fP
-.ad b
 .br
-.ad l
     \fB--labelsector\fP \fINumber\fP
-.ad b
 .br
-.ad l
     \fB--lockopt\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--longhelp\fP
-.ad b
 .br
-.ad l
     \fB--nolocking\fP
-.ad b
 .br
-.ad l
     \fB--profile\fP \fIString\fP
-.ad b
 .br
-.ad l
-    \fB--[pv]metadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
-.ad b
+    \fB--\fP[\fBpv\fP]\fBmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
-.ad l
  \fB-q\fP|\fB--quiet\fP
-.ad b
 .br
-.ad l
     \fB--repair\fP
-.ad b
 .br
-.ad l
     \fB--repairtype\fP \fBpv_header\fP|\fBmetadata\fP|\fBlabel_header\fP
-.ad b
 .br
-.ad l
     \fB--settings\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-t\fP|\fB--test\fP
-.ad b
 .br
-.ad l
  \fB-v\fP|\fB--verbose\fP
-.ad b
 .br
-.ad l
     \fB--version\fP
-.ad b
 .br
-.ad l
  \fB-y\fP|\fB--yes\fP
 .ad b
+.
 .SH DESCRIPTION
+.
 pvck checks and repairs LVM metadata on PVs.
-
+.P
 .SS Dump options 
-
+.P
 .B headers
 .br
 Print LVM on-disk headers and structures: label_header, pv_header,
@@ -117,7 +78,7 @@ a 512 byte sector at offset 4096 bytes.  A second mda_header can
 optionally exist near the end of the device.  The metadata text exists in
 an area (about 1MiB by default) immediately following the mda_header
 sector.  The metadata text is checked but not printed (see other options).
-
+.P
 .B metadata
 .br
 Print the current LVM VG metadata text (or save to a file), using headers
@@ -125,7 +86,7 @@ to locate the latest copy of metadata.  If headers are damaged, metadata
 may not be found (see metadata_search).  Use --settings "mda_num=2" to
 look in mda2 (the second mda@the end of the device, if used).  The
 metadata text is printed to stdout or saved to a file with --file.
-
+.P
 .B metadata_all
 .br
 List all versions of VG metadata found in the metadata area, using headers
@@ -133,7 +94,7 @@ to locate metadata.  Full copies of all metadata are saved to a file with
 the --file option.  If headers are damaged, metadata may not be found (see
 metadata_search).  Use --settings "mda_num=2" as above.  Use -v to include
 descriptions and dates when listing metadata versions.
-
+.P
 .B metadata_search
 .br
 List all versions of VG metadata found in the metadata area, searching
@@ -143,20 +104,20 @@ save one specific version of metadata, use --settings
 "metadata_offset=<offset>", where the offset is taken from the list of
 versions found.  Use -v to include descriptions and dates when listing
 metadata versions.
-
+.P
 .B metadata_area
 .br
 Save the entire text metadata area to a file without processing.
-
+.P
 .SS Repair options
-
+.P
 .B --repair
 .br
 Repair headers and metadata on a PV.  This uses a metadata input file that
-was extracted by --dump, or a backup file (from /etc/lvm/backup).  When
+was extracted by --dump, or a backup file (from \fI#DEFAULT_BACKUP_DIR#\fP).  When
 possible, use metadata saved by --dump from another PV in the same VG (or
 from a second metadata area on the PV).
-
+.P
 There are cases where the PV UUID needs to be specified for the PV being
 repaired.  It is specified using --settings "pv_uuid=<UUID>".  In
 particular, if the device name for the PV being repaired does not match
@@ -165,52 +126,52 @@ the correct PV UUID.  When headers are damaged on more than one PV in a
 VG, it is important for the user to determine the correct PV UUID and
 specify it in --settings.  Otherwise, the wrong PV UUID could be used if
 device names have been swapped since the metadata was last written.
-
+.P
 If a PV has no metadata areas and the pv_header is damaged, then the
 repair will not know to create no metadata areas during repair.  It will
 by default repair metadata in mda1.  To repair with no metadata areas, use
 --settings "mda_offset=0 mda_size=0".
-
+.P
 There are cases where repair should be run on all PVs in the VG (using the
 same metadata file):  if all PVs in the VG are damaged, if using an old
 metadata version, or if a backup file is used instead of raw metadata
 (taken from pvck dump.)
-
+.P
 Using --repair is equivalent to running --repairtype pv_header followed by
 --repairtype metadata.
-
+.P
 .B --repairtype pv_header
 .br
 Repairs the header sector, containing the pv_header and label_header.
-
+.P
 .B --repairtype metadata
 .br
 Repairs the mda_header and metadata text.  It requires the headers to be
 correct (having been undamaged or already repaired).
-
+.P
 .B --repairtype label_header
 .br
 Repairs label_header fields, leaving the pv_header (in the same sector)
 unchanged.  (repairtype pv_header should usually be used instead.)
-
+.P
 .SS Settings
-
+.P
 The --settings option controls or overrides certain dump or repair
 behaviors.  All offset and size values in settings are in bytes (units are
 not recognized.)  These settings are subject to change.
-
+.P
 .B mda_num=1|2
 .br
 Select which metadata area should be used.  By default the first metadata
 area (1) is used.  mda1 is always located at offset 4096.  mda2, at the
 end of the device, often does not exist (it's not created by default.) If
 mda1 is erased, mda2, if it exists, will often still have metadata.
-
+.P
 \fBmetadata_offset=\fP\fIbytes\fP
 .br
 Select metadata text at this offset.  Use with metadata_search to
 print/save one instance of metadata text.
-
+.P
 \fBmda_offset=\fP\fIbytes\fP \fBmda_size=\fP\fIbytes\fP
 .br
 Refers to a metadata area (mda) location and size.  An mda includes an
@@ -218,18 +179,18 @@ mda_header and circular metadata text buffer.  Setting this forces
 metadata_search look for metadata in the given area instead of the
 standard locations.  When set to zero with repair, it indicates no
 metadata areas should exist.
-
+.P
 \fBmda2_offset=\fP\fIbytes\fP \fBmda2_size=\fP\fIbytes\fP
 .br
 When repairing a pv_header, this forces a specific offset and size for
 mda2 that should be recorded in the pv_header.
-
+.P
 \fBpv_uuid=\fP\fIuuid\fP
 .br
 Specify the PV UUID of the device being repaired.  When not specified,
 repair will attempt to determine the correct PV UUID by matching a device
 name in the metadata.
-
+.P
 \fBdevice_size=\fP\fIbytes\fP
 .br
 \fBdata_offset=\fP\fIbytes\fP
@@ -239,46 +200,45 @@ be specified directly, in which case these values are not taken from a
 metadata file (where they usually come from), and the metadata file can be
 omitted.  data_offset is the starting location of the first physical
 extent (data), which follows the first metadata area.
-
+.
 .SH USAGE
+.
 Check for metadata on a device
 .br
 .P
 \fBpvck\fP \fIPV\fP ...
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Check and print LVM headers and metadata on a device
 .br
 .P
-\fBpvck\fP \fB--dump\fP 
+\fBpvck\fP \fB--dump\fP \c
 .nh
-\fBheaders\fP|\:\fBmetadata\fP|\:\fBmetadata_all\fP|\:\fBmetadata_search\fP
+\%\fBheaders\fP|\:\fBmetadata\fP|\:\fBmetadata_all\fP|\:\fBmetadata_search\fP
 .hy 
 \fIPV\fP
 .br
 .RS 4
 .ad l
 [ \fB-f\fP|\fB--file\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--settings\fP \fIString\fP ]
-.ad b
 .br
-.ad l
-[    \fB--[pv]metadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP ]
-.ad b
+[    \fB--\fP[\fBpv\fP]\fBmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP ]
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Repair LVM headers or metadata on a device
 .br
 .P
@@ -287,17 +247,15 @@ Repair LVM headers or metadata on a device
 .RS 4
 .ad l
 [ \fB-f\fP|\fB--file\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--settings\fP \fIString\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Repair LVM headers and metadata on a device
 .br
 .P
@@ -306,13 +264,13 @@ Repair LVM headers and metadata on a device
 .RS 4
 .ad l
 [    \fB--settings\fP \fIString\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Common options for command:
 .
 .RS 4
@@ -320,131 +278,98 @@ Common options for command:
 [    \fB--labelsector\fP \fINumber\fP ]
 .ad b
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
 .ad l
-\fB--dump\fP 
+\fB--dump\fP \c
 .nh
-\fBheaders\fP|\:\fBmetadata\fP|\:\fBmetadata_all\fP|\:\fBmetadata_search\fP
+\%\fBheaders\fP|\:\fBmetadata\fP|\:\fBmetadata_all\fP|\:\fBmetadata_search\fP
 .hy
-.br
 .ad b
+.br
 Dump headers and metadata from a PV for debugging and repair.
 Option values include: \fBheaders\fP to print and check LVM headers,
 \fBmetadata\fP to print or save the current text metadata,
@@ -452,58 +377,50 @@ Option values include: \fBheaders\fP to print and check LVM headers,
 \fBmetadata_search\fP to list or save all versions of metadata,
 searching standard locations in case of damaged headers,
 \fBmetadata_area\fP to save an entire text metadata area to a file.
+.
 .HP
-.ad l
 \fB-f\fP|\fB--file\fP \fIString\fP
 .br
-.ad b
 Metadata file to read or write.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--labelsector\fP \fINumber\fP
 .br
-.ad b
 By default the PV is labelled with an LVM2 identifier in its second
 sector (sector 1). This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source). Use with care.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
-\fB--[pv]metadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
+\fB--\fP[\fBpv\fP]\fBmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
-.ad b
 The number of metadata areas to set aside on a PV for storing VG metadata.
 When 2, one copy of the VG metadata is stored at the front of the PV
 and a second copy is stored at the end.
@@ -511,68 +428,61 @@ When 1, one copy of the VG metadata is stored at the front of the PV.
 When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--repair\fP
 .br
-.ad b
 Repair headers and metadata on a PV.
+.
 .HP
-.ad l
 \fB--repairtype\fP \fBpv_header\fP|\fBmetadata\fP|\fBlabel_header\fP
 .br
-.ad b
 Repair headers and metadata on a PV. See command description.
+.
 .HP
-.ad l
 \fB--settings\fP \fIString\fP
 .br
-.ad b
 Specifies command specific settings in "Key = Value" form.
 Combine multiple settings in quotes, or repeat the settings
 option for each.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIPV\fP
-.br
+.
+.TP
+.I PV
 Physical Volume name, a device path under /dev.
 For commands managing physical extents, a PV positional arg
 generally accepts a suffix indicating a range (or multiple ranges)
@@ -580,99 +490,36 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH EXAMPLES
-
-If the partition table is corrupted or lost on /dev/sda, and you suspect
-there was an LVM partition at approximately 100 MiB, then this
-area of the disk can be scanned using the \fB--labelsector\fP
-parameter with a value of 204800 (100 * 1024 * 1024 / 512 = 204800).
-.br
-.B pvck --labelsector 204800 /dev/sda
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/pvcreate.8_pregen b/man/pvcreate.8_pregen
index f56022b2e..26e5141fe 100644
--- a/man/pvcreate.8_pregen
+++ b/man/pvcreate.8_pregen
@@ -1,36 +1,41 @@
 .TH PVCREATE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-pvcreate - Initialize physical volume(s) for use by LVM
+.
+pvcreate \(em Initialize physical volume(s) for use by LVM
 .
 .SH SYNOPSIS
+.
 \fBpvcreate\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 pvcreate initializes a Physical Volume (PV) on a device so the device is
 recognized as belonging to LVM.  This allows the PV to be used in a Volume
 Group (VG).  An LVM disk label is written to the device, and LVM metadata
 areas are initialized.  A PV can be placed on a whole device or partition.
-
+.P
 Use \fBvgcreate\fP(8) to create a new VG on the PV, or \fBvgextend\fP(8)
 to add the PV to an existing VG.  Use \fBpvremove\fP(8) to remove the LVM
 disk label from the device.
-
+.P
 The force option will create a PV without confirmation.  Repeating the
 force option (\fB-ff\fP) will forcibly create a PV, overriding checks that
 normally prevent it, e.g. if the PV is already in a VG.
-
+.P
 .B Metadata location, size, and alignment
-
+.P
 The LVM disk label begins 512 bytes from the start of the device, and is
 512 bytes in size.
-
+.P
 The LVM metadata area begins at an offset (from the start of the device)
 equal to the page size of the machine creating the PV (often 4 KiB.) The
 metadata area contains a 512 byte header and a multi-KiB circular buffer
 that holds text copies of the VG metadata.
-
+.P
 With default settings, the first physical extent (PE), which contains LV
 data, is 1 MiB from the start of the device.  This location is controlled
 by \fBdefault_data_alignment\fP in lvm.conf, which is set to 1 (MiB) by
@@ -39,7 +44,7 @@ can be checked with:
 .br
 .B pvs -o pe_start
 .I PV
-
+.P
 The size of the LVM metadata area is the space between the the start of
 the metadata area and the first PE.  When metadata begins at 4 KiB and the
 first PE is at 1024 KiB, the metadata area size is 1020 KiB.  This can be
@@ -47,7 +52,7 @@ checked with:
 .br
 .B pvs -o mda_size
 .I PV
-
+.P
 The mda_size cannot be increased after pvcreate, so if larger metadata is
 needed, it must be set during pvcreate.  Two copies of the VG metadata
 must always fit within the metadata area, so the maximum VG metadata size
@@ -55,7 +60,7 @@ is around half the mda_size.  This can be checked with:
 .br
 .B vgs -o mda_free
 .I VG
-
+.P
 A larger metadata area can be set with --metadatasize.  The resulting
 mda_size may be larger than specified due to default_data_alignment
 placing pe_start on a MiB boundary, and the fact that the metadata area
@@ -63,12 +68,12 @@ extends to the first PE.  With metadata starting at 4 KiB and
 default_data_alignment 1 (MiB), setting --metadatasize 2048k results in
 pe_start of 3 MiB and mda_size of 3068 KiB.  Alternatively, --metadatasize
 2044k results in pe_start at 2 MiB and mda_size of 2044 KiB.
-
+.P
 The alignment of pe_start described above may be automatically overridden
 based on md device properties or device i/o properties reported in sysfs.
 These automatic adjustments can be enabled/disabled using lvm.conf
 settings md_chunk_alignment and data_alignment_offset_detection.
-
+.P
 To use a different pe_start alignment, use the --dataalignment option.
 The --metadatasize option would also typically be used in this case
 because the metadata area size also determines the location of pe_start.
@@ -81,152 +86,96 @@ The pe_start of 2176 KiB is the nearest even multiple of 128 KiB that
 provides at least 2048 KiB of metadata space.
 Always check the resulting alignment and metadata size when using
 these options.
-
+.P
 To shift an aligned pe_start value, use the --dataalignmentoffset option.
 The pe_start alignment is calculated as described above, and then the
 value specified with --dataalignmentoffset is added to produce the final
 pe_start value.
+.
 .SH USAGE
+.
 \fBpvcreate\fP \fIPV\fP ...
 .br
 .RS 4
 .ad l
 [ \fB-f\fP|\fB--force\fP ]
-.ad b
 .br
-.ad l
 [ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP ]
-.ad b
 .br
-.ad l
 [ \fB-u\fP|\fB--uuid\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--dataalignment\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--dataalignmentoffset\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--bootloaderareasize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--labelsector\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
-[    \fB--[pv]metadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP ]
-.ad b
+[    \fB--\fP[\fBpv\fP]\fBmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP ]
 .br
-.ad l
 [    \fB--metadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--metadataignore\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--norestorefile\fP ]
-.ad b
 .br
-.ad l
 [    \fB--setphysicalvolumesize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
-.ad l
 [    \fB--restorefile\fP \fIString\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--bootloaderareasize\fP \fISize\fP[m|UNIT]
 .br
-.ad b
 Reserve space for the bootloader between the LVM metadata area and the first PE.
 The bootloader area is reserved for bootloaders to embed their own data or
 metadata; LVM will not use it.
@@ -238,154 +187,134 @@ and --dataalignmentoffset. The bootloader area may be larger than requested
 due to the alignment, but it's never less than the requested size.
 To see the bootloader area start and size of
 an existing PV use pvs -o +pv_ba_start,pv_ba_size.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB--dataalignment\fP \fISize\fP[k|UNIT]
 .br
-.ad b
 Align the start of a PV data area with a multiple of this number.
 To see the location of the first Physical Extent (PE) of an existing PV,
 use pvs -o +pe_start. In addition, it may be shifted by an alignment offset,
 see --dataalignmentoffset.
 Also specify an appropriate PE size when creating a VG.
+.
 .HP
-.ad l
 \fB--dataalignmentoffset\fP \fISize\fP[k|UNIT]
 .br
-.ad b
 Shift the start of the PV data area by this additional offset.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-f\fP|\fB--force\fP ...
 .br
-.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--labelsector\fP \fINumber\fP
 .br
-.ad b
 By default the PV is labelled with an LVM2 identifier in its second
 sector (sector 1). This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source). Use with care.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--metadataignore\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Specifies the metadataignore property of a PV.
 If yes, metadata areas on the PV are ignored, and lvm will
 not store metadata in the metadata areas of the PV.
 If no, lvm will store metadata on the PV.
+.
 .HP
-.ad l
 \fB--metadatasize\fP \fISize\fP[m|UNIT]
 .br
-.ad b
 The approximate amount of space used for each VG metadata area.
 The size may be rounded.
+.
 .HP
-.ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
-.ad b
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
 \fBlvm1\fP (or just \fB1\fP) is no longer used.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--norestorefile\fP
 .br
-.ad b
 In conjunction with --uuid, this allows a uuid to be specified
 without also requiring that a backup of the metadata be provided.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
-\fB--[pv]metadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
+\fB--\fP[\fBpv\fP]\fBmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
-.ad b
 The number of metadata areas to set aside on a PV for storing VG metadata.
 When 2, one copy of the VG metadata is stored at the front of the PV
 and a second copy is stored at the end.
@@ -393,29 +322,26 @@ When 1, one copy of the VG metadata is stored at the front of the PV.
 When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--restorefile\fP \fIString\fP
 .br
-.ad b
 In conjunction with --uuid, this reads the file (produced by
 vgcfgbackup), extracts the location and size of the data on the PV,
 and ensures that the metadata produced by the program is consistent
@@ -423,28 +349,25 @@ with the contents of the file, i.e. the physical extents will be in
 the same place and not be overwritten by new metadata. This provides
 a mechanism to upgrade the metadata format or to add/remove metadata
 areas. Use with care.
+.
 .HP
-.ad l
 \fB--setphysicalvolumesize\fP \fISize\fP[m|UNIT]
 .br
-.ad b
 Overrides the automatically detected size of the PV.
 Use with care, or prior to reducing the physical size of the device.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-u\fP|\fB--uuid\fP \fIString\fP
 .br
-.ad b
 Specify a UUID for the device.
 Without this option, a random UUID is generated.
 This option is needed before restoring a backup of LVM metadata
@@ -453,39 +376,36 @@ onto a replacement device; see \fBvgcfgrestore\fP(8). As such, use of
 All PVs must have unique UUIDs, and LVM will prevent certain operations
 if multiple devices are seen with the same UUID.
 See \fBvgimportclone\fP(8) for more information.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .HP
-.ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Controls if the first 4 sectors (2048 bytes) of the device are wiped.
 The default is to wipe these sectors unless either or both of
 --restorefile or --uuid are specified.
+.
 .SH VARIABLES
-.HP
-\fIPV\fP
-.br
+.
+.TP
+.I PV
 Physical Volume name, a device path under /dev.
 For commands managing physical extents, a PV positional arg
 generally accepts a suffix indicating a range (or multiple ranges)
@@ -493,103 +413,36 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH EXAMPLES
-
-Initialize a partition and a full device.
-.br
-.B pvcreate /dev/sdc4 /dev/sde
-
-If a device is a 4KiB sector drive that compensates for windows
-partitioning (sector 7 is the lowest aligned logical block, the 4KiB
-sectors start at LBA -1, and consequently sector 63 is aligned on a 4KiB
-boundary) manually account for this when initializing for use by LVM.
-.br
-.B pvcreate --dataalignmentoffset 7s /dev/sdb
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/pvdisplay.8_pregen b/man/pvdisplay.8_pregen
index 9a7e4ed56..ff5d9f50a 100644
--- a/man/pvdisplay.8_pregen
+++ b/man/pvdisplay.8_pregen
@@ -1,348 +1,265 @@
 .TH PVDISPLAY 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-pvdisplay - Display various attributes of physical volume(s)
+.
+pvdisplay \(em Display various attributes of physical volume(s)
 .
 .SH SYNOPSIS
+.
 \fBpvdisplay\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 pvdisplay shows the attributes of PVs, like size, physical extent size,
 space used for the VG descriptor area, etc.
-
+.P
 \fBpvs\fP(8) is a preferred alternative that shows the same information
 and more, using a more compact and configurable output format.
+.
 .SH USAGE
+.
 \fBpvdisplay\fP
 .br
 .RS 4
 .ad l
 [ \fB-a\fP|\fB--all\fP ]
-.ad b
 .br
-.ad l
 [ \fB-c\fP|\fB--colon\fP ]
-.ad b
 .br
-.ad l
 [ \fB-C\fP|\fB--columns\fP ]
-.ad b
 .br
-.ad l
 [ \fB-m\fP|\fB--maps\fP ]
-.ad b
 .br
-.ad l
 [ \fB-o\fP|\fB--options\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [ \fB-s\fP|\fB--short\fP ]
-.ad b
 .br
-.ad l
 [ \fB-O\fP|\fB--sort\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--aligned\fP ]
-.ad b
 .br
-.ad l
 [    \fB--binary\fP ]
-.ad b
 .br
-.ad l
 [    \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP ]
-.ad b
 .br
-.ad l
 [    \fB--foreign\fP ]
-.ad b
 .br
-.ad l
 [    \fB--ignorelockingfailure\fP ]
-.ad b
 .br
-.ad l
 [    \fB--logonly\fP ]
-.ad b
 .br
-.ad l
 [    \fB--noheadings\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nosuffix\fP ]
-.ad b
 .br
-.ad l
 [    \fB--readonly\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
-.ad l
 [    \fB--separator\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--shared\fP ]
-.ad b
 .br
-.ad l
 [    \fB--unbuffered\fP ]
-.ad b
 .br
-.ad l
-[    \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP ]
-.ad b
+[    \fB--units\fP \c
+.nh
+\%[\fINumber\fP]\fBr\fP|\:\fBR\fP|\:\fBh\fP|\:\fBH\fP|\:\fBb\fP|\:\fBB\fP|\:\fBs\fP|\:\fBS\fP|\:\fBk\fP|\:\fBK\fP|\:\fBm\fP|\:\fBM\fP|\:\fBg\fP|\:\fBG\fP|\:\fBt\fP|\:\fBT\fP|\:\fBp\fP|\:\fBP\fP|\:\fBe\fP|\:\fBE\fP
+.hy
+]
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP|\fITag\fP ... ]
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--aligned\fP
 .br
-.ad b
 Use with --separator to align the output columns
+.
 .HP
-.ad l
 \fB-a\fP|\fB--all\fP
 .br
-.ad b
 Show information about devices that have not been initialized
 by LVM, i.e. they are not PVs.
+.
 .HP
-.ad l
 \fB--binary\fP
 .br
-.ad b
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
+.
 .HP
-.ad l
 \fB-c\fP|\fB--colon\fP
 .br
-.ad b
 Generate colon separated output for easier parsing in scripts or programs.
 Also see \fBvgs\fP(8) which provides considerably more control over the output.
+.
 .HP
-.ad l
 \fB-C\fP|\fB--columns\fP
 .br
-.ad b
 Display output in columns, the equivalent of \fBvgs\fP(8).
 Options listed are the same as options given in \fBvgs\fP(8).
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
-.ad b
 See \fBlvmreport\fP(7).
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB--foreign\fP
 .br
-.ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--ignorelockingfailure\fP
 .br
-.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--logonly\fP
 .br
-.ad b
 Suppress command report and display only log report.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB-m\fP|\fB--maps\fP
 .br
-.ad b
 Display the mapping of physical extents to LVs and logical extents.
+.
 .HP
-.ad l
 \fB--noheadings\fP
 .br
-.ad b
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--nosuffix\fP
 .br
-.ad b
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
+.
 .HP
-.ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
 .br
-.ad b
 Comma-separated, ordered list of fields to display in columns.
-String arg syntax is: [+|-|#]Field1[,Field2 ...]
+String arg syntax is: [\fB+\fP|\fB-\fP|\fB#\fP]\fIField1\fP[\fB,\fP\fIField2\fP ...]
 The prefix \fB+\fP will append the specified fields to the default fields,
 \fB-\fP will remove the specified fields from the default fields, and
 \fB#\fP will compact specified fields (removing them when empty for all rows.)
@@ -356,49 +273,44 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBpvseg_all\fP all PV segment fields,
 \fBseg_all\fP all LV segment fields, and
 \fBpvseg_all\fP all PV segment columns.
-See the lvm.conf report section for more config options.
+See the \fBlvm.conf\fP(5) report section for more config options.
 See \fBlvmreport\fP(7) for more information about reporting.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--readonly\fP
 .br
-.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
-.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -407,85 +319,81 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
+.
 .HP
-.ad l
 \fB--separator\fP \fIString\fP
 .br
-.ad b
 String to use to separate each column. Useful if grepping the output.
+.
 .HP
-.ad l
 \fB--shared\fP
 .br
-.ad b
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
+.
 .HP
-.ad l
 \fB-s\fP|\fB--short\fP
 .br
-.ad b
 Only display the size of the given PVs.
+.
 .HP
-.ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
 .br
-.ad b
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB--unbuffered\fP
 .br
-.ad b
 Produce output immediately without sorting or aligning the columns properly.
+.
 .HP
 .ad l
-\fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
-.br
+\fB--units\fP \c
+.nh
+\%[\fINumber\fP]\fBr\fP|\:\fBR\fP|\:\fBh\fP|\:\fBH\fP|\:\fBb\fP|\:\fBB\fP|\:\fBs\fP|\:\fBS\fP|\:\fBk\fP|\:\fBK\fP|\:\fBm\fP|\:\fBM\fP|\:\fBg\fP|\:\fBG\fP|\:\fBt\fP|\:\fBT\fP|\:\fBp\fP|\:\fBP\fP|\:\fBe\fP|\:\fBE\fP
+.hy
 .ad b
+.br
 All sizes are output in these units:
 human-(r)eadable with '<' rounding indicator,
 (h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIPV\fP
-.br
+.
+.TP
+.I PV
 Physical Volume name, a device path under /dev.
 For commands managing physical extents, a PV positional arg
 generally accepts a suffix indicating a range (or multiple ranges)
@@ -493,96 +401,40 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
-\fITag\fP
-.br
+.TP
+.I Tag
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/pvmove.8_pregen b/man/pvmove.8_pregen
index 791e2834f..a764ed9ca 100644
--- a/man/pvmove.8_pregen
+++ b/man/pvmove.8_pregen
@@ -1,31 +1,38 @@
 .TH PVMOVE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-pvmove - Move extents from one physical volume to another
+.
+pvmove \(em Move extents from one physical volume to another
 .
 .SH SYNOPSIS
+.
 \fBpvmove\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 pvmove moves the allocated physical extents (PEs) on a source PV to one or
 more destination PVs.  You can optionally specify a source LV in which
 case only extents used by that LV will be moved to free (or specified)
 extents on the destination PV. If no destination PV is specified, the
 normal allocation rules for the VG are used.
-
+.P
 If pvmove is interrupted for any reason (e.g. the machine crashes) then
 run pvmove again without any PV arguments to restart any operations that
 were in progress from the last checkpoint. Alternatively, use the abort
 option at any time to abort the operation. The resulting location of LVs
 after an abort depends on whether the atomic option was used.
-
+.P
 More than one pvmove can run concurrently if they are moving data from
 different source PVs, but additional pvmoves will ignore any LVs already
 in the process of being changed, so some data might not get moved.
+.
 .SH USAGE
+.
 Move PV extents.
 .br
 .P
@@ -34,150 +41,108 @@ Move PV extents.
 .RS 4
 .ad l
 [ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-n\fP|\fB--name\fP \fILV\fP ]
-.ad b
 .br
-.ad l
-[    \fB--alloc\fP 
+[    \fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
 ]
-.ad b
 .br
-.ad l
 [    \fB--atomic\fP ]
-.ad b
 .br
-.ad l
 [    \fB--noudevsync\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
+.P
 Continue or abort existing pvmove operations.
 .br
 .P
 \fBpvmove\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Common options for command:
 .
 .RS 4
 .ad l
 [ \fB-b\fP|\fB--background\fP ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [    \fB--abort\fP ]
 .ad b
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--abort\fP
 .br
-.ad b
 Abort any pvmove operations in progress. If a pvmove was started
 with the --atomic option, then all LVs will remain on the source PV.
 Otherwise, segments that have been moved will remain on the
 destination PV, while unmoved segments will remain on the source PV.
+.
 .HP
 .ad l
-\fB--alloc\fP 
+\fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
-.br
 .ad b
+.br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
 which can be changed with vgchange/lvchange, or overridden on the
@@ -194,182 +159,160 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
+.
 .HP
-.ad l
 \fB--atomic\fP
 .br
-.ad b
 Makes a pvmove operation atomic, ensuring that all affected LVs are
 moved to the destination PV, or none are if the operation is aborted.
+.
 .HP
-.ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
+.
 .HP
-.ad l
 \fB-b\fP|\fB--background\fP
 .br
-.ad b
 If the operation requires polling, this option causes the command to
 return before the operation is complete, and polling is done in the
 background.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB-i\fP|\fB--interval\fP \fINumber\fP
 .br
-.ad b
 Report progress at regular intervals.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB-n\fP|\fB--name\fP \fIString\fP
 .br
-.ad b
 Move only the extents belonging to the named LV.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--noudevsync\fP
 .br
-.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIPV\fP
-.br
+.
+.TP
+.I PV
 Physical Volume name, a device path under /dev.
 For commands managing physical extents, a PV positional arg
 generally accepts a suffix indicating a range (or multiple ranges)
@@ -377,182 +320,36 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH NOTES
-pvmove works as follows:
-
-1. A temporary 'pvmove' LV is created to store details of all the data
-movements required.
-
-2. Every LV in the VG is searched for contiguous data that need moving
-according to the command line arguments.
-For each piece of data found, a new segment is added to the end of the
-pvmove LV.
-This segment takes the form of a temporary mirror to copy the data
-from the original location to a newly allocated location.
-The original LV is updated to use the new temporary mirror segment
-in the pvmove LV instead of accessing the data directly.
-
-3. The VG metadata is updated on disk.
-
-4. The first segment of the pvmove LV is activated and starts to mirror
-the first part of the data.  Only one segment is mirrored at once as this
-is usually more efficient.
-
-5. A daemon repeatedly checks progress at the specified time interval.
-When it detects that the first temporary mirror is in sync, it breaks that
-mirror so that only the new location for that data gets used and writes a
-checkpoint into the VG metadata on disk.  Then it activates the mirror for
-the next segment of the pvmove LV.
-
-6. When there are no more segments left to be mirrored, the temporary LV
-is removed and the VG metadata is updated so that the LVs reflect the new
-data locations.
-
-Note that this new process cannot support the original LVM1
-type of on-disk metadata.  Metadata can be converted using
-\fBvgconvert\fP(8).
-
-If the \fB--atomic\fP option is used, a slightly different approach is
-used for the move.  Again, a temporary 'pvmove' LV is created to store the
-details of all the data movements required.  This temporary LV contains
-all the segments of the various LVs that need to be moved.  However, in
-this case, an identical LV is allocated that contains the same number of
-segments and a mirror is created to copy the contents from the first
-temporary LV to the second.  After a complete copy is made, the temporary
-LVs are removed, leaving behind the segments on the destination PV.  If an
-abort is issued during the move, all LVs being moved will remain on the
-source PV.
-
-.SH EXAMPLES
-
-Move all physical extents that are used by simple LVs on the specified PV to
-free physical extents elsewhere in the VG.
-.br
-.B pvmove /dev/sdb1
-
-Use a specific destination PV when moving physical extents.
-.br
-.B pvmove /dev/sdb1 /dev/sdc1
-
-Move extents belonging to a single LV.
-.br
-.B pvmove -n lvol1 /dev/sdb1 /dev/sdc1
-
-Rather than moving the contents of an entire device, it is possible to
-move a range of physical extents, for example numbers 1000 to 1999
-inclusive on the specified PV.
-.br
-.B pvmove /dev/sdb1:1000-1999
-
-A range of physical extents to move can be specified as start+length. For
-example, starting from PE 1000. (Counting starts from 0, so this refers to the
-1001st to the 2000th PE inclusive.)
-.br
-.B pvmove /dev/sdb1:1000+1000
-
-Move a range of physical extents to a specific PV (which must have
-sufficient free extents).
-.br
-.B pvmove /dev/sdb1:1000-1999 /dev/sdc1
-
-Move a range of physical extents to specific new extents on a new PV.
-.br
-.B pvmove /dev/sdb1:1000-1999 /dev/sdc1:0-999
-
-If the source and destination are on the same disk, the
-\fBanywhere\fP allocation policy is needed.
-.br
-.B pvmove --alloc anywhere /dev/sdb1:1000-1999 /dev/sdb1:0-999
-
-The part of a specific LV present within in a range of physical
-extents can also be picked out and moved.
-.br
-.B pvmove -n lvol1 /dev/sdb1:1000-1999 /dev/sdc1
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/pvremove.8_pregen b/man/pvremove.8_pregen
index 3015b70d1..b34f2a042 100644
--- a/man/pvremove.8_pregen
+++ b/man/pvremove.8_pregen
@@ -1,244 +1,203 @@
 .TH PVREMOVE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-pvremove - Remove LVM label(s) from physical volume(s)
+.
+pvremove \(em Remove LVM label(s) from physical volume(s)
 .
 .SH SYNOPSIS
+.
 \fBpvremove\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 pvremove wipes the label on a device so that LVM will no longer recognise
 it as a PV.
-
+.P
 A PV cannot be removed from a VG while it is used by an active LV.
-
+.P
 Repeat the force option (\fB-ff\fP) to forcibly remove a PV belonging to
 an existing VG. Normally, \fBvgreduce\fP(8) should be used instead.
+.
 .SH USAGE
+.
 \fBpvremove\fP \fIPV\fP ...
 .br
 .RS 4
 .ad l
 [ \fB-f\fP|\fB--force\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-f\fP|\fB--force\fP ...
 .br
-.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIPV\fP
-.br
+.
+.TP
+.I PV
 Physical Volume name, a device path under /dev.
 For commands managing physical extents, a PV positional arg
 generally accepts a suffix indicating a range (or multiple ranges)
@@ -246,91 +205,36 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/pvresize.8_pregen b/man/pvresize.8_pregen
index fcc85885b..ea309b311 100644
--- a/man/pvresize.8_pregen
+++ b/man/pvresize.8_pregen
@@ -1,239 +1,198 @@
 .TH PVRESIZE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-pvresize - Resize physical volume(s)
+.
+pvresize \(em Resize physical volume(s)
 .
 .SH SYNOPSIS
+.
 \fBpvresize\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 pvresize resizes a PV. The PV may already be in a VG and may have active
 LVs allocated on it.
+.
 .SH USAGE
+.
 \fBpvresize\fP \fIPV\fP ...
 .br
 .RS 4
 .ad l
 [    \fB--setphysicalvolumesize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--setphysicalvolumesize\fP \fISize\fP[m|UNIT]
 .br
-.ad b
 Overrides the automatically detected size of the PV.
 Use with care, or prior to reducing the physical size of the device.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIPV\fP
-.br
+.
+.TP
+.I PV
 Physical Volume name, a device path under /dev.
 For commands managing physical extents, a PV positional arg
 generally accepts a suffix indicating a range (or multiple ranges)
@@ -241,103 +200,36 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH NOTES
-pvresize will refuse to shrink a PV if it has allocated extents beyond the
-new end.
-.SH EXAMPLES
-Expand a PV after enlarging the partition.
-.br
-.B pvresize /dev/sda1
-
-Shrink a PV prior to shrinking the partition (ensure that the PV size is
-appropriate for the intended new partition size).
-.br
-.B pvresize --setphysicalvolumesize 40G /dev/sda1
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/pvs.8_pregen b/man/pvs.8_pregen
index f00e0328a..08b5600f5 100644
--- a/man/pvs.8_pregen
+++ b/man/pvs.8_pregen
@@ -1,332 +1,251 @@
 .TH PVS 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-pvs - Display information about physical volumes
+.
+pvs \(em Display information about physical volumes
 .
 .SH SYNOPSIS
+.
 \fBpvs\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 pvs produces formatted output about PVs.
+.
 .SH USAGE
+.
 \fBpvs\fP
 .br
 .RS 4
 .ad l
 [ \fB-a\fP|\fB--all\fP ]
-.ad b
 .br
-.ad l
 [ \fB-o\fP|\fB--options\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [ \fB-O\fP|\fB--sort\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--segments\fP ]
-.ad b
 .br
-.ad l
 [    \fB--aligned\fP ]
-.ad b
 .br
-.ad l
 [    \fB--binary\fP ]
-.ad b
 .br
-.ad l
 [    \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP ]
-.ad b
 .br
-.ad l
 [    \fB--foreign\fP ]
-.ad b
 .br
-.ad l
 [    \fB--ignorelockingfailure\fP ]
-.ad b
 .br
-.ad l
 [    \fB--logonly\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nameprefixes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--noheadings\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nosuffix\fP ]
-.ad b
 .br
-.ad l
 [    \fB--readonly\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
-.ad l
 [    \fB--rows\fP ]
-.ad b
 .br
-.ad l
 [    \fB--separator\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--shared\fP ]
-.ad b
 .br
-.ad l
 [    \fB--unbuffered\fP ]
-.ad b
 .br
-.ad l
-[    \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP ]
-.ad b
+[    \fB--units\fP \c
+.nh
+\%[\fINumber\fP]\fBr\fP|\:\fBR\fP|\:\fBh\fP|\:\fBH\fP|\:\fBb\fP|\:\fBB\fP|\:\fBs\fP|\:\fBS\fP|\:\fBk\fP|\:\fBK\fP|\:\fBm\fP|\:\fBM\fP|\:\fBg\fP|\:\fBG\fP|\:\fBt\fP|\:\fBT\fP|\:\fBp\fP|\:\fBP\fP|\:\fBe\fP|\:\fBE\fP
+.hy
+]
 .br
-.ad l
 [    \fB--unquoted\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIPV\fP|\fITag\fP ... ]
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--aligned\fP
 .br
-.ad b
 Use with --separator to align the output columns
+.
 .HP
-.ad l
 \fB-a\fP|\fB--all\fP
 .br
-.ad b
 Show information about devices that have not been initialized
 by LVM, i.e. they are not PVs.
+.
 .HP
-.ad l
 \fB--binary\fP
 .br
-.ad b
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
-.ad b
 See \fBlvmreport\fP(7).
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB--foreign\fP
 .br
-.ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--ignorelockingfailure\fP
 .br
-.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--logonly\fP
 .br
-.ad b
 Suppress command report and display only log report.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--nameprefixes\fP
 .br
-.ad b
 Add an "LVM2_" prefix plus the field name to the output. Useful
 with --noheadings to produce a list of field=value pairs that can
 be used to set environment variables (for example, in udev rules).
+.
 .HP
-.ad l
 \fB--noheadings\fP
 .br
-.ad b
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--nosuffix\fP
 .br
-.ad b
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
+.
 .HP
-.ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
 .br
-.ad b
 Comma-separated, ordered list of fields to display in columns.
-String arg syntax is: [+|-|#]Field1[,Field2 ...]
+String arg syntax is: [\fB+\fP|\fB-\fP|\fB#\fP]\fIField1\fP[\fB,\fP\fIField2\fP ...]
 The prefix \fB+\fP will append the specified fields to the default fields,
 \fB-\fP will remove the specified fields from the default fields, and
 \fB#\fP will compact specified fields (removing them when empty for all rows.)
@@ -340,63 +259,56 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBpvseg_all\fP all PV segment fields,
 \fBseg_all\fP all LV segment fields, and
 \fBpvseg_all\fP all PV segment columns.
-See the lvm.conf report section for more config options.
+See the \fBlvm.conf\fP(5) report section for more config options.
 See \fBlvmreport\fP(7) for more information about reporting.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--readonly\fP
 .br
-.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--rows\fP
 .br
-.ad b
 Output columns as rows.
+.
 .HP
-.ad l
 \fB--segments\fP
 .br
-.ad b
 Produces one line of output for each contiguous allocation of space on each
 PV, showing the start (pvseg_start) and length (pvseg_size) in units of
 physical extents.
+.
 .HP
-.ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
-.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -405,86 +317,82 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
+.
 .HP
-.ad l
 \fB--separator\fP \fIString\fP
 .br
-.ad b
 String to use to separate each column. Useful if grepping the output.
+.
 .HP
-.ad l
 \fB--shared\fP
 .br
-.ad b
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
+.
 .HP
-.ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
 .br
-.ad b
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB--unbuffered\fP
 .br
-.ad b
 Produce output immediately without sorting or aligning the columns properly.
+.
 .HP
 .ad l
-\fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
-.br
+\fB--units\fP \c
+.nh
+\%[\fINumber\fP]\fBr\fP|\:\fBR\fP|\:\fBh\fP|\:\fBH\fP|\:\fBb\fP|\:\fBB\fP|\:\fBs\fP|\:\fBS\fP|\:\fBk\fP|\:\fBK\fP|\:\fBm\fP|\:\fBM\fP|\:\fBg\fP|\:\fBG\fP|\:\fBt\fP|\:\fBT\fP|\:\fBp\fP|\:\fBP\fP|\:\fBe\fP|\:\fBE\fP
+.hy
 .ad b
+.br
 All sizes are output in these units:
 human-(r)eadable with '<' rounding indicator,
 (h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
+.
 .HP
-.ad l
 \fB--unquoted\fP
 .br
-.ad b
 When used with --nameprefixes, output values in the field=value
 pairs are not quoted.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIPV\fP
-.br
+.
+.TP
+.I PV
 Physical Volume name, a device path under /dev.
 For commands managing physical extents, a PV positional arg
 generally accepts a suffix indicating a range (or multiple ranges)
@@ -492,105 +400,40 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
-\fITag\fP
-.br
+.TP
+.I Tag
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH NOTES
-.
-The pv_attr bits are:
-.IP 1 3
-(d)uplicate, (a)llocatable, (u)sed
-.IP 2 3
-e(x)ported
-.IP 3 3
-(m)issing
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/pvscan.8_pregen b/man/pvscan.8_pregen
index 1b0d3d925..8025d6c34 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -1,52 +1,57 @@
 .TH PVSCAN 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-pvscan - List all physical volumes
+.
+pvscan \(em List all physical volumes
 .
 .SH SYNOPSIS
+.
 \fBpvscan\fP \fIoption_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 When called without the --cache option, pvscan lists PVs on the system,
 like
 .BR pvs (8)
 or
 .BR pvdisplay (8).
-
+.P
 When the --cache and -aay options are used, pvscan records which PVs are
 available on the system, and activates LVs in completed VGs.  A VG is
 complete when pvscan sees that the final PV in the VG has appeared.  This
 is used by event-based system startup (systemd, udev) to activate LVs.
-
+.P
 The four main variations of this are:
-
+.P
 .B pvscan --cache
-.IR device
-
+.I device
+.P
 If device is present, lvm adds a record that the PV on device is online.
 If device is not present, lvm removes the online record for the PV.
 In most cases, the pvscan will only read the named devices.
-
+.P
 .B pvscan --cache -aay
 .IR device ...
-
+.P
 This begins by performing the same steps as above.  Afterward, if the VG
 for the specified PV is complete, then pvscan will activate LVs in the VG
 (the same as vgchange -aay vgname would do.)
-
+.P
 .B pvscan --cache
-
+.P
 This first clears all existing PV online records, then scans all devices
 on the system, adding PV online records for any PVs that are found.
-
+.P
 .B pvscan --cache -aay
-
+.P
 This begins by performing the same steps as pvscan --cache.  Afterward, it
 activates LVs in any complete VGs.
-
+.P
 To prevent devices from being scanned by pvscan --cache, add them
 to
 .BR lvm.conf (5)
@@ -54,23 +59,24 @@ to
 For more information, see:
 .br
 .B lvmconfig --withcomments devices/global_filter
-
+.P
 Auto-activation of VGs or LVs can be enabled/disabled using:
 .br
 .BR lvm.conf (5)
 .B activation/auto_activation_volume_list
-
+.P
 For more information, see:
 .br
 .B lvmconfig --withcomments activation/auto_activation_volume_list
-
+.P
 To disable auto-activation, explicitly set this list to an empty list,
 i.e. auto_activation_volume_list = [ ].
-
+.P
 When this setting is undefined (e.g. commented), then all LVs are
 auto-activated.
-
+.
 .SH USAGE
+.
 Display PV information.
 .br
 .P
@@ -79,24 +85,17 @@ Display PV information.
 .RS 4
 .ad l
 [ \fB-e\fP|\fB--exported\fP ]
-.ad b
 .br
-.ad l
 [ \fB-n\fP|\fB--novolumegroup\fP ]
-.ad b
 .br
-.ad l
 [ \fB-s\fP|\fB--short\fP ]
-.ad b
 .br
-.ad l
 [ \fB-u\fP|\fB--uuid\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Autoactivate a VG when all PVs are online.
 .br
 .P
@@ -105,305 +104,242 @@ Autoactivate a VG when all PVs are online.
 .RS 4
 .ad l
 [ \fB-a\fP|\fB--activate\fP \fBay\fP ]
-.ad b
 .br
-.ad l
 [ \fB-j\fP|\fB--major\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [    \fB--minor\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [    \fB--noudevsync\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIString\fP|\fIPV\fP ... ]
 .RE
-
+.P
 Common options for command:
 .
 .RS 4
 .ad l
 [    \fB--ignorelockingfailure\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .br
-.ad b
 Auto-activate LVs in a VG when the PVs scanned have completed the VG.
 (Only \fBay\fP is applicable.)
+.
 .HP
-.ad l
 \fB--cache\fP
 .br
-.ad b
 Scan one or more devices and record that they are online.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-e\fP|\fB--exported\fP
 .br
-.ad b
 Only show PVs belonging to exported VGs.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--ignorelockingfailure\fP
 .br
-.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB-j\fP|\fB--major\fP \fINumber\fP
 .br
-.ad b
 The major number of a device.
+.
 .HP
-.ad l
 \fB--minor\fP \fINumber\fP
 .br
-.ad b
 The minor number of a device.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--noudevsync\fP
 .br
-.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
+.
 .HP
-.ad l
 \fB-n\fP|\fB--novolumegroup\fP
 .br
-.ad b
 Only show PVs not belonging to any VG.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-s\fP|\fB--short\fP
 .br
-.ad b
 Short listing format.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-u\fP|\fB--uuid\fP
 .br
-.ad b
 Show UUIDs in addition to device names.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIPV\fP
-.br
+.
+.TP
+.I PV
 Physical Volume name, a device path under /dev.
 For commands managing physical extents, a PV positional arg
 generally accepts a suffix indicating a range (or multiple ranges)
@@ -411,91 +347,36 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/vgcfgbackup.8_pregen b/man/vgcfgbackup.8_pregen
index 1ef11ffb0..ce7102595 100644
--- a/man/vgcfgbackup.8_pregen
+++ b/man/vgcfgbackup.8_pregen
@@ -1,382 +1,277 @@
 .TH VGCFGBACKUP 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-vgcfgbackup - Backup volume group configuration(s)
+.
+vgcfgbackup \(em Backup volume group configuration(s)
 .
 .SH SYNOPSIS
+.
 \fBvgcfgbackup\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 vgcfgbackup creates back up files containing metadata of VGs.
 If no VGs are named, back up files are created for all VGs.
 See \fBvgcfgrestore\fP for information on using the back up
 files.
-
+.P
 In a default installation, each VG is backed up into a separate file
 bearing the name of the VG in the directory \fI#DEFAULT_BACKUP_DIR#\fP.
-
+.P
 To use an alternative back up file, use \fB-f\fP. In this case, when
 backing up multiple VGs, the file name is treated as a template, with %s
 replaced by the VG name.
-
+.P
 NB. This DOES NOT back up the data content of LVs.
-
+.P
 It may also be useful to regularly back up the files in
 \fI#DEFAULT_SYS_DIR#\fP.
+.
 .SH USAGE
+.
 \fBvgcfgbackup\fP
 .br
 .RS 4
 .ad l
 [ \fB-f\fP|\fB--file\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--foreign\fP ]
-.ad b
 .br
-.ad l
 [    \fB--ignorelockingfailure\fP ]
-.ad b
 .br
-.ad l
 [    \fB--readonly\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIVG\fP ... ]
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-f\fP|\fB--file\fP \fIString\fP
 .br
-.ad b
 Write the backup to the named file.
 When backing up more than one VG, the file name is
 treated as a template, and %s is replaced by the VG name.
+.
 .HP
-.ad l
 \fB--foreign\fP
 .br
-.ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--ignorelockingfailure\fP
 .br
-.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--readonly\fP
 .br
-.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/vgcfgrestore.8_pregen b/man/vgcfgrestore.8_pregen
index 151aa2505..841626728 100644
--- a/man/vgcfgrestore.8_pregen
+++ b/man/vgcfgrestore.8_pregen
@@ -1,8 +1,11 @@
 .TH VGCFGRESTORE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-vgcfgrestore - Restore volume group configuration
+.
+vgcfgrestore \(em Restore volume group configuration
 .
 .SH SYNOPSIS
+.
 \fBvgcfgrestore\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
@@ -12,472 +15,333 @@ vgcfgrestore - Restore volume group configuration
 .P
 .ad l
     \fB--commandprofile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--config\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-d\fP|\fB--debug\fP
-.ad b
 .br
-.ad l
     \fB--devices\fP \fIPV\fP
-.ad b
 .br
-.ad l
     \fB--devicesfile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--driverloaded\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
  \fB-f\fP|\fB--file\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--force\fP
-.ad b
 .br
-.ad l
  \fB-h\fP|\fB--help\fP
-.ad b
 .br
-.ad l
  \fB-l\fP|\fB--list\fP
-.ad b
 .br
-.ad l
     \fB--lockopt\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--longhelp\fP
-.ad b
 .br
-.ad l
  \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
-.ad b
 .br
-.ad l
     \fB--nolocking\fP
-.ad b
 .br
-.ad l
     \fB--profile\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-q\fP|\fB--quiet\fP
-.ad b
 .br
-.ad l
  \fB-t\fP|\fB--test\fP
-.ad b
 .br
-.ad l
  \fB-v\fP|\fB--verbose\fP
-.ad b
 .br
-.ad l
     \fB--version\fP
-.ad b
 .br
-.ad l
  \fB-y\fP|\fB--yes\fP
 .ad b
+.
 .SH DESCRIPTION
+.
 vgcfgrestore restores the metadata of a VG from a text back up file
 produced by \fBvgcfgbackup\fP. This writes VG metadata onto the devices
 specifed in back up file.
-
+.P
 A back up file can be specified with \fB--file\fP.  If no backup file is
 specified, the most recent one is used. Use \fB--list\fP for a list of
 the available back up and archive files of a VG.
-
+.P
 WARNING: When a VG contains thin pools, changes to thin metadata cannot be
 reverted, and data loss may occur if thin metadata has changed. The force
 option is required to restore in this case.
+.
 .SH USAGE
+.
 Restore VG metadata from last backup.
 .br
 .P
 \fBvgcfgrestore\fP \fIVG\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Restore VG metadata from specified file.
 .br
 .P
 \fBvgcfgrestore\fP \fB-f\fP|\fB--file\fP \fIString\fP \fIVG\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 List all VG metadata backups.
 .br
 .P
 \fBvgcfgrestore\fP \fB-l\fP|\fB--list\fP \fIVG\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 List one VG metadata backup file.
 .br
 .P
 \fBvgcfgrestore\fP \fB-l\fP|\fB--list\fP \fB-f\fP|\fB--file\fP \fIString\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIVG\fP ]
 .RE
--
-
+.P
+\(em
+.P
 Common options for command:
 .
 .RS 4
 .ad l
 [ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP ]
-.ad b
 .br
-.ad l
 [    \fB--force\fP ]
 .ad b
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-f\fP|\fB--file\fP \fIString\fP
 .br
-.ad b
 Read metadata backup from the named file.
 Usually this file was created by vgcfgbackup.
+.
 .HP
-.ad l
 \fB--force\fP ...
 .br
-.ad b
 Force metadata restore even with thin pool LVs.
 Use with extreme caution. Most changes to thin metadata
 cannot be reverted.
 You may lose data if you restore metadata that does not match the
 thin pool kernel metadata precisely.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB-l\fP|\fB--list\fP
 .br
-.ad b
 List metadata backup and archive files pertaining to the VG.
 May be used with --file. Does not restore the VG.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
-.ad b
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
 \fBlvm1\fP (or just \fB1\fP) is no longer used.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH NOTES
-
-To replace PVs, \fBvgdisplay --partial --verbose\fP will show the
-UUIDs and sizes of any PVs that are no longer present. If a PV in the VG
-is lost and you wish to substitute another of the same size, use
-\fBpvcreate --restorefile filename --uuid uuid\fP (plus additional
-arguments as appropriate) to initialise it with the same UUID as the
-missing PV. Repeat for all other missing PVs in the VG.  Then use
-\fBvgcfgrestore --file filename\fP to restore the VG's metadata.
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index 025113627..857dabf04 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -1,8 +1,11 @@
 .TH VGCHANGE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-vgchange - Change volume group attributes
+.
+vgchange \(em Change volume group attributes
 .
 .SH SYNOPSIS
+.
 \fBvgchange\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
@@ -12,206 +15,114 @@ vgchange - Change volume group attributes
 .P
 .ad l
  \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
-.ad b
 .br
-.ad l
     \fB--activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP
-.ad b
 .br
-.ad l
     \fB--addtag\fP \fITag\fP
-.ad b
 .br
-.ad l
-    \fB--alloc\fP 
+    \fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
-.ad b
 .br
-.ad l
  \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--commandprofile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--config\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-d\fP|\fB--debug\fP
-.ad b
 .br
-.ad l
     \fB--deltag\fP \fITag\fP
-.ad b
 .br
-.ad l
     \fB--detachprofile\fP
-.ad b
 .br
-.ad l
     \fB--devices\fP \fIPV\fP
-.ad b
 .br
-.ad l
     \fB--devicesfile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--driverloaded\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
  \fB-f\fP|\fB--force\fP
-.ad b
 .br
-.ad l
  \fB-h\fP|\fB--help\fP
-.ad b
 .br
-.ad l
  \fB-K\fP|\fB--ignoreactivationskip\fP
-.ad b
 .br
-.ad l
     \fB--ignorelockingfailure\fP
-.ad b
 .br
-.ad l
     \fB--ignoremonitoring\fP
-.ad b
 .br
-.ad l
     \fB--lockopt\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--lockstart\fP
-.ad b
 .br
-.ad l
     \fB--lockstop\fP
-.ad b
 .br
-.ad l
     \fB--locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP
-.ad b
 .br
-.ad l
  \fB-l\fP|\fB--logicalvolume\fP \fINumber\fP
-.ad b
 .br
-.ad l
     \fB--longhelp\fP
-.ad b
 .br
-.ad l
  \fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP
-.ad b
 .br
-.ad l
     \fB--metadataprofile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--monitor\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--nolocking\fP
-.ad b
 .br
-.ad l
     \fB--noudevsync\fP
-.ad b
 .br
-.ad l
  \fB-P\fP|\fB--partial\fP
-.ad b
 .br
-.ad l
  \fB-s\fP|\fB--physicalextentsize\fP \fISize\fP[m|UNIT]
-.ad b
 .br
-.ad l
     \fB--poll\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--profile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
-.ad b
 .br
-.ad l
  \fB-q\fP|\fB--quiet\fP
-.ad b
 .br
-.ad l
     \fB--readonly\fP
-.ad b
 .br
-.ad l
     \fB--refresh\fP
-.ad b
 .br
-.ad l
     \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
-.ad b
 .br
-.ad l
  \fB-x\fP|\fB--resizeable\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
  \fB-S\fP|\fB--select\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--setautoactivation\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--sysinit\fP
-.ad b
 .br
-.ad l
     \fB--systemid\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-t\fP|\fB--test\fP
-.ad b
 .br
-.ad l
  \fB-u\fP|\fB--uuid\fP
-.ad b
 .br
-.ad l
  \fB-v\fP|\fB--verbose\fP
-.ad b
 .br
-.ad l
     \fB--version\fP
-.ad b
 .br
-.ad l
-    \fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
-.ad b
+    \fB--\fP[\fBvg\fP]\fBmetadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
 .br
-.ad l
  \fB-y\fP|\fB--yes\fP
 .ad b
+.
 .SH DESCRIPTION
+.
 vgchange changes VG attributes, changes LV activation in the kernel, and
 includes other utilities for VG maintenance.
+.
 .SH USAGE
+.
 Change a general VG attribute. 
 .br
 For options listed in parentheses, any one is 
@@ -235,14 +146,14 @@ required, after which the others are optional.
 .br
      \fB--deltag\fP \fITag\fP
 .br
-     \fB--alloc\fP 
+     \fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
 .br
      \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
-     \fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
+     \fB--\fP[\fBvg\fP]\fBmetadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
 .br
      \fB--profile\fP \fIString\fP
 .br
@@ -256,40 +167,28 @@ required, after which the others are optional.
 .RS 4
 .ad l
 [ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [ \fB-f\fP|\fB--force\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poll\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--ignoremonitoring\fP ]
-.ad b
 .br
-.ad l
 [    \fB--noudevsync\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIVG\fP|\fITag\fP|\fISelect\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Start or stop monitoring LVs from dmeventd.
 .br
 .P
@@ -298,48 +197,32 @@ Start or stop monitoring LVs from dmeventd.
 .RS 4
 .ad l
 [ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [ \fB-f\fP|\fB--force\fP ]
-.ad b
 .br
-.ad l
 [    \fB--sysinit\fP ]
-.ad b
 .br
-.ad l
 [    \fB--ignorelockingfailure\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poll\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--ignoremonitoring\fP ]
-.ad b
 .br
-.ad l
 [    \fB--noudevsync\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIVG\fP|\fITag\fP|\fISelect\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Start or stop processing LV conversions.
 .br
 .P
@@ -348,40 +231,28 @@ Start or stop processing LV conversions.
 .RS 4
 .ad l
 [ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [ \fB-f\fP|\fB--force\fP ]
-.ad b
 .br
-.ad l
 [    \fB--ignorelockingfailure\fP ]
-.ad b
 .br
-.ad l
 [    \fB--ignoremonitoring\fP ]
-.ad b
 .br
-.ad l
 [    \fB--noudevsync\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIVG\fP|\fITag\fP|\fISelect\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Activate or deactivate LVs.
 .br
 .P
@@ -390,68 +261,42 @@ Activate or deactivate LVs.
 .RS 4
 .ad l
 [ \fB-K\fP|\fB--ignoreactivationskip\fP ]
-.ad b
 .br
-.ad l
 [ \fB-P\fP|\fB--partial\fP ]
-.ad b
 .br
-.ad l
 [ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [ \fB-f\fP|\fB--force\fP ]
-.ad b
 .br
-.ad l
 [    \fB--activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP ]
-.ad b
 .br
-.ad l
 [    \fB--sysinit\fP ]
-.ad b
 .br
-.ad l
 [    \fB--readonly\fP ]
-.ad b
 .br
-.ad l
 [    \fB--ignorelockingfailure\fP ]
-.ad b
 .br
-.ad l
 [    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poll\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--ignoremonitoring\fP ]
-.ad b
 .br
-.ad l
 [    \fB--noudevsync\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIVG\fP|\fITag\fP|\fISelect\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Reactivate LVs using the latest metadata.
 .br
 .P
@@ -460,59 +305,45 @@ Reactivate LVs using the latest metadata.
 .RS 4
 .ad l
 [ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [ \fB-f\fP|\fB--force\fP ]
-.ad b
 .br
-.ad l
 [    \fB--sysinit\fP ]
-.ad b
 .br
-.ad l
 [    \fB--ignorelockingfailure\fP ]
-.ad b
 .br
-.ad l
 [    \fB--poll\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--ignoremonitoring\fP ]
-.ad b
 .br
-.ad l
 [    \fB--noudevsync\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIVG\fP|\fITag\fP|\fISelect\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Change the system ID of a VG.
 .br
 .P
 \fBvgchange\fP \fB--systemid\fP \fIString\fP \fIVG\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Start the lockspace of a shared VG in lvmlockd.
 .br
 .P
@@ -521,16 +352,16 @@ Start the lockspace of a shared VG in lvmlockd.
 .RS 4
 .ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIVG\fP|\fITag\fP|\fISelect\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Stop the lockspace of a shared VG in lvmlockd.
 .br
 .P
@@ -539,105 +370,80 @@ Stop the lockspace of a shared VG in lvmlockd.
 .RS 4
 .ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIVG\fP|\fITag\fP|\fISelect\fP ... ]
 .RE
--
-
+.P
+\(em
+.P
 Change the lock type for a shared VG.
 .br
 .P
 \fBvgchange\fP \fB--locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP \fIVG\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Common options for command:
 .
 .RS 4
+.ad l
+.ad b
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .br
-.ad b
 Change the active state of LVs.
 An active LV can be used through a block device,
 allowing data on the LV to be accessed.
@@ -655,18 +461,17 @@ activation commands.  By default, LVs are autoactivated.
 An autoactivation property can be set on a VG or LV to disable autoactivation,
 see --setautoactivation y|n in vgchange, lvchange, vgcreate, and lvcreate.
 Display the property with vgs or lvs "-o autoactivation".
-The lvm.conf auto_activation_volume_list includes names of VGs or LVs
+The \fBlvm.conf\fP(5) auto_activation_volume_list includes names of VGs or LVs
 that should be autoactivated, and anything not listed is not autoactivated.
 When auto_activation_volume_list is undefined (the default), it has no effect.
 If auto_activation_volume_list is defined and empty, no LVs are autoactivated.
 Items included by auto_activation_volume_list will not be autoactivated if
 the autoactivation property has been disabled.
 See \fBlvmlockd\fP(8) for more information about activation options \fBey\fP and \fBsy\fP for shared VGs.
+.
 .HP
-.ad l
 \fB--activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP
 .br
-.ad b
 Determines if LV activation is allowed when PVs are missing,
 e.g. because of a device failure.
 \fBcomplete\fP only allows LVs with no missing PVs to be activated,
@@ -675,23 +480,23 @@ and is the most restrictive mode.
 (This does not include the "mirror" type, see "raid1" instead.)
 \fBpartial\fP allows any LV with missing PVs to be activated, and
 should only be used for recovery or repair.
-For default, see lvm.conf/activation_mode.
+For default, see \fBlvm.conf\fP(5) activation_mode.
 See \fBlvmraid\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--addtag\fP \fITag\fP
 .br
-.ad b
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
+.
 .HP
 .ad l
-\fB--alloc\fP 
+\fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
-.br
 .ad b
+.br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
 which can be changed with vgchange/lvchange, or overridden on the
@@ -708,205 +513,178 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
+.
 .HP
-.ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--deltag\fP \fITag\fP
 .br
-.ad b
 Deletes a tag from a PV, VG or LV. This option can be repeated to delete
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
+.
 .HP
-.ad l
 \fB--detachprofile\fP
 .br
-.ad b
 Detaches a metadata profile from a VG or LV.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-f\fP|\fB--force\fP ...
 .br
-.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB-K\fP|\fB--ignoreactivationskip\fP
 .br
-.ad b
 Ignore the "activation skip" LV flag during activation
 to allow LVs with the flag set to be activated.
+.
 .HP
-.ad l
 \fB--ignorelockingfailure\fP
 .br
-.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
+.
 .HP
-.ad l
 \fB--ignoremonitoring\fP
 .br
-.ad b
 Do not interact with dmeventd unless --monitor is specified.
 Do not use this if dmeventd is already monitoring a device.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--lockstart\fP
 .br
-.ad b
 Start the lockspace of a shared VG in lvmlockd.
 lvmlockd locks becomes available for the VG, allowing LVM to use the VG.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--lockstop\fP
 .br
-.ad b
 Stop the lockspace of a shared VG in lvmlockd.
 lvmlockd locks become unavailable for the VG, preventing LVM from using the VG.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP
 .br
-.ad b
 Change the VG lock type to or from a shared lock type used with lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB-l\fP|\fB--logicalvolume\fP \fINumber\fP
 .br
-.ad b
 Sets the maximum number of LVs allowed in a VG.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP
 .br
-.ad b
 Sets the maximum number of PVs that can belong to the VG.
 The value 0 removes any limitation.
 For large numbers of PVs, also see options --pvmetadatacopies,
 and --vgmetadatacopies for improving performance.
+.
 .HP
-.ad l
 \fB--metadataprofile\fP \fIString\fP
 .br
-.ad b
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--monitor\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Start (yes) or stop (no) monitoring an LV with dmeventd.
 dmeventd monitors kernel events for an LV, and performs
 automated maintenance for the LV in reponse to specific events.
 See \fBdmeventd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--noudevsync\fP
 .br
-.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
+.
 .HP
-.ad l
 \fB-P\fP|\fB--partial\fP
 .br
-.ad b
 Commands will do their best to activate LVs with missing PV extents.
 Missing extents may be replaced with error or zero segments
-according to the lvm.conf missing_stripe_filler setting.
+according to the  missing_stripe_filler setting.
 Metadata may not be changed with this option.
+.
 .HP
-.ad l
 \fB-s\fP|\fB--physicalextentsize\fP \fISize\fP[m|UNIT]
 .br
-.ad b
 Sets the physical extent size of PVs in the VG.
 The value must be either a power of 2 of at least 1 sector
 (where the sector size is the largest sector size of the PVs
@@ -916,11 +694,10 @@ without recreating the VG, unless no extents need moving.
 Before increasing the physical extent size, you might need to use lvresize,
 pvresize and/or pvmove so that everything fits. For example, every
 contiguous range of extents used in a LV must start and end on an extent boundary.
+.
 .HP
-.ad l
 \fB--poll\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 When yes, start the background transformation of an LV.
 An incomplete transformation, e.g. pvmove or lvconvert interrupted
 by reboot or crash, can be restarted from the last checkpoint with --poll y.
@@ -928,18 +705,16 @@ When no, background transformation of an LV will not occur, and the
 transformation will not complete. It may not be appropriate to immediately
 poll an LV after activation, in which case --poll n can be used to defer
 polling until a later --poll y command.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
-.ad b
 The number of metadata areas to set aside on a PV for storing VG metadata.
 When 2, one copy of the VG metadata is stored at the front of the PV
 and a second copy is stored at the end.
@@ -947,56 +722,50 @@ When 1, one copy of the VG metadata is stored at the front of the PV.
 When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--readonly\fP
 .br
-.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
+.
 .HP
-.ad l
 \fB--refresh\fP
 .br
-.ad b
 If the LV is active, reload its metadata.
 This is not necessary in normal operation, but may be useful
 if something has gone wrong, or if some form of manual LV
 sharing is being used.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-x\fP|\fB--resizeable\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Enables or disables the addition or removal of PVs to/from a VG
 (by vgextend/vgreduce).
+.
 .HP
-.ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
-.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -1005,11 +774,10 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
+.
 .HP
-.ad l
 \fB--setautoactivation\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Set the autoactivation property on a VG or LV.
 Display the property with vgs or lvs "-o autoactivation".
 When the autoactivation property is disabled, the VG or LV
@@ -1019,11 +787,10 @@ If autoactivation is disabled on a VG, no LVs will be autoactivated
 in that VG, and the LV autoactivation property has no effect.
 If autoactivation is enabled on a VG, autoactivation can be disabled
 for individual LVs.
+.
 .HP
-.ad l
 \fB--sysinit\fP
 .br
-.ad b
 Indicates that vgchange/lvchange is being invoked from early system initialisation
 scripts (e.g. rc.sysinit or an initrd), before writable filesystems are
 available. As such, some functionality needs to be disabled and this option
@@ -1031,49 +798,43 @@ acts as a shortcut which selects an appropriate set of options. Currently,
 this is equivalent to using --ignorelockingfailure, --ignoremonitoring,
 --poll n, and setting env var LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES.
 vgchange/lvchange skip autoactivation, and defer to pvscan autoactivation.
+.
 .HP
-.ad l
 \fB--systemid\fP \fIString\fP
 .br
-.ad b
 Changes the system ID of the VG.  Using this option requires caution
 because the VG may become foreign to the host running the command,
 leaving the host unable to access it.
 See \fBlvmsystemid\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-u\fP|\fB--uuid\fP
 .br
-.ad b
 Generate new random UUID for specified VGs.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
-\fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
+\fB--\fP[\fBvg\fP]\fBmetadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
 .br
-.ad b
 Number of copies of the VG metadata that are kept.
 VG metadata is kept in VG metadata areas on PVs in the VG,
 i.e. reserved space at the start and/or end of the PVs.
@@ -1087,127 +848,58 @@ The number can also be replaced with special string values:
 metadataignore flags.
 \fBall\fP causes LVM to first clear the metadataignore flags on
 all PVs, and then to become unmanaged.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fITag\fP
-.br
+.TP
+.I Tag
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
-\fISelect\fP
-.br
+.TP
+.I Select
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH NOTES
-If vgchange recognizes COW snapshot LVs that were dropped because they ran
-out of space, it displays a message informing the administrator that the
-snapshots should be removed.
-.SH EXAMPLES
-Activate all LVs in all VGs on all existing devices.
-.br
-.B vgchange -a y
-
-Change the maximum number of LVs for an inactive VG.
-.br
-.B vgchange -l 128 vg00
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/vgck.8_pregen b/man/vgck.8_pregen
index aef35f3b2..f177dfbdd 100644
--- a/man/vgck.8_pregen
+++ b/man/vgck.8_pregen
@@ -1,17 +1,24 @@
 .TH VGCK 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-vgck - Check the consistency of volume group(s)
+.
+vgck \(em Check the consistency of volume group(s)
 .
 .SH SYNOPSIS
+.
 \fBvgck\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 vgck checks LVM metadata for consistency.
+.
 .SH USAGE
+.
 Read and display information about a VG.
 .br
 .P
@@ -20,211 +27,170 @@ Read and display information about a VG.
 .RS 4
 .ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIVG\fP|\fITag\fP ... ]
 .RE
-
+.P
 Rewrite VG metadata to correct problems.
 .br
 .P
 \fBvgck\fP \fB--updatemetadata\fP \fIVG\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Common options for command:
 .
 .RS 4
+.ad l
+.ad b
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB--updatemetadata\fP
 .br
-.ad b
 Update VG metadata to correct problems.
 If VG metadata was updated while a PV was missing, and the PV
 reappears with an old version of metadata, then this option
@@ -235,122 +201,64 @@ this option will clear the outdated metadata from the previously
 missing PV. If metadata text is damaged on one PV, using this
 option will replace the damaged metadata text. For more severe
 damage, e.g. with headers, see \fBpvck\fP(8).
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fITag\fP
-.br
+.TP
+.I Tag
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/vgconvert.8_pregen b/man/vgconvert.8_pregen
index 093512ab0..d18e7af08 100644
--- a/man/vgconvert.8_pregen
+++ b/man/vgconvert.8_pregen
@@ -1,125 +1,90 @@
 .TH VGCONVERT 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-vgconvert - Change volume group metadata format
+.
+vgconvert \(em Change volume group metadata format
 .
 .SH SYNOPSIS
+.
 \fBvgconvert\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 vgconvert is no longer a part of LVM.  It was removed along with
 support for the LVM1 format.  Use an older version of LVM to
 convert VGs from the LVM1 format to LVM2.
+.
 .SH USAGE
+.
 \fBvgconvert\fP \fIVG\fP ...
 .br
 .RS 4
 .ad l
 [ \fB-f\fP|\fB--force\fP ]
-.ad b
 .br
-.ad l
 [ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP ]
-.ad b
 .br
-.ad l
 [    \fB--labelsector\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [    \fB--bootloaderareasize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP ]
-.ad b
 .br
-.ad l
 [    \fB--metadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
-
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--bootloaderareasize\fP \fISize\fP[m|UNIT]
 .br
-.ad b
 Reserve space for the bootloader between the LVM metadata area and the first PE.
 The bootloader area is reserved for bootloaders to embed their own data or
 metadata; LVM will not use it.
@@ -131,122 +96,106 @@ and --dataalignmentoffset. The bootloader area may be larger than requested
 due to the alignment, but it's never less than the requested size.
 To see the bootloader area start and size of
 an existing PV use pvs -o +pv_ba_start,pv_ba_size.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-f\fP|\fB--force\fP ...
 .br
-.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--labelsector\fP \fINumber\fP
 .br
-.ad b
 By default the PV is labelled with an LVM2 identifier in its second
 sector (sector 1). This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source). Use with care.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--metadatasize\fP \fISize\fP[m|UNIT]
 .br
-.ad b
 The approximate amount of space used for each VG metadata area.
 The size may be rounded.
+.
 .HP
-.ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
-.ad b
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
 \fBlvm1\fP (or just \fB1\fP) is no longer used.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
-.ad b
 The number of metadata areas to set aside on a PV for storing VG metadata.
 When 2, one copy of the VG metadata is stored at the front of the PV
 and a second copy is stored at the end.
@@ -254,146 +203,85 @@ When 1, one copy of the VG metadata is stored at the front of the PV.
 When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/vgcreate.8_pregen b/man/vgcreate.8_pregen
index 3a3c35a08..7e357a548 100644
--- a/man/vgcreate.8_pregen
+++ b/man/vgcreate.8_pregen
@@ -1,206 +1,141 @@
 .TH VGCREATE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-vgcreate - Create a volume group
+.
+vgcreate \(em Create a volume group
 .
 .SH SYNOPSIS
+.
 \fBvgcreate\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 vgcreate creates a new VG on block devices. If the devices were not
 previously initialized as PVs with \fBpvcreate\fP(8), vgcreate will
 inititialize them, making them PVs. The pvcreate options for initializing
 devices are also available with vgcreate.
-
+.P
 When vgcreate uses an existing PV, that PV's existing values for metadata
 size, PE start, etc, are used, even if different values are specified in
 the vgcreate command.  To change these values, first use pvremove on the
 device.
-
+.
 .SH USAGE
+.
 \fBvgcreate\fP \fIVG\fP\fI_new\fP \fIPV\fP ...
 .br
 .RS 4
 .ad l
 [ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-c\fP|\fB--clustered\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-l\fP|\fB--maxlogicalvolumes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP ]
-.ad b
 .br
-.ad l
 [ \fB-s\fP|\fB--physicalextentsize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [ \fB-f\fP|\fB--force\fP ]
-.ad b
 .br
-.ad l
 [ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--addtag\fP \fITag\fP ]
-.ad b
 .br
-.ad l
-[    \fB--alloc\fP 
+[    \fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
 ]
-.ad b
 .br
-.ad l
 [    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--labelsector\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [    \fB--metadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP ]
-.ad b
 .br
-.ad l
-[    \fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP ]
-.ad b
+[    \fB--\fP[\fBvg\fP]\fBmetadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP ]
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
-.ad l
 [    \fB--dataalignment\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--dataalignmentoffset\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--shared\fP ]
-.ad b
 .br
-.ad l
 [    \fB--systemid\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP ]
-.ad b
 .br
-.ad l
 [    \fB--setautoactivation\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--addtag\fP \fITag\fP
 .br
-.ad b
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
+.
 .HP
 .ad l
-\fB--alloc\fP 
+\fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
-.br
 .ad b
+.br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
 which can be changed with vgchange/lvchange, or overridden on the
@@ -217,192 +152,167 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
+.
 .HP
-.ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
+.
 .HP
-.ad l
 \fB-c\fP|\fB--clustered\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 This option was specific to clvm and is now replaced by
 the --shared option with \fBlvmlockd\fP(8).
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB--dataalignment\fP \fISize\fP[k|UNIT]
 .br
-.ad b
 Align the start of a PV data area with a multiple of this number.
 To see the location of the first Physical Extent (PE) of an existing PV,
 use pvs -o +pe_start. In addition, it may be shifted by an alignment offset,
 see --dataalignmentoffset.
 Also specify an appropriate PE size when creating a VG.
+.
 .HP
-.ad l
 \fB--dataalignmentoffset\fP \fISize\fP[k|UNIT]
 .br
-.ad b
 Shift the start of the PV data area by this additional offset.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-f\fP|\fB--force\fP ...
 .br
-.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--labelsector\fP \fINumber\fP
 .br
-.ad b
 By default the PV is labelled with an LVM2 identifier in its second
 sector (sector 1). This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source). Use with care.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP
 .br
-.ad b
 Specify the VG lock type directly in place of using --shared.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB-l\fP|\fB--maxlogicalvolumes\fP \fINumber\fP
 .br
-.ad b
 Sets the maximum number of LVs allowed in a VG.
+.
 .HP
-.ad l
 \fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP
 .br
-.ad b
 Sets the maximum number of PVs that can belong to the VG.
 The value 0 removes any limitation.
 For large numbers of PVs, also see options --pvmetadatacopies,
 and --vgmetadatacopies for improving performance.
+.
 .HP
-.ad l
 \fB--metadataprofile\fP \fIString\fP
 .br
-.ad b
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--metadatasize\fP \fISize\fP[m|UNIT]
 .br
-.ad b
 The approximate amount of space used for each VG metadata area.
 The size may be rounded.
+.
 .HP
-.ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
-.ad b
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
 \fBlvm1\fP (or just \fB1\fP) is no longer used.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB-s\fP|\fB--physicalextentsize\fP \fISize\fP[m|UNIT]
 .br
-.ad b
 Sets the physical extent size of PVs in the VG.
 The value must be either a power of 2 of at least 1 sector
 (where the sector size is the largest sector size of the PVs
 currently used in the VG), or at least 128KiB.
 Once this value has been set, it is difficult to change
 without recreating the VG, unless no extents need moving.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
-.ad b
 The number of metadata areas to set aside on a PV for storing VG metadata.
 When 2, one copy of the VG metadata is stored at the front of the PV
 and a second copy is stored at the end.
@@ -410,29 +320,26 @@ When 1, one copy of the VG metadata is stored at the front of the PV.
 When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--setautoactivation\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Set the autoactivation property on a VG or LV.
 Display the property with vgs or lvs "-o autoactivation".
 When the autoactivation property is disabled, the VG or LV
@@ -442,21 +349,19 @@ If autoactivation is disabled on a VG, no LVs will be autoactivated
 in that VG, and the LV autoactivation property has no effect.
 If autoactivation is enabled on a VG, autoactivation can be disabled
 for individual LVs.
+.
 .HP
-.ad l
 \fB--shared\fP
 .br
-.ad b
 Create a shared VG using lvmlockd if LVM is compiled with lockd support.
 lvmlockd will select lock type sanlock or dlm depending on which lock
 manager is running. This allows multiple hosts to share a VG on shared
 devices. lvmlockd and a lock manager must be configured and running.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
+.
 .HP
-.ad l
 \fB--systemid\fP \fIString\fP
 .br
-.ad b
 Specifies the system ID that will be given to the new VG, overriding the
 system ID of the host running the command. A VG is normally created
 without this option, in which case the new VG is given the system ID of
@@ -464,34 +369,30 @@ the host creating it. Using this option requires caution because the
 system ID of the new VG may not match the system ID of the host running
 the command, leaving the VG inaccessible to the host.
 See \fBlvmsystemid\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
-\fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
+\fB--\fP[\fBvg\fP]\fBmetadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
 .br
-.ad b
 Number of copies of the VG metadata that are kept.
 VG metadata is kept in VG metadata areas on PVs in the VG,
 i.e. reserved space at the start and/or end of the PVs.
@@ -505,30 +406,28 @@ The number can also be replaced with special string values:
 metadataignore flags.
 \fBall\fP causes LVM to first clear the metadataignore flags on
 all PVs, and then to become unmanaged.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .HP
-.ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Controls if the first 4 sectors (2048 bytes) of the device are wiped.
 The default is to wipe these sectors unless either or both of
 --restorefile or --uuid are specified.
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fIPV\fP
-.br
+.TP
+.I PV
 Physical Volume name, a device path under /dev.
 For commands managing physical extents, a PV positional arg
 generally accepts a suffix indicating a range (or multiple ranges)
@@ -536,96 +435,36 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH EXAMPLES
-
-Create a VG with two PVs, using the default physical extent size.
-.br
-.B vgcreate myvg /dev/sdk1 /dev/sdl1
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/vgdisplay.8_pregen b/man/vgdisplay.8_pregen
index a6f8106f2..467f74506 100644
--- a/man/vgdisplay.8_pregen
+++ b/man/vgdisplay.8_pregen
@@ -1,337 +1,257 @@
 .TH VGDISPLAY 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-vgdisplay - Display volume group information
+.
+vgdisplay \(em Display volume group information
 .
 .SH SYNOPSIS
+.
 \fBvgdisplay\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 vgdisplay shows the attributes of VGs, and the associated PVs and LVs.
-
+.P
 \fBvgs\fP(8) is a preferred alternative that shows the same information
 and more, using a more compact and configurable output format.
+.
 .SH USAGE
+.
 \fBvgdisplay\fP
 .br
 .RS 4
 .ad l
 [ \fB-A\fP|\fB--activevolumegroups\fP ]
-.ad b
 .br
-.ad l
 [ \fB-c\fP|\fB--colon\fP ]
-.ad b
 .br
-.ad l
 [ \fB-C\fP|\fB--columns\fP ]
-.ad b
 .br
-.ad l
 [ \fB-o\fP|\fB--options\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [ \fB-s\fP|\fB--short\fP ]
-.ad b
 .br
-.ad l
 [ \fB-O\fP|\fB--sort\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--aligned\fP ]
-.ad b
 .br
-.ad l
 [    \fB--binary\fP ]
-.ad b
 .br
-.ad l
 [    \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP ]
-.ad b
 .br
-.ad l
 [    \fB--foreign\fP ]
-.ad b
 .br
-.ad l
 [    \fB--ignorelockingfailure\fP ]
-.ad b
 .br
-.ad l
 [    \fB--logonly\fP ]
-.ad b
 .br
-.ad l
 [    \fB--noheadings\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nosuffix\fP ]
-.ad b
 .br
-.ad l
 [    \fB--readonly\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
-.ad l
 [    \fB--shared\fP ]
-.ad b
 .br
-.ad l
 [    \fB--separator\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--unbuffered\fP ]
-.ad b
 .br
-.ad l
-[    \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP ]
-.ad b
+[    \fB--units\fP \c
+.nh
+\%[\fINumber\fP]\fBr\fP|\:\fBR\fP|\:\fBh\fP|\:\fBH\fP|\:\fBb\fP|\:\fBB\fP|\:\fBs\fP|\:\fBS\fP|\:\fBk\fP|\:\fBK\fP|\:\fBm\fP|\:\fBM\fP|\:\fBg\fP|\:\fBG\fP|\:\fBt\fP|\:\fBT\fP|\:\fBp\fP|\:\fBP\fP|\:\fBe\fP|\:\fBE\fP
+.hy
+]
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIVG\fP|\fITag\fP ... ]
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB-A\fP|\fB--activevolumegroups\fP
 .br
-.ad b
 Only select active VGs. The VG is considered active
 if at least one of its LVs is active.
+.
 .HP
-.ad l
 \fB--aligned\fP
 .br
-.ad b
 Use with --separator to align the output columns
+.
 .HP
-.ad l
 \fB--binary\fP
 .br
-.ad b
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
+.
 .HP
-.ad l
 \fB-c\fP|\fB--colon\fP
 .br
-.ad b
 Generate colon separated output for easier parsing in scripts or programs.
 Also see \fBvgs\fP(8) which provides considerably more control over the output.
+.
 .HP
-.ad l
 \fB-C\fP|\fB--columns\fP
 .br
-.ad b
 Display output in columns, the equivalent of \fBvgs\fP(8).
 Options listed are the same as options given in \fBvgs\fP(8).
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
-.ad b
 See \fBlvmreport\fP(7).
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB--foreign\fP
 .br
-.ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--ignorelockingfailure\fP
 .br
-.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--logonly\fP
 .br
-.ad b
 Suppress command report and display only log report.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--noheadings\fP
 .br
-.ad b
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--nosuffix\fP
 .br
-.ad b
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
+.
 .HP
-.ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
 .br
-.ad b
 Comma-separated, ordered list of fields to display in columns.
-String arg syntax is: [+|-|#]Field1[,Field2 ...]
+String arg syntax is: [\fB+\fP|\fB-\fP|\fB#\fP]\fIField1\fP[\fB,\fP\fIField2\fP ...]
 The prefix \fB+\fP will append the specified fields to the default fields,
 \fB-\fP will remove the specified fields from the default fields, and
 \fB#\fP will compact specified fields (removing them when empty for all rows.)
@@ -345,49 +265,44 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBpvseg_all\fP all PV segment fields,
 \fBseg_all\fP all LV segment fields, and
 \fBpvseg_all\fP all PV segment columns.
-See the lvm.conf report section for more config options.
+See the \fBlvm.conf\fP(5) report section for more config options.
 See \fBlvmreport\fP(7) for more information about reporting.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--readonly\fP
 .br
-.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
-.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -396,176 +311,116 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
+.
 .HP
-.ad l
 \fB--separator\fP \fIString\fP
 .br
-.ad b
 String to use to separate each column. Useful if grepping the output.
+.
 .HP
-.ad l
 \fB--shared\fP
 .br
-.ad b
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
+.
 .HP
-.ad l
 \fB-s\fP|\fB--short\fP
 .br
-.ad b
 Give a short listing showing the existence of VGs.
+.
 .HP
-.ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
 .br
-.ad b
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB--unbuffered\fP
 .br
-.ad b
 Produce output immediately without sorting or aligning the columns properly.
+.
 .HP
 .ad l
-\fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
-.br
+\fB--units\fP \c
+.nh
+\%[\fINumber\fP]\fBr\fP|\:\fBR\fP|\:\fBh\fP|\:\fBH\fP|\:\fBb\fP|\:\fBB\fP|\:\fBs\fP|\:\fBS\fP|\:\fBk\fP|\:\fBK\fP|\:\fBm\fP|\:\fBM\fP|\:\fBg\fP|\:\fBG\fP|\:\fBt\fP|\:\fBT\fP|\:\fBp\fP|\:\fBP\fP|\:\fBe\fP|\:\fBE\fP
+.hy
 .ad b
+.br
 All sizes are output in these units:
 human-(r)eadable with '<' rounding indicator,
 (h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fITag\fP
-.br
+.TP
+.I Tag
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/vgexport.8_pregen b/man/vgexport.8_pregen
index 89a25af07..0e6e0b164 100644
--- a/man/vgexport.8_pregen
+++ b/man/vgexport.8_pregen
@@ -1,33 +1,40 @@
 .TH VGEXPORT 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-vgexport - Unregister volume group(s) from the system
+.
+vgexport \(em Unregister volume group(s) from the system
 .
 .SH SYNOPSIS
+.
 \fBvgexport\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 vgexport changes a VG into the exported state, which ensures that the VG
 and its disks are not being used, and cannot be used until the VG is
 imported by \fBvgimport\fP(8).  Putting a VG into an unusable, offline
 state can be useful when doing things like moving a VG's disks to another
 system.  Exporting a VG provides some protection from its LVs being
 accidentally used, or being used by an automated system before it's ready.
-
+.P
 A VG cannot be exported until all of its LVs are inactive.
-
+.P
 LVM commands will ignore an exported VG or report an error if a command
 tries to use it.
-
+.P
 For an exported VG, the vgs command will display \"x\" in the third VG
 attribute, and the pvs command will display \"x\" in the second PV
 attribute.  Both vgs and pvs will display \"exported\" from the export
 report field.
-
+.P
 vgexport clears the VG system ID, and vgimport sets the VG system ID to
 match the host running vgimport (if the host has a system ID).
+.
 .SH USAGE
+.
 Export specified VGs.
 .br
 .P
@@ -36,22 +43,22 @@ Export specified VGs.
 .RS 4
 .ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Export all VGs.
 .br
 .P
 \fBvgexport\fP \fB-a\fP|\fB--all\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Common options for command:
 .
 .RS 4
@@ -59,183 +66,140 @@ Common options for command:
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB-a\fP|\fB--all\fP
 .br
-.ad b
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
-.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -244,138 +208,78 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fITag\fP
-.br
+.TP
+.I Tag
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
-\fISelect\fP
-.br
+.TP
+.I Select
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/vgextend.8_pregen b/man/vgextend.8_pregen
index c4c0b130a..e5e01c4c5 100644
--- a/man/vgextend.8_pregen
+++ b/man/vgextend.8_pregen
@@ -1,296 +1,232 @@
 .TH VGEXTEND 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-vgextend - Add physical volumes to a volume group
+.
+vgextend \(em Add physical volumes to a volume group
 .
 .SH SYNOPSIS
+.
 \fBvgextend\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 vgextend adds one or more PVs to a VG. This increases the space available
 for LVs in the VG.
-
+.P
 Also, PVs that have gone missing and then returned, e.g. due to a
 transient device failure, can be added back to the VG without
 re-initializing them (see --restoremissing).
-
+.P
 If the specified PVs have not yet been initialized with pvcreate, vgextend
 will initialize them. In this case pvcreate options can be used, e.g.
 --labelsector, --metadatasize, --metadataignore,
 --pvmetadatacopies, --dataalignment, --dataalignmentoffset.
+.
 .SH USAGE
+.
 \fBvgextend\fP \fIVG\fP \fIPV\fP ...
 .br
 .RS 4
 .ad l
 [ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-f\fP|\fB--force\fP ]
-.ad b
 .br
-.ad l
 [ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP ]
-.ad b
 .br
-.ad l
 [    \fB--labelsector\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [    \fB--metadatasize\fP \fISize\fP[m|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP ]
-.ad b
 .br
-.ad l
 [    \fB--metadataignore\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--dataalignment\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--dataalignmentoffset\fP \fISize\fP[k|UNIT] ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
-.ad l
 [    \fB--restoremissing\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB--dataalignment\fP \fISize\fP[k|UNIT]
 .br
-.ad b
 Align the start of a PV data area with a multiple of this number.
 To see the location of the first Physical Extent (PE) of an existing PV,
 use pvs -o +pe_start. In addition, it may be shifted by an alignment offset,
 see --dataalignmentoffset.
 Also specify an appropriate PE size when creating a VG.
+.
 .HP
-.ad l
 \fB--dataalignmentoffset\fP \fISize\fP[k|UNIT]
 .br
-.ad b
 Shift the start of the PV data area by this additional offset.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-f\fP|\fB--force\fP ...
 .br
-.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--labelsector\fP \fINumber\fP
 .br
-.ad b
 By default the PV is labelled with an LVM2 identifier in its second
 sector (sector 1). This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source). Use with care.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--metadataignore\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Specifies the metadataignore property of a PV.
 If yes, metadata areas on the PV are ignored, and lvm will
 not store metadata in the metadata areas of the PV.
 If no, lvm will store metadata on the PV.
+.
 .HP
-.ad l
 \fB--metadatasize\fP \fISize\fP[m|UNIT]
 .br
-.ad b
 The approximate amount of space used for each VG metadata area.
 The size may be rounded.
+.
 .HP
-.ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
-.ad b
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
 \fBlvm1\fP (or just \fB1\fP) is no longer used.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
-.ad b
 The number of metadata areas to set aside on a PV for storing VG metadata.
 When 2, one copy of the VG metadata is stored at the front of the PV
 and a second copy is stored at the end.
@@ -298,78 +234,70 @@ When 1, one copy of the VG metadata is stored at the front of the PV.
 When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--restoremissing\fP
 .br
-.ad b
 Add a PV back into a VG after the PV was missing and then returned,
 e.g. due to a transient failure. The PV is not reinitialized.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .HP
-.ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Controls if the first 4 sectors (2048 bytes) of the device are wiped.
 The default is to wipe these sectors unless either or both of
 --restorefile or --uuid are specified.
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fIPV\fP
-.br
+.TP
+.I PV
 Physical Volume name, a device path under /dev.
 For commands managing physical extents, a PV positional arg
 generally accepts a suffix indicating a range (or multiple ranges)
@@ -377,96 +305,36 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH EXAMPLES
-
-Add two PVs to a VG.
-.br
-.B vgextend vg00 /dev/sda4 /dev/sdn1
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/vgimport.8_pregen b/man/vgimport.8_pregen
index 993a52e21..c0b815b65 100644
--- a/man/vgimport.8_pregen
+++ b/man/vgimport.8_pregen
@@ -1,19 +1,26 @@
 .TH VGIMPORT 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-vgimport - Register exported volume group with system
+.
+vgimport \(em Register exported volume group with system
 .
 .SH SYNOPSIS
+.
 \fBvgimport\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 vgimport makes exported VGs known to the system again, perhaps after
 moving the PVs from a different system.
-
+.P
 vgexport clears the VG system ID, and vgimport sets the VG system ID to
 match the host running vgimport (if the host has a system ID).
+.
 .SH USAGE
+.
 Import specified VGs.
 .br
 .P
@@ -22,218 +29,172 @@ Import specified VGs.
 .RS 4
 .ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Import all VGs.
 .br
 .P
 \fBvgimport\fP \fB-a\fP|\fB--all\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Common options for command:
 .
 .RS 4
 .ad l
 [ \fB-f\fP|\fB--force\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB-a\fP|\fB--all\fP
 .br
-.ad b
 Import all visible VGs.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-f\fP|\fB--force\fP ...
 .br
-.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
-.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -242,138 +203,78 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fITag\fP
-.br
+.TP
+.I Tag
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
-\fISelect\fP
-.br
+.TP
+.I Select
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/vgimportclone.8_pregen b/man/vgimportclone.8_pregen
index 2fe7ed60f..ee9bbe66c 100644
--- a/man/vgimportclone.8_pregen
+++ b/man/vgimportclone.8_pregen
@@ -1,252 +1,208 @@
 .TH VGIMPORTCLONE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-vgimportclone - Import a VG from cloned PVs
+.
+vgimportclone \(em Import a VG from cloned PVs
 .
 .SH SYNOPSIS
+.
 \fBvgimportclone\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 vgimportclone imports a VG from duplicated PVs, e.g. created by a hardware
 snapshot of existing PVs.
-
+.P
 A duplicated VG cannot used until it is made to coexist with the original
 VG. vgimportclone renames the VG associated with the specified PVs and
 changes the associated VG and PV UUIDs.
+.
 .SH USAGE
+.
 \fBvgimportclone\fP \fIPV\fP ...
 .br
 .RS 4
 .ad l
 [ \fB-n\fP|\fB--basevgname\fP \fIVG\fP ]
-.ad b
 .br
-.ad l
 [ \fB-i\fP|\fB--import\fP ]
-.ad b
 .br
-.ad l
 [    \fB--importdevices\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB-n\fP|\fB--basevgname\fP \fIString\fP
 .br
-.ad b
 By default the snapshot VG will be renamed to the original name plus a
 numeric suffix to avoid duplicate naming (e.g. 'test_vg' would be renamed
 to 'test_vg1'). This option will override the base VG name that is
 used for all VG renames. If a VG already exists with the specified name
 a numeric suffix will be added (like the previous example) to make it unique.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB-i\fP|\fB--import\fP
 .br
-.ad b
 Import exported VGs. Otherwise VGs that have been exported
 will not be changed (nor will their associated PVs).
+.
 .HP
-.ad l
 \fB--importdevices\fP
 .br
-.ad b
 Add devices to the devices file.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIPV\fP
-.br
+.
+.TP
+.I PV
 Physical Volume name, a device path under /dev.
 For commands managing physical extents, a PV positional arg
 generally accepts a suffix indicating a range (or multiple ranges)
@@ -254,99 +210,36 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH EXAMPLES
-
-An original VG "vg00" has PVs "/dev/sda" and "/dev/sdb".
-The corresponding PVs from a hardware snapshot are "/dev/sdc" and "/dev/sdd".
-Rename the VG associated with "/dev/sdc" and "/dev/sdd" from "vg00" to "vg00_snap"
-(and change associated UUIDs).
-.br
-.B vgimportclone --basevgname vg00_snap /dev/sdc /dev/sdd
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/vgimportdevices.8_pregen b/man/vgimportdevices.8_pregen
index 18beabdfa..364ef52a4 100644
--- a/man/vgimportdevices.8_pregen
+++ b/man/vgimportdevices.8_pregen
@@ -1,25 +1,31 @@
 .TH VGIMPORTDEVICES 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-vgimportdevices - Add devices for a VG to the devices file.
+.
+vgimportdevices \(em Add devices for a VG to the devices file.
 .
 .SH SYNOPSIS
+.
 \fBvgimportdevices\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 vgimportdevices adds PVs from a VG to the devices file.  This is similar
 to using using lvmdevices --adddev to add each PV to the devices file
 individually.  vgimportdevices will also update the VG metadata to include
 the device IDs of each PV.  vgimportdevices will create a new devices file
 if none exists.
-
+.P
 When a devices file is used, the regex filter is ignored, except in the case
 of vgimportdevices which will apply the regex filter when looking for the VGs
 to import to the devices file.  Use vgimportdevices -a to import all VGs on a
 system to the devices file.
-
+.
 .SH USAGE
+.
 Add devices from specific VGs to the devices file.
 .br
 .P
@@ -28,217 +34,171 @@ Add devices from specific VGs to the devices file.
 .RS 4
 .ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Add devices from all accessible VGs to the devices file.
 .br
 .P
 \fBvgimportdevices\fP \fB-a\fP|\fB--all\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Common options for command:
 .
 .RS 4
 .ad l
 [    \fB--foreign\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB-a\fP|\fB--all\fP
 .br
-.ad b
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB--foreign\fP
 .br
-.ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
-.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -247,138 +207,78 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fITag\fP
-.br
+.TP
+.I Tag
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
-\fISelect\fP
-.br
+.TP
+.I Select
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/vgmerge.8_pregen b/man/vgmerge.8_pregen
index cca10b528..1264bb565 100644
--- a/man/vgmerge.8_pregen
+++ b/man/vgmerge.8_pregen
@@ -1,327 +1,225 @@
 .TH VGMERGE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-vgmerge - Merge volume groups
+.
+vgmerge \(em Merge volume groups
 .
 .SH SYNOPSIS
+.
 \fBvgmerge\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 vgmerge merges two existing VGs. The inactive source VG is merged into the
 destination VG if physical extent sizes are equal and PV and LV summaries
 of both VGs fit into the destination VG's limits.
+.
 .SH USAGE
+.
 \fBvgmerge\fP \fIVG\fP \fIVG\fP
 .br
 .RS 4
 .ad l
 [ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-l\fP|\fB--list\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB-l\fP|\fB--list\fP
 .br
-.ad b
 Display merged destination VG like vgdisplay -v.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH EXAMPLES
-
-Merge an inactive VG named "vg00" into the active or inactive VG named
-"databases", giving verbose runtime information.
-.br
-.B vgmerge -v databases vg00
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/vgmknodes.8_pregen b/man/vgmknodes.8_pregen
index 34213ef8e..10f235949 100644
--- a/man/vgmknodes.8_pregen
+++ b/man/vgmknodes.8_pregen
@@ -1,356 +1,255 @@
 .TH VGMKNODES 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-vgmknodes - Create the special files for volume group devices in /dev
+.
+vgmknodes \(em Create the special files for volume group devices in /dev
 .
 .SH SYNOPSIS
+.
 \fBvgmknodes\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 vgmknodes checks the LVM device nodes in /dev that are needed for active
 LVs and creates any that are missing and removes unused ones.
-
+.P
 This command should not usually be needed if all the system components are
 interoperating correctly.
+.
 .SH USAGE
+.
 \fBvgmknodes\fP
 .br
 .RS 4
 .ad l
 [    \fB--ignorelockingfailure\fP ]
-.ad b
 .br
-.ad l
 [    \fB--refresh\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIVG\fP|\fILV\fP|\fITag\fP ... ]
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--ignorelockingfailure\fP
 .br
-.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--refresh\fP
 .br
-.ad b
 If the LV is active, reload its metadata.
 This is not necessary in normal operation, but may be useful
 if something has gone wrong, or if some form of manual LV
 sharing is being used.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fILV\fP
-.br
+.TP
+.I LV
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-.HP
-\fITag\fP
-.br
+.TP
+.I Tag
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/vgreduce.8_pregen b/man/vgreduce.8_pregen
index f0d22121b..1509e4bd0 100644
--- a/man/vgreduce.8_pregen
+++ b/man/vgreduce.8_pregen
@@ -1,8 +1,11 @@
 .TH VGREDUCE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-vgreduce - Remove physical volume(s) from a volume group
+.
+vgreduce \(em Remove physical volume(s) from a volume group
 .
 .SH SYNOPSIS
+.
 \fBvgreduce\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
@@ -10,116 +13,82 @@ vgreduce - Remove physical volume(s) from a volume group
 .P
 .ad l
  \fB-a\fP|\fB--all\fP
-.ad b
 .br
-.ad l
  \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
     \fB--commandprofile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--config\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-d\fP|\fB--debug\fP
-.ad b
 .br
-.ad l
     \fB--devices\fP \fIPV\fP
-.ad b
 .br
-.ad l
     \fB--devicesfile\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--driverloaded\fP \fBy\fP|\fBn\fP
-.ad b
 .br
-.ad l
  \fB-f\fP|\fB--force\fP
-.ad b
 .br
-.ad l
  \fB-h\fP|\fB--help\fP
-.ad b
 .br
-.ad l
     \fB--lockopt\fP \fIString\fP
-.ad b
 .br
-.ad l
     \fB--longhelp\fP
-.ad b
 .br
-.ad l
     \fB--mirrorsonly\fP
-.ad b
 .br
-.ad l
     \fB--nolocking\fP
-.ad b
 .br
-.ad l
     \fB--profile\fP \fIString\fP
-.ad b
 .br
-.ad l
  \fB-q\fP|\fB--quiet\fP
-.ad b
 .br
-.ad l
     \fB--removemissing\fP
-.ad b
 .br
-.ad l
     \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
-.ad b
 .br
-.ad l
  \fB-t\fP|\fB--test\fP
-.ad b
 .br
-.ad l
  \fB-v\fP|\fB--verbose\fP
-.ad b
 .br
-.ad l
     \fB--version\fP
-.ad b
 .br
-.ad l
  \fB-y\fP|\fB--yes\fP
 .ad b
+.
 .SH DESCRIPTION
+.
 vgreduce removes one or more unused PVs from a VG.
+.
 .SH USAGE
+.
 Remove a PV from a VG.
 .br
 .P
 \fBvgreduce\fP \fIVG\fP \fIPV\fP ...
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Remove all unused PVs from a VG.
 .br
 .P
 \fBvgreduce\fP \fB-a\fP|\fB--all\fP \fIVG\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Remove all missing PVs from a VG.
 .br
 .P
@@ -128,215 +97,166 @@ Remove all missing PVs from a VG.
 .RS 4
 .ad l
 [    \fB--mirrorsonly\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
--
-
+.P
+\(em
+.P
 Common options for command:
 .
 .RS 4
 .ad l
 [ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-f\fP|\fB--force\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB-a\fP|\fB--all\fP
 .br
-.ad b
 Removes all empty PVs if none are named on the command line.
+.
 .HP
-.ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-f\fP|\fB--force\fP ...
 .br
-.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--mirrorsonly\fP
 .br
-.ad b
 Only remove missing PVs from mirror LVs.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--removemissing\fP
 .br
-.ad b
 Removes all missing PVs from the VG, if there are no LVs allocated
 on them. This resumes normal operation of the VG (new LVs may again
 be created, changed and so on).
@@ -347,56 +267,51 @@ were partly on the missing disks are removed completely, including
 those parts on disks that are still present.
 If LVs spanned several disks, including ones that are lost, salvaging
 some data first may be possible by activating LVs in partial mode.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fIPV\fP
-.br
+.TP
+.I PV
 Physical Volume name, a device path under /dev.
 For commands managing physical extents, a PV positional arg
 generally accepts a suffix indicating a range (or multiple ranges)
@@ -404,91 +319,36 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/vgremove.8_pregen b/man/vgremove.8_pregen
index 73d6dbd4a..cf5c48ce4 100644
--- a/man/vgremove.8_pregen
+++ b/man/vgremove.8_pregen
@@ -1,233 +1,189 @@
 .TH VGREMOVE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-vgremove - Remove volume group(s)
+.
+vgremove \(em Remove volume group(s)
 .
 .SH SYNOPSIS
+.
 \fBvgremove\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 vgremove removes one or more VGs. If LVs exist in the VG, a prompt is used
 to confirm LV removal.
-
+.P
 If one or more PVs in the VG are lost, consider
 \fBvgreduce --removemissing\fP to make the VG
 metadata consistent again.
-
+.P
 Repeat the force option (\fB-ff\fP) to forcibly remove LVs in the VG
 without confirmation.
+.
 .SH USAGE
+.
 \fBvgremove\fP \fIVG\fP|\fITag\fP|\fISelect\fP ...
 .br
 .RS 4
 .ad l
 [ \fB-f\fP|\fB--force\fP ]
-.ad b
 .br
-.ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--noudevsync\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-f\fP|\fB--force\fP ...
 .br
-.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--noudevsync\fP
 .br
-.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
-.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -236,138 +192,78 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fITag\fP
-.br
+.TP
+.I Tag
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
-\fISelect\fP
-.br
+.TP
+.I Select
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/vgrename.8_pregen b/man/vgrename.8_pregen
index ba5adca31..24ff24744 100644
--- a/man/vgrename.8_pregen
+++ b/man/vgrename.8_pregen
@@ -1,15 +1,20 @@
 .TH VGRENAME 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-vgrename - Rename a volume group
+.
+vgrename \(em Rename a volume group
 .
 .SH SYNOPSIS
+.
 \fBvgrename\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 vgrename renames a VG.
-
+.P
 All VGs visible to a system need to have different names, otherwise many
 LVM commands will refuse to run or give warning messages. VGs with the
 same name can occur when disks are moved between machines, or filters are
@@ -17,353 +22,243 @@ changed. If a newly connected disk has a VG with the same name as the VG
 containing the root filesystem, the machine may not boot correctly. When
 two VGs have the same name, the VG UUID can be used in place of the source
 VG name.
+.
 .SH USAGE
+.
 Rename a VG.
 .br
 .P
 \fBvgrename\fP \fIVG\fP \fIVG\fP\fI_new\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Rename a VG by specifying the VG UUID.
 .br
 .P
 \fBvgrename\fP \fIString\fP \fIVG\fP\fI_new\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Common options for command:
 .
 .RS 4
 .ad l
 [ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-f\fP|\fB--force\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-f\fP|\fB--force\fP ...
 .br
-.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH EXAMPLES
-
-Rename VG "vg02" to "myvg":
-.br
-.B vgrename "vg02" "myvg"
-
-Rename the VG with the specified UUID to "myvg".
-.br
-.B vgrename Zvlifi-Ep3t-e0Ng-U42h-o0ye-KHu1-nl7Ns4 myvg
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/vgs.8_pregen b/man/vgs.8_pregen
index 2cf23764e..ffb4ddc41 100644
--- a/man/vgs.8_pregen
+++ b/man/vgs.8_pregen
@@ -1,327 +1,248 @@
 .TH VGS 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-vgs - Display information about volume groups
+.
+vgs \(em Display information about volume groups
 .
 .SH SYNOPSIS
+.
 \fBvgs\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 vgs produces formatted output about VGs.
+.
 .SH USAGE
+.
 \fBvgs\fP
 .br
 .RS 4
 .ad l
 [ \fB-a\fP|\fB--all\fP ]
-.ad b
 .br
-.ad l
 [ \fB-o\fP|\fB--options\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [ \fB-O\fP|\fB--sort\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--aligned\fP ]
-.ad b
 .br
-.ad l
 [    \fB--binary\fP ]
-.ad b
 .br
-.ad l
 [    \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP ]
-.ad b
 .br
-.ad l
 [    \fB--foreign\fP ]
-.ad b
 .br
-.ad l
 [    \fB--ignorelockingfailure\fP ]
-.ad b
 .br
-.ad l
 [    \fB--logonly\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nameprefixes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--noheadings\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nosuffix\fP ]
-.ad b
 .br
-.ad l
 [    \fB--readonly\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
-.ad l
 [    \fB--rows\fP ]
-.ad b
 .br
-.ad l
 [    \fB--separator\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--shared\fP ]
-.ad b
 .br
-.ad l
 [    \fB--unbuffered\fP ]
-.ad b
 .br
-.ad l
-[    \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP ]
-.ad b
+[    \fB--units\fP \c
+.nh
+\%[\fINumber\fP]\fBr\fP|\:\fBR\fP|\:\fBh\fP|\:\fBH\fP|\:\fBb\fP|\:\fBB\fP|\:\fBs\fP|\:\fBS\fP|\:\fBk\fP|\:\fBK\fP|\:\fBm\fP|\:\fBM\fP|\:\fBg\fP|\:\fBG\fP|\:\fBt\fP|\:\fBT\fP|\:\fBp\fP|\:\fBP\fP|\:\fBe\fP|\:\fBE\fP
+.hy
+]
 .br
-.ad l
 [    \fB--unquoted\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
 .RS 4
 [ \fIVG\fP|\fITag\fP ... ]
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--aligned\fP
 .br
-.ad b
 Use with --separator to align the output columns
+.
 .HP
-.ad l
 \fB-a\fP|\fB--all\fP
 .br
-.ad b
 List all VGs. Equivalent to not specifying any VGs.
+.
 .HP
-.ad l
 \fB--binary\fP
 .br
-.ad b
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
-.ad b
 See \fBlvmreport\fP(7).
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB--foreign\fP
 .br
-.ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--ignorelockingfailure\fP
 .br
-.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--logonly\fP
 .br
-.ad b
 Suppress command report and display only log report.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--nameprefixes\fP
 .br
-.ad b
 Add an "LVM2_" prefix plus the field name to the output. Useful
 with --noheadings to produce a list of field=value pairs that can
 be used to set environment variables (for example, in udev rules).
+.
 .HP
-.ad l
 \fB--noheadings\fP
 .br
-.ad b
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--nosuffix\fP
 .br
-.ad b
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
+.
 .HP
-.ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
 .br
-.ad b
 Comma-separated, ordered list of fields to display in columns.
-String arg syntax is: [+|-|#]Field1[,Field2 ...]
+String arg syntax is: [\fB+\fP|\fB-\fP|\fB#\fP]\fIField1\fP[\fB,\fP\fIField2\fP ...]
 The prefix \fB+\fP will append the specified fields to the default fields,
 \fB-\fP will remove the specified fields from the default fields, and
 \fB#\fP will compact specified fields (removing them when empty for all rows.)
@@ -335,55 +256,49 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBpvseg_all\fP all PV segment fields,
 \fBseg_all\fP all LV segment fields, and
 \fBpvseg_all\fP all PV segment columns.
-See the lvm.conf report section for more config options.
+See the \fBlvm.conf\fP(5) report section for more config options.
 See \fBlvmreport\fP(7) for more information about reporting.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--readonly\fP
 .br
-.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB--rows\fP
 .br
-.ad b
 Output columns as rows.
+.
 .HP
-.ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
-.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -392,193 +307,117 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
+.
 .HP
-.ad l
 \fB--separator\fP \fIString\fP
 .br
-.ad b
 String to use to separate each column. Useful if grepping the output.
+.
 .HP
-.ad l
 \fB--shared\fP
 .br
-.ad b
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
+.
 .HP
-.ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
 .br
-.ad b
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB--unbuffered\fP
 .br
-.ad b
 Produce output immediately without sorting or aligning the columns properly.
+.
 .HP
 .ad l
-\fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
-.br
+\fB--units\fP \c
+.nh
+\%[\fINumber\fP]\fBr\fP|\:\fBR\fP|\:\fBh\fP|\:\fBH\fP|\:\fBb\fP|\:\fBB\fP|\:\fBs\fP|\:\fBS\fP|\:\fBk\fP|\:\fBK\fP|\:\fBm\fP|\:\fBM\fP|\:\fBg\fP|\:\fBG\fP|\:\fBt\fP|\:\fBT\fP|\:\fBp\fP|\:\fBP\fP|\:\fBe\fP|\:\fBE\fP
+.hy
 .ad b
+.br
 All sizes are output in these units:
 human-(r)eadable with '<' rounding indicator,
 (h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
+.
 .HP
-.ad l
 \fB--unquoted\fP
 .br
-.ad b
 When used with --nameprefixes, output values in the field=value
 pairs are not quoted.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fITag\fP
-.br
+.TP
+.I Tag
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH NOTES
-.
-The vg_attr bits are:
-.IP 1 3
-Permissions: (w)riteable, (r)ead-only
-.IP 2 3
-Resi(z)eable
-.IP 3 3
-E(x)ported
-.IP 4 3
-(p)artial: one or more physical volumes belonging to the volume group
-are missing from the system
-.IP 5 3
-Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, @nywhere
-.IP 6 3
-(c)lustered, (s)hared
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/vgscan.8_pregen b/man/vgscan.8_pregen
index 40145b078..959e16190 100644
--- a/man/vgscan.8_pregen
+++ b/man/vgscan.8_pregen
@@ -1,343 +1,242 @@
 .TH VGSCAN 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-vgscan - Search for all volume groups
+.
+vgscan \(em Search for all volume groups
 .
 .SH SYNOPSIS
+.
 \fBvgscan\fP
 .br
     [ \fIoption_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 vgscan scans all supported LVM block devices in the system for VGs.
+.
 .SH USAGE
+.
 \fBvgscan\fP
 .br
 .RS 4
 .ad l
 [    \fB--ignorelockingfailure\fP ]
-.ad b
 .br
-.ad l
 [    \fB--mknodes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--notifydbus\fP ]
-.ad b
 .br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.ad b
 .br
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--ignorelockingfailure\fP
 .br
-.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB--mknodes\fP
 .br
-.ad b
 Also checks the LVM special files in /dev that are needed for active
 LVs and creates any missing ones and removes unused ones.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--notifydbus\fP
 .br
-.ad b
 Send a notification to D-Bus. The command will exit with an error
 if LVM is not built with support for D-Bus notification, or if the
 notify_dbus config setting is disabled.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
-.ad b
 Overrides current output format for reports which is defined globally by
-the report/output_format setting in lvm.conf.
+the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIString\fP
-.br
+.
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)
diff --git a/man/vgsplit.8_pregen b/man/vgsplit.8_pregen
index c4721b9ba..331c6e491 100644
--- a/man/vgsplit.8_pregen
+++ b/man/vgsplit.8_pregen
@@ -1,156 +1,128 @@
 .TH VGSPLIT 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
-vgsplit - Move physical volumes into a new or existing volume group
+.
+vgsplit \(em Move physical volumes into a new or existing volume group
 .
 .SH SYNOPSIS
+.
 \fBvgsplit\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
+.
 .SH DESCRIPTION
+.
 vgsplit moves one or more PVs from a source VG (the first VG arg) to a
 destination VG (the second VG arg).  The PV(s) to move are named after the
 source and destination VGs, or an LV is named, in which case the PVs
 underlying the LV are moved.
-
+.P
 If the destination VG does not exist, a new VG is created (command options
 can be used to specify properties of the new VG, also see
-\fBvgcreate\fP(8).)
-
+\fBvgcreate\fP(8)).
+.P
 LVs cannot be split between VGs; each LV must be entirely on the PVs in
 the source or destination VG.
-
+.P
 vgsplit can only move complete PVs. (See \fBpvmove\fP(8) for moving part
 of a PV.)
+.
 .SH USAGE
+.
 Split a VG by specified PVs.
 .br
 .P
 \fBvgsplit\fP \fIVG\fP \fIVG\fP \fIPV\fP ...
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Split a VG by PVs in a specified LV.
 .br
 .P
 \fBvgsplit\fP \fB-n\fP|\fB--name\fP \fILV\fP \fIVG\fP \fIVG\fP
 .br
 .RS 4
+.ad l
 [ COMMON_OPTIONS ]
+.ad b
 .RE
-.br
-
+.P
 Common options for command:
 .
 .RS 4
 .ad l
 [ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [ \fB-l\fP|\fB--maxlogicalvolumes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP ]
-.ad b
 .br
-.ad l
 [ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP ]
-.ad b
 .br
-.ad l
-[    \fB--alloc\fP 
+[    \fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
 ]
-.ad b
 .br
-.ad l
-[    \fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP ]
+[    \fB--\fP[\fBvg\fP]\fBmetadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP ]
 .ad b
 .RE
-
+.P
 Common options for lvm:
 .
 .RS 4
 .ad l
 [ \fB-d\fP|\fB--debug\fP ]
-.ad b
 .br
-.ad l
 [ \fB-h\fP|\fB--help\fP ]
-.ad b
 .br
-.ad l
 [ \fB-q\fP|\fB--quiet\fP ]
-.ad b
 .br
-.ad l
 [ \fB-t\fP|\fB--test\fP ]
-.ad b
 .br
-.ad l
 [ \fB-v\fP|\fB--verbose\fP ]
-.ad b
 .br
-.ad l
 [ \fB-y\fP|\fB--yes\fP ]
-.ad b
 .br
-.ad l
 [    \fB--commandprofile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--config\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devices\fP \fIPV\fP ]
-.ad b
 .br
-.ad l
 [    \fB--devicesfile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
 .br
-.ad l
 [    \fB--lockopt\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--longhelp\fP ]
-.ad b
 .br
-.ad l
 [    \fB--nolocking\fP ]
-.ad b
 .br
-.ad l
 [    \fB--profile\fP \fIString\fP ]
-.ad b
 .br
-.ad l
 [    \fB--version\fP ]
 .ad b
 .RE
+.
 .SH OPTIONS
+.
+.
 .HP
 .ad l
-\fB--alloc\fP 
+\fB--alloc\fP \c
 .nh
-\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+\%\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
 .hy
-.br
 .ad b
+.br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
 which can be changed with vgchange/lvchange, or overridden on the
@@ -167,157 +139,136 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
+.
 .HP
-.ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
-.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
+.
 .HP
-.ad l
 \fB--config\fP \fIString\fP
 .br
-.ad b
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
+Config settings for the command. These override \fBlvm.conf\fP(5) settings.
+The String arg uses the same format as \fBlvm.conf\fP(5),
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
+.
 .HP
-.ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
-.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
+.
 .HP
-.ad l
 \fB--devices\fP \fIPV\fP
 .br
-.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
+.
 .HP
-.ad l
 \fB--devicesfile\fP \fIString\fP
 .br
-.ad b
 A file listing devices that LVM should use.
-The file must exist in /etc/lvm/devices/ and is managed
-with the lvmdevices(8) command.
-This overrides the lvm.conf devices/devicesfile and
-devices/use_devicesfile settings.
+The file must exist in \fI#DEFAULT_SYS_DIR#/devices/\fP and is managed
+with the \fBlvmdevices\fP(8) command.
+This overrides the \fBlvm.conf\fP(5) \fBdevices/devicesfile\fP and
+\fBdevices/use_devicesfile\fP settings.
+.
 .HP
-.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
-.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
+.
 .HP
-.ad l
 \fB-h\fP|\fB--help\fP
 .br
-.ad b
 Display help text.
+.
 .HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
-.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
+.
 .HP
-.ad l
 \fB--longhelp\fP
 .br
-.ad b
 Display long help text.
+.
 .HP
-.ad l
 \fB-l\fP|\fB--maxlogicalvolumes\fP \fINumber\fP
 .br
-.ad b
 Sets the maximum number of LVs allowed in a VG.
+.
 .HP
-.ad l
 \fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP
 .br
-.ad b
 Sets the maximum number of PVs that can belong to the VG.
 The value 0 removes any limitation.
 For large numbers of PVs, also see options --pvmetadatacopies,
 and --vgmetadatacopies for improving performance.
+.
 .HP
-.ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
-.ad b
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
 \fBlvm1\fP (or just \fB1\fP) is no longer used.
+.
 .HP
-.ad l
 \fB-n\fP|\fB--name\fP \fIString\fP
 .br
-.ad b
 Move only PVs used by the named LV.
+.
 .HP
-.ad l
 \fB--nolocking\fP
 .br
-.ad b
 Disable locking.
+.
 .HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
-.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
+.
 .HP
-.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
-.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
+.
 .HP
-.ad l
 \fB-t\fP|\fB--test\fP
 .br
-.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
+.
 .HP
-.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
-.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
+.
 .HP
-.ad l
 \fB--version\fP
 .br
-.ad b
 Display version information.
+.
 .HP
-.ad l
-\fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
+\fB--\fP[\fBvg\fP]\fBmetadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
 .br
-.ad b
 Number of copies of the VG metadata that are kept.
 VG metadata is kept in VG metadata areas on PVs in the VG,
 i.e. reserved space@the start and/or end of the PVs.
@@ -331,22 +282,21 @@ The number can also be replaced with special string values:
 metadataignore flags.
 \fBall\fP causes LVM to first clear the metadataignore flags on
 all PVs, and then to become unmanaged.
+.
 .HP
-.ad l
 \fB-y\fP|\fB--yes\fP
 .br
-.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
+.
 .SH VARIABLES
-.HP
-\fIVG\fP
-.br
+.
+.TP
+.I VG
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
-\fIPV\fP
-.br
+.TP
+.I PV
 Physical Volume name, a device path under /dev.
 For commands managing physical extents, a PV positional arg
 generally accepts a suffix indicating a range (or multiple ranges)
@@ -354,91 +304,36 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
-\fIString\fP
-.br
+.TP
+.I String
 See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
+.TP
+.IR Size [UNIT]
 Size is an input number that accepts an optional unit.
 Input units are always treated as base two values, regardless of
 capitalization, e.g. 'k' and 'K' both refer to 1024.
 The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,
-m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.
+UNIT represents other possible input units:
+.BR b | B
+is bytes,
+.BR s | S
+is sectors of 512 bytes,
+.BR k | K
+is KiB,
+.BR m | M
+is MiB,
+.BR g | G
+is GiB,
+.BR t | T
+is TiB,
+.BR p | P
+is PiB,
+.BR e | E
+is EiB.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
+.
 .SH ENVIRONMENT VARIABLES
+.
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmconfig (8),
-.BR lvmdevices (8),
-
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvresize (8),
-.BR pvs (8),
-.BR pvscan (8),
-
-.BR vgcfgbackup (8),
-.BR vgcfgrestore (8),
-.BR vgchange (8),
-.BR vgck (8),
-.BR vgcreate (8),
-.BR vgconvert (8),
-.BR vgdisplay (8),
-.BR vgexport (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgimportdevices (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
-
-.BR lvcreate (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-
-.BR lvm-fullreport (8),
-.BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
-.BR blkdeactivate (8),
-.BR lvmdump (8),
-
-.BR dmeventd (8),
-.BR lvmpolld (8),
-.BR lvmlockd (8),
-.BR lvmlockctl (8),
-.BR cmirrord (8),
-.BR lvmdbusd (8),
-
-.BR lvmsystemid (7),
-.BR lvmreport (7),
-.BR lvmraid (7),
-.BR lvmthin (7),
-.BR lvmcache (7)


