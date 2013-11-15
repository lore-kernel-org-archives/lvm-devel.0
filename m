From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 15 Nov 2013 16:01:34 +0100
Subject: [PATCH 4/6] man: lvcreate -W/--wipesignatures {y/n}
Message-ID: <5286374E.3060505@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 man/lvcreate.8.in | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 4a29720..53eecea 100644
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
@@ -399,6 +401,14 @@ requested size using the zero target.  A suffix of _vorigin is used for
 this device. Note: using sparse snapshots is not efficient for larger
 device sizes (GiB), thin provisioning should be used for this case.
 .TP
+.BR \-W ", " \-\-wipesignatures " {" \fIy | \fIn }
+Controls wiping known signatures. Currently, it includes software RAID
+md superblock, swap and LUKS signatures.
+.br
+Default is \fIn\fPo.
+.br
+Volume is not wiped if the read only flag is set.
+.TP
 .BR \-Z ", " \-\-zero " {" \fIy | \fIn }
 Controls zeroing of the first KiB of data in the new logical volume.
 .br
-- 
1.8.4.2


