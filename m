From: Brassow Jonathan <jbrassow@redhat.com>
Date: Fri, 13 May 2016 18:23:52 -0500
Subject: LVM RAID man page (lvmraid.7)
Message-ID: <5ECBB141-6118-4C80-8710-7D7243CA38AB@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Before I get to far on this, I?m hoping for some comments.  Feel free to gripe about syntax, but I?m looking especially for feedback on additional topics that may be desired or comments on the general approach (I?m modeling it after lvmthin.7).

Thanks,
 brassow

Index: lvm2/man/lvmraid.7.in
===================================================================
--- /dev/null
+++ lvm2/man/lvmraid.7.in
@@ -0,0 +1,178 @@
+.TH "LVMRAID" "7" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
+
+.mso www.tmac
+
+.SH NAME
+lvmraid \(em LVM RAID
+
+.SH DESCRIPTION
+
+LVM provides a variety of RAID types for users to select from; offering
+different options for performance, redundancy, and space utilization (see
+.BR "RAID Segment Types" ).
+LVM leverages the device-mapper kernel
+infrastructure to instantiate logical volumes.  As such, logical volumes
+types like "mirror" and "stripe" were built on native device-mapper
+targets.  However, the 2.6.38-rc1 version of the linux kernel introduced
+a device-mapper target to interface with the MD (aka "Software RAID")
+personalities in the kernel.  This provided device-mapper with RAID 4/5/6
+capabilities and a vibrant community to enhance and maintiain them.
+Later, support for RAID 1, RAID 10, and RAID1E (RAID 10 variants) were
+added.  Support for these new kernel targets was added to LVM in version
+2.02.87 and has been under active development and maintenance since then.
+The capabilities of the new LVM RAID 1 segment type have eclipsed the native
+target; and it is now recommended to use the "raid1" segment type over the
+"mirror" segment type.  (The "raid1" segment type became the default in
+LVM version 2.02.100.)
+
+
+.SH RAID Terms
+
+.TP
+Sub-LV or subLV
+.br
+A subsumed logical volume.
+.br
+A logial volume that is a part of an encapsulating logical volume that
+usually provides additional volume management characteristics.  These
+subLVs are normally "hidden", that is, not reported when displaying
+logical volumes using 'lvs' without the '-a' option.
+
+.TP
+RaidMetadataLV, MetadataLV, or MetaLV
+.br
+The RAID metadata logical volume.
+.br
+The MetadataLVs are used to store RAID superblock information which contains
+the bitmap, device health information, RAID type, and more.
+
+.TP
+RaidDataLV or DataLV
+.br
+The RAID data logical volume.
+.br
+The DataLVs are the devices holding the data or parity information.
+
+.TP
+RaidLV
+.br
+The RAID logical volume.
+.br
+The RAID logical volume is the object presented to the host level for
+user data storage.  The corresponding SNIA term is
+.URL http://www.snia.org/sites/default/files/SNIA_DDF_Technical_Position_v2.0.pdf "virtual disk" "."
+It is composed of at least two DataLV/MetaLV pairs, although rare instances
+allow for the ommission of MetaLVs.
+
+.TP
+Sync, Resync, or Initialize.
+.br
+RAID Synchronization.
+.br
+The process by which the RAID logical volume is made coherent when it is
+activated.  For example, when a single device is converted into a RAID-1
+volume, the contents of the first device must be copied to the remaining
+devices.  This is RAID synchronization.  Likewise, when a RAID 4/5/6
+logical volume is created, the parity blocks must all be computed and
+written.  This process would have to be repeated every time the RaidLV
+was activated if a bitmap were not used in the MetaLV to track what
+portions of the RaidLV are already synchronized.  This process is the
+same whether it is being done for the first time (initialization), a
+subsequent time (resync), manually forced (sync), requiring a full sync,
+or partial sync.  These terms are often interchangeable.
+
+.TP
+Scrubbing, Mismatch Check, RAID Check, or Check
+.br
+RAID Scrubbing.
+.br
+RAID scrubbing is the process of reading everything from the DataLVs and
+checking that they are consistent.  For RAID-1/10, this would mean ensuring
+that all the copies are identical.  For RAID-4/5/6, this would mean reading
+all the data and ensuring the calculated parity is the same as what is
+recorded on the storage device.  Scrubbing can be done in a "check" mode
+or "repair" mode.  The "check" mode is read-only and is only used to
+discover any potential issues.  The "repair" mode will forcibly update
+any inconsistencies found using the same algorithms that are used during
+RAID synchronization (this may not always be what you want!).
+
+.TP
+SyncAction
+.br
+RAID Synchronization Action
+.br
+A RAID synchronization action is any I/O action performed by the RaidLV
+outside those invoked by the user through nominal I/O.  RAID synchronization,
+and RAID scrubbing (either "check" or "repair") are SyncActions.
+
+.SH RAID Usage
+When creating a logical volume, the type (e.g. linear, stripe, raid1, etc)
+often is not explicitly specified on the command line.  This is because the
+"--type SegmentType" argument to
+.B lvcreate
+can often be inferred.  For example, the "-i Stripes" argument that signals
+the number of stripes desired would imply a "--type stripe" argument.  The
+same is true for "-m MirrorCopies" implying the "--type raid1" argument.
+Since there are several different RAID types, it is not so easy to infer
+the RAID type from the arguments.  Thus, the "--type SegmentType" argument
+is required when the arguments are not sufficient to imply a specific RAID
+type.  Below are a couple examples.
+
+.SS 1. Create a 500GiB, 2-disk, RAID-1 logical volume
+Please note that when creating RAID-1 logical volumes, the "-m MirrorCopies"
+argument is the number of
+.I extra
+copies.  A "-m 1" argument would signal a 2-way mirror, a "-m 2" argument
+would signal a 3-way mirror, and so on.
+
+Using long arguments:
+.br
+# lvcreate --type raid1 --size 500G --mirrors 1 --name myRaid1 my_vg
+
+Using short arguments:
+.br
+# lvcreate --type raid1 -L 500G -m 1 -n myRaid1 my_vg
+
+Using implied "--type raid1" argument (See
+.BR "RAID Configuration Options" ):
+.br
+# lvcreate -L 500G -m 1 -n myRaid1 my_vg
+
+Using specific devices in the volume group:
+.br
+# lvcreate -L 500G -m 1 -n myRaid1 my_vg /dev/sd[bc]
+
+
+
+
+.SH RAID Topics
+.B RAID Segment Types
+.br
+.B RAID Initialization
+.br
+.B RAID Conversion
+.br
+.B RAID Scrubbing
+.br
+.B RAID Configuration Options
+.br
+.B RAID Monitoring
+.br
+.B Handling Device Failures
+.br
+.B RAID Take-over
+.br
+.B RAID Reshaping
+.br
+.B RAID Duplication
+
+.SH SEE ALSO
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvcreate (8),
+.BR lvconvert (8),
+.BR lvchange (8),
+.BR lvextend (8),
+.BR lvremove (8),
+.BR lvs (8)


