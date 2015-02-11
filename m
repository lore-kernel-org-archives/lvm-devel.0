From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 11 Feb 2015 09:11:52 +0000 (UTC)
Subject: master - man: reference -S/--select in {vg, lv, pv}change, {vg, lv}remove, {vg, lv, pv}display and vg{import, export} man pages
Message-ID: <20150211091152.9E9B960D7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=437b17964cfe8fc73fe224589c62c47f2b2665dc
Commit:        437b17964cfe8fc73fe224589c62c47f2b2665dc
Parent:        bc1bb7f8c5cd38bdebe18ebbee270882a4ee82d3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Feb 11 10:03:37 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Feb 11 10:04:21 2015 +0100

man: reference -S/--select in {vg,lv,pv}change, {vg,lv}remove, {vg,lv,pv}display and vg{import,export} man pages

---
 man/lvchange.8.in  |    3 ++-
 man/lvdisplay.8.in |    8 ++++----
 man/lvm.8.in       |    5 +++--
 man/lvremove.8.in  |    3 ++-
 man/pvchange.8.in  |    2 ++
 man/pvdisplay.8.in |    8 ++++----
 man/vgchange.8.in  |    2 ++
 man/vgdisplay.8.in |    8 ++++----
 man/vgexport.8.in  |    3 ++-
 man/vgimport.8.in  |    3 ++-
 man/vgremove.8.in  |    3 ++-
 11 files changed, 29 insertions(+), 19 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index bb5bea5..fbae953 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -68,11 +68,12 @@ lvchange \(em change attributes of a logical volume
 .RB [ \-r | \-\-readahead
 .RI { ReadAheadSectors | auto | none }]
 .RB [ \-\-refresh ]
+.RB [ \-S | \-\-select
+.IR Selection ]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-Z | \-\-zero
 .RI { y | n }]
-.I LogicalVolumePath
 .RI [ LogicalVolumePath ...]
 .SH DESCRIPTION
 lvchange allows you to change the attributes of a logical volume
