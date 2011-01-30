From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 13:57:39 +0100
Subject: [PATCH 16/24] Man pages reformating
In-Reply-To: <cover.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
Message-ID: <c2d5347274f52274f4e4ca9d0474e851082faa32.1296391340.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Update format of few more man pages.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 man/fsadm.8.in    |   80 ++++++++++++++++++++++++-------------------
 man/lvreduce.8.in |   65 ++++++++++++++++++----------------
 man/lvremove.8.in |   17 ++++-----
 man/lvrename.8.in |   37 ++++++--------------
 man/lvresize.8.in |   99 +++++++++++++++++++++++++++--------------------------
 5 files changed, 148 insertions(+), 150 deletions(-)

diff --git a/man/fsadm.8.in b/man/fsadm.8.in
index eeec2d3..5f451fd 100644
--- a/man/fsadm.8.in
+++ b/man/fsadm.8.in
@@ -1,64 +1,74 @@
 .TH "FSADM" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
 .SH "NAME"
 fsadm \- utility to resize or check filesystem on a device
-.SH "SYNOPSIS"
+.SH SYNOPSIS
 .B fsadm
-.RI [options]\ check\ device
-
+.RI [ options ]
+.B check
+.I device
+.sp
 .B fsadm
-.RI [options]\ resize\ device\ [new_size[BKMGTEP]]
-
-.SH "DESCRIPTION"
-\fBfsadm\fR utility resizes or checks the filesystem on a device.
-It tries to use the same API for \fBext2/ext3/ext4\fR,
-\fBReiserFS\fR and \fBXFS\fR filesystem.
-.SH "OPTIONS"
+.RI [ options ]
+.B resize
+.I device
+.RI [ new_size [ BKMGTEP ]]
+.sp
+.SH DESCRIPTION
+.B fsadm
+utility resizes or checks the filesystem on a device.
+It tries to use the same API for 
+.IR ext2 , ext3 , ext4 , ReiserFS
+and \fIXFS\fP filesystem.
+.SH OPTIONS
 .TP
