From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 24 Jun 2016 12:52:19 +0000 (UTC)
Subject: master - man: document --configreport, --logonly, --reportformat
Message-ID: <20160624125219.23FF360FA0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a910052a2e7da4531ff0e39e569ab2eaa56b1870
Commit:        a910052a2e7da4531ff0e39e569ab2eaa56b1870
Parent:        9a414245b908bfa1bacb12b6416908de65f0e317
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jun 24 14:51:20 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 24 14:51:20 2016 +0200

man: document --configreport, --logonly, --reportformat

---
 man/lvchange.8.in    |    2 ++
 man/lvcreate.8.in    |    4 ++++
 man/lvdisplay.8.in   |   20 ++++++++++++++------
 man/lvextend.8.in    |    2 ++
 man/lvm.8.in         |   10 ++++++++++
 man/lvreduce.8.in    |    2 ++
 man/lvremove.8.in    |    2 ++
 man/lvrename.8.in    |    2 ++
 man/lvresize.8.in    |    2 ++
 man/lvs.8.in         |   29 ++++++++++++++++++++++++-----
 man/lvscan.8.in      |    2 ++
 man/pvchange.8.in    |    2 ++
 man/pvcreate.8.in    |    2 ++
 man/pvdisplay.8.in   |   21 ++++++++++++++-------
 man/pvmove.8.in      |    2 ++
 man/pvremove.8.in    |    2 ++
 man/pvresize.8.in    |    2 ++
 man/pvs.8.in         |   30 ++++++++++++++++++++++++------
 man/pvscan.8.in      |    4 ++++
 man/vgcfgbackup.8.in |    2 ++
 man/vgchange.8.in    |    2 ++
 man/vgck.8.in        |    2 ++
 man/vgconvert.8.in   |    2 ++
 man/vgcreate.8.in    |    2 ++
 man/vgdisplay.8.in   |   20 ++++++++++++++------
 man/vgexport.8.in    |    2 ++
 man/vgextend.8.in    |    2 ++
 man/vgimport.8.in    |    2 ++
 man/vgmknodes.8.in   |    2 ++
 man/vgreduce.8.in    |    2 ++
 man/vgremove.8.in    |    2 ++
 man/vgrename.8.in    |    2 ++
 man/vgs.8.in         |   30 ++++++++++++++++++++++++------
 man/vgscan.8.in      |    2 ++
 34 files changed, 182 insertions(+), 36 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 2bfe7c0..3800369 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -76,6 +76,8 @@ lvchange \(em change attributes of a logical volume
 .RB [ \-r | \-\-readahead
 .RB { \fIReadAheadSectors | auto | none }]
 .RB [ \-\-refresh ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-\-resync ]
 .RB [ \-S | \-\-select
 .IR Selection ]
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index c28bc41..3e2bf32 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -93,6 +93,8 @@ lvcreate \- create a logical volume in an existing volume group
 .IR Rate ]
 .RB [ \-r | \-\-readahead
 .RB { \fIReadAheadSectors | auto | none }]
+.RB [ \-\-reportformat
+.RB {basic | json}]
 .RB \%[ \-k | \-\-setactivationskip
 .RB { y | n }]
 .RB [ \-s | \-\-snapshot ]
@@ -133,6 +135,8 @@ lvcreate \- create a logical volume in an existing volume group
 .RB { y | n }]
 .RB [ \-n | \-\-name
 .IR SnapshotLogicalVolumeName ]
