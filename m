From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 13 Jan 2010 01:55:05 -0000
Subject: LVM2/man lvconvert.8.in
Message-ID: <20100113015505.22369.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-13 01:55:05

Modified files:
	man            : lvconvert.8.in 

Log message:
	Update lvconvert manpage for snapshot --merge

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/man/lvconvert.8.in	2010/01/12 14:00:51	1.12
+++ LVM2/man/lvconvert.8.in	2010/01/13 01:55:05	1.13
@@ -31,7 +31,18 @@
 [\-\-version]
 .br
 OriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]
+.br
 
+.br
+.B lvconvert
+\-\-merge [\-b|\-\-background] [\-i|\-\-interval Seconds]
+[\-h|\-?|\-\-help]
+[\-v|\-\-verbose]
+[\-\-version]
+SnapshotLogicalVolume[Path]
+.br
+
+.br
 .B lvconvert
 \-\-repair
 [\-h|\-?|\-\-help]
@@ -54,7 +65,8 @@
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .br
-Exactly one of \-\-splitmirrors, \-\-mirrors, \-\-repair or \-\-snapshot arguments required.
+Exactly one of \-\-splitmirrors, \-\-mirrors, \-\-repair, \-\-snapshot
+or \-\-merge arguments is required.
 .br
 .TP
 .I \-m, \-\-mirrors Mirrors
@@ -119,6 +131,17 @@
 .I \-Z, \-\-zero y|n
 Controls zeroing of the first KB of data in the snapshot.
 If the volume is read-only the snapshot will not be zeroed.
+.TP
+.I \-\-merge
+Merges a snapshot into its origin volume. If both the origin and snapshot volume
+are not open the merge will start immediately.  Otherwise, the merge will start
+the first time either the origin or snapshot are activated and both are closed.
+Merging a snapshot into an origin that cannot be closed, for example a root
+filesystem, is deferred until the next time the origin volume is activated.
+When merging starts, the resulting logical volume will have the origin's name,
+minor number and UUID.  While the merge is in progress, reads or writes to the
+origin appear as they were directed to the snapshot being merged.  When the
+merge finishes, the merged snapshot is removed.
 .br
 
 
@@ -171,6 +194,11 @@
 converts mirror logical volume "vg00/lvmirror1" to linear, freeing physical
 extents from /dev/sda.
 
+.br
+"lvconvert --merge vg00/lvol1_snap"
+.br
+merges "vg00/lvol1_snap" into its origin.
+
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgcreate (8),


