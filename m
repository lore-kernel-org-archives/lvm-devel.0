From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 12 Apr 2017 19:30:49 -0400
Subject: master - make generate
Message-ID: <201704122330.v3CNUnt5008394@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5ac230095c72c578cb76996b5b8ae687d04e98a9
Commit:        5ac230095c72c578cb76996b5b8ae687d04e98a9
Parent:        a3e8354479f2b6c3d35fdc992d4114b244326833
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 13 00:30:05 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 13 00:30:05 2017 +0100

make generate

---
 conf/example.conf.in        |   28 +++++++++------
 man/lvchange.8_pregen       |   48 +++++++++++++++++++++----
 man/lvconvert.8_pregen      |   81 +++++++++++++++++++++++-------------------
 man/lvcreate.8_pregen       |   15 ++++----
 man/lvdisplay.8_pregen      |   13 -------
 man/lvm-fullreport.8_pregen |   13 -------
 man/lvs.8_pregen            |   13 -------
 man/lvscan.8_pregen         |   13 -------
 man/pvs.8_pregen            |   13 -------
 man/vgcfgbackup.8_pregen    |   13 -------
 man/vgchange.8_pregen       |   16 ++++----
 man/vgdisplay.8_pregen      |   13 -------
 man/vgs.8_pregen            |   13 -------
 man/vgscan.8_pregen         |   13 -------
 14 files changed, 116 insertions(+), 189 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 614ce53..78f11d1 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -389,6 +389,17 @@ allocation {
 	# Cache pool metadata and data will always use different PVs.
 	cache_pool_metadata_require_separate_pvs = 0
 
+	# Configuration option allocation/cache_metadata_format.
+	# Sets default metadata format for new cache.
+	# 
+	# Accepted values:
+	#   0  Automatically detected best available format
+	#   1  Original format
+	#   2  Improved 2nd. generation format
+	# 
+	# This configuration option has an automatic default value.
+	# cache_metadata_format = 0
+
 	# Configuration option allocation/cache_mode.
 	# The default cache mode used for new cache.
 	# 
@@ -403,17 +414,6 @@ allocation {
 	# This configuration option has an automatic default value.
 	# cache_mode = "writethrough"
 
-	# Configuration option allocation/cache_metadata_format.
-	# Sets default metadata format for new cache.
-	# 
-	# Accepted values:
-	#   0  Automatically detected best available format
-	#   1  Original format
-	#   2  Improved 2nd. generation format
-	# 
-	# This configuration option has an automatic default value.
-	# cache_metadata_format = 0
-
 	# Configuration option allocation/cache_policy.
 	# The default cache policy used for new cache volume.
 	# Since kernel 4.2 the default policy is smq (Stochastic multiqueue),
@@ -1069,6 +1069,12 @@ global {
 	# This configuration option has an automatic default value.
 	# cache_repair_options = [ "" ]
 
+	# Configuration option global/fsadm_executable.
+	# The full path to the fsadm command.
+	# LVM uses this command to help with lvresize -r operations.
+	# This configuration option has an automatic default value.
+	# fsadm_executable = "@FSADM_PATH@"
+
 	# Configuration option global/system_id_source.
 	# The method LVM uses to set the local system ID.
 	# Volume Groups can also be given a system ID (by vgcreate, vgchange,
diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index 199e4cc..174ad32 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -323,6 +323,14 @@ required, after which the others are optional.
 [ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
 .ad b
 .br
+.ad l
+[    \fB--poll\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -384,6 +392,14 @@ Activate or deactivate an LV.
 .ad b
 .br
 .ad l
+[    \fB--poll\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [    \fB--ignorelockingfailure\fP ]
 .ad b
 .br
@@ -407,9 +423,17 @@ Reactivate an LV using the latest metadata.
 .ad b
 .br
 .ad l
+[    \fB--activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP ]
+.ad b
+.br
+.ad l
 [    \fB--poll\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -421,10 +445,6 @@ Start or stop monitoring an LV from dmeventd.
 \fBlvchange\fP \fB--monitor\fP \fBy\fP|\fBn\fP \fIVG\fP|\fILV\fP|\fITag\fP|\fISelect\fP ...
 .br
 .RS 4
-.ad l
-[    \fB--poll\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -455,6 +475,18 @@ Make the minor device number persistent for an LV.
 [ \fB-j\fP|\fB--major\fP \fINumber\fP ]
 .ad b
 .br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[    \fB--poll\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -840,10 +872,10 @@ ignore the devices LVM creates.
 .ad l
 \fB-P\fP|\fB--partial\fP
 .br
-When set, the tools will do their best to provide access to VGs
-that are only partially available (one or more PVs belonging
-to the VG are missing from the system). Metadata may not be
-changed with this option.
+Commands will do their best to activate LVs with missing PV extents.
+Missing extents may be replaced with error or zero segments
+according to the lvm.conf missing_stripe_filler setting.
+Metadata may not be changed with this option.
 .ad b
 .HP
 .ad l
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index e56b6de..3652303 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -243,6 +243,17 @@ To display the current LV type, run the command:
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
@@ -256,48 +267,44 @@ type is deprecated and the
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
-
-The striped raid types combined with raid1 allow for conversion from linear -> striped/raid0/raid0_meta
-and vice-versa by e.g. linear <-> raid1 <-> raid5_n (then adding stripes) <-> striped/raid0/raid0_meta.
-
-Sub LVs can be displayed with the command
-.B lvs -a
+blocks. The parity blocks can be used for data block recovery in case
+devices fail. A maximum number of one device in a raid5 LV may fail, and
+two in case of raid6. Striped raid types typically rotate the parity and
+data blocks for performance reasons, thus avoiding contention on a single
+device. Specific arrangements of parity and data blocks (layouts) can be
+used to optimize I/O performance, or to convert between raid levels.  See
+\fBlvmraid\fP(7) for more information.
+
+Layouts of raid5 rotating parity blocks can be: left-asymmetric
+(raid5_la), left-symmetric (raid5_ls with alias raid5), right-asymmetric
+(raid5_ra), right-symmetric (raid5_rs) and raid5_n, which doesn't rotate
+parity blocks. Layouts of raid6 are: zero-restart (raid6_zr with alias
+raid6), next-restart (raid6_nr), and next-continue (raid6_nc).
+
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
 .SH USAGE
 Convert LV to linear.
 .br
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index 6663087..38edc85 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -244,9 +244,9 @@ lvcreate - Create a logical volume
 .SH DESCRIPTION
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
@@ -263,7 +263,7 @@ unique PVs be available in the VG for allocation.
 Thin pools (for thin provisioning) and cache pools (for caching) are
 represented by special LVs with types thin-pool and cache-pool (see
 \fBlvmthin\fP(7) and \fBlvmcache\fP(7)). The pool LVs are not usable as
-standard block devices, but the LV names act references to the pools.
+standard block devices, but the LV names act as references to the pools.
 
 Thin LVs are thinly provisioned from a thin pool, and are created with a
 virtual size rather than a physical size. A cache LV is the combination of
@@ -271,13 +271,12 @@ a standard LV with a cache pool, used to cache active portions of the LV
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
 .SH USAGE
 Create a linear LV.
 .br
diff --git a/man/lvdisplay.8_pregen b/man/lvdisplay.8_pregen
index 25ce5b8..49de9cf 100644
--- a/man/lvdisplay.8_pregen
+++ b/man/lvdisplay.8_pregen
@@ -48,10 +48,6 @@ and more, using a more compact and configurable output format.
 .ad b
 .br
 .ad l
-[ \fB-P\fP|\fB--partial\fP ]
-.ad b
-.br
-.ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
 .ad b
 .br
@@ -343,15 +339,6 @@ See lvmreport(7) for more information about reporting.
 .ad b
 .HP
 .ad l
-\fB-P\fP|\fB--partial\fP
-.br
-When set, the tools will do their best to provide access to VGs
-that are only partially available (one or more PVs belonging
-to the VG are missing from the system). Metadata may not be
-changed with this option.
-.ad b
-.HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/lvm-fullreport.8_pregen b/man/lvm-fullreport.8_pregen
index bfc5cd3..11ba4b8 100644
--- a/man/lvm-fullreport.8_pregen
+++ b/man/lvm-fullreport.8_pregen
@@ -29,10 +29,6 @@ if information changes between commands.
 .ad b
 .br
 .ad l
-[ \fB-P\fP|\fB--partial\fP ]
-.ad b
-.br
-.ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
 .ad b
 .br
@@ -325,15 +321,6 @@ See lvmreport(7) for more information about reporting.
 .ad b
 .HP
 .ad l
-\fB-P\fP|\fB--partial\fP
-.br
-When set, the tools will do their best to provide access to VGs
-that are only partially available (one or more PVs belonging
-to the VG are missing from the system). Metadata may not be
-changed with this option.
-.ad b
-.HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index 2ac6f3f..31244e2 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -28,10 +28,6 @@ lvs produces formatted output about LVs.
 .ad b
 .br
 .ad l
-[ \fB-P\fP|\fB--partial\fP ]
-.ad b
-.br
-.ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
 .ad b
 .br
@@ -339,15 +335,6 @@ See lvmreport(7) for more information about reporting.
 .ad b
 .HP
 .ad l
-\fB-P\fP|\fB--partial\fP
-.br
-When set, the tools will do their best to provide access to VGs
-that are only partially available (one or more PVs belonging
-to the VG are missing from the system). Metadata may not be
-changed with this option.
-.ad b
-.HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/lvscan.8_pregen b/man/lvscan.8_pregen
index a2c32a0..12211b2 100644
--- a/man/lvscan.8_pregen
+++ b/man/lvscan.8_pregen
@@ -45,10 +45,6 @@ Common options for command:
 .ad b
 .br
 .ad l
-[ \fB-P\fP|\fB--partial\fP ]
-.ad b
-.br
-.ad l
 [    \fB--ignorelockingfailure\fP ]
 .ad b
 .br
@@ -184,15 +180,6 @@ Display long help text.
 .ad b
 .HP
 .ad l
-\fB-P\fP|\fB--partial\fP
-.br
-When set, the tools will do their best to provide access to VGs
-that are only partially available (one or more PVs belonging
-to the VG are missing from the system). Metadata may not be
-changed with this option.
-.ad b
-.HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/pvs.8_pregen b/man/pvs.8_pregen
index d6afbb9..d0742df 100644
--- a/man/pvs.8_pregen
+++ b/man/pvs.8_pregen
@@ -24,10 +24,6 @@ pvs produces formatted output about PVs.
 .ad b
 .br
 .ad l
-[ \fB-P\fP|\fB--partial\fP ]
-.ad b
-.br
-.ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
 .ad b
 .br
@@ -326,15 +322,6 @@ See lvmreport(7) for more information about reporting.
 .ad b
 .HP
 .ad l
-\fB-P\fP|\fB--partial\fP
-.br
-When set, the tools will do their best to provide access to VGs
-that are only partially available (one or more PVs belonging
-to the VG are missing from the system). Metadata may not be
-changed with this option.
-.ad b
-.HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/vgcfgbackup.8_pregen b/man/vgcfgbackup.8_pregen
index b3f41af..d085a34 100644
--- a/man/vgcfgbackup.8_pregen
+++ b/man/vgcfgbackup.8_pregen
@@ -35,10 +35,6 @@ It may also be useful to regularly back up the files in
 .ad b
 .br
 .ad l
-[ \fB-P\fP|\fB--partial\fP ]
-.ad b
-.br
-.ad l
 [    \fB--foreign\fP ]
 .ad b
 .br
@@ -179,15 +175,6 @@ Display long help text.
 .ad b
 .HP
 .ad l
-\fB-P\fP|\fB--partial\fP
-.br
-When set, the tools will do their best to provide access to VGs
-that are only partially available (one or more PVs belonging
-to the VG are missing from the system). Metadata may not be
-changed with this option.
-.ad b
-.HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index df5c946..d3514b9 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -270,6 +270,10 @@ required, after which the others are optional.
 .RE
 .br
 .RS 4
+.ad l
+[    \fB--poll\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -379,10 +383,6 @@ Reactivate LVs using the latest metadata.
 .ad b
 .br
 .ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [    \fB--poll\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -761,10 +761,10 @@ ignore the devices LVM creates.
 .ad l
 \fB-P\fP|\fB--partial\fP
 .br
-When set, the tools will do their best to provide access to VGs
-that are only partially available (one or more PVs belonging
-to the VG are missing from the system). Metadata may not be
-changed with this option.
+Commands will do their best to activate LVs with missing PV extents.
+Missing extents may be replaced with error or zero segments
+according to the lvm.conf missing_stripe_filler setting.
+Metadata may not be changed with this option.
 .ad b
 .HP
 .ad l
diff --git a/man/vgdisplay.8_pregen b/man/vgdisplay.8_pregen
index 2aa9188..a9a9463 100644
--- a/man/vgdisplay.8_pregen
+++ b/man/vgdisplay.8_pregen
@@ -35,10 +35,6 @@ and more, using a more compact and configurable output format.
 .ad b
 .br
 .ad l
-[ \fB-P\fP|\fB--partial\fP ]
-.ad b
-.br
-.ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
 .ad b
 .br
@@ -317,15 +313,6 @@ See lvmreport(7) for more information about reporting.
 .ad b
 .HP
 .ad l
-\fB-P\fP|\fB--partial\fP
-.br
-When set, the tools will do their best to provide access to VGs
-that are only partially available (one or more PVs belonging
-to the VG are missing from the system). Metadata may not be
-changed with this option.
-.ad b
-.HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/vgs.8_pregen b/man/vgs.8_pregen
index 012697c..b621666 100644
--- a/man/vgs.8_pregen
+++ b/man/vgs.8_pregen
@@ -24,10 +24,6 @@ vgs produces formatted output about VGs.
 .ad b
 .br
 .ad l
-[ \fB-P\fP|\fB--partial\fP ]
-.ad b
-.br
-.ad l
 [ \fB-S\fP|\fB--select\fP \fIString\fP ]
 .ad b
 .br
@@ -321,15 +317,6 @@ See lvmreport(7) for more information about reporting.
 .ad b
 .HP
 .ad l
-\fB-P\fP|\fB--partial\fP
-.br
-When set, the tools will do their best to provide access to VGs
-that are only partially available (one or more PVs belonging
-to the VG are missing from the system). Metadata may not be
-changed with this option.
-.ad b
-.HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/vgscan.8_pregen b/man/vgscan.8_pregen
index 011747c..df36e3a 100644
--- a/man/vgscan.8_pregen
+++ b/man/vgscan.8_pregen
@@ -14,10 +14,6 @@ vgscan scans all supported LVM block devices in the system for VGs.
 .br
 .RS 4
 .ad l
-[ \fB-P\fP|\fB--partial\fP ]
-.ad b
-.br
-.ad l
 [    \fB--cache\fP ]
 .ad b
 .br
@@ -165,15 +161,6 @@ notify_dbus config setting is disabled.
 .ad b
 .HP
 .ad l
-\fB-P\fP|\fB--partial\fP
-.br
-When set, the tools will do their best to provide access to VGs
-that are only partially available (one or more PVs belonging
-to the VG are missing from the system). Metadata may not be
-changed with this option.
-.ad b
-.HP
-.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending


