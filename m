From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 29 Mar 2017 18:45:06 -0400
Subject: master - man: raid cleanup
Message-ID: <201703292245.v2TMj6Rw016542@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=803b1775ba06218ad193402a13e6da4b3406511a
Commit:        803b1775ba06218ad193402a13e6da4b3406511a
Parent:        b6724fa423803f175c66b5b8406a06262013be71
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 30 00:44:04 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 30 00:44:35 2017 +0200

man: raid cleanup

---
 man/lvmraid.7_main |  129 +++++++++++++++++++++++++++++----------------------
 1 files changed, 73 insertions(+), 56 deletions(-)

diff --git a/man/lvmraid.7_main b/man/lvmraid.7_main
index 398a25d..7a3235b 100644
--- a/man/lvmraid.7_main
+++ b/man/lvmraid.7_main
@@ -23,7 +23,7 @@ devices, and MD is used to place data on physical devices.
 LVM creates hidden LVs (dm devices) layered between the visible LV and
 physical devices.  LVs in the middle layers are called sub LVs.
 For LVM raid, a sub LV pair to store data and metadata (raid superblock
-and bitmap) is created per raid image/leg (see lvs command examples below).
+and write intent bitmap) is created per raid image/leg (see lvs command examples below).
 
 .SH Create a RAID LV
 
@@ -142,7 +142,8 @@ raid5 is a form of striping that uses an extra device for storing parity
 blocks.  LV data and parity blocks are stored on each device, typically in
 a rotating pattern for performance reasons.  The LV data remains available
 if one device fails.  The parity is used to recalculate data that is lost
-from a single device.  The minimum number of devices required is 3.
+from a single device.  The minimum number of devices required is 3 (unless
+converting from 2 legged raid1 to reshape to more stripes; see reshaping).
 
 .B lvcreate --type raid5
 [\fB--stripes\fP \fINumber\fP \fB--stripesize\fP \fISize\fP]
@@ -272,11 +273,13 @@ Correct blocks are read, parity is calculated, and recalculated blocks are
 written.
 
 The RAID implementation keeps track of which parts of a RAID LV are
-synchronized.  This uses a bitmap saved in the RAID metadata.  The bitmap
-can exclude large parts of the LV from synchronization to reduce the
-amount of work after a crash.  Without this, the entire LV would need
-to be synchronized every time it was activated.  When a RAID LV is
-first created and activated the first synchronization is called initialization.
+synchronized.  When a RAID LV is first created and activated the first
+synchronization is called initialization.  A pointer stored in the raid
+metadata keeps track of the initialization process thus allowing it to be
+restarted after a deactivation of the RaidLV or a crash.  Any writes to
+the RaidLV dirties the respective region of the write intent bitmap which
+allow for fast recovery of the regions after a crash.  Without this, the
+entire LV would need to be synchronized every time it was activated.
 
 Automatic synchronization happens when a RAID LV is activated, but it is
 usually partial because the bitmaps reduce the areas that are checked.
@@ -450,7 +453,7 @@ lvs -a -o name,segtype,devices
 
 .B raid4
 .br
-Two rimage SubLVs each hold a portion of LV data and one rimage SubLV
+At least three rimage SubLVs each hold a portion of LV data and one rimage SubLV
 holds parity.  Each rmeta SubLV holds RAID metadata.
 
 .nf
@@ -470,7 +473,8 @@ lvs -a -o name,segtype,devices
 
 .B raid5
 .br
-Three rimage SubLVs each hold a portion of LV data and parity.
+At least three rimage SubLVs each typcially hold a portion of LV data and parity
+(see section on raid5)
 Each rmeta SubLV holds RAID metadata.
 
 .nf
@@ -490,7 +494,8 @@ lvs -a -o name,segtype,devices
 
 .B raid6
 .br
-Six rimage SubLVs each hold a portion of LV data and parity.
+At least five rimage SubLVs each typically hold a portion of LV data and parity.
+(see section on raid6)
 Each rmeta SubLV holds RAID metadata.
 
 .nf
@@ -518,7 +523,7 @@ lvs -a -o name,segtype,devices
 
 .B raid10
 .br
