From: David Teigland <teigland@sourceware.org>
Date: Wed, 15 Mar 2017 17:00:41 -0400
Subject: master - man: remove blank lines from end/des files
Message-ID: <201703152100.v2FL0fKM027150@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7b6ee130cc5cf0e466d9b91b7b7726267575d310
Commit:        7b6ee130cc5cf0e466d9b91b7b7726267575d310
Parent:        5c5df43ea31ec848a1d5483541afb75c67e3558f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 15 15:59:43 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 15 15:59:43 2017 -0500

man: remove blank lines from end/des files

which produce unwanted blank lines in some output
formats.
---
 man/lvchange.8_end      |    1 -
 man/lvconvert.8_des     |    1 -
 man/lvconvert.8_end     |    1 -
 man/lvm-lvpoll.8_end    |    2 --
 man/lvreduce.8_des      |    1 -
 man/lvremove.8_des      |    1 -
 man/lvremove.8_end      |    3 ---
 man/lvrename.8_end      |    1 -
 man/lvresize.8_des      |    1 -
 man/lvresize.8_end      |    1 -
 man/lvs.8_end           |    1 -
 man/pvcreate.8_end      |    1 -
 man/pvmove.8_des        |    1 -
 man/pvmove.8_end        |    2 --
 man/pvresize.8_end      |    4 ----
 man/pvs.8_end           |    2 --
 man/pvscan.8_des        |   12 ------------
 man/see_also.end        |    1 -
 man/vgchange.8_end      |    4 ----
 man/vgconvert.8_des     |    1 -
 man/vgcreate.8_end      |    1 -
 man/vgextend.8_end      |    1 -
 man/vgimportclone.8_end |    1 -
 man/vgmerge.8_end       |    1 -
 man/vgrename.8_end      |    1 -
 25 files changed, 0 insertions(+), 47 deletions(-)

diff --git a/man/lvchange.8_end b/man/lvchange.8_end
index 0ae1cce..99de8a8 100644
--- a/man/lvchange.8_end
+++ b/man/lvchange.8_end
@@ -1,5 +1,4 @@
 .SH EXAMPLES
-
 Change LV permission to read-only:
 .sp
 .B lvchange \-pr vg00/lvol1
diff --git a/man/lvconvert.8_des b/man/lvconvert.8_des
index 0548c2c..f1efcbd 100644
--- a/man/lvconvert.8_des
+++ b/man/lvconvert.8_des
@@ -62,4 +62,3 @@ and vice-versa by e.g. linear <-> raid1 <-> raid5_n (then adding stripes) <-> st
 
 Sub LVs can be displayed with the command
 .B lvs -a
-
diff --git a/man/lvconvert.8_end b/man/lvconvert.8_end
index bd17434..a329acd 100644
--- a/man/lvconvert.8_end
+++ b/man/lvconvert.8_end
@@ -17,7 +17,6 @@ If LV1 was not a cache pool, the command would convert LV1 to
 a cache pool, optionally using a specified LV for metadata.
 But, if LV1 was already a cache pool, the command would swap
 the current metadata LV with LV2 (for repair purposes.)
-
 .SH EXAMPLES
 Convert a linear LV to a two-way mirror LV.
 .br
diff --git a/man/lvm-lvpoll.8_end b/man/lvm-lvpoll.8_end
index eddb364..d38dfd0 100644
--- a/man/lvm-lvpoll.8_end
+++ b/man/lvm-lvpoll.8_end
@@ -4,7 +4,6 @@ To find the name of the pvmove LV that was created by an original
 \fBpvmove /dev/name\fP command, use the command:
 .br
 \fBlvs -a -S move_pv=/dev/name\fP.
-
 .SH EXAMPLES
 
 Continue polling a pvmove operation.
@@ -30,4 +29,3 @@ Continue snapshot merge.
 Continue thin snapshot merge.
 .br
 .B lvm lvpoll --polloperation merge_thin vg/thin_snapshot
-
diff --git a/man/lvreduce.8_des b/man/lvreduce.8_des
index 3d5fc2a..487954d 100644
--- a/man/lvreduce.8_des
+++ b/man/lvreduce.8_des
@@ -16,4 +16,3 @@ multiple of the number of stripes.
 In the usage section below, \fB--size\fP \fISize\fP can be replaced
 with \fB--extents\fP \fINumber\fP.  See both descriptions
 the options section.
-
diff --git a/man/lvremove.8_des b/man/lvremove.8_des
index 14587c1..a9b4813 100644
--- a/man/lvremove.8_des
+++ b/man/lvremove.8_des
@@ -24,4 +24,3 @@ some intermediate LVs have been removed. The names of such historical LVs
 acquire a hyphen as a prefix (e.g. '-lvol1') and cannot be reactivated.
 Use lvremove a second time, with the hyphen, to remove the record of the
 former LV completely.
-
diff --git a/man/lvremove.8_end b/man/lvremove.8_end
index 5c70ed6..835b711 100644
--- a/man/lvremove.8_end
+++ b/man/lvremove.8_end
@@ -1,5 +1,4 @@
 .SH EXAMPLES
