From: David Teigland <teigland@sourceware.org>
Date: Tue, 11 Apr 2017 16:24:49 -0400
Subject: master - man lvmraid: wrap long lines
Message-ID: <201704112024.v3BKOnEJ003553@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c7ecf379abfffee385c8e862029285d1b436845d
Commit:        c7ecf379abfffee385c8e862029285d1b436845d
Parent:        69c3543855a98fcbb644bec0c7816913369c3892
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 11 15:23:48 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 11 15:23:48 2017 -0500

man lvmraid: wrap long lines

Break lines in examples to keep line length under 80.
---
 man/lvmraid.7_main |  284 ++++++++++++++++++++++++++++++----------------------
 1 files changed, 165 insertions(+), 119 deletions(-)

diff --git a/man/lvmraid.7_main b/man/lvmraid.7_main
index 995115d..47dc6ba 100644
--- a/man/lvmraid.7_main
+++ b/man/lvmraid.7_main
@@ -357,9 +357,9 @@ Also, if mismatches were found, the lvs attr field will display the letter
 "m" (mismatch) in the 9th position, e.g.
 
 .nf
-# lvs -o name,vgname,segtype,attr vg/lvol0
-  LV    VG   Type  Attr
-  lvol0 vg   raid1 Rwi-a-r-m-
+# lvs -o name,vgname,segtype,attr vg/lv
+  LV VG   Type  Attr
+  lv vg   raid1 Rwi-a-r-m-
 .fi
 
 
@@ -427,9 +427,9 @@ Each rimage SubLV holds a portion of LV data.  No parity is used.
 No RAID metadata is used.
 
 .nf
-lvcreate --type raid0 --stripes 2 --name lvr0 ...
+# lvcreate --type raid0 --stripes 2 --name lvr0 ...
 
-lvs -a -o name,segtype,devices
+# lvs -a -o name,segtype,devices
   lvr0            raid0  lvr0_rimage_0(0),lvr0_rimage_1(0)
   [lvr0_rimage_0] linear /dev/sda(...)
   [lvr0_rimage_1] linear /dev/sdb(...)
@@ -441,9 +441,9 @@ Each rimage SubLV holds a complete copy of LV data.  No parity is used.
 Each rmeta SubLV holds RAID metadata.
 
 .nf
-lvcreate --type raid1 --mirrors 1 --name lvr1 ...
+# lvcreate --type raid1 --mirrors 1 --name lvr1 ...
 
-lvs -a -o name,segtype,devices
+# lvs -a -o name,segtype,devices
   lvr1            raid1  lvr1_rimage_0(0),lvr1_rimage_1(0)
   [lvr1_rimage_0] linear /dev/sda(...)
   [lvr1_rimage_1] linear /dev/sdb(...)
@@ -457,9 +457,9 @@ At least three rimage SubLVs each hold a portion of LV data and one rimage SubLV
 holds parity.  Each rmeta SubLV holds RAID metadata.
 
 .nf
-lvcreate --type raid4 --stripes 2 --name lvr4 ...
+# lvcreate --type raid4 --stripes 2 --name lvr4 ...
 
-lvs -a -o name,segtype,devices
+# lvs -a -o name,segtype,devices
   lvr4            raid4  lvr4_rimage_0(0),\\
                          lvr4_rimage_1(0),\\
                          lvr4_rimage_2(0)
@@ -478,9 +478,9 @@ At least three rimage SubLVs each typcially hold a portion of LV data and parity
 Each rmeta SubLV holds RAID metadata.
 
 .nf
-lvcreate --type raid5 --stripes 2 --name lvr5 ...
+# lvcreate --type raid5 --stripes 2 --name lvr5 ...
 
-lvs -a -o name,segtype,devices
+# lvs -a -o name,segtype,devices
   lvr5            raid5  lvr5_rimage_0(0),\\
                          lvr5_rimage_1(0),\\
                          lvr5_rimage_2(0)
