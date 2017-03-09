From: David Teigland <teigland@sourceware.org>
Date: Thu, 9 Mar 2017 12:49:07 -0500
Subject: master - man lvmraid: remove fixmes, use consistent example name
Message-ID: <201703091749.v29Hn7Uc007907@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fab088cbc79211966f654245299347261fd5cb9f
Commit:        fab088cbc79211966f654245299347261fd5cb9f
Parent:        716c3453343009536daf459f10761bd6f322e221
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 9 11:48:30 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 9 11:48:30 2017 -0600

man lvmraid: remove fixmes, use consistent example name

---
 man/lvmraid.7.in |  138 ++++++++++++++++++++++++++----------------------------
 1 files changed, 67 insertions(+), 71 deletions(-)

diff --git a/man/lvmraid.7.in b/man/lvmraid.7.in
index 832242c..704c24a 100644
--- a/man/lvmraid.7.in
+++ b/man/lvmraid.7.in
@@ -917,12 +917,12 @@ between striped and raid4.
 .nf
 Start with a linear LV:
 
-# lvcreate -L1G -n my_lv vg
+# lvcreate -L1G -n lv vg
 
 Convert the linear LV to raid1 with three images
 (original linear image plus 2 mirror images):
 
-# lvconvert --type raid1 --mirrors 2 vg/my_lv
+# lvconvert --type raid1 --mirrors 2 vg/lv
 .fi
 
 4. Converting an LV from \fBstriped\fP (with 4 stripes) to \fBraid6_nc\fP.
@@ -930,27 +930,27 @@ Convert the linear LV to raid1 with three images
 .nf
 Start with a striped LV:
 
-# lvcreate --stripes 4 -L64M -n my_lv vg
+# lvcreate --stripes 4 -L64M -n lv vg
 
 Convert the striped LV to raid6_n_6:
 
-# lvconvert --type raid6 vg/my_lv
+# lvconvert --type raid6 vg/lv
 
 # lvs -a -o lv_name,segtype,sync_percent,data_copies
