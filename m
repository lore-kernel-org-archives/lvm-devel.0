From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 21:05:58 +0000 (UTC)
Subject: master - doc: update --filemap usage in dmstats.8.in
Message-ID: <20160708210558.A0989608F3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=74565e41fc55a99c2c7b750225fd3a616ea84648
Commit:        74565e41fc55a99c2c7b750225fd3a616ea84648
Parent:        6a77a40501b6cc71d8e5af30393a1305fcd923ab
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Jul 8 22:05:14 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 22:05:36 2016 +0100

doc: update --filemap usage in dmstats.8.in

---
 man/dmstats.8.in |   44 ++++++++++++++++++++++++++------------------
 1 files changed, 26 insertions(+), 18 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index ce1368f..161ae8c 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -80,15 +80,15 @@ dmstats \(em device-mapper statistics management
 .de CMD_CREATE
 .  ad l
 .  BR create
-.  IR device_name
+.  RB [ device_name...
+.  RB | file_path... ]
 .  RB [ \-\-alldevices ]
 .  RB [ \-\-areas
 .  IR nr_areas | \fB\-\-areasize
 .  IR area_size ]
 .  RB [ \-\-bounds
 .  IR \%histogram_boundaries ]
-.  RB [ \-\-filemap
-.  IR path ]
+.  RB [ \-\-filemap ]
 .  RB [ \-\-nogroup ]
 .  RB [ \-\-precise ]
 .  RB [ \-\-start
@@ -299,11 +299,11 @@ results.
 .
 .HP
 .BR \-\-filemap
-.IR path
 .br
-Instead of creating regions specified by command line options, open
-the file found at \fBpath\fP, and create regions corresponding to the
-locations of the on-disk extents allocated to the file.
+Instead of creating regions on a device as specified by command line
+options, open the file found at each \fBfile_path\fP argument, and
+create regions corresponding to the locations of the on-disk extents
+allocated to the file(s).
 .
 .HP
 .BR \-\-groupid
@@ -544,13 +544,13 @@ By default dmstats creates regions with a \fBprogram_id\fP of
 On success the \fBregion_id\fP of the newly created region is printed
 to stdout.
 
-If the \fB\-\-filemap\fP option is given with a regular file as the
-\fBpath\fP argument, instead of creating regions with parameters
-specified on the command line, \fBdmstats\fP will open the file located
-at \fBpath\fP and create regions corresponding to the physical extents
-allocated to the file. This can be used to monitor statistics for
-individual files in the file system, for example, virtual machine
-images, swap areas, or large database files.
+If the \fB\-\-filemap\fP option is given with a regular file, or list
+of files, as the \fBfile_path\fP argument, instead of creating regions
+with parameters specified on the command line, \fBdmstats\fP will open
+the files located at \fBfile_path\fP and create regions corresponding to
+the physical extents allocated to the file. This can be used to monitor
+statistics for individual files in the file system, for example, virtual
+machine images, swap areas, or large database files.
 
 To work with the \fB\-\-filemap\fP option, files must be located on a
 local file system, backed by a device-mapper device, that supports
@@ -1045,13 +1045,21 @@ vg00-lvol1: Created new region with 1 area(s) as region ID 1
 .br
 vg00-lvol1: Created new region with 1 area(s) as region ID 2
 .P
-Create regions mapping the file vm.img and place them into a group with
-the alias set to the same name as the file.
+Create regions mapping each file in the directory images/ and place
+them into separate groups, each named after the corresponding file
 .br
 #
-.B dmstats create --filemap vm.img
+.B dmstats create --filemap images/*
+.br
+images/vm1.qcow2: Created new group with 87 region(s) as group ID 0.
+.br
+images/vm1-1.qcow2: Created new group with 8 region(s) as group ID 87.
+.br
+images/vm2.qcow2: Created new group with 11 region(s) as group ID 95.
+.br
+images/vm2-1.qcow2: Created new group with 1454 region(s) as group ID 106.
 .br
-vm.img: Created new group with 112 region(s) as group ID 3.
+images/vm3.img: Created new group with 2 region(s) as group ID 1560.
 .P
 Print raw counters for region 4 on device d0
 .br


