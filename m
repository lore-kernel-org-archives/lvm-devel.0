From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 9 Mar 2017 17:18:48 -0500
Subject: master - man: add more examples to lvmraid(7)
Message-ID: <201703092218.v29MImSB001691@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d2aae8cff476034539c3cfe577204b53187fb166
Commit:        d2aae8cff476034539c3cfe577204b53187fb166
Parent:        1ba11aa7eebb8367e4e0073683db06d53e8fe6e6
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 9 22:26:22 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 9 23:18:13 2017 +0100

man: add more examples to lvmraid(7)

Add examples for reshaping number of stripes
and converting from raid6 to striped to raid10.

Remove trailing spaces.

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 man/lvmraid.7.in |  250 ++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 241 insertions(+), 9 deletions(-)

diff --git a/man/lvmraid.7.in b/man/lvmraid.7.in
index 704c24a..79e6fe0 100644
--- a/man/lvmraid.7.in
+++ b/man/lvmraid.7.in
@@ -351,7 +351,7 @@ Also, if mismatches were found, the lvs attr field will display the letter
 .nf
 # lvs -o name,vgname,segtype,attr vg/lvol0
   LV    VG   Type  Attr
-  lvol0 vg   raid1 Rwi-a-r-m- 
+  lvol0 vg   raid1 Rwi-a-r-m-
 .fi
 
 
@@ -475,12 +475,12 @@ lvs -a -o name,segtype,devices
   lvr5            raid5  lvr5_rimage_0(0),\\
                          lvr5_rimage_1(0),\\
                          lvr5_rimage_2(0)
-  [lvr5_rimage_0] linear /dev/sda(...)                                     
-  [lvr5_rimage_1] linear /dev/sdb(...)                           
-  [lvr5_rimage_2] linear /dev/sdc(...)                                      
-  [lvr5_rmeta_0]  linear /dev/sda(...)                                     
-  [lvr5_rmeta_1]  linear /dev/sdb(...)                           
-  [lvr5_rmeta_2]  linear /dev/sdc(...)                                      
+  [lvr5_rimage_0] linear /dev/sda(...)
+  [lvr5_rimage_1] linear /dev/sdb(...)
+  [lvr5_rimage_2] linear /dev/sdc(...)
+  [lvr5_rmeta_0]  linear /dev/sda(...)
+  [lvr5_rmeta_1]  linear /dev/sdb(...)
+  [lvr5_rmeta_2]  linear /dev/sdc(...)
 .fi
 
 .B raid6
@@ -1031,7 +1031,7 @@ for out-of-place reshaping.  The result is:
 
 .nf
 # lvs -a -o lv_name,segtype,seg_pe_ranges,dataoffset
-  LV            Type     PE Ranges          Doff
+  LV            Type     PE Ranges          DOff
   lv            raid6_nr lv_rimage_0:0-32 \\
                          lv_rimage_1:0-32 \\
                          lv_rimage_2:0-32 \\
@@ -1051,6 +1051,238 @@ for out-of-place reshaping.  The result is:
 All segments with PE ranges '33-33' provide the out-of-place reshape space.
 The dataoffset column shows that the data was moved from initial offset 0 to
 2048 sectors on each component DataLV.