-  LV               Type      Cpy%Sync #Cpy
-  my_lv            raid6_n_6 100.00      3
-  [my_lv_rimage_0] linear
-  [my_lv_rimage_1] linear
-  [my_lv_rimage_2] linear
-  [my_lv_rimage_3] linear
-  [my_lv_rimage_4] linear
-  [my_lv_rimage_5] linear
-  [my_lv_rmeta_0]  linear
-  [my_lv_rmeta_1]  linear
-  [my_lv_rmeta_2]  linear
-  [my_lv_rmeta_3]  linear
-  [my_lv_rmeta_4]  linear
-  [my_lv_rmeta_5]  linear
+  LV            Type      Cpy%Sync #Cpy
+  lv            raid6_n_6 100.00      3
+  [lv_rimage_0] linear
+  [lv_rimage_1] linear
+  [lv_rimage_2] linear
+  [lv_rimage_3] linear
+  [lv_rimage_4] linear
+  [lv_rimage_5] linear
+  [lv_rmeta_0]  linear
+  [lv_rmeta_1]  linear
+  [lv_rmeta_2]  linear
+  [lv_rmeta_3]  linear
+  [lv_rmeta_4]  linear
+  [lv_rmeta_5]  linear
 .fi
 
 This convert begins by allocating MetaLVs (rmeta_#) for each of the
@@ -988,68 +988,64 @@ traditional RAID6.
 
 .nf
 # lvs -o lv_name,segtype,sync_percent,data_copies
-  LV               Type      Cpy%Sync #Cpy
-  my_lv            raid6_n_6 100.00      3
-  [my_lv_rimage_0] linear
-  [my_lv_rimage_1] linear
-  [my_lv_rimage_2] linear
-  [my_lv_rimage_3] linear
-  [my_lv_rimage_4] linear
-  [my_lv_rimage_5] linear
-  [my_lv_rmeta_0]  linear
-  [my_lv_rmeta_1]  linear
-  [my_lv_rmeta_2]  linear
-  [my_lv_rmeta_3]  linear
-  [my_lv_rmeta_4]  linear
-  [my_lv_rmeta_5]  linear
-
-# lvconvert --type raid6_nr vg/my_lv
+  LV            Type      Cpy%Sync #Cpy
+  lv            raid6_n_6 100.00      3
+  [lv_rimage_0] linear
+  [lv_rimage_1] linear
+  [lv_rimage_2] linear
+  [lv_rimage_3] linear
+  [lv_rimage_4] linear
+  [lv_rimage_5] linear
+  [lv_rmeta_0]  linear
+  [lv_rmeta_1]  linear
+  [lv_rmeta_2]  linear
+  [lv_rmeta_3]  linear
+  [lv_rmeta_4]  linear
+  [lv_rmeta_5]  linear
+
+# lvconvert --type raid6_nr vg/lv
 
 # lvs -a -o lv_name,segtype,sync_percent,data_copies
-  LV               Type     Cpy%Sync #Cpy
-  my_lv            raid6_nr 100.00      3
-  [my_lv_rimage_0] linear
-  [my_lv_rimage_0] linear
-  [my_lv_rimage_1] linear
-  [my_lv_rimage_1] linear
-  [my_lv_rimage_2] linear
-  [my_lv_rimage_2] linear
-  [my_lv_rimage_3] linear
-  [my_lv_rimage_3] linear
-  [my_lv_rimage_4] linear
-  [my_lv_rimage_5] linear
-  [my_lv_rmeta_0]  linear
-  [my_lv_rmeta_1]  linear
-  [my_lv_rmeta_2]  linear
-  [my_lv_rmeta_3]  linear
-  [my_lv_rmeta_4]  linear
-  [my_lv_rmeta_5]  linear
+  LV            Type     Cpy%Sync #Cpy
+  lv            raid6_nr 100.00      3
+  [lv_rimage_0] linear
+  [lv_rimage_0] linear
+  [lv_rimage_1] linear
+  [lv_rimage_1] linear
+  [lv_rimage_2] linear
+  [lv_rimage_2] linear
+  [lv_rimage_3] linear
+  [lv_rimage_3] linear
+  [lv_rimage_4] linear
+  [lv_rimage_5] linear
+  [lv_rmeta_0]  linear
+  [lv_rmeta_1]  linear
+  [lv_rmeta_2]  linear
+  [lv_rmeta_3]  linear
+  [lv_rmeta_4]  linear
+  [lv_rmeta_5]  linear
 .fi
 
 The DataLVs are larger (additional segment in each) which provides space
 for out-of-place reshaping.  The result is:
 
-FIXME: should we change device names in the example to sda,sdb,sdc?
-.br
-FIXME: include -o devices or seg_pe_ranges above also?
-
 .nf
 # lvs -a -o lv_name,segtype,seg_pe_ranges,dataoffset
-  LV           Type     PE Ranges          Doff
-  r            raid6_nr r_rimage_0:0-32 \\
-                        r_rimage_1:0-32 \\
-                        r_rimage_2:0-32 \\
-                        r_rimage_3:0-32
-  [r_rimage_0] linear   /dev/sda:0-31      2048
-  [r_rimage_0] linear   /dev/sda:33-33
-  [r_rimage_1] linear   /dev/sdaa:0-31     2048
-  [r_rimage_1] linear   /dev/sdaa:33-33
-  [r_rimage_2] linear   /dev/sdab:1-33     2048
-  [r_rimage_3] linear   /dev/sdac:1-33     2048
-  [r_rmeta_0]  linear   /dev/sda:32-32
-  [r_rmeta_1]  linear   /dev/sdaa:32-32
-  [r_rmeta_2]  linear   /dev/sdab:0-0
-  [r_rmeta_3]  linear   /dev/sdac:0-0
+  LV            Type     PE Ranges          Doff
+  lv            raid6_nr lv_rimage_0:0-32 \\
+                         lv_rimage_1:0-32 \\
+                         lv_rimage_2:0-32 \\
+                         lv_rimage_3:0-32
+  [lv_rimage_0] linear   /dev/sda:0-31      2048
+  [lv_rimage_0] linear   /dev/sda:33-33
+  [lv_rimage_1] linear   /dev/sdaa:0-31     2048
+  [lv_rimage_1] linear   /dev/sdaa:33-33
+  [lv_rimage_2] linear   /dev/sdab:1-33     2048
+  [lv_rimage_3] linear   /dev/sdac:1-33     2048
+  [lv_rmeta_0]  linear   /dev/sda:32-32
+  [lv_rmeta_1]  linear   /dev/sdaa:32-32
+  [lv_rmeta_2]  linear   /dev/sdab:0-0
+  [lv_rmeta_3]  linear   /dev/sdac:0-0
 .fi
 
 All segments with PE ranges '33-33' provide the out-of-place reshape space.