@@ -499,9 +499,9 @@ At least five rimage SubLVs each typically hold a portion of LV data and parity.
 Each rmeta SubLV holds RAID metadata.
 
 .nf
-lvcreate --type raid6 --stripes 3 --name lvr6
+# lvcreate --type raid6 --stripes 3 --name lvr6
 
-lvs -a -o name,segtype,devices
+# lvs -a -o name,segtype,devices
   lvr6            raid6  lvr6_rimage_0(0),\\
                          lvr6_rimage_1(0),\\
                          lvr6_rimage_2(0),\\
@@ -528,9 +528,9 @@ At least four rimage SubLVs each hold a portion of LV data.  No parity is used.
 Each rmeta SubLV holds RAID metadata.
 
 .nf
-lvcreate --type raid10 --stripes 2 --mirrors 1 --name lvr10
+# lvcreate --type raid10 --stripes 2 --mirrors 1 --name lvr10
 
-lvs -a -o name,segtype,devices
+# lvs -a -o name,segtype,devices
   lvr10            raid10 lvr10_rimage_0(0),\\
                           lvr10_rimage_1(0),\\
                           lvr10_rimage_2(0),\\
@@ -689,14 +689,14 @@ the lvchange command to refresh an LV:
 
 .nf
 # lvs -o name,vgname,segtype,attr,size vg
-  LV    VG   Type  Attr       LSize
-  raid1 vg   raid1 Rwi-a-r-r- 100.00g
+  LV VG   Type  Attr       LSize
+  lv vg   raid1 Rwi-a-r-r- 100.00g
 
-# lvchange --refresh vg/raid1
+# lvchange --refresh vg/lv
 
 # lvs -o name,vgname,segtype,attr,size vg
-  LV    VG   Type  Attr       LSize
-  raid1 vg   raid1 Rwi-a-r--- 100.00g
+  LV VG   Type  Attr       LSize
+  lv vg   raid1 Rwi-a-r--- 100.00g
 .fi
 
 .SS Automatic repair
@@ -1133,29 +1133,27 @@ Convert it from 3-way striped to 5-way-striped.
   capacity.
   Logical volume vg/lv successfully converted.
 
-# lvs
+# lvs vg/lv
   LV   VG     Attr       LSize   Cpy%Sync
-  root fedora -wi-ao----  15.00g
-  swap fedora -wi-ao----   3.99g
   lv   vg     rwi-a-r-s- 652.00m 52.94
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
-  LV            Attr       Type     PE Ranges                                                                                   DOff
+  LV            Attr       Type     PE Ranges          DOff
   lv            rwi-a-r--- raid6_nr lv_rimage_0:0-33 \\
                                     lv_rimage_1:0-33 \\
                                     lv_rimage_2:0-33 ... \\
                                     lv_rimage_5:0-33 \\
-                                    lv_rimage_6:0-33    0
-  [lv_rimage_0] iwi-aor--- linear   /dev/sda:0-32                                                                               0
+                                    lv_rimage_6:0-33   0
+  [lv_rimage_0] iwi-aor--- linear   /dev/sda:0-32      0
   [lv_rimage_0] iwi-aor--- linear   /dev/sda:34-34
