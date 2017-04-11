From: David Teigland <teigland@sourceware.org>
Date: Tue, 11 Apr 2017 15:17:38 -0400
Subject: master - man lvmraid: fix line wrapping in examples
Message-ID: <201704111917.v3BJHcPd028137@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1dfb4a2dae05679d0e5f1de1f2f7ded53606b7ec
Commit:        1dfb4a2dae05679d0e5f1de1f2f7ded53606b7ec
Parent:        c448dcb3491cbb54e9382b2b40a719ad87974079
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 11 14:17:08 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 11 14:17:08 2017 -0500

man lvmraid: fix line wrapping in examples

---
 man/lvmraid.7_main |   34 +++++++++++++++++-----------------
 1 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/man/lvmraid.7_main b/man/lvmraid.7_main
index 4d117c4..995115d 100644
--- a/man/lvmraid.7_main
+++ b/man/lvmraid.7_main
@@ -1127,9 +1127,9 @@ Convert it from 3-way striped to 5-way-striped.
 .nf
 # lvconvert --stripes 5 vg/lv
   Using default stripesize 64.00 KiB.
-  WARNING: Adding stripes to active logical volume vg/lv will \
+  WARNING: Adding stripes to active logical volume vg/lv will \\
   grow it from 99 to 165 extents!
-  Run "lvresize -l99 vg/lv" to shrink it or use the additional \
+  Run "lvresize -l99 vg/lv" to shrink it or use the additional \\
   capacity.
   Logical volume vg/lv successfully converted.
 
@@ -1141,10 +1141,10 @@ Convert it from 3-way striped to 5-way-striped.
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
   LV            Attr       Type     PE Ranges                                                                                   DOff
-  lv            rwi-a-r--- raid6_nr lv_rimage_0:0-33 \
-                                    lv_rimage_1:0-33 \
-                                    lv_rimage_2:0-33 ... \
-                                    lv_rimage_5:0-33 \
+  lv            rwi-a-r--- raid6_nr lv_rimage_0:0-33 \\
+                                    lv_rimage_1:0-33 \\
+                                    lv_rimage_2:0-33 ... \\
+                                    lv_rimage_5:0-33 \\
                                     lv_rimage_6:0-33    0
   [lv_rimage_0] iwi-aor--- linear   /dev/sda:0-32                                                                               0
   [lv_rimage_0] iwi-aor--- linear   /dev/sda:34-34
@@ -1173,22 +1173,22 @@ The force option needs to be used, because removing stripes
 .nf
 # lvconvert --stripes 4 vg/lv
   Using default stripesize 64.00 KiB.
-  WARNING: Removing stripes from active logical volume vg/lv will \
+  WARNING: Removing stripes from active logical volume vg/lv will \\
   shrink it from 660.00 MiB to 528.00 MiB!
   THIS MAY DESTROY (PARTS OF) YOUR DATA!
-  If that leaves the logical volume larger than 206 extents due \
+  If that leaves the logical volume larger than 206 extents due \\
   to stripe rounding,
   you may want to grow the content afterwards (filesystem etc.)
-  WARNING: too remove freed stripes after the conversion has finished,\
+  WARNING: to remove freed stripes after the conversion has finished,\\
   you have to run "lvconvert --stripes 4 vg/lv"
   Logical volume vg/lv successfully converted.
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
   LV            Attr       Type     PE Ranges           DOff
-  lv            rwi-a-r-s- raid6_nr lv_rimage_0:0-33 \
-                                    lv_rimage_1:0-33 \
-                                    lv_rimage_2:0-33 ... \
-                                    lv_rimage_5:0-33
+  lv            rwi-a-r-s- raid6_nr lv_rimage_0:0-33 \\
+                                    lv_rimage_1:0-33 \\
+                                    lv_rimage_2:0-33 ... \\
+                                    lv_rimage_5:0-33 \\
                                     lv_rimage_6:0-33    0
   [lv_rimage_0] Iwi-aor--- linear   /dev/sda:0-32       0
   [lv_rimage_0] Iwi-aor--- linear   /dev/sda:34-34
@@ -1215,10 +1215,10 @@ The 'R' in the same column of the attribute field shows the freed image Sub LVs
 .nf
 # lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
   LV   Attr       Type     PE Ranges               DOff
-  lv   rwi-a-r-R- raid6_nr lv_rimage_0:0-33 \
-                           lv_rimage_1:0-33 \
-                           lv_rimage_2:0-33 ... \
-                           lv_rimage_5:0-33
+  lv   rwi-a-r-R- raid6_nr lv_rimage_0:0-33 \\
+                           lv_rimage_1:0-33 \\
+                           lv_rimage_2:0-33 ... \\
+                           lv_rimage_5:0-33 \\
                            lv_rimage_6:0-33        8192
 .fi
 


