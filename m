From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Apr 2021 13:00:58 +0000 (GMT)
Subject: main - man: typography for raid and report
Message-ID: <20210419130058.AA4EA396903D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5f75f5e2bc0f10c74151914aa59264d29815d9ba
Commit:        5f75f5e2bc0f10c74151914aa59264d29815d9ba
Parent:        9164a393de449f285038811d58ade0fb3ecfba30
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 15 22:18:05 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 19 14:54:37 2021 +0200

man: typography for raid and report

Some enhancements for better man page rendering.
---
 man/lvmraid.7_main   | 1199 ++++++++++++++++++++++-----------------------
 man/lvmreport.7_main | 1312 ++++++++++++++++++++++++++------------------------
 2 files changed, 1252 insertions(+), 1259 deletions(-)

diff --git a/man/lvmraid.7_main b/man/lvmraid.7_main
index 2335f5dbe..26938da83 100644
--- a/man/lvmraid.7_main
+++ b/man/lvmraid.7_main
@@ -1,279 +1,303 @@
 .TH "LVMRAID" "7" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
-
+.
+.de ipbu
+.PD 0
+.IP "     \[bu]"
+.PD
+..
+.
+.de ipbu_npd
+.IP "     \[bu]"
+..
+.
 .SH NAME
+.
 lvmraid \(em LVM RAID
-
+.
 .SH DESCRIPTION
-
+.
 \fBlvm\fP(8) RAID is a way to create a Logical Volume (LV) that uses
 multiple physical devices to improve performance or tolerate device
 failures.  In LVM, the physical devices are Physical Volumes (PVs) in a
 single Volume Group (VG).
-
+.P
 How LV data blocks are placed onto PVs is determined by the RAID level.
 RAID levels are commonly referred to as 'raid' followed by a number, e.g.
 raid1, raid5 or raid6.  Selecting a RAID level involves making tradeoffs
 among: physical device requirements, fault tolerance, and performance.  A
 description of the RAID levels can be found at
 .br
-www.snia.org/sites/default/files/SNIA_DDF_Technical_Position_v2.0.pdf
-
+.I www.snia.org/sites/default/files/SNIA_DDF_Technical_Position_v2.0.pdf
+.P
 LVM RAID uses both Device Mapper (DM) and Multiple Device (MD) drivers
 from the Linux kernel.  DM is used to create and manage visible LVM
 devices, and MD is used to place data on physical devices.
-
+.P
 LVM creates hidden LVs (dm devices) layered between the visible LV and
 physical devices.  LVs in the middle layers are called sub LVs.
 For LVM raid, a sub LV pair to store data and metadata (raid superblock
 and write intent bitmap) is created per raid image/leg (see lvs command examples below).
-
-.SH Create a RAID LV
-
+.
+.SH USAGE
+.
 To create a RAID LV, use lvcreate and specify an LV type.
 The LV type corresponds to a RAID level.
 The basic RAID levels that can be used are:
-.B raid0, raid1, raid4, raid5, raid6, raid10.
-
+.BR raid0 ", " raid1 ", " raid4 ", " raid5 ", " raid6 ", " raid10 .
+.P
 .B lvcreate --type
 .I RaidLevel
-[\fIOPTIONS\fP]
+.RI [ OPTIONS ]
 .B --name
 .I Name
 .B --size
 .I Size
 .I VG
-[\fIPVs\fP]
-
+.RI [ PVs ]
+.P
 To display the LV type of an existing LV, run:
-
-.B lvs -o name,segtype
-\fILV\fP
-
+.P
+.B lvs -o name,segtype \fILV
+.P
 (The LV type is also referred to as "segment type" or "segtype".)
-
+.P
 LVs can be created with the following types:
-
+.
 .SS raid0
-
-\&
-
+.
 Also called striping, raid0 spreads LV data across multiple devices in
 units of stripe size.  This is used to increase performance.  LV data will
 be lost if any of the devices fail.
-
+.P
 .B lvcreate --type raid0
-[\fB--stripes\fP \fINumber\fP \fB--stripesize\fP \fISize\fP]
-\fIVG\fP
-[\fIPVs\fP]
-
-.HP
-.B --stripes
-specifies the number of devices to spread the LV across.
-
-.HP
+.RB [ --stripes
+.I Number
 .B --stripesize
-specifies the size of each stripe in kilobytes.  This is the amount of
+.IR Size ]
+.I VG
+.RI [ PVs ]
+.
+.TP
+.B --stripes \fINumber
+specifies the \fINumber\fP of devices to spread the LV across.
+.
+.TP
+.B --stripesize \fISize
+specifies the \fISize\fP of each stripe in kilobytes.  This is the amount of
 data that is written to one device before moving to the next.
 .P
-
 \fIPVs\fP specifies the devices to use.  If not specified, lvm will choose
 \fINumber\fP devices, one for each stripe based on the number of PVs
 available or supplied.
-
+.
 .SS raid1
-
-\&
-
+.
 Also called mirroring, raid1 uses multiple devices to duplicate LV data.
 The LV data remains available if all but one of the devices fail.
 The minimum number of devices (i.e. sub LV pairs) required is 2.
-
+.P
 .B lvcreate --type raid1
 [\fB--mirrors\fP \fINumber\fP]
 \fIVG\fP
 [\fIPVs\fP]
-
-.HP
-.B --mirrors
-specifies the number of mirror images in addition to the original LV
+.
+.TP
+.B --mirrors \fINumber
+specifies the \fINumber\fP of mirror images in addition to the original LV
 image, e.g. --mirrors 1 means there are two images of the data, the
 original and one mirror image.
 .P
-
 \fIPVs\fP specifies the devices to use.  If not specified, lvm will choose
 \fINumber\fP devices, one for each image.
-
+.
 .SS raid4
-
-\&
-
+.
 raid4 is a form of striping that uses an extra, first device dedicated to
 storing parity blocks.  The LV data remains available if one device fails.  The
 parity is used to recalculate data that is lost from a single device.  The
 minimum number of devices required is 3.
-
+.P
 .B lvcreate --type raid4
 [\fB--stripes\fP \fINumber\fP \fB--stripesize\fP \fISize\fP]
 \fIVG\fP
 [\fIPVs\fP]
-
-.HP
-.B --stripes
-specifies the number of devices to use for LV data.  This does not include
+.
+.TP
+.B --stripes \fINumber
+specifies the \fINumber\fP of devices to use for LV data.  This does not include
 the extra device lvm adds for storing parity blocks.  A raid4 LV with
 \fINumber\fP stripes requires \fINumber\fP+1 devices.  \fINumber\fP must
 be 2 or more.
-
-.HP
-.B --stripesize
-specifies the size of each stripe in kilobytes.  This is the amount of
+.
+.TP
+.B --stripesize \fISize
+specifies the \fISize\fP of each stripe in kilobytes.  This is the amount of
 data that is written to one device before moving to the next.
 .P
-
 \fIPVs\fP specifies the devices to use.  If not specified, lvm will choose
 \fINumber\fP+1 separate devices.
-
+.P
 raid4 is called non-rotating parity because the parity blocks are always
 stored on the same device.
-
+.
 .SS raid5
-
-\&
-
+.
 raid5 is a form of striping that uses an extra device for storing parity
 blocks.  LV data and parity blocks are stored on each device, typically in
 a rotating pattern for performance reasons.  The LV data remains available
 if one device fails.  The parity is used to recalculate data that is lost
 from a single device.  The minimum number of devices required is 3 (unless
 converting from 2 legged raid1 to reshape to more stripes; see reshaping).
-
+.P
 .B lvcreate --type raid5
 [\fB--stripes\fP \fINumber\fP \fB--stripesize\fP \fISize\fP]
 \fIVG\fP
 [\fIPVs\fP]
-
-.HP
-.B --stripes
-specifies the number of devices to use for LV data.  This does not include
+.
+.TP
+.B --stripes \fINumber
+specifies the \fINumber\fP of devices to use for LV data.  This does not include
 the extra device lvm adds for storing parity blocks.  A raid5 LV with
 \fINumber\fP stripes requires \fINumber\fP+1 devices.  \fINumber\fP must
 be 2 or more.
-
-.HP
-.B --stripesize
-specifies the size of each stripe in kilobytes.  This is the amount of
+.
+.TP
+.B --stripesize \fISize
+specifies the \fISize\fP of each stripe in kilobytes.  This is the amount of
 data that is written to one device before moving to the next.
 .P
-
 \fIPVs\fP specifies the devices to use.  If not specified, lvm will choose
 \fINumber\fP+1 separate devices.
-
+.P
 raid5 is called rotating parity because the parity blocks are placed on
 different devices in a round-robin sequence.  There are variations of
 raid5 with different algorithms for placing the parity blocks.  The
 default variant is raid5_ls (raid5 left symmetric, which is a rotating
-parity 0 with data restart.)  See \fBRAID5 variants\fP below.
-
+parity 0 with data restart.)  See \fBRAID5 VARIANTS\fP below.
+.
 .SS raid6
-
-\&
-
+.
 raid6 is a form of striping like raid5, but uses two extra devices for
 parity blocks.  LV data and parity blocks are stored on each device, typically
 in a rotating pattern for performance reasons.  The
 LV data remains available if up to two devices fail.  The parity is used
 to recalculate data that is lost from one or two devices.  The minimum
 number of devices required is 5.
-
+.P
 .B lvcreate --type raid6
 [\fB--stripes\fP \fINumber\fP \fB--stripesize\fP \fISize\fP]
 \fIVG\fP
 [\fIPVs\fP]
-
-.HP
-.B --stripes
-specifies the number of devices to use for LV data.  This does not include
+.
+.TP
+.B --stripes \fINumber
+specifies the \fINumber\fP of devices to use for LV data.  This does not include
 the extra two devices lvm adds for storing parity blocks.  A raid6 LV with
 \fINumber\fP stripes requires \fINumber\fP+2 devices.  \fINumber\fP must be
 3 or more.
-
-.HP
-.B --stripesize
-specifies the size of each stripe in kilobytes.  This is the amount of
+.
+.TP
+.B --stripesize \fISize
+specifies the \fISize\fP of each stripe in kilobytes.  This is the amount of
 data that is written to one device before moving to the next.
 .P
-
 \fIPVs\fP specifies the devices to use.  If not specified, lvm will choose
 \fINumber\fP+2 separate devices.
-
+.P
 Like raid5, there are variations of raid6 with different algorithms for
 placing the parity blocks.  The default variant is raid6_zr (raid6 zero
 restart, aka left symmetric, which is a rotating parity 0 with data
-restart.)  See \fBRAID6 variants\fP below.
-
+restart.)  See \fBRAID6 VARIANTS\fP below.
+.
 .SS raid10
-
-\&
-
+.
 raid10 is a combination of raid1 and raid0, striping data across mirrored
 devices.  LV data remains available if one or more devices remains in each
 mirror set.  The minimum number of devices required is 4.
-
+.TP
 .B lvcreate --type raid10
-.RS
 [\fB--mirrors\fP \fINumberMirrors\fP]
 .br
 [\fB--stripes\fP \fINumberStripes\fP \fB--stripesize\fP \fISize\fP]
 .br
 \fIVG\fP
 [\fIPVs\fP]
-.RE
-
-.HP
-.B --mirrors
+.
+.TP
+.B --mirrors \fINumberMirrors
 specifies the number of mirror images within each stripe.  e.g.
 --mirrors 1 means there are two images of the data, the original and one
 mirror image.
-
-.HP
-.B --stripes
+.
+.TP
+.B --stripes \fINumberStripes
 specifies the total number of devices to use in all raid1 images (not the
 number of raid1 devices to spread the LV across, even though that is the
 effective result).  The number of devices in each raid1 mirror will be
-NumberStripes/(NumberMirrors+1), e.g. mirrors 1 and stripes 4 will stripe
+\fINumberStripes\fP/(\fINumberMirrors\fP+1), e.g. mirrors 1 and stripes 4 will stripe
 data across two raid1 mirrors, where each mirror is devices.
-
-.HP
-.B --stripesize
-specifies the size of each stripe in kilobytes.  This is the amount of
+.
+.TP
+.B --stripesize \fISize
+specifies the \fISize\fP of each stripe in kilobytes.  This is the amount of
 data that is written to one device before moving to the next.
 .P
-
 \fIPVs\fP specifies the devices to use.  If not specified, lvm will choose
 the necessary devices.  Devices are used to create mirrors in the
 order listed, e.g. for mirrors 1, stripes 2, listing PV1 PV2 PV3 PV4
 results in mirrors PV1/PV2 and PV3/PV4.
-
+.P
 RAID10 is not mirroring on top of stripes, which would be RAID01, which is
 less tolerant of device failures.
-
-
-.SH Synchronization
-
+.
+.SS Configuration Options
+.
+There are a number of options in the LVM configuration file that affect
+the behavior of RAID LVs.  The tunable options are listed
+below.  A detailed description of each can be found in the LVM
+configuration file itself.
+.RS
+mirror_segtype_default
+.br
+raid10_segtype_default
+.br
+raid_region_size
+.br
+raid_fault_policy
+.br
+activation_mode
+.RE
+.
+.SS Monitoring
+.
+When a RAID LV is activated the \fBdmeventd\fP(8) process is started to
+monitor the health of the LV.  Various events detected in the kernel can
+cause a notification to be sent from device-mapper to the monitoring
+process, including device failures and synchronization completion (e.g.
+for initialization or scrubbing).
+.P
+The LVM configuration file contains options that affect how the monitoring
+process will respond to failure events (e.g. raid_fault_policy).  It is
+possible to turn on and off monitoring with lvchange, but it is not
+recommended to turn this off unless you have a thorough knowledge of the
+consequences.
+.
+.SS Synchronization
+.
 Synchronization is the process that makes all the devices in a RAID LV
 consistent with each other.
-
+.P
 In a RAID1 LV, all mirror images should have the same data.  When a new
 mirror image is added, or a mirror image is missing data, then images need
 to be synchronized.  Data blocks are copied from an existing image to a
 new or outdated image to make them match.
-
+.P
 In a RAID 4/5/6 LV, parity blocks and data blocks should match based on
 the parity calculation.  When the devices in a RAID LV change, the data
 and parity blocks can become inconsistent and need to be synchronized.
 Correct blocks are read, parity is calculated, and recalculated blocks are
 written.
-
+.P
 The RAID implementation keeps track of which parts of a RAID LV are
 synchronized.  When a RAID LV is first created and activated the first
 synchronization is called initialization.  A pointer stored in the raid
@@ -282,96 +306,86 @@ restarted after a deactivation of the RaidLV or a crash.  Any writes to
 the RaidLV dirties the respective region of the write intent bitmap which
 allow for fast recovery of the regions after a crash.  Without this, the
 entire LV would need to be synchronized every time it was activated.
-
+.P
 Automatic synchronization happens when a RAID LV is activated, but it is
 usually partial because the bitmaps reduce the areas that are checked.
 A full sync becomes necessary when devices in the RAID LV are replaced.
-
+.P
 The synchronization status of a RAID LV is reported by the
 following command, where "Cpy%Sync" = "100%" means sync is complete:
-
+.P
 .B lvs -a -o name,sync_percent
-
-
+.
 .SS Scrubbing
-
+.
 Scrubbing is a full scan of the RAID LV requested by a user.
 Scrubbing can find problems that are missed by partial synchronization.
-
+.P
 Scrubbing assumes that RAID metadata and bitmaps may be inaccurate, so it
 verifies all RAID metadata, LV data, and parity blocks.  Scrubbing can
 find inconsistencies caused by hardware errors or degradation.  These
 kinds of problems may be undetected by automatic synchronization which
 excludes areas outside of the RAID write-intent bitmap.
-
+.P
 The command to scrub a RAID LV can operate in two different modes:
-
+.P
 .B lvchange --syncaction
 .BR check | repair
 .I LV
-
-.HP
+.
+.TP
 .B check
 Check mode is read-only and only detects inconsistent areas in the RAID
 LV, it does not correct them.
-
-.HP
+.
+.TP
 .B repair
 Repair mode checks and writes corrected blocks to synchronize any
 inconsistent areas.
-
 .P
-
 Scrubbing can consume a lot of bandwidth and slow down application I/O on
 the RAID LV.  To control the I/O rate used for scrubbing, use:
-
-.HP
-.B --maxrecoveryrate
-\fISize\fP[k|UNIT]
-.br
+.
+.TP
+.BR --maxrecoveryrate " " \fISize [k|UNIT]
 Sets the maximum recovery rate for a RAID LV.  \fISize\fP is specified as
 an amount per second for each device in the array.  If no suffix is given,
 then KiB/sec/device is used.  Setting the recovery rate to \fB0\fP
 means it will be unbounded.
-
-.HP
-.BR --minrecoveryrate
-\fISize\fP[k|UNIT]
-.br
+.
+.TP
+.BR --minrecoveryrate " " \fISize [k|UNIT]
 Sets the minimum recovery rate for a RAID LV.  \fISize\fP is specified as
 an amount per second for each device in the array.  If no suffix is given,
 then KiB/sec/device is used.  Setting the recovery rate to \fB0\fP
 means it will be unbounded.
-
 .P
