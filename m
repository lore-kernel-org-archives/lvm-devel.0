From: David Teigland <teigland@sourceware.org>
Date: Thu, 18 May 2017 17:49:07 -0400
Subject: master - man lvmraid: indirect conversions
Message-ID: <201705182149.v4ILn7dq026151@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a29e7843b1b9fe10af0e5bef8304c65a176e394f
Commit:        a29e7843b1b9fe10af0e5bef8304c65a176e394f
Parent:        2bf01c2f3797d52f1ace72e32028912337918223
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 18 16:47:37 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 18 16:47:37 2017 -0500

man lvmraid: indirect conversions

Start documenting multi-step conversions.

Don't number examples.
---
 man/lvmraid.7_main |   81 +++++++++++++++++++++++++--------------------------
 1 files changed, 40 insertions(+), 41 deletions(-)

diff --git a/man/lvmraid.7_main b/man/lvmraid.7_main
index f0d28f5..6e0287a 100644
--- a/man/lvmraid.7_main
+++ b/man/lvmraid.7_main
@@ -896,7 +896,7 @@ between linear and raid1.
 .IP \(bu 3
 between mirror and raid1.
 .IP \(bu 3
-between 2-legged raid1 and raid4/5.
+between raid1 with two images and raid4/5.
 .IP \(bu 3
 between striped/raid0 and raid4.
 .IP \(bu 3
@@ -912,39 +912,46 @@ between striped/raid0 and raid10.
 .IP \(bu 3
 between striped and raid4.
 
-.SS Examples
+.SS Indirect conversions
 
-1. Converting an LV from \fBlinear\fP to \fBraid1\fP.
+Converting from one raid level to another may require multiple steps,
+converting first to intermediate raid levels.
 
-.nf
-# lvs -a -o name,segtype,size vg
-  LV   Type   LSize
-  lv   linear 300.00g
+.B linear to raid6
 
-# lvconvert --type raid1 --mirrors 1 vg/lv
+To convert an LV from linear to raid6:
+.br
+1. convert to raid1 with two images
+.br
+2. convert to raid5 (internally raid5_ls) with two images
+.br
+3. convert to raid5 with three or more stripes (reshape)
+.br
+4. convert to raid6 (internally raid6_ls_6)
+.br
+5. convert to raid6 (internally raid6_zr, reshape)
 
-# lvs -a -o name,segtype,size vg
-  LV            Type   LSize
-  lv            raid1  300.00g
-  [lv_rimage_0] linear 300.00g
-  [lv_rimage_1] linear 300.00g
-  [lv_rmeta_0]  linear   3.00m
-  [lv_rmeta_1]  linear   3.00m
-.fi
+The commands to perform the steps above are:
+.br
+1. lvconvert --type raid1 --mirrors 1 LV
+.br
+2. lvconvert --type raid5 LV
+.br
+3. lvconvert --stripes 3 LV
+.br
+4. lvconvert --type raid6 LV
+.br
+5. lvconvert --type raid6 LV
 
-2. Converting an LV from \fBmirror\fP to \fBraid1\fP.
+The final conversion from raid6_ls_6 to raid6_zr is done to avoid the
+potential write/recovery performance reduction in raid6_ls_6 because of
+the dedicated parity device.  raid6_zr rotates data and parity blocks to
+avoid this.
 
-.nf
-# lvs -a -o name,segtype,size vg
-  LV            Type   LSize
-  lv            mirror 100.00g
-  [lv_mimage_0] linear 100.00g
-  [lv_mimage_1] linear 100.00g
-  [lv_mlog]     linear   3.00m
 
 .SS Examples
 
-1. Converting an LV from \fBlinear\fP to \fBraid1\fP.
+Converting an LV from \fBlinear\fP to \fBraid1\fP.
 
 .nf
 # lvs -a -o name,segtype,size vg
@@ -962,7 +969,7 @@ between striped and raid4.
   [lv_rmeta_1]  linear   3.00m
 .fi
 
-2. Converting an LV from \fBmirror\fP to \fBraid1\fP.
+Converting an LV from \fBmirror\fP to \fBraid1\fP.
 
 .nf
 # lvs -a -o name,segtype,size vg
@@ -983,28 +990,17 @@ between striped and raid4.
   [lv_rmeta_1]  linear   3.00m
 .fi
 
-3. Converting an LV from \fBlinear\fP to \fBraid1\fP (with 3 images).
+Converting an LV from \fBlinear\fP to \fBraid1\fP (with 3 images).
 
 .nf
-Start with a linear LV:
-
-# lvcreate -L1G -n lv vg
-
-Convert the linear LV to raid1 with three images
-(original linear image plus 2 mirror images):
-
 # lvconvert --type raid1 --mirrors 2 vg/lv
 .fi
 
-4. Converting an LV from \fBstriped\fP (with 4 stripes) to \fBraid6_n_6\fP.
+Converting an LV from \fBstriped\fP (with 4 stripes) to \fBraid6_n_6\fP.
 
 .nf
-Start with a striped LV:
-
 # lvcreate --stripes 4 -L64M -n lv vg
 
-Convert the striped LV to raid6_n_6:
-
 # lvconvert --type raid6 vg/lv
 
 # lvs -a -o lv_name,segtype,sync_percent,data_copies
@@ -1051,7 +1047,9 @@ that is done, the new stripe is unquiesced and used.)
 
 .SS Examples
 
-1. Converting raid6_n_6 to raid6_nr with rotating data/parity.
+(Command output shown in examples may change.)
+
+Converting raid6_n_6 to raid6_nr with rotating data/parity.
 
 This conversion naturally follows a previous conversion from striped/raid0
 to raid6_n_6 (shown above).  It completes the transition to a more
@@ -1318,7 +1316,8 @@ In case the RaidLV should be converted to striped:
 .nf
 # lvconvert --type striped vg/lv
   Unable to convert LV vg/lv from raid6_nr to striped.
-  Converting vg/lv from raid6_nr is directly possible to the following layouts:
+  Converting vg/lv from raid6_nr is directly possible to the \
+  following layouts:
     raid6_nc
     raid6_zr
     raid6_la_6


