From: David Teigland <teigland@sourceware.org>
Date: Tue, 11 Apr 2017 11:55:42 -0400
Subject: master - man lvmraid: improve text layout
Message-ID: <201704111555.v3BFtgaA001877@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e0c169f8b7f214100ad11c68b1cab799e8adaaed
Commit:        e0c169f8b7f214100ad11c68b1cab799e8adaaed
Parent:        2fd9ae070351dd2682d42aad3df5c9acec195bc0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 11 10:55:02 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 11 10:55:02 2017 -0500

man lvmraid: improve text layout

---
 man/lvmraid.7_main |   64 +++++++++++++++++++++++++++++++++------------------
 1 files changed, 41 insertions(+), 23 deletions(-)

diff --git a/man/lvmraid.7_main b/man/lvmraid.7_main
index d000687..99218a5 100644
--- a/man/lvmraid.7_main
+++ b/man/lvmraid.7_main
@@ -520,6 +520,7 @@ lvs -a -o name,segtype,devices
   [lvr6_rmeta_3]  linear /dev/sdd(...)
   [lvr6_rmeta_4]  linear /dev/sde(...)
   [lvr6_rmeta_5]  linear /dev/sdf(...)
+.fi
 
 .B raid10
 .br
@@ -905,6 +906,8 @@ between raid4 and raid5.
 between raid4/raid5 and raid6.
 .IP \(bu 3
 between striped/raid0 and raid10.
+.IP \(bu 3
+between striped and raid4.
 
 .SS Examples
 
@@ -935,8 +938,6 @@ between striped/raid0 and raid10.
   [lv_mimage_0] linear 100.00g
   [lv_mimage_1] linear 100.00g
   [lv_mlog]     linear   3.00m
-.IP \(bu 3
-between striped and raid4.
 
 .SS Examples
 
@@ -1123,21 +1124,27 @@ For performance reasons the raid6_nr RaidLV can be restriped.
 Convert it from 3-way striped to 5-way-striped.
 
 .nf
-# lvconvert --stripes 5 -y vg/lv
+# lvconvert --stripes 5 vg/lv
   Using default stripesize 64.00 KiB.
-  WARNING: Adding stripes to active logical volume vg/lv will grow it from 99 to 165 extents!
-  Run "lvresize -l99 vg/lv" to shrink it or use the additional capacity.
+  WARNING: Adding stripes to active logical volume vg/lv will \
+  grow it from 99 to 165 extents!
+  Run "lvresize -l99 vg/lv" to shrink it or use the additional \
+  capacity.
   Logical volume vg/lv successfully converted.
 
 # lvs
-  LV   VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
+  LV   VG     Attr       LSize   Cpy%Sync
   root fedora -wi-ao----  15.00g
   swap fedora -wi-ao----   3.99g
-  lv   vg     rwi-a-r-s- 652.00m                                    52.94
+  lv   vg     rwi-a-r-s- 652.00m 52.94
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
   LV            Attr       Type     PE Ranges                                                                                   DOff
-  lv            rwi-a-r--- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33    0
+  lv            rwi-a-r--- raid6_nr lv_rimage_0:0-33 \
+                                    lv_rimage_1:0-33 \
+                                    lv_rimage_2:0-33 ... \
+                                    lv_rimage_5:0-33 \
+                                    lv_rimage_6:0-33    0
   [lv_rimage_0] iwi-aor--- linear   /dev/sda:0-32                                                                               0
   [lv_rimage_0] iwi-aor--- linear   /dev/sda:34-34
   [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:0-32                                                                              0
@@ -1163,28 +1170,35 @@ The force option needs to be used, because removing stripes
 (i.e. image SubLVs) from a RaidLV will shrink its size.
 
 .nf
-# lvconvert --stripes 4 --force -y vg/lv
+# lvconvert --stripes 4 vg/lv
   Using default stripesize 64.00 KiB.
-  WARNING: Removing stripes from active logical volume vg/lv will shrink it from 660.00 MiB to 528.00 MiB!
+  WARNING: Removing stripes from active logical volume vg/lv will \
+  shrink it from 660.00 MiB to 528.00 MiB!
   THIS MAY DESTROY (PARTS OF) YOUR DATA!
-  If that leaves the logical volume larger than 206 extents due to stripe rounding,
+  If that leaves the logical volume larger than 206 extents due \
+  to stripe rounding,
   you may want to grow the content afterwards (filesystem etc.)
-  WARNING: too remove freed stripes after the conversion has finished, you have to run "lvconvert --stripes 4 vg/lv"
+  WARNING: too remove freed stripes after the conversion has finished,\
+  you have to run "lvconvert --stripes 4 vg/lv"
   Logical volume vg/lv successfully converted.
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
-  LV            Attr       Type     PE Ranges                                                                                   DOff
-  lv            rwi-a-r-s- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33    0
-  [lv_rimage_0] Iwi-aor--- linear   /dev/sda:0-32                                                                               0
+  LV            Attr       Type     PE Ranges           DOff
+  lv            rwi-a-r-s- raid6_nr lv_rimage_0:0-33 \
+                                    lv_rimage_1:0-33 \
+                                    lv_rimage_2:0-33 ... \
+                                    lv_rimage_5:0-33
+                                    lv_rimage_6:0-33    0
+  [lv_rimage_0] Iwi-aor--- linear   /dev/sda:0-32       0
   [lv_rimage_0] Iwi-aor--- linear   /dev/sda:34-34
-  [lv_rimage_1] Iwi-aor--- linear   /dev/sdaa:0-32                                                                              0
+  [lv_rimage_1] Iwi-aor--- linear   /dev/sdaa:0-32      0
   [lv_rimage_1] Iwi-aor--- linear   /dev/sdaa:34-34
-  [lv_rimage_2] Iwi-aor--- linear   /dev/sdab:0-32                                                                              0
+  [lv_rimage_2] Iwi-aor--- linear   /dev/sdab:0-32      0
   [lv_rimage_2] Iwi-aor--- linear   /dev/sdab:34-34
-  [lv_rimage_3] Iwi-aor--- linear   /dev/sdac:1-34                                                                              0
-  [lv_rimage_4] Iwi-aor--- linear   /dev/sdad:1-34                                                                              0
-  [lv_rimage_5] Iwi-aor--- linear   /dev/sdae:1-34                                                                              0
-  [lv_rimage_6] Iwi-aor-R- linear   /dev/sdaf:1-34                                                                              0
+  [lv_rimage_3] Iwi-aor--- linear   /dev/sdac:1-34      0
+  [lv_rimage_4] Iwi-aor--- linear   /dev/sdad:1-34      0
+  [lv_rimage_5] Iwi-aor--- linear   /dev/sdae:1-34      0
+  [lv_rimage_6] Iwi-aor-R- linear   /dev/sdaf:1-34      0
   [lv_rmeta_0]  ewi-aor--- linear   /dev/sda:33-33
   [lv_rmeta_1]  ewi-aor--- linear   /dev/sdaa:33-33
   [lv_rmeta_2]  ewi-aor--- linear   /dev/sdab:33-33
@@ -1199,8 +1213,12 @@ The 'R' in the same column of the attribute field shows the freed image Sub LVs
 
 .nf
 # lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
-  LV   Attr       Type     PE Ranges                                                                                DOff
-  lv   rwi-a-r-R- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33 8192
+  LV   Attr       Type     PE Ranges               DOff
+  lv   rwi-a-r-R- raid6_nr lv_rimage_0:0-33 \
+                           lv_rimage_1:0-33 \
+                           lv_rimage_2:0-33 ... \
+                           lv_rimage_5:0-33
+                           lv_rimage_6:0-33        8192
 .fi
 
 Now that the reshape is finished the 'R' atribute on the RaidLV shows images can be removed.