-
 To display the current scrubbing in progress on an LV, including
 the syncaction mode and percent complete, run:
-
+.P
 .B lvs -a -o name,raid_sync_action,sync_percent
-
+.P
 After scrubbing is complete, to display the number of inconsistent blocks
 found, run:
-
+.P
 .B lvs -o name,raid_mismatch_count
-
+.P
 Also, if mismatches were found, the lvs attr field will display the letter
 "m" (mismatch) in the 9th position, e.g.
-
+.P
 .nf
 # lvs -o name,vgname,segtype,attr vg/lv
   LV VG   Type  Attr
   lv vg   raid1 Rwi-a-r-m-
 .fi
-
-
+.
 .SS Scrubbing Limitations
-
+.
 The \fBcheck\fP mode can only report the number of inconsistent blocks, it
 cannot report which blocks are inconsistent.  This makes it impossible to
 know which device has errors, or if the errors affect file system data,
 metadata or nothing at all.
-
+.P
 The \fBrepair\fP mode can make the RAID LV data consistent, but it does
 not know which data is correct.  The result may be consistent but
 incorrect data.  When two different blocks of data must be made
@@ -379,72 +393,72 @@ consistent, it chooses the block from the device that would be used during
 RAID initialization.  However, if the PV holding corrupt data is known,
 lvchange --rebuild can be used in place of scrubbing to reconstruct the
 data on the bad device.
-
+.P
 Future developments might include:
-
+.P
 Allowing a user to choose the correct version of data during repair.
-
+.P
 Using a majority of devices to determine the correct version of data to
 use in a 3-way RAID1 or RAID6 LV.
-
+.P
 Using a checksumming device to pin-point when and where an error occurs,
 allowing it to be rewritten.
-
-
-.SH SubLVs
-
+.
+.SS SubLVs
+.
 An LV is often a combination of other hidden LVs called SubLVs.  The
 SubLVs either use physical devices, or are built from other SubLVs
 themselves.  SubLVs hold LV data blocks, RAID parity blocks, and RAID
 metadata.  SubLVs are generally hidden, so the lvs -a option is required
 to display them:
-
+.P
 .B lvs -a -o name,segtype,devices
-
+.P
 SubLV names begin with the visible LV name, and have an automatic suffix
 indicating its role:
