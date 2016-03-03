From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu,  3 Mar 2016 17:09:46 +0000 (UTC)
Subject: master - man: Add some information about historical LVs.
Message-ID: <20160303170946.6FB4260EEA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5764c484ea1eeef1c2726347ba2f93bb21fa4121
Commit:        5764c484ea1eeef1c2726347ba2f93bb21fa4121
Parent:        9a78c258ba8da349059138618858856f66cb7fed
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Mar 3 17:09:25 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Mar 3 17:09:25 2016 +0000

man: Add some information about historical LVs.

---
 man/lvm.8.in      |   17 ++++++++++++++++-
 man/lvremove.8.in |   18 ++++++++++++++++++
 man/lvs.8.in      |   16 +++++++++++-----
 3 files changed, 45 insertions(+), 6 deletions(-)

diff --git a/man/lvm.8.in b/man/lvm.8.in
index fe30b75..fd25001 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -482,7 +482,18 @@ The valid characters for VG and LV names are:
 .BR 0 - 9
 .BR "+ _ . -"
 .P
-VG and LV names cannot begin with a hyphen.
+VG names cannot begin with a hyphen.
+The name of a new LV also cannot begin with a hyphen.  However, if the
+configuration setting \fBmetadata/record_lvs_history\fP is enabled then an LV
+name with a hyphen as a prefix indicates that, although the LV was
+removed, it is still being tracked because it forms part of the history of at
+least one LV that is still present.  This helps to record the ancestry of
+thin snapshots even after some links in the chain have been removed.
+A reference to the historical LV 'lvol1' in VG 'vg00' would be 'vg00/-lvol1'
+or just '-lvol1' if the VG is already set.  (The latter form must be preceded
+by '--' to terminate command line option processing before reaching this
+argument.)
+.P
 There are also various reserved names that are used internally by lvm that can
 not be used as LV or VG names. A VG cannot be called anything that exists in
 \fI/dev/\fP at the time of creation, nor can it be called '.' or '..'.
@@ -501,6 +512,7 @@ Other software and scripts should use the
 amendment when the software is updated.  Should you need to process the node
 names in /dev/mapper, you may use \fBdmsetup splitname\fP to separate out the
 original VG, LV and internal layer names.
+.P
 .
 .SH UNIQUE NAMES
 .
@@ -522,6 +534,9 @@ An exception is if all but one of the VGs with the shared name is foreign
 .BR lvmsystemid (7).)
 In this case, the one VG that is not foreign is assumed to be the intended
 VG and is processed.
+.P
+LV names are unique within a VG.  The name of an historical LV cannot be
+reused until the historical LV has itself been removed or renamed.
 
 .
 .SH ALLOCATION
diff --git a/man/lvremove.8.in b/man/lvremove.8.in
index 8cf1bf3..433c277 100644
--- a/man/lvremove.8.in
+++ b/man/lvremove.8.in
@@ -9,6 +9,7 @@ lvremove \(em remove a logical volume
 .IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
+.RB [ \-\-nohistory ]
 .RB [ \-S | \-\-select
 .IR Selection ]
 .RB [ \-t | \-\-test ]
@@ -27,6 +28,18 @@ Removing an origin logical volume will also remove all dependent snapshots.
 If the logical volume is clustered then it must be deactivated on all
 nodes in the cluster before it can be removed. A single lvchange command
 issued from one node can do this.
+.sp
+If the configuration setting \fBmetadata/record_lvs_history\fP is enabled 
+and the logical volume being removed forms part of the history of at least
+one logical volume that is still present then a simplified representation of
+the logical volume will be retained.  This includes the time of removal
+(\fBlv_time_removed\fP reporting field), creation time (\fBlv_time\fP), name
+(\fBlv_name\fP), LV uuid (\fBlv_uuid\fP) and VG name (\fBvg_name\fP) and
+allows you to see the ancestry chain of thin snapshot volumes even after
+some intermediate logical volumes have been removed.
+The names of such historical logical volumes acquire a hyphen as a prefix
+(e.g. '-lvol1') and cannot be reactivated.  Use lvremove a second time,
+with the hyphen, to remove the record of the former logical volume completely.
 .SH OPTIONS
 See \fBlvm\fP(8) for common options.
 .TP
@@ -35,6 +48,11 @@ Remove active logical volumes without confirmation.
 Tool will try to deactivate \fIunused\fP volume.
 To proceed with damaged pools use \-ff
 .TP
+.B \-\-nohistory
+Disable the recording of history of logical volumes which are being removed.
+(This has no effect unless the configuration setting
+\fBmetadata/record_lvs_history\fP is enabled.)
+.TP
 .B \-\-noudevsync
 Disable udev synchronisation. The
 process will not wait for notification from udev.
diff --git a/man/lvs.8.in b/man/lvs.8.in
index df61497..d4bc7f2 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -10,6 +10,7 @@ lvs \(em report information about logical volumes
 .IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
+.RB [ \-H | \-\-history ]
 .RB [ \-\-ignorelockingfailure ]
 .RB [ \-\-ignoreskippedcluster ]
 .RB [ \-\-nameprefixes ]
@@ -60,6 +61,11 @@ in the output.  For example, after creating a mirror using
 , this option will reveal three internal Logical
 Volumes, with suffixes mimage_0, mimage_1, and mlog.
 .TP
+.B \-H ", " \-\-history
+Include historical logical volumes in the output.
+(This has no effect unless logical volumes were removed while the configuration
+setting \fBmetadata/record_lvs_history\fP was enabled.)
+.TP
 .B \-\-nameprefixes
 Add an "LVM2_" prefix plus the field name to the output.  Useful
 with \fB\-\-noheadings\fP to produce a list of field=value pairs that can
@@ -166,11 +172,11 @@ changes, for example during
 .IP 4 3
 fixed (m)inor
 .IP 5 3
-State: (a)ctive, (s)uspended, (I)nvalid snapshot, invalid (S)uspended snapshot,
-snapshot (m)erge failed, suspended snapshot (M)erge failed,
-mapped (d)evice present without tables, mapped device present with (i)nactive table,
-thin-pool (c)heck needed, suspended thin-pool (C)heck needed,
-(X) unknown
+State: (a)ctive, (h)istorical, (s)uspended, (I)nvalid snapshot,
+invalid (S)uspended snapshot, snapshot (m)erge failed,
+suspended snapshot (M)erge failed, mapped (d)evice present without tables,
+mapped device present with (i)nactive table, thin-pool (c)heck needed,
+suspended thin-pool (C)heck needed, (X) unknown
 .IP 6 3
 device (o)pen, (X) unknown
 .IP 7 3


