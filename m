From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:26:10 +0000 (UTC)
Subject: dev-mornfall-activate - man: updates
Message-ID: <20130604192610.7BB9C61084@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e926f22457774596d6051aa9e8ee22b884f2299d
Commit:        e926f22457774596d6051aa9e8ee22b884f2299d
Parent:        44071331138a7ca3a7d775d8a091933404ee7509
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun May 5 21:38:44 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 13 13:09:30 2013 +0200

man: updates

---
 man/dmsetup.8.in   |   35 ++++++++++++++++++-----------------
 man/lvcreate.8.in  |    8 +++++---
 man/lvdisplay.8.in |    1 +
 man/lvmetad.8.in   |    8 ++++++--
 man/pvdisplay.8.in |    1 +
 5 files changed, 31 insertions(+), 22 deletions(-)

diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index a4eac1e..93621a5 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -54,6 +54,7 @@ dmsetup \- low level logical volume management
 .RB [ \-\-exec
 .IR command ]
 .RB [ \-\-tree ]
+.RS
 .RB [ \-o
 .IR options ]
 .RE
@@ -279,7 +280,7 @@ Destroys the table in the inactive table slot for device_name.
 .br
 Creates a device with the given name.
 If table_file or <table> is supplied, the table is loaded and made live.
-Otherwise a table is read from standard input unless \-\-notable is used.
+Otherwise a table is read from standard input unless \fB\-\-notable\fP is used.
 The optional uuid can be used in place of
 device_name in subsequent dmsetup commands.
 If successful a device will appear as
@@ -357,7 +358,7 @@ each device.  The device name is appended to the supplied command.
 Device names on output can be customised by following options: devno (major
 and minor pair, used by default), blkdevname (block device name),
 devname (map name for device-mapper devices, equal to blkdevname otherwise).
---tree displays dependencies between devices as a tree.
+\fB\-\-tree\fP displays dependencies between devices as a tree.
 It accepts a comma-separate list of options.
 Some specify the information displayed against each node:
 device/nodevice; blkdevname; active, open, rw, uuid.
@@ -404,11 +405,11 @@ driver, adding, changing or removing nodes as necessary.
 Ensure existing device-mapper device name and UUID is in the correct mangled
 form containing only whitelisted characters (supported by udev) and do
 a rename if necessary. Any character not on the whitelist will be mangled
-based on the --manglename setting. Automatic rename works only for device
+based on the \fB\-\-manglename\fP setting. Automatic rename works only for device
 names and not for device UUIDs because the kernel does not allow changing
 the UUID of active devices. Any incorrect UUIDs are reported only and they
 must be manually corrected by deactivating the device first and then
-reactivating it with proper mangling mode used (see also --manglename).
+reactivating it with proper mangling mode used (see also \fB\-\-manglename\fP).
 .br
 .HP
 .B remove
@@ -483,12 +484,12 @@ Default subsystem is LVM.
 .B status
 .RB [ \-\-target
 .IR target_type ]
-.RB [ \-\-noflush ]
+.RB [ \-\-\noflush ]
 .RI [ device_name ]
 .br
 Outputs status information for each of the device's targets.
 With \-\-target, only information relating to the specified target type
-any is displayed.  With \-\-noflush, the thin target (from version 1.3.0)
+any is displayed.  With \fB\-\-noflush\fP, the thin target (from version 1.3.0)
 doesn't commit any outstanding changes to disk before reporting its statistics.
 .br
 .HP
@@ -501,9 +502,9 @@ Suspends a device.  Any I/O that has already been mapped by the device
 but has not yet completed will be flushed.  Any further I/O to that
 device will be postponed for as long as the device is suspended.
 If there's a filesystem on the device which supports the operation,
-an attempt will be made to sync it first unless \-\-nolockfs is specified.
+an attempt will be made to sync it first unless \fB\-\-nolockfs\fP is specified.
 Some targets such as recent (October 2006) versions of multipath may support
-the \-\-noflush option.  This lets outstanding I/O that has not yet reached the
+the \fB\-\-noflush\fP option.  This lets outstanding I/O that has not yet reached the
 device to remain unflushed.
 .br
 .TP
@@ -515,10 +516,10 @@ device to remain unflushed.
 .br
 Outputs the current table for the device in a format that can be fed
 back in using the create or load commands.
-With \-\-target, only information relating to the specified target type
+With \fB\-\-target\fP, only information relating to the specified target type
 is displayed.
 Encryption keys are suppressed in the table output for the crypt
-target unless the \-\-showkeys parameter is supplied.
+target unless the \fB\-\-showkeys\fP parameter is supplied.
 .br
 .TP
 .B targets
@@ -552,8 +553,8 @@ The output is a cookie value. Normally we don't need to create cookies since
 dmsetup creates and destroys them for each action automatically. However, we can
 generate one explicitly to group several actions together and use only one
 cookie instead. We can define a cookie to use for each relevant command by using
-\-\-udevcookie option. Alternatively, we can export this value into the environment
-of the dmsetup process as DM_UDEV_COOKIE variable and it will be used automatically
+\fB\-\-udevcookie\fP option. Alternatively, we can export this value into the environment
+of the dmsetup process as \fBDM_UDEV_COOKIE\fP variable and it will be used automatically
 with all subsequent commands until it is unset.
 Invoking this command will create system-wide semaphore that needs to be cleaned
 up explicitly by calling udevreleasecookie command.