-
 Remove an active LV without asking for confirmation.
 .br
 .B lvremove \-f vg00/lvol1
@@ -7,5 +6,3 @@ Remove an active LV without asking for confirmation.
 Remove all LVs the specified VG.
 .br
 .B lvremove vg00
-
-
diff --git a/man/lvrename.8_end b/man/lvrename.8_end
index 3409b8a..ab7c7bd 100644
--- a/man/lvrename.8_end
+++ b/man/lvrename.8_end
@@ -7,4 +7,3 @@ Rename "lvold" to "lvnew":
 An alternate syntax to rename "lvold" to "lvnew":
 .br
 .B lvrename vg02 lvold lvnew
-
diff --git a/man/lvresize.8_des b/man/lvresize.8_des
index 6f39ef7..dcc42aa 100644
--- a/man/lvresize.8_des
+++ b/man/lvresize.8_des
@@ -4,4 +4,3 @@ lvresize resizes an LV in the same way as lvextend and lvreduce. See
 In the usage section below, \fB--size\fP \fISize\fP can be replaced
 with \fB--extents\fP \fINumber\fP.  See both descriptions
 the options section.
-
diff --git a/man/lvresize.8_end b/man/lvresize.8_end
index a336d62..9ae0a2a 100644
--- a/man/lvresize.8_end
+++ b/man/lvresize.8_end
@@ -3,4 +3,3 @@
 Extend an LV by 16MB using specific physical extents:
 .br
 .B lvresize \-L+16M vg1/lv1 /dev/sda:0\-1 /dev/sdb:0\-1
-
diff --git a/man/lvs.8_end b/man/lvs.8_end
index ff92148..f24ffe9 100644
--- a/man/lvs.8_end
+++ b/man/lvs.8_end
@@ -73,4 +73,3 @@ Related to Thin Logical Volumes: (F)ailed.
 is permitted at all.
 .IP 10 3
 s(k)ip activation: this volume is flagged to be skipped during activation.
-
diff --git a/man/pvcreate.8_end b/man/pvcreate.8_end
index b1b0f3e..478abe3 100644
--- a/man/pvcreate.8_end
+++ b/man/pvcreate.8_end
@@ -10,4 +10,3 @@ sectors start at LBA -1, and consequently sector 63 is aligned on a 4KiB
 boundary) manually account for this when initializing for use by LVM.
 .br
 .B pvcreate \-\-dataalignmentoffset 7s /dev/sdb
-
diff --git a/man/pvmove.8_des b/man/pvmove.8_des
index c003c5e..0786f9b 100644
--- a/man/pvmove.8_des
+++ b/man/pvmove.8_des
@@ -13,4 +13,3 @@ after an abort depends on whether the atomic option was used.
 More than one pvmove can run concurrently if they are moving data from
 different source PVs, but additional pvmoves will ignore any LVs already
 in the process of being changed, so some data might not get moved.
-
diff --git a/man/pvmove.8_end b/man/pvmove.8_end
index 906606d..68f6ef5 100644
--- a/man/pvmove.8_end
+++ b/man/pvmove.8_end
@@ -1,5 +1,4 @@
 .SH NOTES
-
 pvmove works as follows:
 
 1. A temporary 'pvmove' LV is created to store details of all the data
@@ -90,4 +89,3 @@ The part of a specific LV present within in a range of physical
 extents can also be picked out and moved.
 .br
 .B pvmove \-n lvol1 /dev/sdb1:1000\-1999 /dev/sdc1
-
diff --git a/man/pvresize.8_end b/man/pvresize.8_end
index 316e408..bedc334 100644
--- a/man/pvresize.8_end
+++ b/man/pvresize.8_end
@@ -1,10 +1,7 @@
 .SH NOTES
-
 pvresize will refuse to shrink a PV if it has allocated extents beyond the
 new end.
-
 .SH EXAMPLES
-
 Expand a PV after enlarging the partition.
 .br
 .B pvresize /dev/sda1
@@ -13,4 +10,3 @@ Shrink a PV prior to shrinking the partition (ensure that the PV size is
 appropriate for the intended new partition size).
 .br
 .B pvresize \-\-setphysicalvolumesize 40G /dev/sda1
-
diff --git a/man/pvs.8_end b/man/pvs.8_end
index ba36a8b..e47d8e8 100644
--- a/man/pvs.8_end
+++ b/man/pvs.8_end
@@ -7,5 +7,3 @@ The pv_attr bits are:
 e(x)ported
 .IP 3 3
 (m)issing
-
-
diff --git a/man/pvscan.8_des b/man/pvscan.8_des
index ab8c50c..1a24a3d 100644
--- a/man/pvscan.8_des
+++ b/man/pvscan.8_des
@@ -31,15 +31,12 @@ historical reasons.  To avoid disrupting the system with extraneous disk
 scanning, an ordinary pvscan (without \-\-cache) will simply read metadata
 from lvmetad like other LVM commands.  It does not do anything beyond
 displaying the current state of the cache.
-
 .IP \[bu] 2
 When given specific device name arguments, pvscan \-\-cache will only
 read the named devices.