-Four rimage SubLVs each hold a portion of LV data.  No parity is used.
+At least four rimage SubLVs each hold a portion of LV data.  No parity is used.
 Each rmeta SubLV holds RAID metadata.
 
 .nf
@@ -563,9 +568,9 @@ RAID4 and RAID5 LVs can tolerate losing one device without LV data loss.
 RAID6 LVs can tolerate losing two devices without LV data loss.
 
 .IP \[bu] 3
-RAID10 is variable, and depends on which devices are lost.  It can
-tolerate losing all but one device in a raid1 set, where each stripe
-is composed of a raid1 set, without LV data loss.
+RAID10 is variable, and depends on which devices are lost.  It stripes
+across multiple mirror groups with raid1 layout thus it can tolerate
+losing all but one device in each of these groups without LV data loss.
 
 .P
 
@@ -862,10 +867,13 @@ needed.
 
 Conversion often requires full synchronization of the RAID LV (see
 \fBSynchronization\fP).  Converting to RAID1 requires copying all LV data
-blocks to a new image on a new device.  Converting to a parity RAID level
+blocks to N new images on new devices.  Converting to a parity RAID level
 requires reading all LV data blocks, calculating parity, and writing the
-new parity blocks.  Synchronization can take a long time and degrade
-performance (rate controls also apply to conversion, see
+new parity blocks.  Synchronization can take a long time depending on the
+throughpout of the devices used and the size of the RaidLV.  It can degrade
+performance (rate controls also apply to conversion; see
+\fB--minrecoveryrate\fP
+and
 \fB--maxrecoveryrate\fP.)
 
 Warning: though it is possible to create \fBstriped\fP LVs  with up to 128 stripes,
@@ -984,7 +992,7 @@ Convert the linear LV to raid1 with three images
 # lvconvert --type raid1 --mirrors 2 vg/lv
 .fi
 
-4. Converting an LV from \fBstriped\fP (with 4 stripes) to \fBraid6_nc\fP.
+4. Converting an LV from \fBstriped\fP (with 4 stripes) to \fBraid6_n_6\fP.
 
 .nf
 Start with a striped LV:
@@ -1115,19 +1123,19 @@ For performance reasons the raid6_nr RaidLV can be restriped.
 Convert it from 3-way striped to 5-way-striped.
 
 .nf
-# lvconvert --stripes 5 -y tb/lv
+# lvconvert --stripes 5 -y vg/lv
   Using default stripesize 64.00 KiB.
-  WARNING: Adding stripes to active logical volume tb/lv will grow it from 99 to 165 extents!
-  Run "lvresize -l99 tb/lv" to shrink it or use the additional capacity.
-  Logical volume tb/lv successfully converted.
+  WARNING: Adding stripes to active logical volume vg/lv will grow it from 99 to 165 extents!
+  Run "lvresize -l99 vg/lv" to shrink it or use the additional capacity.
+  Logical volume vg/lv successfully converted.
 
 # lvs
   LV   VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
   root fedora -wi-ao----  15.00g
   swap fedora -wi-ao----   3.99g
-  lv   tb     rwi-a-r-s- 652.00m                                    52.94
+  lv   vg     rwi-a-r-s- 652.00m                                    52.94
 
-# lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
+# lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
   LV            Attr       Type     PE Ranges                                                                                   DOff
   lv            rwi-a-r--- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33    0
   [lv_rimage_0] iwi-aor--- linear   /dev/sda:0-32                                                                               0
@@ -1155,16 +1163,16 @@ The force option needs to be used, because removing stripes
 (i.e. image SubLVs) from a RaidLV will shrink its size.
 
 .nf
-# lvconvert --stripes 4 --force -y tb/lv
+# lvconvert --stripes 4 --force -y vg/lv
   Using default stripesize 64.00 KiB.
-  WARNING: Removing stripes from active logical volume tb/lv will shrink it from 660.00 MiB to 528.00 MiB!
+  WARNING: Removing stripes from active logical volume vg/lv will shrink it from 660.00 MiB to 528.00 MiB!
   THIS MAY DESTROY (PARTS OF) YOUR DATA!
   If that leaves the logical volume larger than 206 extents due to stripe rounding,
   you may want to grow the content afterwards (filesystem etc.)
-  WARNING: too remove freed stripes after the conversion has finished, you have to run "lvconvert --stripes 4 tb/lv"
-  Logical volume tb/lv successfully converted.
+  WARNING: too remove freed stripes after the conversion has finished, you have to run "lvconvert --stripes 4 vg/lv"
+  Logical volume vg/lv successfully converted.
 
-# lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
+# lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
   LV            Attr       Type     PE Ranges                                                                                   DOff
   lv            rwi-a-r-s- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33    0
   [lv_rimage_0] Iwi-aor--- linear   /dev/sda:0-32                                                                               0
@@ -1190,7 +1198,7 @@ The 's' in column 9 of the attribute field shows the RaidLV is still reshaping.
 The 'R' in the same column of the attribute field shows the freed image Sub LVs which will need removing once the reshaping finished.
 
 .nf
-# lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
+# lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
   LV   Attr       Type     PE Ranges                                                                                DOff
   lv   rwi-a-r-R- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33 8192
 .fi
@@ -1198,19 +1206,19 @@ The 'R' in the same column of the attribute field shows the freed image Sub LVs
 Now that the reshape is finished the 'R' atribute on the RaidLV shows images can be removed.
 
 .nf
-# lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
+# lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
   LV   Attr       Type     PE Ranges                                                                                 DOff
   lv   rwi-a-r-R- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ...  lv_rimage_5:0-33 lv_rimage_6:0-33 8192
 .fi
 
-This is achieved by repeating the command ("lvconvert --stripes 4 tb/lv" would be sufficient).
+This is achieved by repeating the command ("lvconvert --stripes 4 vg/lv" would be sufficient).
 
 .nf
-# lvconvert --stripes 4 --force -y tb/lv
+# lvconvert --stripes 4 --force -y vg/lv
   Using default stripesize 64.00 KiB.
-  Logical volume tb/lv successfully converted.
+  Logical volume vg/lv successfully converted.
 
-# lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
+# lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
   LV            Attr       Type     PE Ranges                                                               DOff
   lv            rwi-a-r--- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 8192
   [lv_rimage_0] iwi-aor--- linear   /dev/sda:0-32                                                           8192
@@ -1229,7 +1237,7 @@ This is achieved by repeating the command ("lvconvert --stripes 4 tb/lv" would b
   [lv_rmeta_4]  ewi-aor--- linear   /dev/sdad:0-0
   [lv_rmeta_5]  ewi-aor--- linear   /dev/sdae:0-0
 
-# lvs -a -o lv_name,attr,segtype,reshapelen tb
+# lvs -a -o lv_name,attr,segtype,reshapelen vg
   LV            Attr       Type     RSize
   lv            rwi-a-r--- raid6_nr 24.00m
   [lv_rimage_0] iwi-aor--- linear    4.00m
@@ -1249,15 +1257,17 @@ This is achieved by repeating the command ("lvconvert --stripes 4 tb/lv" would b
   [lv_rmeta_5]  ewi-aor--- linear
 .fi
 
+Future developments might include automatic removal of the freed images.
+
 If the reshape space shall be removed any lvconvert command not changing the layout can be used:
 
 .nf
-# lvconvert --stripes 4 tb/lv
+# lvconvert --stripes 4 vg/lv
   Using default stripesize 64.00 KiB.
-  No change in RAID LV tb/lv layout, freeing reshape space.
-  Logical volume tb/lv successfully converted.
+  No change in RAID LV vg/lv layout, freeing reshape space.
+  Logical volume vg/lv successfully converted.
 
-# lvs -a -o lv_name,attr,segtype,reshapelen tb
+# lvs -a -o lv_name,attr,segtype,reshapelen vg
   LV            Attr       Type     RSize
   lv            rwi-a-r--- raid6_nr    0
   [lv_rimage_0] iwi-aor--- linear      0
@@ -1280,9 +1290,9 @@ If the reshape space shall be removed any lvconvert command not changing the lay
 In case the RaidLV should be converted to striped:
 
 .nf
-# lvconvert --type striped tb/lv
-  Unable to convert LV tb/lv from raid6_nr to striped.
-  Converting tb/lv from raid6_nr is directly possible to the following layouts:
+# lvconvert --type striped vg/lv
+  Unable to convert LV vg/lv from raid6_nr to striped.
+  Converting vg/lv from raid6_nr is directly possible to the following layouts:
     raid6_nc
     raid6_zr
     raid6_la_6
@@ -1291,16 +1301,22 @@ In case the RaidLV should be converted to striped:
     raid6_rs_6
     raid6_n_6
 
+A direct conversion isn't possible thus the command informed about the possible ones.
+raid6_n_6 is suitable to convert to striped so convert to it first (this is a reshape
+changing the raid6 layout from raid6_nr to raid6_n_6).
+
 # lvconvert --type raid6_n_6
   Using default stripesize 64.00 KiB.
-  Converting raid6_nr LV tb/lv to raid6_n_6.
-Are you sure you want to convert raid6_nr LV tb/lv? [y/n]: y
-  Logical volume tb/lv successfully converted.
+  Converting raid6_nr LV vg/lv to raid6_n_6.
+Are you sure you want to convert raid6_nr LV vg/lv? [y/n]: y
+  Logical volume vg/lv successfully converted.
 
-# lvconvert -y --type striped tb/lv
-  Logical volume tb/lv successfully converted.
+Wait for the reshape to finish.
 
-[root at vm46 ~]# lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
+# lvconvert -y --type striped vg/lv
+  Logical volume vg/lv successfully converted.
+
+[root at vm46 ~]# lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
   LV   Attr       Type    PE Ranges                                                      DOff
   lv   -wi-a----- striped /dev/sda:2-32 /dev/sdaa:2-32 /dev/sdab:2-32 /dev/sdac:3-33
   lv   -wi-a----- striped /dev/sda:34-35 /dev/sdaa:34-35 /dev/sdab:34-35 /dev/sdac:34-35
@@ -1309,16 +1325,16 @@ Are you sure you want to convert raid6_nr LV tb/lv? [y/n]: y
 From striped we can convert to raid10
 
 .nf
-# lvconvert -y --type raid10 tb/lv
+# lvconvert -y --type raid10 vg/lv
   Using default stripesize 64.00 KiB.
-  Logical volume tb/lv successfully converted.
+  Logical volume vg/lv successfully converted.
 
-# lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
+# lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
   LV   Attr       Type   PE Ranges                                                                                   DOff
   lv   rwi-a-r--- raid10 lv_rimage_0:0-32 lv_rimage_4:0-32 lv_rimage_1:0-32 ... lv_rimage_3:0-32 lv_rimage_7:0-32    0
 
-# lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
-  WARNING: Cannot find matching striped segment for tb/lv_rimage_3.
+# lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
+  WARNING: Cannot find matching striped segment for vg/lv_rimage_3.
   LV            Attr       Type   PE Ranges                                                                                   DOff
   lv            rwi-a-r--- raid10 lv_rimage_0:0-32 lv_rimage_4:0-32 lv_rimage_1:0-32 ... lv_rimage_3:0-32 lv_rimage_7:0-32    0
   [lv_rimage_0] iwi-aor--- linear /dev/sda:2-32                                                                                                                              0
@@ -1438,9 +1454,10 @@ Once the conversion has finished we can can convert to striped.
   lv   -wi-a----- 640.00m striped              5 128.00k       /dev/sda(0),/dev/sdhx(1),/dev/sdhw(1),/dev/sdhv(1),/dev/sdhu(1)
 .fi
 
-Reversing these steps wil convert a given striped LV to linear.
+Reversing these steps will convert a given striped LV to linear.
 
-Mind the fact that stripes are removed thus the capacity of the RaidLV will shrink.
+Mind the facts that stripes are removed thus the capacity of the RaidLV will shrink
+and that changing the RaidLV layout will influence its performance.
 
 "lvconvert --stripes 1 vg/lv" for converting to 1 stripe will inform upfront about
 the reduced size to allow for resizing the content or growing the RaidLV before


