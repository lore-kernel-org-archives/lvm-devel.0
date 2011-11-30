From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Nov 2011 22:32:38 -0000
Subject: LVM2/man dmsetup.8.in
Message-ID: <20111130223238.9766.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-11-30 22:32:37

Modified files:
	man            : dmsetup.8.in 

Log message:
	refer to kernel docs for target info
	FIXME thin still missing

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.46&r2=1.47

--- LVM2/man/dmsetup.8.in	2011/11/13 01:41:57	1.46
+++ LVM2/man/dmsetup.8.in	2011/11/30 22:32:37	1.47
@@ -532,16 +532,13 @@
 To wait until the next event is triggered, use \fBinfo\fP to find
 the last event number.
 .SH TABLE FORMAT
-// FIXME Rewrite safely (a lot of work) or remove.
 Each line of the table specifies a single target and is of the form:
 .P
 .I logical_start_sector num_sectors
 .B target_type
 .RI < target_args >
 .P
-There are currently three simple target types available (linear,
-striped, error) together with more complex optional ones that implement
-e.g. snapshots and mirrors.
+Simple target types and <target_args> include: 
 .HP
 .B linear
 .I destination_device start_sector
@@ -572,83 +569,49 @@
 Errors any I/O that goes to this area.  Useful for testing or
 for creating devices with holes in them.
 .TP
+.B zero
+.br
+Returns blocks of zeroes on reads.  Any data written is discarded silently.
+This is a block-device equivalent of the /dev/zero character-device data sink
+described in \fBnull(4)\fP.
+.P
+More complex targets include:
+.TP
 .B crypt
-.I cipher key iv_offset destination offset
-.RI [ num_params
-.RI < params >]
 .br
-Target for transparent encryption of block devices
-using the kernel crypto API.
+Transparent encryption of block devices using the kernel crypto API.
 .TP
 .B delay
-.I read_device read_offset read_delay
-.RI [ write_device
-.I write_offset
-.IR write_delay ]
 .br
-Creates mapping that "delays" reads and/or writes
-to different devices.
+Delays reads and/or writes to different devices.  Useful for testing.
 .TP
 .B flakey
-.I destination_device start_sector up_interval
-.I down_interval
-.RI [ num_features
-.RI [< feature_arguments >]]
-.br
-Creates the same mapping as the linear target except
-that it exhibits unreliable behaviour periodically.
-Useful for simulating failing devices for testing
-purposes.
+.br
+Creates a similar mapping to the linear target but
+exhibits unreliable behaviour periodically.
+Useful for simulating failing devices when testing.
 .TP
 .B mirror
-.I log_type num_logargs
-.RI < logargs >
-.I num_devices
-.RI < device
-.IR offset >+
 .br
-Creates mirror mapping target for mirrored logical devices.
+Mirrors data across two or more devices.
 .HP
 .B multipath
-.I num_features
-.RI < features >
-.I num_handle_args
-.RI < handle_args >
-.I num_path_groups
-.I path_group
-.RI < path_group_args1\.\.N >
-.br
-Creates multipath mapping.
-.TP
-.BR raid1 | raid4 | raid5_ { la | ra | ls | rs }| raid6_ { zr | mr | nc }
-.I num_raid_params
-.RI < raid_params >
-.I num_raid_devs
-.RI < metadata_device
-.IR device >+
-.br
-Creates RAID "bridge" mapping between DM and MD.
-It allows the MD RAID drivers to be
-accessed using a device-mapper interface.
-.HP
-.B snapshot
-.I origin_device cow_device persistant chunksize
 .br
-.HP
-.B snapshot-merge
-.I origin_device cow_device persistant chunksize
+Mediates access through multiple paths to the same device.
+.TP
+.BR raid
 .br
+Offers an interface to the kernel's software raid driver, md.
 .HP
-.B snapshot-origin
-.I origin_device
-.br
-Supports device snapshots.
-.TP
-.B zero
+.B snapshot
 .br
-Returns always zeroed data on reads and silently drops writes.
-This is similar behavior to /dev/zero, but as a block-device instead
-of a character device.
+Supports snapshots of devices.
+.P
+To find out more about the various targets and their table formats and status
+lines, please read the files in the Documentation/device-mapper directory in
+the kernel source tree.  
+(Your distribution might include a copy of this information in the 
+documentation directory for the device-mapper package.)
 
 .SH EXAMPLES
 


