From: David Teigland <teigland@sourceware.org>
Date: Tue, 11 Apr 2017 11:22:12 -0400
Subject: master - man lvcreate/lvconvert: minor clean up rewording
Message-ID: <201704111522.v3BFMCfH029574@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=21da004e58cdd406d5de0d67f27686373d7d2bfe
Commit:        21da004e58cdd406d5de0d67f27686373d7d2bfe
Parent:        a4f07b701a009aba2ceca7fdb4ef880505ad54c3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 10 16:29:40 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 11 10:21:36 2017 -0500

man lvcreate/lvconvert: minor clean up rewording

---
 man/lvconvert.8_des |   81 +++++++++++++++++++++++++++-----------------------
 man/lvcreate.8_des  |   15 ++++-----
 2 files changed, 51 insertions(+), 45 deletions(-)

diff --git a/man/lvconvert.8_des b/man/lvconvert.8_des
index dc51aae..6fd1ed9 100644
--- a/man/lvconvert.8_des
+++ b/man/lvconvert.8_des
@@ -7,6 +7,17 @@ To display the current LV type, run the command:
 .B lvs -o name,segtype
 .I LV
 
+In some cases, an LV is a single device mapper (dm) layer above physical
+devices.  In other cases, hidden LVs (dm devices) are layered between the
+visible LV and physical devices.  LVs in the middle layers are called sub LVs.
+A command run on a visible LV sometimes operates on a sub LV rather than
+the specified LV.  In other cases, a sub LV must be specified directly on
+the command line.
+
+Sub LVs can be displayed with the command:
+
+.B lvs -a
+
 The
 .B linear
 type is equivalent to the
@@ -20,45 +31,41 @@ type is deprecated and the
 .B raid1
 type should be used.  They are both implementations of mirroring.
 
-In some cases, an LV is a single device mapper (dm) layer above physical
-devices.  In other cases, hidden LVs (dm devices) are layered between the
-visible LV and physical devices.  LVs in the middle layers are called sub LVs.
-A command run on a visible LV sometimes operates on a sub LV rather than
-the specified LV.  In other cases, a sub LV must be specified directly on
-the command line.
-
 Striped raid types are
-.B raid0/raid0_meta
-,
-.B raid5
-(an alias for raid5_ls),
-.B raid6
-(an alias for raid6_zr) and
-.B raid10
-(an alias for raid10_near).
+\fBraid0/raid0_meta\fP,
+\fBraid5\fP (an alias for raid5_ls),
+\fBraid6\fP (an alias for raid6_zr) and
+\fBraid10\fP (an alias for raid10_near).
 
 As opposed to mirroring, raid5 and raid6 stripe data and calculate parity
-blocks. The parity blocks can be used for data block recovery in case devices
-fail. A maximum number of one device in a raid5 LV may fail  and two in case
-of raid6. Striped raid types typically rotate the parity blocks for performance
-reasons thus avoiding contention on a single device.  Layouts of raid5 rotating
-parity blocks can be one of left-asymmetric (raid5_la), left-symmetric (raid5_ls
-with alias raid5), right-asymmetric (raid5_ra), right-symmetric (raid5_rs) and raid5_n,
-which doesn't rotate parity blocks.  Any \"_n\" layouts allow for conversion between
-raid levels (raid5_n -> raid6 or raid5_n -> striped/raid0/raid0_meta).
-raid6 layouts are zero-restart (raid6_zr with alias raid6), next-restart (raid6_nr),
-next-continue (raid6_nc). Additionally, special raid6 layouts for raid level conversions
-between raid5 and raid6 are raid6_ls_6, raid6_rs_6, raid6_la_6 and raid6_ra_6. Those
-correspond to their raid5 counterparts (e.g. raid5_rs can be directly converted to raid6_rs_6
-and vice-versa).
-raid10 (an alias for raid10_near) is currently limited to one data copy and even number of
-sub LVs. This is a mirror group layout thus a single sub LV may fail per mirror group
-without data loss.
-Striped raid types support converting the layout, their stripesize
-and their number of stripes.
+blocks. The parity blocks can be used for data block recovery in case
+devices fail. A maximum number of one device in a raid5 LV may fail, and
+two in case of raid6. Striped raid types typically rotate the parity and
+data blocks for performance reasons, thus avoiding contention on a single
+device. Specific arrangements of parity and data blocks (layouts) can be
+used to optimize I/O performance, or to convert between raid levels.  See
+\fBlvmraid\fP(7) for more information.
 