-  [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:0-32                                                                              0
+  [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:0-32     0
   [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:34-34
-  [lv_rimage_2] iwi-aor--- linear   /dev/sdab:0-32                                                                              0
+  [lv_rimage_2] iwi-aor--- linear   /dev/sdab:0-32     0
   [lv_rimage_2] iwi-aor--- linear   /dev/sdab:34-34
-  [lv_rimage_3] iwi-aor--- linear   /dev/sdac:1-34                                                                              0
-  [lv_rimage_4] iwi-aor--- linear   /dev/sdad:1-34                                                                              0
-  [lv_rimage_5] iwi-aor--- linear   /dev/sdae:1-34                                                                              0
-  [lv_rimage_6] iwi-aor--- linear   /dev/sdaf:1-34                                                                              0
+  [lv_rimage_3] iwi-aor--- linear   /dev/sdac:1-34     0
+  [lv_rimage_4] iwi-aor--- linear   /dev/sdad:1-34     0
+  [lv_rimage_5] iwi-aor--- linear   /dev/sdae:1-34     0
+  [lv_rimage_6] iwi-aor--- linear   /dev/sdaf:1-34     0
   [lv_rmeta_0]  ewi-aor--- linear   /dev/sda:33-33
   [lv_rmeta_1]  ewi-aor--- linear   /dev/sdaa:33-33
   [lv_rmeta_2]  ewi-aor--- linear   /dev/sdab:33-33
@@ -1184,22 +1182,22 @@ The force option needs to be used, because removing stripes
   Logical volume vg/lv successfully converted.
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
-  LV            Attr       Type     PE Ranges           DOff
+  LV            Attr       Type     PE Ranges          DOff
   lv            rwi-a-r-s- raid6_nr lv_rimage_0:0-33 \\
                                     lv_rimage_1:0-33 \\
                                     lv_rimage_2:0-33 ... \\
                                     lv_rimage_5:0-33 \\
-                                    lv_rimage_6:0-33    0
-  [lv_rimage_0] Iwi-aor--- linear   /dev/sda:0-32       0
+                                    lv_rimage_6:0-33   0
+  [lv_rimage_0] Iwi-aor--- linear   /dev/sda:0-32      0
   [lv_rimage_0] Iwi-aor--- linear   /dev/sda:34-34
-  [lv_rimage_1] Iwi-aor--- linear   /dev/sdaa:0-32      0
+  [lv_rimage_1] Iwi-aor--- linear   /dev/sdaa:0-32     0
   [lv_rimage_1] Iwi-aor--- linear   /dev/sdaa:34-34
-  [lv_rimage_2] Iwi-aor--- linear   /dev/sdab:0-32      0
+  [lv_rimage_2] Iwi-aor--- linear   /dev/sdab:0-32     0
   [lv_rimage_2] Iwi-aor--- linear   /dev/sdab:34-34
-  [lv_rimage_3] Iwi-aor--- linear   /dev/sdac:1-34      0
-  [lv_rimage_4] Iwi-aor--- linear   /dev/sdad:1-34      0
-  [lv_rimage_5] Iwi-aor--- linear   /dev/sdae:1-34      0
-  [lv_rimage_6] Iwi-aor-R- linear   /dev/sdaf:1-34      0
+  [lv_rimage_3] Iwi-aor--- linear   /dev/sdac:1-34     0
+  [lv_rimage_4] Iwi-aor--- linear   /dev/sdad:1-34     0
+  [lv_rimage_5] Iwi-aor--- linear   /dev/sdae:1-34     0
+  [lv_rimage_6] Iwi-aor-R- linear   /dev/sdaf:1-34     0
   [lv_rmeta_0]  ewi-aor--- linear   /dev/sda:33-33
   [lv_rmeta_1]  ewi-aor--- linear   /dev/sdaa:33-33
   [lv_rmeta_2]  ewi-aor--- linear   /dev/sdab:33-33
@@ -1214,41 +1212,48 @@ The 'R' in the same column of the attribute field shows the freed image Sub LVs
 
 .nf
 # lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
-  LV   Attr       Type     PE Ranges               DOff
+  LV   Attr       Type     PE Ranges          DOff
   lv   rwi-a-r-R- raid6_nr lv_rimage_0:0-33 \\
                            lv_rimage_1:0-33 \\
                            lv_rimage_2:0-33 ... \\
                            lv_rimage_5:0-33 \\
-                           lv_rimage_6:0-33        8192
+                           lv_rimage_6:0-33   8192
 .fi
 
 Now that the reshape is finished the 'R' atribute on the RaidLV shows images can be removed.
 
 .nf
 # lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
-  LV   Attr       Type     PE Ranges                                                                                 DOff
-  lv   rwi-a-r-R- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ...  lv_rimage_5:0-33 lv_rimage_6:0-33 8192
+  LV   Attr       Type     PE Ranges          DOff
+  lv   rwi-a-r-R- raid6_nr lv_rimage_0:0-33 \\
+                           lv_rimage_1:0-33 \\
+                           lv_rimage_2:0-33 ... \\
+                           lv_rimage_5:0-33 \\
+                           lv_rimage_6:0-33   8192
 .fi
 
 This is achieved by repeating the command ("lvconvert --stripes 4 vg/lv" would be sufficient).
 
 .nf
-# lvconvert --stripes 4 --force -y vg/lv
+# lvconvert --stripes 4 vg/lv
   Using default stripesize 64.00 KiB.
   Logical volume vg/lv successfully converted.
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
-  LV            Attr       Type     PE Ranges                                                               DOff
-  lv            rwi-a-r--- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 8192
-  [lv_rimage_0] iwi-aor--- linear   /dev/sda:0-32                                                           8192
+  LV            Attr       Type     PE Ranges          DOff
+  lv            rwi-a-r--- raid6_nr lv_rimage_0:0-33 \\
+                                    lv_rimage_1:0-33 \\
+                                    lv_rimage_2:0-33 ... \\
+                                    lv_rimage_5:0-33   8192
+  [lv_rimage_0] iwi-aor--- linear   /dev/sda:0-32      8192
   [lv_rimage_0] iwi-aor--- linear   /dev/sda:34-34
-  [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:0-32                                                          8192
+  [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:0-32     8192
   [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:34-34
-  [lv_rimage_2] iwi-aor--- linear   /dev/sdab:0-32                                                          8192
+  [lv_rimage_2] iwi-aor--- linear   /dev/sdab:0-32     8192
   [lv_rimage_2] iwi-aor--- linear   /dev/sdab:34-34
-  [lv_rimage_3] iwi-aor--- linear   /dev/sdac:1-34                                                          8192
-  [lv_rimage_4] iwi-aor--- linear   /dev/sdad:1-34                                                          8192
-  [lv_rimage_5] iwi-aor--- linear   /dev/sdae:1-34                                                          8192
+  [lv_rimage_3] iwi-aor--- linear   /dev/sdac:1-34     8192
+  [lv_rimage_4] iwi-aor--- linear   /dev/sdad:1-34     8192
+  [lv_rimage_5] iwi-aor--- linear   /dev/sdae:1-34     8192
   [lv_rmeta_0]  ewi-aor--- linear   /dev/sda:33-33
   [lv_rmeta_1]  ewi-aor--- linear   /dev/sdaa:33-33
   [lv_rmeta_2]  ewi-aor--- linear   /dev/sdab:33-33
@@ -1319,54 +1324,72 @@ In case the RaidLV should be converted to striped:
     raid6_ra_6
     raid6_rs_6
     raid6_n_6
+.fi
 
 A direct conversion isn't possible thus the command informed about the possible ones.
 raid6_n_6 is suitable to convert to striped so convert to it first (this is a reshape
 changing the raid6 layout from raid6_nr to raid6_n_6).
 
+.nf
 # lvconvert --type raid6_n_6
   Using default stripesize 64.00 KiB.
   Converting raid6_nr LV vg/lv to raid6_n_6.
 Are you sure you want to convert raid6_nr LV vg/lv? [y/n]: y
   Logical volume vg/lv successfully converted.
+.fi
 
 Wait for the reshape to finish.
 
-# lvconvert -y --type striped vg/lv
+.nf
+# lvconvert --type striped vg/lv
   Logical volume vg/lv successfully converted.
 
-[root at vm46 ~]# lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
-  LV   Attr       Type    PE Ranges                                                      DOff
-  lv   -wi-a----- striped /dev/sda:2-32 /dev/sdaa:2-32 /dev/sdab:2-32 /dev/sdac:3-33
-  lv   -wi-a----- striped /dev/sda:34-35 /dev/sdaa:34-35 /dev/sdab:34-35 /dev/sdac:34-35
+# lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
+  LV   Attr       Type    PE Ranges  DOff
+  lv   -wi-a----- striped /dev/sda:2-32 \\
+                          /dev/sdaa:2-32 \\
+                          /dev/sdab:2-32 \\
+                          /dev/sdac:3-33
+  lv   -wi-a----- striped /dev/sda:34-35 \\
+                          /dev/sdaa:34-35 \\
+                          /dev/sdab:34-35 \\
+                          /dev/sdac:34-35
 .fi
 
 From striped we can convert to raid10
 
 .nf
-# lvconvert -y --type raid10 vg/lv
+# lvconvert --type raid10 vg/lv
   Using default stripesize 64.00 KiB.
   Logical volume vg/lv successfully converted.
 
 # lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
-  LV   Attr       Type   PE Ranges                                                                                   DOff
-  lv   rwi-a-r--- raid10 lv_rimage_0:0-32 lv_rimage_4:0-32 lv_rimage_1:0-32 ... lv_rimage_3:0-32 lv_rimage_7:0-32    0
+  LV   Attr       Type   PE Ranges          DOff
+  lv   rwi-a-r--- raid10 lv_rimage_0:0-32 \\
+                         lv_rimage_4:0-32 \\
+                         lv_rimage_1:0-32 ... \\
+                         lv_rimage_3:0-32 \\
+                         lv_rimage_7:0-32   0
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
   WARNING: Cannot find matching striped segment for vg/lv_rimage_3.
-  LV            Attr       Type   PE Ranges                                                                                   DOff
-  lv            rwi-a-r--- raid10 lv_rimage_0:0-32 lv_rimage_4:0-32 lv_rimage_1:0-32 ... lv_rimage_3:0-32 lv_rimage_7:0-32    0
-  [lv_rimage_0] iwi-aor--- linear /dev/sda:2-32                                                                                                                              0
+  LV            Attr       Type   PE Ranges          DOff
+  lv            rwi-a-r--- raid10 lv_rimage_0:0-32 \\
+                                  lv_rimage_4:0-32 \\
+                                  lv_rimage_1:0-32 ... \\
+                                  lv_rimage_3:0-32 \\
+                                  lv_rimage_7:0-32   0
+  [lv_rimage_0] iwi-aor--- linear /dev/sda:2-32      0
   [lv_rimage_0] iwi-aor--- linear /dev/sda:34-35
-  [lv_rimage_1] iwi-aor--- linear /dev/sdaa:2-32                                                                                                                             0
+  [lv_rimage_1] iwi-aor--- linear /dev/sdaa:2-32     0
   [lv_rimage_1] iwi-aor--- linear /dev/sdaa:34-35
-  [lv_rimage_2] iwi-aor--- linear /dev/sdab:2-32                                                                                                                             0
+  [lv_rimage_2] iwi-aor--- linear /dev/sdab:2-32     0
   [lv_rimage_2] iwi-aor--- linear /dev/sdab:34-35
-  [lv_rimage_3] iwi-XXr--- linear /dev/sdac:3-35                                                                                                                             0
-  [lv_rimage_4] iwi-aor--- linear /dev/sdad:1-33                                                                                                                             0
-  [lv_rimage_5] iwi-aor--- linear /dev/sdae:1-33                                                                                                                             0
-  [lv_rimage_6] iwi-aor--- linear /dev/sdaf:1-33                                                                                                                             0
-  [lv_rimage_7] iwi-aor--- linear /dev/sdag:1-33                                                                                                                             0
+  [lv_rimage_3] iwi-XXr--- linear /dev/sdac:3-35     0
+  [lv_rimage_4] iwi-aor--- linear /dev/sdad:1-33     0
+  [lv_rimage_5] iwi-aor--- linear /dev/sdae:1-33     0
+  [lv_rimage_6] iwi-aor--- linear /dev/sdaf:1-33     0
+  [lv_rimage_7] iwi-aor--- linear /dev/sdag:1-33     0
   [lv_rmeta_0]  ewi-aor--- linear /dev/sda:0-0
   [lv_rmeta_1]  ewi-aor--- linear /dev/sdaa:0-0
   [lv_rmeta_2]  ewi-aor--- linear /dev/sdab:0-0
@@ -1387,24 +1410,27 @@ by restripe (4 steps).
 We start with the linear LV.
 
 .nf
-# lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg
-  LV   Attr       LSize   Type   Cpy%Sync #DStr Stripe RSize Devices
-  lv   -wi-a----- 128.00m linear              1     0        /dev/sda(0)
+# lvs -a -o name,size,segtype,syncpercent,datastripes,\\
+            stripesize,reshapelenle,devices vg
+  LV   LSize   Type   Cpy%Sync #DStr Stripe RSize Devices
+  lv   128.00m linear              1     0        /dev/sda(0)
 .fi
 
 Then convert it to a 2-way raid1.
 
 .nf
-# lvconvert -m1 vg/lv
+# lvconvert --mirrors 1 vg/lv
   Logical volume vg/lv successfully converted.
 
-# lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg
-  LV            Attr       LSize   Type   Cpy%Sync #DStr Stripe RSize Devices
-  lv            rwi-a-r--- 128.00m raid1  100.00       2     0        lv_rimage_0(0),lv_rimage_1(0)
-  [lv_rimage_0] iwi-aor--- 128.00m linear              1     0        /dev/sda(0)
-  [lv_rimage_1] iwi-aor--- 128.00m linear              1     0        /dev/sdhx(1)
-  [lv_rmeta_0]  ewi-aor---   4.00m linear              1     0        /dev/sda(32)
-  [lv_rmeta_1]  ewi-aor---   4.00m linear              1     0        /dev/sdhx(0)
+# lvs -a -o name,size,segtype,datastripes,\\
+            stripesize,reshapelenle,devices vg
+  LV            LSize   Type   #DStr Stripe RSize Devices
+  lv            128.00m raid1      2     0        lv_rimage_0(0),\\
+                                                  lv_rimage_1(0)
+  [lv_rimage_0] 128.00m linear     1     0        /dev/sda(0)
+  [lv_rimage_1] 128.00m linear     1     0        /dev/sdhx(1)
+  [lv_rmeta_0]    4.00m linear     1     0        /dev/sda(32)
+  [lv_rmeta_1]    4.00m linear     1     0        /dev/sdhx(0)
 .fi
 
 Once the raid1 LV is fully synchronized we convert it to raid5_n (only 2-way raid1
@@ -1413,17 +1439,19 @@ SubLVs at the end and can be converted to striped directly without any additiona
 conversion.
 
 .nf
-# lvconvert -y --ty raid5_n vg/lv
+# lvconvert --type raid5_n vg/lv
   Using default stripesize 64.00 KiB.
   Logical volume vg/lv successfully converted.
 
-# lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg
-  LV            Attr       LSize   Type    Cpy%Sync #DStr Stripe RSize Devices
-  lv            rwi-a-r--- 128.00m raid5_n 100.00       1 64.00k     0 lv_rimage_0(0),lv_rimage_1(0)
-  [lv_rimage_0] iwi-aor--- 128.00m linear               1     0      0 /dev/sda(0)
-  [lv_rimage_1] iwi-aor--- 128.00m linear               1     0      0 /dev/sdhx(1)
-  [lv_rmeta_0]  ewi-aor---   4.00m linear               1     0        /dev/sda(32)
-  [lv_rmeta_1]  ewi-aor---   4.00m linear               1     0        /dev/sdhx(0)
+# lvs -a -o name,size,segtype,syncpercent,datastripes,\\
+            stripesize,reshapelenle,devices vg
+  LV            LSize   Type    #DStr Stripe RSize Devices
+  lv            128.00m raid5_n     1 64.00k     0 lv_rimage_0(0),\\
+                                                   lv_rimage_1(0)
+  [lv_rimage_0] 128.00m linear      1     0      0 /dev/sda(0)
+  [lv_rimage_1] 128.00m linear      1     0      0 /dev/sdhx(1)
+  [lv_rmeta_0]    4.00m linear      1     0        /dev/sda(32)
+  [lv_rmeta_1]    4.00m linear      1     0        /dev/sdhx(0)
 .fi
 
 Now we'll change the number of data stripes from 1 to 5 and request 128K stripe size
@@ -1432,45 +1460,61 @@ to the one given).  That additonal space can be used by e.g. growing any contain
 or the LV can be reduced in size after the reshaping conversion has finished.
 
 .nf
-# lvconvert --yes --stripesize 128k --stripes 5 vg/lv
+# lvconvert --stripesize 128k --stripes 5 vg/lv
   Converting stripesize 64.00 KiB of raid5_n LV vg/lv to 128.00 KiB.
-  WARNING: Adding stripes to active logical volume vg/lv will grow it from 32 to 160 extents!
+  WARNING: Adding stripes to active logical volume vg/lv will grow \\
+  it from 32 to 160 extents!
   Run "lvresize -l32 vg/lv" to shrink it or use the additional capacity.
   Logical volume vg/lv successfully converted.
 
-# lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg
-  LV            Attr       LSize   Type    Cpy%Sync #DStr Stripe  RSize Devices
-  lv            rwi-a-r--- 640.00m raid5_n 100.00       5 128.00k     6 lv_rimage_0(0),lv_rimage_1(0),lv_rimage_2(0),lv_rimage_3(0),lv_rimage_4(0),lv_rimage_5(0)
-  [lv_rimage_0] iwi-aor--- 132.00m linear               1      0      1 /dev/sda(33)
-  [lv_rimage_0] iwi-aor--- 132.00m linear               1      0        /dev/sda(0)
-  [lv_rimage_1] iwi-aor--- 132.00m linear               1      0      1 /dev/sdhx(33)
-  [lv_rimage_1] iwi-aor--- 132.00m linear               1      0        /dev/sdhx(1)
-  [lv_rimage_2] iwi-aor--- 132.00m linear               1      0      1 /dev/sdhw(33)
-  [lv_rimage_2] iwi-aor--- 132.00m linear               1      0        /dev/sdhw(1)
-  [lv_rimage_3] iwi-aor--- 132.00m linear               1      0      1 /dev/sdhv(33)
-  [lv_rimage_3] iwi-aor--- 132.00m linear               1      0        /dev/sdhv(1)
-  [lv_rimage_4] iwi-aor--- 132.00m linear               1      0      1 /dev/sdhu(33)
-  [lv_rimage_4] iwi-aor--- 132.00m linear               1      0        /dev/sdhu(1)
-  [lv_rimage_5] iwi-aor--- 132.00m linear               1      0      1 /dev/sdht(33)
-  [lv_rimage_5] iwi-aor--- 132.00m linear               1      0        /dev/sdht(1)
-  [lv_rmeta_0]  ewi-aor---   4.00m linear               1      0        /dev/sda(32)
-  [lv_rmeta_1]  ewi-aor---   4.00m linear               1      0        /dev/sdhx(0)
-  [lv_rmeta_2]  ewi-aor---   4.00m linear               1      0        /dev/sdhw(0)
-  [lv_rmeta_3]  ewi-aor---   4.00m linear               1      0        /dev/sdhv(0)
-  [lv_rmeta_4]  ewi-aor---   4.00m linear               1      0        /dev/sdhu(0)
-  [lv_rmeta_5]  ewi-aor---   4.00m linear               1      0        /dev/sdht(0)
+# lvs -a -o name,size,segtype,datastripes,\\
+            stripesize,reshapelenle,devices
+  LV            LSize   Type    #DStr Stripe  RSize Devices
+  lv            640.00m raid5_n     5 128.00k     6 lv_rimage_0(0),\\
+                                                    lv_rimage_1(0),\\
+                                                    lv_rimage_2(0),\\
+                                                    lv_rimage_3(0),\\
+                                                    lv_rimage_4(0),\\
+                                                    lv_rimage_5(0)
+  [lv_rimage_0] 132.00m linear      1      0      1 /dev/sda(33)
+  [lv_rimage_0] 132.00m linear      1      0        /dev/sda(0)
+  [lv_rimage_1] 132.00m linear      1      0      1 /dev/sdhx(33)
+  [lv_rimage_1] 132.00m linear      1      0        /dev/sdhx(1)
+  [lv_rimage_2] 132.00m linear      1      0      1 /dev/sdhw(33)
+  [lv_rimage_2] 132.00m linear      1      0        /dev/sdhw(1)
+  [lv_rimage_3] 132.00m linear      1      0      1 /dev/sdhv(33)
+  [lv_rimage_3] 132.00m linear      1      0        /dev/sdhv(1)
+  [lv_rimage_4] 132.00m linear      1      0      1 /dev/sdhu(33)
+  [lv_rimage_4] 132.00m linear      1      0        /dev/sdhu(1)
+  [lv_rimage_5] 132.00m linear      1      0      1 /dev/sdht(33)
+  [lv_rimage_5] 132.00m linear      1      0        /dev/sdht(1)
+  [lv_rmeta_0]    4.00m linear      1      0        /dev/sda(32)
+  [lv_rmeta_1]    4.00m linear      1      0        /dev/sdhx(0)
+  [lv_rmeta_2]    4.00m linear      1      0        /dev/sdhw(0)
+  [lv_rmeta_3]    4.00m linear      1      0        /dev/sdhv(0)
+  [lv_rmeta_4]    4.00m linear      1      0        /dev/sdhu(0)
+  [lv_rmeta_5]    4.00m linear      1      0        /dev/sdht(0)
 .fi
 
 Once the conversion has finished we can can convert to striped.
 
 .nf
-[root at vm46 ~]# lvconvert -y --ty striped vg/lv
+# lvconvert --type striped vg/lv
   Logical volume vg/lv successfully converted.
 
-[root at vm46 ~]# lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg|sed 's/  *$//'
-  LV   Attr       LSize   Type    Cpy%Sync #DStr Stripe  RSize Devices
-  lv   -wi-a----- 640.00m striped              5 128.00k       /dev/sda(33),/dev/sdhx(33),/dev/sdhw(33),/dev/sdhv(33),/dev/sdhu(33)
-  lv   -wi-a----- 640.00m striped              5 128.00k       /dev/sda(0),/dev/sdhx(1),/dev/sdhw(1),/dev/sdhv(1),/dev/sdhu(1)
+# lvs -a -o name,size,segtype,datastripes,\\
+            stripesize,reshapelenle,devices vg
+  LV   LSize   Type    #DStr Stripe  RSize Devices
+  lv   640.00m striped     5 128.00k       /dev/sda(33),\\
+                                           /dev/sdhx(33),\\
+                                           /dev/sdhw(33),\\
+                                           /dev/sdhv(33),\\
+                                           /dev/sdhu(33)
+  lv   640.00m striped     5 128.00k       /dev/sda(0),\\
+                                           /dev/sdhx(1),\\
+                                           /dev/sdhw(1),\\
+                                           /dev/sdhv(1),\\
+                                           /dev/sdhu(1)
 .fi
 
 Reversing these steps will convert a given striped LV to linear.
@@ -1527,6 +1571,7 @@ RAID5 parity n
 .br
 \[bu]
 Dedicated parity device n used for striped/raid0 conversions
+.br
 \[bu]
 Used for RAID Takeover
 
@@ -1575,6 +1620,7 @@ RAID6 last parity devices
 \[bu]
 Fixed dedicated last devices (P-Syndrome N-1 and Q-Syndrome N)
 with striped data used for striped/raid0 conversions
+.br
 \[bu]
 Used for RAID Takeover
 


