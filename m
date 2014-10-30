From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Oct 2014 23:00:34 +0000 (UTC)
Subject: master - man: update lvcreate with sparse
Message-ID: <20141030230034.CDE0260654@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=651613e9a40c9cc0aaf4a1c7c262ad394ac93ffb
Commit:        651613e9a40c9cc0aaf4a1c7c262ad394ac93ffb
Parent:        e6e647489d49e02dbe9795371df7b154d30baf74
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 30 19:44:42 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 30 23:58:48 2014 +0100

man: update lvcreate with sparse

Document sparse device creation and its default segtype selection.
---
 man/lvcreate.8.in |   22 ++++++++++++++--------
 1 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index c843949..e2b6d91 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -155,7 +155,7 @@ Normally the \fB\-\-zero\fP \fIn\fP argument has to be supplied too because
 zeroing (the default behaviour) also requires activation.
 If autoactivation option is used (\fB\-a\fIay\fR), the logical volume is
 activated only if it matches an item in the
-.BR activation / auto_activation_volume_list
+.IR activation / auto_activation_volume_list
 set in \fBlvm.conf\fP(5).
 For autoactivated logical volumes, \fB\-\-zero\fP \fIn\fP and
 \fB\-\-wipesignatures\fP \fIn\fP is always assumed and it can't
@@ -291,7 +291,9 @@ The default is "\fIraid1\fP".  See the
 legacy "\fImirror\fP" segment type.  See
 .BR lvm.conf (5)
 settings
-.BR global / mirror_segtype_default
+.IR global / mirror_segtype_default
+and
+.IR global / raid10_segtype_default
 to configure default mirror segment type.
 The options
 \fB\-\-mirrorlog\fP and \fB\-\-corelog\fP apply
@@ -316,9 +318,9 @@ Starts or avoids monitoring a mirrored, snapshot or thin pool logical volume wit
 dmeventd, if it is installed.
 If a device used by a monitored mirror reports an I/O error,
 the failure is handled according to
-.BR activation / mirror_image_fault_policy
+.IR activation / mirror_image_fault_policy
 and
-.BR activation / mirror_log_fault_policy
+.IR activation / mirror_log_fault_policy
 set in \fBlvm.conf\fP(5).
 .TP
 .IR \fB\-n ", " \fB\-\-name " " LogicalVolume { Name | Path }
@@ -531,8 +533,12 @@ or
 Default type is \fIlinear\fP.
 .TP
 .BR \-V ", " \-\-virtualsize " " \fIVirtualSize [ \fIbBsSkKmMgGtTpPeE ]
-Creates a sparse device of the given size (in MiB by default) using a snapshot
-or thinly provisioned device when thin pool is specified.
+Creates a thinly provisioned device or a sparse device of the given size (in MiB by default).
+See
+.BR lvm.conf (5)
+settings
+.IR global / sparse_segtype_default
+to configure default sparse segment type.
 See \fBlvmthin\fP(7) for more info about thin provisioning support.
 Anything written to a sparse snapshot will be returned when reading from it.
 Reading from other areas of the device will return blocks of zeros.
@@ -546,12 +552,12 @@ Controls wiping of detected signatures on newly created Logical Volume.
 If this option is not specified, then by default signature wiping is done
 each time the zeroing (\fB\-Z\fP/\fB\-\-zero\fP) is done. This default behaviour
 can be controlled by
-.BR allocation / wipe_signatures_when_zeroing_new_lvs
+.IR allocation / wipe_signatures_when_zeroing_new_lvs
 setting found in
 .BR lvm.conf (5).
 .br
 If blkid wiping is used
-.BR allocation / use_blkid_wiping
+.IR allocation / use_blkid_wiping
 setting in
 .BR lvm.conf (5))
 and LVM2 is compiled with blkid wiping support, then \fBblkid\fP(8) library is used


