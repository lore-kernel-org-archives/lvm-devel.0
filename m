From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 2 Mar 2017 16:24:44 -0500
Subject: master - man: cover reshaping
Message-ID: <201703022124.v22LOi1M001187@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=af7c8e7106632899925c26fff3be37a2de0c8a35
Commit:        af7c8e7106632899925c26fff3be37a2de0c8a35
Parent:        ca859b5149ad21adad9be03e8df794a496b746bb
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 2 22:24:19 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 2 22:24:19 2017 +0100

man: cover reshaping

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 man/lvconvert.8.des |   33 +++++++++++++++++++
 man/lvmraid.7.in    |   87 +++++++++++++++++++++++++++------------------------
 2 files changed, 79 insertions(+), 41 deletions(-)

diff --git a/man/lvconvert.8.des b/man/lvconvert.8.des
index 2aa95a1..0548c2c 100644
--- a/man/lvconvert.8.des
+++ b/man/lvconvert.8.des
@@ -27,6 +27,39 @@ A command run on a visible LV sometimes operates on a sub LV rather than
 the specified LV.  In other cases, a sub LV must be specified directly on
 the command line.
 
+Striped raid types are
+.B raid0/raid0_meta
+,
+.B raid5
+(an alias for raid5_ls),
+.B raid6
+(an alias for raid6_zr) and
+.B raid10
+(an alias for raid10_near).
+
+As opposed to mirroring, raid5 and raid6 stripe data and calculate parity
+blocks. The parity blocks can be used for data block recovery in case devices
+fail. A maximum number of one device in a raid5 LV may fail  and two in case
+of raid6. Striped raid types typically rotate the parity blocks for performance
+reasons thus avoiding contention on a single device.  Layouts of raid5 rotating
+parity blocks can be one of left-asymmetric (raid5_la), left-symmetric (raid5_ls
+with alias raid5), right-asymmetric (raid5_ra), right-symmetric (raid5_rs) and raid5_n,
+which doesn't rotate parity blocks.  Any \"_n\" layouts allow for conversion between
+raid levels (raid5_n -> raid6 or raid5_n -> striped/raid0/raid0_meta).
+raid6 layouts are zero-restart (raid6_zr with alias raid6), next-restart (raid6_nr),
+next-continue (raid6_nc). Additionally, special raid6 layouts for raid level conversions
+between raid5 and raid6 are raid6_ls_6, raid6_rs_6, raid6_la_6 and raid6_ra_6. Those
+correspond to their raid5 counterparts (e.g. raid5_rs can be directly converted to raid6_rs_6
+and vice-versa).
+raid10 (an alias for raid10_near) is currently limited to one data copy and even number of
+sub LVs. This is a mirror group layout thus a single sub LV may fail per mirror group
+without data loss.
+Striped raid types support converting the layout, their stripesize
+and their number of stripes.
+
+The striped raid types combined with raid1 allow for conversion from linear -> striped/raid0/raid0_meta
+and vice-versa by e.g. linear <-> raid1 <-> raid5_n (then adding stripes) <-> striped/raid0/raid0_meta.
+
 Sub LVs can be displayed with the command
 .B lvs -a
 
diff --git a/man/lvmraid.7.in b/man/lvmraid.7.in
index b9ad255..e0657b8 100644
--- a/man/lvmraid.7.in
+++ b/man/lvmraid.7.in
@@ -19,6 +19,11 @@ LVM RAID uses both Device Mapper (DM) and Multiple Device (MD) drivers
 from the Linux kernel.  DM is used to create and manage visible LVM
 devices, and MD is used to place data on physical devices.
 
+LVM creates hidden LVs (dm devices) layered between the visible LV and
+physical devices.  LVs in that middle layers are called sub LVs.
+For LVM raid, a sub LV pair to store data and metadata (raid superblock
+and bitmap) is created per raid leg (see lvs command examples below).
+
 .SH Create a RAID LV
 
 To create a RAID LV, use lvcreate and specify an LV type.
@@ -77,7 +82,7 @@ data that is written to one device before moving to the next.
 
 Also called mirroring, raid1 uses multiple devices to duplicate LV data.
 The LV data remains available if all but one of the devices fail.
-The minimum number of devices required is 2.
+The minimum number of devices (i.e. sub LV pairs) required is 2.
 
 .B lvcreate \-\-type raid1
 [\fB\-\-mirrors\fP \fINumber\fP]
@@ -98,8 +103,8 @@ original and one mirror image.
 
 \&
 
-raid4 is a form of striping that uses an extra device dedicated to storing
-parity blocks.  The LV data remains available if one device fails.  The
+raid4 is a form of striping that uses an extra, first device dedicated to
+storing parity blocks.  The LV data remains available if one device fails.  The
 parity is used to recalculate data that is lost from a single device.  The
 minimum number of devices required is 3.
 
@@ -131,10 +136,10 @@ stored on the same device.
 \&
 
 raid5 is a form of striping that uses an extra device for storing parity
-blocks.  LV data and parity blocks are stored on each device.  The LV data
-remains available if one device fails.  The parity is used to recalculate
-data that is lost from a single device.  The minimum number of devices
-required is 3.
+blocks.  LV data and parity blocks are stored on each device, typically in
+a rotating pattern for performance reasons.  The LV data remains available
+if one device fails.  The parity is used to recalculate data that is lost
+from a single device.  The minimum number of devices required is 3.
 
 .B lvcreate \-\-type raid5
 [\fB\-\-stripes\fP \fINumber\fP \fB\-\-stripesize\fP \fISize\fP]
@@ -167,7 +172,8 @@ parity 0 with data restart.)  See \fBRAID5 variants\fP below.
 \&
 
 raid6 is a form of striping like raid5, but uses two extra devices for
