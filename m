From: Joe Thornber <thornber@sourceware.org>
Date: Mon, 30 Apr 2018 04:56:48 -0400
Subject: master - [scripts] remove scripts/vg_convert
Message-ID: <201804300856.w3U8umjM018976@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0a2b5d5748970e80c4e288fecb1f36a5935fd412
Commit:        0a2b5d5748970e80c4e288fecb1f36a5935fd412
Parent:        65d6118e4773940529063b4e6515673f88b54edb
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Feb 12 16:14:32 2018 +0000
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Apr 30 09:46:05 2018 +0100

[scripts] remove scripts/vg_convert

- it doesn't do anything other than tell you to run vgconvert
- it used to convert from lvm1 format, which is obsolete
---
 scripts/vg_convert |   18 ------------------
 1 files changed, 0 insertions(+), 18 deletions(-)

diff --git a/scripts/vg_convert b/scripts/vg_convert
deleted file mode 100755
index 6559941..0000000
--- a/scripts/vg_convert
+++ /dev/null
@@ -1,18 +0,0 @@
-#!/bin/sh -x
-
-# Original script used to convert a VG from LVM1 to LVM2 metadata format.
-# Superceded by 'vgconvert', but left here to show how to do it step-by-step.
-
-# Takes vgname as parameter.  No error checking.  Uses temp file 'lvmbackup'.
-
-echo "Please use the 'vgconvert' tool instead"
-exit 1
-
-./vgcfgbackup $1 || exit 1
-./vgcfgbackup --file lvmbackup $1 || exit 1
-
-CMDS=`./pvscan -u | sed -ne "s/.*PV \(.*\) with UUID \(.*\) VG $1 .*/.\/pvcreate -ff -y -M lvm2 --restorefile lvmbackup -u \2 \1 ; /p"`
-
-sh -x -c "$CMDS" || exit 1
-
-./vgcfgrestore --file lvmbackup -M lvm2 $1 || exit 1