-
 .IP \[bu] 2
 LVM udev rules and systemd services are used to initiate automatic device
 scanning.
-
 .IP \[bu] 2
 To prevent devices from being scanned by pvscan --cache, add them
 to
@@ -50,22 +47,17 @@ apply to system level scanning.
 For more information, see:
 .br
 .B lvmconfig --withcomments devices/global_filter
-
 .IP \[bu] 2
 If lvmetad is started or restarted after devices are visible, or
 if the global_filter has changed, then all devices must be rescanned
 for metadata with the command pvscan \-\-cache.
-
 .IP \[bu] 2
 lvmetad does not cache older metadata formats, e.g. lvm1, and will
 be temporarily disabled if they are seen.
-
 .IP \[bu] 2
 To notify lvmetad about a device that is no longer present, the major and
 minor numbers must be given, not the path.
-
 .P
-
 \fBAutomatic activation\fP
 
 When event-driven system services detect a new LVM device, the first step
@@ -89,17 +81,13 @@ fully integrated with the event-driven system services.)
 
 When a VG or LV is not auto-activated, traditional activation using
 vgchange or lvchange -a|--activate is needed.
-
 .IP \[bu] 2
 pvscan auto-activation can be only done in combination with \-\-cache.
-
 .IP \[bu] 2
 Auto-activation is designated by the "a" argument in '-a|--activate ay'.
 This is meant to distinguish system generated commands from explicit user
 commands, although it can be used in any activation command.  Whenever it
 is used, the auto_activation_volume_list is applied.
-
 .IP \[bu] 2
 Auto-activation is not yet supported for LVs that are part of partial or
 clustered volume groups.
-
diff --git a/man/see_also.end b/man/see_also.end
index 70eeb89..9e7d3b2 100644
--- a/man/see_also.end
+++ b/man/see_also.end
@@ -64,4 +64,3 @@
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/vgchange.8_end b/man/vgchange.8_end
index a11bdd1..6cf9e87 100644
--- a/man/vgchange.8_end
+++ b/man/vgchange.8_end
@@ -1,11 +1,8 @@
 .SH NOTES
-
 If vgchange recognizes COW snapshot LVs that were dropped because they ran
 out of space, it displays a message informing the administrator that the
 snapshots should be removed.
-
 .SH EXAMPLES
-
 Activate all LVs in all VGs on all existing devices.
 .br
 .B vgchange \-a y
@@ -13,4 +10,3 @@ Activate all LVs in all VGs on all existing devices.
 Change the maximum number of LVs for an inactive VG.
 .br
 .B vgchange \-l 128 vg00
-
diff --git a/man/vgconvert.8_des b/man/vgconvert.8_des
index 47bc0cc..a0d34fd 100644
--- a/man/vgconvert.8_des
+++ b/man/vgconvert.8_des
@@ -4,4 +4,3 @@ format.
 
 Because the LVM1 format should no longer be used, this command is no
 longer needed in general.
-
diff --git a/man/vgcreate.8_end b/man/vgcreate.8_end
index 66bcfbb..e4c81e3 100644
--- a/man/vgcreate.8_end
+++ b/man/vgcreate.8_end
@@ -3,4 +3,3 @@
 Create a VG with two PVs, using the default physical extent size.
 .br
 .B vgcreate myvg /dev/sdk1 /dev/sdl1
-
diff --git a/man/vgextend.8_end b/man/vgextend.8_end
index e50fcce..7cd8fd6 100644
--- a/man/vgextend.8_end
+++ b/man/vgextend.8_end
@@ -3,4 +3,3 @@
 Add two PVs to a VG.
 .br
 .B vgextend vg00 /dev/sda4 /dev/sdn1
-
diff --git a/man/vgimportclone.8_end b/man/vgimportclone.8_end
index 83394b5..4b236f6 100644
--- a/man/vgimportclone.8_end
+++ b/man/vgimportclone.8_end
@@ -6,4 +6,3 @@ Rename the VG associated with "/dev/sdc" and "/dev/sdd" from "vg00" to "vg00_sna
 (and change associated UUIDs).
 .br
 .B vgimportclone \-\-basevgname vg00_snap /dev/sdc /dev/sdd
-
diff --git a/man/vgmerge.8_end b/man/vgmerge.8_end
index 9787c6a..b65d044 100644
--- a/man/vgmerge.8_end
+++ b/man/vgmerge.8_end
@@ -4,4 +4,3 @@ Merge an inactive VG named "vg00" into the active or inactive VG named
 "databases", giving verbose runtime information.
 .br
 .B vgmerge \-v databases vg00
-
diff --git a/man/vgrename.8_end b/man/vgrename.8_end
index 98eeb53..2d191cf 100644
--- a/man/vgrename.8_end
+++ b/man/vgrename.8_end
@@ -7,4 +7,3 @@ Rename VG "vg02" to "myvg":
 Rename the VG with the specified UUID to "myvg".
 .br
 .B vgrename Zvlifi\-Ep3t\-e0Ng\-U42h\-o0ye\-KHu1\-nl7Ns4 myvg
-


