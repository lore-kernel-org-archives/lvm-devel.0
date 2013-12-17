From: Ville Skyttä <ville.skytta@iki.fi>
Date: Tue, 17 Dec 2013 20:26:11 +0200
Subject: [PATCH 2/2] Man page spelling fixes.
In-Reply-To: <1387304771-19004-1-git-send-email-ville.skytta@iki.fi>
References: <1387304771-19004-1-git-send-email-ville.skytta@iki.fi>
Message-ID: <1387304771-19004-2-git-send-email-ville.skytta@iki.fi>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 man/lvconvert.8.in | 2 +-
 man/lvm.8.in       | 2 +-
 man/lvreduce.8.in  | 2 +-
 man/lvresize.8.in  | 2 +-
 man/pvmove.8.in    | 2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 44b89af..c8cb2dc 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -203,7 +203,7 @@ a mirror logical volume.
 .B \-\-trackchanges
 Used with \fB\-\-splitmirrors\fP on a raid1 device, this tracks changes so
 that the read-only detached image can be merged efficiently back into
-the mirror later. Only the regions of the detatched device where
+the mirror later. Only the regions of the detached device where
 the data changed get resynchronized.
 
 Please note that this feature is only supported with the new md-based mirror
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 02a8c0d..d78281a 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -21,7 +21,7 @@ that command.
 On invocation, \fBlvm\fP requires that only the standard file descriptors
 stdin, stdout and stderr are available.  If others are found, they
 get closed and messages are issued warning about the leak.
-This warning can be suppressed by setting enviromental variable
+This warning can be suppressed by setting the environment variable
 .B LVM_SUPPRESS_FD_WARNINGS\fP.
 .LP
 Where commands take VG or LV names as arguments, the full path name is
diff --git a/man/lvreduce.8.in b/man/lvreduce.8.in
index dabdc88..2c38f5b 100644
--- a/man/lvreduce.8.in
+++ b/man/lvreduce.8.in
@@ -57,7 +57,7 @@ size of the Logical Volume with the suffix \fI%LV\fP, as a percentage of the
 remaining free space in the Volume Group with the suffix \fI%FREE\fP, or (for
 a snapshot) as a percentage of the total space in the Origin Logical
 Volume with the suffix \fI%ORIGIN\fP.
-The resulting value for the substraction is rounded downward, for the absolute
+The resulting value for the subtraction is rounded downward, for the absolute
 size it is rounded upward.
 .TP
 .IR \fB\-L ", " \fB\-\-size " [" \- ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
diff --git a/man/lvresize.8.in b/man/lvresize.8.in
index e04869d..3606762 100644
--- a/man/lvresize.8.in
+++ b/man/lvresize.8.in
@@ -56,7 +56,7 @@ the remaining free space of the PhysicalVolumes on the command line with the
 suffix \fI%PVS\fP, as a percentage of the remaining free space in the
 Volume Group with the suffix \fI%FREE\fP, or (for a snapshot) as a percentage
 of the total space in the Origin Logical Volume with the suffix \fI%ORIGIN\fP.
-The resulting value is rounded downward for the substraction otherwise
+The resulting value is rounded downward for the subtraction otherwise
 it is rounded upward.
 .TP
 .IR \fB\-L ", " \fB\-\-size " [" + | - ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
diff --git a/man/pvmove.8.in b/man/pvmove.8.in
index c77dcbc..bb69547 100644
--- a/man/pvmove.8.in
+++ b/man/pvmove.8.in
@@ -131,7 +131,7 @@ also refers to 1000 Physical Extents starting from Physical Extent number 1000.
 (Counting starts from 0, so this refers to the 1001st to the 2000th inclusive.)
 .P
 To move a range of Physical Extents to a specific location (which must have
-sufficent free extents) use the form:
+sufficient free extents) use the form:
 .sp
 .B pvmove /dev/sdb1:1000-1999 /dev/sdc1
 .sp
-- 
1.8.3.1


