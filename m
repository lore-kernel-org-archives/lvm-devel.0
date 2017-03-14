From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 14 Mar 2017 10:56:20 -0400
Subject: master - man: Adjust some wording and update examples style.
Message-ID: <201703141456.v2EEuKmu031265@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c891918174f500f2508a5b69a4d55a427ac2b63c
Commit:        c891918174f500f2508a5b69a4d55a427ac2b63c
Parent:        ca905681ccf9afd2b8313b5a7a89ac609c9a7ba5
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Mar 14 14:55:36 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Mar 14 14:55:36 2017 +0000

man: Adjust some wording and update examples style.

---
 man/blkdeactivate.8_main |   71 ++++++++++++++++++++++++++--------------------
 1 files changed, 40 insertions(+), 31 deletions(-)

diff --git a/man/blkdeactivate.8_main b/man/blkdeactivate.8_main
index 8bb10b5..89f48ba 100644
--- a/man/blkdeactivate.8_main
+++ b/man/blkdeactivate.8_main
@@ -12,8 +12,8 @@ blkdeactivate \(em utility to deactivate block devices
 .RB [ \-v ]
 .RI [ device ]
 .SH DESCRIPTION
-blkdeactivate utility deactivates block devices. If a device
-is mounted, the utility can unmount it automatically before
+The blkdeactivate utility deactivates block devices. For mounted
+block devices, it attempts to unmount it automatically before
 trying to deactivate. The utility currently supports
 device-mapper devices (DM), including LVM volumes and
 software RAID MD devices. LVM volumes are handled directly
@@ -35,30 +35,30 @@ Force device removal.
 .BR \-e ", " \-\-errors
 Show errors reported from tools called by \fBblkdeactivate\fP. Without this
 option, any error messages from these external tools are suppressed and the
-\fBblkdeactivate\fP itself provides only a summary message about device being
-skipped or not.
+\fBblkdeactivate\fP itself provides only a summary message to indicate
+the device was skipped.
 .TP
 .BR \-h ", " \-\-help
 Display the help text.
 .TP
 .BR \-l ", " \-\-lvmoption \ \fIlvm_options\fP
-Comma separated list of LVM specific options:
+Comma-separated list of LVM specific options:
 .RS
 .IP \fIretry\fP
 Retry removal several times in case of failure.
 .IP \fIwholevg\fP
 Deactivate the whole LVM Volume Group when processing a Logical Volume.
-Deactivating Volume Group as a whole takes less time than deactivating each
-Logical Volume separately.
+Deactivating the Volume Group as a whole is quicker than deactivating
+each Logical Volume separately.
 .RE
 .TP
 .BR \-m ", " \-\-mpathoption \ \fImpath_options\fP
-Comma separated list of device-mapper multipath specific options:
+Comma-separated list of device-mapper multipath specific options:
 .RS
 .IP \fIdisablequeueing\fP
-Disable queueing on all multipath devices first before deactivation.
+Disable queueing on all multipath devices before deactivation.
 This avoids a situation where blkdeactivate may end up waiting if
-all paths are unavailable for any underlying device-mapper multipath
+all the paths are unavailable for any underlying device-mapper multipath
 device.
 .RE
 .TP
@@ -69,33 +69,42 @@ Without this option used, a device that is mounted is not deactivated.
 .BR \-v ", " \-\-verbose
 Run in verbose mode. Use \-\-vv for even more verbose mode.
 .SH EXAMPLES
-.sp
-Deactivate all supported block devices found in the system. If a device
-is mounted, skip its deactivation.
-.sp
+.
+Deactivate all supported block devices found in the system, skipping mounted
+devices.
+.BR
+#
 .B blkdeactivate
-
-Deactivate all supported block devices found in the system. If a device
-is mounted, unmount it first if possible.
-.sp
+.BR
+.P
+Deactivate all supported block devices found in the system, unmounting any
+mounted devices first, if possible.
+.BR
+#
 .B blkdeactivate \-u
-
-Deactivate supplied device together with all its holders. If any of the
-devices processed is mounted, unmount it first if possible.
-.sp
+.BR
+.P
+Deactivate the device /dev/vg/lvol0 together with all its holders, unmounting 
+any mounted devices first, if possible.
+.BR
+#
 .B blkdeactivate \-u /dev/vg/lvol0
-
-Deactivate all supported block devices found in the system. Retry deactivation
-of device-mapper devices in case the deactivation fails. Deactivate the whole
+.BR
+.P
+Deactivate all supported block devices found in the system. If the deactivation
+of a device-mapper device fails, retry it. Deactivate the whole
 Volume Group at once when processing an LVM Logical Volume.
-.sp
+.BR
+#
 .B blkdeactivate \-u \-d retry \-l wholevg
-
-Deactivate all supported block devices found in the system. Retry deactivation
-of device-mapper devices in case the deactivation fails and force removal.
-.sp
+.BR
+.P
+Deactivate all supported block devices found in the system. If the deactivation
+of a device-mapper device fails, retry it and force removal.
+.BR
+#
 .B blkdeactivate \-d force,retry
-
+.
 .SH SEE ALSO
 .BR dmsetup (8),
 .BR lsblk (8),


