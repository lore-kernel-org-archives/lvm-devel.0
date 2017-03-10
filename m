From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 10 Mar 2017 16:40:55 -0500
Subject: master - man: add more info/examples to lvmraid(7)
Message-ID: <201703102140.v2ALetBk006358@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=164d4a309ca62eb6e7810b76e5616074656258e3
Commit:        164d4a309ca62eb6e7810b76e5616074656258e3
Parent:        15682270f4557958d5e2994990534b652229857d
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 10 22:40:22 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 10 22:40:22 2017 +0100

man: add more info/examples to lvmraid(7)

Add a warning about maximum supported numbers of stripes
with striped LVs realtive to RAID conversions.

Add examples for a more elaborate, multi-step conversion
from linear to striped (and vice versa).

Shrink lvs examples output.

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 man/lvmraid.7.in |  231 +++++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 195 insertions(+), 36 deletions(-)

diff --git a/man/lvmraid.7.in b/man/lvmraid.7.in
index 79e6fe0..e5a2dc5 100644
--- a/man/lvmraid.7.in
+++ b/man/lvmraid.7.in
@@ -862,13 +862,66 @@ new parity blocks.  Synchronization can take a long time and degrade
 performance (rate controls also apply to conversion, see
 \fB\-\-maxrecoveryrate\fP.)
 
