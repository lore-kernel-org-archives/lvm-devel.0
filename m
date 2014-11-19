From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 19 Nov 2014 00:14:10 +0000 (UTC)
Subject: master - man: blkdeactivate help output
Message-ID: <20141119001410.2740D6033B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=10330b8782628d981b05de7c06da4370e4b34ff0
Commit:        10330b8782628d981b05de7c06da4370e4b34ff0
Parent:        731e99025bf66967de365fb7a79d5689dc14d5fe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 19 00:35:04 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 19 01:09:24 2014 +0100

man: blkdeactivate help output

- Closer to the recommendation of man-pages and groff_man (7) if
  possible
- Sort options and crossrefs
- Relocate sub-options on the right places

Signed-off-by: St??phane Aulery <saulery@free.fr>
---
 man/blkdeactivate.8.in |   76 +++++++++++++++++++++++++----------------------
 1 files changed, 40 insertions(+), 36 deletions(-)

diff --git a/man/blkdeactivate.8.in b/man/blkdeactivate.8.in
index bfd0204..ebeaeaa 100644
--- a/man/blkdeactivate.8.in
+++ b/man/blkdeactivate.8.in
@@ -3,57 +3,61 @@
 blkdeactivate \(em utility to deactivate block devices
 .SH SYNOPSIS
 .B blkdeactivate
-.RI [ options ]
-.RI [ device... ]
-.sp
+.RB [ \-d \  \fIdm_options\fP ]
+.RB [ \-e ]
+.RB [ \-h ]
+.RB [ \-l \  \fIlvm_options\fP ]
+.RB [ \-u ]
+.RB [ \-v ]
+.RS
+.RI [ device ]
+.RE
 .SH DESCRIPTION
 blkdeactivate utility deactivates block devices. If a device
 is mounted, the utility can unmount it automatically before
 trying to deactivate. The utility currently supports
-\fIdevice-mapper\fP devices, including \fILVM\fP volumes.
-LVM volumes are handled directly using the \fIlvm\fP command.
+device-mapper devices, including LVM volumes.
+LVM volumes are handled directly using the \fBlvm\fP(8) command.
 Other device-mapper based devices are handled using the
-\fIdmsetup\fP command.
+\fBdmsetup\fP(8) command.
 .SH OPTIONS
 .TP
+.BR \-d ", " \-\-dmoption \ \fIdm_options\fP
+Comma separated list of device-mapper specific options.
+Accepted \fBdmsetup\fP(8) options are:
+.RS
+.IP \fIretry\fP
+Retry removal several times in case of failure.
+.IP \fIforce\fP
+Force device removal.
+.RE
+.TP
 .BR \-e ", " \-\-errors
-Show errors reported from tools called by blkdeactivate.
-Without this option, any error messages from these external tools
-are suppressed and the blkdeactivate itself provides only a summary
-message about device being skipped or not.
+Show errors reported from tools called by \fBblkdeactivate\fP. Without this
+option, any error messages from these external tools are suppressed and the
+\fBblkdeactivate\fP itself provides only a summary message about device being
+skipped or not.
 .TP
 .BR \-h ", " \-\-help
 Display the help text.
 .TP
+.BR \-l ", " \-\-lvmoption \ \fIlvm_options\fP
+Comma separated list of LVM specific options:
+.RS
+.IP \fIretry\fP
+Retry removal several times in case of failure.
+.IP \fIwholevg\fP
+Deactivate the whole LVM Volume Group when processing a Logical Volume.
+Deactivating Volume Group as a whole takes less time than deactivating each
+Logical Volume separately.
+.RE
+.TP
 .BR \-u ", " \-\-umount
 Unmount a mounted device before trying to deactivate it.
 Without this option used, a device that is mounted is not deactivated.
 .TP
 .BR \-v ", " \-\-verbose
 Run in verbose mode.
-.TP
-.BR \-d ", " \-\-dmoption " " \fIdm_options
-Comma separated list of device-mapper specific options.
-.TP
-.BR \-l ", " \-\-lvmoption " " \fIlvm_options
-Comma separated list of LVM specific options.
-.SH DM_OPTIONS
-.TP
-.B retry
-Retry removal several times in case of failure.
-.TP
-.B force
-Force device removal. See \fBdmsetup\fP(8) for more information.
-.SH LVM_OPTIONS
-.TP
-.B retry
-Retry removal several times in case of failure.
-.TP
-.B wholevg
-Deactivate the whole LVM Volume Group when processing a Logical Volume.
-Deactivating Volume Group as a whole takes less time than deactivating
-each Logical Volume separately.
-
 .SH EXAMPLES
 .sp
 Deactivate all supported block devices found in the system. If a device
@@ -83,7 +87,7 @@ of device-mapper devices in case the deactivation fails and force removal.
 .B blkdeactivate \-d force,retry
 
 .SH SEE ALSO
-.BR lsblk (8)
+.BR dmsetup (8),
+.BR lsblk (8),
+.BR lvm (8),
 .BR umount (8)
-.BR dmsetup (8)
-.BR lvm (8)