-
-.IP \(bu 3
+.
+.ipbu_npd
 SubLVs holding LV data or parity blocks have the suffix _rimage_#.
+.br
 These SubLVs are sometimes referred to as DataLVs.
-
-.IP \(bu 3
+.
+.ipbu_npd
 SubLVs holding RAID metadata have the suffix _rmeta_#.  RAID metadata
 includes superblock information, RAID type, bitmap, and device health
-information.  These SubLVs are sometimes referred to as MetaLVs.
-
+information.
+.br
+These SubLVs are sometimes referred to as MetaLVs.
 .P
-
 SubLVs are an internal implementation detail of LVM.  The way they are
 used, constructed and named may change.
-
+.P
 The following examples show the SubLV arrangement for each of the basic
 RAID LV types, using the fewest number of devices allowed for each.
-
-.SS Examples
-
+.P
+.I Examples
+.P
 .B raid0
 .br
 Each rimage SubLV holds a portion of LV data.  No parity is used.
 No RAID metadata is used.
-
+.P
 .nf
 # lvcreate --type raid0 --stripes 2 --name lvr0 ...
-
+.P
 # lvs -a -o name,segtype,devices
   lvr0            raid0  lvr0_rimage_0(0),lvr0_rimage_1(0)
   [lvr0_rimage_0] linear /dev/sda(...)
   [lvr0_rimage_1] linear /dev/sdb(...)
 .fi
-
+.P
 .B raid1
 .br
 Each rimage SubLV holds a complete copy of LV data.  No parity is used.
 Each rmeta SubLV holds RAID metadata.
-
+.P
 .nf
 # lvcreate --type raid1 --mirrors 1 --name lvr1 ...
-
+.P
 # lvs -a -o name,segtype,devices
   lvr1            raid1  lvr1_rimage_0(0),lvr1_rimage_1(0)
   [lvr1_rimage_0] linear /dev/sda(...)
@@ -452,15 +466,15 @@ Each rmeta SubLV holds RAID metadata.
   [lvr1_rmeta_0]  linear /dev/sda(...)
   [lvr1_rmeta_1]  linear /dev/sdb(...)
 .fi
-
+.P
 .B raid4
 .br
 At least three rimage SubLVs each hold a portion of LV data and one rimage SubLV
 holds parity.  Each rmeta SubLV holds RAID metadata.
-
+.P
 .nf
 # lvcreate --type raid4 --stripes 2 --name lvr4 ...
-
+.P
 # lvs -a -o name,segtype,devices
   lvr4            raid4  lvr4_rimage_0(0),\\
                          lvr4_rimage_1(0),\\
@@ -472,16 +486,16 @@ holds parity.  Each rmeta SubLV holds RAID metadata.
   [lvr4_rmeta_1]  linear /dev/sdb(...)
   [lvr4_rmeta_2]  linear /dev/sdc(...)
 .fi
-
+.P
 .B raid5
 .br
 At least three rimage SubLVs each typically hold a portion of LV data and parity
 (see section on raid5)
 Each rmeta SubLV holds RAID metadata.
-
+.P
 .nf
 # lvcreate --type raid5 --stripes 2 --name lvr5 ...
-
+.P
 # lvs -a -o name,segtype,devices
   lvr5            raid5  lvr5_rimage_0(0),\\
                          lvr5_rimage_1(0),\\
@@ -493,16 +507,16 @@ Each rmeta SubLV holds RAID metadata.
   [lvr5_rmeta_1]  linear /dev/sdb(...)
   [lvr5_rmeta_2]  linear /dev/sdc(...)
 .fi
-
+.P
 .B raid6
 .br
 At least five rimage SubLVs each typically hold a portion of LV data and parity.
 (see section on raid6)
 Each rmeta SubLV holds RAID metadata.
-
+.P
 .nf
 # lvcreate --type raid6 --stripes 3 --name lvr6
-
+.P
 # lvs -a -o name,segtype,devices
   lvr6            raid6  lvr6_rimage_0(0),\\
                          lvr6_rimage_1(0),\\
@@ -523,15 +537,15 @@ Each rmeta SubLV holds RAID metadata.
   [lvr6_rmeta_4]  linear /dev/sde(...)
   [lvr6_rmeta_5]  linear /dev/sdf(...)
 .fi
-
+.P
 .B raid10
 .br
 At least four rimage SubLVs each hold a portion of LV data.  No parity is used.
 Each rmeta SubLV holds RAID metadata.
-
+.P
 .nf
 # lvcreate --type raid10 --stripes 2 --mirrors 1 --name lvr10
-
+.P
 # lvs -a -o name,segtype,devices
   lvr10            raid10 lvr10_rimage_0(0),\\
                           lvr10_rimage_1(0),\\
@@ -546,49 +560,46 @@ Each rmeta SubLV holds RAID metadata.
   [lvr10_rmeta_2]  linear /dev/sdc(...)
   [lvr10_rmeta_3]  linear /dev/sdd(...)
 .fi
-
-
-.SH Device Failure
-
+.
+.SH DEVICE FAILURE
+.
 Physical devices in a RAID LV can fail or be lost for multiple reasons.
 A device could be disconnected, permanently failed, or temporarily
 disconnected.  The purpose of RAID LVs (levels 1 and higher) is to
 continue operating in a degraded mode, without losing LV data, even after
 a device fails.  The number of devices that can fail without the loss of
 LV data depends on the RAID level:
-
-.IP \[bu] 3
+.
+.ipbu
 RAID0 (striped) LVs cannot tolerate losing any devices.  LV data will be
 lost if any devices fail.
-
-.IP \[bu] 3
+.
+.ipbu
 RAID1 LVs can tolerate losing all but one device without LV data loss.
-
-.IP \[bu] 3
+.
+.ipbu
 RAID4 and RAID5 LVs can tolerate losing one device without LV data loss.
-
-.IP \[bu] 3
+.
+.ipbu
 RAID6 LVs can tolerate losing two devices without LV data loss.
-
-.IP \[bu] 3
+.
+.ipbu
 RAID10 is variable, and depends on which devices are lost.  It stripes
 across multiple mirror groups with raid1 layout thus it can tolerate
 losing all but one device in each of these groups without LV data loss.
-
 .P
-
 If a RAID LV is missing devices, or has other device-related problems, lvs
 reports this in the health_status (and attr) fields:
-
+.P
 .B lvs -o name,lv_health_status
-
+.
+.TP
 .B partial
-.br
 Devices are missing from the LV.  This is also indicated by the letter "p"
 (partial) in the 9th position of the lvs attr field.
-
+.
+.TP
 .B refresh needed
-.br
 A device was temporarily missing but has returned.  The LV needs to be
 refreshed to use the device again (which will usually require
 partial synchronization).  This is also indicated by the letter "r" (refresh
@@ -596,58 +607,56 @@ needed) in the 9th position of the lvs attr field.  See
 \fBRefreshing an LV\fP.  This could also indicate a problem with the
 device, in which case it should be be replaced, see
 \fBReplacing Devices\fP.
-
+.
+.TP
 .B mismatches exist
-.br
 See
 .BR Scrubbing .
-
+.P
 Most commands will also print a warning if a device is missing, e.g.
 .br
 .nf
 WARNING: Device for PV uItL3Z-wBME-DQy0-... not found or rejected ...
 .fi
-
+.P
 This warning will go away if the device returns or is removed from the
 VG (see \fBvgreduce --removemissing\fP).
-
-
+.
 .SS Activating an LV with missing devices
-
+.
 A RAID LV that is missing devices may be activated or not, depending on
 the "activation mode" used in lvchange:
-
+.P
 .B lvchange -ay --activationmode
 .BR complete | degraded | partial
 .I LV
-
+.
+.TP
 .B complete
-.br
 The LV is only activated if all devices are present.
-
+.
+.TP
 .B degraded
-.br
 The LV is activated with missing devices if the RAID level can
 tolerate the number of missing devices without LV data loss.
-
+.
+.TP
 .B partial
-.br
 The LV is always activated, even if portions of the LV data are missing
 because of the missing device(s).  This should only be used to perform
 extreme recovery or repair operations.
-
+.P
+Default activation mode when not specified by the command:
+.br
 .BR lvm.conf (5)
 .B activation/activation_mode
-.br
-controls the activation mode when not specified by the command.
-
+.P
 The default value is printed by:
-.nf
-lvmconfig --type default activation/activation_mode
-.fi
-
+.br
+# lvmconfig --type default activation/activation_mode
+.
 .SS Replacing Devices
-
+.
 Devices in a RAID LV can be replaced by other devices in the VG.  When
 replacing devices that are no longer visible on the system, use lvconvert
 --repair.  When replacing devices that are still visible, use lvconvert
@@ -655,16 +664,16 @@ replacing devices that are no longer visible on the system, use lvconvert
 of data LVs that were previously in the LV.  The replace option can be
 repeated to replace multiple PVs.  Replacement devices can be optionally
 listed with either option.
-
+.P
 .B lvconvert --repair
 .I LV
 [\fINewPVs\fP]
-
+.P
 .B lvconvert --replace
 \fIOldPV\fP
 .I LV
 [\fINewPV\fP]
-
+.P
 .B lvconvert
 .B --replace
 \fIOldPV1\fP
@@ -673,120 +682,86 @@ listed with either option.
 ...
 .I LV
 [\fINewPVs\fP]
-
-New devices require synchronization with existing devices, see
+.P
+New devices require synchronization with existing devices.
+.br
+See
 .BR Synchronization .
-
+.
 .SS Refreshing an LV
-
+.
 Refreshing a RAID LV clears any transient device failures (device was
 temporarily disconnected) and returns the LV to its fully redundant mode.
 Restoring a device will usually require at least partial synchronization
 (see \fBSynchronization\fP).  Failure to clear a transient failure results
 in the RAID LV operating in degraded mode until it is reactivated.  Use
 the lvchange command to refresh an LV:
-
+.P
 .B lvchange --refresh
 .I LV
-
+.P
 .nf
 # lvs -o name,vgname,segtype,attr,size vg
   LV VG   Type  Attr       LSize
   lv vg   raid1 Rwi-a-r-r- 100.00g
-
+.P
 # lvchange --refresh vg/lv
-
+.P
 # lvs -o name,vgname,segtype,attr,size vg
   LV VG   Type  Attr       LSize
   lv vg   raid1 Rwi-a-r--- 100.00g
 .fi
-
+.
 .SS Automatic repair
-
+.
 If a device in a RAID LV fails, device-mapper in the kernel notifies the
 .BR dmeventd (8)
 monitoring process (see \fBMonitoring\fP).
 dmeventd can be configured to automatically respond using:
-
+.br
 .BR lvm.conf (5)
 .B activation/raid_fault_policy
-
+.P
 Possible settings are:
-
+.
+.TP
 .B warn
-.br
 A warning is added to the system log indicating that a device has
 failed in the RAID LV.  It is left to the user to repair the LV, e.g.
 replace failed devices.
-
+.
+.TP
 .B allocate
-.br
 dmeventd automatically attempts to repair the LV using spare devices
 in the VG.  Note that even a transient failure is treated as a permanent
 failure under this setting.  A new device is allocated and full
 synchronization is started.
-
-The specific command run by dmeventd to warn or repair is:
+.P
+The specific command run by \fBdmeventd\fP(8) to warn or repair is:
 .br
 .B lvconvert --repair --use-policies
 .I LV
-
-
+.
 .SS Corrupted Data
-
+.
 Data on a device can be corrupted due to hardware errors without the
 device ever being disconnected or there being any fault in the software.
 This should be rare, and can be detected (see \fBScrubbing\fP).
-
-
+.
 .SS Rebuild specific PVs
-
+.
 If specific PVs in a RAID LV are known to have corrupt data, the data on
 those PVs can be reconstructed with:
-
+.P
 .B lvchange --rebuild
 .I PV
 .I LV
-
+.P
 The rebuild option can be repeated with different PVs to replace the data
 on multiple PVs.
-
-
-.SH Monitoring
-
-When a RAID LV is activated the \fBdmeventd\fP(8) process is started to
-monitor the health of the LV.  Various events detected in the kernel can
-cause a notification to be sent from device-mapper to the monitoring
-process, including device failures and synchronization completion (e.g.
-for initialization or scrubbing).
-
-The LVM configuration file contains options that affect how the monitoring
-process will respond to failure events (e.g. raid_fault_policy).  It is
-possible to turn on and off monitoring with lvchange, but it is not
-recommended to turn this off unless you have a thorough knowledge of the
-consequences.
-
-
-.SH Configuration Options
-
-There are a number of options in the LVM configuration file that affect
-the behavior of RAID LVs.  The tunable options are listed
-below.  A detailed description of each can be found in the LVM
-configuration file itself.
-.br
-        mirror_segtype_default
-.br
-        raid10_segtype_default
-.br
-        raid_region_size
-.br
-        raid_fault_policy
-.br
-        activation_mode
-
-
-.SH Data Integrity
-
+.
+.SH DATA INTEGRITY
+.
 The device mapper integrity target can be used in combination with RAID
 levels 1,4,5,6,10 to detect and correct data corruption in RAID images. A
 dm-integrity layer is placed above each RAID image, and an extra sub LV is
@@ -795,30 +770,28 @@ When data is read from an image, integrity checksums are used to detect
 corruption. If detected, dm-raid reads the data from another (good) image
 to return to the caller.  dm-raid will also automatically write the good
 data back to the image with bad data to correct the corruption.
-
+.P
 When creating a RAID LV with integrity, or adding integrity, space is
 required for integrity metadata.  Every 500MB of LV data requires an
 additional 4MB to be allocated for integrity metadata, for each RAID
 image.
-
+.P
 Create a RAID LV with integrity:
-
-.B lvcreate \-\-type raidN \-\-raidintegrity y
-
+.br
+.B lvcreate --type raidN --raidintegrity y
+.P
 Add integrity to an existing RAID LV:
-
-.B lvconvert --raidintegrity y
-.I LV
-
+.br
+.B lvconvert --raidintegrity y \fILV
+.P
 Remove integrity from a RAID LV:
-
-.B lvconvert --raidintegrity n
-.I LV
-
+.br
+.B lvconvert --raidintegrity n \fILV
+.
 .SS Integrity options
-
-.B --raidintegritymode journal|bitmap
-
+.
+.TP
+.BR --raidintegritymode " " journal | bitmap
 Use a journal (default) or bitmap for keeping integrity checksums
 consistent in case of a crash. The bitmap areas are recalculated after a
 crash, so corruption in those areas would not be detected. A journal does
@@ -827,181 +800,175 @@ can improve performance for scattered writes packed into a single journal
 write.  bitmap mode can in theory achieve full write throughput of the
 device, but would not benefit from the potential scattered write
 optimization.
-
-.B --raidintegrityblocksize 512|1024|2048|4096
-
+.
+.TP
+.BR --raidintegrityblocksize " " 512 | 1024 | 2048 | 4096
 The block size to use for dm-integrity on raid images.  The integrity
 block size should usually match the device logical block size, or the file
 system sector/block sizes.  It may be less than the file system
 sector/block size, but not less than the device logical block size.
 Possible values: 512, 1024, 2048, 4096.
-
+.
 .SS Integrity initialization
-
+.
 When integrity is added to an LV, the kernel needs to initialize the
 integrity metadata (checksums) for all blocks in the LV.  The data
 corruption checking performed by dm-integrity will only operate on areas
 of the LV that are already initialized.  The progress of integrity
 initialization is reported by the "syncpercent" LV reporting field (and
 under the Cpy%Sync lvs column.)
-
+.
 .SS Integrity limitations
-
+.
 To work around some limitations, it is possible to remove integrity from
 the LV, make the change, then add integrity again.  (Integrity metadata
 would need to initialized when added again.)
-
+.P
 LVM must be able to allocate the integrity metadata sub LV on a single PV
 that is already in use by the associated RAID image. This can potentially
 cause a problem during lvextend if the original PV holding the image and
 integrity metadata is full.  To work around this limitation, remove
 integrity, extend the LV, and add integrity again.
-
+.P
 Additional RAID images can be added to raid1 LVs, but not to other raid
 levels.
-
+.P
 A raid1 LV with integrity cannot be converted to linear (remove integrity
 to do this.)
-
+.P
 RAID LVs with integrity cannot yet be used as sub LVs with other LV types.
-
+.P
 The following are not yet permitted on RAID LVs with integrity: lvreduce,
 pvmove, snapshots, splitmirror, raid syncaction commands, raid rebuild.
-
-.SH RAID1 Tuning
-
+.
+.SH RAID1 TUNING
+.
 A RAID1 LV can be tuned so that certain devices are avoided for reading
 while all devices are still written to.
-
+.P
 .B lvchange
 .BR -- [ raid ] writemostly
 \fIPV\fP[\fB:y\fP|\fBn\fP|\fBt\fP]
 .I LV
-
+.P
 The specified device will be marked as "write mostly", which means that
 reading from this device will be avoided, and other devices will be
 preferred for reading (unless no other devices are available.)  This
 minimizes the I/O to the specified device.
-
+.P
 If the PV name has no suffix, the write mostly attribute is set.  If the
 PV name has the suffix \fB:n\fP, the write mostly attribute is cleared,
 and the suffix \fB:t\fP toggles the current setting.
-
+.P
 The write mostly option can be repeated on the command line to change
 multiple devices at once.
-
+.P
 To report the current write mostly setting, the lvs attr field will show
 the letter "w" in the 9th position when write mostly is set:
-
+.P
 .B lvs -a -o name,attr
-
+.P
 When a device is marked write mostly, the maximum number of outstanding
 writes to that device can be configured.  Once the maximum is reached,
 further writes become synchronous.  When synchronous, a write to the LV
 will not complete until writes to all the mirror images are complete.
-
+.P
 .B lvchange
 .BR -- [ raid ] writebehind
 .I Number
 .I LV
-
+.P
 To report the current write behind setting, run:
-
+.P
 .B lvs -o name,raid_write_behind
-
+.P
 When write behind is not configured, or set to 0, all LV writes are
 synchronous.
-
-
-.SH RAID Takeover
-
+.
+.SH RAID TAKEOVER
+.
 RAID takeover is converting a RAID LV from one RAID level to another, e.g.
 raid5 to raid6.  Changing the RAID level is usually done to increase or
 decrease resilience to device failures or to restripe LVs.  This is done
 using lvconvert and specifying the new RAID level as the LV type:
-
+.P
 .B lvconvert --type
 .I RaidLevel
 .I LV
 [\fIPVs\fP]
-
+.P
 The most common and recommended RAID takeover conversions are:
-
-.HP
-\fBlinear\fP to \fBraid1\fP
-.br
+.
+.TP
+.BR linear " to " raid1
 Linear is a single image of LV data, and
 converting it to raid1 adds a mirror image which is a direct copy of the
 original linear image.
-
-.HP
-\fBstriped\fP/\fBraid0\fP to \fBraid4/5/6\fP
-.br
+.
+.TP
+.BR striped / raid0 " to " raid4 / 5 / 6
 Adding parity devices to a
 striped volume results in raid4/5/6.
-
 .P
-
 Unnatural conversions that are not recommended include converting between
 striped and non-striped types.  This is because file systems often
 optimize I/O patterns based on device striping values.  If those values
 change, it can decrease performance.
-
+.P
 Converting to a higher RAID level requires allocating new SubLVs to hold
 RAID metadata, and new SubLVs to hold parity blocks for LV data.
 Converting to a lower RAID level removes the SubLVs that are no longer
 needed.
-
+.P
 Conversion often requires full synchronization of the RAID LV (see
 \fBSynchronization\fP).  Converting to RAID1 requires copying all LV data
 blocks to N new images on new devices.  Converting to a parity RAID level
 requires reading all LV data blocks, calculating parity, and writing the
 new parity blocks.  Synchronization can take a long time depending on the
 throughpout of the devices used and the size of the RaidLV.  It can degrade
-performance (rate controls also apply to conversion; see
-\fB--minrecoveryrate\fP
-and
-\fB--maxrecoveryrate\fP.)
-
+performance. Rate controls also apply to conversion; see
+\fB--minrecoveryrate\fP and \fB--maxrecoveryrate\fP.
+.P
 Warning: though it is possible to create \fBstriped\fP LVs  with up to 128 stripes,
 a maximum of 64 stripes can be converted to \fBraid0\fP, 63 to \fBraid4/5\fP and
 62 to \fBraid6\fP because of the added parity SubLVs.
 A \fBstriped\fP LV with a maximum of 32 stripes can be converted to \fBraid10\fP.
-
+.
 .P
-
+.
 The following takeover conversions are currently possible:
 .br
-.IP \(bu 3
+.ipbu
 between striped and raid0.
-.IP \(bu 3
+.ipbu
 between linear and raid1.
-.IP \(bu 3
+.ipbu
 between mirror and raid1.
-.IP \(bu 3
+.ipbu
 between raid1 with two images and raid4/5.
-.IP \(bu 3
+.ipbu
 between striped/raid0 and raid4.
-.IP \(bu 3
+.ipbu
 between striped/raid0 and raid5.
-.IP \(bu 3
+.ipbu
 between striped/raid0 and raid6.
-.IP \(bu 3
+.ipbu
 between raid4 and raid5.
-.IP \(bu 3
+.ipbu
 between raid4/raid5 and raid6.
-.IP \(bu 3
+.ipbu
 between striped/raid0 and raid10.
-.IP \(bu 3
+.ipbu
 between striped and raid4.
-
+.PD
+.
 .SS Indirect conversions
-
+.
 Converting from one raid level to another may require multiple steps,
 converting first to intermediate raid levels.
-
-.B linear to raid6
-
+.P
+.BR linear " to " raid6
+.P
 To convert an LV from linear to raid6:
 .br
 1. convert to raid1 with two images
@@ -1013,7 +980,7 @@ To convert an LV from linear to raid6:
 4. convert to raid6 (internally raid6_ls_6)
 .br
 5. convert to raid6 (internally raid6_zr, reshape)
-
+.P
 The commands to perform the steps above are:
 .br
 1. lvconvert --type raid1 --mirrors 1 LV
@@ -1025,14 +992,14 @@ The commands to perform the steps above are:
 4. lvconvert --type raid6 LV
 .br
 5. lvconvert --type raid6 LV
-
+.P
 The final conversion from raid6_ls_6 to raid6_zr is done to avoid the
 potential write/recovery performance reduction in raid6_ls_6 because of
 the dedicated parity device.  raid6_zr rotates data and parity blocks to
 avoid this.
-
-.B linear to striped
-
+.P
+.BR linear " to " striped
+.P
 To convert an LV from linear to striped:
 .br
 1. convert to raid1 with two images
@@ -1042,7 +1009,7 @@ To convert an LV from linear to striped:
 3. convert to raid5_n with five 128k stripes (reshape)
 .br
 4. convert raid5_n to striped
-
+.P
 The commands to perform the steps above are:
 .br
 1. lvconvert --type raid1 --mirrors 1 LV
@@ -1052,41 +1019,40 @@ The commands to perform the steps above are:
 3. lvconvert --stripes 5 --stripesize 128k LV
 .br
 4. lvconvert --type striped LV
-
+.P
 The raid5_n type in step 2 is used because it has dedicated parity SubLVs
 at the end, and can be converted to striped directly.  The stripe size is
 increased in step 3 to add extra space for the conversion process.  This
 step grows the LV size by a factor of five.  After conversion, this extra
 space can be reduced (or used to grow the file system using the LV).
-
+.P
 Reversing these steps will convert a striped LV to linear.
-
-.B raid6 to striped
-
+.P
+.BR raid6 " to " striped
+.P
 To convert an LV from raid6_nr to striped:
 .br
 1. convert to raid6_n_6
 .br
 2. convert to striped
-
+.P
 The commands to perform the steps above are:
 .br
 1. lvconvert --type raid6_n_6 LV
 .br
 2. lvconvert --type striped LV
-
-
-.SS Examples
-
+.P
+.I Examples
+.P
 Converting an LV from \fBlinear\fP to \fBraid1\fP.
-
+.P
 .nf
 # lvs -a -o name,segtype,size vg
   LV   Type   LSize
   lv   linear 300.00g
-
+.P
 # lvconvert --type raid1 --mirrors 1 vg/lv
-
+.P
 # lvs -a -o name,segtype,size vg
   LV            Type   LSize
   lv            raid1  300.00g
@@ -1095,9 +1061,9 @@ Converting an LV from \fBlinear\fP to \fBraid1\fP.
   [lv_rmeta_0]  linear   3.00m
   [lv_rmeta_1]  linear   3.00m
 .fi
-
+.P
 Converting an LV from \fBmirror\fP to \fBraid1\fP.
-
+.P
 .nf
 # lvs -a -o name,segtype,size vg
   LV            Type   LSize
@@ -1105,9 +1071,9 @@ Converting an LV from \fBmirror\fP to \fBraid1\fP.
   [lv_mimage_0] linear 100.00g
   [lv_mimage_1] linear 100.00g
   [lv_mlog]     linear   3.00m
-
+.P
 # lvconvert --type raid1 vg/lv
-
+.P
 # lvs -a -o name,segtype,size vg
   LV            Type   LSize
   lv            raid1  100.00g
@@ -1116,20 +1082,20 @@ Converting an LV from \fBmirror\fP to \fBraid1\fP.
   [lv_rmeta_0]  linear   3.00m
   [lv_rmeta_1]  linear   3.00m
 .fi
-
+.P
 Converting an LV from \fBlinear\fP to \fBraid1\fP (with 3 images).
-
+.P
 .nf
 # lvconvert --type raid1 --mirrors 2 vg/lv
 .fi
-
+.P
 Converting an LV from \fBstriped\fP (with 4 stripes) to \fBraid6_n_6\fP.
-
+.P
 .nf
 # lvcreate --stripes 4 -L64M -n lv vg
-
+.P
 # lvconvert --type raid6 vg/lv
-
+.P
 # lvs -a -o lv_name,segtype,sync_percent,data_copies
   LV            Type      Cpy%Sync #Cpy
   lv            raid6_n_6 100.00      3
@@ -1146,42 +1112,41 @@ Converting an LV from \fBstriped\fP (with 4 stripes) to \fBraid6_n_6\fP.
   [lv_rmeta_4]  linear
   [lv_rmeta_5]  linear
 .fi
-
+.P
 This convert begins by allocating MetaLVs (rmeta_#) for each of the
 existing stripe devices.  It then creates 2 additional MetaLV/DataLV pairs
 (rmeta_#/rimage_#) for dedicated raid6 parity.
-
+.P
 If rotating data/parity is required, such as with raid6_nr, it must be
 done by reshaping (see below).
-
-
-.SH RAID Reshaping
-
+.
+.SH RAID RESHAPING
+.
 RAID reshaping is changing attributes of a RAID LV while keeping the same
 RAID level.  This includes changing RAID layout, stripe size, or number of
 stripes.
-
+.P
 When changing the RAID layout or stripe size, no new SubLVs (MetaLVs or
 DataLVs) need to be allocated, but DataLVs are extended by a small amount
 (typically 1 extent).  The extra space allows blocks in a stripe to be
 updated safely, and not be corrupted in case of a crash.  If a crash occurs,
 reshaping can just be restarted.
-
+.P
 (If blocks in a stripe were updated in place, a crash could leave them
 partially updated and corrupted.  Instead, an existing stripe is quiesced,
 read, changed in layout, and the new stripe written to free space.  Once
 that is done, the new stripe is unquiesced and used.)
-
-.SS Examples
-
+.P
+.I Examples
+.br
 (Command output shown in examples may change.)
-
+.P
 Converting raid6_n_6 to raid6_nr with rotating data/parity.
-
+.P
 This conversion naturally follows a previous conversion from striped/raid0
 to raid6_n_6 (shown above).  It completes the transition to a more
 traditional RAID6.
-
+.P
 .nf
 # lvs -o lv_name,segtype,sync_percent,data_copies
   LV            Type      Cpy%Sync #Cpy
@@ -1198,9 +1163,9 @@ traditional RAID6.
   [lv_rmeta_3]  linear
   [lv_rmeta_4]  linear
   [lv_rmeta_5]  linear
-
+.P
 # lvconvert --type raid6_nr vg/lv
-
+.P
 # lvs -a -o lv_name,segtype,sync_percent,data_copies
   LV            Type     Cpy%Sync #Cpy
   lv            raid6_nr 100.00      3
@@ -1221,10 +1186,10 @@ traditional RAID6.
   [lv_rmeta_4]  linear
   [lv_rmeta_5]  linear
 .fi
-
+.P
 The DataLVs are larger (additional segment in each) which provides space
 for out-of-place reshaping.  The result is:
-
+.P
 .nf
 # lvs -a -o lv_name,segtype,seg_pe_ranges,dataoffset
   LV            Type     PE Ranges          DOff
@@ -1243,14 +1208,14 @@ for out-of-place reshaping.  The result is:
   [lv_rmeta_2]  linear   /dev/sdab:0-0
   [lv_rmeta_3]  linear   /dev/sdac:0-0
 .fi
-
+.P
 All segments with PE ranges '33-33' provide the out-of-place reshape space.
 The dataoffset column shows that the data was moved from initial offset 0 to
 2048 sectors on each component DataLV.
-
+.P
 For performance reasons the raid6_nr RaidLV can be restriped.
 Convert it from 3-way striped to 5-way-striped.
-
+.P
 .nf
 # lvconvert --stripes 5 vg/lv
   Using default stripesize 64.00 KiB.
@@ -1259,11 +1224,11 @@ Convert it from 3-way striped to 5-way-striped.
   Run "lvresize -l99 vg/lv" to shrink it or use the additional \\
   capacity.
   Logical volume vg/lv successfully converted.
-
+.P
 # lvs vg/lv
   LV   VG     Attr       LSize   Cpy%Sync
   lv   vg     rwi-a-r-s- 652.00m 52.94
-
+.P
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
   LV            Attr       Type     PE Ranges          DOff
   lv            rwi-a-r--- raid6_nr lv_rimage_0:0-33 \\
@@ -1289,12 +1254,12 @@ Convert it from 3-way striped to 5-way-striped.
   [lv_rmeta_5]  ewi-aor--- linear   /dev/sdae:0-0
   [lv_rmeta_6]  ewi-aor--- linear   /dev/sdaf:0-0
 .fi
-
+.P
 Stripes also can be removed from raid5 and 6.
 Convert the 5-way striped raid6_nr LV to 4-way-striped.
 The force option needs to be used, because removing stripes
 (i.e. image SubLVs) from a RaidLV will shrink its size.
-
+.P
 .nf
 # lvconvert --stripes 4 vg/lv
   Using default stripesize 64.00 KiB.
@@ -1307,7 +1272,7 @@ The force option needs to be used, because removing stripes
   WARNING: to remove freed stripes after the conversion has finished,\\
   you have to run "lvconvert --stripes 4 vg/lv"
   Logical volume vg/lv successfully converted.
-
+.P
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
   LV            Attr       Type     PE Ranges          DOff
   lv            rwi-a-r-s- raid6_nr lv_rimage_0:0-33 \\
@@ -1333,10 +1298,10 @@ The force option needs to be used, because removing stripes
   [lv_rmeta_5]  ewi-aor--- linear   /dev/sdae:0-0
   [lv_rmeta_6]  ewi-aor-R- linear   /dev/sdaf:0-0
 .fi
-
+.P
 The 's' in column 9 of the attribute field shows the RaidLV is still reshaping.
 The 'R' in the same column of the attribute field shows the freed image Sub LVs which will need removing once the reshaping finished.
-
+.P
 .nf
 # lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
   LV   Attr       Type     PE Ranges          DOff
@@ -1346,9 +1311,9 @@ The 'R' in the same column of the attribute field shows the freed image Sub LVs
                            lv_rimage_5:0-33 \\
                            lv_rimage_6:0-33   8192
 .fi
-
+.P
 Now that the reshape is finished the 'R' attribute on the RaidLV shows images can be removed.
-
+.P
 .nf
 # lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
   LV   Attr       Type     PE Ranges          DOff
@@ -1358,14 +1323,14 @@ Now that the reshape is finished the 'R' attribute on the RaidLV shows images ca
                            lv_rimage_5:0-33 \\
                            lv_rimage_6:0-33   8192
 .fi
-
+.P
 This is achieved by repeating the command ("lvconvert --stripes 4 vg/lv" would be sufficient).
-
+.P
 .nf
 # lvconvert --stripes 4 vg/lv
   Using default stripesize 64.00 KiB.
   Logical volume vg/lv successfully converted.
-
+.P
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
   LV            Attr       Type     PE Ranges          DOff
   lv            rwi-a-r--- raid6_nr lv_rimage_0:0-33 \\
@@ -1387,7 +1352,7 @@ This is achieved by repeating the command ("lvconvert --stripes 4 vg/lv" would b
   [lv_rmeta_3]  ewi-aor--- linear   /dev/sdac:0-0
   [lv_rmeta_4]  ewi-aor--- linear   /dev/sdad:0-0
   [lv_rmeta_5]  ewi-aor--- linear   /dev/sdae:0-0
-
+.P
 # lvs -a -o lv_name,attr,segtype,reshapelen vg
   LV            Attr       Type     RSize
   lv            rwi-a-r--- raid6_nr 24.00m
@@ -1407,17 +1372,17 @@ This is achieved by repeating the command ("lvconvert --stripes 4 vg/lv" would b
   [lv_rmeta_4]  ewi-aor--- linear
   [lv_rmeta_5]  ewi-aor--- linear
 .fi
-
+.P
 Future developments might include automatic removal of the freed images.
-
+.P
 If the reshape space shall be removed any lvconvert command not changing the layout can be used:
-
+.P
 .nf
 # lvconvert --stripes 4 vg/lv
   Using default stripesize 64.00 KiB.
   No change in RAID LV vg/lv layout, freeing reshape space.
   Logical volume vg/lv successfully converted.
-
+.P
 # lvs -a -o lv_name,attr,segtype,reshapelen vg
   LV            Attr       Type     RSize
   lv            rwi-a-r--- raid6_nr    0
@@ -1437,9 +1402,9 @@ If the reshape space shall be removed any lvconvert command not changing the lay
   [lv_rmeta_4]  ewi-aor--- linear
   [lv_rmeta_5]  ewi-aor--- linear
 .fi
-
+.P
 In case the RaidLV should be converted to striped:
-
+.P
 .nf
 # lvconvert --type striped vg/lv
   Unable to convert LV vg/lv from raid6_nr to striped.
@@ -1453,11 +1418,11 @@ In case the RaidLV should be converted to striped:
     raid6_rs_6
     raid6_n_6
 .fi
-
+.P
 A direct conversion isn't possible thus the command informed about the possible ones.
 raid6_n_6 is suitable to convert to striped so convert to it first (this is a reshape
 changing the raid6 layout from raid6_nr to raid6_n_6).
-
+.P
 .nf
 # lvconvert --type raid6_n_6
   Using default stripesize 64.00 KiB.
@@ -1465,13 +1430,13 @@ changing the raid6 layout from raid6_nr to raid6_n_6).
 Are you sure you want to convert raid6_nr LV vg/lv? [y/n]: y
   Logical volume vg/lv successfully converted.
 .fi
-
+.P
 Wait for the reshape to finish.
-
+.P
 .nf
 # lvconvert --type striped vg/lv
   Logical volume vg/lv successfully converted.
-
+.P
 # lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
   LV   Attr       Type    PE Ranges  DOff
   lv   -wi-a----- striped /dev/sda:2-32 \\
@@ -1483,14 +1448,14 @@ Wait for the reshape to finish.
                           /dev/sdab:34-35 \\
                           /dev/sdac:34-35
 .fi
-
+.P
 From striped we can convert to raid10
-
+.P
 .nf
 # lvconvert --type raid10 vg/lv
   Using default stripesize 64.00 KiB.
   Logical volume vg/lv successfully converted.
-
+.P
 # lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
   LV   Attr       Type   PE Ranges          DOff
   lv   rwi-a-r--- raid10 lv_rimage_0:0-32 \\
@@ -1498,7 +1463,7 @@ From striped we can convert to raid10
                          lv_rimage_1:0-32 ... \\
                          lv_rimage_3:0-32 \\
                          lv_rimage_7:0-32   0
-
+.P
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
   WARNING: Cannot find matching striped segment for vg/lv_rimage_3.
   LV            Attr       Type   PE Ranges          DOff
@@ -1527,29 +1492,28 @@ From striped we can convert to raid10
   [lv_rmeta_6]  ewi-aor--- linear /dev/sdaf:0-0
   [lv_rmeta_7]  ewi-aor--- linear /dev/sdag:0-0
 .fi
-
+.P
 raid10 allows to add stripes but can't remove them.
-
-
+.P
 A more elaborate example to convert from linear to striped
 with interim conversions to raid1 then raid5 followed
 by restripe (4 steps).
-
+.P
 We start with the linear LV.
-
+.P
 .nf
 # lvs -a -o name,size,segtype,syncpercent,datastripes,\\
             stripesize,reshapelenle,devices vg
   LV   LSize   Type   Cpy%Sync #DStr Stripe RSize Devices
   lv   128.00m linear              1     0        /dev/sda(0)
 .fi
-
+.P
 Then convert it to a 2-way raid1.
-
+.P
 .nf
 # lvconvert --mirrors 1 vg/lv
   Logical volume vg/lv successfully converted.
-
+.P
 # lvs -a -o name,size,segtype,datastripes,\\
             stripesize,reshapelenle,devices vg
   LV            LSize   Type   #DStr Stripe RSize Devices
@@ -1560,17 +1524,17 @@ Then convert it to a 2-way raid1.
   [lv_rmeta_0]    4.00m linear     1     0        /dev/sda(32)
   [lv_rmeta_1]    4.00m linear     1     0        /dev/sdhx(0)
 .fi
-
+.P
 Once the raid1 LV is fully synchronized we convert it to raid5_n (only 2-way raid1
 LVs can be converted to raid5).  We select raid5_n here because it has dedicated parity
 SubLVs at the end and can be converted to striped directly without any additional
 conversion.
-
+.P
 .nf
 # lvconvert --type raid5_n vg/lv
   Using default stripesize 64.00 KiB.
   Logical volume vg/lv successfully converted.
-
+.P
 # lvs -a -o name,size,segtype,syncpercent,datastripes,\\
             stripesize,reshapelenle,devices vg
   LV            LSize   Type    #DStr Stripe RSize Devices
@@ -1581,12 +1545,12 @@ conversion.
   [lv_rmeta_0]    4.00m linear      1     0        /dev/sda(32)
   [lv_rmeta_1]    4.00m linear      1     0        /dev/sdhx(0)
 .fi
-
+.P
 Now we'll change the number of data stripes from 1 to 5 and request 128K stripe size
 in one command.  This will grow the size of the LV by a factor of 5 (we add 4 data stripes
 to the one given).  That additional space can be used by e.g. growing any contained filesystem
 or the LV can be reduced in size after the reshaping conversion has finished.
-
+.P
 .nf
 # lvconvert --stripesize 128k --stripes 5 vg/lv
   Converting stripesize 64.00 KiB of raid5_n LV vg/lv to 128.00 KiB.
@@ -1594,7 +1558,7 @@ or the LV can be reduced in size after the reshaping conversion has finished.
   it from 32 to 160 extents!
   Run "lvresize -l32 vg/lv" to shrink it or use the additional capacity.
   Logical volume vg/lv successfully converted.
-
+.P
 # lvs -a -o name,size,segtype,datastripes,\\
             stripesize,reshapelenle,devices
   LV            LSize   Type    #DStr Stripe  RSize Devices
@@ -1623,13 +1587,13 @@ or the LV can be reduced in size after the reshaping conversion has finished.
   [lv_rmeta_4]    4.00m linear      1      0        /dev/sdhu(0)
   [lv_rmeta_5]    4.00m linear      1      0        /dev/sdht(0)
 .fi
-
+.P
 Once the conversion has finished we can can convert to striped.
-
+.P
 .nf
 # lvconvert --type striped vg/lv
   Logical volume vg/lv successfully converted.
-
+.P
 # lvs -a -o name,size,segtype,datastripes,\\
             stripesize,reshapelenle,devices vg
   LV   LSize   Type    #DStr Stripe  RSize Devices
@@ -1644,194 +1608,168 @@ Once the conversion has finished we can can convert to striped.
                                            /dev/sdhv(1),\\
                                            /dev/sdhu(1)
 .fi
-
+.P
 Reversing these steps will convert a given striped LV to linear.
-
+.P
 Mind the facts that stripes are removed thus the capacity of the RaidLV will shrink
 and that changing the RaidLV layout will influence its performance.
-
+.P
 "lvconvert --stripes 1 vg/lv" for converting to 1 stripe will inform upfront about
 the reduced size to allow for resizing the content or growing the RaidLV before
 actually converting to 1 stripe.  The \fB--force\fP option is needed to
 allow stripe removing conversions to prevent data loss.
-
-Of course any interim step can be the intended last one (e.g. striped -> raid1).
-..
-
-.SH RAID5 Variants
-
+.P
+Of course any interim step can be the intended last one (e.g. striped \[->] raid1).
+.
+.SH RAID5 VARIANTS
+.
+.TP
 raid5_ls
-.br
-\[bu]
+.ipbu
 RAID5 left symmetric
-.br
-\[bu]
+.ipbu
 Rotating parity N with data restart
-
+.
+.TP
 raid5_la
-.br
-\[bu]
-RAID5 left symmetric
-.br
-\[bu]
+.ipbu
+RAID5 left asymmetric
+.ipbu
 Rotating parity N with data continuation
-
+.
+.TP
 raid5_rs
-.br
-\[bu]
+.ipbu
 RAID5 right symmetric
-.br
-\[bu]
+.ipbu
 Rotating parity 0 with data restart
-
+.
+.TP
 raid5_ra
-.br
-\[bu]
+.ipbu
 RAID5 right asymmetric
-.br
-\[bu]
+.ipbu
 Rotating parity 0 with data continuation
-
+.
+.TP
 raid5_n
-.br
-\[bu]
+.ipbu
 RAID5 parity n
-.br
-\[bu]
+.ipbu
 Dedicated parity device n used for striped/raid0 conversions
-.br
-\[bu]
+.ipbu
 Used for RAID Takeover
-
-.SH RAID6 Variants
-
-raid6
-.br
-\[bu]
+.
+.SH RAID6 VARIANTS
+.
+.TP
+.RB raid6\ \  "  "
+.ipbu
 RAID6 zero restart (aka left symmetric)
-.br
-\[bu]
+.ipbu
 Rotating parity 0 with data restart
-.br
-\[bu]
+.ipbu
 Same as raid6_zr
-
+.
+.TP
 raid6_zr
-.br
-\[bu]
+.ipbu
 RAID6 zero restart (aka left symmetric)
-.br
-\[bu]
+.ipbu
 Rotating parity 0 with data restart
-
+.
+.TP
 raid6_nr
-.br
-\[bu]
+.ipbu
 RAID6 N restart (aka right symmetric)
-.br
-\[bu]
+.ipbu
 Rotating parity N with data restart
-
+.
+.TP
 raid6_nc
-.br
-\[bu]
+.ipbu
 RAID6 N continue
-.br
-\[bu]
+.ipbu
 Rotating parity N with data continuation
-
+.
+.TP
 raid6_n_6
-.br
-\[bu]
+.ipbu
 RAID6 last parity devices
-.br
-\[bu]
+.ipbu
 Fixed dedicated last devices (P-Syndrome N-1 and Q-Syndrome N)
-.RS 2
 with striped data used for striped/raid0 conversions
-.RE
-.br
-\[bu]
+.ipbu
 Used for RAID Takeover
-
+.
+.TP
 raid6_{ls,rs,la,ra}_6
-.br
-\[bu]
+.ipbu
 RAID6 last parity device
-.br
-\[bu]
+.ipbu
 Dedicated last parity device used for conversions from/to
-.RS 2
 raid5_{ls,rs,la,ra}
-.RE
-
+.
+.TP
 raid6_ls_6
-.br
-\[bu]
+.ipbu
 RAID6 N continue
-.br
-\[bu]
+.ipbu
 Same as raid5_ls for N-1 devices with fixed Q-Syndrome N
-.br
-\[bu]
+.ipbu
 Used for RAID Takeover
-
+.
+.TP
 raid6_la_6
-.br
-\[bu]
+.ipbu
 RAID6 N continue
-.br
-\[bu]
+.ipbu
 Same as raid5_la for N-1 devices with fixed Q-Syndrome N
-.br
-\[bu]
+.ipbu
 Used forRAID Takeover
-
+.
+.TP
 raid6_rs_6
-.br
-\[bu]
+.ipbu
 RAID6 N continue
-.br
-\[bu]
+.ipbu
 Same as raid5_rs for N-1 devices with fixed Q-Syndrome N
-.br
-\[bu]
+.ipbu
 Used for RAID Takeover
-
+.
+.TP
 raid6_ra_6
-.br
-\[bu]
+.ipbu
 RAID6 N continue
-.br
-\[bu]
-ame as raid5_ra for N-1 devices with fixed Q-Syndrome N
-.br
-\[bu]
+.ipbu
+Same as raid5_ra for N-1 devices with fixed Q-Syndrome N
+.ipbu
 Used for RAID Takeover
-
-
+.
+.
 .ig
-.SH RAID Duplication
-
+.
+.SH RAID DUPLICATION
+.
 RAID LV conversion (takeover or reshaping) can be done out-of-place by
 copying the LV data onto new devices while changing the RAID properties.
 Copying avoids modifying the original LV but requires additional devices.
 Once the LV data has been copied/converted onto the new devices, there are
 multiple options:
-
+.P
 1. The RAID LV can be switched over to run from just the new devices, and
 the original copy of the data removed.  The converted LV then has the new
 RAID properties, and exists on new devices.  The old devices holding the
 original data can be removed or reused.
-
+.P
 2. The new copy of the data can be dropped, leaving the original RAID LV
 unchanged and using its original devices.
-
+.P
 3. The new copy of the data can be separated and used as a new independent
 LV, leaving the original RAID LV unchanged on its original devices.
-
+.P
 The command to start duplication is:
-
+.P
 .B lvconvert --type
 .I RaidLevel
 [\fB--stripes\fP \fINumber\fP \fB--stripesize\fP \fISize\fP]
@@ -1840,76 +1778,72 @@ The command to start duplication is:
 .I LV
 [\fIPVs\fP]
 .RE
-
-.HP
+.P
+.TP
 .B --duplicate
 .br
 Specifies that the LV conversion should be done out-of-place, copying
 LV data to new devices while converting.
-
-.HP
+.P
+.TP
 .BR --type , --stripes , --stripesize
 .br
 Specifies the RAID properties to use when creating the copy.
-
 .P
 \fIPVs\fP specifies the new devices to use.
-
+.P
 The steps in the duplication process:
-
-.IP \(bu 3
+.P
+.ipbu
 LVM creates a new LV on new devices using the specified RAID properties
 (type, stripes, etc) and optionally specified devices.
-
-.IP \(bu 3
+.P
+.ipbu
 LVM changes the visible RAID LV to type raid1, making the original LV the
 first raid1 image (SubLV 0), and the new LV the second raid1 image
 (SubLV 1).
-
-.IP \(bu 3
+.P
+.ipbu
 The RAID1 synchronization process copies data from the original LV
 image (SubLV 0) to the new LV image (SubLV 1).
-
-.IP \(bu 3
+.P
+.ipbu
 When synchronization is complete, the original and new LVs are
 mirror images of each other and can be separated.
-
 .P
-
 The duplication process retains both the original and new LVs (both
 SubLVs) until an explicit unduplicate command is run to separate them.  The
 unduplicate command specifies if the original LV should use the old
 devices (SubLV 0) or the new devices (SubLV 1).
-
+.P
 To make the RAID LV use the data on the old devices, and drop the copy on
 the new devices, specify the name of SubLV 0 (suffix _dup_0):
-
+.P
 .B lvconvert --unduplicate
 .BI --name
 .IB LV _dup_0
 .I LV
-
+.P
 To make the RAID LV use the data copy on the new devices, and drop the old
 devices, specify the name of SubLV 1 (suffix _dup_1):
-
+.P
 .B lvconvert --unduplicate
 .BI --name
 .IB LV _dup_1
 .I LV
-
+.P
 FIXME: To make the LV use the data on the original devices, but keep the
 data copy as a new LV, ...
-
+.P
 FIXME: include how splitmirrors can be used.
-
-
-.SH RAID1E
-
+.
+.SS RAID1E
+.
 TODO
 ..
-
-.SH History
-
+.
+.SH HISTORY
+.
 The 2.6.38-rc1 version of the Linux kernel introduced a device-mapper
 target to interface with the software RAID (MD) personalities.  This
 provided device-mapper with RAID 4/5/6 capabilities and a larger
@@ -1919,4 +1853,15 @@ added to LVM version 2.02.87.  The capabilities of the LVM \fBraid1\fP
 type have surpassed the old \fBmirror\fP type.  raid1 is now recommended
 instead of mirror.  raid1 became the default for mirroring in LVM version
 2.02.100.
-
+.
+.SH SEE ALSO
+.
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvcreate (8),
+.BR lvconvert (8),
+.BR lvchange (8),
+.BR lvextend (8),
+.BR dmeventd (8)
diff --git a/man/lvmreport.7_main b/man/lvmreport.7_main
index c13e7789c..f0f04ad1c 100644
--- a/man/lvmreport.7_main
+++ b/man/lvmreport.7_main
@@ -1,24 +1,32 @@
 .TH "LVMREPORT" "7" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
-
+.
 .SH NAME
+.
 lvmreport \(em LVM reporting and related features
-
+.
 .SH DESCRIPTION
+.
 LVM uses single reporting infrastructure that sets standard on LVM command's
 output and it provides wide range of configuration settings and command line
 options to customize report and filter the report's output.
-
-.SH Categorization based on reporting facility
-
+.
+.SH USAGE
+.
+.SS Categorization based on reporting facility
+.
 Based on functionality, commands which make use of the reporting infrastructure
 are divided in two groups:
-.IP \fBReport-oriented commands\fP
+.
+.TP
+.B Report-oriented commands
 These commands inform about current LVM state and their primary role is to
 display this information in compendious way. To make a distinction, we will
 name this report as \fBmain report\fP. The set of report-only commands include:
 pvs, vgs, lvs, pvdisplay, vgdisplay, lvdisplay, lvm devtypes, lvm fullreport.
-For further information about main report, see \fBmain report specifics\fP.
-.IP \fBProcessing-oriented commands\fP
+For further information about main report, see \fBMain report specifics\fP.
+.
+.TP
+.B Processing-oriented commands
 These commands are responsible for changing LVM state and they do not contain
 any main report as identified for report-oriented commands, they only perform
 some kind of processing. The set of processing-oriented commands includes:
@@ -26,18 +34,17 @@ pvcreate, vgcreate, lvcreate, pvchange, vgchange, lvchange, pvremove, vgremove,
 lvremove, pvresize, vgextend, vgreduce, lvextend, lvreduce, lvresize, lvrename,
 pvscan, vgscan, lvscan, pvmove, vgcfgbackup, vgck, vgconvert, vgexport,
 vgimport, vgmknodes.
-
+.P
 .RE
 If enabled, so called \fBlog report\fP is either displayed solely
 (for processing-oriented commands) or in addition to main report
 (for report-oriented commands). The log report contains a log of operations,
 messages and per-object status with complete object identification collected
-during LVM command execution. See \fBlog report specifics\fP for more
+during LVM command execution. See \fBLog report specifics\fP for more
 information about this report type.
-
-
-.SH Terms
-
+.
+.SS Terms
+.
 When describing reporting functionality and features in this text, we will
 use terms \fBrow\fP and \fBcolumn\fP. By row we mean series of values reported
 for single entity (for example single PV, VG or LV). Each value from the row
@@ -46,66 +53,55 @@ which are short descriptions for the columns. The columns are referenced by
 \fBcolumn names\fP. Please note that this text is also using term \fBfield\fP
 interchangeably with the term \fBcolumn\fP. Most of the time the term columns
 is abbreviated as \fBcol\fP in configuration.
-
-.SH Common report configuration settings and command line options
-
+.
+.SS Common report configuration settings and command line options
+.
 There are common configuration settings and command line options which apply
 to both \fBmain report\fP and \fBlog report\fP. Following lists contain all
 of them, separated into groups based on their use.
-
-.RS
-\fBCommon configuration settings:\fP
-
-.RS
-
-.IP \[bu] 3
+.
+.SS Common configuration settings
+.
+.ad l
+.TP
 Changing report output format, composition and other output modifiers:
-.RS
-.IP - 3
-global/units
-.IP - 3
-global/suffix
-.IP - 3
-report/output_format
-.IP - 3
-report/compact_output
-.IP - 3
-report/compact_output_cols
-.IP - 3
-report/aligned
-.IP - 3
-report/headings
-.IP - 3
-report/separator
-.IP - 3
-report/list_item_separator
-.IP - 3
-report/prefixes
-.IP - 3
-report/quoted
-.IP - 3
-report/columns_as_rows
-.IP - 3
-report/binary_values_as_numeric
-.IP - 3
-report/time_format
-.IP - 3
-report/mark_hidden_devices
-.IP - 3
-report/two_word_unknown_device
-.RE
-
-.IP \[bu] 3
+- global/suffix
+.br
+- global/units
+.br
+- report/aligned
+.br
+- report/binary_values_as_numeric
+.br
+- report/columns_as_rows
+.br
+- report/compact_output
+.br
+- report/compact_output_cols
+.br
+- report/headings
+.br
+- report/list_item_separator
+.br
+- report/mark_hidden_devices
+.br
+- report/output_format
+.br
+- report/prefixes
+.br
+- report/quoted
+.br
+- report/separator
+.br
+- report/time_format
+.br
+- report/two_word_unknown_device
+.
+.TP
 Special settings
-.RS
-.IP - 3
-report/buffered
-.RE
-
-.RE
-
-.RE
-
+- report/buffered
+.ad b
+.P
 This document does not describe these settings in more detail - if you need
 detailed information, including values which are accepted for the settings,
 please run \fBlvmconfig --type default --withcomments <setting>\fP. There are
@@ -115,285 +111,286 @@ see \fBmain report specifics\fP and \fBlog report specifics\fP for
 these settings. Besides configuring reports globally by using configuration
 settings, there are also command line options you can use to extend, override
 or further specify the report configuration.
-
+.
+.SS Common command line options
+.
+.TP
+Definition of the set of fields to use
 .RS
-\fBCommon command line options:\fP
-
-.RS
-
-.IP \[bu] 3
-Definition of the set set of fields to use
-.RS
-.IP - 3
---options|-o FieldSet
-.br
+.
+.TP
+.BR -o | --options " " \fIFieldSet
 Field set to use. See \fBmain report specifics\fP and
 \fBlog report specifics\fP for information about field sets configured with
 global configuration settings that this option overrides.
-.IP - 3
---options|-o+ FieldSet
-.br
+.
+.TP
+.BR -o | --options " " +\fIFieldSet
 Fields to include to current field set. See \fBmain report specifics\fP\ and
 \fBlog report specifics\fP for information about field sets configured with
 global configuration settings that this option extends.
-.IP - 3
---options|-o- FieldSet
-.br
+.
+.TP
+.BR -o | --options " " -\fIFieldSet
 Fields to exclude from current field set. See \fBmain report specifics\fP and
 \fBlog report specifics\fP for information about field sets configured with
 global configuration settings that this option reduces.
-.IP - 3
---options|-o# FieldSet
-.br
+.
+.TP
+.BR -o | --options " " # \fIFieldSet
 Compaction of unused fields. Overrides report/compact_output_cols configuration
 setting.
 .RE
-
-.IP \[bu] 3
+.
+.TP
 Sorting
 .RS
-.IP - 3
---sort|-O+ FieldSet
-.br
+.
+.TP
+.BR -O | --sort " " +\fIFieldSet
 Fields to sort by in ascending order. See \fBmain report specifics\fP and
 \fBlog report specifics\fP for information about field sets configured with
 global configuration settings that this option overrides.
-.IP - 3
---sort|-O- FieldSet
-.br
+.
+.TP
+.BR -O | --sort " " -\fIFieldSet
 Fields to sort by in descending order. See \fBmain report specifics\fP and
 \fBlog report specifics\fP for information about fields sets configured with
 global configuration settings that this options overrides.
 .RE
-
-.IP \[bu] 3
+.
+.TP
 Selection
 .RS
-.IP - 3
---select|-S Selection
-.br
+.TP
+.BR -S | --select " " \fISelection
 Define selection criteria for report output. For \fBlog report\fP, this also
 overrides log/command_log_selection configuration setting, see also
 \fBlog report specifics\fP.
 .RE
-
-.IP \[bu] 3
+.
+.TP
 Changing output format and composition
 .RS
-.IP - 3
---reportformat
-.br
+.TP
+.B --reportformat
 Overrides report/output_format configuration setting.
-.IP - 3
---aligned
-.br
+.TP
+.B --aligned
 Overrides report/aligned configuration setting.
-.IP - 3
---binary
-.br
+.TP
+.B --binary
 Overrides report/binary_values_as_numeric configuration setting.
-.IP - 3
---nameprefixes
-.br
+.TP
+.B --nameprefixes
 Overrides report/prefixes configuration setting.
-.IP - 3
---noheadings
-.br
+.TP
+.B --noheadings
 Overrides report/noheadings configuration setting.
-.IP - 3
---nosuffix
-.br
+.TP
+.B --nosuffix
 Overrides global/suffix configuration setting.
-.IP - 3
---rows
-.br
+.TP
+.B --rows
 Overrides report/columns_as_rows configuration setting.
-.IP - 3
---separator
-.br
+.TP
+.B --separator
 Overrides report/separator configuration setting.
-.IP - 3
---units
-.br
+.TP
+.B --units
 Overrides global/units configuration setting.
-.IP - 3
---unquoted
-.br
+.TP
+.B --unquoted
 Overrides report/quoted configuration setting.
 .RE
-
-.IP \[bu] 3
+.
+.TP
 Special options
 .RS
-.IP - 3
---configreport \fBReportName\fP
-.br
-This defines the \fBReportName\fP for which any subsequent -o|--columns,
--O|--sort or -S|--select applies to. See also \fBmain report specifics\fP
-and \fBlog report specifics\fP for possible \fBReportName\fP values.
-.IP - 3
---logonly
-.br
+.
+.TP
+.B --configreport \fIReportName
+This defines the \fIReportName\fP for which any subsequent
+.BR -o | --columns ,
+.BR -O | --sort
+or
+.BR -S | --select
+applies to. See also
+.B Main report specifics
+and
+.B Log report specifics
+for possible \fIReportName\fP values.
+.
+.TP
+.B --logonly
 When an LVM command contains both \fBmain report\fP and \fBlog report\fP,
 this option suppresses the \fBmain report\fP output and it causes the
 \fBlog report\fP output to be displayed only.
-.IP - 3
---unbuffered
-.br
+.
+.TP
+.B --unbuffered
 Overrides report/buffered configuration setting.
 .RE
-
-.RE
-
-.RE
-
-The \fBFieldSet\fP mentioned in the lists above is a set of field names where
-each field name is delimited by "," character. Field set definition, sorting
-and selection may be repeated on command line (-o+/-o- includes/excludes fields
+.P
+The \fIFieldSet\fP mentioned in the lists above is a set of field names where
+each field name is delimited by "\fB,\fP" character. Field set definition, sorting
+and selection may be repeated on command line (\fB-o\fP\fB+\fP/\fB-o\fP\fB-\fP
+includes/excludes fields
 to/from current list, for all the other repeatable options, the last value
 typed for the option on the command line is used). The \fBSelection\fP
 is a string with \fBselection criteria\fP, see also \fBSelection\fP paragraph
 below for more information about constructing these criteria.
-
-
-.SH Main report specifics
-
+.
+.SS Main report specifics
+.
 The \fBmain report\fP currently encompasses these distinct subtypes, referenced
-by their name - \fBReportName\fP as listed below. The command in parenthesis is
+by their name - \fIReportName\fP as listed below. The command in parenthesis is
 representative command that uses the main report subtype by default.
 Each subtype has its own configuration setting for global field set definition
-as well as sort field definition (listed below each individual \fBReportName\fP):
-
+as well as sort field definition (listed below each individual \fIReportName\fP):
+.
+.ad l
+.nh
 .RS
-
-.IP \[bu] 3
-\fBpv\fP representing report about Physical Volumes (\fBpvs\fP)
+.TP
+.B pv
+representing report about Physical Volumes
+(pvs)
 .RS
-.IP - 3
-report/pvs_cols
-.IP - 3
-report/pvs_sort
+- report/pvs_cols
+.br
+- report/pvs_sort
+.br
 .RE
-
-.IP \[bu] 3
-\fBpvseg\fP representing report about Physical Volume Segments (\fBpvs --segments\fP)
+.
+.TP
+.B pvseg
+representing report about Physical Volume Segments
+(pvs\ --segments)
 .RS
-.IP - 3
-report/pvseg_cols
-.IP - 3
-report/pvseg_sort
+- report/pvseg_cols
+.br
+- report/pvseg_sort
+.br
 .RE
-
-.IP \[bu] 3
-\fBvg\fP representing report about Volume Groups (\fBvgs\fP)
+.
+.TP
+.B vg
+representing report about Volume Groups (vgs)
 .RS
-.IP - 3
-report/vgs_cols
-.IP - 3
-report/vgs_sort
+- report/vgs_cols
+.br
+- report/vgs_sort
 .RE
-
-.IP \[bu] 3
-\fBlv\fP representing report about Logical Volumes (\fBlvs\fP)
+.
+.TP
+.B lv
+representing report about Logical Volumes (lvs)
 .RS
-.IP - 3
-report/lvs_cols
-.IP - 3
-report/lvs_sort
+- report/lvs_cols
+.br
+- report/lvs_sort
 .RE
-
-.IP \[bu] 3
-\fBseg\fP representing report about Logical Volume Segments (\fBlvs --segments\fP)
+.
+.TP
+.B seg
+representing report about Logical Volume Segments
+(lvs\ --segments)
 .RS
-.IP - 3
-report/segs_cols
-.IP - 3
-report/segs_sort
+- report/segs_cols
+.br
+- report/segs_sort
 .RE
-
-.IP \[bu] 3
-\fBfull\fP representing report combining all of the above as a whole (\fBlvm fullreport\fP)
+.
+.TP
+.B full
+representing report combining all of the above as a whole
+(lvm\ fullreport)
 .RS
-.IP - 3
-report/pvs_cols_full
-.IP - 3
-report/pvs_sort_full
-.IP - 3
-report/pvsegs_cols_full
-.IP - 3
-report/pvseg_sort_full
-.IP - 3
-report/vgs_cols_full
-.IP - 3
-report/vgs_sort_full
-.IP - 3
-report/lvs_cols_full
-.IP - 3
-report/lvs_sort_full
-.IP - 3
-report/segs_cols_full
-.IP - 3
-report/segs_sort_full
+- report/pvs_cols_full
+.br
+- report/pvs_sort_full
+.br
+- report/pvsegs_cols_full
+.br
+- report/pvseg_sort_full
+.br
+- report/vgs_cols_full
+.br
+- report/vgs_sort_full
+.br
+- report/lvs_cols_full
+.br
+- report/lvs_sort_full
+.br
+- report/segs_cols_full
+.br
+- report/segs_sort_full
 .RE
-
-.IP \[bu] 3
-\fBdevtype\fP representing report about device types (\fBlvm devtypes\fP)
+.
+.TP
+.B devtype
+representing report about device types
+(lvm\ devtypes)
 .RS
-.IP - 3
-report/devtypes_cols
-.IP - 3
-report/devtypes_sort
+- report/devtypes_cols
+.br
+- report/devtypes_sort
 .RE
-
 .RE
-
+.ad b
+.hy
+.P
 Use \fBpvs, vgs, lvs -o help\fP or \fBlvm devtypes -o help\fP to get complete
 list of fields that you can use for main report. The list of fields in the
 help output is separated in groups based on which report type they belong to.
 Note that LVM can change final report type used if fields from different
 groups are combined together. Some of these combinations are not allowed in
 which case LVM will issue an error.
-
+.P
 For all main report subtypes except \fBfull\fP, it's not necessary to use
-\fB--configreport ReportName\fP to denote which report any subsequent
-\fB-o, -O or -S\fP option applies to as they always apply to the single main
+\fB--configreport\fP \fIReportName\fP to denote which report any subsequent
+.BR -o ", " -O
+or \fB-S\fP option applies to as they always apply to the single main
 report type. Currently, \fBlvm fullreport\fP is the only command that
-includes more than one \fBmain report\fP subtype. Therefore, the --configreport
+includes more than one \fBmain report\fP subtype. Therefore, the \fB--configreport\fP
 is particularly suitable for the full report if you need to configure each of
 its subreports in a different way.
-
-
-.SH Log report specifics
-
+.
+.SS Log report specifics
+.
 You can enable log report with \fBlog/report_command_log\fP configuration
 setting - this functionality is disabled by default. The \fBlog report\fP
 contains a log collected during LVM command execution and then the log is
 displayed just like any other report known from main report. There is only one
 log report subtype as shown below together with related configuration settings
 for fields, sorting and selection:
-
+.
 .RS
-
-.IP \[bu] 3
-\fBlog\fP representing log report
-.RS
-.IP - 3
-log/command_log_cols
-.IP - 3
-log/command_log_sort
-.IP - 3
-log/command_log_selection
-.RE
-
+.
+.TP
+.B log
+representing log report
+.br
+- log/command_log_cols
+.br
+- log/command_log_sort
+.br
+- log/command_log_selection
 .RE
-
-You always need to use \fB--configreport log\fP together with \fB-o|--options,
--O|--sort or -S|--selection\fP to override configuration settings directly on
+.P
+You always need to use \fB--configreport log\fP together with
+.BR -o | --options ", " -O | --sort
+or
+.BR -S | --selection
+to override configuration settings directly on
 command line for \fBlog report\fP. When compared to \fBmain report\fP, in
 addition to usual configuration settings for report fields and sorting, the
 \fBlog report\fP has also configuration option for selection -
 \fBreport/command_log_selection\fP. This configuration setting is provided for
-convenience so it's not necessary to use \fB-S|--select\fP on command line
+convenience so it's not necessary to use
+.BR -S | --select
+on command line
 each time an LVM command is executed and we need the same selection criteria
 to be applied for \fBlog report\fP. Default selection criteria used for
 \fBlog report\fP are
@@ -402,7 +399,7 @@ This means that, by default, \fBlog report\fP doesn't display status messages
 about successful operation and it displays only rows with error, warning,
 print-type messages and messages about failure states (for more information,
 see \fBlog report content\fP below).
-
+.P
 .B Log report coverage
 .br
 Currently, when running LVM commands directly (not in LVM shell), the log
@@ -413,7 +410,7 @@ out of log report's coverage range, such message goes directly to output,
 bypassing the \fBlog report\fP. By default, that is \fBstandard error output\fP
 for error and warning messages and \fBstandard output\fP for common print-like
 messages.
-
+.P
 When running LVM commands in \fBLVM shell\fP, the log report covers the whole
 LVM command's execution, including command's \fBprocessing\fP as well as
 \fBinitialization\fP and \fBfinalization stage\fP. So from this point of view,
@@ -425,13 +422,13 @@ next command executed in the shell and then, after the command's run, the shell
 needs to display the log report for that recently executed command. If there
 is a failure or any other message issued during this time, the LVM will bypass
 \fBlog report\fP and display messages on output directly.
-
+.P
 For these reasons and for completeness, it's not possible to rely fully on
 \fBlog report\fP as the only indicator of LVM command's status and the only
 place where all messages issued during LVM command execution are collected.
 You always need to check whether the command has not failed out of log
 report's range by checking the non-report output too.
-
+.P
 To help with this, LVM can separate output which you can then redirect to
 any \fBcustom file descriptor\fP that you prepare before running an LVM
 command or LVM shell and then you make LVM to use these file descriptors
@@ -439,143 +436,155 @@ for different kinds of output by defining environment variables with file
 descriptor numbers. See also \fBLVM_OUT_FD\fP, \fBLVM_ERR_FD\fP and
 \fBLVM_REPORT_FD\fP environment variable description in \fBlvm\fP(8)
 man page.
-
+.P
 Also note that, by default, reports use the same file descriptor as
 common print-like messages, which is \fBstandard output\fP. If you plan to
 use \fBlog report\fP in your scripts or any external tool, you should use
 \fBLVM_OUT_FD\fP, \fBLVM_ERR_FD\fP and \fBLVM_REPORT_FD\fP to separate all
 output types to different file descriptors. For example, with bash, that
 would be:
-
+.P
 .RS
 LVM_OUT_FD=3 LVM_ERR_FD=4 LVM_REPORT_FD=5 <lvm command> 3>out_file 4>err_file 5>report_file
 .RE
-
+.P
 Where the <lvm_command> is either direct LVM command or LVM shell.
 You can collect all three types of output in particular files then.
-
+.P
 .B Log report content
-.br
+.P
 Each item in the log report consists of these set of fields providing various
 information:
-
-.RS
-
-.IP \[bu] 3
+.
+.TP
 Basic information (mandatory):
 .RS
-.IP - 3
-log_seq_num
-.br
+.TP
+.I log_seq_num
 Item sequence number. The sequence number is unique for each log item and it
 increases in the order of the log items as they appeared during LVM command
 execution.
-
-.IP - 3
-log_type
-.br
+.
+.TP
+.I log_type
 Type of log for the item. Currently, these types are used:
 .RS
-.IP
-\fBstatus\fP for any status information that is logged
-.IP
-\fBprint\fP for any common message printed while the log is collected
-.IP
-\fBerror\fP for any error message printed while the log is collected
-.IP
-\fBwarn\fP for any warning message printed while the log is collected
+.
+.TP
+.B status
+for any status information that is logged
+.
+.TP
+.B print
+for any common message printed while the log is collected
+.
+.TP
+.B error
+for any error message printed while the log is collected
+.
+.TP
+.B warn
+for any warning message printed while the log is collected
 .RE
-
-.IP - 3
-log_context
-.br
+.
+.TP
+.I log_context
 Context of the log for the item. Currently, two contexts are identified:
 .RS
-.IP
-\fBshell\fP for the log collected in the outermost code before and after
+.
+.TP
+.B shell
+for the log collected in the outermost code before and after
 executing concrete LVM commands
-.IP
-\fBprocessing\fP for the log collected while processing LVM entities during
+.
+.TP
+.B processing
+for the log collected while processing LVM entities during
 LVM command execution
 .RE
-
 .RE
-
-.IP \[bu] 3
+.
+.TP
 Message (mandatory):
 .RS
-.IP - 3
-log_message
-.br
+.
+.TP
+.I log_message
 Any message associated with current item. For \fBstatus\fP log type,
 the message contains either \fBsuccess\fP or \fBfailure\fP denoting
 current state. For \fBprint\fP, \fBerror\fP and \fBwarn\fP log types,
 the message contains the exact message of that type that got issued.
 .RE
-
-.IP \[bu] 3
+.
+.TP
 Object information (used only if applicable):
 .RS
-.IP - 3
-log_object_type field
-.br
+.
+.TP
+.I log_object_type field
 Type of the object processed. Currently, these object types are recognized:
 .RS
-.IP
-\fBcmd\fP for command as a whole
-.IP
-\fBorphan\fP for processing group of PVs not in any VG yet
-.IP
-\fBpv\fP for PV processing
-.IP
-\fBlabel\fP for direct PV label processing (without VG metadata)
-.IP
-\fBvg\fP for VG processing
-.IP
-\fBlv\fP for LV processing
+.
+.TP
+.B cmd
+for command as a whole
+.
+.TP
+.B orphan
+for processing group of PVs not in any VG yet
+.
+.TP
+.B pv
+for PV processing
+.
+.TP
+.B label
+for direct PV label processing (without VG metadata)
+.
+.TP
+.B vg
+for VG processing
+.
+.TP
+.B lv
+for LV processing
 .RE
-
-.IP - 3
-log_object_name
-.br
+.
+.TP
+.I log_object_name
 Name of the object processed.
-
-.IP - 3
-log_object_id
-.br
+.
+.TP
+.I log_object_id
 ID of the object processed.
-
-.IP - 3
-log_object_group
-.br
+.
+.TP
+.I log_object_group
 A group where the processed object belongs to.
-
-.IP - 3
-log_object_group_id
-.br
+.
+.TP
+.I log_object_group_id
 An ID of a group where the processed object belongs to.
 .RE
-
-.IP \[bu] 3
-Numeric status (used only if applicable)
+.
+.TP
+Numeric status (used only if applicable):
 .RS
-.IP - 3
-log_errno
-.br
+.
+.TP
+.I log_errno
 Error number associated with current item.
-.IP - 3
-log_ret_code
-.br
-Rreturn code associated with current item.
+.
+.TP
+.I log_ret_code
+Return code associated with current item.
 .RE
-
-.RE
-
-
-You can also run \fB<lvm_command> --configreport log -o help\fP to
+.P
+You can also run \fBlvm --configreport log -o help\fP to
 to display complete list of fields that you may use for the \fBlog report\fP.
-
-.SH Selection
+.
+.SS Selection
+.
 Selection is used for a report to display only rows that match
 \fBselection criteria\fP. All rows are displayed with the additional
 \fBselected\fP field (\fB-o selected\fP) displaying 1 if the row matches the
@@ -584,193 +593,218 @@ Selection is used for a report to display only rows that match
 The \fBstatement\fP consists of a \fBfield\fP name for which a set of valid
 \fBvalues\fP is defined using \fBcomparison operators\fP. For complete list
 of fields names that you can use in selection, see the output of
-\fB<lvm_command> -S help\fP. The help output also contains type of values
+\fBlvm -S help\fP. The help output also contains type of values
 that each field displays enclosed in brackets.
-
+.P
 .B List of operators recognized in selection criteria
+.P
 .RS
-.IP \[bu] 3
-Comparison operators (cmp_op)
+.TP
+Comparison operators (\fIcmp_op\fP)
+.PD 0
 .RS
-.IP
-\fB=~\fP matching regular expression.
-.IP
-\fB!~\fP not matching regular expression.
-.IP
-\fB= \fP equal to.
-.IP
-\fB!=\fP not equal to.
-.IP
-\fB>=\fP greater than or equal to.
-.IP
-\fB> \fP greater than
-.IP
-\fB<=\fP less than or equal to.
-.IP
-\fB< \fP less than.
+.TP
+.B =~
+matching regular expression.
+.TP
+.B !~
+not matching regular expression.
+.TP
+.B =
+equal to.
+.TP
+.B !=
+not equal to.
+.TP
+.B >=
+greater than or equal to.
+.TP
+.B >
+greater than
+.TP
+.B <=
+less than or equal to.
+.TP
+.B <
+less than.
 .RE
-
-.IP \[bu] 3
-Binary logical operators (cmp_log)
+.PD
+.
+.TP
+Binary logical operators (\fIcmp_log\fP)
+.PD 0
 .RS
-.IP
-\fB&&\fP all fields must match
-.IP
-\fB, \fP all fields must match
-.IP
-\fB||\fP at least one field must match
-.IP
-\fB# \fP@least one field must match
+.TP
+.B &&
+all fields must match
+.TP
+.B ,
+all fields must match
+.TP
+.B ||
+at least one field must match
+.TP
+.B #
+at least one field must match
 .RE
-
-.IP \[bu] 3
+.PD
+.
+.TP
 Unary logical operators
+.PD 0
 .RS
-.IP
-\fB! \fP logical negation
+.TP
+.B !
+logical negation
 .RE
-
-.IP \[bu] 3
+.PD
+.
+.TP
 Grouping operators
+.PD 0
 .RS
-.IP
-\fB( \fP left parenthesis
-.IP
-\fB) \fP right parenthesis
-.IP
-\fB[ \fP list start
-.IP
-\fB] \fP list end
-.IP
-\fB{ \fP list subset start
-.IP
-\fB} \fP list subset end
+.TP
+.B (
+left parenthesis
+.TP
+.B )
+right parenthesis
+.TP
+.B [
+list start
+.TP
+.B ]
+list end
+.TP
+.B {
+list subset start
+.TP
+.B }
+list subset end
 .RE
-
+.PD
 .RE
-
+.P
 .B Field types and selection operands
-.br
+.P
 Field type restricts the set of operators and values that you may use with
 the field when defining selection criteria. You can see field type for each
-field if you run \fB<lvm command> -S help\fP where you can find the type name
+field if you run \fBlvm -S help\fP where you can find the type name
 enclosed in square brackets. Currently, LVM recognizes these field types in
 reports:
-
+.
 .RS
-.IP \[bu] 3
-\fBstring\fP for set of characters (for each string field type, you can use
+.TP
+.B string
+for set of characters (for each string field type, you can use
 either string or regular expression - regex for the value used in selection
 criteria)
-.IP \[bu] 3
-\fBstring list\fP for set of strings
-.IP \[bu] 3
-\fBnumber\fP for integer value
-.IP \[bu] 3
-\fBsize\fP for integer or floating point number with size unit suffix
+.TP
+.B string list
+for set of strings
+.TP
+.B number
+for integer value
+.TP
+.B size
+for integer or floating point number with size unit suffix
 (see also \fBlvcreate\fP(8) man page and description for "-L|--size"
 option for the list of recognized suffixes)
-.IP \[bu] 3
-\fBpercent\fP for floating point number with or without "%" suffix
+.TP
+.B percent\fP for floating point number with or without "%" suffix
 (e.g. 50 or 50%)
-.IP \[bu] 3
-\fBtime\fP for time values
+.TP
+.B time
+for time values
 .RE
-
+.P
 When using \fBstring list\fP in selection criteria, there are several ways
 how LVM can match string list fields from report, depending on what list
 grouping operator is used and what item separator is used within that set
 of items. Also, note that order of items does not matter here.
-
-.RS
+.P
 .IP \[bu] 3
 \fBmatching the set strictly\fP where all items must match - use [ ], e.g.
 ["a","b","c"]
-.IP \[bu] 3
+.IP \[bu]
 \fBmatching a subset of the set\fP - use { } with "," or "&&" as item
 delimiter, e.g. {"a","b","c"}
-.IP \[bu] 3
+.IP \[bu]
 \fBmatching an intersection with the set\fP - use { } with "#" or
 "||" as item delimiter, e.g. {"a" || "b" || "c"}
-.RE
-
+.P
 When using \fBtime\fP in your selection criteria, LVM can recognize various
 time formats using standard, absolute or freeform expressions. For examples
 demonstrating time expressions in selection criteria, see \fBEXAMPLES\fP section.
-
-.RS
-
+.
 .IP \[bu] 3
-\fBStandard time format\fP
-
+.B Standard time format
 .RS
 .IP - 3
 date
 .RS
-.IP
+.RS
 YYYY-MM-DD
-.IP
+.br
 YYYY-MM, auto DD=1
-.IP
+.br
 YYYY, auto MM=01 and DD=01
 .RE
-
-.IP - 3
+.RE
+.
+.IP -
 time
 .RS
-.IP
+.RS
 hh:mm:ss
-.IP
+.br
 hh:mm, auto ss=0
-.IP
+.br
 hh, auto mm=0, auto ss=0
 .RE
-
-.IP - 3
+.RE
+.
+.IP -
 timezone
 .RS
-.IP
+.RS
 +hh:mm or -hh:mm
-.IP
+.br
 +hh or -hh
 .RE
-
+.RE
+.P
 The full date/time specification is YYYY-MM-DD hh:mm:ss. Users are able
 to leave date/time parts from right to left. Whenever these parts are left out,
 a range is assumed automatically with second granularity. For example:
-
-.RS
-.IP
-"2015-07-07 9:51" means range of "2015-07-07 9:51:00" - "2015-07-07 9:51:59".
-.IP
+.P
+.nf
+"2015-07-07 9:51" means range of "2015-07-07 9:51:00" - "2015-07-07 9:51:59"
 "2015-07" means range of "2015-07-01 0:00:00" - "2015-07-31 23:59:59"
-.IP
 "2015" means range of "2015-01-01 0:00:00" - "2015-12-31 23:59:59"
+.fi
 .RE
-
-.RE
-
+.P
 .IP \[bu] 3
-\fBAbsolute time format\fP
-
+.B Absolute time format
+.br
 Absolute time is defined as number of seconds since the Epoch
 (1970:01:01 00:00 +00:00).
-
 .RS
 .IP - 3
 @seconds
 .RE
-
 .IP \[bu] 3
-\fBFreeform time format\fP
+.B Freeform time format
 .RS
+.PD 0
 .IP - 3
 weekday names ("Sunday" - "Saturday" or abbreviated as "Sun" - "Sat")
-.IP - 3
+.IP -
 labels for points in time ("noon", "midnight")
-.IP - 3
+.IP -
 labels for a day relative to current day ("today", "yesterday")
-.IP - 3
+.IP -
 points back in time with relative offset from today (N is a number)
 .RS
 .IP
@@ -782,41 +816,40 @@ points back in time with relative offset from today (N is a number)
 .RE
 .IP - 3
 time specification either in hh:mm:ss format or with AM/PM suffixes
-.IP - 3
+.IP -
 month names ("January" - "December" or abbreviated as "Jan" - "Dec")
 .RE
-
-.RE
-
+.PD
+.P
 .B Informal grammar specification
-.RS
-.IP
-.BR STATEMENT " = " column " cmp_op " VALUE " | " \%STATEMENT " log_op " STATEMENT " | " \%(STATEMENT) " | " \%!(STATEMENT)
-.IP
-.BR VALUE " = " [VALUE " log_op " VALUE]
+.IP - 2
+.B STATEMENT = column \fIcmp_op\fP VALUE \fR|
+.B STATEMENT \fIlog_op\fP STATEMENT \fR|
+.B (STATEMENT) \fR|\fP !(STATEMENT)
+.IP -
+.B VALUE = [VALUE \fIlog_op\fP VALUE]
 .br
 For list-based types: string list. Matches strictly.
 The log_op must always be of one type within the whole list value.
-.IP
-.BR VALUE " = " {VALUE " log_op " VALUE}
+.IP -
+.B VALUE = {VALUE \fIlog_op\fP VALUE}
 .br
 For list-based types: string list. Matches a subset.
 The log_op must always be of one type within the whole list value.
-.IP
+.IP -
 .BR VALUE " = " value
 .br
 For scalar types: number, size, percent, string (or string regex).
-.RE
-
+.
 .SH EXAMPLES
-
+.
 .SS Basic usage
-
+.
 We start our examples with default configuration - \fBlvmconfig\fP(8) is
 helpful command to display configuration settings which are currently used,
 including all configuration related to reporting. We will use it throughout
 examples below to display current configuration.
-
+.P
 .nf
 # lvmconfig --type full global/units global/suffix \\
    report/output_format  report/compact_output \\
@@ -845,14 +878,14 @@ mark_hidden_devices=1
 two_word_unknown_device=0
 buffered=1
 .fi
-
+.P
 Also, we start with simple LVM layout with two PVs (/dev/sda, /dev/sdb),
 VG (vg) and two LVs (lvol0 and lvol1) in the VG. We display all possible
 reports as single commands here, see also \fBpvs\fP(8), \fBvgs\fP(8),
 \fBlvs\fP(8) man pages for more information. The field set for each report
 type is configured with configuration settings as we already mentioned in
 \fBmain report specifics\fP section in this man page.
-
+.P
 .nf
 # lvmconfig --type full report/pvs_cols report/pvs_sort \\
    report/pvsegs_cols report/pvsegs_sort report/vgs_cols \\
@@ -871,13 +904,13 @@ lvs_sort="vg_name,lv_name"
 segs_cols="lv_name,vg_name,lv_attr,stripes,segtype,seg_size"
 segs_sort="vg_name,lv_name,seg_start"
 .fi
-
+.P
 .nf
 # pvs
   PV         VG Fmt  Attr PSize   PFree
   /dev/sda   vg lvm2 a--  100.00m 88.00m
   /dev/sdb   vg lvm2 a--  100.00m 92.00m
-
+.P
 # pvs --segments
   PV         VG Fmt  Attr PSize   PFree  Start SSize
   /dev/sda   vg lvm2 a--  100.00m 88.00m     0     1
@@ -887,74 +920,76 @@ segs_sort="vg_name,lv_name,seg_start"
   /dev/sdb   vg lvm2 a--  100.00m 92.00m     0     1
   /dev/sdb   vg lvm2 a--  100.00m 92.00m     1     1
   /dev/sdb   vg lvm2 a--  100.00m 92.00m     2    23
-
+.P
 # vgs
   VG #PV #LV #SN Attr   VSize   VFree
   vg   2   2   0 wz--n- 200.00m 180.00m
-
+.P
 # lvs
   LV    VG Attr       LSize Pool Origin Move Log Cpy%Sync Convert
   lvol0 vg -wi-a----- 4.00m
   lvol1 vg rwi-a-r--- 4.00m                      100.00
-
+.P
 # lvs --segments
   LV    VG Attr       #Str Type   SSize
   lvol0 vg -wi-a-----    1 linear 4.00m
   lvol1 vg rwi-a-r---    2 raid1  4.00m
 .fi
-
+.P
 We will use \fBreport/lvs_cols\fP and \fBreport/lvs_sort\fP configuration
 settings to define our own list of fields to use and to sort by that is
 different from defaults. You can do this for other reports in same manner
 with \fBreport/{pvs,pvseg,vgs,seg}_{cols,sort}\fP configuration settings.
 Also note that in the example below, we don't display the "lv_time" field
 even though we're using it for sorting - this is allowed.
-
+.P
 .nf
 # lvmconfig --type full report/lvs_cols report/lvs_sort
 lvs_cols="lv_name,lv_size,origin,pool_lv,copy_percent"
 lvs_sort="-lv_time"
-
+.P
 # lvs
   LV    LSize Origin Pool Cpy%Sync
   lvol1 4.00m             100.00
   lvol0 4.00m
 .fi
-
-You can use \fB-o|--options\fP command line option to override current
+.P
+You can use
+.BR -o | --options
+command line option to override current
 configuration directly on command line.
-
+.P
 .nf
 # lvs -o lv_name,lv_size
   LV    LSize
   lvol1 4.00m
   lvol0 4.00m
-
+.P
 # lvs -o+lv_layout
   LV    LSize Origin Pool Cpy%Sync Layout
   lvol1 4.00m             100.00   raid,raid1
   lvol0 4.00m                      linear
-
+.P
 # lvs -o-origin
   LV    LSize Pool Cpy%Sync
   lvol1 4.00m      100.00
   lvol0 4.00m
-
+.P
 # lvs -o lv_name,lv_size,origin -o+lv_layout -o-origin -O lv_name
   LV    LSize Layout
   lvol0 4.00m linear
   lvol1 4.00m raid,raid1
 .fi
-
+.P
 You can obtain the same information with single command where all the
 information about PVs, PV segments, LVs and LV segments are obtained
-per VG under a single VG lock for consistency, see also \fBlvm-fullreport\fP(8)
+per VG under a single VG lock for consistency, see also \fBlvm fullreport\fP(8)
 man page for more information. The fullreport has its own configuration
 settings to define field sets to use, similar to individual reports as
 displayed above, but configuration settings have "_full" suffix now.
 This way, it's possible to configure different sets of fields to display
 and to sort by for individual reports as well as the full report.
-
+.P
 .nf
 # lvmconfig --type full report/pvs_cols_full \\
    report/pvs_sort_full report/pvsegs_cols_full \\
@@ -973,7 +1008,7 @@ lvs_sort_full="vg_name,lv_name"
 segs_cols_full="lv_name,seg_start,seg_size"
 segs_sort_full="lv_uuid,seg_start"
 .fi
-
+.P
 .nf
 # lvm fullreport
   VG
@@ -996,81 +1031,82 @@ segs_sort_full="lv_uuid,seg_start"
   lvol0    0  4.00m
   lvol1    0  4.00m
 .fi
-
+.
 .SS Automatic output compaction
-
+.
 If you look at the lvs output above, you can see that the report also contains
 fields for which there is no information to display (e.g. the columns under
 "Origin" and "Pool" heading - the "origin" and "pool_lv" fields). LVM can
 automatically compact report output so such fields are not included in final
 output. To enable this feature and to compact all fields, use
 \fBreport/compact_output=1\fP in your configuration.
-
+.P
 .nf
 # lvmconfig --type full report/compact_output
 compact_output=1
-
+.P
 # lvs
   LV    LSize Cpy%Sync
   lvol1 4.00m 100.00
   lvol0 4.00m
-
+.P
 # lvs vg/lvol0
   LV    LSize
   lvol0 4.00m
 .fi
-
+.P
 Alternatively, you can define which fields should be compacted by configuring
-\fBreport/compact_output_cols\fP configuration setting (or \fB-o|--options #\fP
+\fBreport/compact_output_cols\fP configuration setting (or
+.BR -o | --options " " #
 command line option).
-
+.P
 .nf
 # lvmconfig --type full report/compact_output report/compact_output_cols
 compact_output=0
 compact_output_cols="origin"
-
+.P
 # lvs
   LV    LSize Pool Cpy%Sync
   lvol1 4.00m      100.00
   lvol0 4.00m
-
+.P
 # lvs vg/lvol0
   LV    LSize Pool
   lvol0 4.00m
-
+.P
 # lvs -o#pool_lv
   LV    LSize Origin Cpy%Sync
   lvol1 4.00m        100.00
   lvol0 4.00m
 .fi
-
+.P
 We will use \fBreport/compact_output=1\fP for subsequent examples.
-
+.
 .SS Further formatting options
-
+.
 By default, LVM displays sizes in reports in human-readable form which means
 that the most suitable unit is used so it's easy to read. You can use
 \fBreport/units\fP configuration setting (or \fB--units\fP option directly
 on command line) and \fBreport/suffix\fP
 configuration setting (or \fB--nosuffix\fP command line option) to change this.
-
+.P
 .nf
 # lvs --units b --nosuffix
   LV    LSize   Cpy%Sync
   lvol1 4194304 100.00
   lvol0 4194304
 .fi
-
+.P
 If you want to configure whether report headings are displayed or not, use
 \fBreport/headings\fP configuration settings (or \fB--noheadings\fP command
 line option).
-
+.P
 .nf
 # lvs --noheadings
   lvol1 4.00m 100.00
   lvol0 4.00m
 .fi
-
+.P
 In some cases, it may be useful to display report content as key=value pairs
 where key here is actually the field name. Use \fBreport/prefixes\fP
 configuration setting (or \fB--nameprefixes\fP command line option) to switch
@@ -1078,122 +1114,122 @@ between standard output and the key=value output. The key=value pair is the
 output that is suitable for use in scripts and for other tools to parse easily.
 Usually, you also don't want to display headings with the output that has these
 key=value pairs.
-
+.P
 .nf
 # lvs --noheadings --nameprefixes
   LVM2_LV_NAME='lvol1' LVM2_LV_SIZE='4.00m' LVM2_COPY_PERCENT='100.00'
   LVM2_LV_NAME='lvol0' LVM2_LV_SIZE='4.00m' LVM2_COPY_PERCENT=''
 .fi
-
+.P
 To define whether quotation marks in key=value pairs should be used or not,
 use \fBreport/quoted\fP configuration setting (or \fB--unquoted\fP command
 line option).
-
+.P
 .nf
 # lvs --noheadings --nameprefixes --unquoted
   LVM2_LV_NAME=lvol1 LVM2_LV_SIZE=4.00m LVM2_COPY_PERCENT=100.00
   LVM2_LV_NAME=lvol0 LVM2_LV_SIZE=4.00m LVM2_COPY_PERCENT=
 .fi
-
+.P
 For easier parsing, you can even transpose the report so each column now
 becomes a row in the output. This is done with \fBreport/output_as_rows\fP
 configuration setting (or \fB--rows\fP command line option).
-
+.P
 .nf
 # lvs --noheadings --nameprefixes --unquoted --rows
   LVM2_LV_NAME=lvol1 LVM2_LV_NAME=lvol0
   LVM2_LV_SIZE=4.00m LVM2_LV_SIZE=4.00m
   LVM2_COPY_PERCENT=100.00 LVM2_COPY_PERCENT=
 .fi
-
+.P
 Use \fBreport/separator\fP configuration setting (or \fB--separator\fP command
 line option) to define your own field separator to use.
-
+.P
 .nf
 # lvs --noheadings --nameprefixes --unquoted --separator " | "
   LVM2_LV_NAME=lvol1 | LVM2_LV_SIZE=4.00m | LVM2_COPY_PERCENT=100.00
   LVM2_LV_NAME=lvol0 | LVM2_LV_SIZE=4.00m | LVM2_COPY_PERCENT=
 .fi
-
+.P
 If you are using your own separator, the columns in the output are not aligned
 by default. Use \fBreport/aligned\fP configuration setting (or \fB--aligned\fP
 command line option) for LVM to add extra spaces in report to align the output
 properly.
-
+.P
 .nf
 # lvs --separator " | "
   LV | LSize | Cpy%Sync
   lvol1 | 4.00m | 100.00
   lvol0 | 4.00m |
-
+.P
 # lvs --separator " | " --aligned
   LV    | LSize | Cpy%Sync
   lvol1 | 4.00m | 100.00
   lvol0 | 4.00m |
 .fi
-
+.P
 Let's display one one more field in addition ("lv_tags" in this example)
 for the lvs report output.
-
+.P
 .nf
 # lvs -o+lv_tags
   LV    LSize Cpy%Sync LV Tags
   lvol1 4.00m 100.00
   lvol0 4.00m          tagA,tagB
 .fi
-
+.P
 The "LV Tags" column in the example above displays two list values,
 separated by "," character for LV lvol0. If you need different list item
 separator, use \fBreport/list_item_separator\fP configuration setting its
 definition.
-
+.P
 .nf
 # lvmconfig --type full report/list_item_separator
 list_item_separator=";"
-
+.P
 # lvs -o+tags
   LV    LSize Cpy%Sync LV Tags
   lvol1 4.00m 100.00
   lvol0 4.00m          tagA;tagB
 .fi
-
+.P
 But let's still use the original "," character for list_item_separator
 for subsequent examples.
-
+.P
 Format for any of time values displayed in reports can be configured with
 \fBreport/time_format\fP configuretion setting. By default complete date
 and time is displayed, including timezone.
-
+.P
 .nf
 # lvmconfig --type full report/time_format
 time_format="%Y-%m-%d %T %z"
-
+.P
 # lvs -o+time
   LV    LSize Cpy%Sync CTime
   lvol1 4.00m 100.00   2016-08-29 12:53:36 +0200
   lvol0 4.00m          2016-08-29 10:15:17 +0200
 .fi
-
+.P
 We can change time format in similar way as we do when using \fBdate\fP(1)
 command or \fBstrftime\fP(3) function
 (\fBlvmconfig --type default --withcomments report/time_format\fP will
 give you complete list of available formatting options). In the example
 below, we decided to use %s for number of seconds since Epoch (1970-01-01 UTC).
-
+.P
 .nf
 # lvmconfig --type full report/time_format
 time_format="%s"
-
+.P
 # lvs
   LV    Attr       LSize Cpy%Sync LV Tags   CTime
   lvol1 rwi-a-r--- 4.00m 100.00             1472468016
   lvol0 -wi-a----- 4.00m          tagA,tagB 1472458517
 .fi
-
+.P
 The \fBlvs\fP does not display hidden LVs by default - to include these LVs
 in the output, you need to use \fB-a|--all\fP command line option. Names for
 these hidden LVs are displayed within square brackets.
-
+.P
 .nf
 # lvs -a
   LV               LSize Cpy%Sync
@@ -1204,14 +1240,14 @@ these hidden LVs are displayed within square brackets.
   [lvol1_rmeta_1]  4.00m
   lvol0            4.00m
 .fi
-
+.P
 You can configure LVM to display the square brackets for hidden LVs or not with
 \fBreport/mark_hidden_devices\fP configuration setting.
-
+.P
 .nf
 # lvmconfig --type full report/mark_hidden_devices
 mark_hidden_devices=0
-
+.P
 # lvs -a
   LV             LSize Cpy%Sync
   lvol1          4.00m 100.00
@@ -1221,12 +1257,12 @@ mark_hidden_devices=0
   lvol1_rmeta_1  4.00m
   lvol0          4.00m
 .fi
-
+.P
 It's not recommended to use LV marks for hidden devices to decide whether the
 LV is the one to use by end users or not. Please, use "lv_role" field instead
 which can report whether the LV is "public" or "private". The private LVs are
 used by LVM only and they should not be accessed directly by end users.
-
+.P
 .nf
 # lvs -a -o+lv_role
   LV             LSize Cpy%Sync Role
@@ -1237,39 +1273,39 @@ used by LVM only and they should not be accessed directly by end users.
   lvol1_rmeta_1  4.00m          private,raid,metadata
   lvol0          4.00m          public
 .fi
-
+.P
 Some of the reporting fields that LVM reports are of binary nature. For such
 fields, it's either  possible to display word representation of the value
 (this is used by default) or numeric value (0/1 or -1 in case the value is
 undefined).
-
+.P
 .nf
 # lvs -o+lv_active_locally
   LV    LSize Cpy%Sync ActLocal
   lvol1 4.00m 100.00   active locally
   lvol0 4.00m          active locally
 .fi
-
+.P
 We can change the way how these binary values are displayed with
 \fBreport/binary_values_as_numeric\fP configuration setting.
-
+.P
 .nf
 # lvmconfig --type full report/binary_values_as_numeric
 binary_values_as_numeric=1
-
+.P
 # lvs -o+lv_active_locally
   LV    LSize Cpy%Sync ActLocal
   lvol1 4.00m 100.00            1
   lvol0 4.00m                   1
 .fi
-
+.
 .SS Changing output format
-
+.
 LVM can output reports in different formats - use \fBreport/output_format\fP
 configuration setting (or \fB--reportformat\fP command line option) to swith
 the report output format. Currently, LVM supports \fB"basic"\fP (all the examples
 we used above used this format) and \fB"JSON"\fP output format.
-
+.P
 .nf
 # lvs -o lv_name,lv_size --reportformat json
   {
@@ -1283,7 +1319,7 @@ we used above used this format) and \fB"JSON"\fP output format.
       ]
   }
 .fi
-
+.P
 Note that some configuration settings and command line options have no
 effect with certain report formats. For example, with \fBJSON\fP output,
 it doesn't have any meaning to use \fBreport/aligned\fP (\fB--aligned\fP),
@@ -1291,26 +1327,26 @@ it doesn't have any meaning to use \fBreport/aligned\fP (\fB--aligned\fP),
 (\fB--rows\fP) or \fBreport/buffered\fP (\fB--unbuffered\fP). All these
 configuration settings and command line options are ignored if using the
 \fBJSON\fP report output format.
-
+.
 .SS Selection
-
+.
 If you need to select only specific rows from report, you can use LVM's
-report selection feature. If you call \fB<lvm_command> -S help\fP, you'll get
+report selection feature. If you call \fBlvm -S help\fP, you'll get
 quick help on selection. The help contains list of all fields that LVM
 can use in reports together with its type enclosed in square brackets.
 The example below contains a line from lvs -S help.
-
+.P
 .nf
 # lvs -S help
     ...
     lv_size                - Size of LV in current units. [size]
     ...
 .fi
-
+.P
 This line tells you you that the "lv_size" field is of "size" type. If you
 look at the bottom of the help output, you can see section about
 "Selection operators" and its "Comparison operators".
-
+.P
 .nf
 # lvs -S help
  ...
@@ -1328,18 +1364,18 @@ Comparison operators:
 since  - Since specified time (same as '>='). [time]
 after  - After specified time (same as '>'). [time]
 until  - Until specified time (same as '<='). [time]
-before  - Before specified time (same as '<'). [time]
+before - Before specified time (same as '<'). [time]
  ...
 .fi
-
+.P
 Here you can match comparison operators that you may use with the "lv_size"
 field which is of type "size" - it's =, !=, >=, >, <= and <. You can find
 applicable comparison operators for other fields and other field types the
 same way.
-
+.P
 To demonstrate selection functionality in LVM, we will create more LVs in
 addition to lvol0 and lvol1 we used in our previous examples.
-
+.P
 .nf
 # lvs -o name,size,origin,snap_percent,tags,time
   LV    LSize Origin Snap%  LV Tags        CTime
@@ -1349,132 +1385,132 @@ addition to lvol0 and lvol1 we used in our previous examples.
   lvol1 4.00m                              2016-08-29 12:53:36 +0200
   lvol0 4.00m               tagA,tagB      2016-08-29 10:15:17 +0200
 .fi
-
+.P
 When selecting size and percent fields, we don't need to use units.
 For sizes, default "m" (for MiB) is used - this is the same behaviour
 as already used for LVM commands when specifying sizes (e.g. lvcreate -L).
 For percent fields, "%" is assumed automatically if it's not specified.
 The example below also demonstrates how several criteria can be combined
 together.
-
+.P
 .nf
 # lvs -o name,size,snap_percent -S 'size=8m'
   LV    LSize
   lvol2 8.00m
-
+.P
 # lvs -o name,size,snap_percent -S 'size=8'
   LV    LSize
   lvol2 8.00m
-
+.P
 # lvs -o name,size,snap_percent -S 'size < 5000k'
   LV    LSize Snap%
   lvol4 4.00m 24.61
   lvol3 4.00m 5.08
   lvol1 4.00m
   lvol0 4.00m
-
+.P
 # lvs -o name,size,snap_percent -S 'size < 5000k && snap_percent > 20'
   LV    LSize Snap%
   lvol4 4.00m 24.61
-
+.P
 # lvs -o name,size,snap_percent \\
     -S '(size < 5000k && snap_percent > 20%) || name=lvol2'
   LV    LSize Snap%
   lvol4 4.00m 24.61
   lvol2 8.00m
 .fi
-
+.P
 You can also use selection together with processing-oriented commands.
-
+.P
 .nf
 # lvchange --addtag test -S 'size < 5000k'
   Logical volume vg/lvol1 changed.
   Logical volume vg/lvol0 changed.
   Logical volume vg/lvol3 changed.
   Logical volume vg/lvol4 changed.
-
+.P
 # lvchange --deltag test -S 'tags = test'
   Logical volume vg/lvol1 changed.
   Logical volume vg/lvol0 changed.
   Logical volume vg/lvol3 changed.
   Logical volume vg/lvol4 changed.
 .fi
-
+.P
 LVM can recognize more complex values used in selection criteria for
 string list and time field types. For string lists, you can match
 whole list strictly, its subset or intersection. Let's take "lv_tags"
 field as an example - we select only rows which contain "tagA" within
 tags field. We're using { } to denote that we're interested in subset
 that matches. If the subset has only one item, we can leave out { }.
-
+.P
 .nf
 # lvs -o name,tags -S 'tags={tagA}'
   LV    LV Tags
   lvol2 tagA,tagC,tagD
   lvol0 tagA,tagB
-
+.P
 # lvs -o name,tags -S 'tags=tagA'
   LV    LV Tags
   lvol2 tagA,tagC,tagD
   lvol0 tagA,tagB
 .fi
-
+.P
 Depending on whether we use "&&" (or ",") or "||" ( or "#") as delimiter
 for items in the set we define in selection criterion for string list,
 we either match subset ("&&" or ",") or even intersection ("||" or "#").
-
+.P
 .nf
 # lvs -o name,tags -S 'tags={tagA,tagC,tagD}'
   LV    LV Tags
   lvol2 tagA,tagC,tagD
-
+.P
 # lvs -o name,tags -S 'tags={tagA || tagC || tagD}'
   LV    LV Tags
   lvol2 tagA,tagC,tagD
   lvol0 tagA,tagB
 .fi
-
+.P
 To match the complete set, use [ ] with "&&" (or ",") as delimiter for items.
 Also note that the order in which we define items in the set is not relevant.
-
+.P
 .nf
 # lvs -o name,tags -S 'tags=[tagA]'
-
+.P
 # lvs -o name,tags -S 'tags=[tagB,tagA]'
   LV    LV Tags
   lvol0 tagA,tagB
 .fi
-
+.P
 If you use [ ] with "||" (or "#"), this is exactly the same as using { }.
-
+.P
 .nf
 # lvs -o name,tags -S 'tags=[tagA || tagC || tagD]'
   LV    LV Tags
   lvol2 tagA,tagC,tagD
   lvol0 tagA,tagB
 .fi
-
+.P
 To match a set with no items, use "" to denote this (note that we have
 output compaction enabled so the "LV Tags" column is not displayed in
 the example below because it's blank and so it gets compacted).
-
+.P
 .nf
 # lvs -o name,tags -S 'tags=""'
   LV
   lvol4
   lvol3
   lvol1
-
+.P
 # lvs -o name,tags -S 'tags!=""'
   LV    LV Tags
   lvol2 tagA,tagC,tagD
   lvol0 tagA,tagB
 .fi
-
+.P
 When doing selection based on time fields, we can use either standard,
 absolute or freeform time expressions in selection criteria. Examples below
 are using standard forms.
-
+.P
 .nf
 # lvs -o name,time
   LV    CTime
@@ -1483,39 +1519,39 @@ are using standard forms.
   lvol2 2016-09-09 16:55:12 +0200
   lvol1 2016-08-29 12:53:36 +0200
   lvol0 2016-08-29 10:15:17 +0200
-
+.P
 # lvs -o name,time -S 'time since "2016-09-01"'
   LV    CTime
   lvol4 2016-09-09 16:57:44 +0200
   lvol3 2016-09-09 16:56:48 +0200
   lvol2 2016-09-09 16:55:12 +0200
-
+.P
 # lvs -o name,time -S 'time since "2016-09-09 16:56"'
   LV    CTime
   lvol4 2016-09-09 16:57:44 +0200
   lvol3 2016-09-09 16:56:48 +0200
-
+.P
 # lvs -o name,time -S 'time since "2016-09-09 16:57:30"'
   LV    CTime
   lvol4 2016-09-09 16:57:44 +0200
-
+.P
 # lvs -o name,time \\
     -S 'time since "2016-08-29" && time until "2016-09-09 16:55:12"'
   LV    CTime
   lvol2 2016-09-09 16:55:12 +0200
   lvol1 2016-08-29 12:53:36 +0200
   lvol0 2016-08-29 10:15:17 +0200
-
+.P
 # lvs -o name,time \\
     -S 'time since "2016-08-29" && time before "2016-09-09 16:55:12"'
   LV    CTime
   lvol1 2016-08-29 12:53:36 +0200
   lvol0 2016-08-29 10:15:17 +0200
 .fi
-
+.P
 Time operators have synonyms: ">=" for since, "<=" for until,
 ">" for "after" and "<" for "before".
-
+.P
 .nf
 # lvs -o name,time \\
     -S 'time >= "2016-08-29" && time <= "2016-09-09 16:55:30"'
@@ -1523,16 +1559,16 @@ Time operators have synonyms: ">=" for since, "<=" for until,
   lvol2 2016-09-09 16:55:12 +0200
   lvol1 2016-08-29 12:53:36 +0200
   lvol0 2016-08-29 10:15:17 +0200
-
+.P
 # lvs -o name,time \\
     -S 'time since "2016-08-29" && time < "2016-09-09 16:55:12"'
   LV    CTime
   lvol1 2016-08-29 12:53:36 +0200
   lvol0 2016-08-29 10:15:17 +0200
 .fi
-
+.P
 Example below demonstrates using absolute time expression.
-
+.P
 .nf
 # lvs -o name,time --config report/time_format="%s"
   LV    CTime
@@ -1541,15 +1577,15 @@ Example below demonstrates using absolute time expression.
   lvol2 1473432912
   lvol1 1472468016
   lvol0 1472458517
-
+.P
 # lvs -o name,time -S 'time since @1473433008'
   LV    CTime
   lvol4 2016-09-09 16:57:44 +0200
   lvol3 2016-09-09 16:56:48 +0200
 .fi
-
+.P
 Examples below demonstrates using freeform time expressions.
-
+.P
 .nf
 # lvs -o name,time -S 'time since "2 weeks ago"'
   LV    CTime
@@ -1558,29 +1594,29 @@ Examples below demonstrates using freeform time expressions.
   lvol2 2016-09-09 16:55:12 +0200
   lvol1 2016-08-29 12:53:36 +0200
   lvol0 2016-08-29 10:15:17 +0200
-
+.P
 # lvs -o name,time -S 'time since "1 week ago"'
   LV    CTime
   lvol4 2016-09-09 16:57:44 +0200
   lvol3 2016-09-09 16:56:48 +0200
   lvol2 2016-09-09 16:55:12 +0200
-
+.P
 # lvs -o name,time -S 'time since "2 weeks ago"'
   LV    CTime
   lvol1 2016-08-29 12:53:36 +0200
   lvol0 2016-08-29 10:15:17 +0200
-
+.P
 # lvs -o name,time -S 'time before "1 week ago"'
   LV    CTime
   lvol1 2016-08-29 12:53:36 +0200
   lvol0 2016-08-29 10:15:17 +0200
-
+.P
 # lvs -o name,time -S 'time since "68 hours ago"'
   LV    CTime
   lvol4 2016-09-09 16:57:44 +0200
   lvol3 2016-09-09 16:56:48 +0200
   lvol2 2016-09-09 16:55:12 +0200
-
+.P
 # lvs -o name,time -S 'time since "1 year 3 months ago"'
   LV    CTime
   lvol4 2016-09-09 16:57:44 +0200
@@ -1589,9 +1625,9 @@ Examples below demonstrates using freeform time expressions.
   lvol1 2016-08-29 12:53:36 +0200
   lvol0 2016-08-29 10:15:17 +0200
 .fi
-
+.
 .SS Command log reporting
-
+.
 As described in \fBcategorization based on reporting facility\fP section
@the beginning of this document, both \fBreport-oriented\fP and
 \fBprocessing-oriented\fP LVM commands can report the command log if
@@ -1599,7 +1635,7 @@ this is enabled with \fBlog/report_command_log\fP configuration setting.
 Just like any other report, we can set the set of fields to display
 (\fBlog/command_log_cols\fP) and to sort by (\fBlog/command_log_sort\fP)
 for this report.
-
+.P
 .nf
 # lvmconfig --type full log/report_command_log log/command_log_cols \\
    log/command_log_sort log/command_log_selection
@@ -1609,45 +1645,44 @@ command_log_cols="log_seq_num,log_type,log_context,log_object_type,
                   log_errno,log_ret_code"
 command_log_sort="log_seq_num"
 command_log_selection="!(log_type=status && message=success)"
-
-
+.P
 # lvs
   Logical Volume
   ==============
   LV    LSize Cpy%Sync
   lvol1 4.00m 100.00
   lvol0 4.00m
-
+.P
   Command Log
   ===========
   Seq LogType Context ObjType ObjName ObjGrp  Msg     Errno RetCode
 .fi
-
+.P
 As you can see, the command log is empty (it contains only field names).
 By default, LVM uses selection on the command log report and this case
 no row matched the selection criteria, see also \fBlog report specifics\fP
 section in this document for more information. We're displaying complete
 log report in the example below where we can see that both LVs lvol0 and
 lvol1 were successfully processed as well as the VG vg they are part of.
-
+.P
 .nf
 # lvmconfig --type full log/command_log_selection
 command_log_selection="all"
-
+.P
 # lvs
   Logical Volume
   ==============
   LV    LSize Cpy%Sync
   lvol1 4.00m 100.00
   lvol0 4.00m
-
+.P
   Command Log
   ===========
   Seq LogType Context    ObjType ObjName ObjGrp  Msg     Errno RetCode
     1 status  processing lv      lvol0   vg      success     0       1
     2 status  processing lv      lvol1   vg      success     0       1
     3 status  processing vg      vg              success     0       1
-
+.P
 # lvchange -an vg/lvol1
   Command Log
   ===========
@@ -1655,13 +1690,17 @@ command_log_selection="all"
     1 status  processing lv      lvol1   vg      success     0       1
     2 status  processing vg      vg              success     0       1
 .fi
-
+.
 .SS Handling multiple reports per single command
-
+.
 To configure the log report directly on command line, we need to use
-\fB--configreport\fP option before we start any \fB-o|--options\fP,
-\fB-O|--sort\fP or \fB-S|--select\fP that is targeted for log report.
-
+\fB--configreport\fP option before we start any
+.BR -o | --options ,
+.BR -O | --sort
+or
+.BR -S | --select
+that is targeted for log report.
+.P
 .nf
 # lvs -o lv_name,lv_size --configreport log -o log_object_type, \\
    log_object_name,log_message,log_ret_code
@@ -1670,7 +1709,7 @@ To configure the log report directly on command line, we need to use
   LV    LSize
   lvol1 4.00m
   lvol0 4.00m
-
+.P
   Command Log
   ===========
   ObjType ObjName Msg     RetCode
@@ -1678,11 +1717,11 @@ To configure the log report directly on command line, we need to use
   lv      lvol1   success       1
   vg      vg      success       1
 .fi
-
+.P
 The \fBlvm fullreport\fP, with or without log report, consists of several
 reports - the \fB--configreport\fP is also used to target particular
 subreport here.
-
+.P
 Below is an extended example with \fBlvm fullreport\fP to illustrate
 combination of various options. The report output is in JSON format.
 Also, we configure "vg", "pvseg", "seg" and "log" subreport to contain
@@ -1691,7 +1730,7 @@ in PV names having "sda" in their name. For the "log" subreport we're
 interested only in log lines related to either "lvol0" object or object
 having "sda" in its name. Also, for the log subreport we define ordering
 to be based on "log_object_type" field.
-
+.P
 .nf
 # lvm fullreport --reportformat json \\
    --configreport vg -o vg_name,vg_size \\
@@ -1741,22 +1780,22 @@ to be based on "log_object_type" field.
       ]
   }
 .fi
-
+.
 .SS Report extensions for LVM shell
-
+.
 As already stated in \fBlog report coverage\fP paragraph under
 \fBlog report specifics\fP in this documentation, when using \fBLVM shell\fP
 the \fBlog report\fP coverage is wider. There's also special command
 designed to query last command's log report in the \fBLVM shell\fP -
 the \fBlastlog\fP command.
-
+.P
 The example below illustrates a situation where we called lvs command.
 After that, we inspected the log report with the \fBlastlog\fP, without
 any selection so all the log report is displayed on output. Then we called
 \fBlastlog\fP further, giving various selection criteria. Then we ran
 unknown LVM command "abc" for which the log report displays appropriate
 failure state.
-
+.P
 .nf
 # lvm
 lvm> lvs
@@ -1765,7 +1804,7 @@ lvm> lvs
   LV    LSize Cpy%Sync
   lvol1 4.00m 100.00
   lvol0 4.00m
-
+.P
   Command Log
   ===========
   Seq LogType Context    ObjType ObjName ObjGrp  Msg     Errno RetCode
@@ -1773,7 +1812,7 @@ lvm> lvs
     2 status  processing lv      lvol1   vg      success     0       1
     3 status  processing vg      vg              success     0       1
     4 status  shell      cmd     lvs             success     0       1
-
+.P
 lvm> lastlog
   Command Log
   ===========
@@ -1782,20 +1821,20 @@ lvm> lastlog
     2 status  processing lv      lvol1   vg      success     0       1
     3 status  processing vg      vg              success     0       1
     4 status  shell      cmd     lvs             success     0       1
-
+.P
 lvm> lastlog -S log_object_type=lv
   Command Log
   ===========
   Seq LogType Context    ObjType ObjName ObjGrp  Msg     Errno RetCode
     1 status  processing lv      lvol0   vg      success     0       1
     2 status  processing lv      lvol1   vg      success     0       1
-
+.P
 lvm> lastlog -S log_context=shell
   Command Log
   ===========
   Seq LogType Context ObjType ObjName ObjGrp  Msg     Errno RetCode
     4 status  shell   cmd     lvs             success     0       1
-
+.P
 lvm> abc
   Command Log
   ===========
@@ -1803,8 +1842,17 @@ lvm> abc
     1 error   shell   cmd     abc             No such command 'abc'.  Try 'help'.    -1       0
     2 status  shell   cmd     abc             failure                                -1       2
 .fi
-
+.
 .SH SEE ALSO
+.
 .BR lvm (8),
 .BR lvmconfig (8),
-.BR "lvm fullreport" (8)
+.BR "lvm fullreport" (8),
+.BR lvcreate (8),
+.br
+.BR lvs (8),
+.BR pvs (8),
+.BR vgs (8),
+.P
+.BR date (1),
+.BR strftime (3)


