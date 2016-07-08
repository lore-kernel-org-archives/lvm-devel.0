From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 18:26:46 +0000 (UTC)
Subject: master - doc: update dmstats.8.in for --filemap and --nogroup
Message-ID: <20160708182646.E1BC760FCF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d901468a273327b78207e60fde2ab5f8c3a6cbc7
Commit:        d901468a273327b78207e60fde2ab5f8c3a6cbc7
Parent:        7ebe630b696e3bdbd66760ba140e05d11a999df5
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Jul 1 21:41:25 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 14:34:41 2016 +0100

doc: update dmstats.8.in for --filemap and --nogroup

---
 man/dmstats.8.in |   48 ++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 46 insertions(+), 2 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index 6bbcc63..b00ef88 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -87,6 +87,9 @@ dmstats \(em device-mapper statistics management
 .  IR area_size ]
 .  RB [ \-\-bounds
 .  IR \%histogram_boundaries ]
+.  RB [ \-\-filemap
+.  IR path ]
+.  RB [ \-\-nogroup ]
 .  RB [ \-\-precise ]
 .  RB [ \-\-start
 .  IR start_sector
@@ -299,6 +302,14 @@ When peforming a list or report, include objects of type group in the
 results.
 .
 .HP
+.BR \-\-filemap
+.IR path
+.br
+Instead of creating regions specified by command line options, open
+the file found at \fBpath\fP, and create regions corresponding to the
+locations of the on-disk extents allocated to the file.
+.
+.HP
 .BR \-\-groupid
 .IR id
 .br
@@ -356,6 +367,12 @@ Specify the major number.
 Specify the minor number.
 .
 .HP
+.BR \-\-nogroup
+.br
+When creating regions mapping the extents of a file in the file
+system, do not create a group or set an alias.
+.
+.HP
 .BR \-\-nosuffix
 .br
 Suppress the suffix on output sizes.  Use with \fB\-\-units\fP
@@ -538,8 +555,27 @@ device-mapper kernel statistics subsystem.
 By default dmstats creates regions with a \fBprogram_id\fP of
 "dmstats".
 
-On success the \fBregion_id\fP of the newly created region is printed to
-stdout.
+On success the \fBregion_id\fP of the newly created region is printed
+to stdout.
+
+If the \fB\-\-filemap\fP option is given with a regular file as the
+\fBpath\fP argument, instead of creating regions with parameters
+specified on the command line, \fBdmstats\fP will open the file located
+at \fBpath\fP and create regions corresponding to the physical extents
+allocated to the file. This can be used to monitor statistics for
+individual files in the file system, for example, virtual machine
+images, swap areas, or large database files.
+
+To work with the \fB\-\-filemap\fP option, files must be located on a
+local file system, backed by a device-mapper device, that supports
+physical extent data using the FIEMAP ioctl (Ext4 and XFS for e.g.).
+
+By default regions that map a file are placed into a group and the
+group alias is set to the basename of the file. This behaviour can be
+overridden with the \fB\-\-alias\fP and \fB\-\-nogroup\fP options.
+
+To display only group information when listing and reporting, use the
+\fB\-\-statstype\fP option with the 'group' type.
 .
 .HP
 .CMD_DELETE
@@ -1019,6 +1055,14 @@ vg00-lvol1: Created new region with 1 area(s) as region ID 1
 .br
 vg00-lvol1: Created new region with 1 area(s) as region ID 2
 .P
+Create regions mapping the file vm.img and place them into a group with
+the alias set to the same name as the file.
+.br
+#
+.B dmstats create --filemap vm.img
+.br
+vm.img: Created new group with 112 region(s) as group ID 3.
+.P
 Print raw counters for region 4 on device d0
 .br
 #


