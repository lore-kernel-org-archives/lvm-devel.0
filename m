From: David Teigland <teigland@fedoraproject.org>
Date: Tue,  6 Sep 2016 20:21:04 +0000 (UTC)
Subject: master - man lvmraid: comment out unfinished features
Message-ID: <20160906202104.3371A60571@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e1f4fc22d215ed557262a948877c8914a7b94ad1
Commit:        e1f4fc22d215ed557262a948877c8914a7b94ad1
Parent:        ff3f5fa1796f4c55b102ae01e93567030ca8d533
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 6 15:13:59 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 6 15:13:59 2016 -0500

man lvmraid: comment out unfinished features

---
 man/lvmraid.7.in |   42 ++++++++++++++++++++++++++----------------
 1 files changed, 26 insertions(+), 16 deletions(-)

diff --git a/man/lvmraid.7.in b/man/lvmraid.7.in
index 5c49def..b9ad255 100644
--- a/man/lvmraid.7.in
+++ b/man/lvmraid.7.in
@@ -906,7 +906,21 @@ between striped and raid4.
   [lv_rmeta_1]  linear   3.00m
 .fi
 
-3. Converting an LV from \fBstriped\fP (with 4 stripes) to \fBraid6_nc\fP.
+3. Converting an LV from \fBlinear\fP to \fBraid1\fP (with 3 images).
+
+.nf
+Start with a linear LV:
+
+# lvcreate -L1G -n my_lv vg
+
+Convert the linear LV to raid1 with three images
+(original linear image plus 2 mirror images):
+
+# lvconvert --type raid1 --mirrors 2 vg/my_lv
+.fi
+
+.ig
+4. Converting an LV from \fBstriped\fP (with 4 stripes) to \fBraid6_nc\fP.
 
 .nf
 Start with a striped LV:
@@ -940,19 +954,7 @@ existing stripe devices.  It then creates 2 additional MetaLV/DataLV pairs
 
 If rotating data/parity is required, such as with raid6_nr, it must be
 done by reshaping (see below).
-
-4. Converting an LV from \fBlinear\fP to \fBraid1\fP (with 3 images).
-
-.nf
-Start with a linear LV:
-
-# lvcreate -L1G -n my_lv vg
-
-Convert the linear LV to raid1 with three images
-(original linear image plus 2 mirror images):
-
-# lvconvert --type raid1 --mirrors 2 vg/my_lv
-.fi
+..
 
 
 .SH RAID Reshaping
@@ -973,6 +975,9 @@ partially updated and corrupted.  Instead, an existing stripe is quiesced,
 read, changed in layout, and the new stripe written to free space.  Once
 that is done, the new stripe is unquiesced and used.)
 
+(The reshaping features are planned for a future release.)
+
+.ig
 .SS Examples
 
 1. Converting raid6_n_6 to raid6_nr with rotating data/parity.
@@ -1052,7 +1057,7 @@ FIXME: include -o devices or seg_pe_ranges above also?
 All segments with PE ranges '33-33' provide the out-of-place reshape space.
 The dataoffset column shows that the data was moved from initial offset 0 to
 2048 sectors on each component DataLV.
-
+..
 
 .SH RAID5 Variants
 
@@ -1088,6 +1093,7 @@ RAID5 right asymmetric
 \[bu]
 Rotating parity 0 with data continuation
 
+.ig
 raid5_n
 .br
 \[bu]
@@ -1099,6 +1105,7 @@ Same layout as raid4 with a dedicated parity N with striped data.
 \[bu]
 Used for
 .B RAID Takeover
+..
 
 .SH RAID6 Variants
 
@@ -1137,6 +1144,7 @@ RAID6 N continue
 \[bu]
 Rotating parity N with data continuation
 
+.ig
 raid6_n_6
 .br
 \[bu]
@@ -1196,9 +1204,10 @@ Same as raid5_ra for N-1 disks with fixed Q-Syndrome N
 \[bu]
 Used for
 .B RAID Takeover
+..
 
 
-
+.ig
 .SH RAID Duplication
 
 RAID LV conversion (takeover or reshaping) can be done out\-of\-place by
@@ -1294,6 +1303,7 @@ FIXME: include how splitmirrors can be used.
 .SH RAID1E
 
 TODO
+..
 
 .SH History
 