-parity blocks.  LV data and parity blocks are stored on each device.  The
+parity blocks.  LV data and parity blocks are stored on each device, typically
+in a rotating pattern for perfomramce reasons.  The
 LV data remains available if up to two devices fail.  The parity is used
 to recalculate data that is lost from one or two devices.  The minimum
 number of devices required is 5.
@@ -919,7 +925,6 @@ Convert the linear LV to raid1 with three images
 # lvconvert --type raid1 --mirrors 2 vg/my_lv
 .fi
 
-.ig
 4. Converting an LV from \fBstriped\fP (with 4 stripes) to \fBraid6_nc\fP.
 
 .nf
@@ -927,9 +932,9 @@ Start with a striped LV:
 
 # lvcreate --stripes 4 -L64M -n my_lv vg
 
-Convert the striped LV to raid6_nc:
+Convert the striped LV to raid6_n_6:
 
-# lvconvert --type raid6_nc vg/my_lv
+# lvconvert --type raid6 vg/my_lv
 
 # lvs -a -o lv_name,segtype,sync_percent,data_copies
   LV               Type      Cpy%Sync #Cpy
@@ -954,14 +959,12 @@ existing stripe devices.  It then creates 2 additional MetaLV/DataLV pairs
 
 If rotating data/parity is required, such as with raid6_nr, it must be
 done by reshaping (see below).
-..
 
 
 .SH RAID Reshaping
 
 RAID reshaping is changing attributes of a RAID LV while keeping the same
-RAID level, i.e. changes that do not involve changing the number of
-devices.  This includes changing RAID layout, stripe size, or number of
+RAID level.  This includes changing RAID layout, stripe size, or number of
 stripes.
 
 When changing the RAID layout or stripe size, no new SubLVs (MetaLVs or
@@ -975,15 +978,12 @@ partially updated and corrupted.  Instead, an existing stripe is quiesced,
 read, changed in layout, and the new stripe written to free space.  Once
 that is done, the new stripe is unquiesced and used.)
 
-(The reshaping features are planned for a future release.)
-
-.ig
 .SS Examples
 
 1. Converting raid6_n_6 to raid6_nr with rotating data/parity.
 
-This conversion naturally follows a previous conversion from striped to
-raid6_n_6 (shown above).  It completes the transition to a more
+This conversion naturally follows a previous conversion from striped/raid0
+to raid6_n_6 (shown above).  It completes the transition to a more
 traditional RAID6.
 
 .nf
@@ -1029,15 +1029,13 @@ traditional RAID6.
 The DataLVs are larger (additional segment in each) which provides space
 for out-of-place reshaping.  The result is:
 
-FIXME: did the lv name change from my_lv to r?
-.br
 FIXME: should we change device names in the example to sda,sdb,sdc?
 .br
 FIXME: include -o devices or seg_pe_ranges above also?
 
 .nf
 # lvs -a -o lv_name,segtype,seg_pe_ranges,dataoffset
-  LV           Type     PE Ranges          data
+  LV           Type     PE Ranges          Doff
   r            raid6_nr r_rimage_0:0-32 \\
                         r_rimage_1:0-32 \\
                         r_rimage_2:0-32 \\
@@ -1093,19 +1091,15 @@ RAID5 right asymmetric
 \[bu]
 Rotating parity 0 with data continuation
 
-.ig
 raid5_n
 .br
 \[bu]
-RAID5 striping
+RAID5 parity n
 .br
 \[bu]
-Same layout as raid4 with a dedicated parity N with striped data.
-.br
+Dedicated parity device n used for striped/raid0 conversions
 \[bu]
-Used for
-.B RAID Takeover
-..
+Used for RAID Takeover
 
 .SH RAID6 Variants
 
@@ -1144,7 +1138,24 @@ RAID6 N continue
 \[bu]
 Rotating parity N with data continuation
 
-.ig
+raid6_n_6
+.br
+\[bu]
+RAID6 last parity devices
+.br
+\[bu]
+Dedicated last parity devices used for striped/raid0 conversions
+\[bu]
+Used for RAID Takeover
+
+raid6_{ls,rs,la,ra}_6
+.br
+\[bu]
+RAID6 last parity device
+.br
+\[bu]
+Dedicated last parity device used for conversions from/to raid5_{ls,rs,la,ra}
+
 raid6_n_6
 .br
 \[bu]
@@ -1154,8 +1165,7 @@ RAID6 N continue
 Fixed P-Syndrome N-1 and Q-Syndrome N with striped data
 .br
 \[bu]
-Used for
-.B RAID Takeover
+Used for RAID Takeover
 
 raid6_ls_6
 .br
@@ -1166,8 +1176,7 @@ RAID6 N continue
 Same as raid5_ls for N-1 disks with fixed Q-Syndrome N
 .br
 \[bu]
-Used for
-.B RAID Takeover
+Used for RAID Takeover
 
 raid6_la_6
 .br
@@ -1178,8 +1187,7 @@ RAID6 N continue
 Same as raid5_la for N-1 disks with fixed Q-Syndrome N
 .br
 \[bu]
-Used for
-.B RAID Takeover
+Used forRAID Takeover
 
 raid6_rs_6
 .br
@@ -1190,8 +1198,7 @@ RAID6 N continue
 Same as raid5_rs for N-1 disks with fixed Q-Syndrome N
 .br
 \[bu]
-Used for
-.B RAID Takeover
+Used for RAID Takeover
 
 raid6_ra_6
 .br
@@ -1202,9 +1209,7 @@ RAID6 N continue
 Same as raid5_ra for N-1 disks with fixed Q-Syndrome N
 .br
 \[bu]
-Used for
-.B RAID Takeover
-..
+Used for RAID Takeover
 
 
 .ig