diff --git a/man/lvdisplay.8.in b/man/lvdisplay.8.in
index 3232853..ed1d3f7 100644
--- a/man/lvdisplay.8.in
+++ b/man/lvdisplay.8.in
@@ -14,12 +14,13 @@ lvdisplay \(em display attributes of a logical volume
 .RB [ \-\-maps ]
 .RB [ \-\-nosuffix ]
 .RB [ \-P | \-\-partial ]
+.RB [ \-S | \-\-select
+.IR Selection ]
 .RB [ \-\-units
 .IR hHbBsSkKmMgGtTpPeE ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
-.RI [ VolumeGroupName | LogicalVolume { Name | Path }
-.RI [ VolumeGroupName | LogicalVolume { Name | Path }\ ...]]
+.RI [ VolumeGroupName | LogicalVolume { Name | Path }\ ...]
 .br
 
 .B lvdisplay
@@ -50,8 +51,7 @@ lvdisplay \(em display attributes of a logical volume
 .IR hHbBsSkKmMgGtTpPeE ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
-.RI [ VolumeGroupName | LogicalVolume { Name | Path }
-.RI [ VolumeGroupName | LogicalVolume { Name | Path }\ ...]]
+.RI [ VolumeGroupName | LogicalVolume { Name | Path }\ ...]
 .SH DESCRIPTION
 lvdisplay allows you to see the attributes of a logical volume
 like size, read/write status, snapshot information etc.
diff --git a/man/lvm.8.in b/man/lvm.8.in
index f87729e..7bc4c6b 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -210,8 +210,9 @@ match the original followed by \fBvgcfgrestore\fP(8).
 .BR \-S ", " \-\-select " " \fISelection
 For reporting commands, display only rows that match selection criteria.
 All rows are displayed with the additional "selected" column (\fB-o selected\fP)
-showing 1 if the row matches the Selection and 0 otherwise.
-See \fBSELECTION CRITERIA\fP section of this man page for more
+showing 1 if the row matches the Selection and 0 otherwise. For non-reporting
+commands which process LVM entities, the selection can be used to match items
+to process. See \fBSELECTION CRITERIA\fP section of this man page for more
 information about the way the selection criteria are constructed.
 .TP
 .BR \-M ", " \-\-metadatatype " " \fIType
diff --git a/man/lvremove.8.in b/man/lvremove.8.in
index 8426cac..8cf1bf3 100644
--- a/man/lvremove.8.in
+++ b/man/lvremove.8.in
@@ -9,12 +9,13 @@ lvremove \(em remove a logical volume
 .IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
+.RB [ \-S | \-\-select
+.IR Selection ]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
 .RB [ \-f | \-\-force ]
 .RB [ \-\-noudevsync ]
-.IR LogicalVolume { Name |  Path }
 .RI [ LogicalVolume { Name | Path }...]
 .SH DESCRIPTION
 lvremove removes one or more logical volumes.
diff --git a/man/pvchange.8.in b/man/pvchange.8.in
index 606b1dd..5c5b809 100644
--- a/man/pvchange.8.in
+++ b/man/pvchange.8.in
@@ -16,6 +16,8 @@ pvchange \(em change attributes of a physical volume
 .RB [ \-\-metadataignore
 .RI { y | n }]
 .RB [ \-h | \-? | \-\-help ]
+.RB [ \-S | \-\-select
+.IR Selection ]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-a | \-\-all ]
diff --git a/man/pvdisplay.8.in b/man/pvdisplay.8.in
index 70c9bfc..c1232d6 100644
--- a/man/pvdisplay.8.in
+++ b/man/pvdisplay.8.in
@@ -13,13 +13,14 @@ pvdisplay \- display attributes of a physical volume
 .RB [ \-\-maps ]
 .RB [ \-\-nosuffix ]
 .RB [ \-s | \-\-short ]
+.RB [ \-S | \-\-select
+.IR Selection ]
 .RB [ \-\-units
 .IR hsbkmgtHKMGT ]
 .RB [ \-v [ v ]| \-\-verbose
 .RB [ \-\-verbose ]]
 .RB [ \-\-version ]
-.RI [ PhysicalVolumePath
-.RI [ PhysicalVolumePath ...]]
+.RI [ PhysicalVolumePath ...]
 .br
 
 .br
@@ -50,8 +51,7 @@ pvdisplay \- display attributes of a physical volume
 .RB [ \-v [ v ]| \-\-verbose
 .RB [ \-\-verbose ]]
 .RB [ \-\-version ]
-.RI [ PhysicalVolumePath
-.RI [ PhysicalVolumePath ...]]
+.RI [ PhysicalVolumePath ...]
 .SH DESCRIPTION
 pvdisplay allows you to see the attributes of one or more physical volumes
 like size, physical extent size, space used for the volume group descriptor
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index dcd1faf..5014300 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -45,6 +45,8 @@ vgchange \(em change attributes of a volume group
 .RB [ \-P | \-\-partial ]
 .RB [ \-s | \-\-physicalextentsize
 .IR PhysicalExtentSize [ bBsSkKmMgGtTpPeE ]]
+.RB [ \-S | \-\-select
+.IR Selection ]
 .RB [ \-\-refresh ]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
diff --git a/man/vgdisplay.8.in b/man/vgdisplay.8.in
index 1e472d3..172dba4 100644
--- a/man/vgdisplay.8.in
+++ b/man/vgdisplay.8.in
@@ -8,6 +8,8 @@ vgdisplay \(em display attributes of volume groups
 .RB [ \-\-commandprofile
 .IR ProfileName ]
 .RB [ \-s | \-\-short ]
+.RB [ \-S | \-\-select
+.IR Selection ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
@@ -18,8 +20,7 @@ vgdisplay \(em display attributes of volume groups
 .RB [ \-\-units
 .IR hHbBsSkKmMgGtTpPeE ]
 .RB [ \-\-version ]
-.RI [ VolumeGroupName
-.RI [ VolumeGroupName ...]]
+.RI [ VolumeGroupName ...]
 .br
 
 .br
@@ -49,8 +50,7 @@ vgdisplay \(em display attributes of volume groups
 .IR hHbBsSkKmMgGtTpPeE ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
-.RI [ VolumeGroupName
-.RI [ VolumeGroupName ...]]
+.RI [ VolumeGroupName ...]
 .SH DESCRIPTION
 vgdisplay allows you to see the attributes of
 .I VolumeGroupName
diff --git a/man/vgexport.8.in b/man/vgexport.8.in
index 2b31618..94a3e32 100644
--- a/man/vgexport.8.in
+++ b/man/vgexport.8.in
@@ -8,8 +8,9 @@ vgexport \- make volume groups unknown to the system
 .IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
+.RB [ \-S | \-\-select
+.IR Selection ]
 .RB [ \-v | \-\-verbose ]
-.I VolumeGroupName
 .RI [ VolumeGroupName ...]
 .SH DESCRIPTION
 vgexport allows you to make the inactive
diff --git a/man/vgimport.8.in b/man/vgimport.8.in
index 31378f4..3a8a230 100644
--- a/man/vgimport.8.in
+++ b/man/vgimport.8.in
@@ -6,8 +6,9 @@ vgimport \(em make exported volume groups known to the system
 .RB [ \-a | \-\-all ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
+.RB [ \-S | \-\-select
+.IR Selection ]
 .RB [ \-v | \-\-verbose ]
-.I VolumeGroupName
 .RI [ VolumeGroupName ...]
 .SH DESCRIPTION
 vgimport allows you to make a Volume Group that was previously
diff --git a/man/vgremove.8.in b/man/vgremove.8.in
index 10a431f..082c1f3 100644
--- a/man/vgremove.8.in
+++ b/man/vgremove.8.in
@@ -9,9 +9,10 @@ vgremove \(em remove a volume group
 .RB [ \-f | \-\-force ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-noudevsync ]
+.RB [ \-S | \-\-select
+.IR Selection ]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
-.I VolumeGroupName
 .RI [ VolumeGroupName ...]
 .SH DESCRIPTION
 vgremove allows you to remove one or more volume groups.