+Warning: though it is possible to create \fBstriped\fP LVs  with up to 128 stripes,
+a maximum of 64 stripes can be converted to \fBraid0\fP, 63 to \fBraid4/5\fP and
+62 to \fBraid6\fP because of the added parity SubLVs.
+A \fBstriped\fP LV with a maximum of 32 stripes can be converted to \fBraid10\fP.
+
 .P
 
 The following takeover conversions are currently possible:
 .br
 .IP \(bu 3
+between striped and raid0.
+.IP \(bu 3
 between linear and raid1.
 .IP \(bu 3
+between mirror and raid1.
+.IP \(bu 3
+between 2-legged raid1 and raid4/5.
+.IP \(bu 3
+between striped/raid0 and raid4.
+.IP \(bu 3
+between striped/raid0 and raid5.
+.IP \(bu 3
+between striped/raid0 and raid6.
+.IP \(bu 3
+between raid4 and raid5.
+.IP \(bu 3
+between raid4/raid5 and raid6.
+.IP \(bu 3
+between striped/raid0 and raid10.
+
+.SS Examples
+
+1. Converting an LV from \fBlinear\fP to \fBraid1\fP.
+
+.nf
+# lvs -a -o name,segtype,size vg
+  LV   Type   LSize
+  lv   linear 300.00g
+
+# lvconvert --type raid1 --mirrors 1 vg/lv
+
+# lvs -a -o name,segtype,size vg
+  LV            Type   LSize
+  lv            raid1  300.00g
+  [lv_rimage_0] linear 300.00g
+  [lv_rimage_1] linear 300.00g
+  [lv_rmeta_0]  linear   3.00m
+  [lv_rmeta_1]  linear   3.00m
+.fi
+
+2. Converting an LV from \fBmirror\fP to \fBraid1\fP.
+
+.nf
+# lvs -a -o name,segtype,size vg
+  LV            Type   LSize
+  lv            mirror 100.00g
+  [lv_mimage_0] linear 100.00g
+  [lv_mimage_1] linear 100.00g
+  [lv_mlog]     linear   3.00m
+.IP \(bu 3
 between striped and raid4.
 
 .SS Examples
@@ -1052,8 +1105,8 @@ All segments with PE ranges '33-33' provide the out-of-place reshape space.
 The dataoffset column shows that the data was moved from initial offset 0 to
 2048 sectors on each component DataLV.
 
-If the RaidLV should be restriped for performance reasons,
-convert the 3-way striped raid6_nr LV to 5-way-striped.
+For performance reasons the raid6_nr RaidLV can be restriped.
+Convert it from 3-way striped to 5-way-striped.
 
 .nf
 # lvconvert --stripes 5 -y tb/lv
@@ -1069,18 +1122,18 @@ convert the 3-way striped raid6_nr LV to 5-way-striped.
   lv   tb     rwi-a-r-s- 652.00m                                    52.94
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
-  LV            Attr       Type     PE Ranges                                                                                                              DOff
-  lv            rwi-a-r--- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 lv_rimage_3:0-33 lv_rimage_4:0-33 lv_rimage_5:0-33 lv_rimage_6:0-33    0
-  [lv_rimage_0] iwi-aor--- linear   /dev/sda:0-32                                                                                                             0
+  LV            Attr       Type     PE Ranges                                                                                   DOff
+  lv            rwi-a-r--- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33    0
+  [lv_rimage_0] iwi-aor--- linear   /dev/sda:0-32                                                                               0
   [lv_rimage_0] iwi-aor--- linear   /dev/sda:34-34
-  [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:0-32                                                                                                            0
+  [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:0-32                                                                              0
   [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:34-34
-  [lv_rimage_2] iwi-aor--- linear   /dev/sdab:0-32                                                                                                            0
+  [lv_rimage_2] iwi-aor--- linear   /dev/sdab:0-32                                                                              0
   [lv_rimage_2] iwi-aor--- linear   /dev/sdab:34-34
-  [lv_rimage_3] iwi-aor--- linear   /dev/sdac:1-34                                                                                                            0
-  [lv_rimage_4] iwi-aor--- linear   /dev/sdad:1-34                                                                                                            0
-  [lv_rimage_5] iwi-aor--- linear   /dev/sdae:1-34                                                                                                            0
-  [lv_rimage_6] iwi-aor--- linear   /dev/sdaf:1-34                                                                                                            0
+  [lv_rimage_3] iwi-aor--- linear   /dev/sdac:1-34                                                                              0
+  [lv_rimage_4] iwi-aor--- linear   /dev/sdad:1-34                                                                              0
+  [lv_rimage_5] iwi-aor--- linear   /dev/sdae:1-34                                                                              0
+  [lv_rimage_6] iwi-aor--- linear   /dev/sdaf:1-34                                                                              0
   [lv_rmeta_0]  ewi-aor--- linear   /dev/sda:33-33
   [lv_rmeta_1]  ewi-aor--- linear   /dev/sdaa:33-33
   [lv_rmeta_2]  ewi-aor--- linear   /dev/sdab:33-33
@@ -1090,6 +1143,7 @@ convert the 3-way striped raid6_nr LV to 5-way-striped.
   [lv_rmeta_6]  ewi-aor--- linear   /dev/sdaf:0-0
 .fi
 
+Stripes also can be removed from raid5 and 6.
 Convert the 5-way striped raid6_nr LV to 4-way-striped.
 The force option needs to be used, because removing stripes
 (i.e. image SubLVs) from a RaidLV will shrink its size.
@@ -1105,18 +1159,18 @@ The force option needs to be used, because removing stripes
   Logical volume tb/lv successfully converted.
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
-  LV            Attr       Type     PE Ranges                                                                                                              DOff
-  lv            rwi-a-r-s- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 lv_rimage_3:0-33 lv_rimage_4:0-33 lv_rimage_5:0-33 lv_rimage_6:0-33    0
-  [lv_rimage_0] Iwi-aor--- linear   /dev/sda:0-32                                                                                                             0
+  LV            Attr       Type     PE Ranges                                                                                   DOff
+  lv            rwi-a-r-s- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33    0
+  [lv_rimage_0] Iwi-aor--- linear   /dev/sda:0-32                                                                               0
   [lv_rimage_0] Iwi-aor--- linear   /dev/sda:34-34
-  [lv_rimage_1] Iwi-aor--- linear   /dev/sdaa:0-32                                                                                                            0
+  [lv_rimage_1] Iwi-aor--- linear   /dev/sdaa:0-32                                                                              0
   [lv_rimage_1] Iwi-aor--- linear   /dev/sdaa:34-34
-  [lv_rimage_2] Iwi-aor--- linear   /dev/sdab:0-32                                                                                                            0
+  [lv_rimage_2] Iwi-aor--- linear   /dev/sdab:0-32                                                                              0
   [lv_rimage_2] Iwi-aor--- linear   /dev/sdab:34-34
-  [lv_rimage_3] Iwi-aor--- linear   /dev/sdac:1-34                                                                                                            0
-  [lv_rimage_4] Iwi-aor--- linear   /dev/sdad:1-34                                                                                                            0
-  [lv_rimage_5] Iwi-aor--- linear   /dev/sdae:1-34                                                                                                            0
-  [lv_rimage_6] Iwi-aor-R- linear   /dev/sdaf:1-34                                                                                                            0
+  [lv_rimage_3] Iwi-aor--- linear   /dev/sdac:1-34                                                                              0
+  [lv_rimage_4] Iwi-aor--- linear   /dev/sdad:1-34                                                                              0
+  [lv_rimage_5] Iwi-aor--- linear   /dev/sdae:1-34                                                                              0
+  [lv_rimage_6] Iwi-aor-R- linear   /dev/sdaf:1-34                                                                              0
   [lv_rmeta_0]  ewi-aor--- linear   /dev/sda:33-33
   [lv_rmeta_1]  ewi-aor--- linear   /dev/sdaa:33-33
   [lv_rmeta_2]  ewi-aor--- linear   /dev/sdab:33-33
@@ -1131,16 +1185,16 @@ The 'R' in the same column of the attribute field shows the freed image Sub LVs
 
 .nf
 # lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
-  LV   Attr       Type     PE Ranges                                                                                                              DOff
-  lv   rwi-a-r-R- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 lv_rimage_3:0-33 lv_rimage_4:0-33 lv_rimage_5:0-33 lv_rimage_6:0-33 8192
+  LV   Attr       Type     PE Ranges                                                                                DOff
+  lv   rwi-a-r-R- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33 8192
 .fi
 
 Now that the reshape is finished the 'R' atribute on the RaidLV shows images can be removed.
 
 .nf
 # lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
-  LV   Attr       Type     PE Ranges                                                                                                              DOff
-  lv   rwi-a-r-R- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 lv_rimage_3:0-33 lv_rimage_4:0-33 lv_rimage_5:0-33 lv_rimage_6:0-33 8192
+  LV   Attr       Type     PE Ranges                                                                                 DOff
+  lv   rwi-a-r-R- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ...  lv_rimage_5:0-33 lv_rimage_6:0-33 8192
 .fi
 
 This is achieved by repeating the command ("lvconvert --stripes 4 tb/lv" would be sufficient).
@@ -1151,17 +1205,17 @@ This is achieved by repeating the command ("lvconvert --stripes 4 tb/lv" would b
   Logical volume tb/lv successfully converted.
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
-  LV            Attr       Type     PE Ranges                                                                                             DOff
-  lv            rwi-a-r--- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 lv_rimage_3:0-33 lv_rimage_4:0-33 lv_rimage_5:0-33 8192
-  [lv_rimage_0] iwi-aor--- linear   /dev/sda:0-32                                                                                         8192
+  LV            Attr       Type     PE Ranges                                                               DOff
+  lv            rwi-a-r--- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 8192
+  [lv_rimage_0] iwi-aor--- linear   /dev/sda:0-32                                                           8192
   [lv_rimage_0] iwi-aor--- linear   /dev/sda:34-34
-  [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:0-32                                                                                        8192
+  [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:0-32                                                          8192
   [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:34-34
-  [lv_rimage_2] iwi-aor--- linear   /dev/sdab:0-32                                                                                        8192
+  [lv_rimage_2] iwi-aor--- linear   /dev/sdab:0-32                                                          8192
   [lv_rimage_2] iwi-aor--- linear   /dev/sdab:34-34
-  [lv_rimage_3] iwi-aor--- linear   /dev/sdac:1-34                                                                                        8192
-  [lv_rimage_4] iwi-aor--- linear   /dev/sdad:1-34                                                                                        8192
-  [lv_rimage_5] iwi-aor--- linear   /dev/sdae:1-34                                                                                        8192
+  [lv_rimage_3] iwi-aor--- linear   /dev/sdac:1-34                                                          8192
+  [lv_rimage_4] iwi-aor--- linear   /dev/sdad:1-34                                                          8192
+  [lv_rimage_5] iwi-aor--- linear   /dev/sdae:1-34                                                          8192
   [lv_rmeta_0]  ewi-aor--- linear   /dev/sda:33-33
   [lv_rmeta_1]  ewi-aor--- linear   /dev/sdaa:33-33
   [lv_rmeta_2]  ewi-aor--- linear   /dev/sdab:33-33
@@ -1254,13 +1308,13 @@ From striped we can convert to raid10
   Logical volume tb/lv successfully converted.
 
 # lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
-  LV   Attr       Type   PE Ranges                                                                                                                               DOff
-  lv   rwi-a-r--- raid10 lv_rimage_0:0-32 lv_rimage_4:0-32 lv_rimage_1:0-32 lv_rimage_5:0-32 lv_rimage_2:0-32 lv_rimage_6:0-32 lv_rimage_3:0-32 lv_rimage_7:0-32    0
+  LV   Attr       Type   PE Ranges                                                                                   DOff
+  lv   rwi-a-r--- raid10 lv_rimage_0:0-32 lv_rimage_4:0-32 lv_rimage_1:0-32 ... lv_rimage_3:0-32 lv_rimage_7:0-32    0
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
   WARNING: Cannot find matching striped segment for tb/lv_rimage_3.
-  LV            Attr       Type   PE Ranges                                                                                                                               DOff
-  lv            rwi-a-r--- raid10 lv_rimage_0:0-32 lv_rimage_4:0-32 lv_rimage_1:0-32 lv_rimage_5:0-32 lv_rimage_2:0-32 lv_rimage_6:0-32 lv_rimage_3:0-32 lv_rimage_7:0-32    0
+  LV            Attr       Type   PE Ranges                                                                                   DOff
+  lv            rwi-a-r--- raid10 lv_rimage_0:0-32 lv_rimage_4:0-32 lv_rimage_1:0-32 ... lv_rimage_3:0-32 lv_rimage_7:0-32    0
   [lv_rimage_0] iwi-aor--- linear /dev/sda:2-32                                                                                                                              0
   [lv_rimage_0] iwi-aor--- linear /dev/sda:34-35
   [lv_rimage_1] iwi-aor--- linear /dev/sdaa:2-32                                                                                                                             0
@@ -1283,6 +1337,111 @@ From striped we can convert to raid10
 .fi
 
 raid10 allows to add stripes but can't remove them.
+
+
+A more ellaborate example to convert from linear to striped
+with interim conversions to raid1 then raid5 followed
+by restripe (4 steps).
+
+We start with the linear LV.
+
+.nf
+# lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg
+  LV   Attr       LSize   Type   Cpy%Sync #DStr Stripe RSize Devices
+  lv   -wi-a----- 128.00m linear              1     0        /dev/sda(0)
+.fi
+
+Then convert it to a 2-way raid1.
+
+.nf
+# lvconvert -m1 vg/lv
+  Logical volume vg/lv successfully converted.
+
+# lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg
+  LV            Attr       LSize   Type   Cpy%Sync #DStr Stripe RSize Devices
+  lv            rwi-a-r--- 128.00m raid1  100.00       2     0        lv_rimage_0(0),lv_rimage_1(0)
+  [lv_rimage_0] iwi-aor--- 128.00m linear              1     0        /dev/sda(0)
+  [lv_rimage_1] iwi-aor--- 128.00m linear              1     0        /dev/sdhx(1)
+  [lv_rmeta_0]  ewi-aor---   4.00m linear              1     0        /dev/sda(32)
+  [lv_rmeta_1]  ewi-aor---   4.00m linear              1     0        /dev/sdhx(0)
+.fi
+
+Once the raid1 LV is fully synchronized we convert it to raid5_n (only 2-way raid1
+LVs can be converted to raid5).  We select raid5_n here because it has dedicated parity
+SubLVs at the end and can be converted to striped directly without any additional
+conversion.
+
+.nf
+# lvconvert -y --ty raid5_n vg/lv
+  Using default stripesize 64.00 KiB.
+  Logical volume vg/lv successfully converted.
+
+# lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg
+  LV            Attr       LSize   Type    Cpy%Sync #DStr Stripe RSize Devices
+  lv            rwi-a-r--- 128.00m raid5_n 100.00       1 64.00k     0 lv_rimage_0(0),lv_rimage_1(0)
+  [lv_rimage_0] iwi-aor--- 128.00m linear               1     0      0 /dev/sda(0)
+  [lv_rimage_1] iwi-aor--- 128.00m linear               1     0      0 /dev/sdhx(1)
+  [lv_rmeta_0]  ewi-aor---   4.00m linear               1     0        /dev/sda(32)
+  [lv_rmeta_1]  ewi-aor---   4.00m linear               1     0        /dev/sdhx(0)
+.fi
+
+Now we'll change the number of data stripes from 1 to 5 and request 128K stripe size
+in one command.  This will grow the size of the LV by a factor of 5 (we add 4 data stripes
+to the one given).  That additonal space can be used by e.g. growing any contained filesystem
+or the LV can be reduced in size after the reshaping conversion has finished.
+
+.nf
+# lvconvert --yes --stripesize 128k --stripes 5 vg/lv
+  Converting stripesize 64.00 KiB of raid5_n LV vg/lv to 128.00 KiB.
+  WARNING: Adding stripes to active logical volume vg/lv will grow it from 32 to 160 extents!
+  Run "lvresize -l32 vg/lv" to shrink it or use the additional capacity.
+  Logical volume vg/lv successfully converted.
+
+# lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg
+  LV            Attr       LSize   Type    Cpy%Sync #DStr Stripe  RSize Devices
+  lv            rwi-a-r--- 640.00m raid5_n 100.00       5 128.00k     6 lv_rimage_0(0),lv_rimage_1(0),lv_rimage_2(0),lv_rimage_3(0),lv_rimage_4(0),lv_rimage_5(0)
+  [lv_rimage_0] iwi-aor--- 132.00m linear               1      0      1 /dev/sda(33)
+  [lv_rimage_0] iwi-aor--- 132.00m linear               1      0        /dev/sda(0)
+  [lv_rimage_1] iwi-aor--- 132.00m linear               1      0      1 /dev/sdhx(33)
+  [lv_rimage_1] iwi-aor--- 132.00m linear               1      0        /dev/sdhx(1)
+  [lv_rimage_2] iwi-aor--- 132.00m linear               1      0      1 /dev/sdhw(33)
+  [lv_rimage_2] iwi-aor--- 132.00m linear               1      0        /dev/sdhw(1)
+  [lv_rimage_3] iwi-aor--- 132.00m linear               1      0      1 /dev/sdhv(33)
+  [lv_rimage_3] iwi-aor--- 132.00m linear               1      0        /dev/sdhv(1)
+  [lv_rimage_4] iwi-aor--- 132.00m linear               1      0      1 /dev/sdhu(33)
+  [lv_rimage_4] iwi-aor--- 132.00m linear               1      0        /dev/sdhu(1)
+  [lv_rimage_5] iwi-aor--- 132.00m linear               1      0      1 /dev/sdht(33)
+  [lv_rimage_5] iwi-aor--- 132.00m linear               1      0        /dev/sdht(1)
+  [lv_rmeta_0]  ewi-aor---   4.00m linear               1      0        /dev/sda(32)
+  [lv_rmeta_1]  ewi-aor---   4.00m linear               1      0        /dev/sdhx(0)
+  [lv_rmeta_2]  ewi-aor---   4.00m linear               1      0        /dev/sdhw(0)
+  [lv_rmeta_3]  ewi-aor---   4.00m linear               1      0        /dev/sdhv(0)
+  [lv_rmeta_4]  ewi-aor---   4.00m linear               1      0        /dev/sdhu(0)
+  [lv_rmeta_5]  ewi-aor---   4.00m linear               1      0        /dev/sdht(0)
+.fi
+
+Once the conversion has finished we can can convert to striped.
+
+.nf
+[root at vm46 ~]# lvconvert -y --ty striped vg/lv
+  Logical volume vg/lv successfully converted.
+
+[root at vm46 ~]# lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg|sed 's/  *$//'
+  LV   Attr       LSize   Type    Cpy%Sync #DStr Stripe  RSize Devices
+  lv   -wi-a----- 640.00m striped              5 128.00k       /dev/sda(33),/dev/sdhx(33),/dev/sdhw(33),/dev/sdhv(33),/dev/sdhu(33)
+  lv   -wi-a----- 640.00m striped              5 128.00k       /dev/sda(0),/dev/sdhx(1),/dev/sdhw(1),/dev/sdhv(1),/dev/sdhu(1)
+.fi
+
+Reversing these steps wil convert a given striped LV to linear.
+
+Mind the fact that stripes are removed thus the capacity of the RaidLV will shrink.
+
+"lvconvert --stripes 1 vg/lv" for converting to 1 stripe will inform upfront about
+the reduced size to allow for resizing the content or growing the RaidLV before
+actually converting to 1 stripe.  The \fB\-\-force\fP option is needed to
+allow stripe removing conversions to prevent data loss.
+
+Of course any interim step can be the intended last one (e.g. striped -> raid1).
 ..
 
 .SH RAID5 Variants


