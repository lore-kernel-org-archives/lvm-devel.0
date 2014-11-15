From: saulery@free.fr <saulery@free.fr>
Date: Sat, 15 Nov 2014 17:46:28 +0100
Subject: Improve blkdeactivate.8 manpage and help output
In-Reply-To: <1416069988-13208-1-git-send-email-saulery@free.fr>
References: <1416069988-13208-1-git-send-email-saulery@free.fr>
Message-ID: <1416069988-13208-4-git-send-email-saulery@free.fr>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: St?phane Aulery <saulery@free.fr>

- Closer to the recommendation of man-pages and groff_man (7) if possible
- Sort options and crossrefs
- Relocate sub-options on the right places

Signed-off-by: St?phane Aulery <saulery@free.fr>
---
 man/blkdeactivate.8.in | 91 +++++++++++++++++++++++++-------------------------
 1 file changed, 46 insertions(+), 45 deletions(-)

diff --git a/man/blkdeactivate.8.in b/man/blkdeactivate.8.in
index bfd0204..69935b5 100644
--- a/man/blkdeactivate.8.in
+++ b/man/blkdeactivate.8.in
@@ -2,58 +2,60 @@
 .SH "NAME"
 blkdeactivate \(em utility to deactivate block devices
 .SH SYNOPSIS
-.B blkdeactivate
-.RI [ options ]
-.RI [ device... ]
-.sp
+.SY blkdeactivate
+.OP \-d dm_options
+.OP \-e
+.OP \-h
+.OP \-l lvm_options
+.OP \-u
+.OP \-v
+.RI [ device ]
+.YS
 .SH DESCRIPTION
-blkdeactivate utility deactivates block devices. If a device
-is mounted, the utility can unmount it automatically before
-trying to deactivate. The utility currently supports
-\fIdevice-mapper\fP devices, including \fILVM\fP volumes.
-LVM volumes are handled directly using the \fIlvm\fP command.
-Other device-mapper based devices are handled using the
-\fIdmsetup\fP command.
+.B Blkdeactivate
+utility deactivates block devices. If a device is mounted, the utility can
+unmount it automatically before trying to deactivate. The utility currently
+supports device-mapper devices, including LVM volumes. LVM volumes are handled
+directly using the \fBlvm\fP(8) command. Other device-mapper based devices are
+handled using the \fBdmsetup\fP(8) command.
 .SH OPTIONS
 .TP
+.BR "\-d \fIdm_options\fP", " \-\-dmoption \fIdm_options\fP"
+Comma separated list of device-mapper specific options. \fBDmsetup\fP(8)
+options accepted are :
+.RS
+.IP \fIretry\fP
+Retry removal several times in case of failure;
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
+.BR "\-l \fIlvm_options\fP", " \-\-lvmoption \fIlvm_options\fP"
+Comma separated list of LVM specific options.
+.RS
+.IP \fIretry\fP
+Retry removal several times in case of failure;
+.IP \fIwholevg\fP
+Deactivate the whole LVM Volume Group when processing a Logical Volume.
+Deactivating Volume Group as a whole takes less time than deactivating each
+Logical Volume separately.
+.RE
+.TP
 .BR \-u ", " \-\-umount
-Unmount a mounted device before trying to deactivate it.
-Without this option used, a device that is mounted is not deactivated.
+Unmount a mounted device before trying to deactivate it. Without this option
+used, a device that is mounted is not deactivated.
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
@@ -81,9 +83,8 @@ Deactivate all supported block devices found in the system. Retry deactivation
 of device-mapper devices in case the deactivation fails and force removal.
 .sp
 .B blkdeactivate \-d force,retry
-
 .SH SEE ALSO
-.BR lsblk (8)
-.BR umount (8)
-.BR dmsetup (8)
-.BR lvm (8)
+.BR dmsetup (8),
+.BR lsblk (8),
+.BR lvm (8),
+.BR umount (8).
-- 
2.1.3