-The striped raid types combined with raid1 allow for conversion from linear -> striped/raid0/raid0_meta
-and vice-versa by e.g. linear <-> raid1 <-> raid5_n (then adding stripes) <-> striped/raid0/raid0_meta.
+Layouts of raid5 rotating parity blocks can be: left-asymmetric
+(raid5_la), left-symmetric (raid5_ls with alias raid5), right-asymmetric
+(raid5_ra), right-symmetric (raid5_rs) and raid5_n, which doesn't rotate
+parity blocks. Layouts of raid6 are: zero-restart (raid6_zr with alias
+raid6), next-restart (raid6_nr), and next-continue (raid6_nc).
 
-Sub LVs can be displayed with the command
-.B lvs -a
+Layouts including _n allow for conversion between raid levels (raid5_n to
+raid6 or raid5_n to striped/raid0/raid0_meta). Additionally, special raid6
+layouts for raid level conversions between raid5 and raid6 are:
+raid6_ls_6, raid6_rs_6, raid6_la_6 and raid6_ra_6. Those correspond to
+their raid5 counterparts (e.g. raid5_rs can be directly converted to
+raid6_rs_6 and vice-versa).
+
+raid10 (an alias for raid10_near) is currently limited to one data copy
+and even number of sub LVs. This is a mirror group layout, thus a single
+sub LV may fail per mirror group without data loss.
+
+Striped raid types support converting the layout, their stripesize and
+their number of stripes.
+
+The striped raid types combined with raid1 allow for conversion from
+linear -> striped/raid0/raid0_meta and vice-versa by e.g. linear <-> raid1
+<-> raid5_n (then adding stripes) <-> striped/raid0/raid0_meta.
diff --git a/man/lvcreate.8_des b/man/lvcreate.8_des
index 42f4213..589bd63 100644
--- a/man/lvcreate.8_des
+++ b/man/lvcreate.8_des
@@ -1,8 +1,8 @@
 lvcreate creates a new LV in a VG. For standard LVs, this requires
 allocating logical extents from the VG's free physical extents. If there
-is not enough free space, then the VG can be extended (see
-\fBvgextend\fP(8)) with other PVs, or existing LVs can be reduced or
-removed (see \fBlvremove\fP, \fBlvreduce\fP.)
+is not enough free space, the VG can be extended with other PVs
+(\fBvgextend\fP(8)), or existing LVs can be reduced or removed
+(\fBlvremove\fP(8), \fBlvreduce\fP(8).)
 
 To control which PVs a new LV will use, specify one or more PVs as
 position args at the end of the command line. lvcreate will allocate
@@ -19,7 +19,7 @@ unique PVs be available in the VG for allocation.
 Thin pools (for thin provisioning) and cache pools (for caching) are
 represented by special LVs with types thin-pool and cache-pool (see
 \fBlvmthin\fP(7) and \fBlvmcache\fP(7)). The pool LVs are not usable as
-standard block devices, but the LV names act references to the pools.
+standard block devices, but the LV names act as references to the pools.
 
 Thin LVs are thinly provisioned from a thin pool, and are created with a
 virtual size rather than a physical size. A cache LV is the combination of
@@ -27,10 +27,9 @@ a standard LV with a cache pool, used to cache active portions of the LV
 to improve performance.
 .SS Usage notes
 In the usage section below, \fB--size\fP \fISize\fP can be replaced
-with \fB--extents\fP \fINumber\fP.  See both descriptions
-the options section.
+with \fB--extents\fP \fINumber\fP. See descriptions in the options section.
 
 In the usage section below, \fB--name\fP is omitted from the required
-options, even though it is typically used.  When the name is not
+options, even though it is typically used. When the name is not
 specified, a new LV name is generated with the "lvol" prefix and a unique
-numeric suffix.  Also see the description in the options section.
+numeric suffix.