+
+If the RaidLV should be restriped for performance reasons,
+convert the 3-way striped raid6_nr LV to 5-way-striped.
+
+.nf
+# lvconvert --stripes 5 -y tb/lv
+  Using default stripesize 64.00 KiB.
+  WARNING: Adding stripes to active logical volume tb/lv will grow it from 99 to 165 extents!
+  Run "lvresize -l99 tb/lv" to shrink it or use the additional capacity.
+  Logical volume tb/lv successfully converted.
+
+# lvs
+  LV   VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
+  root fedora -wi-ao----  15.00g
+  swap fedora -wi-ao----   3.99g
+  lv   tb     rwi-a-r-s- 652.00m                                    52.94
+
+# lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
+  LV            Attr       Type     PE Ranges                                                                                                              DOff
+  lv            rwi-a-r--- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 lv_rimage_3:0-33 lv_rimage_4:0-33 lv_rimage_5:0-33 lv_rimage_6:0-33    0
+  [lv_rimage_0] iwi-aor--- linear   /dev/sda:0-32                                                                                                             0
+  [lv_rimage_0] iwi-aor--- linear   /dev/sda:34-34
+  [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:0-32                                                                                                            0
+  [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:34-34
+  [lv_rimage_2] iwi-aor--- linear   /dev/sdab:0-32                                                                                                            0
+  [lv_rimage_2] iwi-aor--- linear   /dev/sdab:34-34
+  [lv_rimage_3] iwi-aor--- linear   /dev/sdac:1-34                                                                                                            0
+  [lv_rimage_4] iwi-aor--- linear   /dev/sdad:1-34                                                                                                            0
+  [lv_rimage_5] iwi-aor--- linear   /dev/sdae:1-34                                                                                                            0
+  [lv_rimage_6] iwi-aor--- linear   /dev/sdaf:1-34                                                                                                            0
+  [lv_rmeta_0]  ewi-aor--- linear   /dev/sda:33-33
+  [lv_rmeta_1]  ewi-aor--- linear   /dev/sdaa:33-33
+  [lv_rmeta_2]  ewi-aor--- linear   /dev/sdab:33-33
+  [lv_rmeta_3]  ewi-aor--- linear   /dev/sdac:0-0
+  [lv_rmeta_4]  ewi-aor--- linear   /dev/sdad:0-0
+  [lv_rmeta_5]  ewi-aor--- linear   /dev/sdae:0-0
+  [lv_rmeta_6]  ewi-aor--- linear   /dev/sdaf:0-0
+.fi
+
+Convert the 5-way striped raid6_nr LV to 4-way-striped.
+The force option needs to be used, because removing stripes
+(i.e. image SubLVs) from a RaidLV will shrink its size.
+
+.nf
+# lvconvert --stripes 4 --force -y tb/lv
+  Using default stripesize 64.00 KiB.
+  WARNING: Removing stripes from active logical volume tb/lv will shrink it from 660.00 MiB to 528.00 MiB!
+  THIS MAY DESTROY (PARTS OF) YOUR DATA!
+  If that leaves the logical volume larger than 206 extents due to stripe rounding,
+  you may want to grow the content afterwards (filesystem etc.)
+  WARNING: too remove freed stripes after the conversion has finished, you have to run "lvconvert --stripes 4 tb/lv"
+  Logical volume tb/lv successfully converted.
+
+# lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
+  LV            Attr       Type     PE Ranges                                                                                                              DOff
+  lv            rwi-a-r-s- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 lv_rimage_3:0-33 lv_rimage_4:0-33 lv_rimage_5:0-33 lv_rimage_6:0-33    0
+  [lv_rimage_0] Iwi-aor--- linear   /dev/sda:0-32                                                                                                             0
+  [lv_rimage_0] Iwi-aor--- linear   /dev/sda:34-34
+  [lv_rimage_1] Iwi-aor--- linear   /dev/sdaa:0-32                                                                                                            0
+  [lv_rimage_1] Iwi-aor--- linear   /dev/sdaa:34-34
+  [lv_rimage_2] Iwi-aor--- linear   /dev/sdab:0-32                                                                                                            0
+  [lv_rimage_2] Iwi-aor--- linear   /dev/sdab:34-34
+  [lv_rimage_3] Iwi-aor--- linear   /dev/sdac:1-34                                                                                                            0
+  [lv_rimage_4] Iwi-aor--- linear   /dev/sdad:1-34                                                                                                            0
+  [lv_rimage_5] Iwi-aor--- linear   /dev/sdae:1-34                                                                                                            0
+  [lv_rimage_6] Iwi-aor-R- linear   /dev/sdaf:1-34                                                                                                            0
+  [lv_rmeta_0]  ewi-aor--- linear   /dev/sda:33-33
+  [lv_rmeta_1]  ewi-aor--- linear   /dev/sdaa:33-33
+  [lv_rmeta_2]  ewi-aor--- linear   /dev/sdab:33-33
+  [lv_rmeta_3]  ewi-aor--- linear   /dev/sdac:0-0
+  [lv_rmeta_4]  ewi-aor--- linear   /dev/sdad:0-0
+  [lv_rmeta_5]  ewi-aor--- linear   /dev/sdae:0-0
+  [lv_rmeta_6]  ewi-aor-R- linear   /dev/sdaf:0-0
+.fi
+
+The 's' in column 9 of the attribute field shows the RaidLV is still reshaping.
+The 'R' in the same column of the attribute field shows the freed image Sub LVs which will need removing once the reshaping finished.
+
+.nf
+# lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
+  LV   Attr       Type     PE Ranges                                                                                                              DOff
+  lv   rwi-a-r-R- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 lv_rimage_3:0-33 lv_rimage_4:0-33 lv_rimage_5:0-33 lv_rimage_6:0-33 8192
+.fi
+
+Now that the reshape is finished the 'R' atribute on the RaidLV shows images can be removed.
+
+.nf
+# lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
+  LV   Attr       Type     PE Ranges                                                                                                              DOff
+  lv   rwi-a-r-R- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 lv_rimage_3:0-33 lv_rimage_4:0-33 lv_rimage_5:0-33 lv_rimage_6:0-33 8192
+.fi
+
+This is achieved by repeating the command ("lvconvert --stripes 4 tb/lv" would be sufficient).
+
+.nf
+# lvconvert --stripes 4 --force -y tb/lv
+  Using default stripesize 64.00 KiB.
+  Logical volume tb/lv successfully converted.
+
+# lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
+  LV            Attr       Type     PE Ranges                                                                                             DOff
+  lv            rwi-a-r--- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 lv_rimage_3:0-33 lv_rimage_4:0-33 lv_rimage_5:0-33 8192
+  [lv_rimage_0] iwi-aor--- linear   /dev/sda:0-32                                                                                         8192
+  [lv_rimage_0] iwi-aor--- linear   /dev/sda:34-34
+  [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:0-32                                                                                        8192
+  [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:34-34
+  [lv_rimage_2] iwi-aor--- linear   /dev/sdab:0-32                                                                                        8192
+  [lv_rimage_2] iwi-aor--- linear   /dev/sdab:34-34
+  [lv_rimage_3] iwi-aor--- linear   /dev/sdac:1-34                                                                                        8192
+  [lv_rimage_4] iwi-aor--- linear   /dev/sdad:1-34                                                                                        8192
+  [lv_rimage_5] iwi-aor--- linear   /dev/sdae:1-34                                                                                        8192
+  [lv_rmeta_0]  ewi-aor--- linear   /dev/sda:33-33
+  [lv_rmeta_1]  ewi-aor--- linear   /dev/sdaa:33-33
+  [lv_rmeta_2]  ewi-aor--- linear   /dev/sdab:33-33
+  [lv_rmeta_3]  ewi-aor--- linear   /dev/sdac:0-0
+  [lv_rmeta_4]  ewi-aor--- linear   /dev/sdad:0-0
+  [lv_rmeta_5]  ewi-aor--- linear   /dev/sdae:0-0
+
+# lvs -a -o lv_name,attr,segtype,reshapelen tb
+  LV            Attr       Type     RSize
+  lv            rwi-a-r--- raid6_nr 24.00m
+  [lv_rimage_0] iwi-aor--- linear    4.00m
+  [lv_rimage_0] iwi-aor--- linear
+  [lv_rimage_1] iwi-aor--- linear    4.00m
+  [lv_rimage_1] iwi-aor--- linear
+  [lv_rimage_2] iwi-aor--- linear    4.00m
+  [lv_rimage_2] iwi-aor--- linear
+  [lv_rimage_3] iwi-aor--- linear    4.00m
+  [lv_rimage_4] iwi-aor--- linear    4.00m
+  [lv_rimage_5] iwi-aor--- linear    4.00m
+  [lv_rmeta_0]  ewi-aor--- linear
+  [lv_rmeta_1]  ewi-aor--- linear
+  [lv_rmeta_2]  ewi-aor--- linear
+  [lv_rmeta_3]  ewi-aor--- linear
+  [lv_rmeta_4]  ewi-aor--- linear
+  [lv_rmeta_5]  ewi-aor--- linear
+.fi
+
+If the reshape space shall be removed any lvconvert command not changing the layout can be used:
+
+.nf
+# lvconvert --stripes 4 tb/lv
+  Using default stripesize 64.00 KiB.
+  No change in RAID LV tb/lv layout, freeing reshape space.
+  Logical volume tb/lv successfully converted.
+
+# lvs -a -o lv_name,attr,segtype,reshapelen tb
+  LV            Attr       Type     RSize
+  lv            rwi-a-r--- raid6_nr    0
+  [lv_rimage_0] iwi-aor--- linear      0
+  [lv_rimage_0] iwi-aor--- linear
+  [lv_rimage_1] iwi-aor--- linear      0
+  [lv_rimage_1] iwi-aor--- linear
+  [lv_rimage_2] iwi-aor--- linear      0
+  [lv_rimage_2] iwi-aor--- linear
+  [lv_rimage_3] iwi-aor--- linear      0
+  [lv_rimage_4] iwi-aor--- linear      0
+  [lv_rimage_5] iwi-aor--- linear      0
+  [lv_rmeta_0]  ewi-aor--- linear
+  [lv_rmeta_1]  ewi-aor--- linear
+  [lv_rmeta_2]  ewi-aor--- linear
+  [lv_rmeta_3]  ewi-aor--- linear
+  [lv_rmeta_4]  ewi-aor--- linear
+  [lv_rmeta_5]  ewi-aor--- linear
+.fi
+
+In case the RaidLV should be converted to striped:
+
+.nf
+# lvconvert --type striped tb/lv
+  Unable to convert LV tb/lv from raid6_nr to striped.
+  Converting tb/lv from raid6_nr is directly possible to the following layouts:
+    raid6_nc
+    raid6_zr
+    raid6_la_6
+    raid6_ls_6
+    raid6_ra_6
+    raid6_rs_6
+    raid6_n_6
+
+# lvconvert --type raid6_n_6
+  Using default stripesize 64.00 KiB.
+  Converting raid6_nr LV tb/lv to raid6_n_6.
+Are you sure you want to convert raid6_nr LV tb/lv? [y/n]: y
+  Logical volume tb/lv successfully converted.
+
+# lvconvert -y --type striped tb/lv
+  Logical volume tb/lv successfully converted.
+
+[root at vm46 ~]# lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
+  LV   Attr       Type    PE Ranges                                                      DOff
+  lv   -wi-a----- striped /dev/sda:2-32 /dev/sdaa:2-32 /dev/sdab:2-32 /dev/sdac:3-33
+  lv   -wi-a----- striped /dev/sda:34-35 /dev/sdaa:34-35 /dev/sdab:34-35 /dev/sdac:34-35
+.fi
+
+From striped we can convert to raid10
+
+.nf
+# lvconvert -y --type raid10 tb/lv
+  Using default stripesize 64.00 KiB.
+  Logical volume tb/lv successfully converted.
+
+# lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
+  LV   Attr       Type   PE Ranges                                                                                                                               DOff
+  lv   rwi-a-r--- raid10 lv_rimage_0:0-32 lv_rimage_4:0-32 lv_rimage_1:0-32 lv_rimage_5:0-32 lv_rimage_2:0-32 lv_rimage_6:0-32 lv_rimage_3:0-32 lv_rimage_7:0-32    0
+
+# lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
+  WARNING: Cannot find matching striped segment for tb/lv_rimage_3.
+  LV            Attr       Type   PE Ranges                                                                                                                               DOff
+  lv            rwi-a-r--- raid10 lv_rimage_0:0-32 lv_rimage_4:0-32 lv_rimage_1:0-32 lv_rimage_5:0-32 lv_rimage_2:0-32 lv_rimage_6:0-32 lv_rimage_3:0-32 lv_rimage_7:0-32    0
+  [lv_rimage_0] iwi-aor--- linear /dev/sda:2-32                                                                                                                              0
+  [lv_rimage_0] iwi-aor--- linear /dev/sda:34-35
+  [lv_rimage_1] iwi-aor--- linear /dev/sdaa:2-32                                                                                                                             0
+  [lv_rimage_1] iwi-aor--- linear /dev/sdaa:34-35
+  [lv_rimage_2] iwi-aor--- linear /dev/sdab:2-32                                                                                                                             0
+  [lv_rimage_2] iwi-aor--- linear /dev/sdab:34-35
+  [lv_rimage_3] iwi-XXr--- linear /dev/sdac:3-35                                                                                                                             0
+  [lv_rimage_4] iwi-aor--- linear /dev/sdad:1-33                                                                                                                             0
+  [lv_rimage_5] iwi-aor--- linear /dev/sdae:1-33                                                                                                                             0
+  [lv_rimage_6] iwi-aor--- linear /dev/sdaf:1-33                                                                                                                             0
+  [lv_rimage_7] iwi-aor--- linear /dev/sdag:1-33                                                                                                                             0
+  [lv_rmeta_0]  ewi-aor--- linear /dev/sda:0-0
+  [lv_rmeta_1]  ewi-aor--- linear /dev/sdaa:0-0
+  [lv_rmeta_2]  ewi-aor--- linear /dev/sdab:0-0
+  [lv_rmeta_3]  ewi-aor--- linear /dev/sdac:0-0
+  [lv_rmeta_4]  ewi-aor--- linear /dev/sdad:0-0
+  [lv_rmeta_5]  ewi-aor--- linear /dev/sdae:0-0
+  [lv_rmeta_6]  ewi-aor--- linear /dev/sdaf:0-0
+  [lv_rmeta_7]  ewi-aor--- linear /dev/sdag:0-0
+.fi
+
+raid10 allows to add stripes but can't remove them.
 ..
 
 .SH RAID5 Variants
@@ -1243,7 +1475,7 @@ The command to start duplication is:
 .B \-\-duplicate
 .br
 Specifies that the LV conversion should be done out\-of\-place, copying
-LV data to new devices while converting. 
+LV data to new devices while converting.
 
 .HP
 .BR \-\-type , \-\-stripes , \-\-stripesize