@@ -576,7 +577,7 @@ always reported as DM_SUBSYSTEM_UDEV_FLAG<flag_position>='1'. There are
 .br
 Waits for all pending udev processing bound to given cookie value and clean up
 the cookie with underlying semaphore. If the cookie is not given directly,
-the command will try to use a value defined by DM_UDEV_COOKIE environment variable.
+the command will try to use a value defined by \fBDM_UDEV_COOKIE\fP environment variable.
 .br
 .TP
 .B version
@@ -590,10 +591,10 @@ Outputs version information.
 .RI [ event_nr ]
 .br
 Sleeps until the event counter for device_name exceeds event_nr.
-Use \-v to see the event number returned.
+Use \fB\-v\fP to see the event number returned.
 To wait until the next event is triggered, use \fBinfo\fP to find
 the last event number.
-With \-\-noflush, the thin target (from version 1.3.0) doesn't commit
+With \fB\-\-noflush\fP, the thin target (from version 1.3.0) doesn't commit
 any outstanding changes to disk before reporting its statistics.
 .SH TABLE FORMAT
 Each line of the table specifies a single target and is of the form:
@@ -637,7 +638,7 @@ for creating devices with holes in them.
 .br
 Returns blocks of zeroes on reads.  Any data written is discarded silently.
 This is a block-device equivalent of the /dev/zero character-device data sink
-described in \fBnull(4)\fP.
+described in \fBnull\fP(4).
 .P
 More complex targets include:
 .TP
@@ -708,7 +709,7 @@ A cookie to use for all relevant commands to synchronize with udev processing.
 It is an alternative to using \-\-udevcookie option.
 
 .SH AUTHORS
-Original version: Joe Thornber (thornber at sistina.com)
+Original version: Joe Thornber (thornber at redhat.com)
 
 .SH SEE ALSO
 Device-mapper resource page: http://sources.redhat.com/dm/
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 47c0a72..92cf1e7 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -128,8 +128,9 @@ activated only if it matches an item in the
 set in \fBlvm.conf\fP(5).
 For autoactivated logical volumes, \fB\-\-zero\fP \fIn\fP is always assumed
 and it can't be overridden. If the clustered locking is enabled,
-\fB\-a\fIey\fR will activate exclusively on one node and \fB\-a\fIly\fR will
-activate only on the local node.
+\fB\-a\fIey\fR will activate exclusively on one node and
+.IR \fB\-a { a | l } y
+will activate only on the local node.
 .TP
 .BR \-c ", " \-\-chunksize " " \fIChunkSize [ \fIbBsSkKmMgG ]
 Gives the size of chunk for snapshot and thin pool logical volumes.
@@ -189,7 +190,8 @@ suffix \fI%ORIGIN\fR.
 .TP
 .IR \fB\-L ", " \fB\-\-size " " LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
 Gives the size to allocate for the new logical volume.
-A size suffix of \fIK\fR for kilobytes, \fIM\fR for megabytes,
+A size suffix of \fIB\fR for bytes, \fIS\fR for sectors as 512 bytes,
+\fIK\fR for kilobytes, \fIM\fR for megabytes,
 \fIG\fR for gigabytes, \fIT\fR for terabytes, \fIP\fR for petabytes
 or \fIE\fR for exabytes is optional.
 .br
diff --git a/man/lvdisplay.8.in b/man/lvdisplay.8.in
index 9999849..84f21d3 100644
--- a/man/lvdisplay.8.in
+++ b/man/lvdisplay.8.in
@@ -112,5 +112,6 @@ original logical volume it is associated with:
 .SH SEE ALSO
 .BR lvm (8),
 .BR lvcreate (8),
+.BR lvs (8),
 .BR lvscan (8),
 .BR pvs (8)
diff --git a/man/lvmetad.8.in b/man/lvmetad.8.in
index ef1096d..7110877 100644
--- a/man/lvmetad.8.in
+++ b/man/lvmetad.8.in
@@ -41,10 +41,14 @@ Show help information.
 .B \-s \fIpath
 Path to the socket file to use. The option overrides both the built-in default
 (#DEFAULT_RUN_DIR#/lvmetad.socket) and the environment variable
-LVM_LVMETAD_SOCKET.
+\fBLVM_LVMETAD_SOCKET\fP.
 .TP
 .B \-V
-Show version of dmeventd.
+Display the version of lvmetad daemon.
+.SH ENVIRONMENT VARIABLES
+.TP
+.B LVM_LVMETAD_SOCKET 
+override path for socket file to use.
 
 .SH SEE ALSO
 .BR lvm (8),
diff --git a/man/pvdisplay.8.in b/man/pvdisplay.8.in
index 342c45b..6a8a0d0 100644
--- a/man/pvdisplay.8.in
+++ b/man/pvdisplay.8.in
@@ -89,6 +89,7 @@ Display output in columns, the equivalent of \fBpvs\fP(8).  See
 \fBpvdisplay\fP.
 .SH SEE ALSO
 .BR lvm (8),
+.BR pvs (8),
 .BR pvcreate (8),
 .BR lvcreate (8),
 .BR vgcreate (8)


