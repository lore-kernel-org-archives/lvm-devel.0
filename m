From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 27 Nov 2013 14:52:42 +0000 (UTC)
Subject: master - man: lvcreate -W/--wipesignatures
Message-ID: <20131127145242.1C74660279@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5968f07fd5ccb2b7d4e407cd8fec86b0b1f80f3a
Commit:        5968f07fd5ccb2b7d4e407cd8fec86b0b1f80f3a
Parent:        eaa23d32732c9bc3dd4f948781b5764cf21d84ba
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 27 15:20:12 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 27 15:49:15 2013 +0100

man: lvcreate -W/--wipesignatures

---
 man/lvcreate.8.in |   21 +++++++++++++++++++--
 1 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 4a29720..a34c4ae 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -75,6 +75,7 @@ lvcreate \- create a logical volume in an existing volume group
 .RB [ \-\-type
 .IR SegmentType ]
 .RB [ \-v | \-\-verbose ]
+.RB [ \-W | \-\-wipesignatures ]
 .RB [ \-Z | \-\-zero
 .RI { y | n }]
 .IR VolumeGroup { Name | Path }[/ ThinPoolLogicalVolumeName ]
@@ -135,8 +136,9 @@ If autoactivation option is used (\fB\-a\fIay\fR), the logical volume is
 activated only if it matches an item in the
 .B activation/auto_activation_volume_list
 set in \fBlvm.conf\fP(5).
-For autoactivated logical volumes, \fB\-\-zero\fP \fIn\fP is always assumed
-and it can't be overridden. If the clustered locking is enabled,
+For autoactivated logical volumes, \fB\-\-zero\fP \fIn\fP and
+\fB\-\-wipesignatures\fP \fIn\fP is always assumed and it can't
+be overridden. If the clustered locking is enabled,
 \fB\-a\fIey\fR will activate exclusively on one node and
 .IR \fB\-a { a | l } y
 will activate only on the local node.
@@ -399,6 +401,21 @@ requested size using the zero target.  A suffix of _vorigin is used for
 this device. Note: using sparse snapshots is not efficient for larger
 device sizes (GiB), thin provisioning should be used for this case.
 .TP
+.BR \-W ", " \-\-wipesignatures " {" \fIy | \fIn }
+Controls wiping of detected signatures on newly created Logical Volume.
+If this option is not specified, then by default signature wiping is done
+each time the zeroing (\fB\-Z\fP/\fB\-\-zero\fP) is done. This default behaviour
+can be controlled by \fBallocation/wipe_signatures_on_new_logical_volumes_when_zeroing\fP
+setting found in \fBlvm.conf\fP(5).
+.br
+If blkid wiping is used (\fBallocation/use_blkid_wiping setting\fP in \fBlvm.conf\fP(5))
+and LVM2 is compiled with blkid wiping support, then \fBblkid\fP(8) library is used
+to detect the signatures (use \fBblkid -k\fP command to list the signatures that are recognized).
+Otherwise, native LVM2 code is used to detect signatures (MD RAID, swap and LUKS
+signatures are detected only in this case).
+.br
+Logical Volume is not wiped if the read only flag is set.
+.TP
 .BR \-Z ", " \-\-zero " {" \fIy | \fIn }
 Controls zeroing of the first KiB of data in the new logical volume.
 .br