+.RB [ \-\-reportformat
+.RB {basic | json}]
 .BR \-s | \-\-snapshot | \-H | \-\-cache
 .RI \%{[ VolumeGroup \fB/\fP] OriginalLogicalVolume
 .RB \%[ \-V | \-\-virtualsize
diff --git a/man/lvdisplay.8.in b/man/lvdisplay.8.in
index f14fa03..e8e7809 100644
--- a/man/lvdisplay.8.in
+++ b/man/lvdisplay.8.in
@@ -14,6 +14,8 @@ lvdisplay \(em display attributes of a logical volume
 .RB [ \-\-maps ]
 .RB [ \-\-nosuffix ]
 .RB [ \-P | \-\-partial ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-S | \-\-select
 .IR Selection ]
 .RB [ \-\-units
@@ -30,20 +32,26 @@ lvdisplay \(em display attributes of a logical volume
 .RB [ \-a | \-\-all ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
+.RB [[ \-\-configreport
+.IR ReportName ]
+.RB [ \-o | \-\-options
+.RI [ + | \- | # ] Field1 [, Field2 ...]
+.RB [ \-O | \-\-sort
+.RI [ + | \- ] Key1 [, Key2 ...]]
+.RB [ \-S | \-\-select
+.IR Selection ]
+.RB ...]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
 .RB [ \-\-ignoreskippedcluster ]
+.RB [ \-\-logonly ]
 .RB [ \-\-noheadings ]
 .RB [ \-\-nosuffix ]
-.RB [ \-o | \-\-options
-.RI [ + | \- | # ] Field [ ,Field ...]]
-.RB [ \-O | \-\-sort
-.RI [ + | \- ] Key1 [ , [ + | \- ] Key2 ...]]
 .RB [ \-P | \-\-partial ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-\-segments ]
-.RB [ \-S | \-\-select
-.IR Selection ]
 .RB [ \-\-separator
 .IR Separator ]
 .RB [ \-\-unbuffered ]
diff --git a/man/lvextend.8.in b/man/lvextend.8.in
index 8deab54..eefbf79 100644
--- a/man/lvextend.8.in
+++ b/man/lvextend.8.in
@@ -24,6 +24,8 @@ lvextend \(em extend the size of a logical volume
 .RB [ \-n | \-\-nofsck ]
 .RB [ \-\-noudevsync]
 .RB [ \-r | \-\-resizefs ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-\-use\-policies ]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
diff --git a/man/lvm.8.in b/man/lvm.8.in
index f8400cf..729518b 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -466,6 +466,16 @@ for any other command (with the exception of \fBlvmconfig\fP command where the
 \fB\-\-profile\fP has special meaning, see \fBlvmconfig\fP(8) for more information).
 .
 .HP
+.BR \-\-reportformat
+.IR {basic|json}
+.br
+Overrides current output format for reports which is defined globally by
+\fBreport/output_format\fP configuration setting in \fBlvm.conf\fP(5).
+The \fBbasic\fP format is the original format with columns and rows and
+if there is more than one report per command, each report is prefixed
+with report's name for identification. The \fBjson\fP stands for report
+output in JSON format.
+.HP
 .BR \-\-config
 .IR ConfigurationString
 .br
diff --git a/man/lvreduce.8.in b/man/lvreduce.8.in
index 5aca24e..edf0c92 100644
--- a/man/lvreduce.8.in
+++ b/man/lvreduce.8.in
@@ -20,6 +20,8 @@ lvreduce \(em reduce the size of a logical volume
 .BR \-L | \-\-size
 .RI [ \- ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]}
 .RB [ \-n | \-\-nofsck ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-r | \-\-resizefs ]
 .IR LogicalVolume { Name | Path }
 .SH DESCRIPTION
diff --git a/man/lvremove.8.in b/man/lvremove.8.in
index 433c277..fe9375c 100644
--- a/man/lvremove.8.in
+++ b/man/lvremove.8.in
@@ -10,6 +10,8 @@ lvremove \(em remove a logical volume
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-\-nohistory ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-S | \-\-select
 .IR Selection ]
 .RB [ \-t | \-\-test ]
diff --git a/man/lvrename.8.in b/man/lvrename.8.in
index fdacac7..de6e519 100644
--- a/man/lvrename.8.in
+++ b/man/lvrename.8.in
@@ -14,6 +14,8 @@ lvrename \(em rename a logical volume
 .RB [ \-\-version ]
 .RB [ \-f | \-\-force ]
 .RB [ \-\-noudevsync ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RI { OldLogicalVolume { Name | Path }
 .IR NewLogicalVolume { Name | Path }
 |
diff --git a/man/lvresize.8.in b/man/lvresize.8.in
index a5bda53..9cdb787 100644
--- a/man/lvresize.8.in
+++ b/man/lvresize.8.in
@@ -17,6 +17,8 @@ lvresize \(em resize a logical volume
 .RI [ + ] MetadataVolumeSize [ bBsSkKmMgG ]]
 .RB [ \-f | \-\-force ]
 .RB [ \-n | \-\-nofsck ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-r | \-\-resizefs ]
 .IR LogicalVolume { Name | Path }
 .RI [ PhysicalVolumePath [ :PE [ \-PE ]]...]
diff --git a/man/lvs.8.in b/man/lvs.8.in
index d4bc7f2..7bd25a6 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -8,22 +8,29 @@ lvs \(em report information about logical volumes
 .RB [ \-a | \-\-all ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
+.RB [[ \-\-configreport
+.IR ReportName ]
+.RB [ \-o | \-\-options
+.RI [ + | \- | # ] Field1 [, Field2 ...]
+.RB [ \-O | \-\-sort
+.RI [ + | \- ] Key1 [, Key2 ...]]
+.RB [ \-S | \-\-select
+.IR Selection ]
+.RB ...]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-H | \-\-history ]
 .RB [ \-\-ignorelockingfailure ]
 .RB [ \-\-ignoreskippedcluster ]
+.RB [ \-\-logonly ]
 .RB [ \-\-nameprefixes ]
 .RB [ \-\-noheadings ]
 .RB [ \-\-nosuffix ]
-.RB [ \-o | \-\-options
-.RI [ + | \- | # ] Field [, Field ]]
-.RB [ \-O | \-\-sort
 .RI [ + | \- ] Key1 [,[ + | \- ] Key2 [,...]]]
 .RB [ \-P | \-\-partial ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-\-rows ]
-.RB [ \-S | \-\-select
-.IR Selection ]
 .RB [ \-\-separator
 .IR Separator ]
 .RB [ \-\-segments ]
@@ -51,6 +58,15 @@ Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
 .TP
+.B \-\-configreport  \fI ReportName
+Make any subsequent \fB\-o, \-\-options\fP, \fB\-O, \-\-sort\fP or
+\fB\-S, \-\-select\fP to apply for \fIReportName\fP where \fIReportName\fP
+is either 'lvs' for command's main report or 'log' for log report.
+If \fB\-\-configreport\fP option is not used to identify a report, then
+command's main report is assumed. The log report is available only if
+enabled by \fBlog/report_command_log\fP \fBlvm.conf\fP(5) setting or
+if \fB\-\-logonly\fP option is used.
+.TP
 .B \-\-all
 Include information in the output about internal Logical Volumes that
 are components of normally-accessible Logical Volumes, such as mirrors,
@@ -66,6 +82,9 @@ Include historical logical volumes in the output.
 (This has no effect unless logical volumes were removed while the configuration
 setting \fBmetadata/record_lvs_history\fP was enabled.)
 .TP
+.B \-\-logonly
+Suppress the lvs report itself and display only log report on output.
+.TP
 .B \-\-nameprefixes
 Add an "LVM2_" prefix plus the field name to the output.  Useful
 with \fB\-\-noheadings\fP to produce a list of field=value pairs that can
diff --git a/man/lvscan.8.in b/man/lvscan.8.in
index 0b6e50b..5710e3c 100644
--- a/man/lvscan.8.in
+++ b/man/lvscan.8.in
@@ -11,6 +11,8 @@ lvscan \(em scan (all disks) for Logical Volumes
 .RB [ \-h | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
 .RB [ \-P | \-\-partial ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-v | \-\-verbose ]
 .SH DESCRIPTION
 lvscan scans all known volume groups or all supported LVM block devices
diff --git a/man/pvchange.8.in b/man/pvchange.8.in
index 5c5b809..c7ddc58 100644
--- a/man/pvchange.8.in
+++ b/man/pvchange.8.in
@@ -16,6 +16,8 @@ pvchange \(em change attributes of a physical volume
 .RB [ \-\-metadataignore
 .RI { y | n }]
 .RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-S | \-\-select
 .IR Selection ]
 .RB [ \-t | \-\-test ]
diff --git a/man/pvcreate.8.in b/man/pvcreate.8.in
index a50aaa7..97a9909 100644
--- a/man/pvcreate.8.in
+++ b/man/pvcreate.8.in
@@ -31,6 +31,8 @@ pvcreate \(em initialize a disk or partition for use by LVM
 .RB [ \-\-restorefile
 .IR file ]
 .RB [ \-\-norestorefile ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-\-setphysicalvolumesize
 .IR size ]
 .RB [ \-u | \-\-uuid
diff --git a/man/pvdisplay.8.in b/man/pvdisplay.8.in
index 5f93634..9bca720 100644
--- a/man/pvdisplay.8.in
+++ b/man/pvdisplay.8.in
@@ -12,6 +12,8 @@ pvdisplay \- display attributes of a physical volume
 .RB [ \-\-ignoreskippedcluster ]
 .RB [ \-\-maps ]
 .RB [ \-\-nosuffix ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-s | \-\-short ]
 .RB [ \-S | \-\-select
 .IR Selection ]
@@ -30,19 +32,24 @@ pvdisplay \- display attributes of a physical volume
 .RB [ \-\-binary ]
 .RB [ \-a | \-\-all ]
 .RB [ \-\-commandprofile
+.RB [[ \-\-configreport
+.IR ReportName ]
+.RB [ \-o | \-\-options
+.RI [ + | \- | # ] Field1 [, Field2 ...]
+.RB [ \-O | \-\-sort
+.RI [ + | \- ] Key1 [, Key2 ...]]
+.RB [ \-S | \-\-select
+.IR Selection ]
+.RB ...]
 .IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
+.RB [ \-\-logonly ]
 .RB [ \-\-noheadings ]
 .RB [ \-\-nosuffix ]
-.RB [ \-o | \-\-options
-.RI [ + | \- | # ] Field [ ,Field ...]]
-.RB [ \-O | \-\-sort
-.RI [ + | \- ] Key1 [ , [ + | \- ] Key2 ...
-.RI ]]
-.RB [ \-S | \-\-select
-.IR Selection ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-\-separator
 .IR Separator ]
 .RB [ \-\-unbuffered ]
diff --git a/man/pvmove.8.in b/man/pvmove.8.in
index 43a4e00..39fdfe4 100644
--- a/man/pvmove.8.in
+++ b/man/pvmove.8.in
@@ -15,6 +15,8 @@ pvmove \(em move physical extents
 .RB [ \-i | \-\-interval
 .IR Seconds ]
 .RB [ \-\-noudevsync ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-n | \-\-name
 .IR LogicalVolume ]
diff --git a/man/pvremove.8.in b/man/pvremove.8.in
index 5f9b055..6444884 100644
--- a/man/pvremove.8.in
+++ b/man/pvremove.8.in
@@ -12,6 +12,8 @@ pvremove \(em remove a physical volume
 .RB [ \-\-version ]
 .RB [ \-f [ f ]| \-\-force 
 .RB [ \-\-force ]]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-y | \-\-yes ]
 .I PhysicalVolume
 .RI [ PhysicalVolume ...]
diff --git a/man/pvresize.8.in b/man/pvresize.8.in
index 8b78651..b7d8f33 100644
--- a/man/pvresize.8.in
+++ b/man/pvresize.8.in
@@ -10,6 +10,8 @@ pvresize \(em resize a disk or partition in use by LVM2
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-\-setphysicalvolumesize
 .IR size ]
 .I PhysicalVolume 
diff --git a/man/pvs.8.in b/man/pvs.8.in
index 24d16fb..0a60b6f 100644
--- a/man/pvs.8.in
+++ b/man/pvs.8.in
@@ -8,22 +8,28 @@ pvs \(em report information about physical volumes
 .RB [ \-\-binary ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
+.RB [[ \-\-configreport
+.IR ReportName ]
+.RB [ \-o | \-\-options
+.RI [ + | \- | # ] Field1 [, Field2 ...]
+.RB [ \-O | \-\-sort
+.RI [ + | \- ] Key1 [, Key2 ...]]
+.RB [ \-S | \-\-select
+.IR Selection ]
+.RB ...]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
 .RB [ \-\-ignoreskippedcluster ]
+.RB [ \-\-logonly ]
 .RB [ \-\-nameprefixes ]
 .RB [ \-\-noheadings ]
 .RB [ \-\-nosuffix ]
-.RB [ \-o | \-\-options
-.RI [ + | \- | # ] Field [ ,Field ...]]
-.RB [ \-O | \-\-sort
-.RI [ + | \- ] Key1 [ , [ + | \- ] Key2 ...]]
 .RB [ \-P | \-\-partial ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-\-rows ]
 .RB [ \-\-segments ]
-.RB [ \-S | \-\-select
-.IR Selection ]
 .RB [ \-\-separator
 .IR Separator ]
 .RB [ \-\-unbuffered ]
@@ -51,6 +57,18 @@ Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
 .TP
+.B \-\-configreport  \fI ReportName
+Make any subsequent \fB\-o, \-\-options\fP, \fB\-O, \-\-sort\fP or
+\fB\-S, \-\-select\fP to apply for \fIReportName\fP where \fIReportName\fP
+is either 'pvs' for command's main report or 'log' for log report.
+If \fB\-\-configreport\fP option is not used to identify a report, then
+command's main report is assumed. The log report is available only if
+enabled by \fBlog/report_command_log\fP \fBlvm.conf\fP(5) setting or
+if \fB\-\-logonly\fP option is used.
+.TP
+.B \-\-logonly
+Suppress the pvs report itself and display only log report on output.
+.TP
 .B \-\-nameprefixes
 Add an "LVM2_" prefix plus the field name to the output.  Useful
 with \fB\-\-noheadings\fP to produce a list of field=value pairs that can
diff --git a/man/pvscan.8.in b/man/pvscan.8.in
index 010c091..38f424f 100644
--- a/man/pvscan.8.in
+++ b/man/pvscan.8.in
@@ -13,6 +13,8 @@ pvscan \(em scan all disks for physical volumes
 .RB [ \-\-ignorelockingfailure ]
 .RB [ \-e | \-\-exported ]
 .RB [ \-n | \-\-novolumegroup ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-s | \-\-short ]
 .RB [ \-u | \-\-uuid ]
 .BR
@@ -23,6 +25,8 @@ pvscan \(em scan all disks for physical volumes
 .B \-\-cache
 .RB [ \-a | \-\-activate " " \fIay ]
 .RB [ \-b | \-\-background ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-\-major
 .I major
 .B \-\-minor
diff --git a/man/vgcfgbackup.8.in b/man/vgcfgbackup.8.in
index 898764a..c6f20d9 100644
--- a/man/vgcfgbackup.8.in
+++ b/man/vgcfgbackup.8.in
@@ -11,6 +11,8 @@ vgcfgbackup \(em backup volume group descriptor area
 .RB [ \-h | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
 .RB [ \-P | \-\-partial ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-v | \-\-verbose ]
 .RI [ VolumeGroupName ...]
 .SH DESCRIPTION
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index e334fd1..3b2fc3e 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -49,6 +49,8 @@ vgchange \(em change attributes of a volume group
 .RB [ \-P | \-\-partial ]
 .RB [ \-s | \-\-physicalextentsize
 .IR PhysicalExtentSize [ bBsSkKmMgGtTpPeE ]]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-S | \-\-select
 .IR Selection ]
 .RB [ \-\-systemid
diff --git a/man/vgck.8.in b/man/vgck.8.in
index f09e709..b10f57e 100644
--- a/man/vgck.8.in
+++ b/man/vgck.8.in
@@ -7,6 +7,8 @@ vgck \(em check volume group metadata
 .IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-v | \-\-verbose ]
 .RI [ VolumeGroupName ...]
 .SH DESCRIPTION
diff --git a/man/vgconvert.8.in b/man/vgconvert.8.in
index c77d529..d864483 100644
--- a/man/vgconvert.8.in
+++ b/man/vgconvert.8.in
@@ -18,6 +18,8 @@ vgconvert \- convert volume group metadata format
 .IR NumberOfCopies ]
 .RB [ \-\-metadatasize
 .IR size ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-\-version ]
 .I VolumeGroupName
 .RI [ VolumeGroupName ...]
diff --git a/man/vgcreate.8.in b/man/vgcreate.8.in
index 764d76e..c66753b 100644
--- a/man/vgcreate.8.in
+++ b/man/vgcreate.8.in
@@ -27,6 +27,8 @@ vgcreate \(em create a volume group
 .IR NumberOfCopies | unmanaged | all ]
 .RB [ \-s | \-\-physicalextentsize
 .IR PhysicalExtentSize [ bBsSkKmMgGtTpPeE ]]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-\-shared ]
 .RB [ \-\-systemid
 .IR SystemID ]
diff --git a/man/vgdisplay.8.in b/man/vgdisplay.8.in
index 89a7a5a..045a6ae 100644
--- a/man/vgdisplay.8.in
+++ b/man/vgdisplay.8.in
@@ -7,6 +7,8 @@ vgdisplay \(em display attributes of volume groups
 .RB [ \-c | \-\-colon ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-s | \-\-short ]
 .RB [ \-S | \-\-select
 .IR Selection ]
@@ -30,19 +32,25 @@ vgdisplay \(em display attributes of volume groups
 .RB [ \-\-binary ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
+.RB [[ \-\-configreport
+.IR ReportName ]
+.RB [ \-o | \-\-options
+.RI [ + | \- | # ] Field1 [, Field2 ...]
+.RB [ \-O | \-\-sort
+.RI [ + | \- ] Key1 [, Key2 ...]]
+.RB [ \-S | \-\-select
+.IR Selection ]
+.RB ...]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
 .RB [ \-\-ignoreskippedcluster ]
+.RB [ \-\-logonly ]
 .RB [ \-\-noheadings ]
 .RB [ \-\-nosuffix ]
-.RB [ \-o|\-\-options
-.RI [ + | \- | # ] Field1 [ ,Field2 ...]]
-.RB [ \-O | \-\-sort
-.RI [ + | \- ] Key1 [ , [ + | \- ] Key2 ...]]
 .RB [ \-P | \-\-partial ]
-.RB [ \-S | \-\-select
-.IR Selection ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-\-separator
 .IR Separator ]
 .RB [ \-\-unbuffered ]
diff --git a/man/vgexport.8.in b/man/vgexport.8.in
index 08c1d78..6e2ecbf 100644
--- a/man/vgexport.8.in
+++ b/man/vgexport.8.in
@@ -8,6 +8,8 @@ vgexport \- make volume groups unknown to the system
 .IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-S | \-\-select
 .IR Selection ]
 .RB [ \-v | \-\-verbose ]
diff --git a/man/vgextend.8.in b/man/vgextend.8.in
index 52837db..51bd615 100644
--- a/man/vgextend.8.in
+++ b/man/vgextend.8.in
@@ -9,6 +9,8 @@ vgextend \(em add physical volumes to a volume group
 .IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-\-restoremissing ]
 .RB [ \-f | \-\-force ]
 .RB [ \-t | \-\-test ]
diff --git a/man/vgimport.8.in b/man/vgimport.8.in
index cd34049..ba4fdf9 100644
--- a/man/vgimport.8.in
+++ b/man/vgimport.8.in
@@ -6,6 +6,8 @@ vgimport \(em make exported volume groups known to the system
 .RB [ \-a | \-\-all ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-S | \-\-select
 .IR Selection ]
 .RB [ \-v | \-\-verbose ]
diff --git a/man/vgmknodes.8.in b/man/vgmknodes.8.in
index 4f5bbfe..c5bb5d4 100644
--- a/man/vgmknodes.8.in
+++ b/man/vgmknodes.8.in
@@ -8,6 +8,8 @@ vgmknodes \(em recreate volume group directory and logical volume special files
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-\-refresh ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-v | \-\-verbose ]
 .RI [[ VolumeGroupName | LogicalVolumePath ]...]
 .SH DESCRIPTION
diff --git a/man/vgreduce.8.in b/man/vgreduce.8.in
index 9e70a0a..cce31e8 100644
--- a/man/vgreduce.8.in
+++ b/man/vgreduce.8.in
@@ -11,6 +11,8 @@ vgreduce \(em reduce a volume group
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-removemissing ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .I VolumeGroupName
diff --git a/man/vgremove.8.in b/man/vgremove.8.in
index 082c1f3..4e600ef 100644
--- a/man/vgremove.8.in
+++ b/man/vgremove.8.in
@@ -9,6 +9,8 @@ vgremove \(em remove a volume group
 .RB [ \-f | \-\-force ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-noudevsync ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-S | \-\-select
 .IR Selection ]
 .RB [ \-t | \-\-test ]
diff --git a/man/vgrename.8.in b/man/vgrename.8.in
index 1f2539b..322d740 100644
--- a/man/vgrename.8.in
+++ b/man/vgrename.8.in
@@ -9,6 +9,8 @@ vgrename \(em rename a volume group
 .IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .IR OldVolumeGroup { Path | Name | UUID }
diff --git a/man/vgs.8.in b/man/vgs.8.in
index f219665..ab9d9ac 100644
--- a/man/vgs.8.in
+++ b/man/vgs.8.in
@@ -8,21 +8,27 @@ vgs \(em report information about volume groups
 .RB [ \-\-binary ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
+.RB [[ \-\-configreport
+.IR ReportName ]
+.RB [ \-o | \-\-options
+.RI [ + | \- | # ] Field1 [, Field2 ...]
+.RB [ \-O | \-\-sort
+.RI [ + | \- ] Key1 [, Key2 ...]]
+.RB [ \-S | \-\-select
+.IR Selection ]
+.RB ...]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
 .RB [ \-\-ignoreskippedcluster ]
+.RB [ \-\-logonly ]
 .RB [ \-\-nameprefixes ]
 .RB [ \-\-noheadings ]
 .RB [ \-\-nosuffix ]
-.RB [ \-o | \-\-options
-.RI [ + | \- | # ] Field1 [ ,Field2 ...]]
-.RB [ \-O | \-\-sort
-.RI [ + | \- ] Key1 [ , [ + | \- ] Key2 ...]]
 .RB [ \-P | \-\-partial ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-\-rows ]
-.RB [ \-S | \-\-select
-.IR Selection ]
 .RB [ \-\-separator
 .IR Separator ]
 .RB [ \-\-unbuffered ]
@@ -49,6 +55,18 @@ Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
 .TP
+.B \-\-configreport  \fI ReportName
+Make any subsequent \fB\-o, \-\-options\fP, \fB\-O, \-\-sort\fP or
+\fB\-S, \-\-select\fP to apply for \fIReportName\fP where \fIReportName\fP
+is either 'vgs' for command's main report or 'log' for log report.
+If \fB\-\-configreport\fP option is not used to identify a report, then
+command's main report is assumed. The log report is available only if
+enabled by \fBlog/report_command_log\fP \fBlvm.conf\fP(5) setting or
+if \fB\-\-logonly\fP option is used.
+.TP
+.B \-\-logonly
+Suppress the vgs report itself and display only log report on output.
+.TP
 .B \-\-nameprefixes
 Add an "LVM2_" prefix plus the field name to the output.  Useful
 with \fB\-\-noheadings\fP to produce a list of field=value pairs that can
diff --git a/man/vgscan.8.in b/man/vgscan.8.in
index 8c699d1..e85d817 100644
--- a/man/vgscan.8.in
+++ b/man/vgscan.8.in
@@ -11,6 +11,8 @@ vgscan \(em scan all disks for volume groups and rebuild caches
 .RB [ \-\-mknodes ]
 .RB [ \-\-notifydbus ]
 .RB [ \-P | \-\-partial ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
 .RB [ \-v | \-\-verbose ]
 .SH DESCRIPTION
 vgscan scans all SCSI, (E)IDE disks, multiple devices and a bunch