-\fB\-h \-\-help\fR
-\(em print help message
+.BR \-h ", " \-\-help
+Display the help text.
 .TP
-\fB\-v \-\-verbose\fR
-\(em be more verbose
+.BR \-v ", " \-\-verbose
+Be more verbose.
 .TP
-\fB\-e \-\-ext\-offline\fR
-\(em unmount ext2/ext3/ext4 filesystem before doing resize
+.BR \-e ", " \-\-ext\-offline
+Unmount ext2/ext3/ext4 filesystem before doing resize.
 .TP
-\fB\-f \-\-force\fR
-\(em bypass some sanity checks
+.BR \-f ", " \-\-force
+Bypass some sanity checks.
 .TP
-\fB\-n \-\-dry\-run\fR
-\(em print commands without running them
+.BR \-n ", " \-\-dry\-run
+Print commands without running them.
 .TP
-\fB\-y \-\-yes\fR
-\(em answer "yes" at any prompts
+.BR \-y ", " \-\-yes
+Answer "yes" at any prompts.
 .TP
-\fBnew_size\fR
-\(em Absolute number of filesystem blocks to be in the filesystem,
+.I new_size
+Absolute number of filesystem blocks to be in the filesystem,
 or an absolute size using a suffix (in powers of 1024).
 If new_size is not supplied, the whole device is used.
 
-.SH "DIAGNOSTICS"
+.SH DIAGNOSTICS
 On successful completion, the status code is 0.
 A status code of 2 indicates the operation was interrupted by the user.
 A status code of 3 indicates the requested check operation could not be performed
-because the filesystem is mounted and does not support an online fsck.
+because the filesystem is mounted and does not support an online 
+.BR fsck (8).
 A status code of 1 is used for other failures.
 
-.SH "EXAMPLES"
-"fsadm \-e \-y resize /dev/vg/test 1000M" tries to resize the filesystem
-on logical volume /dev/vg/test. If /dev/vg/test contains ext2/ext3/ext4
+.SH EXAMPLES
+Resize the filesystem on logical volume /dev/vg/test to 1000 megabytes.
+If /dev/vg/test contains ext2/ext3/ext4
 filesystem it will be unmounted prior the resize.
 All [y|n] questions will be answered 'y'.
-.SH "ENVIRONMENT VARIABLES"
+.sp
+.B fsadm \-e \-y resize /dev/vg/test 1000M
+.SH ENVIRONMENT VARIABLES
 .TP
-\fBTMPDIR\fP
-Where the temporary directory should be created.
-.TP
-.BR
-.SH "SEE ALSO"
+.B TMPDIR
+The temporary directory name for mount points. Defaults to "/tmp". 
+
+.SH SEE ALSO
 .BR lvm (8),
 .BR lvresize (8),
 .BR lvm.conf (5),
+.BR fsck (8),
 .BR tune2fs (8),
 .BR resize2fs (8),
 .BR reiserfstune (8),
diff --git a/man/lvreduce.8.in b/man/lvreduce.8.in
index fc77223..7a50d0f 100644
--- a/man/lvreduce.8.in
+++ b/man/lvreduce.8.in
@@ -3,15 +3,15 @@
 lvreduce \- reduce the size of a logical volume
 .SH SYNOPSIS
 .B lvreduce
-[\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-f|\-\-force]
-[\-h|\-?|\-\-help]
-[\-\-noudevsync]
-{\-l|\-\-extents [\-]LogicalExtentsNumber[%{VG|LV|FREE|ORIGIN}] |
-\-L|\-\-size [\-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
-[\-n|\-\-nofsck]
-[\-r|\-\-resizefs]
-[\-t|\-\-test]
-[\-v|\-\-verbose] LogicalVolume[Path]
+.RB [ \-f | \-\-force ]
+.RB [ \-\-noudevsync ]
+.RB { \-l | \-\-extents 
+.RI [ \- ] LogicalExtentsNumber [ % { VG | LV | FREE | ORIGIN "}] |"
+.RB [ \-L | \-\-size 
+.RI [ \- ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]}
+.RB [ \-n | \-\-nofsck ]
+.RB [ \-r | \-\-resizefs ]
+.IR LogicalVolume { Name | Path }
 .SH DESCRIPTION
 lvreduce allows you to reduce the size of a logical volume.
 Be careful when reducing a logical volume's size, because data in the
@@ -23,61 +23,64 @@ resized
 running lvreduce so that the extents that are to be removed are not in use.
 .br
 Shrinking snapshot logical volumes (see
-.B lvcreate(8)
+.BR lvcreate (8)
 for information to create snapshots) is supported as well.
 But to change the number of copies in a mirrored logical
 volume use 
-.B lvconvert (8).
+.BR lvconvert (8).
 .br
 Sizes will be rounded if necessary - for example, the volume size must
 be an exact number of extents and the size of a striped segment must
 be a multiple of the number of stripes.
 .br
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See 
+.BR lvm (8)
+for common options.
 .TP
-.I \-f, \-\-force
+.BR \-f ", " \-\-force
 Force size reduction without prompting even when it may cause data loss.
 .TP
-.I \-\-noudevsync
+.BR \-\-noudevsync
 Disable udev synchronisation. The
 process will not wait for notification from udev.
 It will continue irrespective of any possible udev processing
 in the background.  You should only use this if udev is not running
 or has rules that ignore the devices LVM2 creates.
 .TP
-.I \-l, \-\-extents [\-]LogicalExtentsNumber[%{VG|LV|FREE|ORIGIN}]
+.IR \fB\-l ", " \fB\-\-extents " [" \- ] LogicalExtentsNumber [ % { VG | LV | FREE | ORIGIN }]
 Reduce or set the logical volume size in units of logical extents.
-With the - sign the value will be subtracted from
+With the \fI-\fP sign the value will be subtracted from
 the logical volume's actual size and without it the value will be taken
 as an absolute size.
 The number can also be expressed as a percentage of the total space
-in the Volume Group with the suffix %VG, relative to the existing
-size of the Logical Volume with the suffix %LV, as a percentage of the
-remaining free space in the Volume Group with the suffix %FREE, or (for
+in the Volume Group with the suffix \fI%VG\fP, relative to the existing
+size of the Logical Volume with the suffix \fI%LV\fP, as a percentage of the
+remaining free space in the Volume Group with the suffix \fI%FREE\fP, or (for
 a snapshot) as a percentage of the total space in the Origin Logical
-Volume with the suffix %ORIGIN.
+Volume with the suffix \fI%ORIGIN\fP.
 .TP
-.I \-L, \-\-size [\-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]
+.IR \fB\-L ", " \fB\-\-size " [" \- ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
 Reduce or set the logical volume size in units of megabytes.
-A size suffix of k for kilobyte, m for megabyte, 
-g for gigabytes, t for terabytes, p for petabytes 
-or e for exabytes is optional.
-With the - sign the value will be subtracted from
+A size suffix of \fIk\fP for kilobyte, \fIm\fP for megabyte,
+\fIg\fP for gigabytes, \fIt\fP for terabytes, \fIp\fP for petabytes
+or \fIe\fP for exabytes is optional.
+With the \fI-\fP sign the value will be subtracted from
 the logical volume's actual size and without it it will be taken as
 an absolute size.
 .TP
-.I \-n, \-\-nofsck
+.BR \-n ", " \-\-nofsck
 Do not perform fsck before resizing filesystem when filesystem
 requires it. You may need to use \fB--force\fR to proceed with 
 this option.
 .TP
-.I \-r, \-\-resizefs
+.BR \-r ", " \-\-resizefs
 Resize underlying filesystem together with the logical volume using 
-\fBfsadm\fR(8).
-.SH Example
-"lvreduce -l -3 vg00/lvol1" reduces the size of logical volume lvol1
-in volume group vg00 by 3 logical extents.
+.BR fsadm (8).
+.SH EXAMPLES
+Reduce the size of logical volume lvol1 in volume group vg00 by 3 logical extents:
+.sp
+.B lvreduce -l -3 vg00/lvol1
 .SH SEE ALSO
 .BR fsadm (8),
 .BR lvchange (8),
diff --git a/man/lvremove.8.in b/man/lvremove.8.in
index ac39cb4..ed47fb8 100644
--- a/man/lvremove.8.in
+++ b/man/lvremove.8.in
@@ -3,11 +3,10 @@
 lvremove \- remove a logical volume
 .SH SYNOPSIS
 .B lvremove
-[\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-f|\-\-force]
-[\-h|\-?|\-\-help] 
-[\-\-noudevsync]
-[\-t|\-\-test]
-[\-v|\-\-verbose] LogicalVolumePath [LogicalVolumePath...]
+.RB [ \-f | \-\-force ]
+.RB [ \-\-noudevsync ]
+.IR LogicalVolume { Name |  Path }
+.RI [ LogicalVolume { Name | Path }...]
 .SH DESCRIPTION
 \fBlvremove\fP removes one or more logical volumes.
 Confirmation will be requested before deactivating any active logical
@@ -21,10 +20,10 @@ issued from one node can do this.
 .SH OPTIONS
 See \fBlvm\fP(8) for common options.
 .TP
-.I \-f, \-\-force
+.BR \-f ", " \-\-force
 Remove active logical volumes without confirmation.
 .TP
-.I \-\-noudevsync
+.B \-\-noudevsync
 Disable udev synchronisation. The
 process will not wait for notification from udev.
 It will continue irrespective of any possible udev processing
@@ -34,11 +33,11 @@ or has rules that ignore the devices LVM2 creates.
 Remove the active logical volume lvol1 in volume group vg00 
 without asking for confirmation:
 .sp
-\	\fBlvremove -f vg00/lvol1\fP
+.B lvremove -f vg00/lvol1
 .sp
 Remove all logical volumes in volume group vg00:
 .sp
-\	\fBlvremove vg00\fP
+.B lvremove vg00
 .SH SEE ALSO
 .BR lvcreate (8), 
 .BR lvdisplay (8),
diff --git a/man/lvrename.8.in b/man/lvrename.8.in
index 8f90072..85c5534 100644
--- a/man/lvrename.8.in
+++ b/man/lvrename.8.in
@@ -3,16 +3,10 @@
 lvrename \- rename a logical volume
 .SH SYNOPSIS
 .B lvrename
-.RB [ \-A | \-\-autobackup " {" y | n }]
-.RB [ \-d | \-\-debug ]
 .RB [ \-f | \-\-force ]
-.RB [ \-h | \-\-help ]
 .RB [ \-\-noudevsync ]
-.RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.TP
-.IR "OldLogicalVolumePath NewLogicalVolume" { Path | Name }
+.IR OldLogicalVolume { Name | Path }
+.IR NewLogicalVolume { Name | Path }
 .TP
 .I VolumeGroupName OldLogicalVolumeName NewLogicalVolumeName
 .SH DESCRIPTION
@@ -22,7 +16,7 @@ renames an existing logical volume from
 to
 .IR NewLogicalVolume { Name | Path }.
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP(8) for common options.
 .TP
 .BR \-\-noudevsync
 Disable udev synchronisation. The
@@ -31,23 +25,14 @@ It will continue irrespective of any possible udev processing
 in the background.  You should only use this if udev is not running
 or has rules that ignore the devices LVM2 creates.
 .SH EXAMPLE
-To rename
-.B lvold
-in volume group
-.B vg02
-to
-.BR lvnew :
-.nf
-
-\	lvrename /dev/vg02/lvold /dev/vg02/lvnew
-
-.fi
-An alternate syntax to rename this logical volume is
-.nf
-
-\	lvrename vg02 lvold lvnew
-
-.fi
+To rename lvold in volume group vg02 to lvnew:
+.sp
+.B lvrename /dev/vg02/lvold vg02/lvnew
+.sp
+An alternate syntax to rename this logical volume is:
+.sp
+.B lvrename vg02 lvold lvnew
+.sp
 .SH SEE ALSO
 .BR lvm (8), 
 .BR lvchange (8),
diff --git a/man/lvresize.8.in b/man/lvresize.8.in
index 677b2db..e534d3b 100644
--- a/man/lvresize.8.in
+++ b/man/lvresize.8.in
@@ -3,17 +3,19 @@
 lvresize \- resize a logical volume
 .SH SYNOPSIS
 .B lvresize
-[\-\-alloc AllocationPolicy]
-[\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help]
-[\-\-noudevsync]
-[\-i|\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
-{\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}] |
-\-L|\-\-size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
-[\-f|\-\-force]
-[\-n|\-\-nofsck]
-[\-r|\-\-resizefs]
-[\-t|\-\-test]
-[\-v|\-\-verbose] LogicalVolumePath [PhysicalVolumePath[:PE[-PE]]...]
+.RB [ \-\-alloc " " \fIAllocationPolicy ]
+.RB [ \-\-noudevsync ]
+.RB [ \-i | \-\-stripes " " \fIStripes
+.RB [ \-I | \-\-stripesize " " \fIStripeSize ]]
+.RB {[ \-l | \-\-extents
+.RI [ + | \- ] LogicalExtentsNumber [ % { VG | LV | PVS | FREE | ORIGIN "}] |"
+.RB [ \-L | \-\-size
+.RI [ + | \- ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]}
+.RB [ \-f | \-\-force ]
+.RB [ \-n | \-\-nofsck ]
+.RB [ \-r | \-\-resizefs ]
+.IR LogicalVolume { Name | Path }
+.RI [ PhysicalVolumePath [ :PE [ -PE ]]...]
 .SH DESCRIPTION
 lvresize allows you to resize a logical volume.
 Be careful when reducing a logical volume's size, because data in the reduced
@@ -21,74 +23,73 @@ part is lost!!!
 You should therefore ensure that any filesystem on the volume is
 shrunk first so that the extents that are to be removed are not in use.
 Resizing snapshot logical volumes (see
-.B lvcreate(8)
+.BR lvcreate (8)
 for information about creating snapshots) is supported as well.
 But to change the number of copies in a mirrored logical
 volume use 
 .BR lvconvert (8).
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP(8) for common options.
 .TP
-.I \-f, \-\-force
+.BR \-f ", " \-\-force
 Force resize without prompting even when it may cause data loss.
 .TP
-.I \-l, \-\-extents [+|-]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}]
-Change or set the logical volume size in units of logical extents.
-With the + or - sign the value is added to or subtracted from the actual size
-of the logical volume and without it, the value is taken as an absolute one.
-The number can also be expressed as a percentage of the total space
-in the Volume Group with the suffix %VG, relative to the existing
-size of the Logical Volume with the suffix %LV, as a percentage of
-the remaining free space of the PhysicalVolumes on the command line with the
-suffix %PVS, as a percentage of the remaining free space in the
-Volume Group with the suffix %FREE, or (for a snapshot) as a percentage
-of the total space in the Origin Logical Volume with the suffix %ORIGIN.
-.TP
-.I \-n, \-\-nofsck
+.BR \-n ", " \-\-nofsck
 Do not perform fsck before resizing filesystem when filesystem
 requires it. You may need to use \fB--force\fR to proceed with 
 this option.
 .TP
-.I \-\-noudevsync
-Disable udev synchronisation. The
-process will not wait for notification from udev.
-It will continue irrespective of any possible udev processing
-in the background.  You should only use this if udev is not running
-or has rules that ignore the devices LVM2 creates.
-.TP
-.I \-r, \-\-resizefs
+.BR \-r ", " \-\-resizefs
 Resize underlying filesystem together with the logical volume using 
 \fBfsadm\fR(8).
 .TP
-.I \-L, \-\-size [+|-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]
+.IR \fB\-l ", " \fB\-\-extents " [" + | - ] LogicalExtentsNumber [ % { VG | LV | PVS | FREE | ORIGIN }]
+Change or set the logical volume size in units of logical extents.
+With the \fI+\fP or \fI-\fP sign the value is added to or subtracted from the actual size
+of the logical volume and without it, the value is taken as an absolute one.
+The number can also be expressed as a percentage of the total space
+in the Volume Group with the suffix \fI%VG\fP, relative to the existing
+size of the Logical Volume with the suffix \fI%LV\fP, as a percentage of
+the remaining free space of the PhysicalVolumes on the command line with the
+suffix \fI%PVS\fP, as a percentage of the remaining free space in the
+Volume Group with the suffix \fI%FREE\fP, or (for a snapshot) as a percentage
+of the total space in the Origin Logical Volume with the suffix \fI%ORIGIN\fP.
+.TP
+.IR \fB\-L ", " \fB\-\-size " [" + | - ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
 Change or set the logical volume size in units of megabytes.
-A size suffix of M for megabytes,
-G for gigabytes, T for terabytes, P for petabytes 
-or E for exabytes is optional.
-With the + or - sign the value is added to or subtracted from
+A size suffix of \fIM\fP for megabytes,
+\fIG\fP for gigabytes, \fIT\fP for terabytes, \fIP\fP for petabytes
+or \fIE\fP for exabytes is optional.
+With the \fI+\fP or \fI-\fP sign the value is added to or subtracted from
 the actual size of the logical volume and without it, the value is taken as an
 absolute one.
 .TP
-.I \-i, \-\-stripes Stripes
+.BR \-i ", " \-\-stripes " " \fIStripes
 Gives the number of stripes to use when extending a Logical Volume.
 Defaults to whatever the last segment of the Logical Volume uses.
 Not applicable to LVs using the original metadata LVM format, which must
 use a single value throughout.
 .TP
-.I \-I, \-\-stripesize StripeSize
+.BR \-I ", " \-\-stripesize " " \fIStripeSize
 Gives the number of kilobytes for the granularity of the stripes.
 Defaults to whatever the last segment of the Logical Volume uses.
 Not applicable to LVs using the original metadata LVM format, which
 must use a single value throughout.
 .br
-StripeSize must be 2^n (n = 2 to 9)
-.SH Examples
-.br
-"lvresize -L+16M vg1/lv1 /dev/sda:0-1 /dev/sdb:0-1"
+StripeSize must be 2^n (n = 2 to 9).
+.TP
+.B \-\-noudevsync
+Disable udev synchronisation. The
+process will not wait for notification from udev.
+It will continue irrespective of any possible udev processing
+in the background.  You should only use this if udev is not running
+or has rules that ignore the devices LVM2 creates.
+.SH EXAMPLES
 .br
-tries to extend a logical volume "vg1/lv1" by 16MB using physical extents
-/dev/sda:0-1 and /dev/sdb:0-1 for allocation of extents.
-
+Extend a logical volume vg1/lv1 by 16MB using physical extents
+/dev/sda:0-1 and /dev/sdb:0-1 for allocation of extents:
+.sp
+.B lvresize -L+16M vg1/lv1 /dev/sda:0-1 /dev/sdb:0-1
 .SH SEE ALSO
 .BR fsadm (8),
 .BR lvm (8), 
-- 
1.7.3.5


